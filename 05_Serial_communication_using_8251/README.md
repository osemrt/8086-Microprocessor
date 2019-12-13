
# Serial Communication Using 8251 USART

In a 8086 86P system, 8251 USART is placed at 100H and 104H addresses and serial communication is required. The counter device (TOPSECRET) uses 8 data bits, 1 stop bit without parity for serial communication, and has a 5 byte round robin serial data acquisition buffer.

TOPSECRET works according to the following protocol. Set the serial communication baudrate for TOPSECRET. TERMINAL1, TERMINAL2, 8251 and 8251 Set the square wave values connected to TxC and RxC to be compatible with TOPSECRET. Send the "SR" command, which commences communication with TOPSECRET, and write the assembly code, which sends a request to read data with 'D' 5 times in succession and stops communication with "ST", in order to properly evaluate all incoming command responses. Store the responses of the 'D' commands from the SERIALDATA address in the DATA segment.

![enter image description here](https://drive.google.com/uc?id=16kBJ8Glq03dstvmRqAjfdNIXKJJ2CrWH)

![enter image description here](https://drive.google.com/uc?id=1Wj2ZEfIIPznwX5MUHzos_wRGM6N--KTx)
