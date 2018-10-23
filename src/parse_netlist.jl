# functions to take a .net file and return a ParsedCircuit

function parse_2nodecomponent!(pc::ParsedCircuit{N}, line) where {N<:Number}
    regex1 = regex = r"^([RLCVI]\S+)\s+(\S+)\s+(\S+)\s+(.*)"i
    m = match(regex, line) # two nodes
    m === nothing && return false
    name = Symbol(m.captures[1])
    node_strings = (m.captures[2],m.captures[3])
    restofline = m.captures[4]
    regex2 = r"[a-z0-9_)}\'\"]()\s+[a-z_]"i
    m = match(regex2,restofline)
    if m === nothing
        value_string = restofline
        parameters_string = ""
    else
        value_string = restofline[1:m.offsets[1]]
        parameters_string = restofline[nextind(line,m.offsets[1]):end]
    end
    value = parse_constant_spicevalue(N, value_string)
    nodes = update_group1Names!(pc, node_strings)
    if line[1] == 'R'
        newcomponent = resistor(name, nodes, value,
            increment_length_g!(pc,value), parameters_string)
    elseif line[1] == 'C'
        newcomponent = capacitor(name, nodes, value,
            increment_length_d!(pc,value),parameters_string)
    elseif line[1] =='L'
        newcomponent = inductor(name, nodes, value,
            increment_length_d!(pc,value), parameters_string)
        push!(pc.group2,name)
    elseif line[1] =='V'
        newcomponent = voltageSource(name, nodes, value,
            increment_length_g!(pc,value),parameters_string)
        push!(pc.group2,name)
    elseif line[1] =='I'
        newcomponent = currentSource(name, nodes, value,
            increment_length_g!(pc,value), parameters_string)
    end
    pc.max_element +=1
    push!(pc.netlist, newcomponent)
    return true
end

increment_length_d!(::ParsedCircuit, ::Any) = nothing
function increment_length_d!(pc::ParsedCircuit, ::AbstractString)
    pc.length_d += 1
end
increment_length_g!(::ParsedCircuit, ::Any) = nothing
function increment_length_g!(pc::ParsedCircuit, ::AbstractString)
    pc.length_g += 1
end

function update_group1Names!(pc::ParsedCircuit, node_strings)
    nodearray = Vector{Int}()
        for node_string in node_strings
            node = Symbol(node_string)
            if ~(node ∈ keys(pc.group1Names))
                pc.max_node +=1
                pc.group1Names[node]=pc.max_node
            end
        push!(nodearray, pc.group1Names[node])
        end
    Tuple(nodearray)
end

function parse_netlist(filename::AbstractString, N::Type=Float64)
    io = open(filename)
    pc = nothing
    try
        pc = parse_netlist(io,N)
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
        @warn "Not Processed: " card
    end
    return pc
end

function parse_constant_spicevalue(N,s)
    (value = parse_spicevalue(N,s)) != nothing ? value : s
end
function parse_spicevalue(N,s)
    m = match(r"^\s*((?:[0-9]+(?:[.][0-9]*)?|[.][0-9]+)(?:[e][-+]?[0-9]+)?)
                (k|meg|mil|g|t|m|u|μ|n|p|f){0,1}[a-z0-9_.]*\s*$"ix,s)
    m === nothing && return nothing
    value = parse(N,m.captures[1])
    unitstring = m.captures[2]
    unitstring === nothing || (value *= N(units[lowercase(unitstring)]))
    return value
end





#=

function parse_spiceexpression(N,s)
    (value = parse_spicevalue(N,s)) != nothing && return value
    done, expression = parse_spiceexpression(s); done && return expression
    throw(ErrorException("Could Not Process: $s"))
end

function parse_spiceexpression(s)
    s = fix_spiceunits(s)
    s = fix_netvoltages(s)
    s = fix_branchcurrents(s)
    (true,Base.Meta.parse(s))
end
function fix_spiceunits(s)
    regex = r"(?<![a-z_])(?<value>(?:[0-9]+(?:[.][0-9]*)?|[.][0-9]+)(?:[e][-+]?[0-9]+)?)
              (?<unit>k|meg|mil|g|t|m|u|μ|n|p|f)(?<junk>[a-z0-9_]*)()"ix
    m = match(regex,s)
    m === nothing && return s
    value,unit,junk,null = m.captures
    value_offset, unit_offset, junk_offset, next_offset = m.offsets
    s[1:prevind(s,value_offset)] * value * stringunits[lowercase(unit)] * fix_spiceunits(s[next_offset:end])
end
function fix_netvoltages(s)
    s = replace(s,r"v\(\s*(?<name>[^ ,)]+)\s*\)"i => s"netvoltage(Val(Symbol(\"\g<name>\")))")
    regex = r"v\(\s*(?<name1>[^ ,)]+)\s*,\s*(?<name2>[^ ,)]+)\s*\)"i
    subex = s"netvoltage(Val(Symbol(\"\g<name2>\")))-netvoltage(Val(Symbol(\"\g<name1>\")))"
    replace(s,regex => subex)
end
function fix_branchcurrents(s)
    s = replace(s,r"i\(\s*(?<name>[^ ,)]+)\s*\)"i => s"branchcurrent(Val(Symbol(\"\g<name>\")))")
    regex = r"i\(\s*(?<name1>[^ ,)]+)\s*,\s*(?<name2>[^ ,)]+)\s*\)"i
    subex = s"branchcurrent(Val(Symbol(\"\g<name2>\")))-branchcurrent(Val(Symbol(\"\g<name1>\")))"
    replace(s,regex => subex)
end

=#
