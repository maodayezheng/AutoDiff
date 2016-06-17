module AutoDiff
# (c) David Barber, University College London 2015
push!(LOAD_PATH,pwd())
#push!(LOAD_PATH, joinpath(pwd(), "src"))

# push all subdirectories from src
#map(d -> push!(LOAD_PATH, joinpath(pwd(), "src", d)),
#    filter(d -> isdir(joinpath("src", d)), readdir("src")))#
#
#push!(LOAD_PATH, joinpath(pwd(), "Demos"))

include("gpumacros.jl")
#export @gpu, @cpu

include("initfile.jl")
include("GPUWrappers/ArrayFire/ArrayFire.jl")
@cpu println("Using CPU")
#@gpu println("Compiling kernels...")
#@gpu include("compile_kernels.jl")
@gpu println("Using GPU")

@gpu (using CUDArt; println("using CUDArt"))
@gpu (using CUBLAS; println("using CUBLAS"))

@gpu (import CUDArt.to_host; to_host(A::Array)=A; export to_host;) # CHECKTHIS
@cpu (to_host(A::Array)=A; export to_host;) # CHECKTHIS

using Reexport
@gpu (@reexport using CUDArt;println("reexport using CUDArt"))

abstract ADnode # parent of all AD type
abstract ADParams <:ADnode # parent of ADEntry,ADDifferentiable and ADDumb
abstract ADEntry <: ADParams # Parent of ADVariable and ADConstant
abstract ADPath <: ADParams # Parent of ADDifferentiable and ADDumb
abstract ADFunction <: ADnode # parent of functions

# entry of variable 
function variable{T,N}(::Type{T},s::NTuple{N,Int};update=true)
    dtype = afTypeCheck(T)
    pointer = afAlloc(T,s)
    if update
        return ADDifferentiable(pointer,s,dtype)
    else 
        return ADDumb(pointer,s,dtype)
    end
end


function variable{T,N}(v::Array{T,N};update=true)
        pointer,s,dtype = afAlloc(v)
    if update 
        return ADDifferentiable(pointer,s,dtype)
    else
        return ADDumb(pointer,s,dtype)
    end
end

# entry of constant
function constant{T,N}(::Type{T},s::NTuple{N,Int})
    return variable(T,s;update=false)
end

function constant{T,N}(v::Array{T,N})
    return variable(v;update=false)
end

global GPU

@gpu ArrayOrCudaArray = Union{Array,CudaArray}
@cpu ArrayOrCudaArray = Array



function EndCode()
    return network()
end
export EndCode

export NodeCounter

function Node()
    global node
    node
end
export Node


type ADnode
    index #node index
    parents # node parent indices
    f::Function   # function that the node computes
    f_inplace::Function   # in place version of function
    df::Function  # derivative function
    children::Array{Int,1} # node child indices
    takederivative # whether to take the derivative
    returnderivative::Bool # whether to return the derivative
#    input::Bool # whether this is an input variable
    isconst::Bool
    constval
   #ADnode(f=nx,parents=[];returnderivative=false,isconst=false,constval=nothing)=
       ADnode(f=nx,parents=[];returnderivative=false,isconst=false,constval=nothing)=
        begin
            global nodecounter+=1
            global node
            #if f==nx
            #    input=true
            #else
            #    input=false
            #end
            returnderivative=returnderivative==true
            takederivative=returnderivative
#            if returnderivative & !input
#                error("cannot return derivative for a node that has parents")
#            end
            if isa(parents,Array{ADnode})
                parents=map(n->n.index,parents)
            end
            if isa(parents,ADnode)
                parents=parents.index
            end
            thisnode=new(nodecounter,collect(parents),f,Inplace[f],Derivative[f],[0],takederivative,returnderivative,isconst,constval)
            if isempty(node)
                node=Array(Any,0)
            end
            push!(node,thisnode)
            return thisnode
        end
end


abstract ADdummy

type ADtrans<: ADdummy # transpose node. Dummy node that can be used for code optimisation
    index # node index
    parent # node parent index
#    input::Bool # we set this to true since this prevents dummy nodes being differentiated
    ADtrans(parentnode)=
        begin
            global nodecounter+=1
            global node
            if isa(parentnode,ADnode)
                parent=parentnode.index
            end
            #thisnode=new(nodecounter,parent,true)
            thisnode=new(nodecounter,parent)
            if isempty(node)
                node=Array(Any,0)
            end
            push!(node,thisnode)
            return thisnode
        end
