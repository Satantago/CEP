# TAG = sb
	.text
	
	.data
var:	.byte 0x19
	.text
	la x30, var
	li x15 , 6
	sb x15, 0(x30)
	lw x31, 0(x30)
	
	# max_cycle 50
	# pout_start
	# 00000006
	# pout_end
