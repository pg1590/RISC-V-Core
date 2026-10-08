`include "main.v"
module main_processor_tb();
    reg clk;
    
    // Instantiate the processor
    main uut (.clk(clk));
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 ns clock period
    end

    // Initializing memory and registers
    initial begin
        $dumpfile("gtk.vcd");
        $dumpvars(0, main_processor_tb);
        #100;
        
        $finish;
    end

endmodule
