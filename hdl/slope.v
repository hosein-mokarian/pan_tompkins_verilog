module slope
  #(parameter DATA_WIDTH = 16)
  (
    input rstn,
    input en,
    input clk,
    input signed [DATA_WIDTH - 1 : 0] xin,
    output [DATA_WIDTH - 1 : 0] last_slope,
    output [DATA_WIDTH - 1 : 0] yout
  );

  parameter NB_OF_REGS = 10;

  reg [DATA_WIDTH - 1 : 0] sr [NB_OF_REGS - 1 : 0];
  reg [DATA_WIDTH - 1 : 0] max;
  reg [DATA_WIDTH - 1 : 0] result [1 : 0];
  integer i;

  always @(posedge clk or negedge rstn)
  begin
    if(!rstn)
    begin
      max = 0;

      for (i = 0; i <NB_OF_REGS; i++)
        sr[i] <= 0;

      for (i = 0; i < 2; i++)
        result[i] <= 0;
    end
    else if (rstn && en)
    begin
      sr[0] <= xin;
      for (i = 0; i < NB_OF_REGS - 1; i++)
        sr[i + 1] <= sr[i];

      max = xin;
      for (i = 0; i < NB_OF_REGS - 2; i++)
        if (sr[i] > max )
          max = sr[i];

      result[0] <= max;
      result[1] <= result[0];
    end
  end

  assign last_slope = (rstn && en) ? result[0] : {DATA_WIDTH{1'b0}}; // result[1] 
  assign yout = (rstn && en) ? result[0] : {DATA_WIDTH{1'b0}};

endmodule