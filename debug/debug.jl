
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



a = spzeros(100,100)
