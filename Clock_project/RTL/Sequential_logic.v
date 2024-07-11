`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/05 14:49:49
// Design Name: 
// Module Name: exam02_sequential_logic
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module t_flip_flop_p(
    input clk, reset_p,
    input t,
    output reg q
);

    always @(posedge clk or posedge reset_p) begin
        if (reset_p) begin 
            q = 0;
        end
        else begin
            if(t) q = ~q;
            else q = q;
        end
    end
    
endmodule

module ring_counter_fnd(
    input clk, reset_p,
    output reg [3:0] com
);

    reg [16:0] clk_div; 

    always @(posedge clk) clk_div = clk_div + 1;

    always @(posedge clk_div[16] or posedge reset_p)begin
        if(reset_p) com = 4'b1110;
        else begin
            case(com)
                4'b1110 : com = 4'b1101;
                4'b1101 : com = 4'b1011;
                4'b1011 : com = 4'b0111;
                4'b0111 : com = 4'b1110;
                default : com = 4'b1110;
            endcase
        end
    end
endmodule

module edge_detector_n( //blocking | non_blocking
    input clk, reset_p,
    input cp,
    output p_edge, n_edge
);
    reg ff_cur, ff_old;

    assign p_edge = ({ff_cur, ff_old} == 2'b10) ? 1 : 0;
    assign n_edge = ({ff_cur, ff_old} == 2'b01) ? 1 : 0;
      
    always @(negedge clk or posedge reset_p)begin
        if (reset_p)begin
            ff_cur <= 0;
            ff_old <= 0;
        end
        else begin
            ff_cur <= cp;
            ff_old <= ff_cur;
        end      
    end
        
endmodule

module button_cntr(
    input clk, reset_p,
    input btn,
    output btn_pe, btn_ne
);
    wire clk_div_16;

    reg [16:0] clk_div;
    reg [3:0] debounced_btn;

    edge_detector_n ed1(.clk(clk), .reset_p(reset_p), .cp(clk_div[16]), .p_edge(clk_div_16));
    edge_detector_n ed2(.clk(clk), .reset_p(reset_p), .cp(debounced_btn), .p_edge(btn_pe), .n_edge(btn_ne));   //, .n_dege(btn_ne)

    always @(posedge clk) clk_div = clk_div + 1;
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) debounced_btn = 0;
        else if (clk_div_16) debounced_btn = btn;
    end
        
endmodule

module fnd_4digit_cntr(
    input clk, reset_p,
    input [15:0] value,
    output [7:0] seg_7_an, seg_7_ca,        //0??? ??? an , 1??? ??? cn
    output [3:0] com
);
    reg [3:0] hex_value;

    assign seg_7_ca = ~seg_7_an;
    
    ring_counter_fnd rc(.clk(clk), .reset_p(reset_p), .com(com));
    decoder_7seg fnd (.hex_value(hex_value), .seg_7(seg_7_an));
        
    always @(posedge clk)begin
        case(com)
            4'b0111: hex_value = value[15:12];
            4'b1011: hex_value = value[11:8];
            4'b1101: hex_value = value[7:4];
            4'b1110: hex_value = value[3:0];  
        endcase
    end
                      
endmodule