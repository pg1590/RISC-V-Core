module hazard_detection(
    input  wire        idex_mem_read,     // 1 if ID/EX instruction is a load
    input  wire [4:0]  idex_reg_rd,       // Destination register of the load
    input  wire [31:0] ifid_instruction,  // Current IF/ID instruction (contains Rs1/Rs2)
    output reg         pc_write,          // PC update enable (stall if 0)
    output reg         ifid_write,        // IF/ID register update enable (stall if 0)
    output reg         idex_flush         // Flush/insert bubble in ID/EX if 1
);

  wire [4:0] ifid_rs1 = ifid_instruction[19:15];
  wire [4:0] ifid_rs2 = ifid_instruction[24:20];

  always @(*) begin
    // Default behavior: no stall, normal pipeline operation
    pc_write   = 1'b1;
    ifid_write = 1'b1;
    idex_flush = 1'b0;

    // Check for load-use hazard:
    // if (ID/EX is a load) AND (destination register == IF/ID's Rs1 or Rs2)
    if (idex_mem_read &&
        ((idex_reg_rd == ifid_rs1) || (idex_reg_rd == ifid_rs2)) &&
        (idex_reg_rd != 5'd0)) 
    begin
      // Stall the pipeline
      pc_write   = 1'b0;  // Freeze PC (no new instruction fetch)
      ifid_write = 1'b0;  // Freeze IF/ID register
      idex_flush = 1'b1;  // Next cycle: turn the ID/EX instruction into a bubble
    end
  end

endmodule