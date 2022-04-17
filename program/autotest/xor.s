# TAG = xor
	.text
	
	li x7, 2
	xor x31, x7, x7
	
	li x10, 44
	li x11, 46
	xor x31, x11, x10
	
	
	# max_cycle 50
	# pout_start
	# 00000000
	# 00000002
	# pout_end
