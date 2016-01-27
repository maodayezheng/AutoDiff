# (c) David Barber, University College London 2015
#=From the README the main perporse of compile is to allocate memory
  For GPU or CPU operation
=#

function compile(net;backend="CPU",debug=false)

    

    if backend == "CPU"

        forward = net.forwardNodes
        # TODO: for loop below can be saved, as filter() ADforward() also iterates 
        # through all node
        net.forwardNodes = filter(x->(isa(x,ADFunction)),forward)
        ADforward!(net;debug=false,AllocateMemory=true)
        #Allocate graidents
        iter = length(net.value)
        net.gradient[iter] = cArray(false,Float64,size(net.value[iter]))
            for i = 1:iter-1
            net.gradient[i]=cArray(false,Float64,size(net.value[i]))
            end

    elseif backend == "GPU"
         forward = net.forwardNodes
        # TODO: for loop below can be saved, as filter() ADforward() also iterates 
        # through all node
        net.forwardNodes = filter(x->(isa(x,ADFunction)),forward)
        ADforward!(net;debug=false,AllocateMemory=true)

        iter = length(net.value)
        s = size(net.value[iter])
        net.gradient[iter] = cArray(true,ones(s))
        net.value[iter] = cArray(true,net.value[iter])

        for i=1:iter-1
        s = size(net.value[i])
        net.gradient[i] = cArray(true,zeros(s))
        net.value[i] = cArray(true,net.value[i])
        end

    else
    throw("backend type must be GPU or CPU")
    end










    # It's good to ensure that we only compuile on the CPU since then we don't need to write inplace versions of the GPU functions (we only need the inplace versions of the GPU derivatives. This makes coding a bit easier)
#=
    if debug
        println("Compiling into a tree and storing messages:")
    end
    node=net.node
    N=length(node)
    
    # get the computation tree:
    G=zeros(Bool,N,N)
    returnderivative=zeros(Bool,N)
    # check whether need to be derive 
    # achieved in ADFunction
    for i in net.validnodes
        if !(node[i]==nothing)
            node[i].children=setdiff(find(G[:,i]),node[i].index)
        end
    end

    # forward pass: assume the nodes are defined in ancestral order
    if debug;  println("Forward Pass compilation:");  end

    for n in net.validnodes
        if node[n].isconst==true
            if typeof(node[n].constval)==Float64
                net.value[n]=cArray(gpu,node[n].constval*ones(1,1))
            else
                net.value[n]=cArray(gpu,node[n].constval)
            end
        end
    end

    ForwardPassList!(net) # call this as ForwardPassList(net;ExcludeNodes=[1 2 3 ....]) if there are nodes 1 2 3 ... that are not needed to be calculated in the forward pass

    value=net.value
    gradient=net.gradient
    auxvalue=similar(value)
    net.auxvalue=auxvalue
    net.value=value
    net.gradient=gradient
    net.gpu=gpu



    if debug;  println("Done forward pass compilation:");  end

    # backward compilation:
    if debug;  println("Backward Pass compilation:");  end

    gradient=Array(Any,N)

    for i in net.validnodes
        gradient[i]=cArray(gpu,Float64,size(value[i]))
    end
    fill!(gradient[net.FunctionNode],1.0)

    Nend=net.FunctionNode
    if Nend!=N
        anc=ancestors(node,Nend)
    else
        anc=flipdim(net.validnodes,1); anc=anc[2:end]
    end

    relevantchildren=Array(Any,N)
    ancUnionNend=union(anc,Nend)
    for n in anc
       relevantchildren[n]=intersect(node[n].children,ancUnionNend)
    end

    parentIDX=Dict()
    for c in net.validnodes
        for n in unique(node[c].parents)
            inds=findin(node[c].parents,n)
            parentIDX[c,n]=inds
        end
    end

    net.ancestors=anc
    net.relevantchildren=relevantchildren
    net.gradient=gradient
    net.parentIDX=parentIDX

    if debug
        println("Compiled into a DAG with $(length(node)) nodes")
    end
=#
    return net

end

