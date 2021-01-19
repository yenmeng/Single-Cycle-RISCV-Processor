wvSetPosition -win $_nWave1 {("G1" 0)}
wvOpenFile -win $_nWave1 \
           {/home/raid7_2/userb06/b06066/CA/Final_Project_v2/RISCV.fsdb}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/RISCV_tb"
wvGetSignalSetScope -win $_nWave1 "/RISCV_tb/mem_I"
wvGetSignalSetScope -win $_nWave1 "/RISCV_tb/chip0"
wvGetSignalSetScope -win $_nWave1 "/RISCV_tb/chip0/regfile"
wvSetPosition -win $_nWave1 {("G1" 1)}
wvSetPosition -win $_nWave1 {("G1" 1)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/RISCV_tb/chip0/regfile/registers\[0:31\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 1 )} 
wvSetPosition -win $_nWave1 {("G1" 1)}
wvGetSignalClose -win $_nWave1
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/RISCV_tb"
wvGetSignalSetScope -win $_nWave1 "/RISCV_tb/chip0"
wvGetSignalSetScope -win $_nWave1 "/RISCV_tb/chip0/regfile"
wvSetPosition -win $_nWave1 {("G1" 3)}
wvSetPosition -win $_nWave1 {("G1" 3)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/RISCV_tb/chip0/regfile/registers\[0:31\]} \
{/RISCV_tb/chip0/regfile/clk} \
{/RISCV_tb/chip0/regfile/rst_n} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 2 3 )} 
wvSetPosition -win $_nWave1 {("G1" 3)}
wvGetSignalClose -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/RISCV_tb"
wvGetSignalSetScope -win $_nWave1 "/RISCV_tb/chip0"
wvGetSignalSetScope -win $_nWave1 "/RISCV_tb/chip0/regfile"
wvGetSignalSetScope -win $_nWave1 "/RISCV_tb/chip0/regfile"
wvGetSignalSetScope -win $_nWave1 "/RISCV_tb"
wvSetPosition -win $_nWave1 {("G1" 5)}
wvSetPosition -win $_nWave1 {("G1" 5)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/RISCV_tb/chip0/regfile/registers\[0:31\]} \
{/RISCV_tb/chip0/regfile/clk} \
{/RISCV_tb/chip0/regfile/rst_n} \
{/RISCV_tb/mem_addr_I\[31:2\]} \
{/RISCV_tb/mem_rdata_D\[63:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 4 5 )} 
wvSetPosition -win $_nWave1 {("G1" 5)}
wvGetSignalClose -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvExit
