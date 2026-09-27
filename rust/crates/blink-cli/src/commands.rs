//! Command implementations for blink-cli

use std::{path::Path, process::Command};

use anyhow::{Context, Result};
use colored::*;
use indicatif::{ProgressBar, ProgressStyle};
use walkdir::WalkDir;

use super::utils::*;

pub fn cmd_status(root: &Path, verbose: bool) -> Result<()> {
    println!("{}", "═══ Blink Arcana Project Status ═══".bold().cyan());
    println!();

    // Git status
    let git_status = run_cmd(root, "git", &["status", "--short"])?;
    let branch = run_cmd(root, "git", &["branch", "--show-current"])?;

    println!("{}", "📁 Git".bold());
    println!("  Branch: {}", branch.trim().green());
    if git_status.trim().is_empty() {
        println!("  Status: {}", "Clean".green());
    } else {
        println!("  Status: {}", "Dirty".yellow());
        if verbose {
            for line in git_status.lines() {
                println!("    {}", line);
            }
        }
    }
    println!();

    // Rust status
    println!("{}", "🦀 Rust".bold());
    let rust_version = run_cmd(root, "rustc", &["--version"])?;
    println!("  Toolchain: {}", rust_version.trim());

    let cargo_toml = root.join("rust/Cargo.toml");
    if cargo_toml.exists() {
        let workspace_members = count_workspace_members(&cargo_toml)?;
        println!("  Workspace crates: {}", workspace_members.to_string().cyan());
    }
    println!();

    // Build status
    println!("{}", "🔨 Build".bold());
    let debug_lib = root.join("rust/target/debug/libblink_gdext.so");
    let release_lib = root.join("rust/target/release/libblink_gdext.so");

    if debug_lib.exists() {
        let modified = std::fs::metadata(&debug_lib)?.modified()?;
        println!("  Debug: {} ({:?})", "✓".green(), modified.elapsed()?.as_secs());
    } else {
        println!("  Debug: {}", "✗".red());
    }

    if release_lib.exists() {
        let modified = std::fs::metadata(&release_lib)?.modified()?;
        println!("  Release: {} ({:?})", "✓".green(), modified.elapsed()?.as_secs());
    } else {
        println!("  Release: {}", "✗".red());
    }
    println!();

    // Godot status
    println!("{}", "🎮 Godot".bold());
    let project_godot = root.join("godot/project.godot");
    if project_godot.exists() {
        println!("  Project: {}", "Found".green());
        let ext_lib = root.join("godot/addons/blink_core/bin/libblink_gdext.so");
        if ext_lib.exists() {
            println!("  GDExtension: {}", "Installed".green());
        } else {
            println!("  GDExtension: {}", "Missing".red());
        }
    } else {
        println!("  Project: {}", "Not found".red());
    }
    println!();

    // Specs status
    println!("{}", "📋 Specs".bold());
    let specs_dir = root.join("docs/SPECS");
    if specs_dir.exists() {
        let specs: Vec<_> = WalkDir::new(&specs_dir)
            .into_iter()
            .filter_map(|e| e.ok())
            .filter(|e| e.path().extension().map_or(false, |ext| ext == "md"))
            .collect();
        println!("  Spec sheets: {}", specs.len().to_string().cyan());
        if verbose {
            for spec in &specs {
                println!("    - {}", spec.path().file_name().unwrap().to_string_lossy());
            }
        }
    } else {
        println!("  Specs dir: {}", "Not found".red());
    }

    Ok(())
}

