# Hardware_accelerator_colour_space_conversion
Verilog modules for dynamic/real time colour space conversion for image processing applications, implementable and synthesizable on FPGA 

The process of color space conversion involves iterating over each pixel of the image, retrieving its component values, performing the required calculations, and updating the pixel values with the converted component values in the target color space. This operation is typically executed on a per-pixel basis or in optimized batch operations for better performance.

Hardware Implementation in FPGA
Project Features
This design is intended to be used as Hardware Acceleration for Color Space Conversion Process for real-time Image Processing Applications. 
-	Dynamic real-time selection of input color space
-	Dynamic real-time selection of output color space
-	Low latency, high speed conversion in as low as <>  cycles with a maximum latency of <> cycles
-	Synchronous Design in single clock domain
-	Support to disable the entire module when not in use, for power savings

Implementation Summary
FPGA – DE-10; SOFTWARE- QUARTUS PRIME LITE;

