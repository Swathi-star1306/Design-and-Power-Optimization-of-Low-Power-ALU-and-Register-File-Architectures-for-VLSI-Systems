`timescale 1ns/1ps

//==========================================================
// INDUSTRY-LEVEL BASELINE LOW-POWER PROCESSING SUBSYSTEM
// VERSION-1 : BASELINE ARCHITECTURE
// CADENCE RTL-to-GDS FRIENDLY
//==========================================================

module alu_system #
(
    parameter WIDTH = 8,
    parameter DEPTH = 8
)
(
    input                       clk,
    input                       rst_n,

    input                       valid,

    input       [2:0]           opcode,
    input       [WIDTH-1:0]     A,
    input       [WIDTH-1:0]     B,

    input                       wr_en,
    input       [2:0]           wr_addr,

    output reg  [WIDTH-1:0]     result,
    output reg                  carry,
    output reg                  valid_out,

    output      [31:0]          toggle_count
);

    //------------------------------------------------------
    // Internal Enables
    //------------------------------------------------------

    wire add_en;
    wire sub_en;
    wire logic_en;
    wire shift_en;
    wire cmp_en;

    //------------------------------------------------------
    // Internal Signals
    //------------------------------------------------------

    wire [WIDTH-1:0] alu_result;
    wire alu_carry;

    //------------------------------------------------------
    // Control Unit
    //------------------------------------------------------

    control_unit u_ctrl
    (
        .opcode(opcode),

        .add_en(add_en),
        .sub_en(sub_en),
        .logic_en(logic_en),
        .shift_en(shift_en),
        .cmp_en(cmp_en)
    );

    //------------------------------------------------------
    // ALU Core
    //------------------------------------------------------

    alu_core #
    (
        .WIDTH(WIDTH)
    )
    u_alu
    (
        .A(A),
        .B(B),
        .opcode(opcode),

        .add_en(add_en),
        .sub_en(sub_en),
        .logic_en(logic_en),
        .shift_en(shift_en),
        .cmp_en(cmp_en),

        .result(alu_result),
        .carry(alu_carry)
    );

    //------------------------------------------------------
    // Register File
    //------------------------------------------------------

    register_file #
    (
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    )
    u_regfile
    (
        .clk(clk),
        .rst_n(rst_n),

        .wr_en(wr_en),
        .wr_addr(wr_addr),

        .wr_data(alu_result)
    );

    //------------------------------------------------------
    // Activity Monitor
    //------------------------------------------------------

    activity_monitor #
    (
        .WIDTH(WIDTH)
    )
    u_monitor
    (
        .clk(clk),
        .rst_n(rst_n),

        .signal_in(alu_result),

        .toggle_count(toggle_count)
    );

    //------------------------------------------------------
    // Output Registers
    //------------------------------------------------------

    always @(posedge clk or negedge rst_n) begin

        if(!rst_n) begin

            result      <= {WIDTH{1'b0}};
            carry       <= 1'b0;
            valid_out   <= 1'b0;

        end

        else begin

            if(valid) begin

                result      <= alu_result;
                carry       <= alu_carry;
                valid_out   <= 1'b1;

            end

            else begin

                valid_out <= 1'b0;

            end

        end

    end

endmodule

//==========================================================
// CONTROL UNIT
//==========================================================

module control_unit
(
    input   [2:0] opcode,

    output reg add_en,
    output reg sub_en,
    output reg logic_en,
    output reg shift_en,
    output reg cmp_en
);

always @(*) begin

    add_en     = 1'b0;
    sub_en     = 1'b0;
    logic_en   = 1'b0;
    shift_en   = 1'b0;
    cmp_en     = 1'b0;

    case(opcode)

        3'b000: add_en   = 1'b1;

        3'b001: sub_en   = 1'b1;

        3'b010,
        3'b011,
        3'b100: logic_en = 1'b1;

        3'b101,
        3'b110: shift_en = 1'b1;

        3'b111: cmp_en   = 1'b1;

        default: ;

    endcase

end

endmodule

//==========================================================
// ALU CORE
//==========================================================

module alu_core #
(
    parameter WIDTH = 8
)
(
    input       [WIDTH-1:0] A,
    input       [WIDTH-1:0] B,

    input       [2:0] opcode,

    input                   add_en,
    input                   sub_en,
    input                   logic_en,
    input                   shift_en,
    input                   cmp_en,

    output reg  [WIDTH-1:0] result,
    output reg              carry
);

reg [WIDTH:0] arithmetic_out;

always @(*) begin

    result          = {WIDTH{1'b0}};
    carry           = 1'b0;
    arithmetic_out  = {(WIDTH+1){1'b0}};

    //------------------------------------------------------
    // Arithmetic Unit
    //------------------------------------------------------

    if(add_en) begin

        arithmetic_out = A + B;

        result = arithmetic_out[WIDTH-1:0];
        carry  = arithmetic_out[WIDTH];

    end

    //------------------------------------------------------
    // Subtractor
    //------------------------------------------------------

    else if(sub_en) begin

        arithmetic_out = A - B;

        result = arithmetic_out[WIDTH-1:0];
        carry  = arithmetic_out[WIDTH];

    end

    //------------------------------------------------------
    // Logic Unit
    //------------------------------------------------------

    else if(logic_en) begin

        case(opcode)

            3'b010: result = A & B;
            3'b011: result = A | B;
            3'b100: result = A ^ B;

            default: result = {WIDTH{1'b0}};

        endcase

    end

    //------------------------------------------------------
    // Shift Unit
    //------------------------------------------------------

    else if(shift_en) begin

        case(opcode)

            3'b101: result = A << 1;
            3'b110: result = A >> 1;

            default: result = {WIDTH{1'b0}};

        endcase

    end

    //------------------------------------------------------
    // Comparator
    //------------------------------------------------------

    else if(cmp_en) begin

        result = (A > B) ? {{(WIDTH-1){1'b0}},1'b1} :
                           {WIDTH{1'b0}};

    end

end

endmodule

//==========================================================
// REGISTER FILE
//==========================================================

module register_file #
(
    parameter WIDTH = 8,
    parameter DEPTH = 8
)
(
    input                       clk,
    input                       rst_n,

    input                       wr_en,
    input       [2:0]           wr_addr,

    input       [WIDTH-1:0]     wr_data
);

reg [WIDTH-1:0] mem [0:DEPTH-1];

integer i;

always @(posedge clk or negedge rst_n) begin

    if(!rst_n) begin

        for(i=0;i<DEPTH;i=i+1)
            mem[i] <= {WIDTH{1'b0}};
    end

    else begin

        if(wr_en)
            mem[wr_addr] <= wr_data;
    end

end

endmodule

//==========================================================
// ACTIVITY MONITOR
//==========================================================

module activity_monitor #
(
    parameter WIDTH = 8
)
(
    input                       clk,
    input                       rst_n,

    input       [WIDTH-1:0]     signal_in,

    output reg  [31:0]          toggle_count
);

reg [WIDTH-1:0] prev_signal;

wire [WIDTH-1:0] toggle_vector;

assign toggle_vector = signal_in ^ prev_signal;

integer j;

always @(posedge clk or negedge rst_n) begin

    if(!rst_n) begin

        prev_signal    <= {WIDTH{1'b0}};
        toggle_count   <= 32'd0;
    end

    else begin

        for(j=0;j<WIDTH;j=j+1)
            toggle_count <= toggle_count + toggle_vector[j];

        prev_signal <= signal_in;
    end

end

endmodule