pub fn cmd_check(root: &Path, skip: &[String], verbose: bool) -> Result<()> {
    let checks = vec![
        ("fmt", "Format check", vec!["just", "fmt-check"]),
        ("lint", "Lint check", vec!["just", "lint"]),
        ("test", "Unit tests", vec!["just", "test"]),
        ("build", "Build", vec!["just", "build"]),
    ];

    let mut failed = Vec::new();

    for (name, desc, cmd) in checks {
        if skip.contains(&name.to_string()) {
            println!("{} {}", "⏭".yellow(), desc);
            continue;
        }

        let pb = ProgressBar::new_spinner();
        pb.set_style(ProgressStyle::default_spinner().template("{spinner:.green} {msg}")?);
        pb.set_message(format!("Running {}...", desc));

        let output = Command::new(cmd[0]).args(&cmd[1..]).current_dir(root).output()?;

        pb.finish_and_clear();

        if output.status.success() {
            println!("{} {}", "✓".green(), desc);
        } else {
            println!("{} {}", "✗".red(), desc);
            failed.push((name, String::from_utf8_lossy(&output.stderr).to_string()));
            if verbose {
                eprintln!("{}", String::from_utf8_lossy(&output.stderr).red());
            }
        }
    }

    println!();
    if failed.is_empty() {
        println!("{}", "All checks passed!".bold().green());
    } else {
        println!("{}", "Some checks failed:".bold().red());
        for (name, err) in failed {
            println!("  - {}: {}", name.red(), err.lines().next().unwrap_or(""));
        }
        std::process::exit(1);
    }

    Ok(())
}

pub fn cmd_build(root: &Path, profile: &str, target: Option<&str>, verbose: bool) -> Result<()> {
    let mut args = vec!["build", "--profile", profile, "--workspace"];

    if let Some(t) = target {
        args.extend(["--target", t]);
    }

    let pb = ProgressBar::new_spinner();
    pb.set_style(ProgressStyle::default_spinner().template("{spinner:.green} {msg}")?);
    pb.set_message(format!("Building {} profile...", profile));

    let output = Command::new("cargo").args(&args).current_dir(root.join("rust")).output()?;

    pb.finish_and_clear();

    if output.status.success() {
        println!("{} Build successful!", "✓".green());

        // Copy to Godot
        copy_gdextension(root, profile)?;
        println!("{} GDExtension copied to Godot", "✓".green());
    } else {
        println!("{} Build failed!", "✗".red());
        if verbose {
            eprintln!("{}", String::from_utf8_lossy(&output.stderr).red());
        }
        std::process::exit(1);
    }

    Ok(())
}

pub fn cmd_test(root: &Path, filter: Option<&str>, all: bool, verbose: bool) -> Result<()> {
    let mut args = vec!["nextest", "run", "--workspace", "--all-features"];

    if let Some(f) = filter {
        args.extend(["--filter", f]);
    }

    let pb = ProgressBar::new_spinner();
    pb.set_style(ProgressStyle::default_spinner().template("{spinner:.green} {msg}")?);
    pb.set_message("Running tests...");

    let output = Command::new("cargo").args(&args).current_dir(root.join("rust")).output()?;

    pb.finish_and_clear();

    if output.status.success() {
        println!("{} Rust tests passed!", "✓".green());
    } else {
        println!("{} Rust tests failed!", "✗".red());
        if verbose {
            eprintln!("{}", String::from_utf8_lossy(&output.stderr).red());
        }
        std::process::exit(1);
    }

    if all {
        // Godot headless test
        let output = Command::new("godot")
            .args(&["--headless", "--script-check", "godot/project.godot"])
            .current_dir(root)
            .output()?;

        if output.status.success() {
            println!("{} Godot script check passed!", "✓".green());
        } else {
            println!("{} Godot script check failed!", "✗".red());
            if verbose {
                eprintln!("{}", String::from_utf8_lossy(&output.stderr).red());
            }
        }
    }

    Ok(())
}

