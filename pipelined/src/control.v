module control(
    input [6:0] opcode,
    input hazard_mux,
    output ALUsrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, 
    output [1:0] ALUop
);

    wire b1 = opcode[6];
    wire b2 = opcode[5];
    wire b3 = opcode[4];

    wire b1_0, b2_0, b3_0;
    not not1(b1_0, b1);
    not not2(b2_0, b2);
    not not3(b3_0, b3);

    // ALUsrc
    wire t1,t2,t3,t4;

    and and1(t1,b1_0,b2_0,b3_0);
    and and2(t2,b1_0,b2,b3_0);
    or or1(ALUsrc,t1,t2);

    // MemtoReg
    and and3(MemtoReg,b1_0,b2_0,b3_0);

    // RegWrite
    and and4(t3,b1_0,b2,b3);
    and and5(t4,b1_0,b2_0,b3_0);
    or or2(RegWrite,t3,t4);

    // MemRead
    and and6(MemRead,b1_0,b2_0,b3_0);

    // MemWrite
    and and7(MemWrite,b1_0,b2,b3_0);

    // Branch
    and and8(Branch,b1,b2,b3_0);
    
    // ALUop1
    and and10(ALUop[1],b1_0,b2,b3);

    // ALUop0
    and and9(ALUop[0],b1,b2,b3_0);

endmodule



