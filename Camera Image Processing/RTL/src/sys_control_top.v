`timescale 1ns / 1ps

`default_nettype none
//
module sys_top 
    (
    input  wire i_sysclk,    // 100 MHz Basys3 board
    input  wire i_rst,       // active-high board button

    // camera interface
    output wire o_cam_xclk,  // 24MHz clock to camera from DCM
    output wire o_cam_rstn,  // camera active low reset
    output wire o_cam_pwdn,  // camera active high power down 

    input  wire i_cam_pclk,  // camera generated pixel clock
    input  wire i_cam_vsync, // camera vsync
    input  wire i_cam_href,  // camera href
    input  wire [7:0] i_cam_data,  // camera 8-bit data in

    // i2c interface
    inout  wire SCL,         // 양방향  SCL
    inout  wire SDA,         // 양방향  SDA

    //VGA interface
    output wire [3:0] red,
    output wire [3:0] green,
    output wire [3:0] blue,
    output wire vsync, hsync, 

    // controls
    input  wire btn_mode,
    input  wire btn_decSobel,
    input  wire btn_incSobel,

    input  wire sw_gaussian,
    input  wire sw_sobel,
    input  wire sw_freeze,

    // status
    output wire led_mode,
    output wire led_gaussian,
    output wire led_sobel,
    output wire led_threshold
    );


// =============================================================
//              Parameters, Registers, and Wires
// =============================================================

// DCM
   
    wire clk_25MHz;

// Debounce
    wire db_rstn;

// System Control
    wire cfg_start;
    wire sys_mode;
    wire gaussian_enable;
    wire sobel_enable;
    wire pipe_flush;
    wire [25:0] sobel_threshold;
    wire thresholdBounds;

// Camera Block
    wire i_scl, i_sda;
    wire o_scl, o_sda;
    wire sof;
    wire cam_obuf_rd;
    wire [11:0] cam_obuf_rdata;
    wire cam_obuf_almostempty;
    wire cfg_done;

// Greyscale Block
    wire pp_obuf_rd;
    wire [11:0] pp_obuf_rdata;
    wire pp_obuf_almostempty;
    wire [10:0] pp_obuf_fill;

// Gaussian Block
    wire gssn_obuf_rd;
    wire [11:0] gssn_obuf_rdata;
    wire gssn_obuf_almostempty;

// Sobel Block
    wire sobel_obuf_rd;
    wire [11:0] sobel_obuf_rdata;
    wire sobel_obuf_almostempty;

// Display Interface
    wire [16:0] framebuf_raddr;
    wire [11:0] framebuf_rdata;

// =============================================================
//                    Implementation:
// =============================================================
    assign o_cam_rstn = 1'b1; // sw reset instead
    assign o_cam_pwdn = 1'b0;  
    assign o_cam_xclk = clk_25MHz;  


    assign led_mode      = sys_mode;
    assign led_gaussian  = gaussian_enable;
    assign led_sobel     = sobel_enable;
    assign led_threshold = thresholdBounds;
    
// **** Debounce Reset button ****
// -> debounced in camera pclk domain (24MHz)
    debounce 
    #(.DB_COUNT(1))    // 20ms debounce period
    db_inst (
        .i_clk   (i_cam_pclk),
        .i_input (~i_rst),
        .o_db    (db_rstn)  // 24MHz clock domain debounced reset
    );

