# TAG = BGEU
	.text
	
	li x10 , 15
	li x11 , 15
	bgeu x10, x11 , fin
	fin :
	     li x31, 4
	
	li x20 , 20

	bgeu x20, x10 , fine
	fine :
	     li x31, 5
	
	# max_cycle 50
	# pout_start
	# 00000004
	# 00000005
	# pout_end
