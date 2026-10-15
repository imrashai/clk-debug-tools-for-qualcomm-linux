#!/bin/sh

# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause

_measure ()
{
	clk_name=$1
	clock=$(echo $clocks | tr ';' '\n' | grep -w $clk_name)
	if  [ $? -ne 0 ]; then
		echo "$clk_name is not supported for measure"
		return
	fi

	prim_mux_sel=$(echo $clock | tr ' ' '\n' | head -2 | tail -1)
	prim_mux_name=$(echo $clock | tr ' ' '\n' | head -3 | tail -1)
	num_fields=$(echo $clock | wc -w)

	echo $prim_mux_sel > /sys/kernel/debug/clk/$prim_mux_name/clk_measure

	if [ $num_fields -ge 5 ]; then
		dbg_cc_mux_sel=$(echo $clock | tr ' ' '\n' | head -4 | tail -1)
		dbg_cc_mux_name=$(echo $clock | tr ' ' '\n' | head -5 | tail -1)
		echo $dbg_cc_mux_sel > /sys/kernel/debug/clk/$dbg_cc_mux_name/clk_measure
		val=$(cat /sys/kernel/debug/clk/$dbg_cc_mux_name/clk_measure)
		if [ $num_fields -ge 6 ]; then
			div=$(echo $clock | tr ' ' '\n' | head -6 | tail -1)
			val=$(( val * div ))
		fi
		echo $val
	else
		cat /sys/kernel/debug/clk/$prim_mux_name/clk_measure
	fi
}

