module ball(clk, reset, xPosition, yPosition, isBallMovingNext);
	
	// Clock signal
	input clk;
	
	// Reset signal
	input reset;
	
	// The horizontal and vertical positions of the ball
	output [5:0] xPosition;
	output [4:0] yPosition;
	
	// Output signal that determines whether the ball is going to move or not
	output reg isBallMovingNext;
	
	// Counter that controls the speed of the ball
	reg [3:0] speed;
	reg [18:0] time_counter;
  
  // Ball direction signals
	reg isMovingRight;
	reg  isMovingDown;
	
	// Wires that control the increment and decrement signals for the coordinate registers
	reg incrementX;
	reg incrementY;		
	reg decrementX;
	reg decrementY;
	
	// Store speed
	integer k;
  
  // Store clock reset times
  localparam BALL_SLOWEST_SPEED = 19'd5, BALL_MOVE_STAGE = 19'd4;
	
  // Check collision detection
  always @(*)
  begin
    
    if (reset == 1'b0)
    begin
      isMovingRight <= 1'b0;
			isMovingDown <= 1'b1;
					
			incrementX <= 1'b0;
			incrementY <= 1'b0;
			decrementX <= 1'b0;
			decrementY <= 1'b0;
    end
  
    begin
    // If the ball is ricocheting off the top wall
		if (yPosition <= 5'b00001)
      isMovingDown = 1'b1;
									
		// If the ball is ricocheting off the bottom wall
		else if (yPosition >= 5'b11110)
			isMovingDown = 1'b0;
				
		// If the ball is ricocheting off the left wall
		if (xPosition == 6'b000001)
      isMovingRight = 1'b1;
				
		// If the ball is ricocheting off the right wall
		if (xPosition >= 6'b111110)
			isMovingRight = 1'b0;
    end
      
    // Move the balls in the right positions
		if (isMovingRight == 1'b1)
    begin
      incrementX = 1'b1;
      decrementX = 1'b0;
    end
				
    else
    begin
      decrementX = 1'b1;
      incrementX = 1'b0;
		end
        
		if (isMovingDown == 1'b1)
      begin
        incrementY = 1'b1;
        decrementY = 1'b0;
      end
        
    else
    begin
				decrementY = 1'b1;
        incrementY = 1'b0;
    end
  end
  
	// Control the moving of the ball
	always @(posedge clk, negedge reset)
	begin
		// If the reset signal is on
		if (reset == 1'b0)
		begin
				
			// Reset all variable values
			speed <= 4'b0001;
			time_counter <= 19'b0000000000000000000;
			
			isBallMovingNext <= 1'b0;
		end
		
		else
		begin
			// Handle moving the ball
			if (time_counter == BALL_SLOWEST_SPEED)
      begin
        isBallMovingNext <= 1'b0;
				
        // Reset the timer
				time_counter <= 19'b0000000000000000000;
							
				// Increase the speed by one
				//speed <= speed + 4'b0001;
			end
      
      else if (time_counter == BALL_MOVE_STAGE)
      begin
				isBallMovingNext <= 1'b1;

        time_counter <= time_counter + 19'b1;
      end
      
      else
      begin
        // Move the time counter up
        //k = speed;
        time_counter = time_counter + 19'b1;
      end
		end
  end
				
	// 5 bit Increment-Decrement-Load register for the y coordinates of the ball
	IDLRegister5Bit yPositionRegister(
		.clk(clk),
		.increment(incrementY),
		.decrement(decrementY),
		.load(reset),
		.loadVal(5'b00100),
		.out(yPosition),
    .enable(isBallMovingNext)
	);
	
	// 6 bit Increment-Decrement-Load register for the x coordinates of the ball
	IDLRegister6Bit xPositionRegister(
		.clk(clk),
		.increment(incrementX),
		.decrement(decrementX),
		.load(reset),
		.loadVal(6'b001000),
		.out(xPosition),
    .enable(isBallMovingNext)
	);
	
endmodule

module IDLRegister5Bit(clk, enable, increment, decrement, load, loadVal, out);

	// Clock signal
	input clk;
	
  // Enable increment or decrement signal
  input enable;
  
	// Increment and Decrement signals
	input increment;
	input decrement;
	
	// Load signal
	input load;
	
	// Load Value ( Used for resetting to default)
	input [4:0] loadVal;
	
	// Data stored in the register
	output reg [4:0] out;
	
	// Add or subtract 1 to the stored data based on the signals
	always @(posedge clk, negedge load)
	begin
		if (load == 1'b0)
		begin
			out = loadVal;
		end
		
		else
		begin
      if (enable == 1'b1)
      begin
        if (increment == 1'b1)
          out <= out + 5'b00001;
        else if (decrement == 1'b1)
          out <= out + 5'b11111;
      end
    end
  end
endmodule

module IDLRegister6Bit(clk, enable, increment, decrement, load, loadVal, out);

	// Clock signal
	input clk;
	
	// Increment and Decrement signals
	input increment;
	input decrement;
  
  // Enable signal for incrementing/decrementing
  input enable;
	
	// Load signal
	input load;
	
	// Load Value ( Used for resetting to default)
	input [5:0] loadVal;
	
	// Data stored in the register
	output reg [5:0] out;
	
	// Add or subtract 1 to the stored data based on the signals
	always @(posedge clk, negedge load)
	begin
		if (load == 1'b0)
		begin
			out <= loadVal;
		end
		
		else
		begin
      if (enable == 1'b1)
      begin
        if (increment == 1'b1)
          out <= out + 6'b000001;
        else if (decrement == 1'b1)
          out <= out + 6'b111111;
      end
    end
	end
endmodule
