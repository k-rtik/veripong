vlib work
vlog -timescale 1ns/1ns ../game.v
vsim game

log {/*}
add wave {/*}

# Repeat Clock
force {clk} 					  0 0, 1 10 -repeat 20
force {reset} 					0 0, 1 10
force {leftPaddleUp}		0 0
force {leftPaddleDown} 	0 0, 1 10
force {rightPaddleUp}		0 0
force {rightPaddleDown}	0 0
force {isPvP}					  0 0
force {isPvPEnabled_n}  1 0, 0 30, 1 50
force {playAgain_n}     1 0

run 200