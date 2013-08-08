module GraphViz
    using BinDeps
    @BinDeps.load_dependencies

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
        ctype::Ptr{Uint8}
        quality::Cint
        engine::Ptr{gvdevice_engine_t}
        features::Ptr{gvdevice_features_t}
    end

    const API_render        = int32(0)
    const API_layout        = int32(1)
    const API_textlayout    = int32(2)
    const API_device        = int32(3)
    const API_loadimage     = int32(4)

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
        name::Ptr{Uint8}
        apis::Ptr{gvplugin_api_t}
    end

    # Job Struct

    immutable gvplugin_active_device_t
        engine::Ptr{gvdevice_engine_t}
        id::Cint
        features::Ptr{gvdevice_features_t}
        ctype::Ptr{Uint8}
    end

    immutable gvplugin_active_render_t
        engine::Ptr{Void}
        id::Cint
        features::Ptr{Void}
        ctype::Ptr{Uint8}
    end

    immutable gvplugin_active_loadimage_t
        engine::Ptr{Void}
        id::Cint
        ctype::Ptr{Uint8}
    end

    immutable gv_argvlist_t
        argv::Ptr{Ptr{Uint8}}
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

    type GVJ_s
        gvc::Ptr{Void}
        next::Ptr{GVJ_s}
        next_active::Ptr{GVJ_s}

        common::Ptr{Void}

        obj_state::Ptr{Void}
        input_filename::Ptr{Uint8}
        graph_index::Cint

        layout_type::Ptr{Uint8}

        output_filename::Ptr{Uint8}
        output_file::Ptr{Void}
        output_data::Ptr{Uint8}
        output_data_allocated::Cuint
        output_data_position::Cuint

        output_langname::Ptr{Uint8}
        output_lang::Ptr{Cint}

        render::gvplugin_active_render_t
        device::gvplugin_active_device_t
        loadimage::gvplugin_active_loadimage_t

        callbacks::Ptr{gvdevice_callback_t}

        device_dpi::Pointf
        device_sets_dpi::Uint8

        displat::Ptr{Void}
        screen::Cint

        context::Ptr{Void}
        external_context::Uint8

        imagedata::Ptr{Uint8}

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

        width::Uint32
        height::Uint32

        pageBoundingBox::Box{Int32}
        boundingBox::Box{Int32}

        scale::Point{Float64}
        translation::Point{Float64}
        devscale::Point{Float64}

        fit_mode::Uint8
        needs_refresh::Uint8
        click::Uint8
        has_grown::Uint8
        has_been_rendered::Uint8

        button::Uint8
        pointer::Point{Float64}
        oldpointer::Point{Float64}

        current_obj::Ptr{Void}
        selected_obj::Ptr{Void}

        active_tooltip::Ptr{Uint8}
        selected_href::Ptr{Uint8}

        selected_obj_type_name::gv_argvlist_t
        selected_obj_attributes::gv_argvlist_t

        window::Ptr{Void}

        keybindings::Ptr{Void}
        numkeys::Cint
        keycodes::Ptr{Void}
    end

    null(::Type{gvplugin_installed_t}) = gvplugin_installed_t(int32(0),pointer(Uint8,unsigned(0)),
        int32(0),pointer(gvdevice_engine_t,unsigned(0)),pointer(gvdevice_features_t,unsigned(0)))
    null(::Type{gvplugin_api_t}) = gvplugin_api_t(int32(0),pointer(gvplugin_installed_t,unsigned(0)))

    # Initialization

    function init()
        ccall((:aginit,cgraph),Void,())
    end

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

    type Graph
        handle::Ptr{Void}
        function Graph(p::Ptr{Void})
            this = new(p)
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

    Graph(graph::Vector{Uint8}) = Graph(ccall((:agmemread,cgraph),Ptr{Void},(Ptr{Uint8},),graph))
    Graph(graph::String) = Graph(bytestring(graph).data)

    layout!(c::Context,g::Graph,engine) = ccall((:gvLayout,gvc),Cint,(Ptr{Void},Ptr{Void},Ptr{Uint8}),c.handle,g.handle,engine)

    render_x11(c::Context,g::Graph) = ccall((:gvRender,gvc),Cint,(Ptr{Void},Ptr{Void},Ptr{Uint8},Ptr{Void}),c.handle,g.handle,"x11",C_NULL)
    render_jobs(c::Context,g::Graph) = ccall((:gvRenderJobs,gvc),Cint,(Ptr{Void},Ptr{Void}),c.handle,g.handle)

    # Render

    if isdir(Pkg2.dir("Cairo"))
        using Cairo

        function cairo_initialize(firstjob::Ptr{Void})
            firstjob = convert(Ptr{GVJ_s},firstjob)
            job = unsafe_load(firstjob)
            c = unsafe_pointer_to_objref(job.context)::CairoContext
            job.context = c.ptr
            job.width = width(c.surface)
            job.height = height(c.surface)
            unsafe_store!(firstjob,job)
            job = unsafe_load(firstjob)
            nothing
        end
        cairo_finalize(firstjob::Ptr{Void}) = nothing

        const generic_cairo_engine = [ gvdevice_engine_t(cfunction(cairo_initialize,Void,(Ptr{Void},)),C_NULL,cfunction(cairo_finalize,Void,(Ptr{Void},))) ]
        const generic_cairo_features = [ gvdevice_features_t(int32(GVDEVICE_EVENTS),0.,0.,0.,0.,96.,96.) ]
        const generic_cairo_features_interactive = [ gvdevice_features_t(int32(GVDEVICE_EVENTS),0.,0.,0.,0.,96.,96.) ]
        const generic_cairo_name = "julia:cairo".data
        const generic_cairo_libname = "julia_cairo".data 
        const generic_cairo_device = 
        [ 
          gvplugin_installed_t(int32(0),pointer(generic_cairo_name), int32(0), pointer(generic_cairo_engine), pointer(generic_cairo_features));
          null(gvplugin_installed_t)
        ]
        const generic_cairo_api = 
        [
            gvplugin_api_t(API_device, pointer(generic_cairo_device))
            null(gvplugin_api_t)
        ]

        add_julia_cairo!(c::Context) = ccall((:gvAddLibrary,gvc),Void,(Ptr{Void},Ptr{gvplugin_library_t}),c.handle,[gvplugin_library_t(pointer(generic_cairo_libname),pointer(generic_cairo_api))])

        render(c::CairoContext,cg::Context,g::Graph,format="julia:cairo") = ccall((:gvRenderContext,gvc),Cint,(Ptr{Void},Ptr{Void},Ptr{Uint8},Any),cg.handle,g.handle,format,c)
    
        if isdir(Pkg2.dir("Gtk"))
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
            const gtk_features = [ gvdevice_features_t(int32(GVDEVICE_EVENTS),0.,0.,0.,0.,96.,96.) ]
            const gtk_name = "julia_gtk:cairo".data
            const gtk_libname = "julia_gtk:cairo".data 
            const gtk_device = 
            [ 
              gvplugin_installed_t(int32(0),pointer(gtk_name), int32(0), pointer(gtk_engine), pointer(gtk_features));
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
                    ccall((:gvRenderContext,gvc),Cint,(Ptr{Void},Ptr{Void},Ptr{Uint8},Any),cg.handle,g.handle,"julia_gtk",c)    
                end
                nothing
            end     
        end
    end

    graph_plugins(c::Context) = Graph(ccall((:gvPluginsGraph,gvc),Ptr{Void},(Ptr{Void},),c.handle))

    function listPlugins(c,kind)
        s = Array(Cint,1)
        r = ccall((:gvPluginList,gvc),Ptr{Ptr{Uint8}},(Ptr{Void},Ptr{Uint8},Ptr{Cint},Ptr{Uint8}),c.handle,kind,s,C_NULL)
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

GraphViz.init()