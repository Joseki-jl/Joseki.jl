### Middleware layers

"""
This sets `Access-Control-Allow-Origin` to the requester's origin.  In
production you would want to check the origin against a whitelist and throw an
error otherwise.
"""
function add_cors!(req::HTTP.Request)
    orig = HTTP.Messages.header(req, "Origin")
    push!(req.response.headers, Pair("Access-Control-Allow-Origin", orig))
    push!(req.response.headers, Pair("Access-Control-Allow-Methods", "GET,PUT,POST,DELETE,PATCH,OPTIONS"))
    push!(req.response.headers, Pair("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept"))
    return req
end

"""
Sets `Content-Type` for JSON responses.
"""
function content_type!(req::HTTP.Request)
    push!(req.response.headers,
        Pair("Content-Type", "application/json; charset=utf-8"))
    return req
end

"""
Log a line whenever you get a request.  HTTP.jl already does this.
"""
function hit_logger!(req::HTTP.Request)
    println(req.method, " request to: ", req.target,
        " at ", now())
    return req
end

"""
Log the request body.
"""
function body_logger!(req::HTTP.Request)
    println(String(copy(req.body)))
    return req
end

# Some default middleware
default_middleware = [hit_logger!, body_logger!, add_cors!, content_type!]
