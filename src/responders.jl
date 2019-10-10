### Responders are functions which take a req::HTTP.Request and some sort of
### object, and use that object to modify req.response and return it

export json_responder
"""
    json_responder(req::HTTP.Request, o)

Forms a response in a standard format.  `o` can be a `Number`, `String`,
`Dict`, or an `Array` of one of the other types.  The response will look like:

```
{
    "error": false,
    "result": <JSON serialization of o>
}
```
"""
function json_responder(req::HTTP.Request, o::T) where {T<:Union{Number, AbstractString, Array, Dict}}
    b = """{"error": false, "result": $(JSON.json(o))}"""
    req.response.body = bytes(b)
    return req.response
end


export simple_json_responder
"""
    simple_json_responder(req::HTTP.Request, o)

Respond simply with the JSON serialization of an object.  `o` can be a `Number`, `String`,
`Dict`, or an `Array` of one of the other types.
"""
function simple_json_responder(req::HTTP.Request, o::T) where {T<:Union{Number, AbstractString, Array, Dict}}
    b = JSON.json(o)
    req.response.body = bytes(b)
    return req.response
end


export error_responder
"""
    error_responder(req::HTTP.Request, e::String)
    error_responder(req::HTTP.Request, e::Exception)
    error_responder(e::Exception)

Returns a response representing an error in a standard format.  Errors captured
within endpoints are considered to be user errors and return 200 responses.
Errors not explicitly captured by a `try ... catch` block return 500 responses.
The response will look like:

```
{
    "error": true,
    "message": "You need to pass variables named x and y in the query string"
}
```
"""
function error_responder(req::HTTP.Request, e::String)

    # Endpoints can do their own error checking.  Errors caught by them
    # return a 200-code JSON response that has a key 'error' set to true

    # Make sure we don't have unescaped quotes in the error string since
    # we are going to return it as a json
    ee = replace(e, r"(?<!\\)(?:\\{2})*\K\"" => "\\\"")
    b = """{"error": true, "message": "$(ee)"}"""
    req.response.body = bytes(b)
    return req.response
end

# If we think the julia error will be clear to the user then we can just use
# that.
error_responder(req::HTTP.Request, e::Exception) =
    error_responder(req, string(e))

"""
    unhandled_error_responder(req::HTTP.Request,e::Exception)

The default error handler, not intended for use by users.  It includes a gentle reminder that errors should typically be caught elsewhere.
"""
function unhandled_error_responder(req::HTTP.Request, e::Exception)
    @info string("Unhandled error!  You probably want to catch these: ", string(e))
    error_responder(req, string(e))
end


export critical_error_responder
"""
    critical_error_responder(req::HTTP.Request, e::Exception)

Respond with a 500 error response.
"""
function critical_error_responder(req::HTTP.Request, e::Exception)
    @warn string("Critical error!  Returning a 500 response to the client: ", string(e))
    setstatus(req.response, 500)
    return req.response
end
