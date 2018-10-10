
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


using SparseArrays
a = spzeros(Float32,5,5)


c=:asd
"aaaaaaaaaa  $c"
