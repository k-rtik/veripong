vlib work
vlog -timescale 1ns/1ns ball.v
vsim ball

log {/*}
add wave {/*}

# Repeat Clock
force {clk} 				0 0, 1 1 -repeat 2

# Test One: Resetting
# Test Two: Moving Up and Down
# Test Three: End cases
# Test Four: Combinations of Up and Down
force {reset} 				0 0, 1 10
force {isHittingLeft} 	0 0, 1 50, 0 75
force {isHittingRight} 	0 0, 1 75

run 1400ns