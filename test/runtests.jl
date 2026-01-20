using GraphViz, Cairo, Test

@testset "Basic tests" begin
    g = dot"""graph graphname {
        a [label="Foo"];
        b [shape=box];
        a -- b -- c [color=blue];
        b -- d [style=dotted];
    }"""
    @test_nowarn show(IOBuffer(), MIME"image/svg+xml"(), g)
    @test_nowarn show(IOBuffer(), MIME"image/png"(), g)

    dot_example = """graph graphname {
        a [label="Foo"];
        b [shape=box];
        a -- b -- c [color=blue];
        b -- d [style=dotted];
    }"""

    g = GraphViz.Graph(dot_example)
    @test_nowarn show(IOBuffer(), MIME"image/svg+xml"(), g)
    @test_nowarn show(IOBuffer(), MIME"image/png"(), g)

    @testset "Engine $engine" for engine in ["dot", "neato", "fdp", "circo", "twopi", "osage", "patchwork"]
        g = GraphViz.Graph(dot_example, engine=engine)
        @test_nowarn show(IOBuffer(), MIME"image/svg+xml"(), g)
        @test_nowarn show(IOBuffer(), MIME"image/png"(), g)
    end
end
