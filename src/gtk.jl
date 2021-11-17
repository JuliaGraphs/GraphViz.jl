using Gtk

function gtk_initialize(firstjob::Ptr{Cvoid})
    firstjob = convert(Ptr{GVJ_s},firstjob)
    job = unsafe_load(firstjob)
    c = unsafe_pointer_to_objref(job.context)::Gtk.Canvas
    c.data = firstjob
    job.context = getgc(c).ptr
    job.window = pointer_from_objref(c)
    unsafe_store!(firstjob,job)
    nothing
end

function gtk_finalize(firstjob::Ptr{Cvoid})
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
    ccall(unsafe_load(job.callbacks).refresh,Cvoid,(Ptr{Cvoid},),jobp)
end
const gtk_engine = [ gvdevice_engine_t(@cfunction(gtk_initialize,Cvoid,(Ptr{Cvoid},)),C_NULL,@cfunction(gtk_finalize,Cvoid,(Ptr{Cvoid},))) ]
const gtk_features = [ gvdevice_features_t(Int32(GVDEVICE_EVENTS),0.,0.,0.,0.,96.,96.) ]
const gtk_name = unsafe_wrap(Vector{UInt8}, "julia_gtk:cairo")
const gtk_libname = unsafe_wrap(Vector{UInt8}, "julia_gtk:cairo")
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

add_julia_gtk!(c::Context) = ccall((:gvAddLibrary,gvc),Cvoid,(Ptr{Cvoid},Ptr{gvplugin_library_t}),c.handle,[gvplugin_library_t(pointer(gtk_libname),pointer(gtk_api))])

function render(c::Gtk.Canvas,cg::Context,g::Graph)
    @async begin
        add_julia_gtk!(cg)
        ccall((:gvRenderContext,gvc),Cint,(Ptr{Cvoid},Ptr{Cvoid},Ptr{UInt8},Any),cg.handle,g.handle,"julia_gtk",c)
    end
    nothing
end
