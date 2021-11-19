# Cairo device

using .Cairo

function cairo_initialize(firstjob::Ptr{Cvoid})
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

function cairo_finalize(firstjob::Ptr{Cvoid})
    #=firstjob = convert(Ptr{GVJ_s},firstjob)
    job = unsafe_load(firstjob)
    if last_surface == firstjob
        surface = ccall((:cairo_get_target,Cairo._jl_libcairo),Ptr{Cvoid},(Ptr{Cvoid},),job.context)
        last_surface = CairoSurface(surface, job.width, job.height)
    end=#
    nothing
end

function cairo_format(firstjob::Ptr{Cvoid})
    global last_surface
    firstjob = convert(Ptr{GVJ_s},firstjob)
    job = unsafe_load(firstjob)
    if last_surface == firstjob
        surface = ccall((:cairo_get_target,Cairo.libcairo),Ptr{Cvoid},(Ptr{Cvoid},),job.context)
        last_surface = CairoSurface(surface, job.width, job.height)
    end
    nothing
end

const julia_cairo_engine = Ref{gvdevice_engine_t}()
const julia_cairo_features = Ref{gvdevice_features_t}(gvdevice_features_t(Int32(0),0.,0.,0.,0.,96.,96.))
const julia_cairo_name = Vector{UInt8}("julia:cairo")
const julia_cairo_libname = Vector{UInt8}("julia:cairo")
const julia_cairo_device = Ref{NTuple{2, gvplugin_installed_t}}()
const julia_cairo_api = Ref{NTuple{2, gvplugin_api_t}}()

function init_cairo_structs!()
    julia_cairo_engine[] = gvdevice_engine_t(@cfunction(cairo_initialize,Cvoid,(Ptr{Cvoid},)),@cfunction(cairo_format,Cvoid,(Ptr{Cvoid},)),@cfunction(cairo_finalize,Cvoid,(Ptr{Cvoid},)))
    julia_cairo_device[] = (
        gvplugin_installed_t(Int32(0),pointer(julia_cairo_name), Int32(0), unsafe_convert(Ptr{gvdevice_engine_t}, julia_cairo_engine), unsafe_convert(Ptr{gvdevice_features_t}, julia_cairo_features)),
        null(gvplugin_installed_t)
    )
    julia_cairo_api[] = (gvplugin_api_t(API_device, unsafe_convert(Ptr{gvplugin_installed_t}, julia_cairo_device)),
        null(gvplugin_api_t))
end

function add_julia_cairo!(c::Context)
    lib = Ref{gvplugin_library_t}(gvplugin_library_t(
        pointer(julia_cairo_libname),unsafe_convert(Ptr{gvplugin_api_t}, julia_cairo_api)))
    ccall((:gvAddLibrary,libgvc),Cvoid,(Ptr{Cvoid},Ptr{gvplugin_library_t}),c.handle,lib)
end

function __init__cairo__(c::Context)
    init_cairo_structs!()
    add_julia_cairo!(c)
end

function render(c::CairoContext,g::GraphViz.Graph; context = default_context[], format="julia:cairo")
    GraphViz.add_julia_cairo!(context)
    if !g.didlayout
        error("Must call layout before calling render!")
    end
    ccall((:gvRenderContext,libgvc),Cint,(Ptr{Cvoid},Ptr{Cvoid},Ptr{UInt8},Any),context.handle,g.handle,format,c)
end

function cairo_render(g::GraphViz.Graph; context = default_context[], format="julia:cairo")
    global last_surface
    GraphViz.add_julia_cairo!(context)
    if !g.didlayout
        error("Must call layout before calling render!")
    end
    ccall((:gvRenderContext,libgvc),Cint,(Ptr{Cvoid},Ptr{Cvoid},Ptr{UInt8},Ptr{Cvoid}),context.handle,g.handle,format,C_NULL)
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
