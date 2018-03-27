// `include "game.v"

module graphics(gameXBallPosition, gameYBallPosition, gameLeftPaddleY, gameRightPaddleY, clk, reset, x, y, colour, enable);
	
  input clk;
  input reset;
  
  output enable;
 
  output reg [2:0] colour;
 
  output reg [5:0] x;
  output reg [4:0] y;
 
  localparam FRAMES_60 = 26'd833333;
  
  // Store states
  localparam GET_GAME_POS = 3'd0, UNDRAW_PADDLE_LEFT = 3'd1, UNDRAW_PADDLE_RIGHT = 3'd2, UNDRAW_BALL = 3'd3, DRAW_PADDLE_LEFT = 3'd4, DRAW_PADDLE_RIGHT = 3'd5, DRAW_BALL = 3'd6, WAIT = 3'd7;
  reg [2:0] state;
  
  reg [25:0] clock;
  reg [2:0] paddleCounter;
  reg enable;
  
  // This paddle top y positions
	reg [4:0] lastLeftPaddleY;
	reg [4:0] lastRightPaddleY;
	
	// This ball positions
	reg [5:0] lastXBallPosition;
	reg [4:0] lastYBallPosition;
  
  // Last paddle top y positions
	reg [4:0] thisLeftPaddleY;
	reg [4:0] thisRightPaddleY;
	
	// Last ball positions
	reg [5:0] thisXBallPosition;
	reg [4:0] thisYBallPosition;
  
  // Game paddle top y positions
	input [4:0] gameLeftPaddleY;
	input [4:0] gameRightPaddleY;
	
	// Game ball positions
	input [5:0] gameXBallPosition;
	input [4:0] gameYBallPosition;
  
  always @(posedge clk, negedge reset)
  begin
    if (reset == 1'b0)
    begin
      clock <= 26'b0;
      paddleCounter <= 3'b0;
      enable <= 1'b0;
      
      // This paddle top y positions
      thisLeftPaddleY <= 6'b0;
      thisRightPaddleY <= 6'b0;
      
      // This ball positions
      thisXBallPosition <= 6'b0;
      thisYBallPosition <= 5'b0;
      
      // This paddle top y positions
      lastLeftPaddleY <= 6'b0;
      lastRightPaddleY <= 6'b0;
      
      // This ball positions
      lastXBallPosition <= 6'b0;
      lastYBallPosition <= 5'b0;
      
      // Set state
      state <= WAIT;
      x <= 6'b0;
      y <= 5'b0;
      colour <= 3'b000;
      
    end
    
    case(state)
    
      GET_GAME_POS:
      begin

        // Get the current game positions
        thisLeftPaddleY <= gameLeftPaddleY;
        thisRightPaddleY <= gameRightPaddleY;
        thisXBallPosition <= gameXBallPosition;
        thisYBallPosition <= gameYBallPosition;
        
        // Set the next state
        state <= state + 3'b1;
        
        enable <= 1'b0;
      end
      
      UNDRAW_PADDLE_LEFT:  
      begin
        colour <= 3'b000;
      
        if (paddleCounter == 3'd0)
        begin
          x <= 0;
          y <= lastLeftPaddleY;
        end
        
        else
        begin
          y <= y + 1;
        end
        
        if (paddleCounter == 3'd7)
        begin
          state <= state + 3'b1;
        end
        paddleCounter <= paddleCounter + 3'b1;
      end
      
      UNDRAW_PADDLE_RIGHT:
      begin
        colour <= 3'b000;
        
        if (paddleCounter == 3'd0)
        begin
          x <= 111111;
          y <= lastRightPaddleY;
        end
        
        else
        begin
          y <= y + 1;
        end
        
        if (paddleCounter == 3'd7)
        begin
          state <= state + 3'b1;
        end
        paddleCounter <= paddleCounter + 3'b1;
      end
      
      UNDRAW_BALL:
      begin
        colour <= 3'b000;
        x <= lastXBallPosition;
        y <= lastYBallPosition;
        state <= state + 1;
      end

      DRAW_PADDLE_LEFT:  
      begin
        colour <= 3'b111;
      
        if (paddleCounter == 3'd0)
        begin
          x <= 0;
          y <= thisLeftPaddleY;
        end
        
        else
        begin
          y <= y + 1;
        end
        
        if (paddleCounter == 3'd7)
        begin
          state <= state + 3'b1;
        end
        paddleCounter <= paddleCounter + 3'b1;
      end
      
      DRAW_PADDLE_RIGHT:
      begin
        colour <= 3'b111;
        
        if (paddleCounter == 3'd0)
        begin
          x <= 111111;
          y <= thisRightPaddleY;
        end
        
        else
        begin
          y <= y + 1;
        end
        
        if (paddleCounter == 3'd7)
        begin
          state <= state + 3'b1;
        end
        paddleCounter <= paddleCounter + 3'b1;
      end
      
      DRAW_BALL:
      begin
        colour <= 3'b111;
        x <= thisXBallPosition;
        y <= thisYBallPosition;
        state <= state + 1;
      end
      
      WAIT:
      begin
        if (clock == 26'd5)
        begin
          state <= state + 1;
          clock <= 26'b0;
          
          lastLeftPaddleY <= thisLeftPaddleY;
          lastRightPaddleY <= thisRightPaddleY;
          lastXBallPosition <= thisXBallPosition;
          lastYBallPosition <= thisYBallPosition;
        end
        
        else
        begin
          enable <= 1'b0;
          clock <= clock + 26'b1;
        end
      end
    endcase
  end
endmodule