`timescale 1ns/1ps

// 4-bit ALU (SystemVerilog version)
module alu4 (
    input  logic [3:0] A,
    input  logic [3:0] B,
    input  logic [2:0] opcode,
    output logic [3:0] result,
    output logic       carry_borrow,
    output logic       zero
);

    // Named opcodes instead of raw binary numbers
    typedef enum logic [2:0] {
        OP_ADD = 3'b000,
        OP_SUB = 3'b001,
        OP_AND = 3'b010,
        OP_OR  = 3'b011,
        OP_XOR = 3'b100
    } op_t;

    logic [4:0] temp;

    // always_comb = combinational logic (re-runs whenever an input changes)
    always_comb begin
        result       = 4'b0000;
        carry_borrow = 1'b0;
        temp         = 5'b00000;

        case (opcode)

            OP_ADD: begin
                temp         = {1'b0, A} + {1'b0, B};
                result       = temp[3:0];
                carry_borrow = temp[4];
            end

            OP_SUB: begin
                result       = A - B;
                carry_borrow = (A < B);
            end

            OP_AND: result = A & B;

            OP_OR:  result = A | B;

            OP_XOR: result = A ^ B;

            default: begin
                result       = 4'b0000;
                carry_borrow = 1'b0;
            end

        endcase

        // Zero flag
        zero = (result == 4'b0000);
    end

endmodule
