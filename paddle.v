module paddle(clk, moveUp, moveDown, inPaddleRange, ballPosition, isHit);

	// Signals to move the paddles in a direction
	input moveUp;
	input moveRight;

	// Clock signal
	input clk;

	// Signal to enable collision detection
	input inPaddleRange;

	// Y-position of the ball (Since the X-position is the same as the paddle
	input [6:0] ball_y;
endmodule 


// Shift Register That Loads 0 On Either Side
module Register128bit(clk, reset, kill, leftShift, rightShift, out);
	// Clock signal
	input clk;
	
	// Reset to default values or rest to zero
	input reset;
	input kill;
	
	// Shift enable signals
	input leftShift;
	input rightShift;
	
	// Data output from 128-bit register
	output reg [127:0] out;
endmodule

// Flip flop for Register
module DoubleSideShifter(clk, enableLeft, leftVal, enableRight, rightVal, enableLoad, loadVal, out);
	// Clock signal
	input clk;
	
	// Shift enable signals
	input enableLeft;
	input enableRight;
	
	// Data values for left/right shifts
	input leftVal;
	input rightVal;
	
	// Load enable signal and load value -- Used to Reset
	input enableLoad;
	input loadVal;
	
	// Data output
	reg output out;
	
	always @(posedge clk, negedge enableLoad)
		if (enableLoad == 0)
		// Reset
		begin
			out <= loadVal;
		end
		
		// Shift the data
		else
		begin
			if (enableLeft == 1'b1) out <= leftVal;
			else if (enableRight == 1'b1) out <= rightVal;
		end
endmodule 