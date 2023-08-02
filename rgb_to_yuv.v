// ///////////////////////////////////////////////////////////////////////////
module rgb_to_yuv
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

   wire signed [DATA_WIDTH+FRAC_WIDTH-1:0] Rint_fp, Gint_fp, Bint_fp;

//RGB to YUV Adjustments and calculations
// Adjust widths of components based on frac bits and input width
   assign Rint_fp = $signed({data_in1, {FRAC_WIDTH{1'b0}}});
   assign Gint_fp = $signed({data_in2, {FRAC_WIDTH{1'b0}}});
   assign Bint_fp = $signed({data_in3, {FRAC_WIDTH{1'b0}}});
// Conversion calculations using fixed-point arithmetic
   assign data_out1 = ((19595 * Rint_fp + 38470 * Gint_fp + 7471 * Bint_fp + (1 << (FRAC_WIDTH - 1))) >>> FRAC_WIDTH);
   assign data_out2 = ((-11056 * Rint_fp - 21712 * Gint_fp + 32768 * Bint_fp + (1 << (FRAC_WIDTH - 1))) >>> FRAC_WIDTH);
   assign data_out3 = ((32768 * Rint_fp - 27440 * Gint_fp - 5328 * Bint_fp + (1 << (FRAC_WIDTH - 1))) >>> FRAC_WIDTH);
  
endmodule

