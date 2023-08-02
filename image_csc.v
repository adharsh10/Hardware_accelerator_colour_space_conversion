`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Created By     : 
// 
// Create Date    : 07/01/2023 09:07:49 AM
// Design Name    : Color Space Conversion For Image Processing Applications
// Module Name    : image_csc
// Target Devices : FPGA
// Tool           : Vivado
// Description    : This module is intended to be used for 
//                  Real-Time Image Processing Applications.
//                  Based on the input control and output control that sets
//                  the color space of input data stream and output data
//                  stream, this module applies the color space conversion
//                  algorithm on the input data to get the output data in the
//                  required color space format. 
//
//                  - The data width of input and output components is 8 bits.
//                  - Each input pixel is considered to be of 3 components.
//                  - reset is of positive polarity and asynchronous
// 
//////////////////////////////////////////////////////////////////////////////////
// Module Declaration
//////////////////////////////////////////////////////////////////////////////////
module image_csc (
   input clk,
   input reset, 
   input [1:0] input_control,
   input [1:0] output_control,

   input [7:0] data_in1,
   input [7:0] data_in2,
   input [7:0] data_in3,

   output reg [7:0] data_out1,
   output reg [7:0] data_out2,
   output reg [7:0] data_out3
		
  );

//////////////////////////////////////////////////////////////////////////////////
// Internal Variables declaration
//////////////////////////////////////////////////////////////////////////////////
   reg [7:0] r_int;
   reg [7:0] g_int;
   reg [7:0] b_int;
   reg [7:0] delta;	
   reg [7:0] max;
   reg [7:0] min;
   
   reg [7:0] cmy_int_1;
   reg [7:0] cmy_int_2;
   reg [7:0] cmy_int_3;

   localparam DATA_WIDTH = 8;
   localparam FRAC_WIDTH = 8;
   // Color Space Parameters
   localparam RGB = 2'b00;
   localparam YUV = 2'b01;
   localparam CMY = 2'b10;
   localparam HSV = 2'b11;

   wire signed [DATA_WIDTH+FRAC_WIDTH-1:0] RGB_to_Yint, RGB_to_Uint, RGB_to_Vint;
   wire signed [DATA_WIDTH+FRAC_WIDTH-1:0] YUV_to_Rint, YUV_to_Gint, YUV_to_Bint;
   wire signed [DATA_WIDTH+FRAC_WIDTH-1:0] RGB_to_Hint, RGB_to_Sint, RGB_to_Iint;
   wire signed [DATA_WIDTH+FRAC_WIDTH-1:0] HSV_to_Rint, HSV_to_Gint, HSV_to_Bint;

   wire [DATA_WIDTH-1] Rint1, Gint1, Bint1;
   wire [DATA_WIDTH-1] Rint2, Gint2, Bint2;

//////////////////////////////////////////////////////////////////////////////////
// Sub-module instantiation for different color space conversion logic
// All modules are combo without clock or reset. 
//////////////////////////////////////////////////////////////////////////////////
// RGB to YUV Conversion
   assign Rint1 =     (input_control == RGB ) ? data_in1 : 
	             (input_control == CMY) ?  ~data_in1 : 
		     (input_control == HSV) ? HSV_to_Rint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH] : 
		               8'b0;
   assign Gint1 =     (input_control == RGB) ? data_in2 : 
	             (input_control == CMY) ? ~data_in2 : 
		     (input_control == HSV) ? HSV_to_Gint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH] : 
		               8'b0;
   assign Bint1 =     (input_control == RGB) ? data_in3 : 
	             (input_control == CMY) ? ~data_in3 : 
		     (input_control == HSV) ? HSV_to_Bint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH] : 
		               8'b0;

   rgb_to_yuv (
    .data_in1(Rint1),
    .data_in2(Gint1),
    .data_in3(Bint1),

    .data_out1(RGB_to_Yint),
    .data_out2(RGB_to_Uint),
    .data_out3(RGB_to_Vint)

   );

//////////////////////////////////////////////////////////////////////////////////
// YUV to RGB Conversion
   yuv_to_rgb (
    .data_in1(data_in1),
    .data_in2(data_in2),
    .data_in3(data_in3),

    .data_out1(YUV_to_Rint),
    .data_out2(YUV_to_Gint),
    .data_out3(YUV_to_Bint)

   );

//////////////////////////////////////////////////////////////////////////////////
// RGB to HSV Adjustments and Calcultions
   assign Rint2 =     (input_control == RGB ) ? data_in1 : 
	             (input_control == CMY) ?  ~data_in1 : 
		     (input_control == YUV) ? YUV_to_Rint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH] : 
		               8'b0;
   assign Gint2 =     (input_control == RGB) ? data_in2 : 
	             (input_control == CMY) ? ~data_in2 : 
		     (input_control == YUV) ? YUV_to_Gint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH] : 
		               8'b0;
   assign Bint2 =     (input_control == RGB) ? data_in3 : 
	             (input_control == CMY) ? ~data_in3 : 
		     (input_control == YUV) ? YUV_to_Bint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH] : 
		               8'b0;
   rgb_to_hsv (
    .data_in1(Rint2),
    .data_in2(Gint2),
    .data_in3(Bint2),

    .data_out1(RGB_to_Hint),
    .data_out2(RGB_to_Sint),
    .data_out3(RGB_to_Iint)

   );

//////////////////////////////////////////////////////////////////////////////////
// HSV to RGB Adjustments and Calcultions
   hsv_to_rgb (
    .data_in1(data_in1),
    .data_in2(data_in2),
    .data_in3(data_in3),

    .data_out1(HSV_to_Rint),
    .data_out2(HSV_to_Gint),
    .data_out3(HSV_to_Bint)

   );

//////////////////////////////////////////////////////////////////////////////////
// Output Registering Logic
   always@(posedge clk or posedge reset) begin
      if (reset) begin
         // Reset condition, initialize registers
         data_out1 <= 8'd0;
         data_out2 <= 8'd0;
         data_out3 <= 8'd0;
      end
      else begin
      //RGB to CMY and CMY to RGB
         if ((input_control == RGB && output_control == CMY) || (input_control == CMY && output_control == RGB)) begin
	    data_out1 <= ~data_in1; // 8'd255 - data_in1;
	    data_out2 <= ~data_in2; // 8'd255 - data_in2;
	    data_out3 <= ~data_in3; // 8'd255 - data_in3;
	 end

      //RGB TO YCBCR/YUV
         else if(input_control == RGB && output_control == YUV) begin
            data_out1 <= RGB_to_Yint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH];
            data_out2 <= RGB_to_Uint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH];
            data_out3 <= RGB_to_Vint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH];
	 end

      //YCBCR/YUV TO RGB		
	 else if(input_control == YUV && output_control == RGB) begin
            data_out1 <= YUV_to_Rint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH];
            data_out2 <= YUV_to_Gint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH];
            data_out3 <= YUV_to_Bint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH];

	 end

      //RGB TO HSV
         else if(input_control == RGB && output_control == HSV) begin
            data_out1 <= RGB_to_Hint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH];
            data_out2 <= RGB_to_Sint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH];
            data_out3 <= RGB_to_Iint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH]; 
	 end

      //HSV TO RGB
	 else if(input_control == HSV && output_control == RGB) begin
            data_out1 <= HSV_to_Rint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH];
            data_out2 <= HSV_to_Gint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH];
            data_out3 <= HSV_to_Bint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH]; 
         end

      //CMY to ycbcr
         else if(input_control == CMY && output_control == YUV) begin
            data_out1 <= RGB_to_Yint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH];
            data_out2 <= RGB_to_Uint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH];
            data_out3 <= RGB_to_Vint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH];
         end

      //YCBCR to CMY
	 else if(input_control == YUV && output_control == CMY) begin
            data_out1 <= ~YUV_to_Rint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH];
            data_out2 <= ~YUV_to_Gint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH];
            data_out3 <= ~YUV_to_Bint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH];

         end

      //YCBCR to HSV
	 else if(input_control == YUV && output_control == HSV) begin
            data_out1 <= RGB_to_Hint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH];
            data_out2 <= RGB_to_Sint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH];
            data_out3 <= RGB_to_Iint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH]; 
         end

	//HSV TO YCBCR		
	 else if(input_control == HSV && output_control == YUV) begin
            data_out1 <= RGB_to_Yint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH];
            data_out2 <= RGB_to_Uint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH];
            data_out3 <= RGB_to_Vint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH];
	 end

	//HSV TO CMY
	 else if(input_control == HSV && output_control == CMY) begin
            data_out1 <= ~HSV_to_Rint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH];
            data_out2 <= ~HSV_to_Gint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH];
            data_out3 <= ~HSV_to_Bint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH]; 
         end

	//cmy to hsv
	 else if(input_control == CMY && output_control == HSV) begin
            data_out1 <= RGB_to_Hint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH];
            data_out2 <= RGB_to_Sint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH];
            data_out3 <= RGB_to_Iint[DATA_WIDTH+FRAC_WIDTH-1:FRAC_WIDTH]; 
         end

         else begin
            data_out1 <= data_in1;
            data_out2 <= data_in2;
            data_out3 <= data_in3;
         end

      end // else of reset
   end  // always block

//////////////////////////////////////////////////////////////////////////////////
// Implementation Ends
//////////////////////////////////////////////////////////////////////////////////
endmodule
//////////////////////////////////////////////////////////////////////////////////
