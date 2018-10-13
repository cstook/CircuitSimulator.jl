push!(LOAD_PATH,"..")
using Base.CoreLogging: Debug, global_logger, with_logger
using Logging: ConsoleLogger
using CircuitSimulator: parse_netlist, mna, Resistor, resistor, blankmna, MNA
using NLsolve, LinearAlgebra, SparseArrays


function debugMNA(f)
    pc = parse_netlist(f)
    b = blankmna(pc)
    m = mna(pc)
end

with_logger(ConsoleLogger(stderr, Debug)) do
    debugMNA("f4r2.net")
end


m = debugMNA("debug/f4r2.net")
x = zeros(Float64,length(m.group1Names)+length(m.group2Names))

H = m.H
g = m.g
H*[f(x) for f in g]
G = m.G
g[1]

using LinearAlgebra
using SparseArrays
x = spzeros(7)
using  LinearAlgebra
A = [1 2;3 4]
B = [1.0,2.0,3,4,5,6,7]
x = [1.0,2,3,4,5,6,7]

Y = similar(x)
mul!(Y,G,x,)

N = Float64
Array{N}(undef,size(A))

A = [1,2,3]
A += [5,6,7]


methods(mul!)


A=[1.0 2.0; 3.0 4.0]; B=[1.0 1.0; 1.0 1.0]; Y = Array{Float64}(undef,2,2); mul!(Y, A, B);
A=[1.0 2.0; 3.0 4.0; 3 4; 3 4;5 5;5 5]; B=[1.0,1.0]; Y = Array{Float64}(undef,6); mul!(Y, A, B);
size(A)[1]

struct Z{N}
    x::Int
end

Z{Float64}(1)
zeros(Int,3)
w = working(m)
nlsolve((F,x)->f!(F,x,m,w),  [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0])

g = (F,x)->f!(F,x,m)

z = Array{Float64}(undef,7)
g(z,zeros(Float64,1))



f!(z, [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0],m)


m.s
(i,v) = findnz(m.s)
for _i in i
    println(_i, "   ", v)
end


Vector{Float64}(undef,3)
m

function q(x::Vector{T}) where T<:Number
    zeros(T,3)
end

q([1,2,3,4,5,6])
q(1.1)

A = spzeros(Float64,5)
A[2] = 4.6
findnz(A)
for (i,v) in findnz(A)
    println("dfgdfg")
end



size(m.G)[1]
length(m.g)
size(m.H)[1]
length(m.s)
