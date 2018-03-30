
@def componentfileds begin
    name :: Symbol
    nodes :: Tuple{Vararg{Int}}
    value :: Union{Function,N}
end

abstract type Component{N<:Number} end

struct Resistor{N} <: Component{N} @componentfileds end
Resistor(name, nodes, value, parameter_string) = Resistor(name, nodes, value)

struct Inductor{N} <: Component{N} @componentfileds end
Inductor(name, nodes, value, parameter_string) = Inductor(name, nodes, value)

struct Capacitor{N} <: Component{N} @componentfileds end
Capacitor(name, nodes, value, parameter_string) = Capacitor(name, nodes, value)

struct VoltageSource{N} <: Component{N} @componentfileds end
VoltageSource(name, nodes, value, parameter_string) = VoltageSource(name, nodes, value)

struct CurrentSource{N} <: Component{N} @componentfileds end
CurrentSource(name, nodes, value, parameter_string) = CurrentSource(name, nodes, value)

const nodedict_type = Dict{Symbol,Int}

mutable struct ParsedCircuit{N<:Number}
    titleline :: String
    nodedict :: nodedict_type
    max_node :: Int
    max_element :: Int
    netlist :: Vector{Component{N}}
    ParsedCircuit{N}() where N = new("",Dict("0"=>0), 0, 0, Vector{Component{N}}())
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

function parse_2nodecomponent!(pc::ParsedCircuit, line)
    m = match(r"^([RLCVI]\S+)\s+(\S+)\s+(\S+)\s+(.*?)(?<![+*/-])\s([a-z][^(){}+*/-]*\s*(?:=|\s)\s*[^*/+-]\S*.*)"i,line) # two nodes
    m === nothing && return
    name = Symbol(m.captures[1])
    node_strings = (m.captures[2],m.captures[3])
    value_string = m.captures[4]
    parameters_string = m.captures[5]
    value = parse_spiceexpression(value_string)
    nodes = update_nodedict!(pc, node_strings)
    if line[1] == 'R'
        newcomponent = Resistor(name, nodes, value, parameter_string)
    elseif line[1] == 'C'
        newcomponent = Capacitor(name, nodes, value, parameter_string)
    elseif line[1] =='L'
        newcomponent = Inductor(name, nodes, value, parameter_string)
    elseif line[1] =='V'
        newcomponent = VoltageSource(name, nodes, value, parameter_string)
    elseif line[1] =='I'
        newcomponent = CurrentSource(name, nodes, value, parameter_string)
    end
    pc.max_element +=1
    push!(pc.netlist, newcomponent)
end

function update_nodedict!(pc::ParsedCircuit, node_strings)
    nodearray = Array{Int}()
        for node_string in node_strings
            pc.max_node +=1
            if ~(node_string ∈ keys(pc.nodedict))
            pc.nodedict[node_string]=pc.max_node
        end
        push!(nodearray, pc.nodedict[node_string])
    end
    (nodearray...)
end

function parse_spiceexpression(s)
    parse(s)  # for now
end
