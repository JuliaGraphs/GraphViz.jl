module GraphViz

    using Requires
    using Graphviz_jll
    using FileIO
    using Base: unsafe_convert

    include("capi.jl")

    function jl_afread(io::IO, buf::Ptr{UInt8}, bufsize::Cint)
        #@show (io,buf,bufsize)
        ret = readbytes!(io,unsafe_wrap(Array,buf,Int(bufsize)))
        #@show ret
        convert(Cint,ret)
    end

    function jl_putstr(io::IO, str::Ptr{UInt8})
        #@show (io,str)
        convert(Cint,write(io,unsafe_wrap(Array,str,Int(ccall(:strlen,Csize_t,(Ptr{UInt8},),str)))))::Cint
    end

    jl_flush(io::IO) = convert(Cint,0)


    null(::Type{gvplugin_installed_t}) = gvplugin_installed_t(Int32(0),convert(Ptr{UInt8},0),
        Int32(0),convert(Ptr{gvdevice_engine_t},0),convert(Ptr{gvdevice_features_t},0))
    null(::Type{gvplugin_api_t}) = gvplugin_api_t(Int32(0),convert(Ptr{gvplugin_installed_t},0))

    # Memory interface

    # I/O interface

    # API - Context

    mutable struct Context
        handle::Ptr{Cvoid}
        function Context()
            this = new(ccall((:gvContext,libgvc),Ptr{Cvoid},()))
            finalizer(free, this)
            this
        end
    end

    function free(t::Context)
        if t.handle != C_NULL
            ccall((:gvFreeContext,libgvc), Cvoid, (Ptr{Cvoid},), t.handle)
        end
        t.handle = C_NULL
    end

    # External API
    export @dot_str

    macro dot_str(str)
        :($Graph($str))
    end

    # Graph handle
    mutable struct Graph
        handle::Ptr{Cvoid}
        didlayout::Bool
        function Graph(p::Ptr{Cvoid})
            this = new(p,false)
            finalizer(free, this)
            this
        end
    end

    function free(g::Graph)
        if g.handle != C_NULL
            ccall((:agclose,libcgraph), Cint, (Ptr{Cvoid},), g.handle)
        end
        g.handle = C_NULL
    end

    function Graph(graph::IO)
        iodisc = Ref(Agiodisc_s(
            @cfunction(jl_afread,Cint,(Any,Ptr{UInt8},Cint)),
            @cfunction(jl_putstr,Cint,(Any,Ptr{UInt8})),
            @cfunction(jl_flush,Cint,(Any,))))
        discs = Ref(Agdisc_s(cglobal((:AgMemDisc,libcgraph)),
            cglobal((:AgIdDisc,libcgraph)),
            Base.unsafe_convert(Ptr{Agiodisc_s}, iodisc)))
        Graph(@GC.preserve iodisc ccall((:agread,libcgraph),Ptr{Cvoid},(Any,Ptr{Cvoid}),graph,discs))
    end
    Graph(graph::Vector{UInt8}) = Graph(IOBuffer(graph))
    Graph(graph::String) = @GC.preserve graph Graph(unsafe_wrap(Vector{UInt8}, graph))

    load(f::File{format"DOT"}) = open(Graph, f)


    function layout!(g::Graph;engine="neato", context = default_context[])
        @assert g.handle != C_NULL
        if ccall((:gvLayout,libgvc),Cint,(Ptr{Cvoid},Ptr{Cvoid},Ptr{UInt8}),context.handle,g.handle,engine) == 0
            g.didlayout = true
        end
    end

    render_x11(c::Context,g::Graph) = ccall((:gvRender,libgvc),Cint,(Ptr{Cvoid},Ptr{Cvoid},Ptr{UInt8},Ptr{Cvoid}),c.handle,g.handle,"x11",C_NULL)
    render_jobs(c::Context,g::Graph) = ccall((:gvRenderJobs,libgvc),Cint,(Ptr{Cvoid},Ptr{Cvoid}),c.handle,g.handle)

    # Render

    # IO device

    mutable struct IODeviceState
        io::IO
        oldwritefn::Ptr{Cvoid}
    end

    const active_devices = IdDict()

    function jlio_write(job::Ptr{Cvoid},s::Ptr{UInt8},len::Csize_t)
        job = unsafe_load(convert(Ptr{GVJ_s},job))
        ioc = unsafe_pointer_to_objref(job.context)::IODeviceState
        write(ioc.io,unsafe_wrap(Array,s,Int(len)))
        len #Julia doesn't do half things :)
    end

    # determined by counting bytes ;)
    const WRITEFN_OFFSET = 200

    function julia_io_initialize(firstjob::Ptr{Cvoid})
        #@show firstjob
        firstjob = convert(Ptr{GVJ_s},firstjob)
        job = unsafe_load(firstjob)
        # Temporarily put in our custom write function
        ioc = unsafe_pointer_to_objref(job.context)::IODeviceState
        writefnptr = convert(Ptr{Ptr{Cvoid}},job.gvc+WRITEFN_OFFSET)
        ioc.oldwritefn = unsafe_load(writefnptr)
        unsafe_store!(writefnptr,@cfunction(jlio_write,Csize_t,(Ptr{Cvoid},Ptr{UInt8},Csize_t)))
        # This function has void return
        nothing
    end
    function julia_io_finalize(firstjob::Ptr{Cvoid})
        # Reset the write pointer we changed in julia_io_initialize
        firstjob = convert(Ptr{GVJ_s},firstjob)
        job = unsafe_load(firstjob)
        ioc = unsafe_pointer_to_objref(job.context)::IODeviceState
        writefnptr = convert(Ptr{Ptr{Cvoid}},job.gvc+WRITEFN_OFFSET)
        unsafe_store!(writefnptr,ioc.oldwritefn)
        # Also remove it from the gc preserve dict
        haskey(active_devices,ioc) && pop!(active_devices,ioc)
        nothing
    end

    const default_context = Ref{Context}()

    const julia_io_engine = Ref{gvdevice_engine_t}()
    const julia_io_features = Ref{gvdevice_features_t}(gvdevice_features_t(Int32(GVDEVICE_DOES_TRUECOLOR|GVDEVICE_DOES_LAYERS),0.,0.,0.,0.,72.,72.))
    const julia_io_name = Vector{UInt8}("julia_io:svg")
    const julia_io_libname = Vector{UInt8}("julia_io")
    const julia_io_device = Ref{NTuple{2, gvplugin_installed_t}}()
    const julia_io_api = Ref{NTuple{2, gvplugin_api_t}}()

    function init_io_structs!()
        julia_io_engine[] = gvdevice_engine_t(@cfunction(julia_io_initialize,Cvoid,(Ptr{Cvoid},)),C_NULL,@cfunction(julia_io_finalize,Cvoid,(Ptr{Cvoid},)))
        julia_io_device[] = (
            gvplugin_installed_t(Int32(0),pointer(julia_io_name), Int32(0), unsafe_convert(Ptr{gvdevice_engine_t}, julia_io_engine), unsafe_convert(Ptr{gvdevice_features_t}, julia_io_features)),
            null(gvplugin_installed_t)
        )
        julia_io_api[] = (gvplugin_api_t(API_device, unsafe_convert(Ptr{gvplugin_installed_t}, julia_io_device)),
            null(gvplugin_api_t))
    end

    function add_julia_io!(c::Context)
        lib = Ref{gvplugin_library_t}(gvplugin_library_t(
            pointer(julia_io_libname),unsafe_convert(Ptr{gvplugin_api_t}, julia_io_api)))
        ccall((:gvAddLibrary,libgvc),Cvoid,(Ptr{Cvoid},Ptr{gvplugin_library_t}),c.handle,lib)
    end

    function render(io::IO,g::GraphViz.Graph; context = default_context[], format="julia_io:svg")
        if !g.didlayout
            error("Must call layout before calling render!")
        end
        state = IODeviceState(io,C_NULL)
        active_devices[state] = state
        ccall((:gvRenderContext,libgvc),Cint,(Ptr{Cvoid},Ptr{Cvoid},Ptr{UInt8},Any),context.handle,g.handle,format,state)
    end

    function Base.show(io::IO, ::MIME"image/svg+xml", x::Graph)
        if !x.didlayout
            layout!(x,engine="neato")
        end
        render(io,x)
    end

    graph_plugins(c::Context) = Graph(ccall((:gvPluginsGraph,libgvc),Ptr{Cvoid},(Ptr{Cvoid},),c.handle))

    function listPlugins(c,kind)
        s = Array(Cint,1)
        r = ccall((:gvPluginList,libgvc),Ptr{Ptr{UInt8}},(Ptr{Cvoid},Ptr{UInt8},Ptr{Cint},Ptr{UInt8}),c.handle,kind,s,C_NULL)
        if r == C_NULL
            error("No Plugins available")
        end
        ret = Array(ByteString,s[1])
        for i = 1:s[1]
            ret[i] = bytestring(unsafe_load(r,i))
            c_free(unsafe_load(r,i))
        end
        c_free(r)
        ret
    end

    function __init__()
        default_context[] = Context()
        @require Cairo="159f3aea-2a34-519c-b102-8c37f9878175" begin
            include("cairo.jl")
            Base.invokelatest(__init__cairo__, default_context[])
        end
        #@require Gtk="4c0ca9eb-093a-5379-98c5-f87ac0bbbf44" include("gtk.jl")
        init_io_structs!()
        add_julia_io!(default_context[])
    end
end
