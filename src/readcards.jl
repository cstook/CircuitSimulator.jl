

@resumable function readcards(io::IO)::String
    iscontinueline, card = cardpart(readnoncommentline(io))
    while ~eof(io)
        iscontinueline, nextcard = cardpart(readnoncommentline(io))
        if iscontinueline
            card = card * nextcard
        else
            @yield card
            card, nextcard = nextcard, card
        end
    end
    @yield card
end

function readnoncommentline(io::IO)
    unwantedline = true
    line = ""
    while unwantedline && ~eof(io)
        line = readline(io)
        unwantedline = ismatch(r"^\s*(?:\*)",line) || ismatch(r"^\s*$",line)
    end
    return unwantedline ? "" : line
end

function cardpart(line)
    pos = 1
    m  = match(r"^\s*(\+)?(.*)"i,line,pos)
    iscontinueline = m.captures[1] == "+"
    pos = m.offsets[2]
    cardstart = pos
    while (m = match(r".*?([\"']).*?\1(.*)"i,line,pos)) != nothing
        pos = m.offsets[2]
    end
    m = match(r"(.)(?:(?:\$)|(?://))"i,line,pos)
    if m != nothing
        return (iscontinueline,line[cardstart:m.offset])
    else
        return (iscontinueline,line[cardstart:end])
    end
end
