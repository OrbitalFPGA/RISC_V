set_property PACKAGE_PIN W19 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

create_clock -name clk -period 5.000 [get_ports clk]