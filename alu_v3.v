`timescale 1ns/1ps

module alu_system_v3
(
    input clk,
    input rst_n,

    input valid,

    input [2:0] opcode,
    input [7:0] A,
    input [7:0] B,

    output reg [7:0] result,
    output reg carry,
    output reg valid_out,

    output reg [31:0] toggle_count
);

//====================================================
// Operand Isolation
//====================================================

wire [7:0] A_iso;
wire [7:0] B_iso;

assign A_iso = valid ? A : 8'd0;
assign B_iso = valid ? B : 8'd0;

//====================================================
// ALU
//====================================================

reg [8:0] alu_temp;

always @(*)
begin
    case(opcode)

        3'b000:
            alu_temp = A_iso + B_iso;

        3'b001:
            alu_temp = A_iso - B_iso;

        3'b010:
            alu_temp = {1'b0,(A_iso & B_iso)};

        3'b011:
            alu_temp = {1'b0,(A_iso | B_iso)};

        3'b100:
            alu_temp = {1'b0,(A_iso ^ B_iso)};

        3'b101:
            alu_temp = {1'b0,(A_iso << 1)};

        3'b110:
            alu_temp = {1'b0,(A_iso >> 1)};

        3'b111:
            alu_temp = (A_iso > B_iso) ? 9'd1 : 9'd0;

        default:
            alu_temp = 9'd0;

    endcase
end

//====================================================
// Previous Result Storage
//====================================================

reg [7:0] prev_result;

//====================================================
// Sequential Logic
//====================================================

always @(posedge clk or negedge rst_n)
begin

    if(!rst_n)
    begin
        result       <= 8'd0;
        carry        <= 1'b0;
        valid_out    <= 1'b0;
        toggle_count <= 32'd0;
        prev_result  <= 8'd0;
    end

    else
    begin

        //------------------------------------------------
        // Clock-Gating-Friendly Enable
        //------------------------------------------------

        if(valid)
        begin

            result    <= alu_temp[7:0];
            carry     <= alu_temp[8];
            valid_out <= 1'b1;

            //--------------------------------------------
            // Activity Monitor
            //--------------------------------------------

            if(alu_temp[7:0] != prev_result)
                toggle_count <= toggle_count + 1'b1;

            prev_result <= alu_temp[7:0];

        end

        else
        begin

            valid_out <= 1'b0;

        end

    end

end

endmodule
