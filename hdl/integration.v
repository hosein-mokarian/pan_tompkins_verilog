module integration
    #(parameter DATA_WIDTH = 11)
    (
        input clk,
        input rstn,
        input en,
        input [DATA_WIDTH - 1 : 0] data,
        output [DATA_WIDTH - 1 : 0] out
    )

    #parameter WINDOW_SIZE = 20;

endmodule
