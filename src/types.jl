
@def componentfileds begin
    name :: Symbol
    nodes :: Tuple{Vararg{Int}}
    value :: U
end

abstract type Component{U<:Union{Expr,Number}} end

struct Resistor{U} <: Component{U} @componentfileds end
resistor(name, nodes, value, parameters_string) = Resistor(name, nodes, value)

struct Inductor{U} <: Component{U} @componentfileds end
inductor(name, nodes, value, parameters_string) = Inductor(name, nodes, value)

struct Capacitor{U} <: Component{U} @componentfileds end
capacitor(name, nodes, value, parameters_string) = Capacitor(name, nodes, value)

struct VoltageSource{U} <: Component{U} @componentfileds end
voltageSource(name, nodes, value, parameters_string) = VoltageSource(name, nodes, value)

struct CurrentSource{U} <: Component{U} @componentfileds end
currentSource(name, nodes, value, parameters_string) = CurrentSource(name, nodes, value)

const nodedict_type = Dict{Symbol,Int}

mutable struct ParsedCircuit{N<:Number}
    titleline :: String
    nodedict :: nodedict_type
    max_node :: Int
    max_element :: Int
    netlist :: Vector{Component}
    ParsedCircuit{N}() where N = new("",Dict("0"=>0), 0, 0, Vector{Component}())
end

struct MNA{N<:Number, T<:AbstractArray{N,2}}
    G :: T
    H :: T
    g :: Vector{Function}
    D :: T
    S :: T
    s :: Dict{Int,Function}
    nodedict :: nodedict_type
    currentdict :: nodedict_type #cannot use spase vector here, zero(::Function) is undefined
    function MNA{N,T}(G,H,g,D,S,s,nodedict,currentdict) where {N,T}
        @assert begin (G1,G2) = size(G); G1==G2 end "G not square"
        @assert begin (H1,H2) = size(H); H2==length(g) end "H,g mismatch size(H) $(size(H)), $(length(g))"
        @assert begin (D1,D2) = size(D); D1==D2 end "D not square"
        @assert begin (S1,S2) = size(S); S2==1 end "S must be a columb vector"
        if ~(G1==G2==H1==D1==D2==S1) throw(DimensionMismatch()) end
        new{N,T}(G,H,g,D,S,s,nodedict,currentdict)
    end
end

struct MNAbuilder{N<:Number}
    Gi :: Vector{Int}
    Gj :: Vector{Int}
    Gvalue :: Vector{N}
    g :: Vector{Function}
    Hi :: Vector{Int}
    Hj :: Vector{Int}
    Hvalue :: Vector{N}
    Di :: Vector{Int}
    Dj :: Vector{Int}
    Dvalue :: Vector{N}
    Si :: Vector{N}
    Sj :: Vector{N} # all 1 for column vector
    Svalue :: Vector{N}
    s :: Dict{Int,Function}  #  assume sparse
    nodedict :: nodedict_type
    currentdict :: nodedict_type
    MNAbuilder{N}() where N<:Number =
        new([],[],[],[],[],[],[],[],[],[],[],[],[],Dict(),Dict(),Dict())
end
