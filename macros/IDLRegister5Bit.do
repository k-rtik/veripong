vlib work
vlog -timescale 1ns/1ns ../ball.v
vsim IDLRegister5Bit

log {/*}
add wave {/*}

# Repeat Clock
force {clk} 				0 0, 1 5 -repeat 10

# Test One: Resetting
# Test Two: Moving Up and Down
# Test Three: End cases
# Test Four: Combinations of Up and Down
force {load} 			0 0, 1 10
force {loadVal}		2#00100 0
force {increment} 	0 0, 1 10
force {decrement} 	0 0

run 400ns