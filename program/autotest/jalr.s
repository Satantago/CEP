# TAG = JALR
	.text
	li x10 , 0x100C
	jalr x31, 0(x10)
	li x31, 8
	li x31 , 9
	# max_cycle 50
	# pout_start
	# 00000009
	# pout_end
