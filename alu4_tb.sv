`timescale 1ns/1ps

module alu4_tb;

    logic [3:0] A, B;
    logic [2:0] opcode;
    logic [3:0] result;
    logic       carry_borrow;
    logic       zero;

    int pass_count = 0;
    int fail_count = 0;

    // .* connects every port to the signal with the same name
    alu4 uut (.*);

    // Named opcodes
    typedef enum logic [2:0] {
        OP_ADD = 3'b000,
        OP_SUB = 3'b001,
        OP_AND = 3'b010,
        OP_OR  = 3'b011,
        OP_XOR = 3'b100
    } op_t;

    // Apply inputs, wait, then compare the outputs with the expected values
    task automatic check(
        input string      name,
        input logic [3:0] a_in,
        input logic [3:0] b_in,
        input op_t        op,
        input logic [3:0] exp_result,
        input logic       exp_cb
    );
        string status;
        logic  exp_zero;

        exp_zero = (exp_result == 4'b0000);

        A      = a_in;
        B      = b_in;
        opcode = op;
        #10;

        if (result === exp_result && carry_borrow === exp_cb && zero === exp_zero) begin
            status = "PASS";
            pass_count++;
        end else begin
            status = "FAIL";
            fail_count++;
        end

        $display("%-10s  %b  %b  %b  |  %b      %b          %b    |  %s",
                 name, A, B, opcode, result, carry_borrow, zero, status);
    endtask

    initial begin
        $display("==============================================================");
        $display("            4-BIT ALU SIMULATION (SystemVerilog)");
        $display("==============================================================");
        $display("Test          A     B    OP   | Result Carry/Borrow Zero | Status");
        $display("--------------------------------------------------------------");

        check("ADD 5+3",  4'd5,  4'd3, OP_ADD, 4'd8,  1'b0);   // 8
        check("ADD 15+1", 4'd15, 4'd1, OP_ADD, 4'd0,  1'b1);   // 0 with carry
        check("SUB 5-3",  4'd5,  4'd3, OP_SUB, 4'd2,  1'b0);   // 2
        check("SUB 3-5",  4'd3,  4'd5, OP_SUB, 4'd14, 1'b1);   // 14 with borrow
        check("AND 5&3",  4'd5,  4'd3, OP_AND, 4'd1,  1'b0);   // 1
        check("OR 5|3",   4'd5,  4'd3, OP_OR,  4'd7,  1'b0);   // 7
        check("XOR 5^3",  4'd5,  4'd3, OP_XOR, 4'd6,  1'b0);   // 6
        check("SUB 5-5",  4'd5,  4'd5, OP_SUB, 4'd0,  1'b0);   // zero flag

        $display("==============================================================");
        $display("  Passed: %0d    Failed: %0d", pass_count, fail_count);
        $display("==============================================================");

        $stop;
    end

endmodule
