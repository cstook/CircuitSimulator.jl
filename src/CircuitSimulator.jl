__precompile__()

module CircuitSimulator

using ResumableFunctions

include("def_macro.jl")
include("types.jl")
include("spiceunits.jl")
include("parse_netlist.jl")
include("readcards.jl")


end # module
