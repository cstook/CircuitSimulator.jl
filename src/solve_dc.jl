

# G*x + H*g(x) - S + s(x) = 0

struct Working{T}
    a :: T
    b :: T
    c :: T
end
function working(m::MNA{N,M,M2,V,V2,V3}) where {N<:Number,M,M2,V,V2,V3}
    l = size(m.G)[1]
    a = Vector{N}(undef,length(m.g))
    b = zeros(N,l) #Vector{N}(undef,l)
    c = zeros(N,l)
    Working{Vector{N}}(a,b,c)
end

function f!(F,x,m::MNA{N,M,M2,V,V2,V3},w::Working=working(m)) where {N<:Number,M,M2,V,V2,V3}
    mul!(F,m.G,x)
    for i in eachindex(m.g)
        w.a[i] = m.g[i](x)
        @debug "f! g debug" nonlinear=w.a[i] i x
    end
    mul!(w.b,m.H,w.a)
#    (i,v) = findnz(m.s)
#    for _i in i
#        w.c[_i] = m.s[_i](x)
#    end
    F .= F .+ w.b .- m.S .- w.c
end
