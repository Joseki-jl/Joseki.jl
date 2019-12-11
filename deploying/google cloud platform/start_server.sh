#!/bin/sh
julia -e 'using Pkg; pkg"activate ."; include("server_definition.jl"); HTTP.serve(router, "0.0.0.0", port)'