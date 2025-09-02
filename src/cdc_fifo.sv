


// FIFO for passing registers across clock domains

module cdc_fifo #(
  parameter DATA_WIDTH = 8,
  parameter ADDRESS_WIDTH = 8
) (
  // Sender side signals/buses
  input logic write_clock,
  input logic write_reset,
  input logic [DATA_WIDTH-1:0] write_data,
  input logic write_increment,
  output logic full,

  // Receiver side signals/buses
  input logic read_clock,
  input logic read_reset,
  input logic read_increment,
  output logic [DATA_WIDTH-1:0] read_data,
  output logic empty
);

  wire write_enable;
  wire [ADDRESS_WIDTH-1:0] write_address;
  wire [ADDRESS_WIDTH-1:0] write_address_gray_presync;
  wire [ADDRESS_WIDTH-1:0] write_address_gray_postsync;
  wire [ADDRESS_WIDTH-1:0] read_address;
  wire [ADDRESS_WIDTH-1:0] read_address_gray_presync;
  wire [ADDRESS_WIDTH-1:0] read_address_gray_postsync;

  assign write_enable = (!full & write_increment);

  dpram #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDRESS_WIDTH(ADDRESS_WIDTH)
  ) fifo_memory (
    .clock(write_clock),
    .write_address(write_address),
    .write_data(write_data),
    .write_enable(write_enable),
    .read_address(read_address),
    .read_data(read_data)
  );

  cdc_fifo_write_state #(
    .ADDRESS_WIDTH(ADDRESS_WIDTH)
  ) writestate (
    .clock(write_clock),
    .reset(write_reset),
    .increment(write_increment),
    .read_address_gray(read_address_gray_postsync),
    .write_address(write_address),
    .write_address_gray(write_address_gray_presync),
    .full(full)
  );

  cdc_fifo_read_state #(
    .ADDRESS_WIDTH(ADDRESS_WIDTH)
  ) readstate (
   .clock(read_clock),
   .reset(read_reset),
   .increment(read_increment),
   .write_address_gray(write_address_gray_postsync),
   .read_address(read_address),
   .read_address_gray(read_address_gray_presync),
   .empty(empty)
  );

  synchronizer #(
    .WIDTH(ADDRESS_WIDTH)
  ) write_address_sync (
    .clock(read_clock),
    .reset(read_reset),
    .in(write_address_gray_presync),
    .out(write_address_gray_postsync)
  );

  synchronizer #(
    .WIDTH(ADDRESS_WIDTH)
  ) read_address_sync (
    .clock(write_clock),
    .reset(write_reset),
    .in(read_address_gray_presync),
    .out(read_address_gray_postsync)
  );

endmodule

module binary_to_gray #(
  parameter WIDTH = 8
) (
  input logic [WIDTH-1:0] binary,
  output logic [WIDTH-1:0] gray
);

  assign gray = (binary >> 1) ^ binary;

endmodule


module cdc_fifo_read_state #(
  parameter ADDRESS_WIDTH = 4
) (
  input logic clock,
  input logic reset,
  input logic increment,
  input logic [ADDRESS_WIDTH-1:0] write_address_gray,

  output logic [ADDRESS_WIDTH-1:0] read_address,
  output logic [ADDRESS_WIDTH-1:0] read_address_gray,
  output logic empty
);

  logic [ADDRESS_WIDTH-1:0] write_address;

  gray_to_binary #(
    .WIDTH(ADDRESS_WIDTH)
  ) write_addr_decode (
    .gray(write_address_gray),
    .binary(write_address)
  );

  binary_to_gray #(
    .WIDTH(ADDRESS_WIDTH)
  ) read_addr_encode (
    .binary(read_address),
    .gray(read_address_gray)
  );

  assign empty = (write_address == read_address);

  always_ff @ (posedge clock or posedge reset) begin
    if (reset) begin
      read_address <= 0;
    end else if (increment & !empty) begin
      read_address <= read_address + 1;
    end
  end

endmodule



module cdc_fifo_write_state #(
  parameter ADDRESS_WIDTH = 4
) (
  input logic clock,
  input logic reset,
  input logic increment,
  input logic [ADDRESS_WIDTH-1:0] read_address_gray,

  output logic [ADDRESS_WIDTH-1:0] write_address,
  output logic [ADDRESS_WIDTH-1:0] write_address_gray,
  output logic full
);

  assign full = (write_address + 1 == read_address);

  logic [ADDRESS_WIDTH-1:0] read_address;

  gray_to_binary #(
    .WIDTH(ADDRESS_WIDTH)
  ) read_addr_decode (
    .gray(read_address_gray),
    .binary(read_address)
  );

  binary_to_gray #(
    .WIDTH(ADDRESS_WIDTH)
  ) write_addr_encode (
    .binary(write_address),
    .gray(write_address_gray)
  );

  always_ff @ (posedge clock or posedge reset) begin
    if (reset) begin
      write_address <= 0;
    end else if (increment & !full) begin
      write_address <= write_address + 1;
    end
  end

endmodule


// Dual-ported parameterized RAM module
module dpram #(
  parameter DATA_WIDTH = 8,
  parameter ADDRESS_WIDTH = 8
) (
  input logic clock,

  input logic [ADDRESS_WIDTH-1:0] write_address,
  input logic [DATA_WIDTH-1:0] write_data,
  input logic write_enable,

  input logic [ADDRESS_WIDTH-1:0] read_address,
  output logic [DATA_WIDTH-1:0] read_data
);

  logic [DATA_WIDTH-1:0] memory [0:(1<<ADDRESS_WIDTH)-1];

  assign read_data = memory[read_address];

  always_ff @ (posedge clock) begin
    if (write_enable) begin
      memory[write_address] <= write_data;
    end
  end

endmodule
module gray_to_binary #(
  parameter WIDTH = 8
) (
  input logic [WIDTH-1:0] gray,
  output logic [WIDTH-1:0] binary
);

  always_comb begin
    for (int i = 0; i < WIDTH; i++) begin
      binary[i] = ^(gray >> i);
    end
  end

endmodule

module synchronizer #(
  parameter WIDTH = 1
) (
  input logic clock,
  input logic reset,
  input logic [WIDTH-1:0] in,
  output logic [WIDTH-1:0] out);

  logic [WIDTH-1:0] data;

  always_ff @ (posedge clock or posedge reset) begin
    if (reset) begin
        out <= 0;
        data <= 0;
    end else begin
        {out, data} <= {data, in};
    end
  end
endmodule
