use bindgen::{EnumVariation, RustTarget};
use pkg_config::Config;
use std::env;
use std::path::PathBuf;

fn main() {
	let luau = Config::new().probe("luau").unwrap();

	for link_path in luau.link_paths {
		println!("cargo:rustc-link-search={}", link_path.display());
	}
	println!("cargo:rustc-link-search=build");

	let cxx_stdlib = env::var("CXXSTDLIB").unwrap_or("c++".to_string());
	println!("cargo:rustc-link-lib={cxx_stdlib}");

	let bindings = bindgen::Builder::default()
		.header("rust/wrapper.h")
		.clang_arg("-xc++")
		.use_core()
		.rust_edition(bindgen::RustEdition::Edition2024)
		.rust_target(RustTarget::stable(90, 0).ok().unwrap())
		.layout_tests(false)
		.default_enum_style(EnumVariation::NewType {
			is_bitfield: false,
			is_global: false,
		})
		.derive_default(true)
		.parse_callbacks(Box::new(bindgen::CargoCallbacks::new()))
		.generate()
		.expect("Unable to generate bindings");

	let out_path = PathBuf::from(env::var("OUT_DIR").unwrap());
	bindings
		.write_to_file(out_path.join("bindings.rs"))
		.expect("Couldn't write bindings!");
}
