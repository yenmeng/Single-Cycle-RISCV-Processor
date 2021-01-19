 
****************************************
Report : resources
Design : RISCV
Version: N-2017.09-SP2
Date   : Sat Jan  9 01:22:54 2021
****************************************


Resource Report for this hierarchy in file
        /home/raid7_2/userb06/b06066/CA/Final_Project_v2/RISCV.v
=============================================================================
| Cell           | Module         | Parameters | Contained Operations       |
=============================================================================
| add_x_24       | DW01_add       | width=64   | ALU/add_135 (RISCV.v:135)  |
| ash_26         | DW_leftsh      | A_width=64 | ALU/sll_143 (RISCV.v:143)  |
|                |                | SH_width=64 |                           |
| lt_x_27        | DW_cmp         | width=64   | ALU/lt_147 (RISCV.v:147)   |
| ashr_28        | DW_rightsh     | A_width=64 | ALU/sra_159 (RISCV.v:159)  |
|                |                | SH_width=64 | ALU/srl_155 (RISCV.v:155) |
| sub_x_25       | DW01_sub       | width=64   | ALU/sub_139 (RISCV.v:139)  |
|                |                |            | ALU/sub_171 (RISCV.v:171)  |
| add_x_1        | DW01_inc       | width=31   | add_77 (RISCV.v:77)        |
|                |                |            | add_92_S2 (RISCV.v:92)     |
| DP_OP_88_125_7761               |            |                            |
|                | DP_OP_88_125_7761 |         |                            |
=============================================================================

Datapath Report for DP_OP_88_125_7761
==============================================================================
| Cell                 | Contained Operations                                |
==============================================================================
| DP_OP_88_125_7761    | add_76_S2 (RISCV.v:76) add_74_S2 (RISCV.v:74)       |
==============================================================================

==============================================================================
|       |      | Data     |       |                                          |
| Var   | Type | Class    | Width | Expression                               |
==============================================================================
| I1    | PI   | Unsigned | 30    |                                          |
| I2    | PI   | Unsigned | 30    |                                          |
| O1    | PO   | Unsigned | 30    | I1 + I2 ( RISCV.v:74 RISCV.v:76 )        |
==============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| add_x_24           | DW01_add         | pparch (area,speed)                 |
| ash_26             | DW_leftsh        | astr (area)        |                |
| lt_x_27            | DW_cmp           | apparch (area)     |                |
| ashr_28            | DW_rightsh       | astr (area)        |                |
| sub_x_25           | DW01_sub         | pparch (area,speed)                 |
| add_x_1            | DW01_inc         | pparch (area,speed)                 |
| DP_OP_88_125_7761  | DP_OP_88_125_7761 | str (area,speed)  |                |
===============================================================================


No resource sharing information to report.
 
****************************************
Design : REGFILE
****************************************

No implementations to report
1
