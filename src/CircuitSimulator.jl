__precompile__()

module CircuitSimulator

using ResumableFunctions
using Base.Meta
using Base.CoreLogging: Debug, global_logger
using Logging: ConsoleLogger
global_logger(ConsoleLogger(stderr, Debug))

include("def_macro.jl")
include("types.jl")
include("spiceunits.jl")
include("parse_netlist.jl")
include("readcards.jl")
include("modified_nodal_analysis.jl")

end # module
