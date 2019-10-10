using HTTP, Joseki, JSON, Sockets, Test


@testset "Integration tests" begin

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
    router = Joseki.router(endpoints) # Default middleware

    @info "Starting test server"
    server = Sockets.listen(Sockets.InetAddr(ip"127.0.0.1", 8000))
    server_task = @async HTTP.serve(router, ip"127.0.0.1", 8000; verbose=false,
                                    server = server)
    sleep(1.0)

    res = HTTP.get("http://localhost:8000/pow/?x=2&y=3")
    @test res.status == 200
    @test HTTP.hasheader(res, "Access-Control-Allow-Methods", "GET,PUT,POST,DELETE,PATCH,OPTIONS")

    @info "Shutting down test server"

    close(server)
    sleep(2)
    @test istaskdone(server_task)
end