pub fn cmd_new_spec(
    root: &Path,
    name: &str,
    spec_type: super::SpecType,
    verbose: bool,
) -> Result<()> {
    let specs_dir = root.join("docs/SPECS");
    std::fs::create_dir_all(&specs_dir)?;

    let file_name = format!("{}.md", name.to_lowercase().replace(' ', "-"));
    let file_path = specs_dir.join(&file_name);

    if file_path.exists() {
        println!("{} Spec already exists: {}", "✗".red(), file_path.display());
        std::process::exit(1);
    }

    let template = match spec_type {
        super::SpecType::Combat => include_str!("templates/combat_spec_template.md"),
        super::SpecType::Ai => include_str!("templates/ai_spec_template.md"),
        super::SpecType::Pathfinding => include_str!("templates/pathfinding_spec_template.md"),
        super::SpecType::Data => include_str!("templates/data_spec_template.md"),
        super::SpecType::Gdextension => include_str!("templates/gdextension_spec_template.md"),
        super::SpecType::Ui => include_str!("templates/ui_spec_template.md"),
        super::SpecType::System => include_str!("templates/system_spec_template.md"),
    };

    let content = template
        .replace("{{FEATURE_NAME}}", name)
        .replace("{{FEATURE_ID}}", &name.to_uppercase().replace(' ', "-"))
        .replace("{{DATE}}", &chrono::Local::now().format("%Y-%m-%d").to_string());

    std::fs::write(&file_path, content)?;

    println!("{} Created spec: {}", "✓".green(), file_path.display());

    Ok(())
}

pub fn cmd_validate_specs(root: &Path, verbose: bool) -> Result<()> {
    let specs_dir = root.join("docs/SPECS");

    if !specs_dir.exists() {
        println!("{} Specs directory not found", "✗".red());
        return Ok(());
    }

    let mut issues = Vec::new();

    for entry in WalkDir::new(&specs_dir).into_iter().filter_map(|e| e.ok()) {
        if entry.path().extension().map_or(false, |ext| ext == "md") {
            let content = std::fs::read_to_string(entry.path())?;

            // Check required sections
            let required = vec![
                "## 1. Overview",
                "## 2. Scope",
                "## 3. Data Structures",
                "## 4. Functions",
                "## 5. Error Types",
                "## 6. Testing Requirements",
                "## 7. Integration Points",
            ];

            for section in required {
                if !content.contains(section) {
                    issues.push(format!(
                        "{}: Missing section '{}'",
                        entry.path().file_name().unwrap().to_string_lossy(),
                        section
                    ));
                }
            }

            // Check for placeholder
            if content.contains("TODO") || content.contains("FIXME") {
                issues.push(format!(
                    "{}: Contains TODO/FIXME",
                    entry.path().file_name().unwrap().to_string_lossy()
                ));
            }
        }
    }

    if issues.is_empty() {
        println!("{} All specs valid!", "✓".green());
    } else {
        println!("{} Spec validation issues:", "✗".red());
        for issue in issues {
            println!("  - {}", issue.yellow());
        }
    }

    Ok(())
}

pub fn cmd_sync_data(
    root: &Path,
    direction: super::SyncDirection,
    path: Option<&Path>,
    verbose: bool,
) -> Result<()> {
    println!("{} Data sync not yet implemented", "⚠".yellow());
    println!("Direction: {:?}", direction);
    if let Some(p) = path {
        println!("Path: {}", p.display());
    }
    Ok(())
}

pub fn cmd_asset(root: &Path, action: super::AssetAction, verbose: bool) -> Result<()> {
    match action {
        super::AssetAction::List { type_ } => {
            let assets_dir = root.join("godot/assets");
            if !assets_dir.exists() {
                println!("{} Assets directory not found", "✗".red());
                return Ok(());
            }

            for entry in WalkDir::new(&assets_dir).into_iter().filter_map(|e| e.ok()) {
                if entry.file_type().is_file() {
                    if let Some(t) = &type_ {
                        if !entry.path().to_string_lossy().contains(t) {
                            continue;
                        }
                    }
                    println!("  {}", entry.path().strip_prefix(root).unwrap().display());
                }
            }
        },
        super::AssetAction::Check => {
            println!("{} Asset check not yet implemented", "⚠".yellow());
        },
        super::AssetAction::Manifest => {
            println!("{} Asset manifest not yet implemented", "⚠".yellow());
        },
    }
    Ok(())
}

