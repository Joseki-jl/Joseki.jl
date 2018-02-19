module Joseki

using HTTP, JSON
import HTTP.IOExtras.bytes

include("utilities.jl")
include("responders.jl")
include("middleware.jl")



export stack
"""
    stack(fns::Array{Function, 1}, endpoint::Function; error_fn=rethrow)

Create a `HTTP.Handlers.HandlerFunction` from a set of middlware functions (of
the form `HTTP.Request` => `HTTP.Request`) and an endpoint (of the form
`HTTP.Request` => `HTTP.Response`).  If `error_fn` is not provided then any
requests that cause an error respond with the default HTTP.jl rendering of that
error.
"""
function stack(fns::Array{Function, 1}, endpoint::Function;
               error_fn=rethrow)
    # First we form the function that represents our middleware + endpoint
    # wrapped in a try-catch block so that we can deal with errors that are not
    # explicitly handled.
    s = function(req::HTTP.Request)
        try
            for f in fns
                req = f(req)
            end
            return endpoint(req)
        catch err
            error_fn(err)
        end
    end
    # Once we have this function we wrap it in a HandlerFunction which is used
    # to register routes
    return HTTP.HandlerFunction(s)
end

end # End module
