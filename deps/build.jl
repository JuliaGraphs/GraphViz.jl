using BinDeps

# Configuration / Autodetections
const x11 = @unix? (OS_NAME != :Darwin) : false
const gtk = isdir(Pkg.dir("Gtk"))

@BinDeps.setup

cgraph = library_dependency("cgraph",aliases = ["libcgraph","libcgraph.so.5"], validate = function(p,h)
    dlsym_e(h,:agmemread) != C_NULL
end)
gvc = library_dependency("gvc",aliases = ["libgvc"])

graphviz = [cgraph,gvc]

options = String[]
x11 ? push!(options,"--with-x") : push!(options,"--without-x")
gtk && push!(options,"--with-gtk")
push!(options,"--without-qt")
push!(options,"--with-pangocairo")
push!(options,"--enable-debug")

provides(Sources,URI("http://www.graphviz.org/pub/graphviz/stable/SOURCES/graphviz-2.36.0.tar.gz"),graphviz)
provides(BuildProcess,Autotools(libtarget = "lib/cgraph/.libs/libcgraph."*BinDeps.shlib_ext,configure_options=options),graphviz)

# Ubuntu GraphViz is too old
# provides(AptGet,"graphviz",graphviz)

@BinDeps.install