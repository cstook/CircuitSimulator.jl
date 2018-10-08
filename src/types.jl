
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
    currentdict :: nodedict_type
    max_node :: Int
    max_element :: Int
    netlist :: Vector{Component}
    ParsedCircuit{N}() where N<:Number =
        new("",Dict(Symbol(0)=>0), Dict(), 0, 0, Vector{Component}())
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
struct MNA{N<:Number, M<:AbstractArray, M2<:AbstractArray, V<:AbstractArray}
    G :: M
    H :: M2
    g :: V
    D :: M
    H2 :: M2
    d :: V
    S :: V
    s :: V
    nodedict :: nodedict_type
    currentdict :: nodedict_type #cannot use spase vector here, zero(::Function) is undefined
    function MNA{N,M,M2,V}(G,H,g,D,H2,d,S,s,nodedict,currentdict) where {N,M,M2,V}
        @assert ndims(G) == 2 "G must have 2 dimensions"
        @assert ndims(H) == 2 "H must have 2 dimensions"
        @assert ndims(D) == 2 "D must have 2 dimensions"
        @assert ndims(H2) == 2 "H2 must have 2 dimensions"
        @assert ndims(g) == 1 "g must have 1 dimensions"
        @assert ndims(D) == 1 "D must have 1 dimensions"
        @assert ndims(S) == 1 "S must have 1 dimensions"
        @assert ndims(s) == 1 "s must have 1 dimensions"
        y = length(nodedict) + length(currentdict)
        (Gy,Gx) = size(G)
        @assert Gy==Gx "G not square $Gx x $Gy"
        @assert Gy==y "G wrong size $Gy, should be $y"
        (Hy,Hx) = size(H)
        @assert Hx==length(g) "H,g mismatch $Hx, $(length(g))"
        @assert Hy==y "H,y mismatch $Hy, $y"
        (Dy,Dx) = size(D)
        @assert Dy==Dx "D not square $Dx x $Gy"
        (H2y,H2x) = size(H2)
        @assert H2x==length(d) "H2,d mismatch $H2x, $(length(d))"
        @assert H2y==y "H2,y mismatch $H2y, $y"
        if ~(Gy==Gx==Hy==Dy==Dx==H2y==length(S)==length(g)==length(d)==length(s))
            throw(DimensionMismatch())
        end
        new{N,M,M2,V}(G,H,g,D,H2,d,S,s,nodedict,currentdict)
    end
end





#=
struct MNAbuilder{N<:Number, NonlinearExpressions<:AbstractArray}
    Gi :: Vector{Int}
    Gj :: Vector{Int}
    Gvalue :: Vector{N}
    g :: NonlinearExpressions  # SparseVector?
    Hi :: Vector{Int}
    Hj :: Vector{Int}
    Hvalue :: Vector{Int8}
    Di :: Vector{Int}
    Dj :: Vector{Int}
    Dvalue :: Vector{N}
    H2i :: Vector{Int}
    H2j :: Vector{Int}
    H2value :: Vector{Int8}
    d :: NonlinearExpressions # SparseVector?
    Si :: Vector{Int}
    Svalue :: Vector{N}
    s :: NonlinearExpressions # SparseVector?
    nodedict :: nodedict_type
    currentdict :: nodedict_type
    MNAbuilder{N}(l) where {N<:Number} =
        new([],[],[],   # G
            [],         # g
            [],[],[],   # H
            [],[],[],   # D
            [],[],[],   # H2
            [],         # d
            [],[],      # S
            [],         # s
            [],Dict(),Dict())
end
=#
