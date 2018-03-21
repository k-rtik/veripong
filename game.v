//`include "paddle.v"
//`include "score.v"
//`include "ball.v"

module game(clk, reset, isPvP, leftPaddleUp, leftPaddleDown, rightPaddleUp, rightPaddleDown, leftScore, rightScore, leftPaddleY, rightPaddleY);

	// Clock signal
	input clk;
	
	// Reset signal
	input reset;
	
	// Signal that indicates which game mode is being played
	input isPvP;
	
	// Paddle enables
	input leftPaddleUp;
	input rightPaddleUp;
	input leftPaddleDown;
	input rightPaddleDown;
	
	// Scores for the game
	output [3:0] leftScore;
	output [3:0] rightScore;
	
	// Paddle positions
	wire [31:0] leftPaddlePosition;
	wire [31:0] rightPaddlePosition;
	
	// Paddle top y positions
	output reg [5:0] leftPaddleY;
	output reg [5:0] rightPaddleY;
	
	// Ball positions
	wire [5:0] xBallPosition;
	wire [4:0] yBallPosition;
	
	// Ball moving signal
	wire isBallMoving;
	
	// Ball collision enablers
	reg isHittingLeft;
	reg isHittingRight;
	
	// Scoreboard enable signals
	reg es_p1;
	reg es_p2;
	
	// Enable signal that controls when the game components reset
	reg game_reset;
	
	// Instances of the paddles
	paddle leftPaddle(
		.clk(clk), 
		.reset(game_reset), 
		.moveUp(leftPaddleUp), 
		.moveDown(leftPaddleDown), 
		.verticalPosition(leftPaddlePosition)
	);
	
	paddle rightPaddle(
		.clk(clk), 
		.reset(game_reset), 
		.moveUp(rightPaddleUp), 
		.moveDown(rightPaddleDown), 
		.verticalPosition(rightPaddlePosition)
	);
	
	// Instances of the ball
	ball b(
		.clk(clk), 
		.reset(game_reset), 
		.isHittingLeft(isHittingLeft), 
		.isHittingRight(isHittingRight), 
		.xPosition(xBallPosition), 
		.yPosition(yBallPosition),
		.isBallMoving(isBallMoving)
	);
	
	// Scoreboard for the game
	score scoreboard(
		.clk(clk), 
		.resetn(reset), 
		.hit1(es_p1), 
		.hit2(es_p2), 
		.scoreboard({leftScore, rightScore})
	);
	
	always @(posedge clk, negedge reset)
	begin
		// Reset Logic
		if (reset == 1'b0)
		begin
			isHittingLeft <= 1'b0;
			isHittingRight <= 1'b0;
			es_p1 <= 1'b0;
			es_p2 <= 1'b0;
			game_reset <= 1'b0;
		end
		
		// Check if ball collides with paddle
		else
		begin
			game_reset <= 1'b1;
			isHittingLeft <= 1'b0;
			isHittingRight <= 1'b0;
			es_p1 <= 1'b0;
			es_p2 <= 1'b0;
			
			// Collision detection if the ball is moving
			if (isBallMoving == 1'b1)
				begin
				// Left Paddle Collision
				if (xBallPosition == 6'b000001)
				begin
					if (leftPaddlePosition[yBallPosition] == 1'b1)
					begin
						if (isPvP == 1'b0)
							es_p2 <= 1'b1;
						isHittingLeft <= 1'b1;
					end
					else
					begin
						if (isPvP == 1'b1)
							es_p2 <= 1'b1;
						game_reset <= 1'b0;
					end	
				end
				
				// Right Paddle Collision
				else if (xBallPosition >= 6'b111110)
				begin
					if (rightPaddlePosition[yBallPosition] == 1'b1)
					begin
						if (isPvP == 1'b0)
							es_p1 <= 1'b1;
						isHittingRight <= 1'b1;
					end
					else
					begin
						if (isPvP == 1'b1)
							es_p1 <= 1'b1;
						game_reset <= 1'b0;
					end
				end
			end
		end
	end

	
	integer i;
	
	always @(*)
	begin
		
		for (i = 0; i < 32; i = i + 1)
		begin
			if (leftPaddlePosition[i] == 1'b1)
				leftPaddleY = i;
			if (rightPaddlePosition[i] == 1'b1)
				rightPaddleY = i;
		end
	end
endmodule 