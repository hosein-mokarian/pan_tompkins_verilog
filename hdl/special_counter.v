module special_counter
  #(
    parameter PERIOD = 200
  )
  (
    input rstn,
    input en,
    input clk,
    input start,
    output reg flag,
    output active
  );

  reg signed [31 : 0] counter;

  always @(posedge clk or negedge rstn)
  begin
    if (!rstn)
    begin
      counter <= 0;
      flag <= 0;
    end
    else if (start)
    begin
      counter <= 1;
      flag <= 0;
    end
    else if (rstn && en)
    begin
      if (counter == 0)
        flag <= 0;
      else if (counter == PERIOD)
      begin
        counter <= 0;
        flag <= 1;
      end
      else // (counter > 0 && counter < PERIOD)
        counter <= counter + 1;
    end
  end

  assign active = (rstn && en) ? ((counter != 0) ? 1 : 0) : 0;

endmodule