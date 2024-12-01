{
	description = "Basic racket flake";

	inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

	outputs = {
		self,
		nixpkgs,
	}: let
		system = "x86_64-linux";
		pkgs = import nixpkgs {inherit system;};
	in {
		devShells.${system}.default = pkgs.mkShell {
			packages = with pkgs; [
				# remember to `raco pkg install racket-langserver`!
				racket
			];
		};
	};
}
