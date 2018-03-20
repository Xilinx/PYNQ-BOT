#!/bin/bash
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
 # @file make-hw-sh
 #
 # Bash script that automatically launches the bitstream generation for pynq-bot.
 #
 #
###############################################################################



NETWORK=$1
PLATFORM=$2
MODE=$3
PATH_TO_VIVADO=$(which vivado)
PATH_TO_VIVADO_HLS=$(which vivado_hls)

if [ -z "$pynq_bot_root" ]; then
	echo " The environment variable pynq_bot_root is not set yet. Please set as instructed."
    exit 1
fi

if [ -z "$PATH_TO_VIVADO" ]; then
    echo "vivado not found in path"
    exit 1
fi

if [ -z "$PATH_TO_VIVADO_HLS" ]; then
    echo "vivado_hls not found in path"
    exit 1
fi


# generate bitstream if requested

VIVADO_OUT_DIR="$pynq_bot_root/output/pynq_bot"
TARGET_NAME="pynq_bot"
xdc_dir="$pynq_bot_root"
pwm_ip="$pynq_bot_root/PWM_IP/"
ultrasonic_ip="$pynq_bot_root/Ultrasonic_IP/"
wheels_control="$pynq_bot_root/Wheel_control_IP"
BITSTREAM_PATH="$pynq_bot_root/../bitstream"
TARGET_BITSTREAM="$BITSTREAM_PATH/pynq-bot.bit"
TARGET_TCL="$BITSTREAM_PATH/pynq-bot.tcl"
REPORT_OUT_DIR="$pynq_bot_root/output/report"
#VIVADO_SCRIPT ="$pynq_bot_root/Servo_Wheels_Robot.tcl"
FREQ="100.0"


  
  if [ -d "$VIVADO_OUT_DIR" ]; then
  read -p "Remove existing project at $VIVADO_OUT_DIR (y/n)? " -n 1 -r
  echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Nn]$ ]]
    then
      echo "Cancelled"
      exit 1
    fi
  rm -rf "$pynq_bot_root/output"
  fi
  
  mkdir -p "$pynq_bot_root/output/"
  mkdir -p  "$REPORT_OUT_DIR"
  echo "Setting up Vivado project..."
  cd output
  
 # vivado -mode batch -notrace -source $pynq_bot_root/IP_TCL_FILES/PWM_IP.tcl            -tclargs   $pwm_ip
 # vivado -mode batch -notrace -source $pynq_bot_root/IP_TCL_FILES/Ultrasonic_IP.tcl     -tclargs   $ultrasonic_ip
  
  vivado -mode batch -notrace -source $pynq_bot_root/Servo_Wheels_Robot.tcl -tclargs $TARGET_NAME $VIVADO_OUT_DIR $xdc_dir $pwm_ip $ultrasonic_ip $wheels_control 
  cd ..
  
  if [ -f "$VIVADO_OUT_DIR/$TARGET_NAME.runs/impl_1/procsys_wrapper.bit" ]; then
  
  cp -f "$VIVADO_OUT_DIR/$TARGET_NAME.runs/impl_1/procsys_wrapper.bit" $TARGET_BITSTREAM
  cp -f "$VIVADO_OUT_DIR/procsys.tcl" $TARGET_TCL
  # extract parts of the post-implementation reports
  cat "$VIVADO_OUT_DIR/$TARGET_NAME.runs/impl_1/procsys_wrapper_timing_summary_routed.rpt" | grep "| Design Timing Summary" -B 3 -A 10 > $REPORT_OUT_DIR/vivado.txt
  cat "$VIVADO_OUT_DIR/$TARGET_NAME.runs/impl_1/procsys_wrapper_utilization_placed.rpt" | grep "Slice LUTs" -B 3 -A 10 >> $REPORT_OUT_DIR/vivado.txt
  cat "$VIVADO_OUT_DIR/$TARGET_NAME.runs/impl_1/procsys_wrapper_utilization_placed.rpt" |  grep "| Block RAM Tile" -B 3 -A 5 >> $REPORT_OUT_DIR/vivado.txt
  cat "$VIVADO_OUT_DIR/$TARGET_NAME.runs/impl_1/procsys_wrapper_utilization_placed.rpt" |  grep "| DSPs" -B 3 -A 3 >> $REPORT_OUT_DIR/vivado.txt

  
  echo "Bitstream copied to $TARGET_BITSTREAM"
  echo "Done!"
  exit 0
  
 else   
	echo "Error in bit stream generation, please look into the error in source files or log files"
    exit 1
 fi
  
  