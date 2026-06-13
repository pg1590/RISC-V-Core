`include "alu_control.v"
`include "alu.v"
`include "control.v"
`include "instruction.v"
`include "datamem.v"
`include "registers.v"
`include "immgen.v"
`include "control_mux.v"
`include "hazard_control.v"
`include "forwarding.v"

module main(input clk);

    // all wire declaration
    wire [63:0] next_pc_add, nxt_address_immd, address_1;
    wire PCsrc;
    wire [31:0] instruction;
    wire [63:0] rd1, rd2;
    wire [4:0] rs1, rs2; 
    wire [6:0] opcode;
    wire [2:0] func3;
    wire ALUsrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch;
    wire [1:0] ALUop;
    wire ALUsrc_mux, MemtoReg_mux, RegWrite_mux, MemRead_mux, MemWrite_mux, Branch_mux;
    wire [1:0] ALUop_mux;
    wire [63:0] immediate;
    wire [1:0] alu_opcode;
    wire [3:0] alu_code;
    wire [63:0] src1, src2, pc_sum;
    wire overflow, zero_flag;
    wire [63:0] alu_res;
    wire pc_overflow;
    wire [63:0] intermediate;
    wire [63:0] ReadData;
    wire [63:0] WriterData_final;
    wire pc_write, ifid_write, idex_flush;
    wire [1:0] ForwardA, ForwardB;


    // all reg declaration
    reg [63:0] curr_pc_add;
    reg [63:0] pc_reg;
    reg [31:0] instruction_reg;
    reg [7:0] control_reg;
    reg [63:0] rd1_reg, rd2_reg, immediate_reg, pc_reg2;
    reg [3:0] alu_input;
    reg [4:0] write_reg1;
    reg [4:0] rs1_reg, rs2_reg;
    reg RegWrite_final, MemtoReg_final;
    reg [63:0] ReadData_reg, address_reg;
    reg [4:0] write_reg3;
    reg [4:0] control_reg2, write_reg2;
    reg zero_reg;
    reg [63:0] pc_reg3,alu_res_reg, rd2_reg2;

    initial begin
        curr_pc_add = 64'b0;
        pc_reg = 64'b0;
        instruction_reg = 32'b0;
        control_reg = 8'b0;
        rd1_reg = 64'b0;
        rd2_reg = 64'b0;
        immediate_reg = 64'b0;
        pc_reg2 = 64'b0;
        alu_input = 4'b0;
        write_reg1 = 5'b0;
        rs1_reg = 5'b0;
        rs2_reg = 5'b0;
        control_reg2 = 5'b0;
        write_reg2 = 5'b0;
        zero_reg = 1'b0;
        pc_reg3 = 64'b0;
        alu_res_reg = 64'b0;
        rd2_reg2 = 64'b0;
        RegWrite_final = 1'b0;
        MemtoReg_final = 1'b0;
        ReadData_reg = 64'b0;
        address_reg = 64'b0;
        write_reg3 = 5'b0;
    end

    initial begin
        curr_pc_add <= 64'b0;
    end

    assign nxt_address_immd = 64'd4;

    bit_adder_64 u_adder1(.a(curr_pc_add),.b(nxt_address_immd),.s(address_1));

    // Next PC address
    genvar j;
    generate
        for (j = 0; j<64; j=j+1) begin : pc_loop
            mux2x1 mux_inter(.in0(address_1[j]), .in1(pc_reg3[j]), .select(PCsrc), .out(next_pc_add[j]));
        end
    endgenerate

    always @(posedge clk ) begin
        if(pc_write == 1'b1) begin
            curr_pc_add <= next_pc_add;
        end
    end

    // Branch taken being resolved

    always @(posedge PCsrc) begin
      if(PCsrc == 1'b1) begin
        instruction_reg <= 32'b0;
        control_reg <= 8'b0;
        pc_reg <= 0;
        pc_reg2 <= 0;
        rd1_reg <= 0;
        rd2_reg <= 0;
        immediate_reg <= 0;
        rs1_reg <= 0;
        rs2_reg <= 0;
        write_reg1 <= 0;
      end
    end

/*-------------------------------------------------------------------------*/

    // Between PC and IF/ID register 
    
    // Instruction memory module
    instr_mem_512 uut_instr_mem(
                    .address(curr_pc_add),
                    .instruction(instruction));

    /***********************************************************************/
    wire ifid_write_flush;
    wire not_branch;
    not not_branch_module(not_branch, PCsrc);
    and and_ifid(ifid_write_flush, not_branch, ifid_write);

    always @(posedge clk ) begin
        if(ifid_write_flush == 1'b1) begin
            pc_reg <= curr_pc_add;
            instruction_reg <= instruction;
        end
    end

/*-------------------------------------------------------------------------*/
    // Between IF/ID and ID/EX

    assign opcode = instruction_reg[6:0];
    assign func3 = instruction_reg[14:12];
    assign rs1 = instruction_reg[19:15];
    assign rs2 = instruction_reg[24:20];

    /***********************************************************************/

    // Instantiate the control module
    control uut_control(
                    .opcode(opcode),
                    .ALUsrc(ALUsrc),
                    .MemtoReg(MemtoReg),
                    .RegWrite(RegWrite),
                    .MemRead(MemRead),
                    .MemWrite(MemWrite),
                    .Branch(Branch),
                    .ALUop(ALUop));

    /***********************************************************************/

    // Instatiate the mux and hazard control after control module
    
    hazard_control_mux uut_control_mux(
                    .ALUsrc(ALUsrc),
                    .MemtoReg(MemtoReg),
                    .RegWrite(RegWrite),
                    .MemRead(MemRead),
                    .MemWrite(MemWrite),
                    .Branch(Branch),
                    .ALUop(ALUop),
                    .hz_ctrl(idex_flush),
                    .ALUop_mux(ALUop_mux),
                    .ALUsrc_mux(ALUsrc_mux),
                    .MemtoReg_mux(MemtoReg_mux),
                    .RegWrite_mux(RegWrite_mux),
                    .MemRead_mux(MemRead_mux),
                    .MemWrite_mux(MemWrite_mux),
                    .Branch_mux(Branch_mux));

    /***********************************************************************/
    // The register file here with two outputs
    reg_file_64bit uut_reg_file(
                    .clk(clk),
                    .rs1_addr(rs1),
                    .rs2_addr(rs2),
                    .rs1_data(rd1),
                    .rs2_data(rd2),
                    .rd_addr(write_reg3), //change this when the correct register is initializes
                    .rd_data(WriterData_final), 
                    .reg_write(RegWrite_final)); // change this when correct regwrite initializes

    /***********************************************************************/

   
    // Instantiate the immediate generation module
    immgen uut_immgen(
                    .instr(instruction_reg),
                    .imm(immediate));

    // Loading into the register ID/EX

    always @(posedge clk ) begin
        control_reg <= {Branch_mux, MemWrite_mux, MemRead_mux, RegWrite_mux, MemtoReg_mux, ALUsrc_mux,ALUop_mux[0],ALUop_mux[1]};
        rd1_reg <= rd1;
        rd2_reg <= rd2;
        immediate_reg <= immediate;
        alu_input <= {instruction_reg[30], func3};
        write_reg1 <= instruction_reg[11:7];
        pc_reg2 <= pc_reg;
        rs1_reg <= rs1;
        rs2_reg <= rs2;
    end

/*-------------------------------------------------------------------------*/

    // Between ID/EX and EX/MEM
    
    assign alu_opcode[0] = control_reg[1];
    assign alu_opcode[1] = control_reg[0];

    alu_control alu_control_uut(
                    .func3(alu_input[2:0]),
                    .func7(alu_input[3]),
                    .aluop(alu_opcode),
                    .alu_code(alu_code));

    /***********************************************************************/

    // Instantiate the ALU module    
    genvar i;
    generate
        for (i = 0; i<64; i=i+1) begin : alu_loop
            mux2x1 mux_alu(
                            .out(src2[i]),
                            .select(control_reg[2]),
                            .in0(intermediate[i]),
                            .in1(immediate_reg[i]));  
        end
    endgenerate

    alu alu_uut(
                    .alu_code(alu_code),
                    .src1(src1),
                    .src2(src2),
                    .result(alu_res),
                    .overflow(overflow),
                    .zero_flag(zero_flag));

    /***********************************************************************/

    bit_adder_64 adder_uut(
        .a(pc_reg2), .b(immediate_reg), .s(pc_sum), .overflow(pc_overflow)
    );

    /***********************************************************************/
    // Loading into the register EX/MEM

    always @(posedge clk) begin
        write_reg2 <= write_reg1;
        rd2_reg2 <= intermediate;
        alu_res_reg <= alu_res;
        zero_reg <= zero_reg;
        pc_reg3 <= pc_sum;
        control_reg2 <= control_reg[7:3];
    end
/*-------------------------------------------------------------------------*/    
    // Between EX/MEM and MEM/WB
    
    and and_branch(PCsrc,control_reg2[4],zero_flag);

    // Instantiate the data memory unit 
    data_mem uut_datamem(
                    .Address(alu_res_reg),
                    .WriteData(rd2_reg2),
                    .ReadData(ReadData),
                    .MemRead(control_reg2[2]),
                    .MemWrite(control_reg2[3]),
                    .clk(clk));

    // Loading into the MEM/WB regsiter
    always @(posedge clk) begin
        RegWrite_final <= control_reg2[1];
        MemtoReg_final <= control_reg2[0];
        address_reg <= alu_res_reg;
        ReadData_reg <= ReadData;
        write_reg3 <= write_reg2; 
    end

/*-------------------------------------------------------------------------*/

    // After MEM/WB stage
    genvar k;
    generate
        for (k =0 ;k<64 ;k=k+1) begin
            mux2x1 mux_memtoreg(.in0(address_reg[k]), .in1(ReadData_reg[k]), .select(MemtoReg_final), .out(WriterData_final[k]));
        end
    endgenerate

/*-------------------------------------------------------------------------*/

    // Connecting the Hazard detection unit
    hazard_detection hazard_detection_uut(.idex_mem_read(control_reg[5]), .idex_reg_rd(write_reg1), .ifid_instruction(instruction_reg), .pc_write(pc_write), .ifid_write(ifid_write), .idex_flush(idex_flush));

/*-------------------------------------------------------------------------*/
    
    //  connecting Forwarding unit
    ForwardingUnit ForwardingUnit_uut(
                    .ID_EX_RegisterA(rs1_reg),
                    .ID_EX_RegisterB(rs2_reg),
                    .EX_MEM_rd(write_reg2),
                    .MEM_WB_rd(write_reg3),
                    .EX_MEM_RegWrite(control_reg2[1]),
                    .MEM_WB_RegWrite(RegWrite_final),
                    .ForwardA(ForwardA),
                    .ForwardB(ForwardB));

    genvar l;
    generate
        for (l = 0; l<64; l=l+1) begin
            mux4x1 mux_forwardA(.out(src1[l]), .sel0(ForwardA[0]), .sel1(ForwardA[1]), .in0(rd1_reg[l]), .in1(WriterData_final[l]), .in2(alu_res_reg[l]), .in3(1'b0));
            mux4x1 mux_forwardB(.out(intermediate[l]), .sel0(ForwardB[0]), .sel1(ForwardB[1]), .in0(rd2_reg[l]), .in1(WriterData_final[l]), .in2(alu_res_reg[l]), .in3(1'b0));   
        end
    endgenerate

endmodule

