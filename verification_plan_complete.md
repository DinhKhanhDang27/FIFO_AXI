# Verification Plan Complete

## 1. Revision

| Revision ID | Date | Description | P.I.C | Review |
| :--- | :--- | :--- | :--- | :--- |
| 0 | 13/08/2026 | Initial Verification Plan based on Spec | DV Engineer | |

---

## 2. Scansheet

| Line num | Quotation (Feature from Spec) | CHK/NOCHK | Test vector |
| :--- | :--- | :--- | :--- |
| 1 | AXI4-Lite / AXI4 Slave Interface: Register access and data FIFO access. | CHK | `axi4_lite_reg_access_test` |
| 2 | AXI4-Stream Interfaces: Transmit Data (TXD), Transmit Control (TXC), Receive Data (RXD). | CHK | `tx_store_forward_test`, `rx_store_forward_test` |
| 3 | Datapath Mode: Store-and-Forward Mode. | CHK | `tx_store_forward_test`, `rx_store_forward_test` |
| 4 | Datapath Mode: Cut-Through Mode. | CHK | `tx_cut_through_test`, `rx_cut_through_test` |
| 5 | Interrupts: Status and error conditions (Completion, Overrun, Underrun, Size Error, ECC errors, Reset completion). | CHK | `interrupt_completion_test`, `interrupt_threshold_test`, `tx_size_error_test`, `tx_overrun_error_test`, `rx_underrun_error_test` |
| 6 | Error Correction Code (ECC): 1-bit and 2-bit error injection and reporting for both TX and RX FIFOs. | CHK | `tx_ecc_error_test`, `rx_ecc_error_test` |
| 7 | Independent FIFOs: Full duplex operation of TX and RX FIFOs. | CHK | `full_duplex_test` |
| 8 | Reset Operations: Global reset, TX FIFO reset, RX FIFO reset, and AXI4-Stream reset. | CHK | `hw_reset_test`, `sw_reset_test` |

---

## 3. Testlist

| Item No | Cat 1 (Feature) | Cat 2 (Sub-feature) | Cat 3 (Type) | Test description | Check description | Test name | Cover point |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | Register | AXI4-Lite | Normal | Verify read/write access for all supported registers | Read value matches written value (for R/W registers) | `axi4_lite_reg_access_test` | Register coverage |
| 2 | Reset | Hardware | Normal | Assert `s_axi_aresetn` and verify default values | Registers return to default values | `hw_reset_test` | HW Reset coverage |
| 3 | Reset | Software | Normal | Write `0xA5` to `TDFR`, `RDFR`, `SRR` and check reset behavior | Internal FIFOs reset, `TRC`/`RRC` interrupts assert | `sw_reset_test` | SW Reset coverage |
| 4 | TX Datapath | Store-and-Forward | Normal | Write data to `TDFD`, then packet length to `TLR` | AXI4-Stream `TXD` drives correct packet with `TLAST` | `tx_store_forward_test` | TX Store-and-Forward cover point |
| 5 | TX Datapath | Cut-Through | Normal | Configure cut-through, write data to `TDFD` | `TXD` transmission starts before `TLR` is written | `tx_cut_through_test` | TX Cut-Through cover point |
| 6 | RX Datapath | Store-and-Forward | Normal | Drive packet on `RXD`, read `RDFD` | Data matches driven packet, `RDFO` is correct | `rx_store_forward_test` | RX Store-and-Forward cover point |
| 7 | RX Datapath | Cut-Through | Normal | Drive packet on `RXD`, read `RDFD` while receiving | `RLR` indicates partial packet (bit 31=1), data matches | `rx_cut_through_test` | RX Cut-Through cover point |
| 8 | Datapath | Full Duplex | Normal | Simultaneously transmit and receive packets | Both TX and RX packets are processed correctly | `full_duplex_test` | Full Duplex cover point |
| 9 | Interrupt | TX/RX Complete | Normal | Complete a TX and RX transfer successfully | `TC` and `RC` interrupts assert in `ISR` | `interrupt_completion_test` | Interrupt TC/RC cover point |
| 10 | Interrupt | Prog Empty/Full | Normal | Fill/drain FIFOs to hit threshold values | `RFPE`, `RFPF`, `TFPE`, `TFPF` interrupts assert | `interrupt_threshold_test` | Interrupt Threshold cover point |
| 11 | Error | Transmit Size | Error | Mismatch `TDFD` word counts and `TLR` length | `TSE` interrupt asserts | `tx_size_error_test` | TSE error cover point |
| 12 | Error | Transmit Overrun | Error | Attempt to write `TDFD` when `TDFV` (vacancy) is 0 | `TPOE` interrupt asserts | `tx_overrun_error_test` | TPOE error cover point |
| 13 | Error | Receive Underrun | Error | Attempt to read `RDFD` when `RDFO` (occupancy) is 0 | `RPUE` interrupt asserts | `rx_underrun_error_test` | RPUE error cover point |
| 14 | Error | Receive Overrun Read| Error | Read more words from `RDFD` than current packet size | `RPORE` interrupt asserts | `rx_overrun_read_test` | RPORE error cover point |
| 15 | ECC | Transmit FIFO | Error | Inject 1-bit and 2-bit errors in TX FIFO via backdoor | `TFE1BE`/`TFE2BE` assert, error counters increment | `tx_ecc_error_test` | TX ECC cover point |
| 16 | ECC | Receive FIFO | Error | Inject 1-bit and 2-bit errors in RX FIFO via backdoor | `RFE1BE`/`RFE2BE` assert, error counters increment | `rx_ecc_error_test` | RX ECC cover point |
| 17 | Datapath | Backpressure | Boundary | Apply random backpressure on `TXD` `TREADY` and AXI4-Lite | Data integrity preserved, no packet drop | `backpressure_test` | Backpressure cover point |
