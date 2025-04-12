module integration
    #(parameter DATA_WIDTH = 16)
    (
        input rstn,
        input en,
        input clk,
        input [DATA_WIDTH - 1 : 0] xin,
        output [DATA_WIDTH - 1 : 0] yout
    );

    parameter WINDOW_SIZE = 30;

    reg signed [DATA_WIDTH - 1 : 0] xn [WINDOW_SIZE - 1 : 0];
    reg signed [2 * DATA_WIDTH - 1 : 0] sum;

    integer i;

    wire [DATA_WIDTH - 1 : 0] xn0 = xn[0];
    wire [DATA_WIDTH - 1 : 0] xn1 = xn[1];
    wire [DATA_WIDTH - 1 : 0] xn2 = xn[2];
    wire [DATA_WIDTH - 1 : 0] xn3 = xn[3];
    wire [DATA_WIDTH - 1 : 0] xn4 = xn[4];
    wire [DATA_WIDTH - 1 : 0] xn5 = xn[5];
    wire [DATA_WIDTH - 1 : 0] xn6 = xn[6];
    wire [DATA_WIDTH - 1 : 0] xn7 = xn[7];
    wire [DATA_WIDTH - 1 : 0] xn8 = xn[8];
    wire [DATA_WIDTH - 1 : 0] xn9 = xn[9];
    wire [DATA_WIDTH - 1 : 0] xn10 = xn[10];
    wire [DATA_WIDTH - 1 : 0] xn11 = xn[11];
    wire [DATA_WIDTH - 1 : 0] xn12 = xn[12];
    wire [DATA_WIDTH - 1 : 0] xn13 = xn[13];
    wire [DATA_WIDTH - 1 : 0] xn14 = xn[14];
    wire [DATA_WIDTH - 1 : 0] xn15 = xn[15];
    wire [DATA_WIDTH - 1 : 0] xn16 = xn[16];
    wire [DATA_WIDTH - 1 : 0] xn17 = xn[17];
    wire [DATA_WIDTH - 1 : 0] xn18 = xn[18];
    wire [DATA_WIDTH - 1 : 0] xn19 = xn[19];
    wire [DATA_WIDTH - 1 : 0] xn20 = xn[20];
    wire [DATA_WIDTH - 1 : 0] xn21 = xn[21];
    wire [DATA_WIDTH - 1 : 0] xn22 = xn[22];
    wire [DATA_WIDTH - 1 : 0] xn23 = xn[23];
    wire [DATA_WIDTH - 1 : 0] xn24 = xn[24];
    wire [DATA_WIDTH - 1 : 0] xn25 = xn[25];
    wire [DATA_WIDTH - 1 : 0] xn26 = xn[26];
    wire [DATA_WIDTH - 1 : 0] xn27 = xn[27];
    wire [DATA_WIDTH - 1 : 0] xn28 = xn[28];
    wire [DATA_WIDTH - 1 : 0] xn29 = xn[29];


    always @(posedge clk or negedge rstn)
    begin
      if (!rstn)
      begin
        for (i = 0; i < WINDOW_SIZE; i++)
          xn[i] <= 0;
        sum = 0;
      end
      else if (rstn && en)
      begin
        xn[0] <= xin;
        for (i = 0; i < WINDOW_SIZE; i++)
          xn[i + 1] <= xn[i];

        sum = xin;
        for (i = 0; i < WINDOW_SIZE - 1; i++)
          sum = sum + xn[i];
          
        sum = sum / WINDOW_SIZE;
        
      end
    end

    assign yout = (rstn && en) ? sum[DATA_WIDTH - 1 : 0] : {DATA_WIDTH{1'b0}};

endmodule
