`timescale 1ns / 1ps

module top(

        input wire clk,
        input wire reset,
        output wire overflow_o,
        output wire zero_o

    );
    
    wire [31:0] instr_mem_address_s;
    wire [31:0] instr_mem_read_s;
    wire [3:0] data_mem_we_s;
    wire [31:0] data_mem_address_s;
    wire [31:0] data_mem_write_s;
    wire [31:0] data_mem_read_s;
    
    cpu risc_v_imb(
    
        // global CPU interface
        
        .clk(clk),
        .reset(reset),
        .overflow_o(overflow_o),
        .zero_o(zero_o),
        
        // CPU interface towards memories in top module
       
        .instr_mem_address_o(instr_mem_address_s),
        .instr_mem_read_i(instr_mem_read_s),
        
        .data_mem_we_o(data_mem_we_s),
        .data_mem_address_o(data_mem_address_s),
        .data_mem_write_o(data_mem_write_s),
        .data_mem_read_i(data_mem_read_s)
    );
    
  bram_module #(
    .RAM_PERFORMANCE("LOW_LATENCY"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE("C:\\Users\\Win 10\\Desktop\\ftn\\projekat\\rtl\\project_zybo\\project_zybo.srcs\\sim_1\\new\\asm.v")    // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) instruction_memory (
    .addra(instr_mem_address_s >> 2),   // Port A address bus, width determined from RAM_DEPTH
    .addrb(),   // Port B address bus, width determined from RAM_DEPTH
    .dina(),     // Port A RAM input data, width determined from RAM_WIDTH
    .dinb(),     // Port B RAM input data, width determined from RAM_WIDTH
    .clka(clk),     // Clock
    .wea(4'b0),       // Port A write enable
    .web(4'b0),       // Port B write enable
    .ena(1'b1),       // Port A RAM Enable, for additional power savings, disable port when not in use
    .enb(),       // Port B RAM Enable, for additional power savings, disable port when not in use
    .rsta(reset),     // Port A output reset (does not affect memory contents)
    .rstb(reset),     // Port B output reset (does not affect memory contents)
    .regcea(1'b1), // Port A output register enable
    .regceb(1'b1), // Port B output register enable
    .douta(instr_mem_read_s),   // Port A RAM output data, width determined from RAM_WIDTH
    .doutb()    // Port B RAM output data, width determined from RAM_WIDTH
  );
  
    bram_module #(
    .RAM_PERFORMANCE("LOW_LATENCY"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE("")                        // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) data_memory (
    .addra(data_mem_address_s >> 2),   // Port A address bus, width determined from RAM_DEPTH
    .addrb(),   // Port B address bus, width determined from RAM_DEPTH
    .dina(data_mem_write_s),     // Port A RAM input data, width determined from RAM_WIDTH
    .dinb(),     // Port B RAM input data, width determined from RAM_WIDTH
    .clka(clk),     // Clock
    .wea(data_mem_we_s),       // Port A write enable /* JUST FOR SMOKE TEST*/
    .web(4'b0),       // Port B write enable
    .ena(1'b1),       // Port A RAM Enable, for additional power savings, disable port when not in use
    .enb(1'b0),       // Port B RAM Enable, for additional power savings, disable port when not in use
    .rsta(reset),     // Port A output reset (does not affect memory contents)
    .rstb(reset),     // Port B output reset (does not affect memory contents)
    .regcea(1'b1), // Port A output register enable
    .regceb(1'b0), // Port B output register enable
    .douta(data_mem_read_s),   // Port A RAM output data, width determined from RAM_WIDTH
    .doutb()    // Port B RAM output data, width determined from RAM_WIDTH
  );
  
  
    
endmodule