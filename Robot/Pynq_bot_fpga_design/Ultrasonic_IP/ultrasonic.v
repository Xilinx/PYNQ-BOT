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

This IP controls the Front Ultrasonic sensor on Robot. 
Following is brief description about module ports/variables

enable_sensor ->   This is used to enable ("1") the Ultrasonic sensor or  to bypass ("0") it. 
obstruction   ->   This port is set to 1 in case an obstruction is detected by the sensor in specified distance.
signal_out    ->   Signal to trigger the Ultrasonic sensor and then measure the return time of reflected signal.
distance      ->   Counter to set the obstruction distance.   The robot will be forced to stop when distance between obstruction and robot is less than or equal to distance.
settle_time   ->   Every ultrasonic sensor has settling time before it can be triggered again.   This counter configures the settling time of ultrasonic sensor.

*/


module ultrasonic
#(parameter WIDTH=32) (
    input  wire clk, rst,
	input wire [WIDTH-1:0] enable_sensor,
    output  wire obstruction,
    inout  signal_out,
	input  wire [WIDTH-1:0] distance,
	input  wire[WIDTH-1:0] settle_time
	//output wire pulse
);

	reg dir,trigger_in;
	wire pulse;
	//reg pulse;
	reg obstruction_internal;

    reg [WIDTH-1:0] count; 
    reg [WIDTH-1:0] count_nano_sec;
   
 
    assign signal_out = dir ? trigger_in : 1'bz;
    assign pulse = signal_out;
	assign obstruction = enable_sensor[0] ? obstruction_internal  : 1'b1;

    initial begin

		dir=1'b1;
        trigger_in <= 1'b0;
        count <= {WIDTH{1'b0}};
		count_nano_sec<={WIDTH{1'b0}};
    end


    // The counter
    always @(posedge clk) begin
	
	//pulse = signal_out;

        if(!rst)
            begin
                 count <= {WIDTH{1'b0}};
			     trigger_in<=1'b0;
			     obstruction_internal<=1'b0;
			     count_nano_sec<= {WIDTH{1'b0}};
			     dir <=1'b1;
		     end 	

        else if (count < 200)
		begin
		   dir=1'b1;
           trigger_in=1'b0;
		   count = count + 1;
		 end

		 

		else if (count>=200 && count<1200)
		 begin
		    dir=1'b1;
			trigger_in=1'b1;
			count = count + 1;	
	    end

		
    	else if (count==1200)
		begin
			dir=1'b1;
			trigger_in=1'b0;
			count=count+1;
		end

		else if (count==1201)
		begin
		dir=1'b0;
		count=count+1;
		end	

        else if (count >1201 && pulse)
		begin
			count_nano_sec=count_nano_sec+1;
			count=count+1;
     	end	

			

		else if (count >=settle_time && !pulse) 
		// Current working settling time counter value is 6001200.
		begin
              count=0;
			  if (count_nano_sec >distance)
			  // distance working value is 90000
			  begin
			    obstruction_internal= 1'b1;
			    count_nano_sec=0;
			  end
   

			   else
			   begin
			  obstruction_internal=1'b0;
			  count_nano_sec=0;
			   end

		end	   
	    
	    else 
			count=count+1;

    end



endmodule

