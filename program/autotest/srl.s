# TAG = srl
	.text
	
	li x15,  0x600
	li x16 , 5
	srl x31 , x15 , x16
	li x31, x15 , 37
	srl x31 , x15 , x17
	
	# max_cycle 50
	# pout_start
	# 00000030
	# 00000030
	# pout_end
