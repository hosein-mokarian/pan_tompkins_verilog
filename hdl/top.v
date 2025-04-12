`include "low_pass_filter.v"
`include "high_pass_filter.v"
`include "derivative.v"
`include "squared.v"
`include "integration.v"
`include "slope.v"
`include "shift_register.v"
`include "peak_detector.v"
`include "special_counter.v"
`include "special_counter_2.v"
`include "control_unit.v"
`include "correct_threshold.v"
`include "rr_update.v"


module top
    #(parameter DATA_WIDTH = 16)
    (
        input clk,
        input rstn,
        input en,
        input [DATA_WIDTH - 1 : 0] xin,
        output y
    );

    parameter PT150MS = 30;
    parameter PT200MS = 40;
    parameter PT160MS = 32;
    parameter PT360MS = 72;
    parameter PT1000MS = 200;
    parameter PT2000MS = 400;
    parameter PT4000MS = 800;

    wire signed [DATA_WIDTH - 1 : 0] lpf_out;
    wire signed [DATA_WIDTH - 1 : 0] hpf_out;
    wire signed [DATA_WIDTH - 1 : 0] sr_out;
    wire signed [DATA_WIDTH - 1 : 0] deriv_out;
    wire signed [DATA_WIDTH - 1 : 0] squared_out;
     wire signed [DATA_WIDTH - 1 : 0] sr_out_2;
    wire signed [DATA_WIDTH - 1 : 0] integral_out;

    wire [DATA_WIDTH - 1 : 0] slope_out;
    wire [DATA_WIDTH - 1 : 0] last_slope;

    wire signed [DATA_WIDTH - 1 : 0] peak_i;
    wire signed [DATA_WIDTH - 1 : 0] peak_i_max;
    wire signed [DATA_WIDTH - 1 : 0] peak_i_mean;
    wire sc200_start;
    wire sc200_activation;
    wire sc200_flag;

    wire sc200_f_activation;
    wire sc200_f_flag;

    wire timer_360ms_update_flag;
    wire timer_360ms_activation;  

    wire timer_2s_update_flag;
    wire timer_2s_trigger;
    wire timer_2s_activation;
    wire init_thrs;

    wire signed [DATA_WIDTH - 1 : 0] peak_f;
    wire signed [DATA_WIDTH - 1 : 0] peak_f_max;
    wire signed [DATA_WIDTH - 1 : 0] peak_f_mean;
    wire peak_f_flag;

    wire [DATA_WIDTH - 1 : 0] rr_interval;

    wire qrs;
    wire signed [DATA_WIDTH - 1 : 0] rrmiss;

    wire signed [DATA_WIDTH - 1 : 0] thri_1;
    wire signed [DATA_WIDTH - 1 : 0] thrf_1;
    wire signed [DATA_WIDTH - 1 : 0] thri_2;
    wire signed [DATA_WIDTH - 1 : 0] thrf_2;
   
    wire npu;
    wire spu;
    wire rru;
    wire search_back;
    wire t_wave;

    wire load;
    wire [DATA_WIDTH - 1 : 0] preset_value;
    wire signed [DATA_WIDTH - 1 : 0] peak_i_sb;
    wire signed [DATA_WIDTH - 1 : 0] peak_f_sb;

    wire regular;


    low_pass_filter 
    #(
      .DATA_WIDTH(DATA_WIDTH)
    )
    LPF
    (
      .rstn(rstn),
      .en(en),
      .clk(clk),
      .xin(xin),
      .yout(lpf_out)
    );


    high_pass_filter
    #(
      .DATA_WIDTH(DATA_WIDTH)
    )
    HPF
    (
      .rstn(rstn),
      .en(en),
      .clk(clk),
      .xin(lpf_out),
      .yout(hpf_out)
    );


    shift_register
    #(
      .DATA_WIDTH(DATA_WIDTH),
      .NB_OF_REGS(3)
    )
    SR_1
    (
      .rstn(rstn),
      .en(en),
      .clk(clk),
      .xin(hpf_out),
      .yout(sr_out)
    );


    derivative
    #(
      .DATA_WIDTH(DATA_WIDTH)
    )
    DERIV
    (
      .rstn(rstn),
      .en(en),
      .clk(clk),
      .xin(hpf_out),
      .yout(deriv_out)
    );


    squared
    #(
      .DATA_WIDTH(DATA_WIDTH)
    )
    SQR
    (
      .rstn(rstn),
      .en(en),
      .clk(clk),
      .xin(deriv_out),
      .yout(squared_out)
    );

    shift_register
    #(
      .DATA_WIDTH(DATA_WIDTH),
      .NB_OF_REGS(1)
    )
    SR_2
    (
      .rstn(rstn),
      .en(en),
      .clk(clk),
      .xin(squared_out),
      .yout(sr_out_2)
    );


    integration
    #(
      .DATA_WIDTH(DATA_WIDTH)
    )
    MWI
    (
      .rstn(rstn),
      .en(en),
      .clk(clk),
      .xin(squared_out),
      .yout(integral_out)
    );


    slope
    #(
      .DATA_WIDTH(DATA_WIDTH)
    )
    SL
    (
      .rstn(rstn),
      .en(en),
      .clk(clk),
      .xin(sr_out_2),
      .last_slope(last_slope),
      .yout(slope_out)
    );


    peak_detector
    #(
      .DATA_WIDTH(DATA_WIDTH)
    )
    PDF
    (
      .rstn(rstn),
      .en(en),
      .clk(clk),
      .xin(sr_out),
      .timer_activation(sc200_f_activation),
      .yout(peak_f),
      .flag(peak_f_flag)
    );

    special_counter
    #(
      .PERIOD(PT200MS)
    )
    SC_200ms_f
    (
      .rstn(rstn),
      .en(en),
      .clk(clk),
      .start(peak_f_flag),
      .flag(sc200_f_flag),
      .active(sc200_f_activation)
    );


    peak_detector
    #(
      .DATA_WIDTH(DATA_WIDTH)
    )
    PDI
    (
      .rstn(rstn),
      .en(en),
      .clk(clk),
      .xin(integral_out),
      .timer_activation(sc200_activation),
      .yout(peak_i),
      .flag(sc200_start)
    );


    special_counter
    #(
      .PERIOD(PT200MS)
    )
    SC_200ms
    (
      .rstn(rstn),
      .en(en),
      .clk(clk),
      .start(sc200_start),
      .flag(sc200_flag),
      .active(sc200_activation)
    );


    control_unit
    #(
      .DATA_WIDTH(DATA_WIDTH),
      .PT360MS(PT360MS)
    )
    CU_1
    (
      .rstn(rstn),
      .en(en),
      .clk(clk),
      .peak_i(peak_i),
      .peak_f(peak_f),
      .thri_1(thri_1),
      .thri_2(thri_2),
      .thrf_1(thrf_1),
      .thrf_2(thrf_2),
      .rrmiss(rrmiss),
      .peak_i_flag(sc200_start),
      .peak_f_validation(sc200_f_flag),
      .s200ms_flag(sc200_flag),
      .s360ms_flag(timer_360ms_update_flag),
      .slope(slope_out),
      .last_slope(last_slope),
      .rr_interval(rr_interval),
      .timer_2s_update_flag,
      .timer_2s_trigger,
      .peak_i_max(peak_i_max),
      .peak_i_mean(peak_i_mean),
      .peak_f_max(peak_f_max),
      .peak_f_mean(peak_f_mean),
      .init_thrs(init_thrs),
      .load(load),
      .preset_value(preset_value),
      .peak_i_sb(peak_i_sb),
      .peak_f_sb(peak_f_sb),
      .npu(npu),
      .spu(spu),
      .rru(rru),
      .search_back(search_back),
      .t_wave(t_wave)
    );


    special_counter
    #(
      .PERIOD(PT2000MS)
    )
    SC_2000s
    (
      .rstn(rstn),
      .en(en),
      .clk(clk),
      .start(timer_2s_trigger),
      .flag(timer_2s_update_flag),
      .active(timer_2s_activation)
    );


    special_counter
    #(
      .PERIOD(PT160MS)
    )
    SC_360ms
    (
      .rstn(rstn),
      .en(en),
      .clk(clk),
      .start(sc200_flag),
      .flag(timer_360ms_update_flag),
      .active(timer_360ms_activation)
    );


    special_counter_2
    #(
      .DATA_WIDTH(DATA_WIDTH),
      .PERIOD(16'hFFFF)
    )
    SC2_count_rr_interval
    (
      .rstn(rstn),
      .en(en),
      .clk(clk),
      .start(spu),
      .load(load),
      .value(preset_value),
      .counter_val(rr_interval)
    );


  correct_threshould
  #(
    .DATA_WIDTH(DATA_WIDTH)
  )
  UP
  (
    .rstn(rstn),
    .en(en),
    .clk(clk),
    .peak_i(peak_i),
    .peak_f(peak_f),
    .peak_i_sb(peak_i_sb),
    .peak_f_sb(peak_f_sb),
    .peak_i_max(peak_i_max),
    .peak_i_mean(peak_i_mean),
    .peak_f_max(peak_f_max),
    .peak_f_mean(peak_f_mean),
    .init(init_thrs),
    .peak_selector(load),
    .npu(npu),
    .spu(spu),
    .flag(regular),
    .thri_1(thri_1),
    .thri_2(thri_2),
    .thrf_1(thrf_1),
    .thrf_2(thrf_2),
    .qrs(qrs)
  );


  rr_update
  #(
    .DATA_WIDTH(DATA_WIDTH)
  )
  rr_u
  (
    .rstn(rstn),
    .en(en),
    .clk(clk),
    .rru(rru),
    .rr_interval(rr_interval),
    .rrmiss(rrmiss),
    .regular(regular)
  );


  assign y = (rstn | en) ? (load | spu) : 0;

endmodule
