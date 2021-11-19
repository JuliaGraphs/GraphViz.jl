# GraphViz.jl

This package provides an interface to the the `GraphViz` package for graph visualization. There are two primary entry points:
 - The `GraphViz.load` function (not exported) to load graphs from a file
 - The `dot"""` string macro for literal inline specifications of graphs

Both of these accept `Graph` type accepts graph in [DOT](http://en.wikipedia.org/wiki/DOT_(graph_description_language)) format.
To load a graph from a non-constant string, use `GraphViz.load` with an `IOBuffer`.

# Getting started
If you already have a graph you would like to work with, the following code snippets may be helpful. If not, have a look
at the "Simple Examples" section below
```
using GraphViz
GraphViz.load("mygraph.dot")
dot"""
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
dot"""
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
```
