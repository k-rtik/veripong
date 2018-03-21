vlib work
vlog -timescale 1ns/1ns ball.v
vsim ball

log {/*}
add wave {/*}

# Repeat Clock
force {clk} 				0 0, 1 5 -repeat 10

# Test One: Resetting
# Test Two: Moving Up and Down
# Test Three: End cases
# Test Four: Combinations of Up and Down
force {reset} 				0 0, 1 10
force {isHittingLeft} 	0 0
force {isHittingRight} 	0 0

run 400ns