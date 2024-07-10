module edge_detector_n( //blocking | non_blocking
        input clk, reset_p,
        input cp,
        output p_edge, n_edge
);
        reg ff_cur, ff_old;
        
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
        
        assign p_edge = ({ff_cur, ff_old} == 2'b10) ? 1 : 0;
        assign n_edge = ({ff_cur, ff_old} == 2'b01) ? 1 : 0;
endmodule

module button_cntr(
        input clk, reset_p,
        input btn,
        output btn_pe, btn_ne
);
        reg [16:0] clk_div;
        always @(posedge clk) clk_div = clk_div + 1;
        wire clk_div_16;
        reg [3:0] debounced_btn;
        edge_detector_n ed1(.clk(clk), .reset_p(reset_p), .cp(clk_div[16]), .p_edge(clk_div_16));
        always @(posedge clk, posedge reset_p) begin
                if(reset_p) debounced_btn = 0;
                else if (clk_div_16) debounced_btn = btn;
        end
        edge_detector_n ed2(.clk(clk), .reset_p(reset_p), .cp(debounced_btn), .p_edge(btn_pe), .n_edge(btn_ne));          //, .n_dege(btn_ne)
endmodule