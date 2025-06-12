# UART Communication Project in Verilog

This project implements a complete UART (Universal Asynchronous Receiver/Transmitter) communication system using Verilog. It includes:

- A **Transmitter module** (`TX.v`)
- A **Receiver module** (`RX.v`)


##  Project Components

### 1. `TX.v` — UART Transmitter

The `TX` module is responsible for serially transmitting 8-bit data over the UART protocol. The baud rate is configurable via the `t_rate` parameter.

#### Inputs:
- `clk`: System clock.
- `Rst_tx`: Active-low reset signal.
- `Start`: Signal to begin transmission.
- `data`: 8-bit data to be transmitted.

#### Outputs:
- `done`: Goes high when transmission is complete.
- `Rs232_tx`: The UART TX line (serial output).

#### Behavior:
- Transmits data bit-by-bit, starting with a **start bit (0)**, followed by **8 data bits**, and ending with a **stop bit (1)**.
- The `done` signal is asserted after the full frame is sent.

---

### 2. `RX.v` — UART Receiver

The `RX` module receives serial data from the UART line and converts it into an 8-bit parallel word.

#### Inputs:
- `clk`: System clock.
- `Rst_rx`: Active-low reset signal.
- `Rs232`: Serial input from the UART line.

#### Outputs:
- `rx_data`: The 8-bit received data.
- `done`: Goes high when a full byte is successfully received.

#### Behavior:
- Waits for a **start bit (0)** on the `Rs232` line.
- Samples the next 8 data bits and checks for a **valid stop bit (1)**.
- If valid, sets `done = 1` and outputs the data on `rx_data`.

---

##  How to Use

You can simulate the UART modules using tools such as:

- **ModelSim**
- **Icarus Verilog + GTKWave**

### Example Instantiation:

```verilog
wire tx_line;
wire done_tx, done_rx;
wire [7:0] data_out;

TX #(5208) uart_tx (
    .clk(clk),
    .Rst_tx(reset),
    .Start(start_tx),
    .data(data_in),
    .done(done_tx),
    .Rs232_tx(tx_line)
);

RX #(5208) uart_rx (
    .clk(clk),
    .Rst_rx(reset),
    .Rs232(tx_line),
    .rx_data(data_out),
    .done(done_rx)
);
