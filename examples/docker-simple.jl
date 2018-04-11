using Joseki, JSON

### Create some endpoints

# This function takes two numbers x and y from the query string and returns x^y
# In this case they need to be identified by name and it should be called with
# something like 'http://localhost:8000/pow/?x=2&y=3'
function pow(req::HTTP.Request)
    j = HTTP.queryparams(HTTP.URI(req.target))
    if !(haskey(j, "x")&haskey(j, "y"))
        return error_responder(req, "You need to specify values for x and y!")
    end
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
    if !(haskey(j, "n")&haskey(j, "k"))
        return error_responder(req, "You need to specify values for n and k!")
    end
    json_responder(req, binomial(j["n"],j["k"]))
end

### Create and run the server

# Make a router and add routes for our endpoints.
endpoints = [
    (pow, "GET", "/pow"),
    (bin, "POST", "/bin")
]
s = Joseki.server(endpoints)

# If there is a PORT environment variable defined us it, otherwise use 8000
haskey(ENV, "PORT") ? port = ENV["PORT"] : port = 8000
# Figure out what the local IP is
ip = IPv4(split(readstring(`hostname -I`))[1])
# Fire up the server
HTTP.serve(s, ip, port; verbose=false)
