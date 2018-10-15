using CircuitSimulator: ParsedCircuit, MNA,
                        parse_netlist,NameDict, Resistor,
                        Inductor,Capacitor, CurrentSource, VoltageSource
@testset "parser Tests" begin
    @test typeof(ParsedCircuit{Float64}()) == ParsedCircuit{Float64}
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

    pc = @test_logs (:warn, "Not Processed: ") parse_netlist(netlist1)
    @test pc.titleline == "Hello World"
    @test pc.group1Names==NameDict(Symbol("a")=>1,Symbol("b")=>2,Symbol(1)=>3,Symbol(2)=>4, Symbol(0)=>0)
    @test pc.max_node == maximum(collect(values(pc.group1Names)))
    @test pc.netlist[1] == Resistor(:R1,(1,2),10.0e3,nothing)
    @test pc.netlist[2] == Resistor(:R2,(1,0),10.0,nothing)
    @test pc.netlist[3] == Inductor(:Lone,(3,4),23.7e6,nothing)
    @test pc.netlist[4] == Capacitor(:C10,(3,1),2.0,nothing)
    @test pc.netlist[5] == VoltageSource(:V1,(2,0),2.0,nothing)
    @test pc.netlist[6] == CurrentSource(:I1,(4,2),3.0,nothing)
    @test pc.max_element == length(pc.netlist)
    netlist2=IOBuffer(
    """netlist2
    R1 a b 10k + V(a) + V(b,1)
    R1 a b 10k + V(a) + V(b,1) a = 1 b = 34
    R1 a b 10k + V(a) + V(b,1) a 1 b 34
    R1 c d I(R1) - 7.9megOhm
    """)
    pc2 = parse_netlist(netlist2)

    netlist3=IOBuffer(
    """
    \$ Example from p131
    \$

    Vs 0 1 2
    Vd1 1 2 1.52e-9*exp( V(2,1)/(1.752*0.5)-1 )  \$ 1N914 Is = 1.52e-9, n=1.752, Vt=0.5 ?
    R1 2 0 1
    R3 2 3 1
    Vr2 3 0 I(Vr2)^3*(I(Vr2)-1) \$ R2
    R4 1 3 1
    """
    )
    pc3 = parse_netlist(netlist3)
end
