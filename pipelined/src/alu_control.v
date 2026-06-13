module alu_control(input [2:0] func3, input func7, input [1:0] aluop,
    output [3:0] alu_code
);
    // 4th bit logic
    and alu_4(alu_code[3],aluop[0], aluop[1]);

    // 3rd bit logic
    wire t1;
    and temp(t1, aluop[1], func7);
    or alu_3(alu_code[2], t1, aluop[0]);

    // 2nd bit logic
    wire t2, not_alu_1, f3_2_not, f3_1_not, f3_0_not;
    not not1(not_alu_1, aluop[1]);
    not not2(f3_2_not, func3[2]);
    not not3(f3_1_not, func3[1]);
    not not4(f3_0_not, func3[0]);
    and temp2(t2, aluop[1],f3_2_not,f3_1_not,f3_0_not);
    or alu_2(alu_code[1], t2, not_alu_1);

    // 1st bit logic
    wire t3;
    and alu_1(alu_code[0],aluop[1], func3[1], f3_0_not);
endmodule