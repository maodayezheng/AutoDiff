# Allocate an empty memory space
function afAlloc{N}(dytpe::Int,s::NTuple{N,Int};release=true)
		pointer = AFPtr[0]
		dims = Clonglong[s...]
		handler(pointer,N,dims,dtype)
		pointer = pointer[1]
		if release
			finalizer(pointer,free)
		end
		return pointer
end

# Allocate memory space with data
function afAlloc{T,N}(data::Array{T,N};release=true)
		pointer = AFPtr[0]
		s = size(data)
		dims = Clonglong[s...]
		dtype = AFTypeCheck(T)	
		create(pointer,data,N,dims,dtype)
		pointer = pointer[1]
		if release
			finalizer(pointer,free)
		end
		return pointer,s,dtype
	end

function free(p::AFPtr)
	@afcheck(:af_release_array,(AFPtr, ),p)
end

function handler(ptr,ndims,dims,dtype)
    @afcheck(:af_create_handle,(Ptr{AFPtr},UInt,Ptr{Clonglong},UInt),ptr,ndims,dims,dtype)
end

function create(ptr,data,ndims,dims,dtype)
	@afcheck(:af_create_array,(Ptr{AFPtr},Ptr{Void},UInt,Ptr{Clonglong},UInt),ptr,data,ndims,dims,dtype)
end

function Base.eltype(p::AFPtr)
	dtype = UInt[0]
	@afcheck(:af_get_type,(Ptr{UInt},Ptr{AFPtr}),dtype,p)
	dtype = dtype[1]
	if dtype == f32 
		 return Float32
  	elseif dtype == c32 
  		 return Complex{Float32}
  	elseif dtype == f64 
  		 return Float64
  	elseif dtype == c64 
  		return Complex{Float64}
  	elseif dtype == b8 
  	    return Bool
  	elseif dtype == s32 
  	    return Int32
  	elseif dtype == u32 
  		return UInt32
    elseif dtype == u8 
    	return UInt8
   	elseif dtype == s64 
   	    return Int64
   	elseif dtype == u64 
   		return UInt64
   	else 
   		throw("Unkonw type read from ArrayFire")
   	end

end

function Base.size(array::AFArray)
		n = Clonglong[0]
		m = Clonglong[0]
		l = Clonglong[0]
		r = Clonglong[0]
		@afcheck(:af_get_dims,(Ptr{Clonglong},Ptr{Clonglong},Ptr{Clonglong},Ptr{Clonglong},Ptr{AFPtr}),n,m,l,r,array.ptr)
		if r[1] > 1
			return (n[1],m[1],l[1],r[1])
		end
		if l[1] > 1
			return (n[1],m[1],l[1])
		end
		if m[1] > 1
			return (n[1],m[1])
		end
		return (n[1], )

end

function to_host(array::AFArray)
	hostArray = Array(eltype(array),size(array))
	@afcheck(:af_get_data_ptr,(Ptr{Void},Ptr{AFPtr}),hostArray,array.ptr)
	return hostArray
end







