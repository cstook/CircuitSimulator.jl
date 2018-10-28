# turn MNA system into a DifferentialEquations.jl problem type


# test with allocating math first
function residual(du,u,p,t,m::MNA{T,M,M2,V,V2,V3}) where {T<:Number,M,M2,V,V2,V3}
    G,H,g,D,E,d,S,s = m.G, m.H, m.g, m.D, m.E, m.d, m.S, m.s
    r1 = Array{T}(undef,length(S))
    r1 .= G*u .+ D*du .- S # linear part
    r2 = Array{T}(undef,length(g))
    for i in eachindex(g)
        r2[i] = g[i](u,t)
    end
    r3 = Array{T}(undef,length(d))
    for i in eachindex(d)
        r3[i] = d[i](u,t)
    end
    r1 .+= H*r2 #.+ D*r3
    #=
    for i in findall(!iszero, s)
        r1 .+= s[i](u,t)
    end
    =#
    r1
end

function defaultdu0(m::MNA{T,M,M2,V,V2,V3}) where {T<:Number,M,M2,V,V2,V3}
    zeros(T,length(m.S))
end
function defaultu0(m::MNA{T,M,M2,V,V2,V3}) where {T<:Number,M,M2,V,V2,V3}
    zeros(T,length(m.S))
end
function defaulttspan(m::MNA{T,M,M2,V,V2,V3}) where {T<:Number,M,M2,V,V2,V3}
    T(1.0)
end

myDEAProblem(m::MNA, du0=defaultdu0(m), u0=defaultu0(m), tspan=defaulttspan(m)) = DAEProblem((du,u,p,t)->residual(du,u,p,t,m), du0, u0, tspan)
