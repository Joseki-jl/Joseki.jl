# These tests are closely based on the server tests in HTTP.jl:
# https://github.com/JuliaWeb/HTTP.jl/blob/master/test/server.jl

using HTTP, Joseki, JSON
@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end


@testset "Joseki" begin

    # Simple server
    function pow(req::HTTP.Request)
        j = HTTP.queryparams(HTTP.URI(req.target))
        if !(haskey(j, "x")&haskey(j, "y"))
            return error_responder(req, "You need to specify values for x and y!")
        end
        x = parse(Float32, j["x"])
        y = parse(Float32, j["y"])
        json_responder(req, x^y)
    end

    endpoints = [
        (pow, "GET", "/pow")
    ]
    server = Joseki.server(endpoints) # Default middleware

    info("Starting test server")
    server_task = @async HTTP.serve(server, ip"127.0.0.1", 8000; verbose=false)
    sleep(1.0)

    res = HTTP.get("http://localhost:8000/pow/?x=2&y=3")
    @test res.status == 200
    @test HTTP.hasheader(res, "Access-Control-Allow-Methods", "GET,PUT,POST,DELETE,PATCH,OPTIONS")

    info("Shutting down test server")

    put!(server.in, HTTP.Servers.KILL)
    sleep(2)
    @test istaskdone(server_task)
end
