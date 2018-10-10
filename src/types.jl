
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

const NameDict = Dict{Symbol,Int}
const Group2Type = Set{Symbol}

mutable struct ParsedCircuit{N<:Number}
    titleline :: String
    group1Names :: NameDict
    group2 :: Group2Type
    max_node :: Int
    max_element :: Int
    length_g :: Int
    length_d :: Int
    netlist :: Vector{Component}
    ParsedCircuit{N}() where N<:Number =
        new("",Dict(Symbol(0)=>0),Group2Type(),0,0,0,0,Vector{Component}())
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
struct MNA{M<:AbstractArray, M2<:AbstractArray, V<:AbstractArray, V2<:AbstractArray, V3<:AbstractArray}
    G :: M
    H :: M2
    g :: V
    D :: M
    H2 :: M2
    d :: V
    S :: V2
    s :: V3
    group1Names :: NameDict # nodes
    group2Names :: NameDict # components
    function MNA{M,M2,V,V2,V3}(G,H,g,D,H2,d,S,s,group1Names,group2Names) where {M,M2,V,V2,V3}
        @assert ndims(G) == 2 "G must have 2 dimensions"
        @assert ndims(H) == 2 "H must have 2 dimensions"
        @assert ndims(D) == 2 "D must have 2 dimensions"
        @assert ndims(H2) == 2 "H2 must have 2 dimensions"
        @assert ndims(g) == 1 "g must have 1 dimensions"
        @assert ndims(d) == 1 "d must have 1 dimensions"
        @assert ndims(S) == 1 "S must have 1 dimensions"
        @assert ndims(s) == 1 "s must have 1 dimensions"
        y = length(group1Names) + length(group2Names)
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
        if ~(Gy==Gx==Hy==Dy==Dx==H2y==length(S)==length(s))
            throw(DimensionMismatch())
        end
        new(G,H,g,D,H2,d,S,s,group1Names,group2Names)
    end
end
MNA(G::M, H::M2, g::V, D::M, H2::M2,
    d::V, S::V2, s::V3, group1Names, group2Names) where {M,M2,V,V2,V3} =
        MNA{M,M2,V,V2,V3}(G,H,g,D,H2,d,S,s,group1Names,group2Names)
