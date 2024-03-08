module derivative
    #(parameter DATA_WIDTH = 11)
    (
        input clk,
        input rstn,
        input en,
        input [DATA_WIDTH - 1 : 0] data,
        output [DATA_WIDTH - 1 : 0] out
    )

    #parameter NB_OF_X_REG = 2;

    integer i;

    reg [DATA_WIDTH - 1 : 0] xn [NB_OF_X_REG - 1 : 0];
    reg [DATA_WIDTH - 1 : 0] yn;

    always @(posedge clk)
    begin
        if (!rstn)
        begin
            for (i = 0; i < NB_OF_X_REG; i++)
                xn[i] <= 0;
        end
        else
            if (en)
            begin
                for (i = NB_OF_X_REG - 2; i > 0; i--)
                    xn[i + 1] <= xn[i];
            end 
    end

    always @(posedge clk)
    begin
        if (rstn & en)
        begin
            xn[0] <= data;
            yn <= xn[0] - x[1];
        end
    end

    assign out = (rstn & en) ? yn : 11`b0;

endmodule
