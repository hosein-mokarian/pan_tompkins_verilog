`include "low_pass_filter.v"
`include "high_pass_filter.v"
`include "derivative.v"
`include "squared.v"
`include "integration.v"


module top
    #(parameter DATA_WIDTH = 11)
    (
        input clk,
        input rstn,
        input en,
        input [DATA_WIDTH - 1 : 0] xin,
        output [DATA_WIDTH - 1 : 0] y
    )

    

endmodule
