using Test, Joseki

@testset "Utilities" begin
    j1 = Dict("a" => 1, "b" => 2)
    j2 = Dict("a" => 1, "c" => 2)
    required_keys = ["a", "b"]
    @test has_all_required_keys(required_keys, j1)
    @test !has_all_required_keys(required_keys, j2)

    req = sample_request()
    j = Joseki.body_as_dict(req)
    @test j == Dict{String, Any}("x" => 5, "y" => 3)
end
