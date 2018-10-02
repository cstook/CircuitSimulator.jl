using CircuitSimulator: parse_netlist

using Base.CoreLogging: Debug, global_logger
using Logging: ConsoleLogger
global_logger(ConsoleLogger(stderr, Debug))


netlist2=IOBuffer(
"""netlist2
R1 a b 10k + V(a) + V(b,1)
R1 a b 10k + V(a) + V(b,1) a = 1 b = 34
R1 a b 10k + V(a) + V(b,1) a 1 b 34
R1 c d I(R1) - 7.9megOhm
""")
pc2 = parse_netlist(netlist2)
@debug "parsed netlist 2" pc2
