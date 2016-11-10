module GraphViz
    if isfile(joinpath(dirname(@__FILE__),"..","deps","deps.jl"))
        include("../deps/deps.jl")
    else
        error("GraphViz not properly installed. Please run Pkg.build(\"GraphViz\").")
    end

    # Plugin Struct

    immutable gvdevice_engine_t
        initialize::Ptr{Void}
        format::Ptr{Void}
        finalize::Ptr{Void}
    end

    immutable Pointf
        x::Float64
        y::Float64
    end

    immutable gvdevice_features_t
        flags::Cint
        default_margin_x::Float64
        default_margin_y::Float64
        default_pagesize_x::Float64
        default_pagesize_y::Float64
        default_dpi_x::Float64
        default_dpi_y::Float64
    end

    immutable gvplugin_installed_t
        id::Cint
        ctype::Ptr{UInt8}
        quality::Cint
        engine::Ptr{gvdevice_engine_t}
        features::Ptr{gvdevice_features_t}
    end

    const API_render        = Int32(0)
    const API_layout        = Int32(1)
    const API_textlayout    = Int32(2)
    const API_device        = Int32(3)
    const API_loadimage     = Int32(4)

    const EMIT_SORTED                   = (1<<0)
    const EMIT_COLORS                   = (1<<1)
    const EMIT_CLUSTERS_LAST            = (1<<2)
    const EMIT_PREORDER                 = (1<<3)
    const EMIT_EDGE_SORTED              = (1<<4)
    const GVDEVICE_DOES_PAGES           = (1<<5)
    const GVDEVICE_DOES_LAYERS          = (1<<6)
    const GVDEVICE_EVENTS               = (1<<7)
    const GVDEVICE_DOES_TRUECOLOR       = (1<<8)
    const GVDEVICE_BINARY_FORMAT        = (1<<9)
    const GVDEVICE_COMPRESSED_FORMAT    = (1<<10)
    const GVDEVICE_NO_WRITER            = (1<<11)
    const GVRENDER_Y_GOES_DOWN          = (1<<12)
    const GVRENDER_DOES_TRANSFORM       = (1<<13)
    const GVRENDER_DOES_ARROWS          = (1<<14)
    const GVRENDER_DOES_LABELS          = (1<<15)
    const GVRENDER_DOES_MAPS            = (1<<16)
    const GVRENDER_DOES_MAP_RECTANGLE   = (1<<17)
    const GVRENDER_DOES_MAP_CIRCLE      = (1<<18)
    const GVRENDER_DOES_MAP_POLYGON     = (1<<19)
    const GVRENDER_DOES_MAP_ELLIPSE     = (1<<20)
    const GVRENDER_DOES_MAP_BSPLINE     = (1<<21)
    const GVRENDER_DOES_TOOLTIPS        = (1<<22)
    const GVRENDER_DOES_TARGETS         = (1<<23)
    const GVRENDER_DOES_Z               = (1<<24)
    const GVRENDER_NO_WHITE_BG          = (1<<25)
    const LAYOUT_NOT_REQUIRED           = (1<<26)
    const OUTPUT_NOT_REQUIRED           = (1<<27)


    immutable gvplugin_api_t
        api::Cint
        types::Ptr{gvplugin_installed_t}
    end

    immutable gvplugin_library_t
        name::Ptr{UInt8}
        apis::Ptr{gvplugin_api_t}
    end

    # Job Struct

    immutable gvplugin_active_device_t
        engine::Ptr{gvdevice_engine_t}
        id::Cint
        features::Ptr{gvdevice_features_t}
        ctype::Ptr{UInt8}
    end

    immutable gvplugin_active_render_t
        engine::Ptr{Void}
        id::Cint
        features::Ptr{Void}
        ctype::Ptr{UInt8}
    end

    immutable gvplugin_active_loadimage_t
        engine::Ptr{Void}
        id::Cint
        ctype::Ptr{UInt8}
    end

    immutable gv_argvlist_t
        argv::Ptr{Ptr{UInt8}}
        argc::Cint;
        alloc::Cint;
    end

    immutable Point{T}
        x::T
        y::T
    end

    immutable Box{T}
        topleft::Point{T}
        bottomright::Point{T}
    end

    immutable gvdevice_callback_t
        refresh::Ptr{Void}          # void (*refresh) (GVJ_t * job);
        button_press::Ptr{Void}     # void (*button_press) (GVJ_t * job, int button, pointf pointer);
        button_release::Ptr{Void}   # void (*button_release) (GVJ_t * job, int button, pointf pointer);
        motion::Ptr{Void}           # void (*motion) (GVJ_t * job, pointf pointer);
        modify::Ptr{Void}           # void (*modify) (GVJ_t * job, const char *name, const char *value);
        del::Ptr{Void}              # void (*del) (GVJ_t * job);  /* can't use "delete" 'cos C++ stole it */
        read::Ptr{Void}             # void (*read) (GVJ_t * job, const char *filename, const char *layout);
        layout::Ptr{Void}           # void (*layout) (GVJ_t * job, const char *layout);
        render::Ptr{Void}           # void (*render) (GVJ_t * job, const char *format, const char *filename);
    end

    # TODO: These are probably wrong
    type GVCOMMON_s
        info::Ptr{Ptr{UInt8}}
        cmdname::Ptr{UInt8}
        verbose::Cint
        config::UInt8
        auto_outfile_names::UInt8
        errorfn::Ptr{Void}
        show_boxes::Ptr{Ptr{Void}}
        lib::Ptr{Ptr{Void}}
        viewNum::Cint
        builtins::Ptr{Void}
        demand_loading::Cint
    end

    type GVC_s
        common::GVCOMMON_s

        config_path::Ptr{UInt8}
        config_found::UInt8

        input_filenames::Ptr{Ptr{UInt8}}

        gvgs::Ptr{Void}
        gvg::Ptr{Void}

        # Hack until tuples are properly inlined into types
        apis0::Ptr{Void}
        apis1::Ptr{Void}
        apis2::Ptr{Void}
        apis3::Ptr{Void}
        apis4::Ptr{Void}
        api0::Ptr{Void}
        api1::Ptr{Void}
        api2::Ptr{Void}
        api3::Ptr{Void}
        api4::Ptr{Void}
        packages::Ptr{Void}

        #  size_t (*write_fn) (GVJ_t *job, const char *s, size_t len);
        write_fn::Ptr{Void}

        # More stuff I don't need right now
    end

    type GVJ_s
        gvc::Ptr{GVC_s}
        next::Ptr{GVJ_s}
        next_active::Ptr{GVJ_s}

        common::Ptr{Void}

        obj_state::Ptr{Void}
        input_filename::Ptr{UInt8}
        graph_index::Cint

        layout_type::Ptr{UInt8}

        output_filename::Ptr{UInt8}
        output_file::Ptr{Void}
        output_data::Ptr{UInt8}
        output_data_allocated::Cuint
        output_data_position::Cuint

        output_langname::Ptr{UInt8}
        output_lang::Ptr{Cint}

        render::gvplugin_active_render_t
        device::gvplugin_active_device_t
        loadimage::gvplugin_active_loadimage_t

        callbacks::Ptr{gvdevice_callback_t}

        device_dpi::Pointf
        device_sets_dpi::UInt8

        displat::Ptr{Void}
        screen::Cint

        context::Ptr{Void}
        external_context::UInt8

        imagedata::Ptr{UInt8}

        flags::Cint

        numLayers::Cint
        layerNum::Cint

        pagesArraySize::Point{Int32}
        pagesArrayFirst::Point{Int32}
        pagesArrayMajor::Point{Int32}
        pagesArrayMinor::Point{Int32}
        pagesArrayElem::Point{Int32}
        numPages::Cint

        bb::Box{Float64}
        pad::Point{Float64}
        clip::Box{Float64}
        pageBox::Box{Float64}
        pageSize::Point{Float64}
        focus::Point{Float64}

        zoom::Float64
        rotation::Cint

        view::Point{Float64}
        canvasBox::Box{Float64}
        margin::Point{Float64}

        dpi::Point{Float64}

        width::UInt32
        height::UInt32

        pageBoundingBox::Box{Int32}
        boundingBox::Box{Int32}

        scale::Point{Float64}
        translation::Point{Float64}
        devscale::Point{Float64}

        fit_mode::UInt8
        needs_refresh::UInt8
        click::UInt8
        has_grown::UInt8
        has_been_rendered::UInt8

        button::UInt8
        pointer::Point{Float64}
        oldpointer::Point{Float64}

        current_obj::Ptr{Void}
        selected_obj::Ptr{Void}

        active_tooltip::Ptr{UInt8}
        selected_href::Ptr{UInt8}

        selected_obj_type_name::gv_argvlist_t
        selected_obj_attributes::gv_argvlist_t

        window::Ptr{Void}

        keybindings::Ptr{Void}
        numkeys::Cint
        keycodes::Ptr{Void}
    end

    # Disciplines


    immutable Agmemdisc_s      
        #void *(*open) (Agdisc_t*);  /* independent of other resources */
        open::Ptr{Void}
        #void *(*alloc) (void *state, size_t req);
        alloc::Ptr{Void}
        #void *(*resize) (void *state, void *ptr, size_t old, size_t req);
        resize::Ptr{Void}
        # void (*free) (void *state, void *ptr);
        free::Ptr{Void}
        # void (*close) (void *state);
        close::Ptr{Void}
    end

    immutable Agiddisc_s
        # void *(*open) (Agraph_t * g, Agdisc_t*);    /* associated with a graph */
        open::Ptr{Void}
        # long (*map) (void *state, int objtype, char *str, unsigned long *id, int createflag);
        map::Ptr{Void}
        # long (*alloc) (void *state, int objtype, unsigned long id);
        alloc::Ptr{Void}
        #void (*free) (void *state, int objtype, unsigned long id);
        free::Ptr{Void}
        #char *(*print) (void *state, int objtype, unsigned long id);
        print::Ptr{Void}
        #void (*close) (void *state);
        close::Ptr{Void}
        #void (*idregister) (void *state, int objtype, void *obj);
        idregister::Ptr{Void}
    end

    immutable Agiodisc_s
        # int (*afread) (void *chan, char *buf, int bufsize);
        afread::Ptr{Void}
        # int (*putstr) (void *chan, const char *str);
        putstr::Ptr{Void}
        # int (*flush) (void *chan);  /* sync */
        flush::Ptr{Void}
    end

    immutable Agdisc_s
        mem::Ptr{Agmemdisc_s}
        id::Ptr{Agiddisc_s}
        io::Ptr{Agiodisc_s}
    end

    function jl_afread(io::Ptr{Void}, buf::Ptr{UInt8}, bufsize::Cint)
        #@show (io,buf,bufsize)
        ret = readbytes!(unsafe_pointer_to_objref(io)::IO,unsafe_wrap(Array,buf,Int(bufsize)))
        #@show ret
        convert(Cint,ret)
    end

    function jl_putstr(io::Ptr{Void}, str::Ptr{UInt8})
        #@show (io,str)
        convert(Cint,write(unsafe_pointer_to_objref(io)::IO,unsafe_wrap(Array,str,Int(ccall(:strlen,Csize_t,(Ptr{UInt8},),str)))))::Cint
    end

    jl_flush(io::Ptr{Void}) = convert(Cint,0)


    const JuliaIODisc = [Agiodisc_s(
        cfunction(jl_afread,Cint,(Ptr{Void},Ptr{UInt8},Cint)),
        cfunction(jl_putstr,Cint,(Ptr{Void},Ptr{UInt8})),
        cfunction(jl_flush,Cint,(Ptr{Void},))
    )]


    null(::Type{gvplugin_installed_t}) = gvplugin_installed_t(Int32(0),convert(Ptr{UInt8},0),
        Int32(0),convert(Ptr{gvdevice_engine_t},0),convert(Ptr{gvdevice_features_t},0))
    null(::Type{gvplugin_api_t}) = gvplugin_api_t(Int32(0),convert(Ptr{gvplugin_installed_t},0))

    # Memory interface

    # I/O interface

    # API - Context

    type Context
        handle::Ptr{Void}
        function Context() 
            this = new(ccall((:gvContext,gvc),Ptr{Void},()))
            finalizer(this,free)
            this
        end
    end

    function free(t::Context) 
        if t.handle != C_NULL
            ccall((:gvFreeContext,gvc), Void, (Ptr{Void},), t.handle)
        end
        t.handle = C_NULL
    end

    # API - Graph

    export Graph

    type Graph
        handle::Ptr{Void}
        didlayout::Bool
        function Graph(p::Ptr{Void})
            this = new(p,false)
            finalizer(this,free)
            this
        end
    end

    function free(g::Graph)
        if g.handle != C_NULL
            ccall((:agclose,cgraph), Cint, (Ptr{Void},), g.handle)
        end
        g.handle = C_NULL
    end

    Graph(graph::IO) = Graph(ccall((:agread,cgraph),Ptr{Void},(Any,Ptr{Void}),graph,[Agdisc_s(
        cglobal((:AgMemDisc,cgraph)),
        cglobal((:AgIdDisc,cgraph)),
        pointer(JuliaIODisc)
        )]))
    Graph(graph::Vector{UInt8}) = Graph(IOBuffer(graph))
    Graph(graph::String) = Graph(graph.data)

    function layout!(g::Graph;engine="neato", context = default_context)
        @assert g.handle != C_NULL
        ccall((:gvLayout,gvc),Cint,(Ptr{Void},Ptr{Void},Ptr{UInt8}),context.handle,g.handle,engine)
        g.didlayout = true
    end

    render_x11(c::Context,g::Graph) = ccall((:gvRender,gvc),Cint,(Ptr{Void},Ptr{Void},Ptr{UInt8},Ptr{Void}),c.handle,g.handle,"x11",C_NULL)
    render_jobs(c::Context,g::Graph) = ccall((:gvRenderJobs,gvc),Cint,(Ptr{Void},Ptr{Void}),c.handle,g.handle)

    # Render

    # IO device

    type IODeviceState
        io::IO
        oldwritefn::Ptr{Void}
    end

    const active_devices = ObjectIdDict()

    function jlio_write(job::Ptr{Void},s::Ptr{UInt8},len::Csize_t)
        job = unsafe_load(convert(Ptr{GVJ_s},job))
        ioc = unsafe_pointer_to_objref(job.context)::IODeviceState
        write(ioc.io,unsafe_wrap(Array,s,Int(len)))
        len #Julia doesn't do half things :)
    end

    # determined by counting bytes ;)
    const WRITEFN_OFFSET = 200

    function julia_io_initialize(firstjob::Ptr{Void})
        #@show firstjob
        firstjob = convert(Ptr{GVJ_s},firstjob)
        job = unsafe_load(firstjob)
        # Temporarily put in our custom write function
        ioc = unsafe_pointer_to_objref(job.context)::IODeviceState
        writefnptr = convert(Ptr{Ptr{Void}},job.gvc+WRITEFN_OFFSET)
        ioc.oldwritefn = unsafe_load(writefnptr)
        unsafe_store!(writefnptr,cfunction(jlio_write,Csize_t,(Ptr{Void},Ptr{UInt8},Csize_t)))
        # This function has void return
        nothing
    end
    function julia_io_finalize(firstjob::Ptr{Void}) 
        # Reset the write pointer we changed in julia_io_initialize
        firstjob = convert(Ptr{GVJ_s},firstjob)
        job = unsafe_load(firstjob)
        ioc = unsafe_pointer_to_objref(job.context)::IODeviceState
        writefnptr = convert(Ptr{Ptr{Void}},job.gvc+WRITEFN_OFFSET)
        unsafe_store!(writefnptr,ioc.oldwritefn)
        # Also remove it from the gc preserve dict
        haskey(active_devices,ioc) && pop!(active_devices,ioc)
        nothing
    end

    const default_context = GraphViz.Context()

    const julia_io_engine = [ gvdevice_engine_t(cfunction(julia_io_initialize,Void,(Ptr{Void},)),C_NULL,cfunction(julia_io_finalize,Void,(Ptr{Void},))) ]
    const julia_io_features = [ gvdevice_features_t(Int32(GVDEVICE_DOES_TRUECOLOR|GVDEVICE_DOES_LAYERS),0.,0.,0.,0.,72.,72.) ]
    const julia_io_name = "julia_io:svg".data
    const julia_io_libname = "julia_io".data 
    const julia_io_device = 
    [ 
      gvplugin_installed_t(Int32(0),pointer(julia_io_name), Int32(0), pointer(julia_io_engine), pointer(julia_io_features));
      null(gvplugin_installed_t)
    ]
    const julia_io_api = 
    [
        gvplugin_api_t(API_device, pointer(julia_io_device))
        null(gvplugin_api_t)
    ]

    add_julia_io!(c::Context) = ccall((:gvAddLibrary,gvc),Void,(Ptr{Void},Ptr{gvplugin_library_t}),c.handle,[gvplugin_library_t(pointer(julia_io_libname),pointer(julia_io_api))])

    function render(io::IO,g::GraphViz.Graph; context = default_context, format="julia_io:svg")
        GraphViz.add_julia_io!(context)
        if !g.didlayout
            error("Must call layout before calling render!")
        end
        state = IODeviceState(io,C_NULL)
        active_devices[state] = state
        ccall((:gvRenderContext,GraphViz.gvc),Cint,(Ptr{Void},Ptr{Void},Ptr{UInt8},Any),context.handle,g.handle,format,state)
    end

    function Base.show(io::IO, ::MIME"image/svg+xml", x::Graph)
        if !x.didlayout
            layout!(x,engine="neato")
        end
        render(io,x)
    end

    # Cairo device

    if isdir(Pkg.dir("Cairo"))
        using Cairo

        function cairo_initialize(firstjob::Ptr{Void})
            firstjob = convert(Ptr{GVJ_s},firstjob)
            job = unsafe_load(firstjob)
            if job.context != C_NULL
                c = unsafe_pointer_to_objref(job.context)::CairoContext
                job.context = c.ptr
                job.external_context    = 0x1
                job.width = width(c.surface)
                job.height = height(c.surface)
                unsafe_store!(firstjob,job)
            else
                job.external_context = 1
                unsafe_store!(firstjob,job)
                global last_surface = firstjob
            end
            nothing
        end

        global last_surface = nothing

        function cairo_finalize(firstjob::Ptr{Void})
            #=firstjob = convert(Ptr{GVJ_s},firstjob)
            job = unsafe_load(firstjob)
            if last_surface == firstjob
                surface = ccall((:cairo_get_target,Cairo._jl_libcairo),Ptr{Void},(Ptr{Void},),job.context)
                last_surface = CairoSurface(surface, job.width, job.height)
            end=#
            nothing
        end

        function cairo_format(firstjob::Ptr{Void})
            global last_surface
            firstjob = convert(Ptr{GVJ_s},firstjob)
            job = unsafe_load(firstjob)
            if last_surface == firstjob
                surface = ccall((:cairo_get_target,Cairo._jl_libcairo),Ptr{Void},(Ptr{Void},),job.context)
                last_surface = CairoSurface(surface, job.width, job.height)
            end
            nothing
        end

        const generic_cairo_engine = [ gvdevice_engine_t(cfunction(cairo_initialize,Void,(Ptr{Void},)),cfunction(cairo_format,Void,(Ptr{Void},)),cfunction(cairo_finalize,Void,(Ptr{Void},))) ]
        const generic_cairo_features = [ gvdevice_features_t(Int32(0),0.,0.,0.,0.,96.,96.) ]
        const generic_cairo_features_interactive = [ gvdevice_features_t(Int32(0),0.,0.,0.,0.,96.,96.) ]
        const generic_cairo_name = "julia:cairo".data
        const generic_cairo_libname = "julia:cairo".data 
        const generic_cairo_device = 
        [ 
          gvplugin_installed_t(Int32(0),pointer(generic_cairo_name), Int32(0), pointer(generic_cairo_engine), pointer(generic_cairo_features));
          null(gvplugin_installed_t)
        ]
        const generic_cairo_api = 
        [
            gvplugin_api_t(API_device, pointer(generic_cairo_device))
            null(gvplugin_api_t)
        ]

        add_julia_cairo!(c::Context) = ccall((:gvAddLibrary,gvc),Void,(Ptr{Void},Ptr{gvplugin_library_t}),c.handle,[gvplugin_library_t(pointer(generic_cairo_libname),pointer(generic_cairo_api))])

        function render(c::CairoContext,g::GraphViz.Graph; context = default_context, format="julia:cairo")
            GraphViz.add_julia_cairo!(context)
            if !g.didlayout
                error("Must call layout before calling render!")
            end
            ccall((:gvRenderContext,GraphViz.gvc),Cint,(Ptr{Void},Ptr{Void},Ptr{UInt8},Any),context.handle,g.handle,format,c)
        end

        function cairo_render(g::GraphViz.Graph; context = default_context, format="julia:cairo")
            global last_surface
            GraphViz.add_julia_cairo!(context)
            if !g.didlayout
                error("Must call layout before calling render!")
            end
            ccall((:gvRenderContext,GraphViz.gvc),Cint,(Ptr{Void},Ptr{Void},Ptr{UInt8},Ptr{Void}),context.handle,g.handle,format,C_NULL)
            surface = last_surface
            last_surface = nothing
            return surface
        end

        function Base.show(io::IO, m::MIME"image/png", x::Graph)
            if !x.didlayout
                layout!(x,engine="dot")
            end
            show(io, m, cairo_render(x))
        end
        #=
        if isdir(Pkg.dir("Gtk"))
            using Gtk

            function gtk_initialize(firstjob::Ptr{Void})
                firstjob = convert(Ptr{GVJ_s},firstjob)
                job = unsafe_load(firstjob)
                c = unsafe_pointer_to_objref(job.context)::Gtk.Canvas
                c.data = firstjob
                job.context = getgc(c).ptr
                job.window = pointer_from_objref(c)
                unsafe_store!(firstjob,job)
                nothing
            end

            function gtk_finalize(firstjob::Ptr{Void})
                firstjob = convert(Ptr{GVJ_s},firstjob)
                job = unsafe_load(firstjob)
                c = unsafe_pointer_to_objref(job.window)::Gtk.Canvas
                draw(gtk_update,c)
                wait() #TODO: Make conditional on closing the widget
                nothing
            end 

            function gtk_update(c::Canvas)
                jobp = c.data::Ptr{GVJ_s}
                job = unsafe_load(jobp)
                job.height              = height(c)
                job.width               = width(c)
                job.context             = getgc(c).ptr
                job.external_context    = 0x1
                unsafe_store!(jobp,job)
                println(job.callbacks)
                println(unsafe_load(job.callbacks).refresh)
                ccall(unsafe_load(job.callbacks).refresh,Void,(Ptr{Void},),jobp)
            end
            const gtk_engine = [ gvdevice_engine_t(cfunction(gtk_initialize,Void,(Ptr{Void},)),C_NULL,cfunction(gtk_finalize,Void,(Ptr{Void},))) ]
            const gtk_features = [ gvdevice_features_t(Int32(GVDEVICE_EVENTS),0.,0.,0.,0.,96.,96.) ]
            const gtk_name = "julia_gtk:cairo".data
            const gtk_libname = "julia_gtk:cairo".data 
            const gtk_device = 
            [ 
              gvplugin_installed_t(Int32(0),pointer(gtk_name), Int32(0), pointer(gtk_engine), pointer(gtk_features));
              null(gvplugin_installed_t)
            ]
            const gtk_api = 
            [
                gvplugin_api_t(API_device, pointer(gtk_device))
                null(gvplugin_api_t)
            ]

            add_julia_gtk!(c::Context) = ccall((:gvAddLibrary,gvc),Void,(Ptr{Void},Ptr{gvplugin_library_t}),c.handle,[gvplugin_library_t(pointer(gtk_libname),pointer(gtk_api))])

            function render(c::Gtk.Canvas,cg::Context,g::Graph) 
                @async begin
                    add_julia_gtk!(cg)
                    ccall((:gvRenderContext,gvc),Cint,(Ptr{Void},Ptr{Void},Ptr{UInt8},Any),cg.handle,g.handle,"julia_gtk",c)    
                end
                nothing
            end
        end
        =#
    end

    graph_plugins(c::Context) = Graph(ccall((:gvPluginsGraph,gvc),Ptr{Void},(Ptr{Void},),c.handle))

    function listPlugins(c,kind)
        s = Array(Cint,1)
        r = ccall((:gvPluginList,gvc),Ptr{Ptr{UInt8}},(Ptr{Void},Ptr{UInt8},Ptr{Cint},Ptr{UInt8}),c.handle,kind,s,C_NULL)
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
end
