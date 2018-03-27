module hello(
	CLOCK_50,
	KEY,
	VGA_CLK,                       	//	VGA Clock
	VGA_HS,                        	//	VGA H_SYNC
	VGA_VS,                        	//	VGA V_SYNC
	VGA_BLANK_N,                    	//	VGA BLANK
	VGA_SYNC_N,                    	//	VGA SYNC
	VGA_R,                       	//	VGA Red[9:0]
	VGA_G,                         	//	VGA Green[9:0]
	VGA_B                       	//	VGA Blue[9:0]
 );

	input CLOCK_50;
	input [0:0] KEY;

	output        VGA_CLK;               	//	VGA Clock
  output        VGA_HS;                	//	VGA H_SYNC
  output        VGA_VS;                	//	VGA V_SYNC
  output        VGA_BLANK_N;            	//	VGA BLANK
  output        VGA_SYNC_N;            	//	VGA SYNC
  output	[9:0]	VGA_R;               	//	VGA Red[9:0]
  output	[9:0]	VGA_G;                 	//	VGA Green[9:0]
  output	[9:0]	VGA_B;               	//	VGA Blue[9:0]

	wire resetn;
  
  reg writeEn;
  
  assign resetn = KEY[0];
 
  reg [2:0] colour;
 
  wire [5:0] x;
  wire [4:0] y;
 

	vga_adapter VGA_white(
        .resetn(resetn),
        .clock(CLOCK_50),
        .colour(colour),
        .x(x),
        .y(y),
        .plot(writeEn),
				
          	/* Signals for the DAC to drive the monitor. */
          	
				.VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_BLANK(VGA_BLANK_N),
        .VGA_SYNC(VGA_SYNC_N),
        .VGA_CLK(VGA_CLK)
  );
      	
	defparam VGA_white.RESOLUTION = "160x120";
  defparam VGA_white.MONOCHROME = "FALSE";
  defparam VGA_white.BITS_PER_COLOUR_CHANNEL = 1;
  defparam VGA_white.BACKGROUND_IMAGE = "black.mif";

	ball b0(
  	.clk(CLOCK_50),
  	.reset(resetn),
  	.isHittingLeft(1'b1),
  	.isHittingRight(1'b1),
  	.xPosition(x),
  	.yPosition(y)
	);

	wire newclk;

	ratedivider rd0(.divider(26'd833333),
                	.reset(resetn),
                	.clk(CLOCK_50),
                	.out(newclk));

	always @(posedge newclk, negedge resetn)
	begin
  	if (resetn == 1'b0)
   begin
    	writeEn <= 1'b0;
	   colour <= 3'b000;
   end
  	else
    	begin
	writeEn <= 1'b1;
      	//writeEn <= writeEn;
	colour <= ~colour;
    	end
	end

endmodule

module ratedivider(divider, reset, clk, out);
  input [25:0] divider;
  input reset, clk;
  output out;

  reg [25:0] c;
  reg d;

  always @(posedge clk, negedge reset)
  begin
	if (reset == 1'b0)
 	begin
    	c <= divider;
  	end
	else
  	begin
  	c = c - 26'd1;
  	if (c == 26'd0)
    	begin
    	d<=1'b1;
    	c <= divider;
    	end
  	else
    	d<=1'b0;
  	end
  end
  assign out = d;
endmodule

module ball(clk, reset, isHittingLeft, isHittingRight, xPosition, yPosition, isBallMovingNext);

	// Clock signal
	input clk;

	// Reset signal
	input reset;

	// Signal that indicates that the ball is hitting the left paddle
	input isHittingLeft;

	// Signal that indicatees that the ball is hitting the right paddle
	input isHittingRight;

	// The horizontal and vertical positions of the ball
	output [5:0] xPosition;
	output [4:0] yPosition;

	// Output signal that determines whether the ball is going to move or not
	output reg isBallMovingNext;

	// Counter that controls the speed of the ball
	reg [3:0] speed;
	reg [20:0] time_counter;
	reg isMovingRight;
	reg  isMovingDown;

	// Wires that control the increment and decrement signals for the coordinate registers
	reg incrementX;
	reg incrementY;
	reg decrementX;
	reg decrementY;

	// Store speed
	integer k;

	// Control the moving of the ball
	always @(posedge clk, negedge reset)
	begin
    	// If the reset signal is on
    	if (reset == 1'b0)
    	begin

        	// Reset all variable values
        	speed <= 4'b0001;
        	time_counter <=21'd0;

        	isMovingRight <= 1'b0;
        	isMovingDown <= 1'b1;

        	incrementX <= 1'b0;
        	incrementY <= 1'b0;
        	decrementX <= 1'b0;
        	decrementY <= 1'b0;

        	isBallMovingNext <= 1'b0;
    	end

    	else
    	begin

        	// Reset incrementing signals
        	incrementX <= 1'b0;
        	incrementY <= 1'b0;
        	decrementX <= 1'b0;
        	decrementY <= 1'b0;
        	isBallMovingNext <= 1'b0;

        	// Move the time counter up
        	//k = speed;
        	time_counter = time_counter + 21'd1;

        	// Check if it is time for the ball to be moved
        	if (time_counter >= 21'd5)
        	begin
            	// Signal that the ball is moving
            	isBallMovingNext <= 1'b1;

            	// Reset the timer
            	time_counter <= 21'd0;

            	// Increase the speed by one
            	speed <= speed + 4'b0001;

            	// If the ball is ricocheting off the top wall
            	if (yPosition <= 5'b00001)
                	isMovingDown <= 1'b1;

            	// If the ball is ricocheting off the bottom wall
            	else if (yPosition >= 5'b11110)
                	isMovingDown <= 1'b0;

            	// If the ball is ricocheting off the left wall
            	if (xPosition == 6'b000001)
            	begin
                	// if (isHittingLeft == 1'b1)
                    	isMovingRight = 1'b1;
            	end

            	// If the ball is ricocheting off the right wall
            	if (xPosition >= 6'b111110)
            	begin
                	if (isHittingRight == 1'b1)
                    	isMovingRight = 1'b0;
            	end

            	// Move the balls in the right positions
            	if (isMovingRight == 1'b1)
                	incrementX <= 1'b1;

            	else
                	decrementX <= 1'b1;

            	if (isMovingDown == 1'b1)
                	incrementY <= 1'b1;

            	else
                	decrementY <= 1'b1;
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
    	.out(yPosition)
	);

	// 6 bit Increment-Decrement-Load register for the x coordinates of the ball
	IDLRegister6Bit xPositionRegister(
    	.clk(clk),
    	.increment(incrementX),
    	.decrement(decrementX),
    	.load(reset),
    	.loadVal(6'b001000),
    	.out(xPosition)
	);

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
        	if (increment == 1'b1)
            	out <= out + 5'b00001;
        	else if (decrement == 1'b1)
            	out <= out + 5'b11111;
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
	output reg [5:0] out;

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
            	out <= out + 6'b000001;
        	else if (decrement == 1'b1)
            	out <= out + 6'b111111;
    	end
	end
endmodule
