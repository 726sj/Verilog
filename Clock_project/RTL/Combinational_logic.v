`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/22 12:16:58
// Design Name: 
// Module Name: exam01_combinational_logic
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

module decoder_7seg(
    input [3:0] hex_value,
    output reg [7:0] seg_7);
    
    always @(hex_value)begin
        case(hex_value)
                              //abcd_efgp
            4'b0000: seg_7 = 8'b1100_0000;  //0
            4'b0001: seg_7 = 8'b1111_1001;  //1
            4'b0010: seg_7 = 8'b1010_0100;  //2
            4'b0011: seg_7 = 8'b1011_0000;  //3
            4'b0100: seg_7 = 8'b1001_1001;  //4
            4'b0101: seg_7 = 8'b1001_0010;  //5
            4'b0110: seg_7 = 8'b1000_0010;  //6
            4'b0111: seg_7 = 8'b1101_1000;  //7
            4'b1000: seg_7 = 8'b1000_0000;  //8
            4'b1001: seg_7 = 8'b1001_1000;  //9
            4'b1010: seg_7 = 8'b1000_1000;  //A
            4'b1011: seg_7 = 8'b1000_0011;  //b
            4'b1100: seg_7 = 8'b1100_0110;  //C
            4'b1101: seg_7 = 8'b1010_0001;  //d
            4'b1110: seg_7 = 8'b1000_0110;  //E
            4'b1111: seg_7 = 8'b1000_1110;  //F
        endcase
    end
endmodule