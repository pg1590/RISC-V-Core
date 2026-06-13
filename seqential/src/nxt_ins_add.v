module address_gen(
    output [63:0] nxt_pc_address,
    input [63:0] pc_address, immd,
    input branch
);

    wire [63:0] nxt_address, jump_address;

    // Logic for calculating the next address
    wire [63:0] nxt_address_immd;
    assign nxt_address_immd = 64'd4;
    bit_adder_64 u_adder1(.a(pc_address),.b(nxt_address_immd),.s(nxt_address));

    // Logic for calculating the jump address
    // Left shift the immediate value by 1
    wire [63:0] jump_address_immd;
    assign jump_address_immd=immd;
    
    // genvar i;
    // generate
    //     for (i = 0; i < 63; i = i + 1) begin : shift_loop
    //         assign jump_address_immd[i+1] = immd[i];
    //     end
    // endgenerate
    // assign jump_address_immd[0] = 1'b0;
    
    bit_adder_64 u_adder2(.a(pc_address),.b(jump_address_immd),.s(jump_address));

    genvar j;
    generate
        for (j=0 ;j<64 ;j=j+1) begin
            mux2x1 mux_sel(.in0(nxt_address[j]),.in1(jump_address[j]),.select(branch),.out(nxt_pc_address[j]));
        end
    endgenerate

endmodule

