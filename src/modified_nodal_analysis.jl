# functions to build MNA from parsed circuit
#


# group 2 strategy:
# ignore currents for current controled components for now.
# this allows the size of the MNA matrix to be determined without
# parsing expressions.
# could be fixed by only allowing current measurment at voltage sources.
function  mna(pc::ParsedCircuit{N}, group2 = Group2Type()) where N<:Number
    x = blankmna(pc,group2)
    processnetlist!(x,pc)
    x
end

function blankmna(pc::ParsedCircuit{N}, group2 = Group2Type()) where N<:Number
    mnagroup1Names = copy(pc.group1Names)
    pop!(mnagroup1Names,Symbol(0))
    mnaGroup2 = union(group2,pc.group2)
    y = length(mnagroup1Names) + length(mnaGroup2)
    G = spzeros(N, y, y)
    H = spzeros(Int8, y, pc.length_g)
    g = Array{Function}(undef, pc.length_g)
    D = spzeros(N, y, y)
    E = spzeros(Int8, y, pc.length_d)
    d = Array{Function}(undef, pc.length_d)
    S = spzeros(N, y)
    s = spzeros(Function, y)
    stateNames = copy(mnagroup1Names)
    i = pc.max_node+1
    group2Names = Dict{Symbol,Int}()
    for  name in mnaGroup2
        group2Names[name] = i
        i+=1
    end
    MNA(G,H,g,D,E,d,S,s,mnagroup1Names,group2Names)
end

function processnetlist!(x::MNA, pc::ParsedCircuit{N})  where N<:Number
    for component ∈ pc.netlist
        addstamp!(x, component, component.name∈keys(x.group2Names))
    end
end

# DO NOT ADD NODE 0!
# retain currents for group 2, voltage sources and anything else we want currents for
addstamp!(::MNA, c::Component, ::Bool) = @warn "unknown component" c
function addstamp!(x::MNA, c::Resistor{T}, g2::Bool) where T<:Number
    vp = c.nodes[1]
    vn = c.nodes[2]
    if g2
        if vp!=0
            x.G[i,vp] += +1
            x.G[vp,i] += +1
        end
        if vn!=0
            x.G[i,vn] += -1
            x.G[vn,i] += -1
        end
        i = x.group2Names[c.name]
        x.G[i,i] += c.value
    else
        g = inv(c.value)
        if vp!=0
            x.G[vp,vp] += +g
        end
        if vn!=0
            x.G[vn,vn] += +g
            if vp!=0
                x.G[vp,vn] += -g
                x.G[vn,vp] += -g
            end
        end
    end
end
function addstamp!(x::MNA, c::Resistor{T}, g2::Bool) where T<:AbstractString
end

function addstamp!(x::MNA, c::VoltageSource{T}, g2::Bool) where T<:Number
    if ~g2
        throw(ErrorException("$(c.name) not in group 2"))
    end
    vp = c.nodes[1]
    vn = c.nodes[2]
    i = x.group2Names[c.name]
    if vp!=0
        x.G[i,vp] += +1
        x.G[vp,i] += +1
    end
    if vn!=0
        x.G[i,vn] += -1
        x.G[vn,i] += -1
    end
    x.S[i] += c.value
end
function addstamp!(x::MNA, c::VoltageSource{T}, g2::Bool) where T<:AbstractString
    if ~g2
        throw(ErrorException("$(c.name) not in group 2"))
    end
    f = valuefunction(x,c.value)
    x.g[c.dg_position] = f
    vp = c.nodes[1]
    vn = c.nodes[2]
    i = x.group2Names[c.name]
    if vp!=0
        x.G[i,vp] += +1
        x.G[vp,i] += +1
    end
    if vn!=0
        x.G[i,vn] += -1
        x.G[vn,i] += -1
    end
    x.H[i,c.dg_position] = -1
end
function addstamp!(x::MNA, c::CurrentSource{T}, g2::Bool) where T<:Number
    vp = c.nodes[1]
    vn = c.nodes[2]
    if g2
        i = x.group2Names[c.name]
        vp!=0 && (x.G[vp,i] += +1)
        vn!=0 && (x.G[vn,i] += -1)
        x.G[i,i] += +1
        x.S[i] += c.value
    else
        vp!=0 && (x.S[vp] += -c.value)
        vn!=0 && (x.S[vn] += c.value)
    end
end
function addstamp!(x::MNA, c::CurrentSource{T}, g2::Bool) where T<:AbstractString
    vp = c.nodes[1]
    vn = c.nodes[2]
    f = valuefunction(x,c.value)
    x.g[c.dg_position] = f
    if g2
        i = x.group2Names[c.name]
        vp!=0 && (x.G[vp,i] += +1)
        vn!=0 && (x.G[vn,i] += -1)
        x.H[i,c.dg_position] = 1
    else
        vp!=0 && (x.H[vp,c.dg_position] = 1)
        vn!=0 && (x.H[vn,c.dg_position] =-1)
    end
end
function addstamp!(x::MNA, c::Capacitor{T}, g2::Bool) where T<:Number
    vp = c.nodes[1]
    vn = c.nodes[2]
    if g2
        i = x.group2Names[c.name]
        if vp!=0
            x.D[vp,i] = -c.value
        end
        if vn!=0
            x.D[vn,i] = c.value
        end
        x.G[i,i] = 1
    else
        if vp!=0
            x.D[vp,vp] += +c.value
        end
        if vn!=0
            x.D[vn,vn] += +c.value
            if vp!=0
                x.D[vp,vn] += -c.value
                x.D[vn,vp] += -c.value
            end
        end
    end
end
function addstamp!(x::MNA, c::Inductor{T}, g2::Bool) where T<:Number
    if ~g2
        throw(ErrorException("$(c.name) not in group 2"))
    end
    vp = c.nodes[1]
    vn = c.nodes[2]
    i = x.group2Names[c.name]
    if vp!=0
        x.D[vp,i] = 1
    end
    if vn!=0
        x.D[vn,i] = -1
    end
    x.D[i,i] = c.value
end

# take a spice expression as a string and return an
# anonymous function of the state variable of the MNA system
# todo: spice units
function valuefunction(x::MNA, s::AbstractString, io=IOBuffer())
    l = ncodeunits(s)
    i = 1
    write(io,"(x,time)->")
    while i<=l
        m = match(r"(.*?)([vi])\((.*?)\)()"i,s,i)
        if m==nothing
            write(io,s[i:end])
            break
        end
        i = m.offsets[4]
        (before,vi,parameters,nullstring) = m.captures
        write(io,before)
        isv = uppercase(vi) == "V"
        m = match(r"\s*(\S*)\s*,\s*(\S*)\s*",parameters)
        if m!=nothing
            (n,p) = m.captures
            write(io,"( x[")
            index = isv ? x.group1Names[Symbol(n)] : x.group2Names[Symbol(n)]
            write(io,string(index))
            write(io,"] -x[")
            index = isv ? x.group1Names[Symbol(p)] : x.group2Names[Symbol(p)]
            write(io,string(index))
            write(io,"] )")
        else
            m = match(r"\s*(\S*)\s*",parameters)
            p = m.captures[1]
            write(io," x[")
            index = isv ? x.group1Names[Symbol(p)] : x.group2Names[Symbol(p)]
            write(io,string(index))
            write(io,"] ")
        end
    end
    newstring = String(take!(io))
    ex = Meta.parse(newstring)
    @debug "expression parser" s newstring  ex
    eval(ex)
end
