@testset "readcards Tests" begin
    using CircuitSimulator: readnoncommentline, cardpart, readcards
    @test readnoncommentline(IOBuffer("* comment line\n not a comment")) == " not a comment"
    @test readnoncommentline(IOBuffer("* comment line\n")) == ""
    testbuffer = IOBuffer("""
    * comment line
    * also should remove blank lines


    * line that
    this is not a comment
    * but this is
    2nd non comment line
    """)
    @test readnoncommentline(testbuffer) == "this is not a comment"
    @test readnoncommentline(testbuffer) == "2nd non comment line"
    @test cardpart("   abcd \$ comment") == (false, "abcd ")
    @test cardpart("   abcd // comment") == (false, "abcd ")
    @test cardpart("  + abcd // comment") == (true, " abcd ")
    @test cardpart("  + a\"\$\"bcd // comment") == (true, " a\"\$\"bcd ")
    @test cardpart("  + a\'\$\'bcd // comment") == (true, " a\'\$\'bcd ")
    @test cardpart("   abcd μ\$μ comment") == (false, "abcd μ")
    testbuffer = IOBuffer("""
    * Title Line
    *V1 N001 0 PULSE(0 1 0 .01 .01 {.5-.01} 1 10)
    V1 N001 0 1V
    R1 N003 N001 1k
    R2 0 N003 67.9
    R3 N003 N002 234\$ comment
    + a = 2 b = 3// comment
    + c = 6
    * comment
    + d = 7
    R4 N002 0 1Meg
    C1 N002 N001 1µ// comment
    .tran 20
    .backanno\$ comment
    .end
    """)
    verified = IOBuffer("""
    V1 N001 0 1V
    R1 N003 N001 1k
    R2 0 N003 67.9
    R3 N003 N002 234 a = 2 b = 3 c = 6 d = 7
    R4 N002 0 1Meg
    C1 N002 N001 1µ
    .tran 20
    .backanno
    .end
    """)
    testbuffercollected = collect(readcards(testbuffer))
    @test (length(testbuffercollected)) == 9
    for card in testbuffercollected
        @test card == readline(verified)
    end
end;
