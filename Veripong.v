module GameLoopModule(clk, reset);

// Clock signal
input clk;
	
// Reset Signal
input reset;

endmodule 

module GameLoopControlModule(clk, reset);

// Clock Signal
input clk;

// Reset Signal
input reset;

// Params for state machines
localparam MAIN_MENU, GAME_START, GAME, GAME_END;

endmodule
