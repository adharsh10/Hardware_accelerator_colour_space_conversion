// ///////////////////////////////////////////////////////////////////////////
module hsv_to_rgb
    #(parameter DATA_WIDTH=8,
      parameter FRAC_WIDTH=8)
(
   input [DATA_WIDTH-1:0] data_in1,
   input [DATA_WIDTH-1:0] data_in2,
   input [DATA_WIDTH-1:0] data_in3,

   output reg signed [DATA_WIDTH+FRAC_WIDTH-1:0] data_out1,
   output reg signed [DATA_WIDTH+FRAC_WIDTH-1:0] data_out2,
   output reg signed [DATA_WIDTH+FRAC_WIDTH-1:0] data_out3

);

   wire signed [DATA_WIDTH+FRAC_WIDTH-1:0] Hint_fp, Sint_fp, Vint_fp;

   reg signed [DATA_WIDTH+FRAC_WIDTH-1:0] C, X, m;
  
  always @* begin
    C = (Vint_fp * Sint_fp) >>> FRAC_WIDTH;
    //X = (C * (1 - (abs((Hint_fp / (60 << FRAC_WIDTH)) % 2 - 1) << FRAC_WIDTH))) >>> FRAC_WIDTH;
    X = (C * (1 - (((Hint_fp / (60 << FRAC_WIDTH)) % 2) << FRAC_WIDTH) - (1 << FRAC_WIDTH))) >>> FRAC_WIDTH;
    m = Vint_fp - C;

    if (Hint_fp < (60 << FRAC_WIDTH)) begin
      data_out1 = C + m;
      data_out2 = X + m;
      data_out3 = m;
    end else if (Hint_fp < (120 << FRAC_WIDTH)) begin
      data_out1 = X + m;
      data_out2 = C + m;
      data_out3 = m;
    end else if (Hint_fp < (180 << FRAC_WIDTH)) begin
      data_out1 = m;
      data_out2 = C + m;
      data_out3 = X + m;
    end else if (Hint_fp < (240 << FRAC_WIDTH)) begin
      data_out1 = m;
      data_out2 = X + m;
      data_out3 = C + m;
    end else if (Hint_fp < (300 << FRAC_WIDTH)) begin
      data_out1 = X + m;
      data_out2 = m;
      data_out3 = C + m;
    end else begin
      data_out1 = C + m;
      data_out2 = m;
      data_out3 = X + m;
    end

endmodule

