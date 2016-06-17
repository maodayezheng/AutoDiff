# Lists of avaliable functions
# Binary functions take two inputs argument
const binaryFunctions 




#= 
Check whether a function is differentiable 
and accumulate the computational graph 
Inputs:
node => function node
operand => input arguments of function
Return:
true =>  differentiable
false => not differentiable 
=#

function adfunction(node,operands)
        operands = collect(operands)
        # check forawrd path parent
        parents = map(n->n.poniter,operands) 
        node.parents = parents
        push!(forwardNodes,node) # forward pass extension 
        # check backward path children 
        children = map(n->(isa(n,ADDifferentiable)? n.pointer:nothing))
        differentiable = isempty(filter(n->!(n==nothing),children))
        # set up function 
        if !isempty(differentiable)
            node.children = children
            unshift!(backwardNodes,node) #backward path extension
            return true
        return false
end

