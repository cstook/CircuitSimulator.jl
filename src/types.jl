
@def componentfileds begin
    name :: Symbol
    nodes :: Tuple{Vararg{Int}}
    value :: ValueType
end

abstract type Component{U} end

struct Resistor{ValueType} <: Component{ValueType} @componentfileds end
resistor(name, nodes, value, parameters_string) = Resistor(name, nodes, value)

struct Inductor{ValueType} <: Component{ValueType} @componentfileds end
inductor(name, nodes, value, parameters_string) = Inductor(name, nodes, value)

struct Capacitor{ValueType} <: Component{ValueType} @componentfileds end
capacitor(name, nodes, value, parameters_string) = Capacitor(name, nodes, value)

struct VoltageSource{ValueType} <: Component{ValueType} @componentfileds end
voltageSource(name, nodes, value, parameters_string) = VoltageSource(name, nodes, value)

struct CurrentSource{ValueType} <: Component{ValueType} @componentfileds end
currentSource(name, nodes, value, parameters_string) = CurrentSource(name, nodes, value)

const nodedict_type = Dict{Symbol,Int}

mutable struct ParsedCircuit{N<:Number}
    titleline :: String
    nodedict :: nodedict_type
    max_node :: Int
    max_element :: Int
    netlist :: Vector{Component{Union{N,String}}}
    ParsedCircuit{N}() where N = new("",Dict(Symbol(0)=>0), 0, 0, Vector{Component{Union{N,String}}}())
end

struct MNA{N<:Number, M<:AbstractArray, V<:AbstractArray}
    G :: M
    H :: M
    g :: V
    D :: M
    H2 :: M
    d :: V
    S :: V
    s :: V
    nodedict :: nodedict_type
    currentdict :: nodedict_type #cannot use spase vector here, zero(::Function) is undefined
    function MNA{N,M,V}(G,H,g,D,H2,d,S,s,nodedict,currentdict) where {N,M,V}
        @assert ndims(G) = 2 "G must have 2 dimensions"
        @assert ndims(H) = 2 "H must have 2 dimensions"
        @assert ndims(D) = 2 "D must have 2 dimensions"
        @assert ndims(H2) = 2 "H2 must have 2 dimensions"
        @assert ndims(g) = 1 "g must have 1 dimensions"
        @assert ndims(D) = 1 "D must have 1 dimensions"
        @assert ndims(S) = 1 "S must have 1 dimensions"
        @assert ndims(s) = 1 "s must have 1 dimensions"
        @assert begin (Gy,Gx) = size(G); Gy==Gx end "G not square"
        @assert begin (Hy,Hx) = size(H); Hx==length(g) end "H,g mismatch $(size(H)), $(length(g))"
        @assert begin (Dy,Dx) = size(D); Dy==Dx end "D not square"
        @assert begin (H2y,H2x) = size(H2); H2x==length(d) end "H2,d mismatch $(size(H2)), $(length(d))"
        if ~(G1==G2==H1==D1==D2==S1) throw(DimensionMismatch()) end
        new{N,M,V}(G,H,g,D,H2,d,S,s,nodedict,currentdict)
    end
end

#=
G*x(t) + H*g(x) + D*x'(t) = s(t)


G = MNA system matrix, constant matrix (linear resitors)
H = elements are either -1,0,+1
g(x) = vector of nonlinear element functions
D = constant matrix from L,C
H2 = elements are either -1,0,+1 not included yet
d(x) = nonlinear L,C, not included yet
S = constant source vector
s = nonlinear source vector
=#

struct MNAbuilder{N<:Number, Index<:Integer, NonlinearExpressions<:AbstractArray}
    Gi :: Vector{Index}
    Gj :: Vector{Index}
    Gvalue :: Vector{N}
    g :: NonlinearExpressions  # SparseVector?
    Hi :: Vector{Index}
    Hj :: Vector{Index}
    Hvalue :: Vector{Int8}
    Di :: Vector{Index}
    Dj :: Vector{Index}
    Dvalue :: Vector{N}
    H2i :: Vector{Index}
    H2j :: Vector{Index}
    H2value :: Vector{Int8}
    d :: NonlinearExpressions # SparseVector?
    Si :: Vector{Index}
    Sj :: Vector{Index} # all 1 for column vector
    Svalue :: Vector{N}
    s :: NonlinearExpressions # SparseVector?
    nodedict :: nodedict_type
    currentdict :: nodedict_type
    MNAbuilder{N,Index,NonlinearExpressions}() where {N<:Number, Index<:Integer, NonlinearExpressions<:AbstractArray} =
        new([],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],Dict(),Dict())
end
