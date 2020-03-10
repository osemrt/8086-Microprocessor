
### Performing arithmetic operations using 8255 in mode-1

In this either port A or B can work and port C bits are used to provide handshaking. The outputs as well as inputs are latched. It has interrupt handling capability. Before actual data transfer there is transmission of signal to match speed of CPU and printer. 

Example: When CPU wants to send data to slow peripheral device like printer, it will send handshaking signal to printer to tell whether it is ready or not to transfer the data. When printer will be ready it will send one acknowledgement to CPU then there will be transfer of data through data bus.

![enter image description here](https://github.com/image-assets/gif/blob/master/04_Mathematical_Operations_8255_mod1.gif)
