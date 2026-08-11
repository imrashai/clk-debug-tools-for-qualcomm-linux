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
	cam_cc_camnoc_axi_clk 0x8C gcc_debug_mux 0x35 cam_cc_debug_mux;
	cam_cc_camnoc_dcd_xo_clk 0x8C gcc_debug_mux 0x36 cam_cc_debug_mux;
	cam_cc_camnoc_xo_clk 0x8C gcc_debug_mux 0x37 cam_cc_debug_mux;
	cam_cc_cci_0_clk 0x8C gcc_debug_mux 0x30 cam_cc_debug_mux;
	cam_cc_cci_1_clk 0x8C gcc_debug_mux 0x31 cam_cc_debug_mux;
	cam_cc_cci_2_clk 0x8C gcc_debug_mux 0x5 cam_cc_debug_mux;
	cam_cc_cci_3_clk 0x8C gcc_debug_mux 0x6 cam_cc_debug_mux;
	cam_cc_core_ahb_clk 0x8C gcc_debug_mux 0x3A cam_cc_debug_mux;
	cam_cc_cpas_ahb_clk 0x8C gcc_debug_mux 0x32 cam_cc_debug_mux;
	cam_cc_cpas_fast_ahb_clk 0x8C gcc_debug_mux 0x33 cam_cc_debug_mux;
	cam_cc_cpas_ife_0_clk 0x8C gcc_debug_mux 0x18 cam_cc_debug_mux;
	cam_cc_cpas_ife_1_clk 0x8C gcc_debug_mux 0x1D cam_cc_debug_mux;
	cam_cc_cpas_ife_lite_clk 0x8C gcc_debug_mux 0x22 cam_cc_debug_mux;
	cam_cc_cpas_ipe_clk 0x8C gcc_debug_mux 0x13 cam_cc_debug_mux;
	cam_cc_cpas_sfe_lite_0_clk 0x8C gcc_debug_mux 0x27 cam_cc_debug_mux;
	cam_cc_cpas_sfe_lite_1_clk 0x8C gcc_debug_mux 0x2B cam_cc_debug_mux;
	cam_cc_csi0phytimer_clk 0x8C gcc_debug_mux 0x9 cam_cc_debug_mux;
	cam_cc_csi1phytimer_clk 0x8C gcc_debug_mux 0xC cam_cc_debug_mux;
	cam_cc_csi2phytimer_clk 0x8C gcc_debug_mux 0xE cam_cc_debug_mux;
	cam_cc_csi3phytimer_clk 0x8C gcc_debug_mux 0x10 cam_cc_debug_mux;
	cam_cc_csid_clk 0x8C gcc_debug_mux 0x34 cam_cc_debug_mux;
	cam_cc_csid_csiphy_rx_clk 0x8C gcc_debug_mux 0xB cam_cc_debug_mux;
	cam_cc_csiphy0_clk 0x8C gcc_debug_mux 0xA cam_cc_debug_mux;
	cam_cc_csiphy1_clk 0x8C gcc_debug_mux 0xD cam_cc_debug_mux;
	cam_cc_csiphy2_clk 0x8C gcc_debug_mux 0xF cam_cc_debug_mux;
	cam_cc_csiphy3_clk 0x8C gcc_debug_mux 0x11 cam_cc_debug_mux;
	cam_cc_icp_ahb_clk 0x8C gcc_debug_mux 0x2F cam_cc_debug_mux;
	cam_cc_icp_clk 0x8C gcc_debug_mux 0x2E cam_cc_debug_mux;
	cam_cc_ife_0_clk 0x8C gcc_debug_mux 0x17 cam_cc_debug_mux;
	cam_cc_ife_0_fast_ahb_clk 0x8C gcc_debug_mux 0x1B cam_cc_debug_mux;
	cam_cc_ife_1_clk 0x8C gcc_debug_mux 0x1C cam_cc_debug_mux;
	cam_cc_ife_1_fast_ahb_clk 0x8C gcc_debug_mux 0x20 cam_cc_debug_mux;
	cam_cc_ife_lite_ahb_clk 0x8C gcc_debug_mux 0x25 cam_cc_debug_mux;
	cam_cc_ife_lite_clk 0x8C gcc_debug_mux 0x21 cam_cc_debug_mux;
	cam_cc_ife_lite_cphy_rx_clk 0x8C gcc_debug_mux 0x24 cam_cc_debug_mux;
	cam_cc_ife_lite_csid_clk 0x8C gcc_debug_mux 0x23 cam_cc_debug_mux;
	cam_cc_ipe_ahb_clk 0x8C gcc_debug_mux 0x15 cam_cc_debug_mux;
	cam_cc_ipe_clk 0x8C gcc_debug_mux 0x12 cam_cc_debug_mux;
	cam_cc_ipe_fast_ahb_clk 0x8C gcc_debug_mux 0x16 cam_cc_debug_mux;
	cam_cc_mclk0_clk 0x8C gcc_debug_mux 0x1 cam_cc_debug_mux;
	cam_cc_mclk1_clk 0x8C gcc_debug_mux 0x2 cam_cc_debug_mux;
	cam_cc_mclk2_clk 0x8C gcc_debug_mux 0x3 cam_cc_debug_mux;
	cam_cc_mclk3_clk 0x8C gcc_debug_mux 0x4 cam_cc_debug_mux;
	cam_cc_sfe_lite_0_clk 0x8C gcc_debug_mux 0x26 cam_cc_debug_mux;
	cam_cc_sfe_lite_0_fast_ahb_clk 0x8C gcc_debug_mux 0x29 cam_cc_debug_mux;
	cam_cc_sfe_lite_1_clk 0x8C gcc_debug_mux 0x2A cam_cc_debug_mux;
	cam_cc_sfe_lite_1_fast_ahb_clk 0x8C gcc_debug_mux 0x2D cam_cc_debug_mux;
	cam_cc_sleep_clk 0x8C gcc_debug_mux 0x3C cam_cc_debug_mux;
	gcc_aggre_noc_qupv3_axi_clk 0x224 gcc_debug_mux;
	gcc_aggre_ufs_card_axi_clk 0x1E8 gcc_debug_mux;
	gcc_aggre_ufs_phy_axi_clk 0x1E7 gcc_debug_mux;
	gcc_aggre_usb2_prim_axi_clk 0x1E5 gcc_debug_mux;
	gcc_aggre_usb3_prim_axi_clk 0x1E3 gcc_debug_mux;
	gcc_aggre_usb3_sec_axi_clk 0x1E4 gcc_debug_mux;
	gcc_ahb2phy0_clk 0xED gcc_debug_mux;
	gcc_ahb2phy2_clk 0xEE gcc_debug_mux;
	gcc_ahb2phy3_clk 0xEF gcc_debug_mux;
	gcc_boot_rom_ahb_clk 0x114 gcc_debug_mux;
	gcc_camera_hf_axi_clk 0x86 gcc_debug_mux;
	gcc_camera_sf_axi_clk 0x88 gcc_debug_mux;
	gcc_camera_throttle_xo_clk 0x8B gcc_debug_mux;
	gcc_camera_trig_clk 0x81 gcc_debug_mux;
	gcc_cfg_noc_usb2_prim_axi_clk 0x39 gcc_debug_mux;
	gcc_cfg_noc_usb3_prim_axi_clk 0x37 gcc_debug_mux;
	gcc_cfg_noc_usb3_sec_axi_clk 0x38 gcc_debug_mux;
	gcc_ddrss_gpu_axi_clk 0x13E gcc_debug_mux;
	gcc_disp1_hf_axi_clk 0x96 gcc_debug_mux;
	gcc_disp_hf_axi_clk 0x90 gcc_debug_mux;
	gcc_emac0_axi_clk 0x204 gcc_debug_mux;
	gcc_emac0_phy_aux_clk 0x206 gcc_debug_mux;
	gcc_emac0_ptp_clk 0x207 gcc_debug_mux;
	gcc_emac0_rgmii_clk 0x208 gcc_debug_mux;
	gcc_emac0_slv_ahb_clk 0x205 gcc_debug_mux;
	gcc_emac1_axi_clk 0x20D gcc_debug_mux;
	gcc_emac1_phy_aux_clk 0x20F gcc_debug_mux;
	gcc_emac1_ptp_clk 0x210 gcc_debug_mux;
	gcc_emac1_rgmii_clk 0x211 gcc_debug_mux;
	gcc_emac1_slv_ahb_clk 0x20E gcc_debug_mux;
	gcc_gp1_clk 0x183 gcc_debug_mux;
	gcc_gp2_clk 0x184 gcc_debug_mux;
	gcc_gp3_clk 0x185 gcc_debug_mux;
	gcc_gp4_clk 0x234 gcc_debug_mux;
	gcc_gp5_clk 0x235 gcc_debug_mux;
	gcc_gpu_gpll0_clk_src 0x1FB gcc_debug_mux;
	gcc_gpu_gpll0_div_clk_src 0x1FC gcc_debug_mux;
	gcc_gpu_memnoc_gfx_clk 0x1F7 gcc_debug_mux;
	gcc_gpu_snoc_dvm_gfx_clk 0x1FA gcc_debug_mux;
	gcc_gpu_tcu_throttle_ahb_clk 0x1F4 gcc_debug_mux;
	gcc_gpu_tcu_throttle_clk 0x1F8 gcc_debug_mux;
	gcc_pcie_0_aux_clk 0x198 gcc_debug_mux;
	gcc_pcie_0_cfg_ahb_clk 0x196 gcc_debug_mux;
	gcc_pcie_0_mstr_axi_clk 0x195 gcc_debug_mux;
	gcc_pcie_0_phy_aux_clk 0x197 gcc_debug_mux;
	gcc_pcie_0_phy_rchng_clk 0x19B gcc_debug_mux;
	gcc_pcie_0_pipe_clk 0x199 gcc_debug_mux;
	gcc_pcie_0_pipediv2_clk 0x19A gcc_debug_mux;
	gcc_pcie_0_slv_axi_clk 0x194 gcc_debug_mux;
	gcc_pcie_0_slv_q2a_axi_clk 0x193 gcc_debug_mux;
	gcc_pcie_1_aux_clk 0x18B gcc_debug_mux;
	gcc_pcie_1_cfg_ahb_clk 0x189 gcc_debug_mux;
	gcc_pcie_1_mstr_axi_clk 0x188 gcc_debug_mux;
	gcc_pcie_1_phy_aux_clk 0x18A gcc_debug_mux;
	gcc_pcie_1_phy_rchng_clk 0x18E gcc_debug_mux;
	gcc_pcie_1_pipe_clk 0x18C gcc_debug_mux;
	gcc_pcie_1_pipediv2_clk 0x18D gcc_debug_mux;
	gcc_pcie_1_slv_axi_clk 0x187 gcc_debug_mux;
	gcc_pcie_1_slv_q2a_axi_clk 0x186 gcc_debug_mux;
	gcc_pcie_throttle_cfg_clk 0x5D gcc_debug_mux;
	gcc_pdm2_clk 0x10C gcc_debug_mux;
	gcc_pdm_ahb_clk 0x10A gcc_debug_mux;
	gcc_pdm_xo4_clk 0x10B gcc_debug_mux;
	gcc_qmip_camera_nrt_ahb_clk 0x84 gcc_debug_mux;
	gcc_qmip_camera_rt_ahb_clk 0x85 gcc_debug_mux;
	gcc_qmip_disp1_ahb_clk 0x94 gcc_debug_mux;
	gcc_qmip_disp1_rot_ahb_clk 0x95 gcc_debug_mux;
	gcc_qmip_disp_ahb_clk 0x8E gcc_debug_mux;
	gcc_qmip_disp_rot_ahb_clk 0x8F gcc_debug_mux;
	gcc_qmip_video_cvp_ahb_clk 0x9C gcc_debug_mux;
	gcc_qmip_video_vcodec_ahb_clk 0x9D gcc_debug_mux;
	gcc_qmip_video_vcpu_ahb_clk 0x9E gcc_debug_mux;
	gcc_qupv3_wrap0_core_2x_clk 0xF7 gcc_debug_mux;
	gcc_qupv3_wrap0_core_clk 0xF6 gcc_debug_mux;
	gcc_qupv3_wrap0_s0_clk 0xF8 gcc_debug_mux;
	gcc_qupv3_wrap0_s1_clk 0xF9 gcc_debug_mux;
	gcc_qupv3_wrap0_s2_clk 0xFA gcc_debug_mux;
	gcc_qupv3_wrap0_s3_clk 0xFB gcc_debug_mux;
	gcc_qupv3_wrap0_s4_clk 0xFC gcc_debug_mux;
	gcc_qupv3_wrap0_s5_clk 0xFD gcc_debug_mux;
	gcc_qupv3_wrap0_s6_clk 0xFE gcc_debug_mux;
	gcc_qupv3_wrap1_core_2x_clk 0x102 gcc_debug_mux;
	gcc_qupv3_wrap1_core_clk 0x101 gcc_debug_mux;
	gcc_qupv3_wrap1_s0_clk 0x103 gcc_debug_mux;
	gcc_qupv3_wrap1_s1_clk 0x104 gcc_debug_mux;
	gcc_qupv3_wrap1_s2_clk 0x105 gcc_debug_mux;
	gcc_qupv3_wrap1_s3_clk 0x106 gcc_debug_mux;
	gcc_qupv3_wrap1_s4_clk 0x107 gcc_debug_mux;
	gcc_qupv3_wrap1_s5_clk 0x108 gcc_debug_mux;
	gcc_qupv3_wrap1_s6_clk 0x109 gcc_debug_mux;
	gcc_qupv3_wrap2_core_2x_clk 0x219 gcc_debug_mux;
	gcc_qupv3_wrap2_core_clk 0x218 gcc_debug_mux;
	gcc_qupv3_wrap2_s0_clk 0x21A gcc_debug_mux;
	gcc_qupv3_wrap2_s1_clk 0x21B gcc_debug_mux;
	gcc_qupv3_wrap2_s2_clk 0x21C gcc_debug_mux;
	gcc_qupv3_wrap2_s3_clk 0x21D gcc_debug_mux;
	gcc_qupv3_wrap2_s4_clk 0x21E gcc_debug_mux;
	gcc_qupv3_wrap2_s5_clk 0x21F gcc_debug_mux;
	gcc_qupv3_wrap2_s6_clk 0x220 gcc_debug_mux;
	gcc_qupv3_wrap3_core_2x_clk 0x225 gcc_debug_mux;
	gcc_qupv3_wrap3_core_clk 0x223 gcc_debug_mux;
	gcc_qupv3_wrap3_qspi_clk 0x227 gcc_debug_mux;
	gcc_qupv3_wrap3_s0_clk 0x226 gcc_debug_mux;
	gcc_qupv3_wrap_0_m_ahb_clk 0xF4 gcc_debug_mux;
	gcc_qupv3_wrap_0_s_ahb_clk 0xF5 gcc_debug_mux;
	gcc_qupv3_wrap_1_m_ahb_clk 0xFF gcc_debug_mux;
	gcc_qupv3_wrap_1_s_ahb_clk 0x100 gcc_debug_mux;
	gcc_qupv3_wrap_2_m_ahb_clk 0x216 gcc_debug_mux;
	gcc_qupv3_wrap_2_s_ahb_clk 0x217 gcc_debug_mux;
	gcc_qupv3_wrap_3_m_ahb_clk 0x221 gcc_debug_mux;
	gcc_qupv3_wrap_3_s_ahb_clk 0x222 gcc_debug_mux;
	gcc_sdcc1_ahb_clk 0xF1 gcc_debug_mux;
	gcc_sdcc1_apps_clk 0xF0 gcc_debug_mux;
	gcc_sdcc1_ice_core_clk 0xF3 gcc_debug_mux;
	gcc_tscss_ahb_clk 0x1F1 gcc_debug_mux;
	gcc_tscss_etu_clk 0x1F0 gcc_debug_mux;
	gcc_tscss_global_cntr_clk 0x1EF gcc_debug_mux;
	gcc_ufs_card_ahb_clk 0x19F gcc_debug_mux;
	gcc_ufs_card_axi_clk 0x19E gcc_debug_mux;
	gcc_ufs_card_ice_core_clk 0x1A5 gcc_debug_mux;
	gcc_ufs_card_phy_aux_clk 0x1A6 gcc_debug_mux;
	gcc_ufs_card_rx_symbol_0_clk 0x1A1 gcc_debug_mux;
	gcc_ufs_card_rx_symbol_1_clk 0x1A7 gcc_debug_mux;
	gcc_ufs_card_tx_symbol_0_clk 0x1A0 gcc_debug_mux;
	gcc_ufs_card_unipro_core_clk 0x1A4 gcc_debug_mux;
	gcc_ufs_phy_ahb_clk 0x1AB gcc_debug_mux;
	gcc_ufs_phy_axi_clk 0x1AA gcc_debug_mux;
	gcc_ufs_phy_ice_core_clk 0x1B1 gcc_debug_mux;
	gcc_ufs_phy_phy_aux_clk 0x1B2 gcc_debug_mux;
	gcc_ufs_phy_rx_symbol_0_clk 0x1AD gcc_debug_mux;
	gcc_ufs_phy_rx_symbol_1_clk 0x1B3 gcc_debug_mux;
	gcc_ufs_phy_tx_symbol_0_clk 0x1AC gcc_debug_mux;
	gcc_ufs_phy_unipro_core_clk 0x1B0 gcc_debug_mux;
	gcc_usb20_master_clk 0xE3 gcc_debug_mux;
	gcc_usb20_mock_utmi_clk 0xE5 gcc_debug_mux;
	gcc_usb20_sleep_clk 0xE4 gcc_debug_mux;
	gcc_usb30_prim_master_clk 0xD4 gcc_debug_mux;
	gcc_usb30_prim_mock_utmi_clk 0xD6 gcc_debug_mux;
	gcc_usb30_prim_sleep_clk 0xD5 gcc_debug_mux;
	gcc_usb30_sec_master_clk 0xDD gcc_debug_mux;
	gcc_usb30_sec_mock_utmi_clk 0xDF gcc_debug_mux;
	gcc_usb30_sec_sleep_clk 0xDE gcc_debug_mux;
	gcc_usb3_prim_phy_aux_clk 0xD7 gcc_debug_mux;
	gcc_usb3_prim_phy_com_aux_clk 0xD8 gcc_debug_mux;
	gcc_usb3_prim_phy_pipe_clk 0xD9 gcc_debug_mux;
	gcc_usb3_sec_phy_aux_clk 0xE0 gcc_debug_mux;
	gcc_usb3_sec_phy_com_aux_clk 0xE1 gcc_debug_mux;
	gcc_usb3_sec_phy_pipe_clk 0xE2 gcc_debug_mux;
	gcc_video_axi0_clk 0x9F gcc_debug_mux;
	gcc_video_axi1_clk 0xA0 gcc_debug_mux;
	gcc_video_trig_clk 0x82 gcc_debug_mux;
	gpu_cc_ahb_clk 0x1F6 gcc_debug_mux 0x16 gpu_cc_debug_mux;
	gpu_cc_crc_ahb_clk 0x1F6 gcc_debug_mux 0x17 gpu_cc_debug_mux;
	gpu_cc_cx_apb_clk 0x1F6 gcc_debug_mux 0x1A gpu_cc_debug_mux;
	gpu_cc_cx_ff_clk 0x1F6 gcc_debug_mux 0x21 gpu_cc_debug_mux;
	gpu_cc_cx_gmu_clk 0x1F6 gcc_debug_mux 0x1E gpu_cc_debug_mux;
	gpu_cc_cx_snoc_dvm_clk 0x1F6 gcc_debug_mux 0x1B gpu_cc_debug_mux;
	gpu_cc_cxo_aon_clk 0x1F6 gcc_debug_mux 0xB gpu_cc_debug_mux;
	gpu_cc_cxo_clk 0x1F6 gcc_debug_mux 0x1F gpu_cc_debug_mux;
	gpu_cc_hub_aon_clk 0x1F6 gcc_debug_mux 0x2F gpu_cc_debug_mux;
	gpu_cc_hub_cx_int_clk 0x1F6 gcc_debug_mux 0x20 gpu_cc_debug_mux;
	gpu_cc_memnoc_gfx_clk 0x1F6 gcc_debug_mux 0x22 gpu_cc_debug_mux;
	gpu_cc_mnd1x_1_gfx3d_clk 0x1F6 gcc_debug_mux 0x2A gpu_cc_debug_mux;
	gpu_cc_sleep_clk 0x1F6 gcc_debug_mux 0x1C gpu_cc_debug_mux;
	mdss_0_disp_cc_mdss_ahb1_clk 0x92 gcc_debug_mux 0x27 disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_ahb_clk 0x92 gcc_debug_mux 0x26 disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_byte0_clk 0x92 gcc_debug_mux 0x12 disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_byte0_intf_clk 0x92 gcc_debug_mux 0x13 disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_byte1_clk 0x92 gcc_debug_mux 0x14 disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_byte1_intf_clk 0x92 gcc_debug_mux 0x15 disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_dptx0_aux_clk 0x92 gcc_debug_mux 0x1C disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_dptx0_crypto_clk 0x92 gcc_debug_mux 0x1B disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_dptx0_link_clk 0x92 gcc_debug_mux 0x18 disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_dptx0_link_intf_clk 0x92 gcc_debug_mux 0x19 disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_dptx0_pixel0_clk 0x92 gcc_debug_mux 0x1D disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_dptx0_pixel1_clk 0x92 gcc_debug_mux 0x1E disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_dptx0_pixel2_clk 0x92 gcc_debug_mux 0x28 disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_dptx0_pixel3_clk 0x92 gcc_debug_mux 0x29 disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_dptx0_usb_router_link_intf_clk 0x92 gcc_debug_mux 0x1A disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_dptx1_aux_clk 0x92 gcc_debug_mux 0x25 disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_dptx1_crypto_clk 0x92 gcc_debug_mux 0x24 disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_dptx1_link_clk 0x92 gcc_debug_mux 0x21 disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_dptx1_link_intf_clk 0x92 gcc_debug_mux 0x22 disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_dptx1_pixel0_clk 0x92 gcc_debug_mux 0x1F disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_dptx1_pixel1_clk 0x92 gcc_debug_mux 0x20 disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_dptx1_usb_router_link_intf_clk 0x92 gcc_debug_mux 0x23 disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_esc0_clk 0x92 gcc_debug_mux 0x16 disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_esc1_clk 0x92 gcc_debug_mux 0x17 disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_mdp1_clk 0x92 gcc_debug_mux 0xD disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_mdp_clk 0x92 gcc_debug_mux 0xC disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_mdp_lut1_clk 0x92 gcc_debug_mux 0xF disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_mdp_lut_clk 0x92 gcc_debug_mux 0xE disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_non_gdsc_ahb_clk 0x92 gcc_debug_mux 0x2A disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_pclk0_clk 0x92 gcc_debug_mux 0xA disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_pclk1_clk 0x92 gcc_debug_mux 0xB disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_pll_lock_monitor_clk 0x92 gcc_debug_mux 0x2D disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_rscc_ahb_clk 0x92 gcc_debug_mux 0x2C disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_rscc_vsync_clk 0x92 gcc_debug_mux 0x2B disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_vsync1_clk 0x92 gcc_debug_mux 0x11 disp_cc_0_debug_mux;
	mdss_0_disp_cc_mdss_vsync_clk 0x92 gcc_debug_mux 0x10 disp_cc_0_debug_mux;
	mdss_0_disp_cc_sleep_clk 0x92 gcc_debug_mux 0x35 disp_cc_0_debug_mux;
	mdss_1_disp_cc_mdss_ahb1_clk 0x98 gcc_debug_mux 0x27 disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_ahb_clk 0x98 gcc_debug_mux 0x26 disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_byte0_clk 0x98 gcc_debug_mux 0x12 disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_byte0_intf_clk 0x98 gcc_debug_mux 0x13 disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_byte1_clk 0x98 gcc_debug_mux 0x14 disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_byte1_intf_clk 0x98 gcc_debug_mux 0x15 disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_dptx0_aux_clk 0x98 gcc_debug_mux 0x1C disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_dptx0_crypto_clk 0x98 gcc_debug_mux 0x1B disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_dptx0_link_clk 0x98 gcc_debug_mux 0x18 disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_dptx0_link_intf_clk 0x98 gcc_debug_mux 0x19 disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_dptx0_pixel0_clk 0x98 gcc_debug_mux 0x1D disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_dptx0_pixel1_clk 0x98 gcc_debug_mux 0x1E disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_dptx0_pixel2_clk 0x98 gcc_debug_mux 0x28 disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_dptx0_pixel3_clk 0x98 gcc_debug_mux 0x29 disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_dptx0_usb_router_link_intf_clk 0x98 gcc_debug_mux 0x1A disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_dptx1_aux_clk 0x98 gcc_debug_mux 0x25 disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_dptx1_crypto_clk 0x98 gcc_debug_mux 0x24 disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_dptx1_link_clk 0x98 gcc_debug_mux 0x21 disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_dptx1_link_intf_clk 0x98 gcc_debug_mux 0x22 disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_dptx1_pixel0_clk 0x98 gcc_debug_mux 0x1F disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_dptx1_pixel1_clk 0x98 gcc_debug_mux 0x20 disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_dptx1_usb_router_link_intf_clk 0x98 gcc_debug_mux 0x23 disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_esc0_clk 0x98 gcc_debug_mux 0x16 disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_esc1_clk 0x98 gcc_debug_mux 0x17 disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_mdp1_clk 0x98 gcc_debug_mux 0xD disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_mdp_clk 0x98 gcc_debug_mux 0xC disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_mdp_lut1_clk 0x98 gcc_debug_mux 0xF disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_mdp_lut_clk 0x98 gcc_debug_mux 0xE disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_non_gdsc_ahb_clk 0x98 gcc_debug_mux 0x2A disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_pclk0_clk 0x98 gcc_debug_mux 0xA disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_pclk1_clk 0x98 gcc_debug_mux 0xB disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_pll_lock_monitor_clk 0x98 gcc_debug_mux 0x2D disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_rscc_ahb_clk 0x98 gcc_debug_mux 0x2C disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_rscc_vsync_clk 0x98 gcc_debug_mux 0x2B disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_vsync1_clk 0x98 gcc_debug_mux 0x11 disp_cc_1_debug_mux;
	mdss_1_disp_cc_mdss_vsync_clk 0x98 gcc_debug_mux 0x10 disp_cc_1_debug_mux;
	mdss_1_disp_cc_sleep_clk 0x98 gcc_debug_mux 0x35 disp_cc_1_debug_mux;
	measure_only_cam_cc_gdsc_clk 0x8C gcc_debug_mux 0x3B cam_cc_debug_mux;
	measure_only_cnoc_clk 0x2E gcc_debug_mux;
	measure_only_gcc_camera_ahb_clk 0x83 gcc_debug_mux;
	measure_only_gcc_camera_xo_clk 0x8A gcc_debug_mux;
	measure_only_gcc_disp1_ahb_clk 0x93 gcc_debug_mux;
	measure_only_gcc_disp1_xo_clk 0x97 gcc_debug_mux;
	measure_only_gcc_disp_ahb_clk 0x8D gcc_debug_mux;
	measure_only_gcc_disp_xo_clk 0x91 gcc_debug_mux;
	measure_only_gcc_gpu_cfg_ahb_clk 0x1F3 gcc_debug_mux;
	measure_only_gcc_gpu_cfg_ahb_clk 0x1F6 gcc_debug_mux 0x1 gpu_cc_debug_mux;
	measure_only_gcc_video_ahb_clk 0x9B gcc_debug_mux;
	measure_only_gcc_video_xo_clk 0xA1 gcc_debug_mux;
	measure_only_gpu_cc_cb_clk 0x1F6 gcc_debug_mux 0x2E gpu_cc_debug_mux;
	measure_only_ipa_2x_clk 0x1EB gcc_debug_mux;
	measure_only_mccc_clk 0xff mc_cc_debug_mux;
	measure_only_mdss_0_disp_cc_xo_clk 0x92 gcc_debug_mux 0x34 disp_cc_0_debug_mux;
	measure_only_mdss_1_disp_cc_xo_clk 0x98 gcc_debug_mux 0x34 disp_cc_1_debug_mux;
	measure_only_memnoc_clk 0x145 gcc_debug_mux;
	measure_only_snoc_clk 0x19 gcc_debug_mux;
	measure_only_video_cc_ahb_clk 0xA2 gcc_debug_mux 0x7 video_cc_debug_mux;
	measure_only_video_cc_xo_clk 0xA2 gcc_debug_mux 0xB video_cc_debug_mux;
	video_cc_mvs0_clk 0xA2 gcc_debug_mux 0x3 video_cc_debug_mux;
	video_cc_mvs0c_clk 0xA2 gcc_debug_mux 0x1 video_cc_debug_mux;
	video_cc_mvs1_clk 0xA2 gcc_debug_mux 0x5 video_cc_debug_mux;
	video_cc_mvs1c_clk 0xA2 gcc_debug_mux 0x9 video_cc_debug_mux;
	video_cc_pll_lock_monitor_clk 0xA2 gcc_debug_mux 0xE video_cc_debug_mux;
	video_cc_sleep_clk 0xA2 gcc_debug_mux 0xC video_cc_debug_mux;
"

if [ $# -lt 1 ]; then
	echo "No clock name passed"
	return 0
fi

_measure $1
