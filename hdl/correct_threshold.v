module correct_threshould
  #(parameter DATA_WIDTH = 16)
  (
    input rstn,
    input en,
    input clk,
    input signed [DATA_WIDTH - 1 : 0] peak_i,
    input signed [DATA_WIDTH - 1 : 0] peak_f,
    input signed [DATA_WIDTH - 1 : 0] peak_i_sb,
    input signed [DATA_WIDTH - 1 : 0] peak_f_sb,
    input signed [DATA_WIDTH - 1 : 0] peak_i_max,
    input signed [DATA_WIDTH - 1 : 0] peak_i_mean,
    input signed [DATA_WIDTH - 1 : 0] peak_f_max,
    input signed [DATA_WIDTH - 1 : 0] peak_f_mean,
    input init,
    input peak_selector,
    input npu,
    input spu,
    input flag,
    output reg signed [DATA_WIDTH - 1 : 0] thri_1,
    output reg signed [DATA_WIDTH - 1 : 0] thri_2,
    output reg signed [DATA_WIDTH - 1 : 0] thrf_1,
    output reg signed [DATA_WIDTH - 1 : 0] thrf_2,
    output reg qrs
  );

  reg signed [DATA_WIDTH - 1 : 0] peak_i_selected;
  reg signed [DATA_WIDTH - 1 : 0] peak_f_selected;

  reg signed [DATA_WIDTH - 1: 0] npk_i;
  reg signed [DATA_WIDTH - 1: 0] spk_i;

  reg signed [DATA_WIDTH - 1: 0] npk_f;
  reg signed [DATA_WIDTH - 1: 0] spk_f;


  always @(posedge clk or negedge rstn)
  begin
    if (!rstn)
    begin
      peak_i_selected = 0;
      peak_f_selected = 0;
      npk_i = 0;
      spk_i = 0;
      npk_f = 0;
      spk_f = 0;
      thri_1 = 0;
      thri_2 = 0;
      thrf_1 = 0;
      thrf_2 = 0;
      qrs <= 0;
    end
    else if (rstn && en)
    begin
      if (peak_selector == 1)
      begin
        peak_i_selected = peak_i_sb;
        peak_f_selected = peak_f_sb;
      end
      else
      begin
        peak_i_selected = peak_i;
        peak_f_selected = peak_f;
      end

      if (qrs == 1)
        qrs <= 0;
      
      if (init == 1)
      begin
        spk_i = (peak_i_max >> 1);
        npk_i = (peak_i_mean >> 3);
        thri_1 = npk_i + ((spk_i - npk_i) >> 2);
        thri_2 = thri_1 >> 1;

        spk_f = (peak_f_max >> 1);
        npk_f = (peak_f_mean >> 3);
        thrf_1 = npk_f + ((spk_f - npk_f) >> 2);
        thrf_2 = thrf_1 >> 1;
      end

      if (npu == 1)
      begin
        npk_i = 0.125 * peak_i_selected + 0.875 * npk_i;
        npk_f = 0.125 * peak_f_selected + 0.875 * npk_f;
        // npk_i = 4 * peak_i_selected + 28 * npk_i;
        // npk_f = 4 * peak_f_selected + 28 * npk_f;
      end

      if (spu == 1)
      begin
        spk_i = 0.125 * peak_i_selected + 0.875 * spk_i;
        spk_f = 0.125 * peak_f_selected + 0.875 * spk_f;
        // spk_i = 4 * peak_i_selected + 28 * spk_i;
        // spk_f = 4 * peak_f_selected + 28 * spk_f;
        qrs <= 1;
      end

      if (spu == 1 || npu == 1)
      begin
        thri_1 = npk_i + 0.25 * (spk_i - npk_i);
        // thri_1 = npk_i + 8 * (spk_i - npk_i);
        thri_2 = 0.5 * thri_1; // 0.5 * thri_1;

        thrf_1 = npk_f + 0.25 * (spk_f - npk_f);
        // thrf_1 = npk_f + 8* (spk_f - npk_f);
        thrf_2 = 0.5 * thrf_1; // 0.5 * thrf_1;
      end

      if (flag == 1)
      begin
        thri_1 = thri_1 / 2;
				thrf_1 = thrf_1 / 2;
      end

    end
  end

endmodule