function matmul(leftOperant::AFPtr,rightOperant::AFPtr,result::AFPtr)
	leftOption = 0
	rightOption = 0
    @afcheck(:af_matmul,(Ptr{AFPtr},AFPtr,AFPtr,UInt32,UInt32),result,leftOperant,rightOperant,leftOption,rightOption)
end
