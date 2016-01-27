function ADforward!(net;returnf=false,debug=false,AllocateMemory=false)
#=   calculate the value and auxiliary values of a net function
=#
    # (c) David Barber, University College London 2015
    #=
    if AllocateMemory & net.gpu
        TransformToGPU=true
        net=convert(net,"CPU")
    else
        TransformToGPU=false
    end
    =#

    if debug; println("Get value:"); end

    if isempty(net.auxvalue)
        net.auxvalue=similar(net.value)
    end

    # forward pass:
    for node in net.forwardNodes
        if debug
            println("node $i: $(thisnode.f)($(thisnode.parents))");
        end
        if AllocateMemory
            if debug
                @time net.value[node],net.auxvalue[node]=node.f(net.value[node.parents]...) ## not in place
            else
                n = net.value[node.parents]
                net.value[node],net.auxvalue[node]=node.f(n...) ## not in place
            end
        else
            if debug
                println("in place")
                @time node.f_inplace(net.value[node],net.auxvalue[node],net.value[node.parents]...) ## in place
            else
                node.f_inplace(net.value[node],net.auxvalue[node],net.value[node.parents]...) ## in place
            end
        end
    end

    #=
    if TransformToGPU
        net=convert(net,"GPU")
    end

    if returnf
        if net.gpu
            return to_host(net.value[net.FunctionNode])[1]
        else
            return net.value[net.FunctionNode][1]
        end
#        @gpu if net.gru
#        @cpu return net.value[net.FunctionNode][1]
    end

    if debug; println("done"); end
    =#
end

