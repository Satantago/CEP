# TAG = sub
	.text
	
	li x5, 5
	li x10 , 4
	li x11 , 9
	sub x31, x5, x10
	sub x31, x11, x10
	
	
	# max_cycle 50
	# pout_start
	# 00000001
	# 00000005
	# pout_end
