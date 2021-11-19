using GraphViz, Cairo, Test

let g = dot"""
graph graphname {
     // The label attribute can be used to change the label of a node
     a [label="Foo"];
     // Here, the node shape is changed.
     b [shape=box];
     // These edges both have different line properties
     a -- b -- c [color=blue];
     b -- d [style=dotted];
 }
"""
    @test_nowarn show(IOBuffer(), MIME"image/svg+xml"(), g)
    @test_nowarn show(IOBuffer(), MIME"image/png"(), g)
end

