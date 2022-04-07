# TAG = sw
	.text
	
	lui x15 , 1
	lui x10 , 5
	sw x10, 0(x15)
	lw x31 , 0(x15)
	
	
	
	# max_cycle 50
	# pout_start
	# 000017B7
	# pout_end
