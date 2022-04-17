# TAG = and
	.text
	
	li x10, 30
	li x11, 40
	li x12, 25
	and x31, x10, x11
	and x31, x10, x12
	and x31, x11, x12
	
	
	
	# max_cycle 50
	# pout_start
	# 00000008
	# 00000018
	# 00000008
	# pout_end
	 
