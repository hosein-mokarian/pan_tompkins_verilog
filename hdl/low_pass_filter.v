module low_pass_filter
    #(parameter DATA_WIDTH = 16)
    (
        input rstn,
        input en,
        input clk,
        input signed [DATA_WIDTH - 1 : 0] xin,
        output signed [DATA_WIDTH - 1 : 0] yout
    );

    parameter NB_OF_X_REG = 13;
    parameter NB_OF_Y_REG = 2; // 3

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

    wire [DATA_WIDTH - 1 : 0] yn0 = yn[0];
    wire [DATA_WIDTH - 1 : 0] yn1 = yn[1];
    // wire [DATA_WIDTH - 1 : 0] yn2 = yn[2];


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

    assign y = (2 * yn[0]) - yn[1] + xn[0] - (2 * xn[5]) + xn[11];

    assign yout = (rstn & en) ? y[DATA_WIDTH - 1 + 3 : 3] : {DATA_WIDTH{1'b0}};

endmodule
