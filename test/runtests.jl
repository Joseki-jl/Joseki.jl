# These tests are closely based on the server tests in HTTP.jl:
# https://github.com/JuliaWeb/HTTP.jl/blob/master/test/server.jl

using HTTP
import HTTP.IOExtras.bytes

# Function to make a simple request that can be used in tests
function sample_request()
    body = """{"x": 5, "y": 3}"""
    encoded_body = bytes(body)
    return HTTP.Request("GET", "", [], encoded_body)
end

include("utilities-tests.jl")
include("middleware-tests.jl")
include("responders-tests.jl")
include("integration-tests.jl")
include("dockerfile-tests.jl")
