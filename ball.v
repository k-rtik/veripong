module ball(clk, reset, isHittingLeft, isHittingRight, xPosition, yPosition);
	
	// Clock signal
	input clk;
	
	// Reset signal
	input reset;
	
	// Signal that indicates that the ball is hitting the left paddle
	input isHittingLeft;
	
	// Signal that indicatees that the ball is hitting the right paddle
	input isHittingRight;
	
	// The horizontal and vertical positions of the ball
	reg output [5:0] xPosition;
	reg output [4:0] yPosition;
	
	// Counter that controls the speed of the ball
	reg [3:0] speed;
	reg [18:0] time_counter;
	reg isMovingRight;
	reg  isMovingDown;
	
	// Wires that control the increment and decrement signals for the coordinate registers
	reg increment_x;
	reg increment_y;
	reg decrement_x;
	reg decrement_y;
	
	// 5 bit Increment-Decrement-Load register for the y coordinates of the ball
	IDLRegister5Bit yPositionRegister(
		.clk(clk),
		.increment(increment_y),
		.decrement(decrement_y),
		.load(reset),
		.loadVal(5'b00100),
		.out(yPosition)
	);
	
	// 6 bit Increment-Decrement-Load register for the x coordinates of the ball
	IDLRegister6Bit xPositionRegister(
		.clk(clk),
		.increment(increment_x),
		.decrement(decrement_x),
		.load(reset),
		.loadVal(6'001000),
		.out(xPosition)
	);
	
	// Control the moving of the ball
	always @(posedge clk, negedge reset)
	begin
		// If the reset signal is on
		if (reset == 1'b0)
		begin
				
			// Reset all variable values
			speed = 4'b0001;
			time_counter =19'b0000000000000000000;
					
			xPosition = 6'b001000;
			yPosition = 5'00100;
					
			increment_x = 1'b0;
			increment_y = 1'b0;
			decrement_x = 1'b0;
			decrement_y = 1'b0;
		end
		
		else
		begin
					
			// Reset incrementing signals
			increment_x = 1'b0;
			increment_y = 1'b0;
			decrement_x = 1'b0;
			decrement_y = 1'b0;
							
			// Move the time counter up
			integer k = speed;
			timeController = timeController + k;
					
			// Check if it is time for the ball to be moved
			if (timeController >= 19'bb1111010000100100000)
			begin
				// Reset the timer
				time_counter = 19'b0000000000000000000;
							
				// Increase the speed by one
				speed = speed + 4'b0001;
								
				// If the ball is ricocheting off the top wall
				else if (yPosition == 5'b00001)
					isMovingDown = 1'b1;
									
				// If the ball is ricocheting off the bottom wall
				else if (yPosition == 5'b11110)
					isMovingDown = 1;'b0;
				
				// If the ball is ricocheting off the left wall
				if (xPosition == 6'b000001)
				begin
					if (isHittingLeft == 1'b1)
						isMovingRight = 1'b1;
				end
				
				// If the ball is ricocheting off the right wall
				if (xPosition == 6'b111110)
				begin
					if (isHittingRight == 1'b1)
						isMovingRight = 1'b0;
				end
				
				// Move the balls in the right positions
				if (isMovingRight == 1'b1)
					increment_x = 1'b1;
								
				else
					decrement_x = 1'b1;
										
				if (isMovingDown == 1'b1)
					increment_y = 1'b1;
									
				else
					decrement_y = 1'b1;
				end
			end
		end
	end
endmodule

module IDLRegister5Bit(clk, increment, decrement, load, loadVal, out);

	// Clock signal
	input clk;
	
	// Increment and Decrement signals
	input increment;
	input decrement;
	
	// Load signal
	input load;
	
	// Load Value ( Used for resetting to default)
	input [4:0] loadVal;
	
	// Data stored in the register
	output [4:0] out;
	
	// Add or subtract 1 to the stored data based on the signals
	always @(posedge clk, negedge load)
	begin
		if (load == 1'b0)
		begin
			out = loadVal;
		end
		
		else
		begin
			if (increment == 1'b1)
				out = out + 5'b00001;
			else if (decrement == 1'b1)
				out = out + 5'b11111;
			end
		end
endmodule

module IDLRegister6Bit(clk, increment, decrement, load, loadVal, out);

	// Clock signal
	input clk;
	
	// Increment and Decrement signals
	input increment;
	input decrement;
	
	// Load signal
	input load;
	
	// Load Value ( Used for resetting to default)
	input [5:0] loadVal;
	
	// Data stored in the register
	output [5:0] out;
	
	// Add or subtract 1 to the stored data based on the signals
	always @(posedge clk, negedge load)
	begin
		if (load == 1'b0)
		begin
			out = loadVal;
		end
		
		else
		begin
			if (increment == 1'b1)
				out = out + 6'b000001;
			else if (decrement == 1'b1)
				out = out + 6'b111111;
		end
	end
endmodule
