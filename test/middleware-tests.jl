using Test, Joseki
import HTTP.IOExtras.bytes

@testset "Middleware" begin
    req = sample_request()
    # Make sure this doesn't throw an error
    Joseki.require_json_body!(req)

    # Now make a bad request and make sure it does throw
    bad_body = "{definitely not valid json}"
    req = HTTP.Request("GET", "", [], bytes(bad_body))
    @test_throws Exception Joseki.require_json_body!(req)
end
