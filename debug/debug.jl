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
    debugMNA("debug/f4r2.net")
end


m = debugMNA("debug/f4r2.net")
x = zeros(Float64,length(m.group1Names)+length(m.group2Names))

H = m.H
g = m.g
H*[f(x) for f in g]
