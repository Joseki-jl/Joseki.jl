module Joseki

using HTTP, JSON, Dates
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
               error_fn=unhandled_error_responder)
    # First we form the function that represents our middleware + endpoint
    # wrapped in a try-catch block so that we can deal with errors that are not
    # explicitly handled.
    s = function(req::HTTP.Request)
        try
            for f! in fns
                f!(req)
            end
            return endpoint(req)
        catch err
            error_fn(req, err)
        end
    end
    # Once we have this function we wrap it in a HandlerFunction which is used
    # to register routes
    return HTTP.Handlers.HandlerFunction(s)
end

function register!(router, method::String, url::String, handler)
    eval(quote HTTP.@register($router, $method, $url, $handler) end)
end

# TODO: Named tuples might be good here...
"""
    Joseki.router(endpoints; middleware=default_middleware, error_fn=error_responder)

Construct a `HTTP.Servers.Server` from an array of `Tuples` of the form (endpoint_function, http_method, endpoint_route).
"""
function router(endpoints::Array{Tuple{T, String, String}, 1};
        middleware=default_middleware,
        error_fn=unhandled_error_responder) where {T<:Function}
    router = HTTP.Router()
    for ep in endpoints
        register!(router, ep[2], ep[3], 
                    stack(middleware, ep[1]; error_fn=error_responder))
    end
    return router
end

end # End module
