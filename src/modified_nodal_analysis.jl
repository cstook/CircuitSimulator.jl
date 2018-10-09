# functions to build MNA from parsed circuit
#


# group 2 strategy:
# ignore currents for current controled elements for now.
# this allows the size of the MNA matrix to be determined without
# parsing expressions.
# could be fixed by only allowing current measurment at voltage sources.
function  mna(pc::ParsedCircuit{N}, group2 = Group2Type()) where N<:Number
    mnagroup1Names = copy(pc.group1Names)
    mnaGroup2 = union(group2,pc.group2)
    y = length(mnagroup1Names) + length(mnaGroup2)
    G = spzeros(N, y, y)
    H = spzeros(Int8, y, pc.length_g)
    g = Array{Function}(undef, pc.length_g)
    D = spzeros(N, y, y)
    H2 = spzeros(Int8, y, pc.length_d)
    d = Array{Function}(undef, pc.length_d)
    S = spzeros(N, y)
    s = spzeros(Function, y)
    stateNames = copy(mnagroup1Names)
    i = pc.max_node+1
    for  name in mnaGroup2

    end
    x = MNA(G,H,g,D,H2,d,S,s,mnagroup1Names,mnaGroup2)

end


function mna______(pc::ParsedCircuit{N}, group2 = Group2Type()) where N<:Number
    x = MNAbuilder{N}()
    for (key,value) in pc.group1Names
        x.group1Names[key] = value
    end
    for i in eachindex(pc.netlist)
        element = pc.netlist[i]
        forcegroup2 =  element.name ∈ group2
        process!(x, element, forcegroup2, pc)
    end
    MNA(x,pc.max_node)
end


# retain currents for group 2, voltage sources and anything else we want currents for

#=
process!(x::MNAbuilder{T}, e::Component, forcegroup2::Bool, pc) where T = @warn "unknown element" element=(e.name)
function process!(x::MNAbuilder{T}, e::Resistor, forcegroup2::Bool, pc) where T
    if forcegroup2
        pc.max_node += 1
        x.currentdict[e.name] = pc.max_node
        pushvalue!(x.Gi,x.Gj,x.Gvalue, e.nodes[1],     pc.max_node,    one(T))
        pushvalue!(x.Gi,x.Gj,x.Gvalue, e.nodes[2],     pc.max_node,    -one(T))
        pushvalue!(x.Gi,x.Gj,x.Gvalue, pc.max_node, e.nodes[1],        one(T))
        pushvalue!(x.Gi,x.Gj,x.Gvalue, pc.max_node, e.nodes[1],        -one(T))
        pushvalue!(x.Gi,x.Gj,x.Gvalue, pc.max_node, pc.max_node,    e.value)
    else
        conductance = 1/e.value
        pushvalue!(x.Gi,x.Gj,x.Gvalue, e.nodes[1], e.nodes[1], conductance)
        pushvalue!(x.Gi,x.Gj,x.Gvalue, e.nodes[2], e.nodes[2], conductance)
        pushvalue!(x.Gi,x.Gj,x.Gvalue, e.nodes[1], e.nodes[2], -conductance)
        pushvalue!(x.Gi,x.Gj,x.Gvalue, e.nodes[2], e.nodes[1], -conductance)
    end
end
function process!(x::MNAbuilder{T}, e::Inductor, forcegroup2::Bool, pc) where T<:Number
end
function process!(x::MNAbuilder{T}, e::Capacitor, forcegroup2::Bool, pc) where T<:Number
end
function process!(x::MNAbuilder{T}, e::VoltageSource, ::Bool, pc)  where T<:Number # group 2 only
    pc.max_node += 1
    x.currentdict[e.name] = pc.max_node
    pushvalue!(x.Gi,x.Gj,x.Gvalue, pc.max_node, e.nodes[1],    one(T))
    pushvalue!(x.Gi,x.Gj,x.Gvalue, pc.max_node, e.nodes[2],    -one(T))
    pushvalue!(x.Gi,x.Gj,x.Gvalue, e.nodes[1],     pc.max_node, one(T))
    pushvalue!(x.Gi,x.Gj,x.Gvalue, e.nodes[2],     pc.max_node, -one(T))
    pushvalue!(x.Si,x.Sj,x.Svalue, pc.max_node, 1,           e.value)
end
function process!(x::MNAbuilder{T}, e::CurrentSource, forcegroup2::Bool, pc) where T<:Number
    if forcegroup2
        pc.max_node += 1
        x.currentdict[e.name] = pc.max_node
        pushvalue!(x.Gi,x.Gj,x.Gvalue, pc.max_node, e.nodes[1]     , one(T))
        pushvalue!(x.Gi,x.Gj,x.Gvalue, pc.max_node, e.nodes[2]     , -one(T))
        pushvalue!(x.Gi,x.Gj,x.Gvalue, pc.max_node, pc.max_node , one(T))
        pushvalue!(x.Si,x.Sj,x.Svalue, ps.max_node, 1           , e.value)
    else
        pushvalue!(x.Si,x.Sj,x.Svalue, e.nodes[1], 1, -e.value)
        pushvalue!(x.Si,x.Sj,x.Svalue, e.nodes[2], 1, e.value)
    end
end

function pushvalue!(i_array, j_array, value_array, i, j, value::N) where N<:Number
    if i>0 && j>0
        push!(i_array, i)
        push!(j_array, j)
        push!(value_array, value)
    end
end

function pushvalue!(x::MNAbuilder{N}, i, j, value::N) where N<:Number
    if i>0 && j>0
        push!(x.Gi, i)
        push!(x.Gj, j)
        push!(x.Svalue, value)
    end
end

function pushvalue!(x::MNAbuilder{N}, i, j, value::Expr) where N<:Number
    if i>0 && j>0
        # push! into H and g(x)
        @debug value
    end
end
=#
