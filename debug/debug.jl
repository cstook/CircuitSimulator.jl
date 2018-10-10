
using Base.CoreLogging: Debug, global_logger, with_logger
using Logging: ConsoleLogger
using CircuitSimulator: parse_netlist, mna, Resistor, resistor, blankmna

function debugMNA(f)
    pc = parse_netlist("debug/f4r2.net")
    b = blankmna(pc)
    m = mna(pc)
end

with_logger(ConsoleLogger(stderr, Debug)) do
    debugMNA("debug/f4r2.net")
end


using SparseArrays
a = spzeros(Float32,5,5)


c=:asd
"aaaaaaaaaa  $c"
(5,6)[2]

1/5.0

inv(5.0)

f=x->x[1]+2*x[2]+3*x[3]
f([1,2,3])

io = IOBuffer()
write(io, "JuliaLang is a GitHub organization.", " It has many members.")
String(take!(io))
s = "abcdesfgijk"
s = "1.52e-9*exp( V(2,1)/(1.752*0.5)-1 )"
s = "v(2)"
ncodeunits(s)
i = 5
m = match(r"(.*?)[vi]\((.*?)\)()"i,s,i)
m.captures[1]
m.captures[2]
m.captures[3]
m.offset
m.offsets[1]
m.offsets[2]
m.offsets[3]
s[1:end]
function f()
    i = 1
    while i<10
        i+=1
    end
end

f()

s= "π"
length(s)

(a,b,c) = [1,2,3]
a

uppercase("v") == "V"

parameters = " 1 , 2 "

m = match(r"\s*(\S*)\s*,\s*(\S*)\s*",parameters)

string(1)

d = Dict{Symbol,Int}(Symbol(1)=>1)

d[1]
