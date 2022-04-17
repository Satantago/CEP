# TAG = bltu
	.text
	
	li x10 , 15
	li x11 , 15
	bltu x10, x11 , fin
	fin :
	     li x31, 4
	
	li x20 , 20

	bltu x10, x20 , fine
	fine :
	     li x31, 5
	
	# max_cycle 50
	# pout_start
	# 00000004
	# 00000005
	# pout_end
