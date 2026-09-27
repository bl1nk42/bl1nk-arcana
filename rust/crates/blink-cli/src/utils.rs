//! Utility functions for blink-cli

use std::path::Path;

use anyhow::Result;

pub fn find_project_root(start: &Path) -> Result<std::path::PathBuf> {
    let mut current = start.to_path_buf();

    loop {
        if current.join("PDR.md").exists() && current.join("justfile").exists() {
            return Ok(current);
        }

        if !current.pop() {
            break;
        }
    }

    anyhow::bail!("Not in a Blink Arcana project (no PDR.md found)")
}

pub fn run_command(cmd: &str, args: &[&str], dir: &Path) -> Result<String> {
    let output = std::process::Command::new(cmd).args(args).current_dir(dir).output()?;

    Ok(String::from_utf8_lossy(&output.stdout).to_string())
}

pub fn run_command_with_stderr(cmd: &str, args: &[&str], dir: &Path) -> Result<(String, String)> {
    let output = std::process::Command::new(cmd).args(args).current_dir(dir).output()?;

    Ok((
        String::from_utf8_lossy(&output.stdout).to_string(),
        String::from_utf8_lossy(&output.stderr).to_string(),
    ))
}

pub fn parse_toml_value(content: &str, key: &str) -> Result<String> {
    let doc: toml::Value = content.parse()?;

    let keys: Vec<&str> = key.split('.').collect();
    let mut current = &doc;

    for k in keys {
        current = current.get(k).ok_or_else(|| anyhow::anyhow!("Key not found: {}", key))?;
    }

    Ok(current.to_string())
}
