using Documenter, BinaryClassifierEvaluation;

makedocs(
	format = Documenter.HTML(),
	sitename = "BinaryClassifierEvaluation.jl",
	modules = [BinaryClassifierEvaluation],
	authors = "Marek Dědič",
	pages = Any[
		"Home" => "index.md"
	]
);
