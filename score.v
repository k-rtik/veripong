module score(clk, resetn, hit1, hit2, scoreboard);
  input clk, resetn, hit1, hit2;
  output [7:0] scoreboard;

  reg [7:0] p1score;

  always @(posedge clk, negedge resetn)
  begin
    if (resetn == 1'b0)
      p1score<=8'd0;
    else
      begin
      if (hit1 == 1'b1)
        p1score <= p1score + 8'b00000001;
      else if (hit1 == 1'b0)
        p1score <= p1score;
      end
  end

  reg [7:0] p2score;

  always @(posedge clk, negedge resetn)
  begin
    if (resetn == 1'b0)
      p2score<=8'd0;
    else
      begin
      if (hit2 == 1'b1)
        p2score <= p2score + 8'b00010000;
      else if (hit2 == 1'b0)
        p2score <= p2score;
      end
  end

  assign scoreboard = p1score + p2score;

endmodule
