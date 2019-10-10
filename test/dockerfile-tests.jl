# This file is not part of the automated test suite, as it requires Docker
# to be present on the system.

using Test, Joseki, JSON

@testset "Test sample dockerfile" begin
    @info "Starting server from included dockerfile"
    cd(dirname(@__FILE__))
    cd("../")
    run(`docker build -t joseki .`)
    run(`docker run -d --rm -p 8000:8000 --name joseki-test joseki`)
    sleep(5)

    res = HTTP.get("http://localhost:8000/pow/?x=2&y=3")
    @test res.status == 200
    @test HTTP.hasheader(res, "Access-Control-Allow-Methods", "GET,PUT,POST,DELETE,PATCH,OPTIONS")

    @info "Shutting down dockerfile server"
    run(`docker rm -f joseki-test`)
end
