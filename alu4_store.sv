`timescale 1ns/1ps

// 4-bit ALU + memory to store results (SystemVerilog version)
// Each memory location holds 6 bits: {zero, carry_borrow, result[3:0]}
module alu4_store (
    input  logic       clk,
    input  logic       we,        // write enable (1 = store ALU output)
    input  logic [3:0] addr,      // memory address (0 to 15)
    input  logic [3:0] A,
    input  logic [3:0] B,
    input  logic [2:0] opcode,
    output logic [5:0] dout       // data read back from memory
);

    logic [3:0] result;
    logic       carry_borrow;
    logic       zero;

    // ALU (alu4.sv)
    alu4 alu (
        .A(A),
        .B(B),
        .opcode(opcode),
        .result(result),
        .carry_borrow(carry_borrow),
        .zero(zero)
    );

    // Memory: 16 locations, 6 bits each  ([16] is the same as [0:15])
    logic [5:0] mem [16];

    // always_ff = clocked (sequential) logic
    always_ff @(posedge clk) begin
        if (we)
            mem[addr] <= {zero, carry_borrow, result};   // store data
        dout <= mem[addr];                               // read data
    end

endmodule