pub fn cmd_runbook(root: &Path, action: super::RunbookAction, verbose: bool) -> Result<()> {
    let runbooks_dir = root.join("docs/RUNBOOKS");

    match action {
        super::RunbookAction::List => {
            if !runbooks_dir.exists() {
                println!("{} Runbooks directory not found", "✗".red());
                return Ok(());
            }

            for entry in WalkDir::new(&runbooks_dir).into_iter().filter_map(|e| e.ok()) {
                if entry.path().extension().map_or(false, |ext| ext == "md") {
                    println!("  {}", entry.path().strip_prefix(root).unwrap().display());
                }
            }
        },
        super::RunbookAction::Show { name } => {
            let path = runbooks_dir.join(&name);
            if !path.exists() {
                // Try with .md
                let path = runbooks_dir.join(format!("{}.md", name));
                if !path.exists() {
                    println!("{} Runbook not found: {}", "✗".red(), name);
                    return Ok(());
                }
            }
            let content = std::fs::read_to_string(&path)?;
            println!("{}", content);
        },
        super::RunbookAction::Search { query } => {
            if !runbooks_dir.exists() {
                println!("{} Runbooks directory not found", "✗".red());
                return Ok(());
            }

            for entry in WalkDir::new(&runbooks_dir).into_iter().filter_map(|e| e.ok()) {
                if entry.path().extension().map_or(false, |ext| ext == "md") {
                    let content = std::fs::read_to_string(entry.path())?;
                    if content.to_lowercase().contains(&query.to_lowercase()) {
                        println!(
                            "  {} (matches)",
                            entry.path().strip_prefix(root).unwrap().display()
                        );
                    }
                }
            }
        },
    }
    Ok(())
}

pub fn cmd_docker(root: &Path, action: super::DockerAction, verbose: bool) -> Result<()> {
    match action {
        super::DockerAction::Build { tag } => {
            let tag = tag.unwrap_or_else(|| "blink-arcana:latest".to_string());
            let output = Command::new("docker")
                .args(["build", "-t", &tag, "-f", "docker/Dockerfile", "."])
                .current_dir(root)
                .output()?;

            if output.status.success() {
                println!("{} Docker image built: {}", "✓".green(), tag);
            } else {
                println!("{} Docker build failed!", "✗".red());
                eprintln!("{}", String::from_utf8_lossy(&output.stderr).red());
            }
        },
        super::DockerAction::Dev => {
            let output = Command::new("docker")
                .args([
                    "run",
                    "--rm",
                    "-it",
                    "-v",
                    &format!("{}:/app", root.display()),
                    "blink-arcana:dev",
                ])
                .current_dir(root)
                .status()?;

            if !output.success() {
                std::process::exit(1);
            }
        },
        super::DockerAction::Clean => {
            let _ = Command::new("docker").args(["system", "prune", "-f"]).status()?;
            let _ = Command::new("docker").args(["builder", "prune", "-f"]).status()?;
            println!("{} Docker cleaned", "✓".green());
        },
    }
    Ok(())
}

pub fn cmd_git(root: &Path, action: super::GitAction, verbose: bool) -> Result<()> {
    match action {
        super::GitAction::Commit { message } => {
            let msg = message.unwrap_or_else(|| {
                println!("Commit types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert");
                println!("Format: type(scope): description");
                print!("Enter commit message: ");
                use std::io::{self, Write};
                io::stdout().flush().unwrap();
                let mut input = String::new();
                io::stdin().read_line(&mut input).unwrap();
                input.trim().to_string()
            });

            let output =
                Command::new("git").args(["commit", "-m", &msg]).current_dir(root).output()?;

            if output.status.success() {
                println!("{} Committed: {}", "✓".green(), msg);
            } else {
                eprintln!("{}", String::from_utf8_lossy(&output.stderr).red());
            }
        },
        super::GitAction::Status => {
            let output =
                Command::new("git").args(["status", "--short"]).current_dir(root).output()?;

            let status = String::from_utf8_lossy(&output.stdout);
            if status.trim().is_empty() {
                println!("{} Working tree clean", "✓".green());
            } else {
                println!("{}", status);
            }
        },
        super::GitAction::Branch { name } => {
            let branch = format!("feature/{}", name.to_lowercase().replace(' ', "-"));
            let output =
                Command::new("git").args(["checkout", "-b", &branch]).current_dir(root).output()?;

            if output.status.success() {
                println!("{} Created branch: {}", "✓".green(), branch);
            } else {
                eprintln!("{}", String::from_utf8_lossy(&output.stderr).red());
            }
        },
    }
    Ok(())
}

