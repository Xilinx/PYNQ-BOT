# PYNQ-BOT
This repo. contains the hardware/software design files and Ipython notebooks for PYNQ-BOT.

![alt text](https://github.com/Xilinx/PYNQ-BOT/blob/master/PYNQ-BOT.jpg)


## Quick Start

In order to install it your PYNQ-Z1 boad, connect to the board, open a terminal and type:

sudo pip3.6 install git+https://github.com/Xilinx/PYNQ-BOT.git (on PYNQ v2.1)

Instructions for connecting with board and opening a terminal are on this page :  [PYNQ Getting Started Guide](http://pynq.readthedocs.io/en/latest/getting_started.html)

This will install the PYNQ-BOT package to your board, and create a **pynq_bot** directory in the **jupyter_notebooks** folder on PYNQ-Z1. You will find the Jupyter notebook to run the robot in this directory. 

- Note 1:  In order to test the existing package, you have to assemble PYNQ-BOT first or connect individual components (sensor/motors etc.) with corresponding I/O ports as mentioned below. 

- Note 2: Before executing the Jupyter notebook, have a look at the comments/instrucitons in Jupyter notebook and see what each of block of code is doing.  You need to configure some parameters for sensor and motors as per your needs.  

## Mechanical and Electrical Structure of PYNQ-BOT

Following robotics kit and components were used to assemble the PYNQ-BOT. 

 - [PYNQ Z1 Board](https://store.digilentinc.com/pynq-z1-python-productivity-for-zynq/)

 - Robotics Kit
   - [Link 1 : Tomtop.com](https://www.tomtop.com/p-rm5075us.html)
   - [Link 2 : RCMoment.com](https://www.rcmoment.com/p-rm5075us.html?currency=EUR&Warehouse=CN&aid=rmplaietjc&gclid=Cj0KCQjw7Z3VBRC-ARIsAEQifZT8f2Hdemirf_S9fkUOPT_8KJOtJlaZfj95Sk3Q4seSBleIj9Ybw1caAn-mEALw_wcB )
   - [Link 3 :  Amazon.co.uk](https://www.amazon.co.uk/Kuman-Professional-Raspberry-Electronic-Controlled/dp/B0719M1BG3/ref=pd_rhf_se_s_pd_session_scf_0_8?_encoding=UTF8&pd_rd_i=B0719M1BG3&pd_rd_r=KS5CNCZV2CG0Z4G00888&pd_rd_w=dsMlU&pd_rd_wg=IfH4G&pf_rd_i=desktop-rhf&pf_rd_m=A3P5ROKL5A1OLE&pf_rd_p=1667995087&pf_rd_r=KS5CNCZV2CG0Z4G00888&pf_rd_s=desktop-rhf&pf_rd_t=40701&psc=1&refRID=KS5CNCZV2CG0Z4G00888)
 
   - [Link 4 : CAFAGO.com](https://www.cafago.com/en/p-rm5075us.html?currency=EUR&Warehouse=CN&aid=cagplaie3782)
   - [Link 5 :  Newegg.com](https://www.newegg.com/Product/Product.aspx?Item=01Z-00AJ-003E4)

 - [Raspberry Pi USB WiFi Adapter](https://www.canakit.com/raspberry-pi-wifi.html)
 
-  [2-Port USB 2.0 Hub](https://www.amazon.co.uk/gp/product/B007KYTI34/ref=ox_sc_act_title_1?smid=A3P5ROKL5A1OLE&psc=1)

-  [Grove Ultrasonic Ranger](http://wiki.seeed.cc/Grove-Ultrasonic_Ranger) (Optional, If obstruction detection is not needed) 

-  [PYNQ PMOD Grove Adapter](https://store.digilentinc.com/pynq-grove-system-add-on-board)  (Optional, required for above  Grove Ultrasonic Ranger only)
  
*The Arduino board in robotics kit was replaced by PYNQ-Z1 board and Wifi module was replaced by Raspberry Pi USB WiFi Adapter.* 

*You are free to use any robotics kit, chassis, motor power IC and ultrasonic sensor, but make sure you connect them with correct ports as mentioned in below in I/O Control ports table.* 

## Pre-build bitstream and Ipython-notebook 
-  The pre-generated bitstream and tcl files can be found under the folder `clone_path/PYNQ-BOT/Robot/bitstream`
-  The Ipython notebook can be found under the folder `clone_path/PYNQ-BOT/notebook`

- In Ipython notebook, execute all the cells,  then at the end you will see robot control widgets.  Just press the buttons to control robot movement and sliders to rotate the camera up/down or left/right. 


##  Control register addresses of IPs 
![alt text](https://github.com/Xilinx/PYNQ-BOT/blob/master/Register_Address_Mapping.jpg)

## Hardware design rebuilt

In order to rebuild the hardware designs, the repo should be cloned in a machine with installation of the Vivado Design Suite (tested with 2017.4). 
Following the step-by-step instructions:

1.	Clone the repository on your linux machine: git clone https://github.com/Xilinx/PYNQ-BOT.git;
2.	Move to `clone_path/PYNQ-BOT/Robot/Pynq_bot_fpga_design` 
3.	Set the pynq_bot_root environment variable to `clone_path/PYNQ-BOT/Robot/Pynq_bot_fpga_design`. Make sure to set the variable in bash   shell mode, as script uses bash to rebuild the hardware design. 
4.	Launch the shell script `make-hw.sh`.
5.	The results will be visible in `clone_path/PYNQ-BOT/Robot` that is organized as follows:
	- vivado-project  :  Vivado project can be found in  `Pynq_bot_fpga_design/output/pynq_bot`
	- bitstreams      :  bitstream and tcl files can be found in  `bitstream` folder;
	- Reports         :  Utilization report can be found in `Pynq_bot_fpga_design/output/report`.
	
	
##  I/O Control ports description 
![alt text](https://github.com/Xilinx/PYNQ-BOT/blob/master/Port_Description.JPG)


- Note : Make sure all the motors are powered using external power supply/battery and not through the PYNQ-Z1 board.  It can damage the board.

## Control Robot Over WIFI 
Following are the steps and hardware required to control the robot using a Wireless connection.

### Hardware Required: 

1. [Raspberry Pi WiFi Adapter](https://www.canakit.com/raspberry-pi-wifi.html)  has to be plugged into USB port of PYNQ-Z1 board. 
2. Note :  No usb device should be connected to PYNQ-Z1 during power up.  Once the board is powered and is up and running, then connect the USB devices like USB WIFI dongle or USB camera etc.  Since PYNQ-Z1 has one USB port, you will need
   a [2-Port USB 2.0 Hub](https://www.amazon.co.uk/gp/product/B007KYTI34/ref=ox_sc_act_title_1?smid=A3P5ROKL5A1OLE&psc=1) to connect more than one device. 
   
   
### Setup Instructions:

In **jupyter_notebooks/common** folder on PYNQ-Z1, you will find 
[usb-wifi.ipynb](https://github.com/Xilinx/PYNQ/blob/master/pynq/notebooks/common/usb_wifi.ipynb) notebook, which can be used to connect robot with a wireless router/hotspot and control it over WIFI.

 
