type ADTanNode <: ADFunction
pointer::AFPtr # hold intermediate results (forward) and dervatives (backward)
parents::Array{AFPtr,1} # parent for forward path denpendency 
children::Array{AFPtr,1} # children for backward path denpendency
name :: ASCIIString # name for error handle  
end

function forward(node::ADTanNode)


end

function backward(node::ADTanNode)


end