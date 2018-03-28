//`include "paddle.v"
//`include "score.v"
//`include "ball.v"
//`include "graphics.v"

module game(clk, reset, isPvP, isPvPEnabled_n, playAgain_n, leftPaddleUp, leftPaddleDown, rightPaddleUp, rightPaddleDown, leftScore, rightScore, x, y, colour, graphics_enable);
	// Clock signal
	input clk;
	
	// Reset signal
	input reset;
	
	// Signal that indicates which game mode is being played
	input isPvP;
  input isPvPEnabled_n;
  
  input playAgain_n;
  
  // States
  reg [1:0] states;
  localparam START_MENU = 2'd0, GAME = 2'd1, END_MENU = 2'd3;
	
	// Paddle enables
	input leftPaddleUp;
	input rightPaddleUp;
	input leftPaddleDown;
	input rightPaddleDown;
	
	// Scores for the game
	output [3:0] leftScore;
	output [3:0] rightScore;
	
  // Storing isPvP value when enabled
  reg thisPvP;
  
	// Paddle positions
	wire [31:0] leftPaddlePosition;
	wire [31:0] rightPaddlePosition;
	
	// Paddle top y positions
	reg [5:0] leftPaddleY;
	reg [5:0] rightPaddleY;
	
	// Ball positions
	wire [5:0] xBallPosition;
	wire [4:0] yBallPosition;
	
	// Ball moving signal
	wire isBallMovingNext;
	
	// Ball collision enablers
	reg isHittingLeft;
	reg isHittingRight;
	
	// Scoreboard enable signals
	reg es_p1;
	reg es_p2;
	
	// Enable signal that controls when the game components reset
	reg game_reset;
  
  // A clock that only works in game mode
  reg game_clk;
  
  // Output Signals
  output [5:0] x;
  output [4:0] y;
  output [2:0] colour;
  
  output graphics_enable;
  
  // Instance of the graphic converter
  graphics g1(xBallPosition, yBallPosition, leftPaddleY, rightPaddleY, game_clk, reset, x, y, colour, graphics_enable);
	
	// Instances of the paddles
	paddle leftPaddle(
		.clk(game_clk), 
		.reset(game_reset), 
		.moveUp(leftPaddleUp), 
		.moveDown(leftPaddleDown), 
		.verticalPosition(leftPaddlePosition)
	);
	
	paddle rightPaddle(
		.clk(game_clk), 
		.reset(game_reset), 
		.moveUp(rightPaddleUp), 
		.moveDown(rightPaddleDown), 
		.verticalPosition(rightPaddlePosition)
	);
	
	// Instances of the ball
	ball b(
		.clk(game_clk), 
		.reset(game_reset),
		.xPosition(xBallPosition), 
		.yPosition(yBallPosition),
    .isBallMovingNext(isBallMovingNext)
	);
	
	// Scoreboard for the game
	score scoreboard(
		.clk(game_clk), 
		.resetn(reset), 
		.hit1(es_p1), 
		.hit2(es_p2), 
		.scoreboard({leftScore, rightScore})
	);
	
  integer i;
  
  always @(*)
  begin
    if (reset == 1'b0)
      game_clk <= 1'b0;
      
    else if (states == GAME)
      game_clk <= clk;
    else
      game_clk <= 1'b0;
		
    for (i = 0; i < 32; i = i + 1)
		begin
			if (leftPaddlePosition[i] == 1'b1)
				leftPaddleY = i;
			if (rightPaddlePosition[i] == 1'b1)
				rightPaddleY = i;
		end
  end
  
  // GAME LOGIC
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
      thisPvP <= 1'b0;
      states <= START_MENU;
		end
		
    
		// Handle Game Logic
		else
    begin
      if (states == GAME)
      begin  
        if (leftScore == 4'b1011 | rightScore == 4'b1011)
        begin
          if (isPvP == 1'b1)
          begin
            game_reset <= 1'b0;
            states <= END_MENU;
          end
        end
        
        else
        begin
          game_reset <= 1'b1;
          isHittingLeft <= 1'b0;
          isHittingRight <= 1'b0;
          es_p1 <= 1'b0;
          es_p2 <= 1'b0;
          
          // Collision detection if the ball is moving
          if (isBallMovingNext == 1'b1)
            begin
            // Left Paddle Collision
            if (xBallPosition == 6'b000001)
            begin
              if (leftPaddlePosition[yBallPosition] == 1'b1)
              begin
                if (thisPvP == 1'b0)
                  es_p2 <= 1'b1;
                isHittingLeft <= 1'b1;
              end
              else
              begin
                if (thisPvP == 1'b1)
                  es_p2 <= 1'b1;
                game_reset <= 1'b0;
              end	
            end
            
            // Right Paddle Collision
            else if (xBallPosition >= 6'b111110)
            begin
              if (rightPaddlePosition[yBallPosition] == 1'b1)
              begin
                if (thisPvP == 1'b0)
                  es_p1 <= 1'b1;
                isHittingRight <= 1'b1;
              end
              else
              begin
                if (thisPvP == 1'b1)
                  es_p1 <= 1'b1;
                game_reset <= 1'b0;
              end
            end
          end
        end
      end
    
      else if (states == START_MENU)
      begin
        game_reset <= 1'b0;
        isHittingLeft <= 1'b0;
        isHittingRight <= 1'b0;
        es_p1 <= 1'b0;
        es_p2 <= 1'b0;
        game_reset <= 1'b0;
        thisPvP <= 1'b0;
      
        if (isPvPEnabled_n == 1'b0)
        begin
          thisPvP <= isPvP;
          states <= GAME;
        end
      end
      
      else if (states == END_MENU)
      begin
        if (playAgain_n == 1'b0)
        begin
          states <= START_MENU;
        end
      end
    end
	end  
endmodule 