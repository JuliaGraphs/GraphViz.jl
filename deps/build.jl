using BinDeps

# Configuration / Autodetections
const x11 = @unix? true : false
const gtk = isdir(Pkg2.dir("Gtk"))

@BinDeps.setup

cgraph = library_dependency("cgraph",aliases = ["libcgraph","libcgraph.so.5"], validate = function(p,h)
    dlsym_e(h,:agmemread) != C_NULL
end)
gvc = library_dependency("gvc",aliases = ["libgvc"])

graphviz = [cgraph,gvc]

options = String[]
x11 && push!(options,"--with-x")
gtk && push!(options,"--with-gtk")
push!(options,"--without-qt")

provides(Sources,URI("http://www.graphviz.org/pub/graphviz/development/SOURCES/graphviz-2.33.20130807.0447.tar.gz"),graphviz)
provides(BuildProcess,Autotools(libtarget = "lib/cgraph/.libs/libcgraph."*BinDeps.shlib_ext,configure_options=options),graphviz)

# Ubuntu GraphViz is too old
# provides(AptGet,"graphviz",graphviz)

@BinDeps.install