// **** Async Reset Synchronizers ****
    // 100 MHz
    reg sync_rstn_PS, q_rstn_PS;
    always@(posedge i_sysclk or negedge db_rstn) begin
        if(!db_rstn) {sync_rstn_PS, q_rstn_PS} <= 2'b0;
        else         {sync_rstn_PS, q_rstn_PS} <= {q_rstn_PS, 1'b1};
    end

    // 25 MHz
    reg sync_rstn_25, q_rstn_25;
    always@(posedge clk_25MHz or negedge db_rstn) begin
        if(!db_rstn) {sync_rstn_25, q_rstn_25} <= 2'b0;
        else         {sync_rstn_25, q_rstn_25} <= {q_rstn_25, 1'b1};
    end

// =============================================================
//                    Submodule Instantiation:
// =============================================================

    //---------------------------------------------------
    //                 Clocking Wizard:
    //---------------------------------------------------

    clk_wiz_0
    dcm_i (
        .clk_25MHz(clk_25MHz), // display pixel clock
        .reset(1'b0),
        .clk_in1(i_sysclk) // 100MHz board clock
    );

    //---------------------------------------------------
    //                 System Control:
    //---------------------------------------------------

    sys_control 
    ctrl_i (
        .i_sysclk(i_sysclk), // 100MHz clock
        .i_rstn(sync_rstn_PS), // active-low sync reset
        
        .i_sof(sof), //Start of Frame
    
        .i_btn_mode(btn_mode), // board button 
        .i_sw_gaussian(sw_gaussian),
        .i_sw_sobel(sw_sobel),
        .i_btn_incSobel(btn_incSobel),
        .i_btn_decSobel(btn_decSobel),
    
        .o_cfg_start(cfg_start), // config module start
        .o_gaussian_enable(gaussian_enable),
        .o_sobel_enable(sobel_enable),
        .o_mode(sys_mode),
        .o_pipe_flush(pipe_flush),
        .o_sobel_threshold(sobel_threshold),
        .o_thresholdBounds(thresholdBounds)              
    );
    
    //---------------------------------------------------
    //                 Camera Block:
    //---------------------------------------------------

    assign SCL = (o_scl) ? 1'bz : 1'b0;
    assign SDA = (o_sda) ? 1'bz : 1'b0;
    assign i_scl = SCL;
    assign i_sda = SDA;

    cam_top 
    #(.T_CFG_CLK(10))
    cam_i (
        .i_cfg_clk(i_sysclk),
        .i_rstn(sync_rstn_PS),
        .o_sof(sof),
    
    // OV7670 external inputs    
        .i_cam_pclk(i_cam_pclk),
        .i_cam_vsync(i_cam_vsync),
        .i_cam_href(i_cam_href),
        .i_cam_data(i_cam_data),

    // i2c  pins
        .i_scl(i_scl),
        .i_sda(i_sda),
        .o_scl(o_scl),
        .o_sda(o_sda),

    // Controls
        .i_cfg_init(cfg_start),
        .o_cfg_done(cfg_done),

    // output buffer read interface
        .i_obuf_rclk(i_sysclk),
        .i_obuf_rstn(sync_rstn_PS),
        .i_obuf_rd(cam_obuf_rd),
        .o_obuf_data(cam_obuf_rdata),
        .o_obuf_empty(),  
        .o_obuf_almostempty(cam_obuf_almostempty),  
        .o_obuf_fill()
    );

    //---------------------------------------------------
    //               Greyscale Converter:
    //---------------------------------------------------

    pp_preprocess pp_i (
        .i_clk(i_sysclk),
        .i_rstn(sync_rstn_PS),
        .i_flush(pipe_flush||sw_freeze),

        // greyscale algorithm enable
        .i_mode(sys_mode),

        // input interface
        .o_rd(cam_obuf_rd),
        .i_data(cam_obuf_rdata),
        .i_almostempty(cam_obuf_almostempty),

        // output buffer interface
        .i_rd(pp_obuf_rd),
        .o_data(pp_obuf_rdata),
        .o_fill(), 
        .o_almostempty (pp_obuf_almostempty)
    );

    //---------------------------------------------------
    //                Gaussian Operator:
    //---------------------------------------------------

    ps_gaussian_top gaussian_i (
        .i_clk(i_sysclk),
        .i_rstn(sync_rstn_PS),
        .i_enable(gaussian_enable),
        .i_flush(pipe_flush||sw_freeze),
          
        .i_data(pp_obuf_rdata),
        .i_almostempty(pp_obuf_almostempty),
        .o_rd(pp_obuf_rd),

        .i_obuf_rd(gssn_obuf_rd),
        .o_obuf_data(gssn_obuf_rdata),
        .o_obuf_fill(),
        .o_obuf_full(),
        .o_obuf_almostfull(),
        .o_obuf_empty(),
        .o_obuf_almostempty(gssn_obuf_almostempty)
    );

    //---------------------------------------------------
    //                Sobel Operator:
    //---------------------------------------------------

    ps_sobel_top sobel_i (
        .i_clk(i_sysclk),
        .i_rstn(sync_rstn_PS),
        .i_enable(sobel_enable),
        .i_flush(pipe_flush||sw_freeze),
        .i_threshold(sobel_threshold),
          
        .i_data(gssn_obuf_rdata),
        .i_almostempty(gssn_obuf_almostempty),
        .o_rd(gssn_obuf_rd),

        .i_obuf_rd(sobel_obuf_rd),
        .o_obuf_data(sobel_obuf_rdata),
        .o_obuf_fill(),
        .o_obuf_full(),
        .o_obuf_almostfull(),
        .o_obuf_empty(),
        .o_obuf_almostempty(sobel_obuf_almostempty)
    );


    //---------------------------------------------------
    //                 Memory Interface:
    //---------------------------------------------------

    mem_interface 
    #(.DATA_WIDTH (12),
      .BRAM_DEPTH (307200) 
     )
    mem_i(
        .i_clk(i_sysclk), // 100 MHz board clock
        .i_rstn(sync_rstn_PS), // active-low sync reset
        .i_flush(pipe_flush||sw_freeze),

    // Input FIFO read interface
        .o_rd(sobel_obuf_rd),
        .i_rdata(sobel_obuf_rdata),
        .i_almostempty(sobel_obuf_almostempty),


    // frame buffer read interface
        .i_rclk(clk_25MHz),
        .i_raddr(framebuf_raddr),
        .o_rdata(framebuf_rdata)
    ); 


    //---------------------------------------------------
    //                 Display Interface:
    //---------------------------------------------------

    vga vga_i(
        .clk25(clk_25MHz),
        .i_mode(sys_mode),
        .red(red),
        .green(green),
        .blue(blue),
        .vga_hsync(hsync),
        .vga_vsync(vsync),
        .HCnt(),
        .VCnt(),
        .frame_addr(framebuf_raddr),
        .frame_pixel(framebuf_rdata)
    );
    
endmodule
