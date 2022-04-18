# TAG = JALR
	.text
	lui x10 , 1
	addi x10, x10 , 16
	jalr x15, 0(x10) // saute à la ligne 1000 + 16
	li x31 , 15
	li x31 , 9
	# max_cycle 50
	# pout_start
	# 00000009
	# pout_end
