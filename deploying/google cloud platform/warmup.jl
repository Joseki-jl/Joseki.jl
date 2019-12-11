@info "Julia started, imporing libraries and defining endpoints"

include("server_definition.jl")

using Sockets

@info "Starting the server"

server = Sockets.listen(Sockets.InetAddr(ip"127.0.0.1", 8000))
server_task = @async HTTP.serve(router, ip"127.0.0.1", 8000; verbose=false,
                                server = server)

@info "Exercising the endpoints"

# Exercise the two endpoints
HTTP.get("http://localhost:8000/pow/?x=2&y=3")
params = Dict("n" => 4, "k" => 3)
HTTP.post("http://localhost:8000/bin", 
          ["Content-Type" => "application/json"],
          JSON.json(params))


# All done, shut down the server
close(server)
@info "All done!"