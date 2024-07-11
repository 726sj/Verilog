`timescale 1ns / 1ps

module stop_watch(
    input clk, reset_p,
    input [1:0] btn_pedge,
    output [15:0] value
);
    wire clk_usec, clk_msec, clk_sec, clk_csec;
    wire start_stop;
    wire clk_start;
    wire [3:0] sec1, sec10, csec1, csec10;
    wire lap_swatch, lap_load;
    wire [15:0] cur_time;
        
    reg [15:0] lap_time;

    assign cur_time = {sec10,sec1, csec10,csec1};
    assign clk_start = start_stop ? clk : 0;
    assign value = lap_swatch ? lap_time : cur_time;
        
    clock_set clock(.clk(clk_start), .reset_p(reset_p),  .clk_usec(clk_usec), .clk_msec(clk_msec), 
                                                .clk_csec(clk_csec), .clk_sec(clk_sec));

    counter_dec_100 counter_csec(clk,reset_p,clk_csec, csec1, csec10);
    counter_dec_60 counter_sec(clk, reset_p, clk_sec,sec1,sec10);                                            
      
    t_flip_flop_p tff_start(.clk(clk), .reset_p(reset_p), .t(btn_pedge[0]), .q(start_stop));
    t_flip_flop_p tff_lap(.clk(clk), .reset_p(reset_p), .t(btn_pedge[1]), .q(lap_swatch));
         
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(lap_swatch), .p_edge(lap_load));
        
    always @(posedge clk or posedge reset_p)begin
        if(reset_p)lap_time = 0;
        else if(lap_load) lap_time = cur_time;
    end   
endmodule