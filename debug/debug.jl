push!(LOAD_PATH,"..")
using Base.CoreLogging: Debug, global_logger, with_logger
using Logging: ConsoleLogger
using CircuitSimulator: parse_netlist, mna, Resistor, resistor, blankmna


function debugMNA(f)
    pc = parse_netlist(f)
    b = blankmna(pc)
    m = mna(pc)
end

with_logger(ConsoleLogger(stderr, Debug)) do
    debugMNA("f4r2.net")
end


m = debugMNA("debug/f4r2.net")
x = zeros(Float64,length(m.group1Names)+length(m.group2Names))

H = m.H
g = m.g
H*[f(x) for f in g]
G = m.G
g[1]

using LinearAlgebra
using SparseArrays
x = spzeros(7)
using  LinearAlgebra
A = [1 2;3 4]
B = [1.0,2.0,3,4,5,6,7]
Y = [0.0,0,0,0,0,0,0]

mul!(Y,x,G)
Y


A = [1,2,3]
A += [5,6,7]
