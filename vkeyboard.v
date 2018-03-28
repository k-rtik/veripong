// `include "PS2_Controller.v"
// `include "PS2_Keyboard_Controller.v"

module vboard(SW, KEY, CLOCK_50, VGA_CLK, VGA_HS,	VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R,	VGA_G, VGA_B, PS2_CLK, PS2_DAT);

  // Board inputs
  input [1:0] SW;
  input [3:0] KEY;
  input CLOCK_50;
  
  // VGA Stuff
  output        VGA_CLK;                                       	//	VGA Clock
  output        VGA_HS;                	                        //	VGA H_SYNC
  output        VGA_VS;                	                        //	VGA V_SYNC
  output        VGA_BLANK_N;            	                      //	VGA BLANK
  output        VGA_SYNC_N;            	                        //	VGA SYNC
  output	[9:0]	VGA_R;               	                          //	VGA Red[9:0]
  output	[9:0]	VGA_G;                 	                        //	VGA Green[9:0]
  output	[9:0]	VGA_B;               	                          //	VGA Blue[9:0]
  
  // Keyboard Stuff
  inout PS2_CLK;
  inout PS2_DAT;
  
  // Invert signals from active low to active high
  wire paddleLup;
  wire paddleLdown;
  wire paddleRup;
  wire paddleRdown;
  
  wire reset = ~SW[1];
  
  // Temporarily store outputs
  wire [4:0] leftScore;
  wire [4:0] rightScore;
  
  up_down_only_keyboard_tracker #(.PULSE_OR_HOLD(1)) paddle_input(
	  .clock(CLOCK_50),
	  .reset(KEY[0]),
		.PS2_CLK(PS2_CLK),
		.PS2_DAT(PS2_DAT),
		.w(paddleLup),
		.s(paddleLdown),
		.up(paddleRup),
		.down(paddleRdown)
	);
  
  game(CLOCK_50, reset, SW[0], KEY[0], KEY[0], paddleLup, paddleLdown, paddleRup, paddleRdown, leftScore, rightScore, x, y, colour, enable);
  
  vga_adapter v_a(
    .resetn(resetn),
    .clock(CLOCK_50),
    .colour(colour),
    .x(x),
    .y(y),
    .plot(enable),
				
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
      	
	defparam v_a.RESOLUTION               = "160x120";
  defparam v_a.MONOCHROME               = "FALSE";
  defparam v_a.BITS_PER_COLOUR_CHANNEL  = 1;
  defparam v_a.BACKGROUND_IMAGE         = "black.mif";
  
endmodule