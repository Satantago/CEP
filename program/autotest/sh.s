# TAG = sh
	.text
	
	.data
var:	.short 0x5125
	.text
	la x30, var
	li x15 , 6
	sw x15, 0(x30)
	lw x31, 0(x30)
	
	# max_cycle 50
	# pout_start
	# 00000006
	# pout_end
