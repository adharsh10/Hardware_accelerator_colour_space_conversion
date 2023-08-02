// ///////////////////////////////////////////////////////////////////////////
module rgb_to_hsv
    #(parameter DATA_WIDTH=8,
      parameter FRAC_WIDTH=8)
(
   input [DATA_WIDTH-1:0] data_in1,
   input [DATA_WIDTH-1:0] data_in2,
   input [DATA_WIDTH-1:0] data_in3,

   output reg signed [DATA_WIDTH+FRAC_WIDTH-1:0] data_out1,
   output reg signed [DATA_WIDTH+FRAC_WIDTH-1:0] data_out2,
   output reg signed [DATA_WIDTH+FRAC_WIDTH-1:0] data_out3

)
   wire signed [DATA_WIDTH+FRAC_WIDTH-1:0] Rint_fp, Gint_fp, Bint_fp;
   reg signed [DATA_WIDTH+FRAC_WIDTH-1:0] Cmax, Cmin, Delta;
   reg signed [DATA_WIDTH-1:0] H_temp, S_temp;

// Adjust widths of components based on frac bits and input width
   assign Rint_fp = $signed({data_in1, {FRAC_WIDTH{1'b0}}});
   assign Gint_fp = $signed({data_in2, {FRAC_WIDTH{1'b0}}});
   assign Bint_fp = $signed({data_in3, {FRAC_WIDTH{1'b0}}});

   always @* begin
      Cmax = $signed($max(Rint_fp, $max(Gint_fp, Bint_fp)));
      Cmin = $signed($min(Rint_fp, $min(Gint_fp, Bint_fp)));
      Delta = Cmax - Cmin;
  
      data_out3 = Cmax;
  
      if (Delta != 0) begin
        if (Cmax == Rint_fp) begin
          H_temp = (60 * ((Gint_fp - Bint_fp) / Delta));
          if (H_temp < 0) data_out1 = H_temp + (360 << FRAC_WIDTH);
          else data_out1 = H_temp;
        end 
        else if (Cmax == Gint_fp)
          data_out1 = 60 * ((Bint_fp - Rint_fp) / Delta) + (120 << FRAC_WIDTH);
        else if (Cmax == Bint_fp)
          data_out1 = 60 * ((Rint_fp - Gint_fp) / Delta) + (240 << FRAC_WIDTH);
        S_temp = (Delta / Cmax);
        data_out2 = S_temp;
      end else begin
        data_out1 = 0;
        data_out2 = 0;
      end
    end

  
endmodule

