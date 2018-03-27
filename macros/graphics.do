vlib work
vlog -timescale 1ns/1ns ../graphics.v
vsim graphics

log {/*}
add wave {/*}

# Repeat Clock
force {clk} 					0 0, 1 1 -repeat 2
force {reset} 				0 0, 1 1

run 100