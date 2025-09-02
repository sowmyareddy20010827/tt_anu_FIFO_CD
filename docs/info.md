<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

The asynchronous FIFO operates as a buffer that allows reliable data transfer between two independent clock domains. It uses a dual-port memory where the write side is driven by the write_clock and the read side is driven by the read_clock. Separate read and write pointers track positions in the memory, and these pointers are synchronized across domains using Gray-code conversion to avoid metastability issues. Control logic generates full and empty status flags based on the relative positions of the read and write pointers, ensuring that writes occur only when space is available and reads occur only when valid data exists. This structure allows smooth, lossless data movement even when the two clocks are unrelated, making the design robust and reusable for asynchronous communication.
 

## How to Test

To reset the FIFO, keep write_reset and read_reset low while toggling the clock for a short period, then set them high to initialize the module.

### Writing to the FIFO

Place the desired 4-bit value on the write_data bus, check that the full flag is low, and then pulse write_increment high for one cycle of the write_clock to store the value.

### Reading from the FIFO

The current output is continuously available on the read_data bus. If the empty flag is low, the data is valid, and you can advance to the next value by pulsing read_increment high for one cycle of the read_clock.


## External hardware

NO external hardware is used.


