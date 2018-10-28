__precompile__()

module CircuitSimulator

using ResumableFunctions
using SparseArrays
using Base.Meta
using LinearAlgebra
using NLsolve
using DifferentialEquations


include("def_macro.jl")
include("types.jl")
include("spiceunits.jl")
include("parse_netlist.jl")
include("readcards.jl")
include("modified_nodal_analysis.jl")
include("solve_dc.jl")
include("problem.jl")

end # module
