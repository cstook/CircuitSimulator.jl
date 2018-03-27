using CircuitSimulator: ParsedCircuit, MNA, MNAbuilder
@testset "parser Tests" begin
    @test typeof(ParsedCircuit{Float64}()) == ParsedCircuit{Float64}
    @test typeof(MNAbuilder{Float64}()) == MNAbuilder{Float64}
end
