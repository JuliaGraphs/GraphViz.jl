# Plugin Struct
struct gvdevice_engine_t
    initialize::Ptr{Cvoid}
    format::Ptr{Cvoid}
    finalize::Ptr{Cvoid}
end

struct Pointf
    x::Float64
    y::Float64
end

struct gvdevice_features_t
    flags::Cint
    default_margin_x::Float64
    default_margin_y::Float64
    default_pagesize_x::Float64
    default_pagesize_y::Float64
    default_dpi_x::Float64
    default_dpi_y::Float64
end

struct gvplugin_installed_t
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


struct gvplugin_api_t
    api::Cint
    types::Ptr{gvplugin_installed_t}
end

struct gvplugin_library_t
    name::Ptr{UInt8}
    apis::Ptr{gvplugin_api_t}
end

# Job Struct

struct gvplugin_active_device_t
    engine::Ptr{gvdevice_engine_t}
    id::Cint
    features::Ptr{gvdevice_features_t}
    ctype::Ptr{UInt8}
end

struct gvplugin_active_render_t
    engine::Ptr{Cvoid}
    id::Cint
    features::Ptr{Cvoid}
    ctype::Ptr{UInt8}
end

struct gvplugin_active_loadimage_t
    engine::Ptr{Cvoid}
    id::Cint
    ctype::Ptr{UInt8}
end

struct gv_argvlist_t
    argv::Ptr{Ptr{UInt8}}
    argc::Cint;
    alloc::Cint;
end

struct Point{T}
    x::T
    y::T
end

struct Box{T}
    topleft::Point{T}
    bottomright::Point{T}
end

struct gvdevice_callback_t
    refresh::Ptr{Cvoid}          # void (*refresh) (GVJ_t * job);
    button_press::Ptr{Cvoid}     # void (*button_press) (GVJ_t * job, int button, pointf pointer);
    button_release::Ptr{Cvoid}   # void (*button_release) (GVJ_t * job, int button, pointf pointer);
    motion::Ptr{Cvoid}           # void (*motion) (GVJ_t * job, pointf pointer);
    modify::Ptr{Cvoid}           # void (*modify) (GVJ_t * job, const char *name, const char *value);
    del::Ptr{Cvoid}              # void (*del) (GVJ_t * job);  /* can't use "delete" 'cos C++ stole it */
    read::Ptr{Cvoid}             # void (*read) (GVJ_t * job, const char *filename, const char *layout);
    layout::Ptr{Cvoid}           # void (*layout) (GVJ_t * job, const char *layout);
    render::Ptr{Cvoid}           # void (*render) (GVJ_t * job, const char *format, const char *filename);
end

# TODO: These are probably wrong
mutable struct GVCOMMON_s
    info::Ptr{Ptr{UInt8}}
    cmdname::Ptr{UInt8}
    verbose::Cint
    config::UInt8
    auto_outfile_names::UInt8
    errorfn::Ptr{Cvoid}
    show_boxes::Ptr{Ptr{Cvoid}}
    lib::Ptr{Ptr{Cvoid}}
    viewNum::Cint
    builtins::Ptr{Cvoid}
    demand_loading::Cint
end

mutable struct GVC_s
    common::GVCOMMON_s

    config_path::Ptr{UInt8}
    config_found::UInt8

    input_filenames::Ptr{Ptr{UInt8}}

    gvgs::Ptr{Cvoid}
    gvg::Ptr{Cvoid}

    # Hack until tuples are properly inlined into types
    apis0::Ptr{Cvoid}
    apis1::Ptr{Cvoid}
    apis2::Ptr{Cvoid}
    apis3::Ptr{Cvoid}
    apis4::Ptr{Cvoid}
    api0::Ptr{Cvoid}
    api1::Ptr{Cvoid}
    api2::Ptr{Cvoid}
    api3::Ptr{Cvoid}
    api4::Ptr{Cvoid}
    packages::Ptr{Cvoid}

    #  size_t (*write_fn) (GVJ_t *job, const char *s, size_t len);
    write_fn::Ptr{Cvoid}

    # More stuff I don't need right now
end

mutable struct GVJ_s
    gvc::Ptr{GVC_s}
    next::Ptr{GVJ_s}
    next_active::Ptr{GVJ_s}

    common::Ptr{Cvoid}

    obj_state::Ptr{Cvoid}
    input_filename::Ptr{UInt8}
    graph_index::Cint

    layout_type::Ptr{UInt8}

    output_filename::Ptr{UInt8}
    output_file::Ptr{Cvoid}
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

    displat::Ptr{Cvoid}
    screen::Cint

    context::Ptr{Cvoid}
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

    current_obj::Ptr{Cvoid}
    selected_obj::Ptr{Cvoid}

    active_tooltip::Ptr{UInt8}
    selected_href::Ptr{UInt8}

    selected_obj_type_name::gv_argvlist_t
    selected_obj_attributes::gv_argvlist_t

    window::Ptr{Cvoid}

    keybindings::Ptr{Cvoid}
    numkeys::Cint
    keycodes::Ptr{Cvoid}
end

# Disciplines


struct Agmemdisc_s
    #void *(*open) (Agdisc_t*);  /* independent of other resources */
    open::Ptr{Cvoid}
    #void *(*alloc) (void *state, size_t req);
    alloc::Ptr{Cvoid}
    #void *(*resize) (void *state, void *ptr, size_t old, size_t req);
    resize::Ptr{Cvoid}
    # void (*free) (void *state, void *ptr);
    free::Ptr{Cvoid}
    # void (*close) (void *state);
    close::Ptr{Cvoid}
end

struct Agiddisc_s
    # void *(*open) (Agraph_t * g, Agdisc_t*);    /* associated with a graph */
    open::Ptr{Cvoid}
    # long (*map) (void *state, int objtype, char *str, unsigned long *id, int createflag);
    map::Ptr{Cvoid}
    # long (*alloc) (void *state, int objtype, unsigned long id);
    alloc::Ptr{Cvoid}
    #void (*free) (void *state, int objtype, unsigned long id);
    free::Ptr{Cvoid}
    #char *(*print) (void *state, int objtype, unsigned long id);
    print::Ptr{Cvoid}
    #void (*close) (void *state);
    close::Ptr{Cvoid}
    #void (*idregister) (void *state, int objtype, void *obj);
    idregister::Ptr{Cvoid}
end

struct Agiodisc_s
    # int (*afread) (void *chan, char *buf, int bufsize);
    afread::Ptr{Cvoid}
    # int (*putstr) (void *chan, const char *str);
    putstr::Ptr{Cvoid}
    # int (*flush) (void *chan);  /* sync */
    flush::Ptr{Cvoid}
end

struct Agdisc_s
    mem::Ptr{Agmemdisc_s}
    id::Ptr{Agiddisc_s}
    io::Ptr{Agiodisc_s}
end