pub fn cmd_errors(root: &Path, count: usize, verbose: bool) -> Result<()> {
    // Check recent build logs
    let target_dir = root.join("rust/target");
    if !target_dir.exists() {
        println!("{} No build artifacts found", "⚠".yellow());
        return Ok(());
    }

    // Find recent build scripts
    for entry in WalkDir::new(&target_dir).into_iter().filter_map(|e| e.ok()) {
        if entry.file_name().to_string_lossy().ends_with(".stderr")
            || entry.file_name().to_string_lossy().contains("error")
        {
            let content = std::fs::read_to_string(entry.path())?;
            let lines: Vec<&str> = content.lines().rev().take(count).collect();
            if !lines.is_empty() {
                println!("{}", entry.path().display().to_string().bold());
                for line in lines.iter().rev() {
                    if line.contains("error") {
                        println!("  {}", line.red());
                    } else if line.contains("warning") {
                        println!("  {}", line.yellow());
                    } else {
                        println!("  {}", line);
                    }
                }
            }
        }
    }

    Ok(())
}

pub fn cmd_clean(root: &Path, level: super::CleanLevel, verbose: bool) -> Result<()> {
    match level {
        super::CleanLevel::Dev => {
            run_cmd(root, "cargo", &["clean"])?;
            let _ = std::fs::remove_dir_all(root.join("godot/addons/blink_core/bin"));
            let _ = std::fs::remove_dir_all(root.join("build"));
            println!("{} Dev clean complete", "✓".green());
        },
        super::CleanLevel::All => {
            run_cmd(root, "cargo", &["clean"])?;
            let _ = std::fs::remove_dir_all(root.join("rust/target"));
            let _ = std::fs::remove_dir_all(root.join("godot/addons/blink_core/bin"));
            let _ = std::fs::remove_dir_all(root.join("build"));
            let _ = std::fs::remove_dir_all(root.join("target"));
            println!("{} Full clean complete", "✓".green());
        },
        super::CleanLevel::Docker => {
            let _ = Command::new("docker").args(["system", "prune", "-f"]).status()?;
            let _ = Command::new("docker").args(["builder", "prune", "-f"]).status()?;
            println!("{} Docker clean complete", "✓".green());
        },
    }
    Ok(())
}

fn copy_gdextension(root: &Path, profile: &str) -> Result<()> {
    let src_dir = root.join(format!("rust/target/{}", profile));
    let dst_dir = root.join("godot/addons/blink_core/bin");

    std::fs::create_dir_all(&dst_dir)?;

    let extensions = if cfg!(target_os = "windows") {
        vec!["blink_gdext.dll"]
    } else if cfg!(target_os = "macos") {
        vec!["libblink_gdext.dylib"]
    } else {
        vec!["libblink_gdext.so"]
    };

    for ext in extensions {
        let src = src_dir.join(ext);
        if src.exists() {
            std::fs::copy(&src, dst_dir.join(ext))?;
        }
    }

    Ok(())
}

fn count_workspace_members(cargo_toml: &Path) -> Result<usize> {
    let content = std::fs::read_to_string(cargo_toml)?;
    let doc: toml::Value = content.parse()?;

    if let Some(members) = doc.get("workspace").and_then(|w| w.get("members")) {
        if let Some(arr) = members.as_array() {
            return Ok(arr.len());
        }
    }
    Ok(0)
}

fn run_cmd(root: &Path, cmd: &str, args: &[&str]) -> Result<String> {
    let output = Command::new(cmd).args(args).current_dir(root).output()?;

    Ok(String::from_utf8_lossy(&output.stdout).to_string())
}
