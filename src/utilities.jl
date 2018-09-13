### Convenience functions

export body_as_dict
"""
    body_as_dict(req::HTTP.Request)

Endpoints that expect a `POST` request with a json-encoded body can use this.
"""
function body_as_dict(req::HTTP.Request)
    JSON.parse(String(req.body))
end

export has_all_required_keys
"""
    has_all_required_keys(required_keys::Array{String, 1}, json::T) where {T <: AbstractDict}

Returns true if the dict `j` contains all the required `keys`, false otherwise.  This is a convenience function to make endpoints more concise and readable.
"""
function has_all_required_keys(required_keys::Array{String, 1}, json::T) where {T <: AbstractDict}
    return count(in.(required_keys, Ref(keys(json)))) == length(required_keys)
end
