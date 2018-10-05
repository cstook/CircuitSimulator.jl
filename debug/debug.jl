
using Base.CoreLogging: Debug, global_logger, with_logger
using Logging: ConsoleLogger
using CircuitSimulator: parse_netlist, mna

function debugMNA(f)
    pc = parse_netlist("debug/f4r2.net")
    m = mna(pc)
end

with_logger(ConsoleLogger(stderr, Debug)) do
    debugMNA("debug/f4r2.net")
end
