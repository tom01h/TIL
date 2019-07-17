onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TOP/top/batch_ctrl/prm_v
add wave -noupdate /TOP/top/batch_ctrl/src_v
add wave -noupdate /TOP/top/s_init
add wave -noupdate /TOP/top/s_fin
add wave -noupdate /TOP/top/dst_buf/dst_v
add wave -noupdate /TOP/top/k_init
add wave -noupdate /TOP/top/exec
add wave -noupdate /TOP/top/k_fin
add wave -noupdate /TOP/top/outr
add wave -noupdate /TOP/top/AXIS_ACLK
add wave -noupdate /TOP/top/run
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {438 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {0 ns} {2972 ns}
