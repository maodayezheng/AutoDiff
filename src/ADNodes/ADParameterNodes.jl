# ADParametersNodes pass parameter informations on graph
# indicate differentiable 
type ADDifferentiable{N} <:ADPath
    pointer::AFPtr
    ndims::Int
    size::NTuple{N,Int}
    dtype::Int
    function ADDifferentiable{N}(p::AFPtr,s::NTuple{N,Int},t::Int)
        node = new()
        node.pointer = p
        node.size = s
        node.dtype = t
        node.ndims = N
        return node
    end
end

# indicate none differentiable 
type ADDumb{N} <:ADPath
    pointer::AFPtr
    ndims::Int 
    size::NTuple{N,Int}
    dtype::Int
    function ADDumb{N}(p::AFPtr,s::NTuple{N,Int},t::Int)
        node = new()
        node.pointer = p
        node.size = s
        node.ndims = N
        node.dtype = t
        return node
    end
end

#=
covert non AD parameter to ADParams
inputs: any type of parameter
outputs: a correspond ADnode
error: if no correspond ADnode is available
=#

function ADParameters(parameter)
    if !isa(parameter,ADParams)
        dtype = isa(parameter,Array)? eltype(parameter) : typeof(parameter)
    end
    return parameter
end



