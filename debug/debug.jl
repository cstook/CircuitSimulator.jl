push!(LOAD_PATH,"..")
using Base.CoreLogging: Debug, global_logger, with_logger
using Logging: ConsoleLogger
using CircuitSimulator: parse_netlist, mna, Resistor, resistor, blankmna, MNA
using NLsolve, LinearAlgebra, SparseArrays

f = "debug/f4r2.net"
function debugMNA(f)
    pc = parse_netlist(f)
    b = blankmna(pc)
    m = mna(pc)
end

with_logger(ConsoleLogger(stderr, Debug)) do
    debugMNA(f)
end


m = debugMNA(f)
G = Array(m.G)
g = Array(m.g)
H = Array(m.H)
m.S



include("../src/solve_dc.jl")
w = working(m)
with_logger(ConsoleLogger(stderr, Debug)) do
    nlsolve((F,x)->f!(F,x,m,w), zeros(5))
end

F=zeros(5)
f!(F,x)=f!(F,x,m,w)
with_logger(ConsoleLogger(stderr, Debug)) do
    f!(F,[2.0, 2.0, 2.0, 2.0, 2.0])
end

g[1]([3.0,2.0,3,3,3])

f1(x,y)=1.52e-9 * exp((-(y) + x) / (1.752 * 0.02585) - 1)
f1(3.0,2)
m.group1Names



m.group2Names