end
export ADtrans



type ADdiag<:ADdummy# Dummy diag node that can be used for code optimisation
    index # node index
    parent # node parent index
#    input::Bool # we set this to true since this prevents dummy nodes being differentiated
    ADdiag(parentnode)=
        begin
            global nodecounter+=1
            global node
            if isa(parentnode,ADnode)
                parent=parentnode.index
            end
            #thisnode=new(nodecounter,parent,true)
            thisnode=new(nodecounter,parent)
            if isempty(node)
                node=Array(Any,0)
            end
            push!(node,thisnode)
            return thisnode
        end
end
export ADdiag




ArrayADnode=Array{ADnode}
ADnodeOrArrayADnode=Union{ADnode,Array{ADnode}}
export ADnodeOrArrayADnode, ArrayADnode

import Base.getindex
getindex(x::Array,A::ADnode)=getindex(x,A.index)
export getindex

import Base.setindex!
setindex!(x::Array,value,A::ADnode)=setindex!(x,value,A.index)
export setindex!

function setindex!(x::Array,value::Float64,A::ADnode)
    tmp=cArray((1,1))
    fill!(tmp,value)
    setindex!(x,tmp,A.index)
end
export setindex!


type network
    #node::Array{ADnode,1}
    node::Array{Any,1}
    FunctionNode::Int # Node that forms the scalar function (by default the last node in the graph)
    value
    auxvalue
    gradient
    validnodes
    ancestors
    relevantchildren
    ForwardPassList
    parentIDX
    gpu::Bool
    eltype # Float32 or Float64

   function network()
    vn=find(map((x)->( x!=nothing && !isa(x,ADdummy))  ,Node()))
        return new(Node(),NodeCounter(),Array(Any,NodeCounter()),Array(Any,NodeCounter()),Array(Any,NodeCounter()),vn,nothing,nothing,nothing,nothing,PROC=="GPU",Float64)
    end

    function network(node)
        vn=find(map((x)->( x!=nothing && !isa(x,ADdummy))  ,Node()))
        return new(node,NodeCounter(),Array(Any,NodeCounter()),Array(Any,NodeCounter()),Array(Any,NodeCounter()),vn,nothing,nothing,nothing,nothing,PROC=="GPU",Float64)
    end

    function network(node,FunctionNode,value,auxvalue,gradient,anc,relevantchildren,forwardlist=nothing)
    vn=find(map((x)->( x!=nothing && !isa(x,ADdummy))  ,Node()))
        return new(node,NodeCounter(),value,auxvalue,gradient,vn,anc,relevantchildren,forwardlist,nothing,PROC=="GPU",Float64)
    end

end


include("utils.jl")
include("CUDAutils.jl")

include("defs.jl")
include("compile.jl")

include("ADforward!.jl")
include("ADbackward!.jl")

include("gradcheckGPU.jl"); export gradcheckGPU
include("gradcheckCPU.jl"); export gradcheckCPU

include("netutils.jl")

function gradcheck(net;showgrad=false)
    if net.gpu
        gradcheckGPU(net;showgrad=showgrad)
    else
        gradcheckCPU(net;showgrad=showgrad)
    end
end
export gradcheck

export matread, jldopen, matopen
export ADnode, network, compile
export ADforward!, ADbackward!
export gradcheck
export ArrayOrCudaArray


#ADvariable(;returnderivative=true)=ADnode(;returnderivative=returnderivative)
ADvariable(;returnderivative=true)=ADnode(;returnderivative=returnderivative)
export ADvariable

# make the following form an array if constval is a scalar:
ADconst(constval)=ADnode(;returnderivative=false,isconst=true,constval=Float64(constval))
ADint(constval)=ADnode(;returnderivative=false,isconst=true,constval=Int(constval))
export ADconst
export ADint

#export @gpu, @cpu

end


#function MapReduce(f,op,node::Array{ADnode,1})
#    # f is the function mapped onto each node
#    # op is the binary reduction
#    f(node[1])
#    for i=2:length(node)
#        oldcounter=NodeCounter()
#        f(node[i])
#        op(oldcounter, NodeCounter())
#    end
#    return Node()[end]
#end
#export MapReduce

#function endnode(node)
#    d=falses(length(node))
#    for i=1:length(d)
#        d[i]=isdefined(node,i);
#    end
#    return last(find(d))
#end
#export endnode

# Source code generation:
#include("genFcode.jl")
#include("genRcode.jl")
#export genFcode, genRcode
