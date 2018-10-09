
using Base.CoreLogging: Debug, global_logger, with_logger
using Logging: ConsoleLogger
using CircuitSimulator: parse_netlist, mna, Resistor, resistor, MNAbuilder

function debugMNA(f)
    pc = parse_netlist("debug/f4r2.net")
    m = mna(pc)
end

with_logger(ConsoleLogger(stderr, Debug)) do
    debugMNA("debug/f4r2.net")
end


resistor{s}
dump(Meta.parse("V(1,2)+1"))

using SparseArrays
S = spzeros(100)

S[2] = 4.5

S2 = sparsevec([],Vector{String}(),100)

N=Float64
Vector{N}()



a = spzeros(Float32,100,100)

d = Dict(1=>"A")
e = d
e[6] = "B"
f = copy(d)
f[8] = "F"
f
d

struct A{T,U}
    a::T
    b::U
    function A{T,U}(a,b) where {T,U}
        new(a,b)
    end
end
A(a::T,b::U) where {T,U}= A{T,U}(a,b)

A(1,"d")
