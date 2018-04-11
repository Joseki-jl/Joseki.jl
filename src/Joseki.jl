module Joseki

using HTTP, JSON
import HTTP.IOExtras.bytes

include("utilities.jl")
include("responders.jl")
include("middleware.jl")



export stack
"""
    stack(fns::Array{Function, 1}, endpoint::Function; error_fn=(req, err)->rethrow(err))

Create a `HTTP.Handlers.HandlerFunction` from a set of middlware functions (of
the form `HTTP.Request` => `HTTP.Request`) and an endpoint (of the form
`HTTP.Request` => `HTTP.Response`).  If `error_fn` is not provided then any
requests that cause an unhandled error respond with the default HTTP.jl
rendering of that error (a plain text string).
"""
function stack(fns::Array{Function, 1}, endpoint::Function;
               error_fn=(req, err)->rethrow(err))
    # First we form the function that represents our middleware + endpoint
    # wrapped in a try-catch block so that we can deal with errors that are not
    # explicitly handled.
    s = function(req::HTTP.Request)
        try
            for f! in fns
                f!(req)
                # Allow middleware to abort the stack and return a response
                req.response.status != 0 && return req.response
            end
            return endpoint(req)
        catch err
            error_fn(req, err)
        end
    end
    # Once we have this function we wrap it in a HandlerFunction which is used
    # to register routes
    return HTTP.HandlerFunction(s)
end

end # End module
