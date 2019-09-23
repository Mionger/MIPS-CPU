# CPU通用寄存器使用情况
#  0 零寄存器，不用
#  1 不用
#  2 
#  3 开关运算寄存器
#  4
#  5 数据段地址
#  6 音量控制器读取的数据        *
#  7 曲目控制器读取的数据        *
#  8 要送往LED的数据            *
#  9 要送往SEG的数据             
# 10 蓝牙模块处理过的信号        *
# 11 旋转编码器处理过的信号      *
# 12 MP3模块曲目寄存器          *
# 13 开关传入的信息      
# 14 MP3模块音量寄存器          *
# 15 时间寄存器                 *
# 16 从SD卡读取的数据            **
# 17 
# 18 
# 19 
# 20 
# 21
# 22
# 23
# 24
# 25
# 26
# 27
# 28 
# 29 
# 30 
# 31 子程序返回地址
sll  $0, $0, 0
j    _reset

_main:
# 读取SD卡中的内容
lw   $16, 0x838($5)

# 将SD卡读出来的初始化音量送往音量寄存器
addi $6, $0, 0
add  $6, $16, $0
sw   $6, 0x840($5)

# 将SD卡读出来的初始化音量送往MP3
addi $14, $0, 0
add  $14, $16, $0
sw   $14, 0x804($5)

_main_start:
# # 更新音量
lw   $6, 0x800($5)
lw   $14, 0x830($5)
bne  $6, $14, _update_vol
_update_vol_return:

# 更新曲目
lw   $7, 0x808($5)
lw   $12, 0x828($5)
bne  $7, $12, _update_sw
_update_sw_return:

# 读取其他传感器的数据
lw   $8, 0x810($5)
lw   $9, 0x814($5)
lw   $10, 0x820($5)
lw   $11, 0x824($5)
lw   $13, 0x82c($5)
lw   $15, 0x834($5)

# 显示程序
lw   $13, 0x82c($5)
andi $3, $13, 0x1
bne  $3, $0, _display_1
andi $3, $13, 0x2
bne  $3, $0, _display_2
andi $3, $13, 0x4
bne  $3, $0, _display_3
andi $3, $13, 0x8
bne  $3, $0, _display_4
andi $3, $13, 0x10
bne  $3, $0, _display_5
andi $3, $13, 0x20
bne  $3, $0, _display_6
andi $3, $13, 0x40
bne  $3, $0, _display_7
andi $3, $13, 0x80
bne  $3, $0, _display_8
andi $3, $13, 0x100
bne  $3, $0, _display_11
j    _display
_display_return:

# 判断是否开始
lw   $13, 0x82c($5)
andi $3, $13, 0x8000
beq  $3, $0, _reset
j    _main_start

_reset:
# 初始化基址寄存器
addi $5, $0, 0
addi $5, $0, 0x10010000

# SD卡初始化
_sd_init:
lw   $18, 0x83c($5)
andi $3, $18, 0x2
bne  $3, $0, _sd_read_over
lw   $13, 0x82c($5)
andi $3, $13, 0x100
bne  $3, $0, _display_9
_sd_init_display_return:
andi $3, $18, 0x1
beq  $3, $0, _sd_init  

# SD卡读取
_sd_read:
lw   $18, 0x83c($5)
lw   $13, 0x82c($5)
andi $3, $13, 0x100
bne  $3, $0, _display_10
_sd_read_display_return:
andi $3, $18, 0x2
beq  $3, $0, _sd_read

_sd_read_over:
# 判断是否开始
lw   $13, 0x82c($5)
andi $3, $13, 0x8000
beq  $3, $0, _reset

# 初始化剩余的寄存器
addi $7, $0, 0
addi $8, $0, 0
addi $9, $0, 0
addi $10, $0, 0
addi $11, $0, 0
addi $12, $0, 0
addi $15, $0, 0
j    _main

# 更新MP3的音量
_update_vol:
lw   $6, 0x800($5)
sw   $6, 0x804($5)
j    _update_vol_return

# 更新MP3的曲目
_update_sw:
sw   $7, 0x80c($5)
j    _update_sw_return

_display:
sw   $8, 0x818($5)
sw   $9, 0x81c($5)
j    _display_return

_display_1:
sw   $6, 0x818($5)
sw   $9, 0x81c($5)
j    _display_return

_display_2:
sw   $7, 0x818($5)
sw   $9, 0x81c($5)
j    _display_return

_display_3:
sw   $10, 0x818($5)
sw   $9, 0x81c($5)
j    _display_return

_display_4:
sw   $11, 0x818($5)
sw   $9, 0x81c($5)
j    _display_return

_display_5:
sw   $12, 0x818($5)
sw   $9, 0x81c($5)
j    _display_return

_display_6:
sw   $14, 0x818($5)
sw   $9, 0x81c($5)
j    _display_return

_display_7:
sw   $15, 0x818($5)
sw   $9, 0x81c($5)
j    _display_return

_display_8:
sw   $16, 0x818($5)
sw   $9, 0x81c($5)
j    _display_return

_display_9:
sw   $18, 0x818($5)
sw   $9, 0x81c($5)
j    _sd_init_display_return

_display_10:
sw   $18, 0x818($5)
sw   $9, 0x81c($5)
j    _sd_read_display_return

_display_11:
sw   $18, 0x818($5)
sw   $9, 0x81c($5)
j    _display_return