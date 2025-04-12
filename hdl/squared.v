module squared
    #(parameter DATA_WIDTH = 16)
    (
        input rstn,
        input en,
        input clk,
        input signed [DATA_WIDTH - 1 : 0] xin,
        output signed [DATA_WIDTH - 1 : 0] yout
    );

    integer i;

    reg signed [2 * DATA_WIDTH - 1 : 0] mul;


    always @(posedge clk or negedge rstn)
    begin
        if (!rstn)
            mul <= 0;
        else
            if (rstn  && en)
                mul <= xin * xin;
    end

    assign yout = (rstn & en) ? mul[DATA_WIDTH - 1 : 0] : {DATA_WIDTH{1'b0}};

endmodule
