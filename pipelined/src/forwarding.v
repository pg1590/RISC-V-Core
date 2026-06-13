module ForwardingUnit (
    input [4:0] ID_EX_RegisterA,
    input [4:0] ID_EX_RegisterB,
    input [4:0] EX_MEM_rd,
    input [4:0] MEM_WB_rd,
    input EX_MEM_RegWrite,
    input MEM_WB_RegWrite,
    
    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB
);

wire [4:0] EX_MEM_Rd;
assign EX_MEM_Rd = EX_MEM_rd; 

wire [4:0] MEM_WB_Rd;
assign MEM_WB_Rd = MEM_WB_rd;

always @(*) begin
    // Default: No forwarding (register file values used)
    ForwardA = 2'b00;
    ForwardB = 2'b00;
    
    // First Priority: Forward from EX/MEM stage (most recent result)
    if (EX_MEM_RegWrite && 
        (EX_MEM_Rd != 0) && 
        (EX_MEM_Rd == ID_EX_RegisterA)) begin
        ForwardA = 2'b10;
    end
    
    if (EX_MEM_RegWrite && 
        (EX_MEM_Rd != 0) && 
        (EX_MEM_Rd == ID_EX_RegisterB)) begin
        ForwardB = 2'b10;
    end
    
    // Second Priority: Forward from MEM/WB stage
    // Additional check to prevent multiple forwarding for same register
    if (MEM_WB_RegWrite && 
        (MEM_WB_Rd != 0) && 
        (MEM_WB_Rd == ID_EX_RegisterA) &&
        !(EX_MEM_RegWrite && (EX_MEM_Rd != 0) && (EX_MEM_Rd == ID_EX_RegisterA))) begin
        ForwardA = 2'b01;
    end
    
    if (MEM_WB_RegWrite && 
        (MEM_WB_Rd != 0) && 
        (MEM_WB_Rd == ID_EX_RegisterB) &&
        !(EX_MEM_RegWrite && (EX_MEM_Rd != 0) && (EX_MEM_Rd == ID_EX_RegisterB))) begin
        ForwardB = 2'b01;
    end
    
    // If both EX/MEM and MEM/WB stages can forward to same register
    if (EX_MEM_RegWrite && MEM_WB_RegWrite &&
        (EX_MEM_Rd != 0) && (MEM_WB_Rd != 0) &&
        (EX_MEM_Rd == ID_EX_RegisterA) && (MEM_WB_Rd == ID_EX_RegisterA)) begin
        // Prioritize EX/MEM stage forwarding
        ForwardA = 2'b10;
    end
    
    if (EX_MEM_RegWrite && MEM_WB_RegWrite &&
        (EX_MEM_Rd != 0) && (MEM_WB_Rd != 0) &&
        (EX_MEM_Rd == ID_EX_RegisterB) && (MEM_WB_Rd == ID_EX_RegisterB)) begin
        // Prioritize EX/MEM stage forwarding
        ForwardB = 2'b10;
    end
end

endmodule   