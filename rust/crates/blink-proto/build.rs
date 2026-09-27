use std::path::PathBuf;

use prost_build::Config;

fn main() {
    let mut config = Config::new();
    config.type_attribute(".", "#[derive(serde::Serialize, serde::Deserialize)]");
    config
        .compile_protos(&["../../../proto/blink_v1.proto"], &["../../../proto"])
        .expect("Failed to compile protos");

    println!("cargo:rerun-if-changed=../../../proto/blink_v1.proto");
}
