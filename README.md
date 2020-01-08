# Joseki.jl

Want to make an API in Julia but not sure where to start?  Newer versions of 
[HTTP.jl](https://github.com/JuliaWeb/HTTP.jl) have everything you need to build one from scratch,
but getting started can be a bit intimidating at the moment.  Joseki.jl is a set of examples and
tools to help you on your way.  It's inspired by [Mux.jl](https://github.com/JuliaWeb/Mux.jl) and
[Express](https://expressjs.com/).  

|            **Documentation**            |                       **Build Status**                        |
| :-------------------------------------: | :-----------------------------------------------------------: |
| [![][docs-stable-img]][docs-stable-url] [![][docs-latest-img]][docs-latest-url] | [![][travis-img]][travis-url] [![][codecov-img]][codecov-url] |

## The basics

Middleware in Joseki is any function that takes a `HTTP.Request` and modifies it (and the associated
response).  Endpoints are functions that accept a `HTTP.Request` and returns a modified version of
its associated `HTTP.Response`.  Typically any request is passed through the same set of middleware
layers before being routed to a single endpoint.  

You combine a set of middleware, endpoints, and optionally an error-handling function with
`Joseki.router(endpoints; middleware=default_middleware error_fn=error_responder)` to create a
`HTTP.Router`.  This can be used with standard `HTTP.jl` methods to create a server.

## A simple example

To install Joseki.jl, run `Pkg.clone("https://github.com/amellnik/Joseki.jl.git")`.

```julia
using Joseki, JSON, HTTP

### Create some endpoints

# This function takes two numbers x and y from the query string and returns x^y
# In this case they need to be identified by name and it should be called with
# something like 'http://localhost:8000/pow/?x=2&y=3'
function pow(req::HTTP.Request)
    j = HTTP.queryparams(HTTP.URI(req.target))
    has_all_required_keys(["x", "y"], j) || return error_responder(req, "You need to specify values for x and y!")
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
    has_all_required_keys(["n", "k"], j) || return error_responder(req, "You need to specify values for n and k!")
    json_responder(req, binomial(j["n"],j["k"]))
end

### Create and run the server

# Make a router and add routes for our endpoints.
endpoints = [
    (pow, "GET", "/pow"),
    (bin, "POST", "/bin")
]
r = Joseki.router(endpoints)

# Fire up the server
HTTP.serve(r, "127.0.0.1", 8000; verbose=false)
```

If you run this example you can try it out by going to http://localhost:8000/pow/?x=2&y=3.  You
should see a response like:

```json
{"error": false, "result": 8.0}
```

In order to test the 2nd endpoint, you can make a POST request from within a different Julia
session:

```julia
using HTTP, JSON
HTTP.post("http://localhost/bin", [], JSON.json(Dict("n" => 4, "k" => 3)))
```

You can also do this from the command line with cURL:

```shell
curl -X POST \
  http://localhost:8000/bin \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/json' \
  -d '{"n": 4, "k": 3}'
```

or use a tool like [Postman](https://www.getpostman.com/).

## Next steps

You can modify or add to the default middleware stack, write your own responders, or create
additional endpoints.  

## Containers and deploying

In many cases you will want to deploy your API as a Docker container.  This makes it possible to
deploy to most hosting services.  This folder contains a Dockerfile that demonstrates hosting the
example above (with a few minor modifications to make it work in Docker).  

To build the image you can run

```shell
docker build -t joseki .
```

from this folder and then run

```shell
docker run --rm -p 8000:8000 joseki
```

to start the server.  If you need to debug anything you can start an interactive session with

```shell
docker run --rm -p 8000:8000 -it --entrypoint=/bin/bash joseki
```

This runs Joseki from within its own package environment, but a more common use case would be to
create a new project that adds Joseki as a dependency.  You can find examples that do this in separate repositories within the [Joseki org](https://github.com/Joseki-jl).  


[docs-stable-img]: https://img.shields.io/badge/docs-stable-green.svg
[docs-stable-url]: https://amellnik.github.io/Joseki.jl/stable/

[docs-latest-img]: https://img.shields.io/badge/docs-latest-blue.svg
[docs-latest-url]: https://amellnik.github.io/Joseki.jl/latest/

[travis-img]: https://travis-ci.com/amellnik/Joseki.jl.svg?branch=master
[travis-url]: https://travis-ci.com/amellnik/Joseki.jl

[codecov-img]: https://codecov.io/gh/amellnik/Joseki.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/amellnik/Joseki.jl