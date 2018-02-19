# Joseki.jl

Want to make an API in Julia but not sure where to start?  Newer versions of [HTTP.jl](https://github.com/JuliaWeb/HTTP.jl) have everything you need to build one from scratch, but getting started can be a bit intimidating at the moment.  Joseki.jl is a set of examples and tools to help you on your way.  It's inspired by [Mux.jl](https://github.com/JuliaWeb/Mux.jl) and [Express](https://expressjs.com/).  

## The basics

Middleware in Joseki is any function that takes a `HTTP.Request` and modifies it (and the associated response).  Endpoints are functions that accept a `HTTP.Request` and returns a modified version of its associated `HTTP.Response`.  Typically any request is passed through the same set of middleware layers before being routed to a single endpoint.  

You combine a set of middleware, an endpoint, and optionally an error-handling function with `stack(fns::Array{Function, 1}, endpoint::Function; error_fn=rethrow)` to create a `HTTP.HandlerFunction`.  This can be used with standard `HTTP.jl` methods to create a server.

## A simple example

To install Joseki.jl, run `Pkg.clone("https://github.com/amellnik/Joseki.jl.git")`.

```julia
using Joseki, JSON

### Create some endpoints

# This function takes two numbers x and y from the query string and returns x^y
# In this case they need to be identified by name and it should be called with
# something like 'http://localhost:8000/pow/?x=2&y=3'
function pow(req::HTTP.Request)
    j = HTTP.queryparams(HTTP.URI(req.target))
    if !(haskey(j, "x")&haskey(j, "y"))
        return error_responder(req, "You need to specify values for x and y!")
    end
    # Try to parse the values as numbers.  If there's an error here the generic
    # error handler will deal with it.
    x = parse(Float32, j["x"])
    y = parse(Float32, j["y"])
    json_responder(req, x^y)
end

# This function takes two numbers n and k from a JSON-encoded request
# body and returns binomial(n, k)
function bin(req::HTTP.Request)
    j = try
        body_as_dict(req)
    catch err
        return error_responder(req, "I was expecting a json request body!")
    end
    if !(haskey(j, "n")&haskey(j, "k"))
        return error_responder(req, "You need to specify values for n and k!")
    end
    json_responder(req, binomial(j["n"],j["k"]))
end

### Create and run the server

# Make a router and add routes for our endpoints.
router = HTTP.Router()
mw = Joseki.default_middleware
HTTP.register!(router, "GET", "/pow",
    stack(mw, pow; error_fn=Joseki.error_responder))
HTTP.register!(router, "POST", "/bin",
    stack(mw, bin; error_fn=Joseki.error_responder))

# Fire up the server
s = HTTP.Servers.Server(router)
HTTP.serve(s, ip"127.0.0.1", 8000; verbose=false)
```

If you run this example you can try it out by going to http://localhost:8000/pow/?x=2&y=3.  You should see a response like:

```json
{"error": false, "result": 8.0}
```

In order to test the 2nd endpoint, you can make a POST request with cURL:

```
curl -X POST \
  http://localhost:8000/bin \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/json' \
  -d '{"n": 4, "k": 3}'
```

or use a tool like [Postman](https://www.getpostman.com/).

## Next steps

You can modify or add to the default middleware stack, write your own responders, or create additional endpoints.  

## Containers and deploying

In many cases you will want to deploy your API as a Docker container.  This makes it possible to deploy to most hosting services.  This folder contains a Dockerfile that demonstrates hosting the example above (with a few minor modifications to make it work in Docker).  

To build the image you can run

```
docker build -t joseki .
```

from this folder and then run

```
docker run --rm -p 8000:8000 joseki
```

to start the server.  If you need to debug anything you can start an interactive session with

```
docker run --rm -p 8000:8000 -it --entrypoint=/bin/bash joseki
```

How you deploy it will depend on your hosting provider.  When you deploy your own API you will need to modify both the julia server file and possibly also the Dockerfile (to add additional dependencies).  

## TODO: Common tasks to add
* Handling long-running tasks
* Serving up static files
