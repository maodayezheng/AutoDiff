function mul(leftOperant::AFPtr,rightOperant::AFPtr,result::AFPtr)
    @afcheck(:af_mul,(Ptr{AFPtr},AFPtr,AFPtr,Cint),result,leftOperant,rightOperant,1)
end

function div(leftOperant::AFPtr,rightOperant::AFPtr,result::AFPtr)
    @afcheck(:af_div,(Ptr{AFPtr},AFPtr,AFPtr,Cint),result,leftOperant,rightOperant,1)
end

function add(leftOperant::AFPtr,rightOperant::AFPtr,result::AFPtr)
    @afcheck(:af_add,(Ptr{AFPtr},AFPtr,AFPtr,Cint),result,leftOperant,rightOperant,1)
end

function sub(leftOperant::AFPtr,rightOperant::AFPtr,result::AFPtr)
    @afcheck(:af_sub,(Ptr{AFPtr},AFPtr,AFPtr,Cint),result,leftOperant,rightOperant,1)
end

function pow(leftOperant::AFPtr,rightOperant::AFPtr,result::AFPtr)
    @afcheck(:af_pow,(Ptr{AFPtr},AFPtr,AFPtr,Cint),result,leftOperant,rightOperant,1)
end

function log(operand::AFPtr,result::AFPtr)
	@afcheck(:af_log,(Ptr{AFPtr},AFPtr),result,operand)
end

function sqrt(operand::AFPtr)
	@afcheck(:af_sqrt,(Ptr{AFPtr},AFPtr),result,operand)
end

function tan(operand::AFPtr)
	@afcheck(:af_tan,(Ptr{AFPtr},AFPtr),result,operand)
end

function sin(operand::AFPtr)
	@afcheck(:af_sin,(Ptr{AFPtr},AFPtr),result,operand)
end

function cos(operand::AFPtr)
	@afcheck(:af_cos,(Ptr{AFPtr},AFPtr),result,operand)
end

function tanh(operand::AFPtr)
	@afcheck(:af_tanh,(Ptr{AFPtr},AFPtr),result,operand)
end

function sinh(operand::AFPtr)
	@afcheck(:af_sinh,(Ptr{AFPtr},AFPtr),result,operand)
end

function cosh(operand::AFPtr)
	@afcheck(:af_cosh,(Ptr{AFPtr},AFPtr),result,operand)
end


