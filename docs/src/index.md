# Joseki.jl

Suggested opening moves for build APIs in Julia with HTTP.jl.

## Contents

```@contents
```

## Introduction

Want to make an API in Julia but not sure where to start?  Newer versions of [HTTP.jl](https://github.com/JuliaWeb/HTTP.jl) have everything you need to build one from scratch, but getting started can be a bit intimidating at the moment.  Joseki.jl is a set of examples and tools to help you on your way.  It's inspired by [Mux.jl](https://github.com/JuliaWeb/Mux.jl) and [Express](https://expressjs.com/).  

You can see a simple example in the main [Readme.md](https://github.com/amellnik/Joseki.jl/blob/master/README.md) file.  

## Basics

```@docs
Joseki.router(endpoints::Array{Tuple{T, String, String}, 1}; middleware=default_middleware, error_fn=unhandled_error_responder) where {T<:Function}
```

## Middleware

```@docs
Joseki.add_cors!(req::HTTP.Request)
Joseki.content_type!(req::HTTP.Request)
Joseki.hit_logger!(req::HTTP.Request)
Joseki.body_logger!(req::HTTP.Request)
```

## Responders

```@docs
json_responder(req::HTTP.Request, o::T) where {T<:Union{Number, AbstractString, Array, Dict}}
error_responder(req::HTTP.Request, e::String)
Joseki.unhandled_error_responder(req::HTTP.Request,e::Exception)
```

## Utilities
```@docs
body_as_dict(req::HTTP.Request)
```

## Index

```@index
```
