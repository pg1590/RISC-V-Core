`include "alu_control.v"
`include "alu.v"
`include "control.v"
`include "nxt_ins_add.v"
`include "instruction.v"
`include "datamem.v"
`include "registers.v"
`include "immgen.v"

module main(input clk);

    reg [63:0] curr_pc_add;
    wire [63:0] next_pc_add;
    initial begin
        curr_pc_add <= 64'b0;
    end
    
/*-------------------------------------------------------------------------*/

    // Declaration of the wires
    wire [63:0] wdata, src1, src2, alu_res, immediate,ReadData,rd1,rd2;
    wire [4:0] rs1, rs2, wreg; //wreg is the destination register
    wire [6:0] opcode;
    wire [2:0] func3;
    wire [3:0] alu_code;
    wire [1:0] ALUop;
    wire [31:0] instruction;
    wire ALUsrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, b_logic;
    wire overflow, zero_flag;

/*-------------------------------------------------------------------------*/

    // Assignments of all the wires
    assign opcode = instruction[6:0];
    assign func3 = instruction[14:12];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign wreg = instruction[11:7];
    assign src1 = rd1;

/*-------------------------------------------------------------------------*/

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

/*-------------------------------------------------------------------------*/

    // Instantiate the ALU control module
    alu_control uut_alu_control(
                    .func3(func3),
                    .func7(instruction[30]),
                    .aluop(ALUop),
                    .alu_code(alu_code));

/*-------------------------------------------------------------------------*/

    // The register file here with two outputs
    reg_file_64bit uut_reg_file(
                    .clk(clk),
                    .rs1_addr(rs1),
                    .rs2_addr(rs2),
                    .rs1_data(rd1),
                    .rs2_data(rd2),
                    .rd_addr(wreg),
                    .rd_data(wdata),
                    .reg_write(RegWrite));

/*-------------------------------------------------------------------------*/

    // Instantiate the immediate generation module
    immgen uut_immgen(
                    .instr(instruction),
                    .imm(immediate));

/*-------------------------------------------------------------------------*/

    // Instantiate the ALU operation module
    alu uut_alu_module(
                    .alu_code(alu_code),
                    .src1(src1),
                    .src2(src2),
                    .result(alu_res),
                    .overflow(overflow),
                    .zero_flag(zero_flag));

/*-------------------------------------------------------------------------*/

    // ALU mux operation
    genvar a;
    generate
        for (a = 0; a < 64; a = a + 1) begin : mux2x1_generate
            mux2x1 uut_alu_mux(
                            .out(src2[a]),
                            .select(ALUsrc),
                            .in0(rd2[a]),
                            .in1(immediate[a]));
        end
    endgenerate

/*-------------------------------------------------------------------------*/

    // Instantiate the data memory module
    data_mem uut_data_mem(
                    .ReadData(ReadData),
                    .Address(alu_res),
                    .WriteData(rd2),
                    .MemRead(MemRead),
                    .MemWrite(MemWrite),
                    .clk(clk));

/*-------------------------------------------------------------------------*/

    // Mux for ReadData and alu_res for wdata
    genvar b;
    generate
        for (b = 0; b < 64; b = b + 1) begin : mux2x1_wdata
            mux2x1 uut_wdata_mux(
                            .out(wdata[b]),
                            .select(MemtoReg),
                            .in1(ReadData[b]),
                            .in0(alu_res[b]));
        end
    endgenerate

/*-------------------------------------------------------------------------*/

    // Instruction memory module
    instr_mem_512 uut_instr_mem(
                    .address(curr_pc_add),
                    .instruction(instruction));

/*-------------------------------------------------------------------------*/

    // Instantiate the next instruction address module
    and and_branch(b_logic, zero_flag,Branch);
    address_gen uut_nxt_ins_add(
                    .pc_address(curr_pc_add),
                    .immd(immediate),
                    .branch(b_logic),
                    .nxt_pc_address(next_pc_add));

/*-------------------------------------------------------------------------*/    

    always @(posedge clk) begin
        curr_pc_add <= next_pc_add;
    end

/*-------------------------------------------------------------------------*/  

// always @(instruction) begin
//     if (^instruction[6:0] === 1'bx) begin
//         $display("All the instructions have been executed. The simulation will now end.");
//         $finish;
//     end
// end

endmodule
