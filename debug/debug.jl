push!(LOAD_PATH,"..")
using Base.CoreLogging: Debug, global_logger, with_logger
using Logging: ConsoleLogger
using CircuitSimulator: parse_netlist, mna, Resistor, resistor, blankmna, MNA
using NLsolve, LinearAlgebra, SparseArrays

f = "debug/f4r2.net"
function debugMNA(f)
    pc = parse_netlist(f)
    b = blankmna(pc,group2=Set(:Id1)
    m = mna(pc)
end

with_logger(ConsoleLogger(stderr, Debug)) do
    debugMNA(f)
end


m = debugMNA(f)
Array(m.G)
Array(m.H)


w = working(m)
nlsolve((F,x)->f!(F,x,m,w),  [1.0, 2.0, 3.0, 4.0, 5.0])


m.g
~true
