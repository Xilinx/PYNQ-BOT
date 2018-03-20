###############################################################################
###############################################################################
 #  Copyright (c) 2018, Xilinx, Inc.
 #  All rights reserved.
 #
 #  Redistribution and use in source and binary forms, with or without
 #  modification, are permitted provided that the following conditions are met:
 #
 #  1.  Redistributions of source code must retain the above copyright notice,
 #     this list of conditions and the following disclaimer.
 #
 #  2.  Redistributions in binary form must reproduce the above copyright
 #      notice, this list of conditions and the following disclaimer in the
 #      documentation and/or other materials provided with the distribution.
 #
 #  3.  Neither the name of the copyright holder nor the names of its
 #      contributors may be used to endorse or promote products derived from
 #      this software without specific prior written permission.
 #
 #  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 #  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 #  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 #  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 #  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 #  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 #  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 #  OR BUSINESS INTERRUPTION). HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 #  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 #  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 #  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 #
###############################################################################
###############################################################################
 #
 #
 # @file Servo_Wheels_Robot.tcl
 #
 # tcl script for block design and bitstream generation. 
 # Tested with Vivado 2017.4
 #
 #
###############################################################################

#Creates a Vivado project ready for synthesis and launches bitstream generation
if {$argc != 6} {
   puts "Expected:<proj name> <proj dir> <xdc_dir> <pwm_module> <ultra_sonic_dir> <wheels_control>"  exit
}


# Project name, Target dir and FPGA part to use
set config_proj_name [lindex $argv 0]
set config_proj_dir [lindex $argv 1]
set config_proj_part "xc7z020clg400-1"

# Set xdc constraints directory
set xdc_dir    		 [lindex $argv 2]
set pwm_ip_dir 		 [lindex $argv 3]
set ultra_sonic_dir  [lindex $argv 4]
set wheels_control   [lindex $argv 5]



# set up project
create_project $config_proj_name $config_proj_dir -part $config_proj_part


update_ip_catalog

#Add PYNQ XDC
add_files -fileset constrs_1 -norecurse "${xdc_dir}/pynq_robot.xdc"

# create block design
create_bd_design "procsys"

# Create ports
  set m1_motor [ create_bd_port -dir O -from 2 -to 0 m1_motor ]
  set m2_motor [ create_bd_port -dir O -from 2 -to 0 m2_motor ]  
  
# Create instance: robot_direction_control, and set properties
  set robot_direction_control [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 robot_direction_control ]
  set_property -dict [ list \
CONFIG.C_ALL_OUTPUTS {1} \
CONFIG.C_GPIO_WIDTH {3} \
 ] $robot_direction_control
 


# Create instance: processing_system7_0, and set properties
set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
source "${xdc_dir}/config_bot.tcl"
  

# Create and connect basic blocks including zynq processing system, reset block and processing system AXI-interconnect and GPIO blocks.
  
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]
startgroup
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "/processing_system7_0/FCLK_CLK0 (100 MHz)" }  [get_bd_intf_pins robot_direction_control/S_AXI]
endgroup

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1


# Add the details of AXI-LITE4 PWM and Ultrasonic IPs and Wheels Control IP
set_property  ip_repo_paths  [list $xdc_dir  ] [current_project]
update_ip_catalog

# Add the Wheel_control IP Block 
create_bd_cell -type ip -vlnv xilinx.com:user:wheels_control:1.0 wheels_control_0


# Create three PWM IP Blocks in the design 
create_bd_cell -type ip -vlnv xilinx.com:user:PWM_Generator_v1_0:1.0 Servo_left_right
create_bd_cell -type ip -vlnv xilinx.com:user:PWM_Generator_v1_0:1.0 Servo_Up_down
create_bd_cell -type ip -vlnv xilinx.com:user:PWM_Generator_v1_0:1.0 Robot_speed_control 


# Create Ultrasonic sensor control IP in the design 
create_bd_cell -type ip -vlnv xilinx.com:user:ultrasonic_V2_v1_0:1.0 ultrasonic_sensor


# Create Ports for PWM output, leds are being connected to pwm output for validation of pwm output.
set led_sonic1 [ create_bd_port -dir O led_sonic1 ]
set led_pwm_wheels [ create_bd_port -dir O led_pwm_wheels ]


set servo_pwm_1 [ create_bd_port -dir O servo_pwm_1 ]
set servo_pwm_2 [ create_bd_port -dir O servo_pwm_2 ]


set pmodJB_7 [create_bd_port -dir IO pmodJB_7]

# Create interface connections
connect_bd_net [get_bd_ports servo_pwm_1] [get_bd_pins Servo_left_right/pwm_out]
connect_bd_net [get_bd_ports servo_pwm_2] [get_bd_pins Servo_Up_down/pwm_out]
connect_bd_net -net Net [get_bd_ports pmodJB_7] [get_bd_pins ultrasonic_sensor/signal_out]
connect_bd_net -net PWM_Generator_v1_0_2_pwm_out [get_bd_ports led_pwm_wheels] [get_bd_pins Robot_speed_control/pwm_out] [get_bd_pins wheels_control_0/pwm]
connect_bd_net -net axi_gpio_0_gpio_io_o [get_bd_pins robot_direction_control/gpio_io_o] [get_bd_pins wheels_control_0/direction]
connect_bd_net -net ultrasonic_V2_v1_0_0_obstruction [get_bd_ports led_sonic1] [get_bd_pins ultrasonic_sensor/obstruction] [get_bd_pins wheels_control_0/ultrasonic]
connect_bd_net -net wheels_control_0_left_side [get_bd_ports m2_motor] [get_bd_pins wheels_control_0/left_side]
connect_bd_net -net wheels_control_0_right_side [get_bd_ports m1_motor] [get_bd_pins wheels_control_0/right_side]
connect_bd_net [get_bd_pins wheels_control_0/clk] [get_bd_pins processing_system7_0/FCLK_CLK0]


startgroup
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "/processing_system7_0/FCLK_CLK0 (100 MHz)" }  [get_bd_intf_pins ultrasonic_sensor/s00_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "/processing_system7_0/FCLK_CLK0 (100 MHz)" }  [get_bd_intf_pins Servo_left_right/s00_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "/processing_system7_0/FCLK_CLK0 (100 MHz)" }  [get_bd_intf_pins Servo_Up_down/s00_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "/processing_system7_0/FCLK_CLK0 (100 MHz)" }  [get_bd_intf_pins Robot_speed_control/s00_axi]
endgroup 

# create HDL wrapper for the block design
save_bd_design
make_wrapper -files [get_files $config_proj_dir/$config_proj_name.srcs/sources_1/bd/procsys/procsys.bd] -top
add_files -norecurse $config_proj_dir/$config_proj_name.srcs/sources_1/bd/procsys/hdl/procsys_wrapper.v


set_property synth_checkpoint_mode None [get_files  $config_proj_dir/pynq_bot.srcs/sources_1/bd/procsys/procsys.bd]
set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]

write_bd_tcl -force $config_proj_dir/procsys.tcl

launch_runs impl_1 -to_step write_bitstream -jobs 2
wait_on_run impl_1

