using CircuitSimulator: ParsedCircuit, MNA, MNAbuilder,parse_netlist
@testset "parser Tests" begin
    @test typeof(ParsedCircuit{Float64}()) == ParsedCircuit{Float64}
    @test typeof(MNAbuilder{Float64}()) == MNAbuilder{Float64}
    netlist1=IOBuffer("""
    Hello World
    R1 a b 10 a=1
    R2 a 0 10
    Lone 1 2 23
    C10 1 a 2
    V1 b 0 2
    I1 2 b 3
    Z4 z x 45 \$ not a valid part
    """)
    parse_netlist(netlist1)
end
