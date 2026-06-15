`timescale 1ns/1ps

//==========================================================
// VERSION-2
// LOW-POWER PROCESSING SUBSYSTEM
// FEATURES:
// 1. CLOCK GATING
// 2. OPERAND ISOLATION
// 3. ACTIVITY MONITOR
// 4. DATAPATH FREEZING
//==========================================================

module alu_system_v2 #
(
    parameter WIDTH = 8
)
(
    input                       clk,
    input                       rst_n,

    input                       valid,

    input       [2:0]           opcode,

    input       [WIDTH-1:0]     A,
    input       [WIDTH-1:0]     B,

    output reg  [WIDTH-1:0]     result,
    output reg                  carry,

    output reg                  valid_out,

    output      [31:0]          toggle_count
);

    //------------------------------------------------------
    // OPERATION ENABLES
    //------------------------------------------------------

    wire add_en;
    wire sub_en;
    wire logic_en;
    wire shift_en;
    wire cmp_en;

    //------------------------------------------------------
    // CLOCK GATING ENABLE
    //------------------------------------------------------

    wire alu_enable;

    assign alu_enable =
            add_en   |
            sub_en   |
            logic_en |
            shift_en |
            cmp_en;

    //------------------------------------------------------
    // GATED CLOCK
    //------------------------------------------------------

    wire gclk;

    assign gclk = clk & alu_enable;

    //------------------------------------------------------
    // CONTROL UNIT
    //------------------------------------------------------

    control_unit_v2 u_ctrl
    (
        .opcode(opcode),

        .add_en(add_en),
        .sub_en(sub_en),
        .logic_en(logic_en),
        .shift_en(shift_en),
        .cmp_en(cmp_en)
    );

    //------------------------------------------------------
    // OPERAND ISOLATION
    //------------------------------------------------------

    wire [WIDTH-1:0] arith_A;
    wire [WIDTH-1:0] arith_B;

    wire [WIDTH-1:0] logic_A;
    wire [WIDTH-1:0] logic_B;

    wire [WIDTH-1:0] shift_A;

    assign arith_A = (add_en || sub_en) ? A : {WIDTH{1'b0}};
    assign arith_B = (add_en || sub_en) ? B : {WIDTH{1'b0}};

    assign logic_A = logic_en ? A : {WIDTH{1'b0}};
    assign logic_B = logic_en ? B : {WIDTH{1'b0}};

    assign shift_A = shift_en ? A : {WIDTH{1'b0}};

    //------------------------------------------------------
    // FUNCTIONAL UNIT OUTPUTS
    //------------------------------------------------------

    reg [WIDTH-1:0] arithmetic_result;
    reg [WIDTH-1:0] logic_result;
    reg [WIDTH-1:0] shift_result;
    reg [WIDTH-1:0] compare_result;

    reg arithmetic_carry;

    //------------------------------------------------------
    // ARITHMETIC UNIT
    //------------------------------------------------------

    always @(*) begin

        arithmetic_result = {WIDTH{1'b0}};
        arithmetic_carry  = 1'b0;

        if(add_en) begin

            {arithmetic_carry, arithmetic_result}
                = arith_A + arith_B;

        end

        else if(sub_en) begin

            {arithmetic_carry, arithmetic_result}
                = arith_A - arith_B;

        end

    end

    //------------------------------------------------------
    // LOGIC UNIT
    //------------------------------------------------------

    always @(*) begin

        logic_result = {WIDTH{1'b0}};

        if(logic_en) begin

            case(opcode)

                3'b010:
                    logic_result = logic_A & logic_B;

                3'b011:
                    logic_result = logic_A | logic_B;

                3'b100:
                    logic_result = logic_A ^ logic_B;

                default:
                    logic_result = {WIDTH{1'b0}};

            endcase

        end

    end

    //------------------------------------------------------
    // SHIFT UNIT
    //------------------------------------------------------

    always @(*) begin

        shift_result = {WIDTH{1'b0}};

        if(shift_en) begin

            case(opcode)

                3'b101:
                    shift_result = shift_A << 1;

                3'b110:
                    shift_result = shift_A >> 1;

                default:
                    shift_result = {WIDTH{1'b0}};

            endcase

        end

    end

    //------------------------------------------------------
    // COMPARATOR
    //------------------------------------------------------

    always @(*) begin

        compare_result = {WIDTH{1'b0}};

        if(cmp_en) begin

            compare_result =
                (A > B) ?
                {{(WIDTH-1){1'b0}},1'b1} :
                {WIDTH{1'b0}};
        end

    end

    //------------------------------------------------------
    // RESULT MUX
    //------------------------------------------------------

    reg [WIDTH-1:0] final_result;
    reg final_carry;

    always @(*) begin

        final_result = {WIDTH{1'b0}};
        final_carry  = 1'b0;

        if(add_en || sub_en) begin

            final_result = arithmetic_result;
            final_carry  = arithmetic_carry;

        end

        else if(logic_en) begin

            final_result = logic_result;

        end

        else if(shift_en) begin

            final_result = shift_result;

        end

        else if(cmp_en) begin

            final_result = compare_result;

        end

    end

    //------------------------------------------------------
    // REGISTERED OUTPUTS
    //------------------------------------------------------

    always @(posedge gclk or negedge rst_n) begin

        if(!rst_n) begin

            result      <= {WIDTH{1'b0}};
            carry       <= 1'b0;
            valid_out   <= 1'b0;

        end

        else begin

            if(valid) begin

                result      <= final_result;
                carry       <= final_carry;
                valid_out   <= 1'b1;

            end

            else begin

                valid_out <= 1'b0;

            end

        end

    end

    //------------------------------------------------------
    // ACTIVITY MONITOR
    //------------------------------------------------------

    activity_monitor_v2 #
    (
        .WIDTH(WIDTH)
    )
    u_monitor
    (
        .clk(clk),
        .rst_n(rst_n),

        .signal_in(result),

        .toggle_count(toggle_count)
    );

endmodule

//==========================================================
// CONTROL UNIT
//==========================================================

module control_unit_v2
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
// ACTIVITY MONITOR
//==========================================================

module activity_monitor_v2 #
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

integer i;

always @(posedge clk or negedge rst_n) begin

    if(!rst_n) begin

        prev_signal    <= {WIDTH{1'b0}};
        toggle_count   <= 32'd0;
    end

    else begin

        for(i=0;i<WIDTH;i=i+1)
            toggle_count <= toggle_count + toggle_vector[i];

        prev_signal <= signal_in;

    end

end

endmodule
