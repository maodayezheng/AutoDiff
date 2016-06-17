type ADAbsNode <: ADFunction
pointer::AFPtr # hold intermediate results (forward) and dervatives (backward)
parents::Array{AFPtr,1} # parent for forward path denpendency 
name :: ASCIIString # name for error handle 
end

function adAbs()


end

function forward(node::ADAbsNode)


end


function backward(node::ADAbsNode)


end
