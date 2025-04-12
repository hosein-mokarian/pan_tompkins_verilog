module derivative
    #(parameter DATA_WIDTH = 16)
    (
        input rstn,
        input en,
        input clk,
        input signed [DATA_WIDTH - 1 : 0] xin,
        output signed [DATA_WIDTH - 1 : 0] yout
    );

    parameter NB_OF_X_REG = 2;

    integer i;

    reg signed [DATA_WIDTH - 1 : 0] xn [NB_OF_X_REG - 1 : 0];
    wire signed [DATA_WIDTH - 1 : 0] yn;

    wire [DATA_WIDTH - 1 : 0] xn0 = xn[0];
    wire [DATA_WIDTH - 1 : 0] xn1 = xn[1];


    always @(posedge clk or negedge rstn)
    begin
        if (!rstn)
        begin
            for (i = 0; i < NB_OF_X_REG; i++)
                xn[i] <= 0;
        end
        else
            if (rstn && en)
            begin
                for (i = 0; i < NB_OF_X_REG - 1; i++)
                    xn[i + 1] <= xn[i];
                
                xn[0] <= xin;
                // yn <= xn[0] - xn[1];
            end 
    end

    assign yn = xn[0] - xn[1];

    assign yout = (rstn & en) ? yn : {DATA_WIDTH{1'b0}};

endmodule
