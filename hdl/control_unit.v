module control_unit
  #(
    parameter DATA_WIDTH = 16,
    parameter PT360MS = 350
  )
  (
    input rstn,
    input en,
    input clk,
    input signed [DATA_WIDTH - 1 : 0] peak_i,
    input signed [DATA_WIDTH - 1 : 0] peak_f,
    input signed [DATA_WIDTH - 1 : 0] thri_1,
    input signed [DATA_WIDTH - 1 : 0] thri_2,
    input signed [DATA_WIDTH - 1 : 0] thrf_1,
    input signed [DATA_WIDTH - 1 : 0] thrf_2,
    input signed [DATA_WIDTH - 1 : 0] rrmiss,
    input peak_i_flag,
    input peak_f_validation,
    input s200ms_flag,
    input s360ms_flag,
    input [DATA_WIDTH - 1 : 0] slope,
    input [DATA_WIDTH - 1 : 0] last_slope,
    input [DATA_WIDTH - 1 : 0] rr_interval,
    input timer_2s_update_flag,
    output reg timer_2s_trigger,
    output reg signed [DATA_WIDTH - 1 : 0] peak_i_max,
    output reg signed [DATA_WIDTH - 1 : 0] peak_i_mean,
    output reg signed [DATA_WIDTH - 1 : 0] peak_f_max,
    output reg signed [DATA_WIDTH - 1 : 0] peak_f_mean,
    output reg init_thrs,
    output reg load,
    output reg [DATA_WIDTH - 1 : 0] preset_value,
    output reg signed [DATA_WIDTH - 1 : 0] peak_i_sb,
    output reg signed [DATA_WIDTH - 1 : 0] peak_f_sb,
    output reg npu,
    output reg spu,
    output reg rru,
    output reg search_back,
    output reg t_wave
  );

  parameter STATE_START_UP          = 2'd0;
  parameter STATE_LEARNING_PHASE_1  = 2'd1;
  parameter STATE_LEARNING_PHASE_2  = 2'd2;
  parameter STATE_DETECTION         = 2'd3;

  reg [1 : 0] state;
  reg [1 : 0] rr_counter;
  reg [DATA_WIDTH - 1 : 0] last_rr_interval;
  reg signed [DATA_WIDTH - 1 : 0] peak_f_best;


  always @(posedge clk or negedge rstn)
  begin
    if (!rstn)
    begin
      init_thrs <= 0;
      load <= 0;
      preset_value <= 0;
      npu <= 0;
      spu <= 0;
      rru <= 0;
      search_back <= 0;
      t_wave <= 0;
      state <= STATE_START_UP;
      timer_2s_trigger <= 0;
      rr_counter <= 0;
      peak_i_max <= 0;
      peak_i_mean <= 0;
      peak_f_max <= 0;
      peak_f_mean <= 0;
      last_rr_interval <= 0;
      peak_f_best <= 0;
      peak_i_sb <= 0;
      peak_f_sb <= 0;
    end
    else if (rstn && en)
    begin
        if (peak_f_validation == 1)
          peak_f_best <= peak_f;
        
        case(state)
          STATE_START_UP:
          begin
            if (s200ms_flag == 1)
            begin
              peak_i_max <= peak_i;
              peak_i_mean <= peak_i;
              // if (peak_f_best > peak_f_max)
              //   peak_f_max <= peak_f_best;
              peak_f_max <= peak_f_best;
              peak_f_mean <= peak_f_best;

              state <= STATE_LEARNING_PHASE_1;
              timer_2s_trigger <= 1;
              rr_counter <= 0;
            end

            // if (peak_i_flag)
            // begin
            //   // todo
            // end
          end
          STATE_LEARNING_PHASE_1:
          begin
            timer_2s_trigger <= 0;

            if (s200ms_flag == 1)
            begin
              if (peak_i > peak_i_max)
                  peak_i_max <= peak_i;
              if (peak_f_best > peak_f_max)
                  peak_f_max <= peak_f_best;

              peak_i_mean <= (peak_i_mean + peak_i) >> 1;
              peak_f_mean <= (peak_f_mean + peak_f_best) >> 1;
            end

            if (timer_2s_update_flag == 1)
            begin
              init_thrs <= 1;
              state <= STATE_LEARNING_PHASE_2;
            end
          end
          STATE_LEARNING_PHASE_2:
          begin
            init_thrs <= 0;

            if (s200ms_flag == 1)
            begin
              if (peak_i > thri_1 && peak_f_best > thrf_1)
              begin
                spu <= 1;
              end
              else
              begin
                npu <= 1;
                //---> todo: update search-back
                load <= 1;
              end

              rr_counter <= rr_counter + 1;
            end
            else
            begin
              if (spu == 1)
                spu <= 0;
              if (npu == 1)
                npu <= 0;
              if (load == 1)
                load <= 0;
            end
            
            if (rr_counter == 2)
            begin
              rr_counter <= 0;
              state <= STATE_DETECTION;
            end

            // if (peak_i_flag)
            // begin
            //   // todo
            // end
          end
          STATE_DETECTION:
          begin
            if (s200ms_flag == 1)
            begin
              if (peak_i >= thri_1 && peak_f_best >= thrf_1)
              begin
                // if (s200ms_flag == 0)
                // begin
                //   npu <= 1;
                //   spu <= 0;
                //   rru <= 0;
                //   search_back <= 0;
                // end
                if (s200ms_flag == 1 && s360ms_flag == 0)
                begin
                  if (slope < last_slope / 2)
                  begin
                    npu <= 1;
                    spu <= 0;
                    rru <= 0;
                    t_wave <= 1; // todo:
                    // search_back <= 1 // todo:
                    // load <= 1; // todo:
                  end
                  else
                  begin
                    npu <= 0;
                    spu <= 1;
                    rru <= 1;
                    search_back <= 0;
                    peak_i_sb <= 0;
                    peak_f_sb <= 0;
                  end
                end
                else if (s200ms_flag == 0 && s360ms_flag == 1)
                begin
                  npu <= 0;
                  spu <= 1;
                  rru <= 1;
                  search_back <= 0;
                end
              end
              else
              begin
                npu <= 1;
                spu <= 0;
                rru <= 0;

                if (peak_i > peak_i_sb && rr_interval >= PT360MS)
                begin
                  search_back <= 1; //--- todo:
                  // load <= 1; //--- todo:
                  last_rr_interval <= rr_interval;
                  peak_i_sb <= peak_i;
                  peak_f_sb <= peak_f_best;
                end
              end
            end
            else
            begin
              if (spu == 1)
                spu <= 0;
              if (npu == 1)
                npu <= 0;
              if (rru == 1)
                rru <= 0;
              if (search_back == 1)
                search_back <= 0;
              if (t_wave == 1)
                t_wave <= 0;
              if (load == 1)
                load <= 0;
            end
            //---
            // search back
            if (rr_interval > rrmiss)
            begin
              if (peak_i_sb >= thri_2 && peak_f_sb >= thrf_2)
              begin
                npu <= 0;
                spu <= 1;
                rru <= 1;
                load <= 1;
                preset_value <= last_rr_interval;
                peak_i_sb <= 0;
                peak_f_sb <= 0;
              end
            end
            //---
          end
        endcase

        if (load == 1)
          load <= 0;
    end
  end

endmodule