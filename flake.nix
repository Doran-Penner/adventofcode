{
	description = "Basic racket flake";

	inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

	inputs.fenix.url = "github:nix-community/fenix/monthly";
	inputs.fenix.inputs.nixpkgs.url = "nixpkgs";

	outputs = {
		self,
		nixpkgs,
		fenix,
	}: let
		system = "x86_64-linux";
		pkgs = import nixpkgs {inherit system;};
	in {
		devShells.${system}.default = pkgs.mkShell {
			packages = let
				rust-packages = fenix.packages.${system}.stable.defaultToolchain;
				# nice link to offline docs
				rust-docs = pkgs.writeShellScriptBin "rust-docs" ''
					xdg-open "${rust-packages}/share/doc/rust/html/index.html"
				'';
			in
				with pkgs; [
					# remember to `raco pkg install racket-langserver`!
					racket
					rust-packages
					rust-docs
				];
		};
	};
}
