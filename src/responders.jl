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
    "result": "You need to pass variables named x and y in the query string"
}
``
"""
# Endpoints can do their own error checking.  Errors caught by them
# return a 200-code JSON response that has a key 'error' set to true
function error_responder(req::HTTP.Request, e::String)
    b = """{"error": true, "message": "$(e)"}"""
    req.response.body = bytes(b)
    return req.response
end

# If we thing the julia error will be clear to the user then we can just use
# that.
error_responder(req::HTTP.Request, e::Exception) =
    error_responder(req, string(e))

# Sometimes things go terribly wrong and we don't get a response. In this case
# we return the error text in the same format but set the status code to 500.
function error_responder(e::Exception)
    println("Unhandled error!  You probably want to catch these.")
    return HTTP.Response(500, """{"error": true, "message": "$(e)"}""")
end
