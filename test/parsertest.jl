using CircuitSimulator: ParsedCircuit, MNA, MNAbuilder,
                        parse_netlist,nodedict_type, Resistor,
                        Inductor,Capacitor, CurrentSource, VoltageSource
@testset "parser Tests" begin
    @test typeof(ParsedCircuit{Float64}()) == ParsedCircuit{Float64}
    @test typeof(MNAbuilder{Float64}()) == MNAbuilder{Float64}
    netlist1=IOBuffer(
    """Hello World
    R1 a b 10k a=1
    R2 a 0 10 bgh s + 1
    Lone 1 2 23.7Meg b = 4 c = 5
    C10 1 a 2
    V1 b 0 2
    I1 2 b 3
    Z4 z x 45 \$ not a valid part
    """)
    print("Should see waring here: ")
    pc = parse_netlist(netlist1)
    @test pc.titleline == "Hello World"
    @test pc.nodedict==nodedict_type(Symbol("a")=>1,Symbol("b")=>2,Symbol(1)=>3,Symbol(2)=>4,Symbol(0)=>0)
    @test pc.max_node == maximum(collect(values(pc.nodedict)))
    @test pc.netlist[1] == Resistor(:R1,(1,2),10.0e3)
    @test pc.netlist[2] == Resistor(:R2,(1,0),10.0)
    @test pc.netlist[3] == Inductor(:Lone,(3,4),23.7e6)
    @test pc.netlist[4] == Capacitor(:C10,(3,1),2.0)
    @test pc.netlist[5] == VoltageSource(:V1,(2,0),2.0)
    @test pc.netlist[6] == CurrentSource(:I1,(4,2),3.0)
    @test pc.max_element == length(pc.netlist)
    netlist2=IOBuffer(
    """netlist2
    R1 a b 10k + V(a) + V(b,1)
    """)
    pc2 = parse_netlist(netlist2)
end
