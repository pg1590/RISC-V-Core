// Top Module
module alu(
    input signed [63:0] src1,src2,
    input [3:0] alu_code,
    output signed [63:0] result,
    output overflow,zero_flag
);

    wire [63:0] add_result, sub_result, and_result, or_result;
    wire mark1, mark2;
    bit_adder_64 u_adder (.a(src1), .b(src2), .s(add_result), .overflow(mark1));
    bit_sub_64 u_sub (.a(src1), .b(src2), .s(sub_result), .overflow(mark2));
    bit_and_64 u_and (.a(src1), .b(src2), .s(and_result));
    bit_or_64 u_or (.a(src1), .b(src2), .s(or_result));

    // Logic for the selection of the output
    wire [1:0] opout;

    // opout[0] bit logic
    and and1(opout[1],1,alu_code[1]);

    // opout[1] bit logic
    wire a,b,c,d;
    wire t1,t2;
    not not1(a,alu_code[3]);
    not not2(b,alu_code[2]);
    not not3(c,alu_code[1]);
    not not4(d,alu_code[0]);

    and and2(t1, a,b,c,alu_code[0]);
    and and3(t2, a,alu_code[2],alu_code[1],d);
    or or1(opout[0],t1,t2);

    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : mux_loop
            mux4x1 u_mux (.out(result[i]), .sel0(opout[0]), .sel1(opout[1]), .in0(and_result[i]), .in1(or_result[i]), .in2(add_result[i]), .in3(sub_result[i]));
        end
    endgenerate
    wire in0,in1;
    assign in0 = 1'b0;
    assign in1 = 1'b0;

    // Logic for overflow bit
    mux4x1 u_mux_overflow (.out(overflow), .sel0(opout[0]), .sel1(opout[1]), .in0(in0), .in1(in1), .in2(mark1), .in3(mark2));

    // Logc for zero_flag
    zerodetector u_zero (.b(result), .zero_flag(zero_flag));

endmodule

module zerodetector(
    input [63:0] b, 
    output zero_flag
);
    wire [62:0] or_chain; 
    or or_gate_first_bit(or_chain[0], b[0], b[1]);
    genvar i;
    generate
        for (i = 1; i < 63; i = i + 1) begin : or_loop
            or or_gate(or_chain[i], or_chain[i-1], b[i+1]); 
        end
    endgenerate

    not not_gate(zero_flag, or_chain[62]);
endmodule


// Adder Module
module one_bit_adder (
    input a, b, cin,
    output cout, s
);

    wire c, e, f;

    xor xor1(c, a, b);
    xor xor2(s, cin, c);

    and and1(f, cin, c);
    and and2(e, a, b);

    or or1(cout, f, e);

endmodule
module bit_adder_64 (
    input signed [63:0] a, b,
    output signed [63:0] s,
    output overflow
);

    wire [63:0] carry;
    wire c;
    
    assign c= 0;
    one_bit_adder u1_adder(.a(a[0]),.b(b[0]),.cin(c),.cout(carry[0]),.s(s[0]));
    genvar i;
    generate
        for (i = 1; i < 64; i = i + 1) begin : adder_loop
            one_bit_adder u_adder (.a(a[i]),.b(b[i]),.cin(carry[i-1]),.cout(carry[i]),.s(s[i]));
        end
    endgenerate
    xor xor1(overflow,carry[63],carry[62]);
endmodule

// Subtractor Module
module one_bit_sub (
    input a, b, cin,
    output cout, s
);
    wire c, e, f;

    xor xor1(c, a, b);   
    xor xor2(s, cin, c); 

    and and1(f, cin, c);
    and and2(e, a, b);    

    or or1(cout, f, e); 
endmodule   
module bit_sub_64 (
    input signed [63:0] a, b,
    output signed [63:0] s, 
    output [63:0] carry,
    output last_carry, output overflow
);
    wire [63:0] flipped;
    assign carry[0] = 1;

    genvar j;
    generate
        for (j = 0; j < 64; j = j + 1) begin : flip_b_loop
            xor xor_flip(flipped[j], b[j], 1'b1);
        end
    endgenerate

    one_bit_sub u1_sub (.a(a[0]), .b(flipped[0]), .cin(1'b1), .cout(carry[1]), .s(s[0]));

    genvar i;
    generate
        for (i = 1; i < 63; i = i + 1) begin : sub_loop
            one_bit_sub u_sub (.a(a[i]), .b(flipped[i]), .cin(carry[i]), .cout(carry[i+1]), .s(s[i]));
        end
    endgenerate

    one_bit_sub u_last_sub (.a(a[63]), .b(flipped[63]), .cin(carry[63]), .cout(last_carry), .s(s[63]));
    xor xor1(overflow, last_carry, carry[63]);
endmodule

// AND Module
module bit_and_64(
    input [63:0] a, b,  
    output [63:0] s   
);

    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin
            and and1(s[i], a[i], b[i]);  
        end
    endgenerate

endmodule

// OR Module
module bit_or_64(
    input [63:0] a, b,
    output [63:0] s  
);

    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin
            or or1(s[i], a[i], b[i]);
        end
    endgenerate

endmodule

// Mux Logic 
module mux2x1 (
    output out,
    input select,in0,in1
);
    wire select_bar;
    not n1(select_bar,select);
    wire temp1,temp2;
    and (temp1,select_bar,in0);
    and (temp2,select,in1);
    or (out,temp1,temp2);
endmodule

module mux4x1(
    output out,
    input sel0,sel1,in0,in1,in2,in3
);
    wire t1,t2;
    mux2x1 M1(t1,sel0,in0,in1);
    mux2x1 M2(t2,sel0,in2,in3);
    mux2x1 M3(out,sel1,t1,t2);
endmodule