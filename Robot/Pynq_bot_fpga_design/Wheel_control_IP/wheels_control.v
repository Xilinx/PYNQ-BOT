/******************************************************************************
 *  Copyright (c) 2018, Xilinx, Inc.
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are met:
 *
 *  1.  Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *
 *  2.  Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *
 *  3.  Neither the name of the copyright holder nor the names of its
 *      contributors may be used to endorse or promote products derived from
 *      this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 *  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 *  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 *  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 *  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 *  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 *  OR BUSINESS INTERRUPTION). HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 *  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 *  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 *  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 *****************************************************************************/
/******************************************************************************/

/*
This module is responsible for DIRECTION control of robot.   
Following are brief port/variable descriptions:

ultrasonic  -  The output of ultrasonic sensor IP, which will be used to enable/disable the forward motion of robot in case of any obstruction. 
pwm         -  In order to control the forward speed of robot, the pwm signal is used. Depending on duty cycle value we can change robot speed from Jupyter notebook in run-time.
direction   -  Control signal from processing system to control the direction of motor.  Its value is  0 for "stop", 1 for "Forward", 2 for "Backward", 3 for "Right" and 4 for "Left".
right_side  -  In robot, both motors on right side are controlled using this signal.
left_side   -  In robot, both motors on left side are controlled using this signal. 

*/


module wheels_control
#(parameter WIDTH=3) (
    input  wire pwm, clk, ultrasonic,
	input  wire [WIDTH-1:0] direction,
	output  reg[2:0]  right_side,
    output reg [2:0] left_side

	
);

  wire out;
  assign out = pwm & ultrasonic;

always @ (posedge clk)
begin
 
   case (direction) 
    3'd0 :  
		begin
		right_side <=3'd0;
		left_side <= 3'd0;
		end  
		
    3'd1 : 
	begin
		right_side <= {out,1'b0,1'b1};
		left_side  <= {out,1'b0,1'b1};
	end
	
    3'd2 : 
	begin
		right_side <= {1'b0,1,1'b1};
		left_side  <= {1'b0,1,1'b1};
	end
	
   3'd3 : 
	begin
		right_side <={ultrasonic,1'b0,1'b1};
		left_side  <= 3'd0;
	end
	
   3'd4: 
	begin
		right_side <= 3'b0;
		left_side  <= {ultrasonic,1'b0,1'b1};
	end
	
    default : 
		begin
		right_side <=3'b0;
		left_side <= 3'b0;
		end 
 endcase 
end
endmodule

