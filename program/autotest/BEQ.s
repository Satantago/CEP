# TAG = BEQ
	.text
	
	li x10 , 15
	li x11 , 15
	beq x10, x11 , fin
	fin :
	     li x31, 4
	
	
	# max_cycle 50
	# pout_start
	# 00000004
	# pout_end
