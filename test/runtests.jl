using CircuitSimulator
using Test

function arrayequal(x::AbstractArray, y::AbstractArray)
    eq = true
    for (i,j) in zip(findall(!iszero,x),findall(!iszero,y))
        if i!=j
            eq=false
            break
        end
        if x[i] != y[i]
            eq=false
            break
        end
    end
    eq
end

include("readcardstest.jl")
include("parsertest.jl")
include("mnatests.jl")
