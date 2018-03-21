//NOTES
// GAME COORDINATES : 32X64
// PADDLE SIZE : 8X1

module paddle(clk, reset, moveUp, moveDown, verticalPosition);

	// Signals to move the paddles in a direction
	input moveUp;
	input moveDown;

	// Clock signal
	input clk;
	
	// Reset signal
	input reset;
	
	// Store the returned position of the paddle from the register
	output [31:0] verticalPosition;

	// Store the end case logic
	reg enableUp;
	reg enableDown;
	
	// Reset the values of enable up and down
	always @(negedge reset)
	begin
		enableUp = 1'b0;
		enableDown = 1'b0;
	end
	
	// End cases logic
	always @(*)
	begin
		if (moveUp == 1'b1)
		begin
			if (verticalPosition[31] == 1'b1)
				enableUp = 1'b0;
			
			else
				enableUp = 1'b1;
		end
		
		if (moveDown == 1'b1)
		begin
			if (verticalPosition[0] == 1'b1)
				enableDown = 1'b0;
			else
				enableDown = 1'b1;
		end
	end
	
		
	// 32-bit register that stores the position of the paddle
	Register32bit r32b(clk, reset, enableUp, enableDown, verticalPosition);
	
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
	genvar i;
	
	for (i = 0; i < 31; i=i+1)
	begin
		assign rightVals[i] = out[i+1];
		assign leftVals[i+1] = out[i];
	end
	
	assign leftVals[0] = 1'b0;
	assign rightVals[31] = 1'b0;
	
	// Double sided shifters connected to each other to store the position of the paddle
	DoubleSideShifter ds[31:0] (
		.clk(clk),
		.enableLeft(leftShift),
		.leftVal(leftVals),
		.enableRight(rightShift),
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
	output reg out;
	
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