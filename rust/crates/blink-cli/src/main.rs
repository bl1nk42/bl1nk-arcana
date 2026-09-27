//! blink-cli: Blink Arcana Project Management CLI
//!
//! Provides commands for development workflow automation.

use std::path::PathBuf;

use clap::{Parser, Subcommand};
use colored::*;
use indicatif::{ProgressBar, ProgressStyle};
use walkdir::WalkDir;

mod commands;
mod utils;

use commands::*;
use utils::*;

#[derive(Parser)]
#[command(name = "blink")]
#[command(about = "Blink Arcana Project Management CLI", long_about = None)]
#[command(version)]
struct Cli {
    #[command(subcommand)]
    command: Commands,

    /// Project root directory (default: current dir)
    #[arg(short, long, global = true)]
    root: Option<PathBuf>,

    /// Verbose output
    #[arg(short, long, global = true)]
    verbose: bool,

    /// Disable colored output
    #[arg(long, global = true)]
    no_color: bool,
}

#[derive(Subcommand)]
enum Commands {
    /// Show project status overview
    Status,

    /// Run quality checks (fmt, lint, test)
    Check {
        /// Skip specific checks
        #[arg(long, value_delimiter = ',')]
        skip: Vec<String>,
    },

    /// Build project (debug or release)
    Build {
        /// Build profile
        #[arg(short, long, default_value = "debug")]
        profile: String,

        /// Target platform
        #[arg(short, long)]
        target: Option<String>,
    },

    /// Run tests
    Test {
        /// Test filter pattern
        #[arg(short, long)]
        filter: Option<String>,

        /// Run all tests including Godot
        #[arg(long)]
        all: bool,
    },

    /// Generate new feature spec from template
    NewSpec {
        /// Feature name (kebab-case)
        name: String,

        /// Feature type
        #[arg(short, long, value_enum)]
        type_: SpecType,
    },

    /// Validate all spec sheets
    ValidateSpecs,

    /// Sync data: JSON ↔ .tres ↔ Protobuf
    SyncData {
        /// Direction: json-to-tres, tres-to-json, json-to-proto
        #[arg(value_enum)]
        direction: SyncDirection,

        /// Specific file or directory
        path: Option<PathBuf>,
    },

    /// Asset management
    Asset {
        #[command(subcommand)]
        action: AssetAction,
    },

    /// Runbook helper
    Runbook {
        #[command(subcommand)]
        action: RunbookAction,
    },

    /// Docker helpers
    Docker {
        #[command(subcommand)]
        action: DockerAction,
    },

    /// Git helpers
    Git {
        #[command(subcommand)]
        action: GitAction,
    },

    /// Show recent errors from build/test
    Errors {
        /// Number of recent errors to show
        #[arg(short, long, default_value = "10")]
        count: usize,
    },

    /// Clean build artifacts
    Clean {
        /// Clean level: dev, all, docker
        #[arg(value_enum, default_value = "dev")]
        level: CleanLevel,
    },
}

#[derive(clap::ValueEnum, Clone)]
enum SpecType {
    Combat,
    Ai,
    Pathfinding,
    Data,
    Gdextension,
    Ui,
    System,
}

#[derive(clap::ValueEnum, Clone, Debug)]
enum SyncDirection {
    JsonToTres,
    TresToJson,
    JsonToProto,
}

#[derive(clap::ValueEnum, Clone)]
enum CleanLevel {
    Dev,
    All,
    Docker,
}

#[derive(Subcommand)]
enum AssetAction {
    /// List all assets
    List {
        /// Filter by type
        #[arg(short, long)]
        type_: Option<String>,
    },
    /// Check for missing assets
    Check,
    /// Generate asset manifest
    Manifest,
}

#[derive(Subcommand)]
enum RunbookAction {
    /// List available runbooks
    List,
    /// Show runbook content
    Show { name: String },
    /// Search runbooks
    Search { query: String },
}

#[derive(Subcommand)]
enum DockerAction {
    /// Build Docker image
    Build { tag: Option<String> },
    /// Run dev container
    Dev,
    /// Clean Docker artifacts
    Clean,
}

#[derive(Subcommand)]
enum GitAction {
    /// Show conventional commit helpers
    Commit { message: Option<String> },
    /// Check for uncommitted changes
    Status,
    /// Create feature branch
    Branch { name: String },
}

fn main() -> anyhow::Result<()> {
    let cli = Cli::parse();

    if cli.no_color {
        colored::control::set_override(false);
    }

    let root = cli.root.unwrap_or_else(|| std::env::current_dir().unwrap());

    match cli.command {
        Commands::Status => cmd_status(&root, cli.verbose),
        Commands::Check { skip } => cmd_check(&root, &skip, cli.verbose),
        Commands::Build { profile, target } => {
            cmd_build(&root, &profile, target.as_deref(), cli.verbose)
        },
        Commands::Test { filter, all } => cmd_test(&root, filter.as_deref(), all, cli.verbose),
        Commands::NewSpec { name, type_ } => cmd_new_spec(&root, &name, type_, cli.verbose),
        Commands::ValidateSpecs => cmd_validate_specs(&root, cli.verbose),
        Commands::SyncData { direction, path } => {
            cmd_sync_data(&root, direction, path.as_deref(), cli.verbose)
        },
        Commands::Asset { action } => cmd_asset(&root, action, cli.verbose),
        Commands::Runbook { action } => cmd_runbook(&root, action, cli.verbose),
        Commands::Docker { action } => cmd_docker(&root, action, cli.verbose),
        Commands::Git { action } => cmd_git(&root, action, cli.verbose),
        Commands::Errors { count } => cmd_errors(&root, count, cli.verbose),
        Commands::Clean { level } => cmd_clean(&root, level, cli.verbose),
    }
}
