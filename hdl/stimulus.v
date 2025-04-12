`timescale 1ns/1ps

module stimulus;

  parameter DATA_WIDTH = 16;

  // Inputs
	reg clk;
	reg rstn;
	reg en;
	reg signed [DATA_WIDTH - 1 : 0] xin;

	// Outputs
	wire signed [DATA_WIDTH - 1 : 0] y;

	// Instantiate the Unit Under Test (UUT)
	top uut (
		.clk(clk),
		.rstn(rstn),
		.en(en),
		.xin(xin), 
		.y(y)
	);


  integer i = 1;
  integer fid_input_file, fid_output_file;


  initial
  begin

    fid_input_file  = $fopen("ecg.txt", "r");
    fid_output_file = $fopen("output.dat", "w");
    
    if (fid_input_file == 0) 
      begin
        $display("Error: Failed to open file \n Exiting Simulation.");
        $finish;
      end

    xin = 0;
    clk = 0;
    rstn = 0;
    en = 0;

    #5 rstn = 1;
    #5 en = 1;

    while (i > 0)
    begin
      @(negedge clk) 
      begin
        i = $fscanf(fid_input_file, "%d", xin);
      end
    end

    $fclose(fid_input_file);
    #10000;
    $display("Simulation ended normally");
    $finish;

  end


  initial 
		begin
			$dumpfile("qrs_results.vcd");
			$dumpvars(0, stimulus);
		end


  always
		#1 clk=~clk; 

endmodule