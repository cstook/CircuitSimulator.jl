macro def(name, definition)
    return quote
        macro $(esc(name))()
            esc($(Expr(:quote, definition)))
        end
    end
end

# http://www.stochasticlifestyle.com/type-dispatch-design-post-object-oriented-programming-julia/
