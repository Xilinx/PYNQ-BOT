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
This Verilog generates the PWM signal  for:

 - Servo Motors  (Controlling the up/down and left/right movement of Camera ) 
 - Wheel Motors  (Controlling the Forward movement speed of robot only).

 -Time_period_counter ->  This counter sets the Time period of PWM signal and can be calculated using Time_period_counter = Clock_time_period/Time_period_req
 -duty_cycle_counter  ->  This counter sets the Duty cycle of  PWM signal and can be calculated using duty_cycle_counter = Time_period_counter*duty_cycle 
 -enable_pwm          ->  As name states, this is to enable or disable the pwm signal.     
 
*/

module pwm
#(parameter WIDTH=32) (
    input wire clk, rst,
    input wire [WIDTH-1:0] Time_period_counter, duty_cycle_counter, enable_pwm,
    output wire pwm_out
);
    
    reg [WIDTH-1:0] count;
    reg pwm_out_r;
    
    // Make sure output is low if PWM is disabled
    assign pwm_out = enable_pwm[0] & pwm_out_r;
    
    initial begin
        pwm_out_r = 1'b0;
        count = {WIDTH{1'b0}};
    end
    
    // The counter
    always @(posedge clk) begin
        if(!rst)
            count = {WIDTH{1'b0}};
        else if (count < Time_period_counter && enable_pwm[0])
            count = count + 1;
        else
            count = 0;
    end
    
    always @(negedge clk) begin
        if(!rst)
            pwm_out_r = 1'b0;
        else if (duty_cycle_counter==0)
            pwm_out_r=1'b0;        
        else  begin
            case(count)
                0 : pwm_out_r = 1'b1;
                duty_cycle_counter : pwm_out_r = 1'b0;
                default : pwm_out_r = pwm_out_r;
            endcase
        end
    end

endmodule
