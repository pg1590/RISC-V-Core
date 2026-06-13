module hazard_control_mux(
    input ALUsrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, hz_ctrl,
    input [1:0] ALUop,
    output ALUsrc_mux, MemtoReg_mux, RegWrite_mux, MemRead_mux, MemWrite_mux, Branch_mux,
    output [1:0] ALUop_mux
);

    wire hazard_control;
    not notgate(hazard_control, hz_ctrl);
    wire zero_value;
    assign zero_value = 1'b0;
    mux2x1 mux1(ALUsrc_mux,hazard_control,zero_value,ALUsrc);
    mux2x1 mux2(MemtoReg_mux,hazard_control,zero_value,MemtoReg);
    mux2x1 mux3(RegWrite_mux,hazard_control,zero_value,RegWrite);
    mux2x1 mux4(MemRead_mux,hazard_control,zero_value,MemRead);
    mux2x1 mux5(MemWrite_mux,hazard_control,zero_value,MemWrite);
    mux2x1 mux6(Branch_mux,hazard_control,zero_value,Branch);
    mux2x1 mux7(ALUop_mux[0],hazard_control,zero_value,ALUop[0]);
    mux2x1 mux8(ALUop_mux[1],hazard_control,zero_value,ALUop[1]);
    
endmodule
