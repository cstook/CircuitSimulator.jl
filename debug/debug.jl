push!(LOAD_PATH,"..")
using Base.CoreLogging: Debug, global_logger, with_logger
using Logging: ConsoleLogger
using CircuitSimulator: parse_netlist, mna, Resistor, resistor, blankmna, MNA,
        residual, myDEAProblem
using NLsolve, LinearAlgebra, SparseArrays
using DifferentialEquations

f = "debug/f4r2.net"

netio = IOBuffer(
"""
a simple test
Vs 1 0 sin(time*0.1)
R1 1 0 1.5
"""
)
function debugMNA(f)
    pc = parse_netlist(f)
    b = blankmna(pc)
    m = mna(pc)
end

with_logger(ConsoleLogger(stderr, Debug)) do
    debugMNA(f)
end

pc = parse_netlist(netio)
m = mna(pc)


prob = myDEAProblem(m)

sol = solve(prob)
