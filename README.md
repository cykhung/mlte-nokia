## Pluto Demo - LTE Rx
The following files are used to demonstrate how to use a Pluto radio to capture over-the-air LTE downlink signal and use the LTE Toolbox to lock on to PSS/SSS and decode MIB and SIB1.

* **MIBDemo.ppt** - PowerPoint slides.
* **capture.m**   - MATLAB file that uses Pluto radio to do one capture.
* **capture.mat** - MATLAB MAT-file that stores the IQ baseband complex samples (variable *x*) and sampling rate (variable *fs*)
* **SIB1RecoveryExample\SIB1RecoveryExample.m** - This is the main MATLAB script to run the demo. To run the demo:
    
    \>> cd SIB1RecoveryExample
    
    \>> SIB1RecoveryExample

## Pluto Demo - LTE Tx
The following files are used to demonstrate how to use a Pluto radio to transmit a LTE downlink signal to jam an iphone.

* **jam.m** - This is the main MATLAB function to transmit a LTE downlink signal.
* **jamvideo.mov** - Movie showing the demo.
* **ltefreq.m** - MATLAB function that calculates LTE carrier center frequency for either downlink or uplink.

## Miscellaneous Files
* **Notebook13.pdf** - Kevin's personal notes for LTE Release 8.
