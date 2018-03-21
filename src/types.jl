
@def componentfileds2nodes begin
    name :: AbstractString
    node1 :: Int
    node2 :: Int
    parameters :: Dict{String,N}
    value
end

abstract type Component{N<:Number} end
struct Resistor{N} <: Component{N} @componentfileds2nodes end
struct Inductor{N} <: Component{N} @componentfileds2nodes end
struct Capacitor{N} <: Component{N} @componentfileds2nodes end
struct VoltageSource{N} <: Component{N} @componentfileds2nodes end
struct CurrentSource{N} <: Component{N} @componentfileds2nodes end

mutable struct ParsedCircuit{N}
    titleline :: String
    nodedict :: Dict{String,Int}
    max_node :: Int
    max_element :: Int
    netlist :: Vector{Component{N}}
    ParsedCircuit{N}() where N = new("",Dict("0"=>0), 0, 0, Vector{Component{N}}())
end
