module squared
    #(parameter DATA_WIDTH = 11)
    (
        input clk,
        input rstn,
        input en,
        input [DATA_WIDTH - 1 : 0] data,
        output [DATA_WIDTH - 1 : 0] out
    )

    integer i;

    reg [2 * (DATA_WIDTH - 1) : 0] mul;

    always @(posedge clk)
    begin
        if (!rstn)
            mul <= 0;
        else
            if (en)
                mul <= data * data;
    end

    assign out = (rstn & en) ? mul[19 : 9] : 11`b0;

endmodule