clocks="
	audio_core_cc_aif_if0_ebit_clk 0x12D gcc_debug_mux 0x5 audio_core_cc_debug_mux;
	audio_core_cc_aif_if0_ibit_clk 0x12D gcc_debug_mux 0x4 audio_core_cc_debug_mux;
	audio_core_cc_aif_if1_ebit_clk 0x12D gcc_debug_mux 0x7 audio_core_cc_debug_mux;
	audio_core_cc_aif_if1_ibit_clk 0x12D gcc_debug_mux 0x6 audio_core_cc_debug_mux;
	audio_core_cc_aif_if2_ebit_clk 0x12D gcc_debug_mux 0x9 audio_core_cc_debug_mux;
	audio_core_cc_aif_if2_ibit_clk 0x12D gcc_debug_mux 0x8 audio_core_cc_debug_mux;
	audio_core_cc_aif_if3_ebit_clk 0x12D gcc_debug_mux 0xB audio_core_cc_debug_mux;
	audio_core_cc_aif_if3_ibit_clk 0x12D gcc_debug_mux 0xA audio_core_cc_debug_mux;
	audio_core_cc_aud_dma_clk 0x12D gcc_debug_mux 0x2 audio_core_cc_debug_mux;
	audio_core_cc_aud_dma_mem_clk 0x12D gcc_debug_mux 0x3 audio_core_cc_debug_mux;
	audio_core_cc_bus_clk 0x12D gcc_debug_mux 0x1 audio_core_cc_debug_mux;
	audio_core_cc_ext_mclka_out_clk 0x12D gcc_debug_mux 0xC audio_core_cc_debug_mux;
	audio_core_cc_ext_mclkb_out_clk 0x12D gcc_debug_mux 0xD audio_core_cc_debug_mux;
	audio_core_cc_im_sleep_clk 0x12D gcc_debug_mux 0x13 audio_core_cc_debug_mux;
	audio_core_cc_lpaif_pcmoe_clk 0x12D gcc_debug_mux 0x12 audio_core_cc_debug_mux;
	audio_core_cc_rx_mclk_2x_clk 0x12D gcc_debug_mux 0xF audio_core_cc_debug_mux;
	audio_core_cc_rx_mclk_clk 0x12D gcc_debug_mux 0x11 audio_core_cc_debug_mux;
	audio_core_cc_sampling_clk 0x12D gcc_debug_mux 0x0 audio_core_cc_debug_mux;
	audio_core_cc_tx_mclk_2x_clk 0x12D gcc_debug_mux 0xE audio_core_cc_debug_mux;
	audio_core_cc_tx_mclk_clk 0x12D gcc_debug_mux 0x10 audio_core_cc_debug_mux;
	disp_cc_mdss_ahb_clk 0x60 gcc_debug_mux 0x1A disp_cc_debug_mux;
	disp_cc_mdss_byte0_clk 0x60 gcc_debug_mux 0x11 disp_cc_debug_mux;
	disp_cc_mdss_byte0_intf_clk 0x60 gcc_debug_mux 0x12 disp_cc_debug_mux;
	disp_cc_mdss_esc0_clk 0x60 gcc_debug_mux 0x13 disp_cc_debug_mux;
	disp_cc_mdss_mdp_clk 0x60 gcc_debug_mux 0xE disp_cc_debug_mux;
	disp_cc_mdss_mdp_lut_clk 0x60 gcc_debug_mux 0xF disp_cc_debug_mux;
	disp_cc_mdss_non_gdsc_ahb_clk 0x60 gcc_debug_mux 0x1B disp_cc_debug_mux;
	disp_cc_mdss_pclk0_clk 0x60 gcc_debug_mux 0xD disp_cc_debug_mux;
	disp_cc_mdss_vsync_clk 0x60 gcc_debug_mux 0x10 disp_cc_debug_mux;
	disp_cc_sleep_clk 0x60 gcc_debug_mux 0x24 disp_cc_debug_mux;
	disp_cc_xo_clk 0x60 gcc_debug_mux 0x23 disp_cc_debug_mux;
	gcc_ahb2phy_csi_clk 0x86 gcc_debug_mux;
	gcc_ahb2phy_usb_clk 0x87 gcc_debug_mux;
	gcc_boot_rom_ahb_clk 0x9D gcc_debug_mux;
	gcc_cam_throttle_nrt_clk 0x6A gcc_debug_mux;
	gcc_cam_throttle_rt_clk 0x69 gcc_debug_mux;
	gcc_camera_ahb_clk 0x55 gcc_debug_mux;
	gcc_camera_xo_clk 0x5D gcc_debug_mux;
	gcc_camss_axi_clk 0x15B gcc_debug_mux;
	gcc_camss_camnoc_atb_clk 0x15D gcc_debug_mux;
	gcc_camss_camnoc_dragonlink_atb_clk 0x162 gcc_debug_mux;
	gcc_camss_camnoc_nts_xo_clk 0x15E gcc_debug_mux;
	gcc_camss_cci_0_clk 0x159 gcc_debug_mux;
	gcc_camss_cphy_0_clk 0x150 gcc_debug_mux;
	gcc_camss_cphy_1_clk 0x151 gcc_debug_mux;
	gcc_camss_csi0phytimer_clk 0x144 gcc_debug_mux;
	gcc_camss_csi1phytimer_clk 0x145 gcc_debug_mux;
	gcc_camss_mclk0_clk 0x146 gcc_debug_mux;
	gcc_camss_mclk1_clk 0x147 gcc_debug_mux;
	gcc_camss_mclk2_clk 0x148 gcc_debug_mux;
	gcc_camss_mclk3_clk 0x149 gcc_debug_mux;
	gcc_camss_nrt_axi_clk 0x15F gcc_debug_mux;
	gcc_camss_ope_ahb_clk 0x158 gcc_debug_mux;
	gcc_camss_ope_clk 0x156 gcc_debug_mux;
	gcc_camss_rt_axi_clk 0x161 gcc_debug_mux;
	gcc_camss_tfe_0_clk 0x14A gcc_debug_mux;
	gcc_camss_tfe_0_cphy_rx_clk 0x14E gcc_debug_mux;
	gcc_camss_tfe_0_csid_clk 0x152 gcc_debug_mux;
	gcc_camss_tfe_1_clk 0x14C gcc_debug_mux;
	gcc_camss_tfe_1_cphy_rx_clk 0x14F gcc_debug_mux;
	gcc_camss_tfe_1_csid_clk 0x154 gcc_debug_mux;
	gcc_camss_top_ahb_clk 0x15A gcc_debug_mux;
	gcc_cfg_noc_usb2_prim_axi_clk 0x43 gcc_debug_mux;
	gcc_cfg_noc_usb3_prim_axi_clk 0x36 gcc_debug_mux;
	gcc_ddrss_gpu_axi_clk 0xB5 gcc_debug_mux;
	gcc_ddrss_memnoc_pcie_sf_clk 0xC7 gcc_debug_mux;
	gcc_disp_ahb_clk 0x56 gcc_debug_mux;
	gcc_disp_gpll0_div_clk_src 0x65 gcc_debug_mux;
	gcc_disp_hf_axi_clk 0x5B gcc_debug_mux;
	gcc_disp_throttle_core_clk 0x67 gcc_debug_mux;
	gcc_disp_xo_clk 0x5E gcc_debug_mux;
	gcc_emac0_ahb_clk 0x18B gcc_debug_mux;
	gcc_emac0_axi_clk 0x18C gcc_debug_mux;
	gcc_emac0_axi_sys_noc_clk 0x1C gcc_debug_mux;
	gcc_emac0_cc_sgmiiphy_rx_clk 0x192 gcc_debug_mux;
	gcc_emac0_cc_sgmiiphy_rx_clk_src 0x193 gcc_debug_mux;
	gcc_emac0_cc_sgmiiphy_tx_clk 0x190 gcc_debug_mux;
	gcc_emac0_cc_sgmiiphy_tx_clk_src 0x191 gcc_debug_mux;
	gcc_emac0_phy_aux_clk 0x18D gcc_debug_mux;
	gcc_emac0_ptp_clk 0x18E gcc_debug_mux;
	gcc_emac0_rgmii_clk 0x18F gcc_debug_mux;
	gcc_emac1_ahb_clk 0x198 gcc_debug_mux;
	gcc_emac1_axi_clk 0x199 gcc_debug_mux;
	gcc_emac1_axi_sys_noc_clk 0x1D gcc_debug_mux;
	gcc_emac1_cc_sgmiiphy_rx_clk 0x19F gcc_debug_mux;
	gcc_emac1_cc_sgmiiphy_rx_clk_src 0x1A0 gcc_debug_mux;
	gcc_emac1_cc_sgmiiphy_tx_clk 0x19D gcc_debug_mux;
	gcc_emac1_cc_sgmiiphy_tx_clk_src 0x19E gcc_debug_mux;
	gcc_emac1_phy_aux_clk 0x19A gcc_debug_mux;
	gcc_emac1_ptp_clk 0x19B gcc_debug_mux;
	gcc_emac1_rgmii_clk 0x19C gcc_debug_mux;
	gcc_gp1_clk 0xE6 gcc_debug_mux;
	gcc_gp2_clk 0xE7 gcc_debug_mux;
	gcc_gp3_clk 0xE8 gcc_debug_mux;
	gcc_gpu_cfg_ahb_clk 0x119 gcc_debug_mux;
	gcc_gpu_gpll0_clk_src 0x11F gcc_debug_mux;
	gcc_gpu_gpll0_div_clk_src 0x120 gcc_debug_mux;
	gcc_gpu_memnoc_gfx_clk 0x11C gcc_debug_mux;
	gcc_gpu_snoc_dvm_gfx_clk 0x11E gcc_debug_mux;
	gcc_gpu_throttle_core_clk 0x123 gcc_debug_mux;
	gcc_lpass_config_clk 0x12B gcc_debug_mux;
	gcc_lpass_core_axim_clk 0x12A gcc_debug_mux;
	gcc_pcie_aux_clk 0x1AA gcc_debug_mux;
	gcc_pcie_aux_clk_src 0x1AE gcc_debug_mux;
	gcc_pcie_cfg_ahb_clk 0x1A5 gcc_debug_mux;
	gcc_pcie_mstr_axi_clk 0x1A8 gcc_debug_mux;
	gcc_pcie_pipe_clk 0x1AC gcc_debug_mux;
	gcc_pcie_pipe_clk_src 0x1AD gcc_debug_mux;
	gcc_pcie_rchng_phy_clk 0x1A9 gcc_debug_mux;
	gcc_pcie_sleep_clk 0x1AB gcc_debug_mux;
	gcc_pcie_slv_axi_clk 0x1A7 gcc_debug_mux;
	gcc_pcie_slv_q2a_axi_clk 0x1A6 gcc_debug_mux;
	gcc_pcie_tbu_clk 0x1B4 gcc_debug_mux;
	gcc_pcie_throttle_core_clk 0x1B3 gcc_debug_mux;
	gcc_pcie_throttle_xo_clk 0x1B2 gcc_debug_mux;
	gcc_pcie_tile_axi_sys_noc_clk 0x32 gcc_debug_mux;
	gcc_pdm2_clk 0x9A gcc_debug_mux;
	gcc_pdm_ahb_clk 0x98 gcc_debug_mux;
	gcc_pdm_xo4_clk 0x99 gcc_debug_mux;
	gcc_pwm0_xo512_clk 0x9B gcc_debug_mux;
	gcc_qmip_camera_nrt_ahb_clk 0x58 gcc_debug_mux;
	gcc_qmip_camera_rt_ahb_clk 0x66 gcc_debug_mux;
	gcc_qmip_disp_ahb_clk 0x59 gcc_debug_mux;
	gcc_qmip_gpu_cfg_ahb_clk 0x121 gcc_debug_mux;
	gcc_qmip_pcie_cfg_ahb_clk 0x1B1 gcc_debug_mux;
	gcc_qmip_video_vcodec_ahb_clk 0x57 gcc_debug_mux;
	gcc_qupv3_wrap0_core_2x_clk 0x8D gcc_debug_mux;
	gcc_qupv3_wrap0_core_clk 0x8C gcc_debug_mux;
	gcc_qupv3_wrap0_s0_clk 0x8E gcc_debug_mux;
	gcc_qupv3_wrap0_s1_clk 0x8F gcc_debug_mux;
	gcc_qupv3_wrap0_s2_clk 0x90 gcc_debug_mux;
	gcc_qupv3_wrap0_s3_clk 0x91 gcc_debug_mux;
	gcc_qupv3_wrap0_s4_clk 0x92 gcc_debug_mux;
	gcc_qupv3_wrap0_s5_clk 0x93 gcc_debug_mux;
	gcc_qupv3_wrap0_s6_clk 0x94 gcc_debug_mux;
	gcc_qupv3_wrap0_s7_clk 0x95 gcc_debug_mux;
	gcc_qupv3_wrap0_s8_clk 0x96 gcc_debug_mux;
	gcc_qupv3_wrap0_s9_clk 0x97 gcc_debug_mux;
	gcc_qupv3_wrap_0_m_ahb_clk 0x8A gcc_debug_mux;
	gcc_qupv3_wrap_0_s_ahb_clk 0x8B gcc_debug_mux;
	gcc_sdcc1_ahb_clk 0x127 gcc_debug_mux;
	gcc_sdcc1_apps_clk 0x126 gcc_debug_mux;
	gcc_sdcc1_ice_core_clk 0x128 gcc_debug_mux;
	gcc_sdcc2_ahb_clk 0x89 gcc_debug_mux;
	gcc_sdcc2_apps_clk 0x88 gcc_debug_mux;
	gcc_sys_noc_cpuss_ahb_clk 0x9 gcc_debug_mux;
	gcc_sys_noc_usb2_prim_axi_clk 0x1E gcc_debug_mux;
	gcc_sys_noc_usb3_prim_axi_clk 0x18 gcc_debug_mux;
	gcc_tscss_ahb_clk 0x18A gcc_debug_mux;
	gcc_tscss_cntr_clk 0x189 gcc_debug_mux;
	gcc_tscss_etu_clk 0x188 gcc_debug_mux;
	gcc_usb20_master_clk 0x1B6 gcc_debug_mux;
	gcc_usb20_mock_utmi_clk 0x1B8 gcc_debug_mux;
	gcc_usb20_sleep_clk 0x1B7 gcc_debug_mux;
	gcc_usb30_prim_master_clk 0x7E gcc_debug_mux;
	gcc_usb30_prim_mock_utmi_clk 0x80 gcc_debug_mux;
	gcc_usb30_prim_sleep_clk 0x7F gcc_debug_mux;
	gcc_usb3_prim_phy_com_aux_clk 0x81 gcc_debug_mux;
	gcc_usb3_prim_phy_pipe_clk 0x82 gcc_debug_mux;
	gcc_usb3_prim_phy_pipe_clk_src 0x83 gcc_debug_mux;
	gcc_vcodec0_axi_clk 0x168 gcc_debug_mux;
	gcc_venus_ahb_clk 0x169 gcc_debug_mux;
	gcc_venus_ctl_axi_clk 0x167 gcc_debug_mux;
	gcc_video_ahb_clk 0x54 gcc_debug_mux;
	gcc_video_axi0_clk 0x5A gcc_debug_mux;
	gcc_video_throttle_core_clk 0x68 gcc_debug_mux;
	gcc_video_vcodec0_sys_clk 0x165 gcc_debug_mux;
	gcc_video_venus_ctl_clk 0x163 gcc_debug_mux;
	gcc_video_xo_clk 0x5C gcc_debug_mux;
	gpu_cc_ahb_clk 0x11B gcc_debug_mux 0x10 gpu_cc_debug_mux;
	gpu_cc_crc_ahb_clk 0x11B gcc_debug_mux 0x11 gpu_cc_debug_mux;
	gpu_cc_cx_gfx3d_clk 0x11B gcc_debug_mux 0x1A gpu_cc_debug_mux;
	gpu_cc_cx_gfx3d_slv_clk 0x11B gcc_debug_mux 0x1B gpu_cc_debug_mux;
	gpu_cc_cx_gmu_clk 0x11B gcc_debug_mux 0x18 gpu_cc_debug_mux;
	gpu_cc_cx_snoc_dvm_clk 0x11B gcc_debug_mux 0x15 gpu_cc_debug_mux;
	gpu_cc_cxo_aon_clk 0x11B gcc_debug_mux 0xA gpu_cc_debug_mux;
	gpu_cc_cxo_clk 0x11B gcc_debug_mux 0x19 gpu_cc_debug_mux;
	gpu_cc_gx_cxo_clk 0x11B gcc_debug_mux 0xE gpu_cc_debug_mux;
	gpu_cc_gx_gfx3d_clk 0x11B gcc_debug_mux 0xB gpu_cc_debug_mux;
	gpu_cc_sleep_clk 0x11B gcc_debug_mux 0x16 gpu_cc_debug_mux;
	measure_only_cnoc_clk 0x33 gcc_debug_mux;
	measure_only_gcc_cpuss_gnoc_clk 0xD6 gcc_debug_mux;
	measure_only_hwkm_ahb_clk 0xD2 gcc_debug_mux;
	measure_only_ipa_2x_clk 0xF9 gcc_debug_mux;
	measure_only_mccc_clk 0xff mc_cc_debug_mux;
	measure_only_pka_ahb_clk 0xD4 gcc_debug_mux;
	measure_only_pka_core_clk 0xD3 gcc_debug_mux;
	measure_only_qpic_ahb_clk 0xCE gcc_debug_mux;
	measure_only_qpic_clk 0xCC gcc_debug_mux;
	measure_only_snoc_clk 0x7 gcc_debug_mux;
"

if [ $# -lt 1 ]; then
	echo "No clock name passed"
	return 0
fi

_measure $1
