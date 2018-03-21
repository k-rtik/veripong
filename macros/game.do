vlib work
vlog -timescale 1ms/1ms ../game.v
vsim game

log {/*}
add wave {/*}

# Repeat Clock
force {clk} 					0 0, 1 8333 -repeat 16666
force {reset} 					0 0, 1 10
force {leftPaddleUp}			0 0
force {leftPaddleDown} 		0 0, 1 16666, 0 49999
force {rightPaddleUp}		0 0
force {rightPaddleDown}		0 0
force {isPvP}					0 0

run 999970