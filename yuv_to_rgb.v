// ///////////////////////////////////////////////////////////////////////////
module yuv_to_rgb
    #(parameter DATA_WIDTH=8,
      parameter FRAC_WIDTH=8)
(
   input [DATA_WIDTH-1:0] data_in1,
   input [DATA_WIDTH-1:0] data_in2,
   input [DATA_WIDTH-1:0] data_in3,

   output signed [DATA_WIDTH+FRAC_WIDTH-1:0] data_out1,
   output signed [DATA_WIDTH+FRAC_WIDTH-1:0] data_out2,
   output signed [DATA_WIDTH+FRAC_WIDTH-1:0] data_out3

);

   wire signed [DATA_WIDTH+FRAC_WIDTH-1:0] Yint_fp, Uint_fp, Vint_fp;
   wire signed [DATA_WIDTH+FRAC_WIDTH-1:0] Cb_temp, Cr_temp;

//YUV to RGB Adjustments and calculations
// Adjust widths of components based on frac bits and input width
   assign Yint_fp = $signed({data_in1, {FRAC_WIDTH{1'b0}}});
   assign Uint_fp = $signed({data_in2, {FRAC_WIDTH{1'b0}}});
   assign Vint_fp = $signed({data_in3, {FRAC_WIDTH{1'b0}}});

   assign  Cb_temp = Uint_fp - (1 << (DATA_WIDTH-1));
   assign  Cr_temp = Vint_fp - (1 << (DATA_WIDTH-1));

   assign data_out1 = (Yint_fp + (91881 * Cr_temp + (1 << (FRAC_WIDTH - 1))) >>> FRAC_WIDTH);
   assign data_out2 = (Yint_fp - (22544 * Cb_temp + 46802 * Cr_temp + (1 << (FRAC_WIDTH - 1))) >>> FRAC_WIDTH);
   assign data_out3 = (Yint_fp + (116130 * Cb_temp + (1 << (FRAC_WIDTH - 1))) >>> FRAC_WIDTH);
  
endmodule

