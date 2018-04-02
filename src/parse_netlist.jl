
function parse_2nodecomponent!(pc::ParsedCircuit{N}, line) where {N<:Number}
    regex = r"^(([RLCVI]\S+)\s+(\S+)\s+(\S+)\s+(.*?)(?<![+*/-])
    \s+([a-z][^(){}+*/-]*\s*(?:=|\s)\s*[^*/+-]\S*.*)*)
    |
    ([RLCVI]\S+)\s+(\S+)\s+(\S+)\s+(.*?)(?<![+*/-])\s*$"ix
    m = match(regex, line) # two nodes
    m === nothing && return false
    if ~(m.captures[1] === nothing)
        name = Symbol(m.captures[2])
        node_strings = (m.captures[3],m.captures[4])
        value_string = m.captures[5]
        parameters_string = m.captures[6]
    else
        name = Symbol(m.captures[7])
        node_strings = (m.captures[8],m.captures[9])
        value_string = m.captures[10]
        parameters_string = ""
    end
    value = parse_spiceexpression(N, value_string)
    nodes = update_nodedict!(pc, node_strings)
    if line[1] == 'R'
        newcomponent = resistor(name, nodes, value, parameters_string)
    elseif line[1] == 'C'
        newcomponent = capacitor(name, nodes, value, parameters_string)
    elseif line[1] =='L'
        newcomponent = inductor(name, nodes, value, parameters_string)
    elseif line[1] =='V'
        newcomponent = voltageSource(name, nodes, value, parameters_string)
    elseif line[1] =='I'
        newcomponent = currentSource(name, nodes, value, parameters_string)
    end
    pc.max_element +=1
    push!(pc.netlist, newcomponent)
    return true
end

function update_nodedict!(pc::ParsedCircuit, node_strings)
    nodearray = Vector{Int}()
        for node_string in node_strings
            node = Symbol(node_string)
            if ~(node ∈ keys(pc.nodedict))
                pc.max_node +=1
                pc.nodedict[node]=pc.max_node
            end
        push!(nodearray, pc.nodedict[node])
        end
    (nodearray...)
end

function parse_netlist(filename::AbstractString)
    io = open(filename)
    try
        pc = parse_netlist(io)
    finally
        close(io)
    end
    return pc
end
function parse_netlist(io::IO, N::Type=Float64)
    #seekstart(io)
    pc = ParsedCircuit{N}()
    pc.titleline = readline(io)
    for card in readcards(io)
        parse_2nodecomponent!(pc,card) && continue
        warn("Not Processed: ",card)
    end
    return pc
end

function parse_spiceexpression(N,s)
    done, value = parse_spicevalue(N,s); done && return value
    done, expression = parse_spiceexpression(s); done && return value
    throw(ErrorException("Could Not Process: $s"))
    # parse(N,s)  # for now
end
function parse_spicevalue(N,s)
    m = match(r"^\s*((?:[0-9]+(?:[.][0-9]*)?|[.][0-9]+)(?:[e][-+]?[0-9]+)?)
                (k|meg|mil|g|t|m|u|μ|n|p|f){0,1}[a-z0-9_.]*\s*$"ix,s)
    m === nothing && return (false, nothing)
    value = parse(N,m.captures[1])
    unitstring = m.captures[2]
    unitstring === nothing || (value *= N(units[lowercase(unitstring)]))
    return (true, value)
end
parse_spiceexpression(s) = (true, :nothing) # placeholder
