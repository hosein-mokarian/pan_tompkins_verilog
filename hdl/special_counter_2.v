module special_counter_2
  #(
    parameter DATA_WIDTH = 16,
    parameter PERIOD = 16'hFFFF
  )
  (
    input rstn,
    input en,
    input clk,
    input start,
    input load,
    input [DATA_WIDTH - 1 : 0] value,
    output [DATA_WIDTH - 1 : 0] counter_val
  );

  reg signed [31 : 0] counter;

  always @(posedge clk or negedge rstn)
  begin
    if (!rstn)
    begin
      counter <= 0;
    end
    else if (start)
    begin
      counter <= 1;
    end
    else if (load)
    begin
      counter <= value;
    end
    else if (rstn && en)
    begin
      if (counter == PERIOD)
        counter <= 0;
      else // (counter > 0 && counter < PERIOD)
        counter <= counter + 1;
    end
  end

  assign counter_val = (rstn && en) ? counter : {DATA_WIDTH{1'b0}};

endmodule