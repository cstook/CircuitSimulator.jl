
using Base.CoreLogging: Debug, global_logger, with_logger
using Logging: ConsoleLogger
using CircuitSimulator: parse_netlist, mna, Resistor, resistor

function debugMNA(f)
    pc = parse_netlist("debug/f4r2.net")
    m = mna(pc)
end

with_logger(ConsoleLogger(stderr, Debug)) do
    debugMNA("debug/f4r2.net")
end

d = Dict{Symbol,Int}(:a=>1,:b=>2)

for (s,i) in d
    println(s,i)
end


e = Dict{Symbol,Int}(:a=>3,:d=>2)

union(d,f)

f = Set((:a,:f))
