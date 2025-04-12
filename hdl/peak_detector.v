module peak_detector
  #(parameter DATA_WIDTH = 16)
  (
    input rstn,
    input en,
    input clk,
    input signed [DATA_WIDTH - 1 : 0] xin,
    input timer_activation,
    output signed [DATA_WIDTH - 1: 0] yout,
    output flag
  );

  parameter NB_OF_REGS = 3;

  reg signed [DATA_WIDTH - 1 : 0] sr [NB_OF_REGS - 1 : 0];
  reg signed [DATA_WIDTH - 1 : 0] peak;
  reg state;
  integer i;

  wire signed [DATA_WIDTH - 1 : 0] sr0 = sr[0];
  wire signed [DATA_WIDTH - 1 : 0] sr1 = sr[1];
  wire signed [DATA_WIDTH - 1 : 0] sr2 = sr[2];

  always @(posedge clk or negedge rstn)
  begin
    if (!rstn)
    begin
      for (i = 0; i < NB_OF_REGS; i++)
        sr[i] <= 0;
      peak <= 0;
      state <= 0;
    end
    else if (rstn && en)
    begin
      sr[0] <= xin;
      for (i= 0; i < NB_OF_REGS - 1; i++)
        sr[i + 1] <= sr[i];
      
      if (sr[1] > sr[2] && sr[1] >= sr[0])
      begin
        if (timer_activation == 0)
        begin
          peak <= sr[1];
          state <= 1;
        end
        else
        begin
          if (sr[1] > peak)
          begin
            peak <= sr[1];
            state <= 1;
          end
        end
      end
      else
        state <= 0;
    end
  end

  // assign peak = (sr[1] > sr[2] && sr[1] < sr[0]) ? sr[1] : {DATA_WIDTH{1'b0}};

  assign yout = (rstn && en) ? peak : {DATA_WIDTH{1'b0}};
  assign flag = (rstn && en) ? (state ? 1 : 0) : 0;

endmodule