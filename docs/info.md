<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

The asynchronous FIFO operates as a buffer that allows reliable data transfer between two independent clock domains. It uses a dual-port memory where the write side is driven by the write_clock and the read side is driven by the read_clock. Separate read and write pointers track positions in the memory, and these pointers are synchronized across domains using Gray-code conversion to avoid metastability issues. Control logic generates full and empty status flags based on the relative positions of the read and write pointers, ensuring that writes occur only when space is available and reads occur only when valid data exists. This structure allows smooth, lossless data movement even when the two clocks are unrelated, making the design robust and reusable for asynchronous communication.


## How to test

Hold ``write_reset`` and ``read_reset`` LOW while running the clock for a bit to reset, then raise to initialize the module.

Writing to the fifo: Prepare your data on the 4-bit ``write_data`` bus, ensure the full state is low and then raise write_increment for 1 cycle of ``write_clock`` to write data into the FIFO memory.

Reading from the fifo: The FIFO will present the current output on the ``read_data`` bus. If empty is low, this output should be valid and you can acknowledge receive of this value by raising ``read_increment`` for 1 cycle of read_clock.

## External hardware

NO external hardware is used.


