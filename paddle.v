//NOTES
// GAME COORDINATES : 32X64
// PADDLE SIZE : 8X1

module paddle(clk, reset, moveUp, moveDown, inPaddleRange, ballPosition, isHit);

	// Signals to move the paddles in a direction
	input moveUp;
	input moveRight;

	// Clock signal
	input clk;
	
	// Reset signal
	input reset;

	// Signal to enable collision detection
	input inPaddleRange;

	// Y-position of the ball (Since the X-position is the same as the paddle
	input [4:0] ballPosition;
	
	// Output that indicates whether the ball has hit the paddle or not
	reg output isHit;
	
	// Wires that store the returned position of the paddle from the register
	wire [31:0] paddlePositions;
	
	// 32-bit register that stores the position of the paddle
	Register32bit(clk, reset, moveUp, moveDown, paddlePositions);
	
	// Collision detection between ball and paddle
	always @(posedge clk, negedge reset) 
		begin
			if (clk == 1'b1)
				begin
					if (inPaddleRange == 1'b1)
						begin
							integer ballPos = ballPosition;
							if (paddlePositions[ballPos] == 1'b1)
								isHit = 1'b0;
							else
								isHit = 1'b1;
						end
				end
			else 
				begin
					isHit = 1'b0;
				end
		end
endmodule 

// Shift Register That Loads 0 On Either Side
module Register32bit(clk, reset, leftShift, rightShift, out);
	// Clock signal
	input clk;
	
	// Reset to default values
	input reset;
	
	// Shift enable signals
	input leftShift;
	input rightShift;
	
	// Data output from 32-bit register
	output [31:0] out;
	
	// Reset values for register
	wire [31:0] loadVals = 32'b00000000000011111111000000000000;
	
	// Wires to connect double side shifters to each other
	wire [31:0] leftVals;
	wire [31:0] rightVals;
	
	// Assign the wires to the proper output connections
	integer i;
	
	for (i = 0; i < 31; i=i+1) begin
		assign rightVals[i] = out[i+1];
		assign leftVals[i+1] = out[i];
	end
	
	leftVals[0] = 1'b0;
	rightVals[31] = 1'b0;
	
	// Double sided shifters connected to each other to store the position of the paddle
	DoubleSideShifter ds[31:0] (
		.clk(clk),
		.enableLeft(moveUp),
		.leftVal(leftVals),
		.enableRight(moveDown),
		.rightVal(rightVals),
		.enableLoad(reset),
		.loadVal(loadVals),
		.out(out)
	);
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