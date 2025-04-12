module high_pass_filter
    #(parameter DATA_WIDTH = 16)
    (
        input rstn,
        input en,
        input clk,
        input signed [DATA_WIDTH - 1 : 0] xin,
        output signed [DATA_WIDTH - 1 : 0] yout
    );

    parameter NB_OF_X_REG = 33;
    parameter NB_OF_Y_REG = 1; // 2

    integer i;

    reg signed [DATA_WIDTH - 1 : 0] xn [NB_OF_X_REG - 1 : 0];
    reg signed [DATA_WIDTH - 1 : 0] yn [NB_OF_Y_REG - 1 : 0];

    wire signed [2 * DATA_WIDTH - 1 : 0] y;

    // Expose individual sr elements as wires for debugging
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
    wire [DATA_WIDTH - 1 : 0] xn30 = xn[30];
    wire [DATA_WIDTH - 1 : 0] xn31 = xn[31];
    wire [DATA_WIDTH - 1 : 0] xn32 = xn[32];

    wire [DATA_WIDTH - 1 : 0] yn0 = yn[0];
    // wire [DATA_WIDTH - 1 : 0] yn1 = yn[1];


    always @(posedge clk or negedge rstn)
    begin
        if (!rstn)
        begin
            for (i = 0; i < NB_OF_X_REG; i++)
                xn[i] <= 0;
            for (i = 0; i < NB_OF_Y_REG; i++)
                yn[i] <= 0;
        end
        else
            if (rstn && en)
            begin
                for (i = 0; i < NB_OF_X_REG - 1; i++)
                    xn[i + 1] <= xn[i];
                for (i = 0; i < NB_OF_Y_REG - 1; i++)
                    yn[i + 1] <= yn[i];
                
                xn[0] <= xin;
                yn[0] <= y[DATA_WIDTH - 1 + 5 : 5];
            end 
    end

    assign y = (32 * xn[15]) - yn[0] - xn[0] + xn[31];

    assign yout = (rstn & en) ? y[DATA_WIDTH - 1 + 5 : 5] : {DATA_WIDTH{1'b0}};

endmodule
