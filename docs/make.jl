using Documenter, Joseki, HTTP, JSON

makedocs(
    format = Documenter.HTML(),
    sitename = "Joseki.jl"
)

deploydocs(
    repo = "github.com/amellnik/joseki.jl.git",
)