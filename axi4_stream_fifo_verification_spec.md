# Verification Specification for AXI4-Stream FIFO v4.3 IP

## 1. Introduction
This document defines the verification specification for the **AXI4-Stream FIFO v4.3** IP. The IP provides memory-mapped (AXI4/AXI4-Lite) access to an AXI4-Stream interface. The verification environment will be implemented using SystemVerilog (typically with UVM methodology).

## 2. IP Features to Verify
*   **AXI4-Lite / AXI4 Slave Interface**: Register access and data FIFO access.
*   **AXI4-Stream Interfaces**: Transmit Data (TXD), Transmit Control (TXC), Receive Data (RXD).
*   **Datapath Modes**:
    *   Store-and-Forward Mode.
    *   Cut-Through Mode.
*   **Interrupts**: Status and error conditions (Completion, Overrun, Underrun, Size Error, ECC errors, Reset completion).
*   **Error Correction Code (ECC)**: 1-bit and 2-bit error injection and reporting for both TX and RX FIFOs.
*   **Independent FIFOs**: Full duplex operation of TX and RX FIFOs.
*   **Reset Operations**: Global reset, TX FIFO reset, RX FIFO reset, and AXI4-Stream reset.

## 3. Interface Definitions
The verification environment must instantiate VIPs/Agents for the following interfaces:
1.  **AXI4-Lite Slave Interface (`s_axi_*`)**: 32-bit interface for register read/write.
2.  **AXI4 Slave Interface (`s_axi4_*`)**: Optional interface used for data burst access.
3.  **AXI4-Stream Transmit Data (`axi_str_txd_*`)**: Master interface driving data out of the FIFO.
4.  **AXI4-Stream Transmit Control (`axi_str_txc_*`)**: Master interface driving control data.
5.  **AXI4-Stream Receive Data (`axi_str_rxd_*`)**: Slave interface receiving data into the FIFO.

## 4. Register Map (RAL)
A Register Abstraction Layer (RAL) model must be created covering the following address map:

| Offset | Register Name | Description | Access |
| :--- | :--- | :--- | :--- |
| `0x00` | `ISR` | Interrupt Status Register | R/W1C |
| `0x04` | `IER` | Interrupt Enable Register | R/W |
| `0x08` | `TDFR` | Transmit Data FIFO Reset (`0xA5` to reset) | W |
| `0x0C` | `TDFV` | Transmit Data FIFO Vacancy | R |
| `0x10` | `TDFD` | Transmit Data FIFO Data Write Port (Offset `0x0000` for AXI4) | W |
| `0x14` | `TLR` | Transmit Length Register | W |
| `0x18` | `RDFR` | Receive Data FIFO Reset (`0xA5` to reset) | W |
| `0x1C` | `RDFO` | Receive Data FIFO Occupancy | R |
| `0x20` | `RDFD` | Receive Data FIFO Data Read Port (Offset `0x1000` for AXI4) | R |
| `0x24` | `RLR` | Receive Length Register | R |
| `0x28` | `SRR` | AXI4-Stream Reset (`0xA5` to reset) | W |
| `0x2C` | `TDR` | Transmit Destination Register | W |
| `0x30` | `RDR` | Receive Destination Register | R |
| `0x44` | `TX_ECC_CFG` | Transmit FIFO ECC Configuration Register | R/W |
| `0x48` | `TX_ECC_CNT` | Transmit FIFO ECC Error Counter Register | R |
| `0x4C` | `RX_ECC_CFG` | Receive FIFO ECC Configuration Register | R/W |
| `0x50` | `RX_ECC_CNT` | Receive FIFO ECC Error Counter Register | R |

## 5. Verification Test Plan & Scenarios

### 5.1. Register and Reset Tests
*   **RAL HW Reset Test**: Verify default reset values of all registers.
*   **RAL Bit Bash Test**: Verify R/W access for all supported registers.
*   **Software Reset Test**: Write `0xA5` to `TDFR`, `RDFR`, and `SRR` and verify the respective completion interrupts (`TRC`, `RRC`).

### 5.2. Datapath Tests (Normal Operations)
*   **TX Store-and-Forward**: Write data to `TDFD`, then write packet length to `TLR`. Verify AXI4-Stream `TXD` interface drives the packet correctly with `TLAST` at the end.
*   **TX Cut-Through**: Configure IP in Cut-Through mode. Verify that `TXD` begins transmission before the full packet is written, closing properly once `TLR` is updated.
*   **RX Store-and-Forward**: Drive a packet on `RXD`. Verify `RDFO` reflects correct occupancy. Read `RLR` to get length, then read data from `RDFD`.
*   **RX Cut-Through**: Drive a large packet on `RXD`. Verify `RLR` indicates a partial packet (bit 31=1) and allow continuous reading from `RDFD` before `TLAST` arrives.
*   **Full Duplex**: Simultaneously transmit and receive packets with random delays and backpressure.

### 5.3. Interrupt Verification
*   **TX/RX Complete (`TC`, `RC`)**: Verify interrupts trigger upon successful packet TX/RX.
*   **Programmable Empty/Full (`RFPE`, `RFPF`, `TFPE`, `TFPF`)**: Hit programmable thresholds on FIFOs by slowly draining/filling them, ensuring interrupts toggle correctly.
*   **Interrupt Enable/Disable**: Mask and unmask interrupts in `IER` and verify `interrupt` pin behavior.

### 5.4. Error & Corner Case Scenarios
*   **Transmit Size Error (`TSE`)**: Write mismatched word counts to `TDFD` vs length in `TLR`.
*   **Transmit Packet Overrun (`TPOE`)**: Attempt to write to `TDFD` when `TDFV` (Vacancy) is 0.
*   **Receive Packet Underrun (`RPUE`)**: Attempt to read `RDFD` when `RDFO` (Occupancy) is 0.
*   **Receive Packet Overrun Read (`RPORE`)**: Read more words from `RDFD` than specified in the current packet.
*   **Receive Underrun Read (`RPURE`)**: Read `RLR` when it is empty.
*   **ECC Errors (`TFE1BE`, `TFE2BE`, `RFE1BE`, `RFE2BE`)**: Using backdoor memory access (if supported by simulation model), inject 1-bit and 2-bit errors into the TX/RX FIFOs and verify the interrupt flags and error counters.
*   **Backpressure Handling**: Apply heavy backpressure on `AXI_STR_TXD` `TREADY` and observe `TDFV` vacancy decreasing correctly. Apply backpressure on AXI4-Lite read channels.

### 5.5. AXI4-Stream Control (TXC) Tests
*   Verify that driving `TDR` (Transmit Destination Register) correctly routes sideband/control info if the Ethernet partial CSUM feature is used via the `TXC` interface.

## 6. Coverage Goals
*   **Code Coverage**: 100% Line, Condition, FSM, and Toggle coverage (waiving unreachable logic).
*   **Functional Coverage**:
    *   Cross coverage of all FIFO states (Empty, Partial, Full) with read/write operations.
    *   Cross coverage of all Interrupts with respective enabling/disabling states.
    *   Cross coverage of AXI4-Stream `TDATA` widths (if DUT is configurable).
    *   All error conditions hit at least once.
