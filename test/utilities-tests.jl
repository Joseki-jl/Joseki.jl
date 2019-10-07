using Test, Joseki

@testset "Utility tests" begin
    j1 = Dict("a" => 1, "b" => 2)
    j2 = Dict("a" => 1, "c" => 2)
    required_keys = ["a", "b"]
    @test has_all_required_keys(required_keys, j1)
    @test !has_all_required_keys(required_keys, j2)
end
