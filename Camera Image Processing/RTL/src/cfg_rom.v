`timescale 1ns / 1ps

// Key takeaway is that OV7670 is configured to RGB444 output
// data frame format:    1)  { x, x, x, x, R[0], R[1], R[2], R[3] }  {G[0], G[1], G[2], G[3], B[0], B[1], B[2], B[3]}
`default_nettype none
//
module cfg_rom 
    (
    input wire i_clk,
    input wire i_rstn,

    input wire [7:0]i_addr,
    output reg [15:0]o_data
    );

    always@(posedge i_clk) begin
        if(!i_rstn) o_data <= 0;
        else begin
            case(i_addr)
                0:  o_data <= 16'h12_80; // reset     
                1:  o_data <= 16'hFF_F0; // delay 1ms, hardcoded in camera_interface
                2:  o_data <= 16'h12_14;
                3:  o_data <= 16'h8c_02; // RGB444, {xR}{GB} sequence
                4:  o_data <= 16'h40_d0;
                5:  o_data <= 16'h3a_04;
                6:  o_data <= 16'h3d_c0;
                7:  o_data <= 16'h1e_00;
                8:  o_data <= 16'h6b_00;
                9:  o_data <= 16'h32_b6;
                10: o_data <= 16'h17_13;
                11: o_data <= 16'h18_01;
                12: o_data <= 16'h19_02;
                13: o_data <= 16'h1a_7a;
                14: o_data <= 16'h03_0a;
                15: o_data <= 16'h0c_00;
                16: o_data <= 16'h3e_00;
                17: o_data <= 16'h04_00; //COM1,disable CCIR656
                18: o_data <= 16'h70_00;
                19: o_data <= 16'h71_00;
                20: o_data <= 16'h72_11;
                21: o_data <= 16'h73_00;
                22: o_data <= 16'ha2_02;
                23: o_data <= 16'h11_80;
                24: o_data <= 16'h7a_20;
                25: o_data <= 16'h7b_10;
                26: o_data <= 16'h7c_1e;
                27: o_data <= 16'h7d_3c; // R gain
                28: o_data <= 16'h7e_55; // G gain
                29: o_data <= 16'h7f_68; // B gain
                30: o_data <= 16'h80_76;
                31: o_data <= 16'h81_80;
                32: o_data <= 16'h82_88;
                33: o_data <= 16'h83_8f;
                34: o_data <= 16'h84_96;
                35: o_data <= 16'h85_a3;
                36: o_data <= 16'h86_af;
                37: o_data <= 16'h87_c4;
                38: o_data <= 16'h88_d7;
                39: o_data <= 16'h89_e8;
                40: o_data <= 16'h13_e0;
                41: o_data <= 16'h00_00;
                42: o_data <= 16'h10_00;
                43: o_data <= 16'h0d_00;
                44: o_data <= 16'h14_28;
                45: o_data <= 16'ha5_05;
                46: o_data <= 16'hab_07;
                47: o_data <= 16'h24_95;
                48: o_data <= 16'h25_33;
                49: o_data <= 16'h26_e3;
                50: o_data <= 16'h9f_78;
                51: o_data <= 16'ha0_68;
                52: o_data <= 16'ha1_03;
                53: o_data <= 16'ha6_df;
                54: o_data <= 16'ha7_df;
                55: o_data <= 16'ha8_f0;
                56: o_data <= 16'ha9_90;
                57: o_data <= 16'haa_94;
                58: o_data <= 16'h13_ef;
                59: o_data <= 16'h0e_61;
                60: o_data <= 16'h0f_4b;
                61: o_data <= 16'h16_02;
                62: o_data <= 16'h21_02;
                63: o_data <= 16'h22_91;
                64: o_data <= 16'h29_07;
                65: o_data <= 16'h33_0b;
                66: o_data <= 16'h35_0b;
                67: o_data <= 16'h37_1d;
                68: o_data <= 16'h38_71;
                69: o_data <= 16'h39_2a;
                70: o_data <= 16'h3c_78;
                71: o_data <= 16'h4d_40;
                72: o_data <= 16'h4e_20;
                73: o_data <= 16'h69_06;
                74: o_data <= 16'h74_19;
                75: o_data <= 16'h8d_4f;
                76: o_data <= 16'h8e_00;
                77: o_data <= 16'h8f_00;
                78: o_data <= 16'h90_00;
                79: o_data <= 16'h91_00;
                80: o_data <= 16'h92_00;
                81: o_data <= 16'h96_00;
                82: o_data <= 16'h9a_80;
                83: o_data <= 16'hb0_84;
                84: o_data <= 16'hb1_0c;
                85: o_data <= 16'hb2_0e;
                86: o_data <= 16'hb3_82;
                87: o_data <= 16'hb8_0a;
                88: o_data <= 16'h43_14;
                89: o_data <= 16'h44_f0;
                90: o_data <= 16'h45_34;
                91: o_data <= 16'h46_58;
                92: o_data <= 16'h47_28;
                93: o_data <= 16'h48_3a;
                94: o_data <= 16'h59_90;
                95: o_data <= 16'h5a_3f;
                96: o_data <= 16'h5b_43;
                97: o_data <= 16'h5c_4e;
                98: o_data <= 16'h5d_43;
                99: o_data <= 16'h5e_80;
                100: o_data <= 16'h62_36;
                101: o_data <= 16'h64_04;
                102: o_data <= 16'h65_20;
                103: o_data <= 16'h66_05;
                104: o_data <= 16'h94_04;
                105: o_data <= 16'h95_08;
                106: o_data <= 16'h6c_0a;
                107: o_data <= 16'h6d_55;
                108: o_data <= 16'h6e_11;
                109: o_data <= 16'h6f_9f;
                110: o_data <= 16'h6a_40;
                111: o_data <= 16'h01_40;
                112: o_data <= 16'h02_40;
                113: o_data <= 16'h13_e7;
                114: o_data <= 16'h15_00;
                115: o_data <= 16'h4f_B3;
                116: o_data <= 16'h50_B3;
                117: o_data <= 16'h51_00;
                118: o_data <= 16'h52_3D;
                119: o_data <= 16'h53_A7;
                120: o_data <= 16'h54_E4;
                121: o_data <= 16'h58_9E;
                122: o_data <= 16'h41_08;
                123: o_data <= 16'h3f_00;
                124: o_data <= 16'h75_05;
                125: o_data <= 16'h76_e1;
                126: o_data <= 16'h4c_00;
                127: o_data <= 16'h77_01;
                128: o_data <= 16'h4b_09;
                129: o_data <= 16'hc9_f0;
                130: o_data <= 16'h41_38;
                131: o_data <= 16'h56_40;
                132: o_data <= 16'h34_11;
                133: o_data <= 16'h3b_02;
                134: o_data <= 16'ha4_89;
                135: o_data <= 16'h96_00;
                136: o_data <= 16'h97_30;
                137: o_data <= 16'h98_20;
                138: o_data <= 16'h99_30;
                139: o_data <= 16'h9a_84;
                140: o_data <= 16'h9b_29;
                141: o_data <= 16'h9c_03;
                142: o_data <= 16'h9d_4c;
                143: o_data <= 16'h9e_3f;
                144: o_data <= 16'h78_04;
                145: o_data <= 16'h79_01;
                146: o_data <= 16'hc8_f0;
                147: o_data <= 16'h79_0f;
                148: o_data <= 16'hc8_00;
                149: o_data <= 16'h79_10;
                150: o_data <= 16'hc8_7e;
                151: o_data <= 16'h79_0a;
                152: o_data <= 16'hc8_80;
                153: o_data <= 16'h79_0b;
                154: o_data <= 16'hc8_01;
                155: o_data <= 16'h79_0c;
                156: o_data <= 16'hc8_0f;
                157: o_data <= 16'h79_0d;
                158: o_data <= 16'hc8_20;
                159: o_data <= 16'h79_09;
                160: o_data <= 16'hc8_80;
                161: o_data <= 16'h79_02;
                162: o_data <= 16'hc8_c0;
                163: o_data <= 16'h79_03;
                164: o_data <= 16'hc8_40;
                165: o_data <= 16'h79_05;
                166: o_data <= 16'hc8_30;
                167: o_data <= 16'h79_26;
                168: o_data <= 16'h09_03;
                169: o_data <= 16'h3b_42;
                170: o_data <= 16'h69_06;
                default: o_data <= 16'hFF_FF; //mark end of ROM
            endcase
        end
    end
endmodule