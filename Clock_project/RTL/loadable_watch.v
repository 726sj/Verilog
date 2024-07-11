`timescale 1ns / 1ps

module loadable_watch(
    input clk, reset_p,
    input [2:0] btn_pedge,
    output [15:0] value
);  
    wire [15:0] cur_time, set_time;
    wire [3:0] cur_sec1, cur_sec10, set_sec1, set_sec10;
    wire [3:0] cur_min1, cur_min10, set_min1, set_min10;
    
    wire clk_usec, clk_msec, clk_sec, clk_min;
    wire cur_time_load_en, set_time_load_en;
    wire sec_edge, min_edge;
    wire set_mode;

    assign cur_time = {cur_min10, cur_min1, cur_sec10, cur_sec1};
    assign set_time = {set_min10, set_min1, set_sec10, set_sec1};
    assign value = set_mode ? set_time : cur_time;
    assign sec_edge = set_mode ? btn_pedge[1] : clk_sec;
    assign min_edge = set_mode ? btn_pedge[2] : clk_min;
    
    clock_set clock(.clk(clk), .reset_p(reset_p),  .clk_usec(clk_usec), .clk_msec(clk_msec), 
                                            .clk_sec(clk_sec), .clk_min(clk_min));
        
    loadable_counter_dec_60 cur_time_sec(.clk(clk), .reset_p(reset_p), .clk_time(clk_sec), 
                        .load_enable(cur_time_load_en), .set_value1(set_sec1), .set_value10(set_sec10),
                            .dec1(cur_sec1), .dec10(cur_sec10));
                            
    loadable_counter_dec_60 cur_time_min(.clk(clk), .reset_p(reset_p), .clk_time(clk_min), 
                        .load_enable(cur_time_load_en), .set_value1(set_min1), .set_value10(set_min10),
                            .dec1(cur_min1), .dec10(cur_min10));
                            
    loadable_counter_dec_60 set_time_sec(.clk(clk), .reset_p(reset_p), .clk_time(btn_pedge[1]), 
                        .load_enable(set_time_load_en), .set_value1(cur_sec1), .set_value10(cur_sec10),
                            .dec1(set_sec1), .dec10(set_sec10));
                            
    loadable_counter_dec_60 set_time_min(.clk(clk), .reset_p(reset_p), .clk_time(btn_pedge[2]), 
                        .load_enable(set_time_load_en), .set_value1(cur_min1), .set_value10(cur_min10),
                            .dec1(set_min1), .dec10(set_min10));
    
    t_flip_flop_p tff_setmode(.clk(clk), .reset_p(reset_p), .t(btn_pedge[0]), .q(set_mode));
        
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(set_mode), .n_edge(cur_time_load_en), .p_edge(set_time_load_en));
         
endmodule