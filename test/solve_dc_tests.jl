using CircuitSimulator: parse_netlist, mna, f!, working
using NLsolve: nlsolve

@testset "solve_dc tests" begin
    dc_test_net1 = IOBuffer(
    """
    \$ Example from p131
    Vs 1 0 2
    Id1 1 2 1.52e-9*exp( V(1,2)/(1.752*0.02585)-1 )  \$ 1N914 Is = 1.52e-9, n=1.752, Vt=0.02585 ?
    R1 2 0 1
    R3 2 3 1
    Vr2 3 0 I(Vr2)^3*(I(Vr2)-1) \$ R2
    R4 1 3 1
    """)
    pc = parse_netlist(dc_test_net1)
    m = mna(pc)

    result = nlsolve((F,x)->f!(F,x,m), zeros(5))
    @test arrayequal(result.zero,[2.0,1.0264162801997632,0.8405754962629832,
        1.3452652876737965,-2.37168156787356])
    @test m.g[1](result.zero,0) ≈ 1.212257064136541

    # for now...
    w = working(m)
    result = nlsolve((F,x)->f!(F,x,m,w), zeros(5))
end
