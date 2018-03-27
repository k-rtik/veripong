vlib work
vlog -timescale 1ns/1ns ../game.v
vsim game

log {/*}
add wave {/*}

# Repeat Clock
force {clk} 					0 0, 1 10 -repeat 20
force {reset} 					0 0, 1 10
force {leftPaddleUp}			0 0
force {leftPaddleDown} 		0 0, 1 10
force {rightPaddleUp}		0 0
force {rightPaddleDown}		0 0
force {isPvP}					0 0

run 200