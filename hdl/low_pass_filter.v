module low_pas_filter
    #(parameter DATA_WIDTH = 11)
    (
        input clk,
        input rstn,
        input en,
        input [DATA_WIDTH - 1 : 0] data,
        output [DATA_WIDTH - 1 : 0] out
    )

    #parameter NB_OF_X_REG = 12;
    #parameter NB_OF_Y_REG = 3;

    integer i;

    reg [DATA_WIDTH - 1 : 0] xn [NB_OF_X_REG - 1 : 0];
    reg [DATA_WIDTH - 1 : 0] yn [NB_OF_Y_REG - 1 : 0];

    always @(posedge clk)
    begin
        if (!rstn)
        begin
            for (i = 0; i < NB_OF_X_REG; i++)
                xn[i] <= 0;
            for (i = 0; i < NB_OF_Y_REG; i++)
                yn[i] <= 0;
        end
        else
            if (en)
            begin
                for (i = NB_OF_X_REG - 2; i > 0; i--)
                    xn[i + 1] <= xn[i];
                for (i = NB_OF_Y_REG - 2; i > 0; i--)
                    yn[i + 1] <= yn[i];
            end 
    end

    always @(posedge clk)
    begin
        if (rstn & en)
        begin
            xn[0] <= data;
            yn[0] <= (2 * yn[1]) - yn[2] + xn[0] - (2 * xn[6]) + xn[12]; 
        end
    end

    assign out = (rstn & en) ? yn[0] : 11`b0;

endmodule
