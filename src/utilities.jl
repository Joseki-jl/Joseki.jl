### Convenience functions

export body_as_dict
"""
    body_as_dict(req::HTTP.Request)

Endpoints that expect a `POST` request with a json-encoded body can use this.
"""
function body_as_dict(req::HTTP.Request)
    JSON.parse(String(req.body))
end
