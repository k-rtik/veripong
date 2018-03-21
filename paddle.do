vlib work
vlog -timescale 1ns/1ns paddle.v
vsim paddle

log {/*}
add wave {/*}

# Repeat Clock
force {clk} 		0 0, 1 5 -repeat 10

# Test One: Resetting
# Test Two: Moving Up and Down
# Test Three: End cases
# Test Four: Combinations of Up and Down
force {reset} 		0 0, 1 10
force {moveUp} 	0 0, 1 10, 0 130
force {moveDown} 	0 0, 1 140, 0 400

run 400ns