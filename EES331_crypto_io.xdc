## EES331 crypto/decrypto IO constraints
## Device: xc7z020clg484-1

## Target clock (period 8.200ns => 121.951MHz)
set_property PACKAGE_PIN M19 [get_ports clk_100m]
set_property IOSTANDARD LVCMOS33 [get_ports clk_100m]
create_clock -period 12.000 -name sys_clk [get_ports clk_100m]

## Light-touch timing micro-optimization constraints
## 1) Encourage fanout replication during synthesis/opt
set_max_fanout 32 [current_design]

## Mode button (S1, FPGA_RESET)
set_property PACKAGE_PIN L18 [get_ports btn_mode]
set_property IOSTANDARD LVCMOS33 [get_ports btn_mode]

## DIP switches SW0~SW7
set_property PACKAGE_PIN AB6 [get_ports {sw[0]}]
set_property PACKAGE_PIN Y4 [get_ports {sw[1]}]
set_property PACKAGE_PIN AA4 [get_ports {sw[2]}]
set_property PACKAGE_PIN R6 [get_ports {sw[3]}]
set_property PACKAGE_PIN T6 [get_ports {sw[4]}]
set_property PACKAGE_PIN T4 [get_ports {sw[5]}]
set_property PACKAGE_PIN U4 [get_ports {sw[6]}]
set_property PACKAGE_PIN V5 [get_ports {sw[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[*]}]

## LEDs LED0~LED7
set_property PACKAGE_PIN V4 [get_ports {led[0]}]
set_property PACKAGE_PIN U6 [get_ports {led[1]}]
set_property PACKAGE_PIN U5 [get_ports {led[2]}]
set_property PACKAGE_PIN V7 [get_ports {led[3]}]
set_property PACKAGE_PIN W7 [get_ports {led[4]}]
set_property PACKAGE_PIN W6 [get_ports {led[5]}]
set_property PACKAGE_PIN W5 [get_ports {led[6]}]
set_property PACKAGE_PIN U7 [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]

## 7-seg low bank segment lines: LED0_CA~LED0_DP
set_property PACKAGE_PIN R21 [get_ports {seg0[0]}]
set_property PACKAGE_PIN P20 [get_ports {seg0[1]}]
set_property PACKAGE_PIN P21 [get_ports {seg0[2]}]
set_property PACKAGE_PIN N15 [get_ports {seg0[3]}]
set_property PACKAGE_PIN P15 [get_ports {seg0[4]}]
set_property PACKAGE_PIN P17 [get_ports {seg0[5]}]
set_property PACKAGE_PIN P18 [get_ports {seg0[6]}]
set_property PACKAGE_PIN T16 [get_ports {seg0[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg0[*]}]

## 7-seg high bank segment lines: LED1_CA~LED1_DP
set_property PACKAGE_PIN T17 [get_ports {seg1[0]}]
set_property PACKAGE_PIN R19 [get_ports {seg1[1]}]
set_property PACKAGE_PIN T19 [get_ports {seg1[2]}]
set_property PACKAGE_PIN R18 [get_ports {seg1[3]}]
set_property PACKAGE_PIN T18 [get_ports {seg1[4]}]
set_property PACKAGE_PIN P16 [get_ports {seg1[5]}]
set_property PACKAGE_PIN R16 [get_ports {seg1[6]}]
set_property PACKAGE_PIN R15 [get_ports {seg1[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg1[*]}]

## 7-seg digit select lines: LED_BIT1~LED_BIT8
set_property PACKAGE_PIN M20 [get_ports {dig_sel[0]}]
set_property PACKAGE_PIN N19 [get_ports {dig_sel[1]}]
set_property PACKAGE_PIN N20 [get_ports {dig_sel[2]}]
set_property PACKAGE_PIN M21 [get_ports {dig_sel[3]}]
set_property PACKAGE_PIN M22 [get_ports {dig_sel[4]}]
set_property PACKAGE_PIN N22 [get_ports {dig_sel[5]}]
set_property PACKAGE_PIN P22 [get_ports {dig_sel[6]}]
set_property PACKAGE_PIN R20 [get_ports {dig_sel[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dig_sel[*]}]


create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clk_100m_IBUF_BUFG]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 16 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {dbg_rf_wdata[0]} {dbg_rf_wdata[1]} {dbg_rf_wdata[2]} {dbg_rf_wdata[3]} {dbg_rf_wdata[4]} {dbg_rf_wdata[5]} {dbg_rf_wdata[6]} {dbg_rf_wdata[7]} {dbg_rf_wdata[8]} {dbg_rf_wdata[9]} {dbg_rf_wdata[10]} {dbg_rf_wdata[11]} {dbg_rf_wdata[12]} {dbg_rf_wdata[13]} {dbg_rf_wdata[14]} {dbg_rf_wdata[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 2 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {dbg_load_waddr[0]} {dbg_load_waddr[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 16 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {dbg_ram_rdata_mem[0]} {dbg_ram_rdata_mem[1]} {dbg_ram_rdata_mem[2]} {dbg_ram_rdata_mem[3]} {dbg_ram_rdata_mem[4]} {dbg_ram_rdata_mem[5]} {dbg_ram_rdata_mem[6]} {dbg_ram_rdata_mem[7]} {dbg_ram_rdata_mem[8]} {dbg_ram_rdata_mem[9]} {dbg_ram_rdata_mem[10]} {dbg_ram_rdata_mem[11]} {dbg_ram_rdata_mem[12]} {dbg_ram_rdata_mem[13]} {dbg_ram_rdata_mem[14]} {dbg_ram_rdata_mem[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 2 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {dbg_rf_waddr[0]} {dbg_rf_waddr[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 16 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {instr[0]} {instr[1]} {instr[2]} {instr[3]} {instr[4]} {instr[5]} {instr[6]} {instr[7]} {instr[8]} {instr[9]} {instr[10]} {instr[11]} {instr[12]} {instr[13]} {instr[14]} {instr[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 16 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {dbg_ram_addr[0]} {dbg_ram_addr[1]} {dbg_ram_addr[2]} {dbg_ram_addr[3]} {dbg_ram_addr[4]} {dbg_ram_addr[5]} {dbg_ram_addr[6]} {dbg_ram_addr[7]} {dbg_ram_addr[8]} {dbg_ram_addr[9]} {dbg_ram_addr[10]} {dbg_ram_addr[11]} {dbg_ram_addr[12]} {dbg_ram_addr[13]} {dbg_ram_addr[14]} {dbg_ram_addr[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 8 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {rom_addr[0]} {rom_addr[1]} {rom_addr[2]} {rom_addr[3]} {rom_addr[4]} {rom_addr[5]} {rom_addr[6]} {rom_addr[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list dbg_mem_read]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list dbg_mem_wait]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list PC_Stall]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list rf_regwrite]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_100m_IBUF_BUFG]
