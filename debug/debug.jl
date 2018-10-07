
using Base.CoreLogging: Debug, global_logger, with_logger
using Logging: ConsoleLogger
using CircuitSimulator: parse_netlist, mna

function debugMNA(f)
    pc = parse_netlist("debug/f4r2.net")
    #m = mna(pc)
end

with_logger(ConsoleLogger(stderr, Debug)) do
    debugMNA("debug/f4r2.net")
end



const a = [1,2,3,4,5,6]
@inbounds f() = a[4]
@code_native f()
@code_native a[4]

const b = (1,2,3,4,5,6)

g() = b[4]
@code_native g()
@code_native b[4]


struct A{T<:Union{Int,String}}
    x :: T
end

A(1)
A("sdgfsdfg")


using SparseArrays
spzeros(3)
SparseVector{Float64,Int64}<:AbstractArray
SparseMatrixCSC<:AbstractArray

(value = 1) == nothing && print("nothing")

value
a = [1 2 3;
    4 5 6;
    7 8 9]
a[1,3]

length(a)
size(a)
b = [1,2,3]

 ndims(b)
