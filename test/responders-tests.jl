using Test, Joseki, JSON
import HTTP.IOExtras.bytes

@testset "Responders" begin
    req = sample_request()
    obj = Dict{String, Any}("some string" => "a", "a number" => 3)
    expected = Dict{String, Any}("error" => false, "result" => obj)
    res = Joseki.json_responder(req, obj)
    @test JSON.parse(String(res.body)) == expected

    req = sample_request()
    obj = Dict{String, Any}("some string" => "a", "a number" => 3)
    res = Joseki.simple_json_responder(req, obj)
    @test JSON.parse(String(res.body)) == obj

    req = sample_request()
    expected = Dict{String, Any}("error" => true, "message" => "error goes here")
    res = Joseki.error_responder(req, "error goes here")
    @test JSON.parse(String(res.body)) == expected

    req = sample_request()
    res = Joseki.error_responder(req, DivideError())
    # Don't worry about the particular message
    @test JSON.parse(String(res.body))["error"]

    req = sample_request()
    res = Joseki.critical_error_responder(req, DivideError())
    # Don't worry about the particular message
    @test res.status == 500
end
