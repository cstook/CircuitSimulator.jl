using CircuitSimulator: mna, parse_netlist, MNA
using SparseArrays
using FileIO, JLD2

mnaconstants(x::MNA) = (x.G,x.H,x.D,x.H2,x.S)

@testset "MNA tests" begin
    mna_test_net1 = IOBuffer(
    """
    \$ Example from p131
    Vs 1 0 2
    Id1 1 2 1.52e-9*exp( V(2,1)/(1.752*0.02585)-1 )  \$ 1N914 Is = 1.52e-9, n=1.752, Vt=0.02585 ?
    R1 2 0 1
    R3 2 3 1
    Vr2 3 0 I(Vr2)^3*(I(Vr2)-1) \$ R2
    R4 1 3 1
    """)
    if ~isfile("mna_test_1.jld2")
        @warn "Creating mna_test_1.jld2"
        pc_verified = parse_netlist(mna_test_net1)
        mna_verified = mna(pc_verified)
        verified = mnaconstants(mna_verified)
        @save "mna_test_1.jld2" verified
    end
    seekstart(mna_test_net1)
    pc = parse_netlist(mna_test_net1)
    m = mna(pc)
    c = mnaconstants(m)
    @load "mna_test_1.jld2" verified
    for i in eachindex(c)
        @test arrayequal(c[i],verified[i])
    end
end
