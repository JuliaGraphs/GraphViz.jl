# GraphViz.jl

This package provides an interface to the the `GraphViz` package for graph visualization. The primary export is the 
`Graph` type. The `Graph` type accepts graph in [DOT](http://en.wikipedia.org/wiki/DOT_(graph_description_language)) format.
You may either pass in an IO object (see the below examples) from which to read the graph or pass it in as a string or memory blob (in form of a `Uint8` array). GraphViz will copy the graph so you do not need to worry about the memory being passed in. 

# Getting started
If you already have a graph you would like to work with, the following code snippets may be helpful. If not, have a look
at the "Simple Examples" section below
```
using GraphViz
open(Graph,"mygraph.dot")
Graph("""
 digraph graphname {
     a -> b -> c;
     b -> d;
 }
""")
```

# Usage

After obtaining the package through the package manager, the following suffices to load the package:

```
using GraphViz
```

Note that graphviz has many configuration options. In particular, both the Cairo and the GTK backends may be disabled
by default.

# Simple Examples
Try the following in an IJulia Notebook (this example is taken from [here](http://en.wikipedia.org/wiki/DOT_(graph_description_language))):

```
Graph("""
graph graphname {
     // The label attribute can be used to change the label of a node
     a [label="Foo"];
     // Here, the node shape is changed.
     b [shape=box];
     // These edges both have different line properties
     a -- b -- c [color=blue];
     b -- d [style=dotted];
 }
""")
