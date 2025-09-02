<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This FIFO is designed to transfer data asynchronously between different clock domains. It supports storage of up to 32 entries, each 4 bits wide, for a total capacity of 16 bytes. The design uses separate read and write pointers with full and empty control signals, ensuring data is written only when space is available and read only when valid data is present. By synchronizing pointers across clock domains, it enables reliable and lossless data transfer.

 

## How to Test

To reset the FIFO, keep write_reset and read_reset low while toggling the clock for a short period, then set them high to initialize the module.

### Writing to the FIFO

Place the desired 4-bit value on the write_data bus, check that the full flag is low, and then pulse write_increment high for one cycle of the write_clock to store the value.

### Reading from the FIFO

The current output is continuously available on the read_data bus. If the empty flag is low, the data is valid, and you can advance to the next value by pulsing read_increment high for one cycle of the read_clock.

