module instr_mem_512 (         // Clock signal
    input  wire [63:0] address,     // 64-bit byte address input
    output reg  [31:0] instruction  // 32-bit instruction output
);

    // Define a 512-byte memory array
    reg [7:0] memory [0:511];

    // Optionally initialize memory from a file.
    // The file should contain the memory contents in hexadecimal format.
    initial begin
        $readmemb("instructions.txt", memory);
    end

    always @(*) begin
        instruction <= { 
            memory[address],
            memory[address + 1],
            memory[address + 2],
            memory[address + 3] 
        };
    end

endmodule
