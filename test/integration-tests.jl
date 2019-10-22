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

    function test_error_responder(req::HTTP.Request, e::Exception)
        error_responder(req, "Unhandled error!")
    end

    endpoints = [
        (pow, "GET", "/pow")
    ]
    # Default middleware but a custom error responder
    router = Joseki.router(endpoints; error_fn=test_error_responder)

    @info "Starting test server"
    server = Sockets.listen(Sockets.InetAddr(ip"127.0.0.1", 8000))
    server_task = @async HTTP.serve(router, ip"127.0.0.1", 8000; verbose=false,
                                    server = server)
    sleep(1.0)

    # A valid request
    res = HTTP.get("http://localhost:8000/pow/?x=2&y=3")
    @test res.status == 200
    @test HTTP.hasheader(res, "Access-Control-Allow-Methods", "GET,PUT,POST,DELETE,PATCH,OPTIONS")

    # An invalid request
    res = HTTP.get("http://localhost:8000/pow/?x=2&y=nothing")
    @test res.status == 200 # Our handeled errors return 200 responses
    @test occursin("Unhandled error!", String(copy(res.body)))

    @info "Shutting down test server"

    close(server)
    sleep(2)
    @test istaskdone(server_task)
end
