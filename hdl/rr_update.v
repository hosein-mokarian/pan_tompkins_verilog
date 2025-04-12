module rr_update
  #(parameter DATA_WIDTH = 16)
  (
    input rstn,
    input en,
    input clk,
    input rru,
    input signed [DATA_WIDTH - 1 : 0] rr_interval,
    output reg signed [DATA_WIDTH - 1 : 0] rrmiss,
    output reg regular
  );

  parameter PT1000MS = 200;

  parameter RR92PERCENT = 184;
  parameter RR116PERCENT = 232;
  parameter RR166PERCENT = 332;

  parameter REGULAR_HR = 0;
  parameter IRREGULAR_HR = 1;

  parameter NB_OF_REGS = 8;

  reg signed [DATA_WIDTH - 1 : 0] sr1 [NB_OF_REGS - 1 : 0];
  reg signed [DATA_WIDTH - 1 : 0] sr2 [NB_OF_REGS - 1 : 0];
  reg signed [2 * DATA_WIDTH - 1 : 0] rravg1;
  reg signed [2 * DATA_WIDTH - 1 : 0] rravg2;
  reg signed [DATA_WIDTH - 1 : 0] rrlow;
  reg signed [DATA_WIDTH - 1 : 0] rrhigh;
  integer i;

  wire signed [DATA_WIDTH - 1 : 0] sr1_0 = sr1[0];
  wire signed [DATA_WIDTH - 1 : 0] sr1_1 = sr1[1];
  wire signed [DATA_WIDTH - 1 : 0] sr1_2 = sr1[2];
  wire signed [DATA_WIDTH - 1 : 0] sr1_3 = sr1[3];
  wire signed [DATA_WIDTH - 1 : 0] sr1_4 = sr1[4];
  wire signed [DATA_WIDTH - 1 : 0] sr1_5 = sr1[5];
  wire signed [DATA_WIDTH - 1 : 0] sr1_6 = sr1[6];
  wire signed [DATA_WIDTH - 1 : 0] sr1_7 = sr1[7];

  wire signed [DATA_WIDTH - 1 : 0] sr2_0 = sr2[0];
  wire signed [DATA_WIDTH - 1 : 0] sr2_1 = sr2[1];
  wire signed [DATA_WIDTH - 1 : 0] sr2_2 = sr2[2];
  wire signed [DATA_WIDTH - 1 : 0] sr2_3 = sr2[3];
  wire signed [DATA_WIDTH - 1 : 0] sr2_4 = sr2[4];
  wire signed [DATA_WIDTH - 1 : 0] sr2_5 = sr2[5];
  wire signed [DATA_WIDTH - 1 : 0] sr2_6 = sr2[6];
  wire signed [DATA_WIDTH - 1 : 0] sr2_7 = sr2[7];


  always @(posedge clk or negedge rstn)
  begin
    if(!rstn)
    begin
      for (i = 0; i < NB_OF_REGS; i++)
      begin
        sr1[i] <= PT1000MS;
        sr2[i] <= PT1000MS;
      end

      rravg1 = PT1000MS << 3;
      rravg2 = PT1000MS << 3;
      regular = REGULAR_HR;
      rrlow = RR92PERCENT;
      rrhigh = RR116PERCENT;
      rrmiss = RR166PERCENT;
    end
    else if (rstn && en)
    begin
      if (rru == 1)
      begin
        sr1[0] <= rr_interval;
        for ( i = 0; i < NB_OF_REGS - 1; i++)
          sr1[i + 1] <= sr1[i];
        
        rravg1 = rr_interval;
        for (i = 1; i < NB_OF_REGS - 2; i++)
          rravg1 = rravg1 + sr1[i];
        rravg1 = rravg1 / NB_OF_REGS;

        if (rr_interval >= rrlow && rr_interval <= rrhigh)
        begin
          sr2[0] <= rr_interval;
          for ( i = 0; i < NB_OF_REGS - 2; i++)
            sr2[i + 1] <= sr2[i];
          
          rravg2 = rr_interval;
          for (i = 1; i < NB_OF_REGS - 2; i++)
            rravg2 = rravg2 + sr2[i];
          rravg2 = rravg2 / NB_OF_REGS;

          rrlow = 0.92 * rravg1;
          rrhigh = 1.16 * rravg1;
          rrmiss = 1.66 * rravg2;

          regular = REGULAR_HR;
        end
        else
        begin
          rrmiss = 1.66 * rravg1;
          regular = IRREGULAR_HR;
        end
      end
      else
      begin
        regular = REGULAR_HR;
      end
    end
  end

endmodule