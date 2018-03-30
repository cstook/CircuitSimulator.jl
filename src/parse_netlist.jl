
function parse_2nodecomponent!(pc::ParsedCircuit{N}, line) where {N<:Number}
    m = match(r"^([RLCVI]\S+)\s+(\S+)\s+(\S+)\s+(.*?)(?<![+*/-])\s([a-z][^(){}+*/-]*\s*(?:=|\s)\s*[^*/+-]\S*.*)"i,line) # two nodes
    println(m)
    m === nothing && return false
    name = Symbol(m.captures[1])
    node_strings = (m.captures[2],m.captures[3])
    value_string = m.captures[4]
    parameters_string = m.captures[5]
    value = parse_spiceexpression(value_string,N)
    nodes = update_nodedict!(pc, node_strings)
    if line[1] == 'R'
        newcomponent = Resistor(name, nodes, value, parameters_string)
    elseif line[1] == 'C'
        newcomponent = Capacitor(name, nodes, value, parameters_string)
    elseif line[1] =='L'
        newcomponent = Inductor(name, nodes, value, parameters_string)
    elseif line[1] =='V'
        newcomponent = VoltageSource(name, nodes, value, parameters_string)
    elseif line[1] =='I'
        newcomponent = CurrentSource(name, nodes, value, parameters_string)
    end
    pc.max_element +=1
    push!(pc.netlist, newcomponent)
    return true
end

function update_nodedict!(pc::ParsedCircuit, node_strings)
    nodearray = Vector{Int}()
        for node_string in node_strings
            node = Symbol(node_string)
            pc.max_node +=1
            if ~(node ∈ keys(pc.nodedict))
            pc.nodedict[node]=pc.max_node
        end
        push!(nodearray, pc.nodedict[node])
    end
    (nodearray...)
end

function parse_netlist(filename::AbstractString)
    io = open(filename)
    pc = parse_netlist(io)
    close(io)
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

function parse_spiceexpression(s,N)
    convert(N,parse(s))  # for now
end

#=
constantNumeric:
    match: '(?i:(?<![a-z_])((?:[0-9]+(?:[.][0-9]*)?|[.][0-9]+)(?:[e][-+]?[0-9]+)?)(k|meg|mil|g|t|m|u|μ|n|p|f){0,1}([a-z0-9_]*))'
    name: 'meta.numeric.ngspice'
    captures:
      1: name: 'constant.numeric.ngspice'
      2: name: 'constant.numeric.ngspice'
      3: name: ''

=#
