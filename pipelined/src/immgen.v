module immgen(
    input [31:0] instr,  // 32-bit instruction
    output reg [63:0] imm // 64-bit immediate value
);

    // Extract the opcode (bits [6:0]) to determine the instruction format
    wire [6:0] opcode = instr[6:0];

    always @(*) begin
        case (opcode)
            // I-type instructions (e.g., ADDI, LW)
            7'b0010011, 7'b0000011: begin
                imm = { {52{instr[31]}}, instr[31:20] }; // Sign-extend imm[11:0]
            end

            // S-type instructions (e.g., SW)
            7'b0100011: begin
                imm = { {52{instr[31]}}, instr[31:25], instr[11:7] }; // Sign-extend imm[11:5] and imm[4:0]
            end

            // B-type instructions (e.g., BEQ, BNE)
            7'b1100011: begin
                imm = { {52{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0 }; // Sign-extend imm[12:1]
            end

            // U-type instructions (e.g., LUI, AUIPC)
            7'b0110111, 7'b0010111: begin
                imm = { {32{instr[31]}}, instr[31:12], 12'b0 }; // Sign-extend imm[31:12]
            end

            // J-type instructions (e.g., JAL)
            7'b1101111: begin
                imm = { {44{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 }; // Sign-extend imm[20:1]
            end

            // Default case (zero-extend or handle unsupported formats)
            default: begin
                imm = 64'b0; // Default to 0 for unsupported formats
            end
        endcase
    end

endmodule