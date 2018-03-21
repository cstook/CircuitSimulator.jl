using CircuitSimulator: ParsedCircuit
@testset "parser Tests" begin
    @test typeof(ParsedCircuit{Float64}()) == ParsedCircuit{Float64}
end
