# TAG = srai
	.text
	li x16 , 0x60
	srai x31 , x16 , 4
	li x15 , 0x7000
	srai x31 , x15 , 5
	
	# max_cycle 50
	# pout_start
	# 00000006
	# 00000380
	# pout_end
