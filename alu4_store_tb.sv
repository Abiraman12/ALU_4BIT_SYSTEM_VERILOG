`timescale 1ns/1ps

module alu4_store_tb;

    logic       clk = 0;
    logic       we;
    logic [3:0] addr;
    logic [3:0] A, B;
    logic [2:0] opcode;
    logic [5:0] dout;          // {zero, carry_borrow, result[3:0]}

    // .* connects every port to the signal with the same name
    alu4_store uut (.*);

    // Clock: 10 ns period
    always #5 clk = ~clk;

    // Named opcodes
    typedef enum logic [2:0] {
        OP_ADD = 3'b000,
        OP_SUB = 3'b001,
        OP_AND = 3'b010,
        OP_OR  = 3'b011,
        OP_XOR = 3'b100
    } op_t;

    // Test names (only used to make the printed table easy to read)
    string label [16];

    // Call this task to run the ALU and STORE the result at address ad
    task automatic store_result(
        input string      name,
        input logic [3:0] a_in,
        input logic [3:0] b_in,
        input op_t        op,
        input logic [3:0] ad
    );
        begin
            label[ad] = name;
            @(negedge clk);
            A = a_in; B = b_in; opcode = op; addr = ad; we = 1;
            @(negedge clk);
            we = 0;
        end
    endtask

    // Call this task to READ the stored result from address ad
    task automatic read_result(input logic [3:0] ad);
        begin
            @(negedge clk);
            addr = ad; we = 0;
            @(negedge clk);
            $display("  %2d    %-9s  %b    %2d         %b          %b",
                     ad, label[ad], dout[3:0], dout[3:0], dout[4], dout[5]);
        end
    endtask

    initial begin
        we = 0; addr = 0; A = 0; B = 0; opcode = 0;

        // ---------------- STORE ----------------
        store_result("ADD 5+3",  4'd5,  4'd3, OP_ADD, 4'd0);
        store_result("ADD 15+1", 4'd15, 4'd1, OP_ADD, 4'd1);   // carry
        store_result("SUB 5-3",  4'd5,  4'd3, OP_SUB, 4'd2);
        store_result("SUB 3-5",  4'd3,  4'd5, OP_SUB, 4'd3);   // borrow
        store_result("AND 5&3",  4'd5,  4'd3, OP_AND, 4'd4);
        store_result("OR 5|3",   4'd5,  4'd3, OP_OR,  4'd5);
        store_result("XOR 5^3",  4'd5,  4'd3, OP_XOR, 4'd6);
        store_result("SUB 5-5",  4'd5,  4'd5, OP_SUB, 4'd7);   // zero

        // ---------------- READ BACK ----------------
        $display("=================================================================");
        $display("     STORED ALU RESULTS (read from memory) - SystemVerilog");
        $display("=================================================================");
        $display("  Addr  Test       Result  Dec   Carry/Borrow  Zero");
        $display("-----------------------------------------------------------------");

        for (int i = 0; i < 8; i++)
            read_result(4'(i));

        $display("=================================================================");
        #10 $finish;
    end

endmodule
