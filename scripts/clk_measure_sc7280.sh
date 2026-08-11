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
	cam_cc_bps_ahb_clk 0x4E gcc_debug_mux 0x18 cam_cc_debug_mux;
	cam_cc_bps_areg_clk 0x4E gcc_debug_mux 0x17 cam_cc_debug_mux;
	cam_cc_bps_axi_clk 0x4E gcc_debug_mux 0x16 cam_cc_debug_mux;
	cam_cc_bps_clk 0x4E gcc_debug_mux 0x14 cam_cc_debug_mux;
	cam_cc_camnoc_axi_clk 0x4E gcc_debug_mux 0x3C cam_cc_debug_mux;
	cam_cc_camnoc_dcd_xo_clk 0x4E gcc_debug_mux 0x3D cam_cc_debug_mux;
	cam_cc_cci_0_clk 0x4E gcc_debug_mux 0x39 cam_cc_debug_mux;
	cam_cc_cci_1_clk 0x4E gcc_debug_mux 0x3A cam_cc_debug_mux;
	cam_cc_core_ahb_clk 0x4E gcc_debug_mux 0x40 cam_cc_debug_mux;
	cam_cc_cpas_ahb_clk 0x4E gcc_debug_mux 0x3B cam_cc_debug_mux;
	cam_cc_csi0phytimer_clk 0x4E gcc_debug_mux 0x8 cam_cc_debug_mux;
	cam_cc_csi1phytimer_clk 0x4E gcc_debug_mux 0xA cam_cc_debug_mux;
	cam_cc_csi2phytimer_clk 0x4E gcc_debug_mux 0xC cam_cc_debug_mux;
	cam_cc_csi3phytimer_clk 0x4E gcc_debug_mux 0xE cam_cc_debug_mux;
	cam_cc_csi4phytimer_clk 0x4E gcc_debug_mux 0x10 cam_cc_debug_mux;
	cam_cc_csiphy0_clk 0x4E gcc_debug_mux 0x9 cam_cc_debug_mux;
	cam_cc_csiphy1_clk 0x4E gcc_debug_mux 0xB cam_cc_debug_mux;
	cam_cc_csiphy2_clk 0x4E gcc_debug_mux 0xD cam_cc_debug_mux;
	cam_cc_csiphy3_clk 0x4E gcc_debug_mux 0xF cam_cc_debug_mux;
	cam_cc_csiphy4_clk 0x4E gcc_debug_mux 0x11 cam_cc_debug_mux;
	cam_cc_gdsc_clk 0x4E gcc_debug_mux 0x41 cam_cc_debug_mux;
	cam_cc_icp_ahb_clk 0x4E gcc_debug_mux 0x36 cam_cc_debug_mux;
	cam_cc_icp_clk 0x4E gcc_debug_mux 0x35 cam_cc_debug_mux;
	cam_cc_ife_0_axi_clk 0x4E gcc_debug_mux 0x25 cam_cc_debug_mux;
	cam_cc_ife_0_clk 0x4E gcc_debug_mux 0x1E cam_cc_debug_mux;
	cam_cc_ife_0_cphy_rx_clk 0x4E gcc_debug_mux 0x24 cam_cc_debug_mux;
	cam_cc_ife_0_csid_clk 0x4E gcc_debug_mux 0x22 cam_cc_debug_mux;
	cam_cc_ife_0_dsp_clk 0x4E gcc_debug_mux 0x21 cam_cc_debug_mux;
	cam_cc_ife_1_axi_clk 0x4E gcc_debug_mux 0x2D cam_cc_debug_mux;
	cam_cc_ife_1_clk 0x4E gcc_debug_mux 0x27 cam_cc_debug_mux;
	cam_cc_ife_1_cphy_rx_clk 0x4E gcc_debug_mux 0x2C cam_cc_debug_mux;
	cam_cc_ife_1_csid_clk 0x4E gcc_debug_mux 0x2B cam_cc_debug_mux;
	cam_cc_ife_1_dsp_clk 0x4E gcc_debug_mux 0x2A cam_cc_debug_mux;
	cam_cc_ife_2_axi_clk 0x4E gcc_debug_mux 0x53 cam_cc_debug_mux;
	cam_cc_ife_2_clk 0x4E gcc_debug_mux 0x7 cam_cc_debug_mux;
	cam_cc_ife_2_cphy_rx_clk 0x4E gcc_debug_mux 0x52 cam_cc_debug_mux;
	cam_cc_ife_2_csid_clk 0x4E gcc_debug_mux 0x51 cam_cc_debug_mux;
	cam_cc_ife_2_dsp_clk 0x4E gcc_debug_mux 0x26 cam_cc_debug_mux;
	cam_cc_ife_lite_0_clk 0x4E gcc_debug_mux 0x2F cam_cc_debug_mux;
	cam_cc_ife_lite_0_cphy_rx_clk 0x4E gcc_debug_mux 0x31 cam_cc_debug_mux;
	cam_cc_ife_lite_0_csid_clk 0x4E gcc_debug_mux 0x30 cam_cc_debug_mux;
	cam_cc_ife_lite_1_clk 0x4E gcc_debug_mux 0x2E cam_cc_debug_mux;
	cam_cc_ife_lite_1_cphy_rx_clk 0x4E gcc_debug_mux 0x37 cam_cc_debug_mux;
	cam_cc_ife_lite_1_csid_clk 0x4E gcc_debug_mux 0x32 cam_cc_debug_mux;
	cam_cc_ipe_0_ahb_clk 0x4E gcc_debug_mux 0x1D cam_cc_debug_mux;
	cam_cc_ipe_0_areg_clk 0x4E gcc_debug_mux 0x1C cam_cc_debug_mux;
	cam_cc_ipe_0_axi_clk 0x4E gcc_debug_mux 0x1B cam_cc_debug_mux;
	cam_cc_ipe_0_clk 0x4E gcc_debug_mux 0x19 cam_cc_debug_mux;
	cam_cc_jpeg_clk 0x4E gcc_debug_mux 0x33 cam_cc_debug_mux;
	cam_cc_lrme_clk 0x4E gcc_debug_mux 0x13 cam_cc_debug_mux;
	cam_cc_mclk0_clk 0x4E gcc_debug_mux 0x1 cam_cc_debug_mux;
	cam_cc_mclk1_clk 0x4E gcc_debug_mux 0x2 cam_cc_debug_mux;
	cam_cc_mclk2_clk 0x4E gcc_debug_mux 0x3 cam_cc_debug_mux;
	cam_cc_mclk3_clk 0x4E gcc_debug_mux 0x4 cam_cc_debug_mux;
	cam_cc_mclk4_clk 0x4E gcc_debug_mux 0x5 cam_cc_debug_mux;
	cam_cc_mclk5_clk 0x4E gcc_debug_mux 0x6 cam_cc_debug_mux;
	cam_cc_sleep_clk 0x4E gcc_debug_mux 0x42 cam_cc_debug_mux;
	disp_cc_mdss_ahb_clk 0x54 gcc_debug_mux 0x16 disp_cc_debug_mux;
	disp_cc_mdss_byte0_clk 0x54 gcc_debug_mux 0xE disp_cc_debug_mux;
	disp_cc_mdss_byte0_intf_clk 0x54 gcc_debug_mux 0xF disp_cc_debug_mux;
	disp_cc_mdss_dp_aux_clk 0x54 gcc_debug_mux 0x15 disp_cc_debug_mux;
	disp_cc_mdss_dp_crypto_clk 0x54 gcc_debug_mux 0x13 disp_cc_debug_mux;
	disp_cc_mdss_dp_link_clk 0x54 gcc_debug_mux 0x11 disp_cc_debug_mux;
	disp_cc_mdss_dp_link_intf_clk 0x54 gcc_debug_mux 0x12 disp_cc_debug_mux;
	disp_cc_mdss_dp_pixel_clk 0x54 gcc_debug_mux 0x14 disp_cc_debug_mux;
	disp_cc_mdss_edp_aux_clk 0x54 gcc_debug_mux 0x1A disp_cc_debug_mux;
	disp_cc_mdss_edp_link_clk 0x54 gcc_debug_mux 0x18 disp_cc_debug_mux;
	disp_cc_mdss_edp_link_intf_clk 0x54 gcc_debug_mux 0x19 disp_cc_debug_mux;
	disp_cc_mdss_edp_pixel_clk 0x54 gcc_debug_mux 0x17 disp_cc_debug_mux;
	disp_cc_mdss_esc0_clk 0x54 gcc_debug_mux 0x10 disp_cc_debug_mux;
	disp_cc_mdss_mdp_clk 0x54 gcc_debug_mux 0xA disp_cc_debug_mux;
	disp_cc_mdss_mdp_lut_clk 0x54 gcc_debug_mux 0xC disp_cc_debug_mux;
	disp_cc_mdss_non_gdsc_ahb_clk 0x54 gcc_debug_mux 0x1B disp_cc_debug_mux;
	disp_cc_mdss_pclk0_clk 0x54 gcc_debug_mux 0x9 disp_cc_debug_mux;
	disp_cc_mdss_rot_clk 0x54 gcc_debug_mux 0xB disp_cc_debug_mux;
	disp_cc_mdss_rscc_ahb_clk 0x54 gcc_debug_mux 0x1D disp_cc_debug_mux;
	disp_cc_mdss_rscc_vsync_clk 0x54 gcc_debug_mux 0x1C disp_cc_debug_mux;
	disp_cc_mdss_vsync_clk 0x54 gcc_debug_mux 0xD disp_cc_debug_mux;
	disp_cc_sleep_clk 0x54 gcc_debug_mux 0x23 disp_cc_debug_mux;
	gcc_aggre_noc_pcie_tbu_clk 0x2F gcc_debug_mux;
	gcc_aggre_ufs_phy_axi_clk 0x12F gcc_debug_mux;
	gcc_aggre_usb3_prim_axi_clk 0x12E gcc_debug_mux;
	gcc_camera_ahb_clk 0x46 gcc_debug_mux;
	gcc_camera_hf_axi_clk 0x49 gcc_debug_mux;
	gcc_camera_sf_axi_clk 0x4B gcc_debug_mux;
	gcc_camera_xo_clk 0x4D gcc_debug_mux;
	gcc_cfg_noc_usb3_prim_axi_clk 0x1B gcc_debug_mux;
	gcc_cpuss_ahb_clk 0xE8 gcc_debug_mux;
	gcc_ddrss_gpu_axi_clk 0xCD gcc_debug_mux;
	gcc_ddrss_pcie_sf_clk 0xCE gcc_debug_mux;
	gcc_disp_ahb_clk 0x4F gcc_debug_mux;
	gcc_disp_gpll0_clk_src 0x45 gcc_debug_mux;
	gcc_disp_hf_axi_clk 0x51 gcc_debug_mux;
	gcc_disp_sf_axi_clk 0x52 gcc_debug_mux;
	gcc_disp_xo_clk 0x53 gcc_debug_mux;
	gcc_gp1_clk 0xF8 gcc_debug_mux;
	gcc_gp2_clk 0xF9 gcc_debug_mux;
	gcc_gp3_clk 0xFA gcc_debug_mux;
	gcc_gpu_cfg_ahb_clk 0x144 gcc_debug_mux;
	gcc_gpu_gpll0_clk_src 0x14B gcc_debug_mux;
	gcc_gpu_gpll0_div_clk_src 0x14C gcc_debug_mux;
	gcc_gpu_memnoc_gfx_clk 0x147 gcc_debug_mux;
	gcc_gpu_snoc_dvm_gfx_clk 0x14A gcc_debug_mux;
	gcc_gpu_tcu_throttle_cfg_ahb_clk 0x14D gcc_debug_mux;
	gcc_gpu_tcu_throttle_core_clk 0x14E gcc_debug_mux;
	gcc_pdm2_clk 0xA4 gcc_debug_mux;
	gcc_pdm_ahb_clk 0xA2 gcc_debug_mux;
	gcc_pdm_xo4_clk 0xA3 gcc_debug_mux;
	gcc_qmip_camera_nrt_ahb_clk 0x47 gcc_debug_mux;
	gcc_qmip_camera_rt_ahb_clk 0x48 gcc_debug_mux;
	gcc_qmip_disp_ahb_clk 0x50 gcc_debug_mux;
	gcc_qmip_video_vcodec_ahb_clk 0x57 gcc_debug_mux;
	gcc_qupv3_wrap0_core_2x_clk 0x8D gcc_debug_mux;
	gcc_qupv3_wrap0_core_clk 0x8C gcc_debug_mux;
	gcc_qupv3_wrap0_s0_clk 0x8E gcc_debug_mux;
	gcc_qupv3_wrap0_s2_clk 0x90 gcc_debug_mux;
	gcc_qupv3_wrap0_s3_clk 0x91 gcc_debug_mux;
	gcc_qupv3_wrap0_s4_clk 0x92 gcc_debug_mux;
	gcc_qupv3_wrap0_s5_clk 0x93 gcc_debug_mux;
	gcc_qupv3_wrap0_s6_clk 0x94 gcc_debug_mux;
	gcc_qupv3_wrap0_s7_clk 0x95 gcc_debug_mux;
	gcc_qupv3_wrap1_core_2x_clk 0x99 gcc_debug_mux;
	gcc_qupv3_wrap1_core_clk 0x98 gcc_debug_mux;
	gcc_qupv3_wrap1_s0_clk 0x9A gcc_debug_mux;
	gcc_qupv3_wrap1_s1_clk 0x9B gcc_debug_mux;
	gcc_qupv3_wrap1_s2_clk 0x9C gcc_debug_mux;
	gcc_qupv3_wrap1_s3_clk 0x9D gcc_debug_mux;
	gcc_qupv3_wrap1_s4_clk 0x9E gcc_debug_mux;
	gcc_qupv3_wrap1_s5_clk 0x9F gcc_debug_mux;
	gcc_qupv3_wrap1_s6_clk 0xA0 gcc_debug_mux;
	gcc_qupv3_wrap1_s7_clk 0xA1 gcc_debug_mux;
	gcc_qupv3_wrap_1_m_ahb_clk 0x96 gcc_debug_mux;
	gcc_qupv3_wrap_1_s_ahb_clk 0x97 gcc_debug_mux;
	gcc_sdcc1_ahb_clk 0x15D gcc_debug_mux;
	gcc_sdcc1_apps_clk 0x15E gcc_debug_mux;
	gcc_sdcc1_ice_core_clk 0x15F gcc_debug_mux;
	gcc_sdcc2_ahb_clk 0x87 gcc_debug_mux;
	gcc_sdcc2_apps_clk 0x86 gcc_debug_mux;
	gcc_sdcc4_ahb_clk 0x89 gcc_debug_mux;
	gcc_sdcc4_apps_clk 0x88 gcc_debug_mux;
	gcc_sys_noc_cpuss_ahb_clk 0xA gcc_debug_mux;
	gcc_titan_nrt_throttle_core_clk 0x4C gcc_debug_mux;
	gcc_titan_rt_throttle_core_clk 0x4A gcc_debug_mux;
	gcc_ufs_phy_ahb_clk 0x10E gcc_debug_mux;
	gcc_ufs_phy_axi_clk 0x10D gcc_debug_mux;
	gcc_ufs_phy_ice_core_clk 0x114 gcc_debug_mux;
	gcc_ufs_phy_phy_aux_clk 0x115 gcc_debug_mux;
	gcc_ufs_phy_rx_symbol_0_clk 0x110 gcc_debug_mux;
	gcc_ufs_phy_rx_symbol_1_clk 0x116 gcc_debug_mux;
	gcc_ufs_phy_tx_symbol_0_clk 0x10F gcc_debug_mux;
	gcc_ufs_phy_unipro_core_clk 0x113 gcc_debug_mux;
	gcc_usb30_prim_master_clk 0x70 gcc_debug_mux;
	gcc_usb30_prim_mock_utmi_clk 0x72 gcc_debug_mux;
	gcc_usb30_prim_sleep_clk 0x71 gcc_debug_mux;
	gcc_usb3_prim_phy_aux_clk 0x73 gcc_debug_mux;
	gcc_usb3_prim_phy_com_aux_clk 0x74 gcc_debug_mux;
	gcc_usb3_prim_phy_pipe_clk 0x75 gcc_debug_mux;
	gcc_video_ahb_clk 0x55 gcc_debug_mux;
	gcc_video_axi0_clk 0x58 gcc_debug_mux;
	gcc_video_mvp_throttle_core_clk 0x59 gcc_debug_mux;
	gcc_video_xo_clk 0x5C gcc_debug_mux;
	gpu_cc_ahb_clk 0x146 gcc_debug_mux 0x12 gpu_cc_debug_mux;
	gpu_cc_cb_clk 0x146 gcc_debug_mux 0x26 gpu_cc_debug_mux;
	gpu_cc_crc_ahb_clk 0x146 gcc_debug_mux 0x13 gpu_cc_debug_mux;
	gpu_cc_cx_apb_clk 0x146 gcc_debug_mux 0x16 gpu_cc_debug_mux;
	gpu_cc_cx_gmu_clk 0x146 gcc_debug_mux 0x1A gpu_cc_debug_mux;
	gpu_cc_cx_snoc_dvm_clk 0x146 gcc_debug_mux 0x17 gpu_cc_debug_mux;
	gpu_cc_cxo_aon_clk 0x146 gcc_debug_mux 0xB gpu_cc_debug_mux;
	gpu_cc_cxo_clk 0x146 gcc_debug_mux 0x1B gpu_cc_debug_mux;
	gpu_cc_freq_measure_clk 0x146 gcc_debug_mux 0xC gpu_cc_debug_mux;
	gpu_cc_gx_gmu_clk 0x146 gcc_debug_mux 0x11 gpu_cc_debug_mux;
	gpu_cc_gx_vsense_clk 0x146 gcc_debug_mux 0xE gpu_cc_debug_mux;
	gpu_cc_hub_aon_clk 0x146 gcc_debug_mux 0x27 gpu_cc_debug_mux;
	gpu_cc_hub_cx_int_clk 0x146 gcc_debug_mux 0x1C gpu_cc_debug_mux;
	gpu_cc_mnd1x_0_gfx3d_clk 0x146 gcc_debug_mux 0x21 gpu_cc_debug_mux;
	gpu_cc_mnd1x_1_gfx3d_clk 0x146 gcc_debug_mux 0x22 gpu_cc_debug_mux;
	gpu_cc_sleep_clk 0x146 gcc_debug_mux 0x18 gpu_cc_debug_mux;
	measure_only_cnoc_clk 0x17 gcc_debug_mux;
	measure_only_disp_cc_xo_clk 0x54 gcc_debug_mux 0x24 disp_cc_debug_mux;
	measure_only_gcc_aggre_noc_pcie_0_axi_clk 0x12C gcc_debug_mux;
	measure_only_gcc_aggre_noc_pcie_1_axi_clk 0x12D gcc_debug_mux;
	measure_only_gcc_aggre_noc_pcie_center_sf_axi_clk 0x172 gcc_debug_mux;
	measure_only_gcc_aggre_usb3_sec_axi_clk 0x170 gcc_debug_mux;
	measure_only_gcc_cfg_noc_usb3_sec_axi_clk 0x1C gcc_debug_mux;
	measure_only_gcc_pcie0_phy_rchng_clk 0x101 gcc_debug_mux;
	measure_only_gcc_pcie1_phy_rchng_clk 0x10A gcc_debug_mux;
	measure_only_gcc_pcie_0_aux_clk 0xFF gcc_debug_mux;
	measure_only_gcc_pcie_0_cfg_ahb_clk 0xFE gcc_debug_mux;
	measure_only_gcc_pcie_0_mstr_axi_clk 0xFD gcc_debug_mux;
	measure_only_gcc_pcie_0_pipe_clk 0x100 gcc_debug_mux;
	measure_only_gcc_pcie_0_slv_axi_clk 0xFC gcc_debug_mux;
	measure_only_gcc_pcie_0_slv_q2a_axi_clk 0xFB gcc_debug_mux;
	measure_only_gcc_pcie_1_aux_clk 0x108 gcc_debug_mux;
	measure_only_gcc_pcie_1_cfg_ahb_clk 0x107 gcc_debug_mux;
	measure_only_gcc_pcie_1_mstr_axi_clk 0x106 gcc_debug_mux;
	measure_only_gcc_pcie_1_pipe_clk 0x109 gcc_debug_mux;
	measure_only_gcc_pcie_1_slv_axi_clk 0x105 gcc_debug_mux;
	measure_only_gcc_pcie_1_slv_q2a_axi_clk 0x104 gcc_debug_mux;
	measure_only_gcc_pcie_throttle_core_clk 0x30 gcc_debug_mux;
	measure_only_gcc_qupv3_wrap0_s1_clk 0x8F gcc_debug_mux;
	measure_only_gcc_qupv3_wrap_0_m_ahb_clk 0x8A gcc_debug_mux;
	measure_only_gcc_qupv3_wrap_0_s_ahb_clk 0x8B gcc_debug_mux;
	measure_only_gcc_throttle_pcie_ahb_clk 0x3A gcc_debug_mux;
	measure_only_gcc_usb30_sec_master_clk 0x7C gcc_debug_mux;
	measure_only_gcc_usb30_sec_mock_utmi_clk 0x7E gcc_debug_mux;
	measure_only_gcc_usb30_sec_sleep_clk 0x7D gcc_debug_mux;
	measure_only_gcc_usb3_sec_phy_aux_clk 0x7F gcc_debug_mux;
	measure_only_gcc_usb3_sec_phy_com_aux_clk 0x80 gcc_debug_mux;
	measure_only_gcc_usb3_sec_phy_pipe_clk 0x81 gcc_debug_mux;
	measure_only_gpu_cc_cx_gfx3d_clk 0x146 gcc_debug_mux 0x1D gpu_cc_debug_mux;
	measure_only_gpu_cc_cx_gfx3d_slv_clk 0x146 gcc_debug_mux 0x1E gpu_cc_debug_mux;
	measure_only_gpu_cc_gx_gfx3d_clk 0x146 gcc_debug_mux 0xD gpu_cc_debug_mux;
	measure_only_ipa_2x_clk 0x132 gcc_debug_mux;
	measure_only_mccc_clk 0xff mc_cc_debug_mux;
	measure_only_memnoc_clk 0xD3 gcc_debug_mux;
	measure_only_pcie_0_pipe_clk 0x102 gcc_debug_mux;
	measure_only_pcie_1_pipe_clk 0x10B gcc_debug_mux;
	measure_only_snoc_clk 0x9 gcc_debug_mux;
	measure_only_ufs_phy_rx_symbol_0_clk 0x112 gcc_debug_mux;
	measure_only_ufs_phy_rx_symbol_1_clk 0x117 gcc_debug_mux;
	measure_only_ufs_phy_tx_symbol_0_clk 0x111 gcc_debug_mux;
	measure_only_usb3_phy_wrapper_gcc_usb30_pipe_clk 0x79 gcc_debug_mux;
	video_cc_apb_clk 0x5D gcc_debug_mux 0xB video_cc_debug_mux;
	video_cc_iris_ahb_clk 0x5D gcc_debug_mux 0x5 video_cc_debug_mux;
	video_cc_mvs0_axi_clk 0x5D gcc_debug_mux 0x9 video_cc_debug_mux;
	video_cc_mvs0_core_clk 0x5D gcc_debug_mux 0x3 video_cc_debug_mux;
	video_cc_mvsc_core_clk 0x5D gcc_debug_mux 0x1 video_cc_debug_mux;
	video_cc_mvsc_ctl_axi_clk 0x5D gcc_debug_mux 0x8 video_cc_debug_mux;
	video_cc_sleep_clk 0x5D gcc_debug_mux 0x7 video_cc_debug_mux;
	video_cc_venus_ahb_clk 0x5D gcc_debug_mux 0xC video_cc_debug_mux;
	video_cc_xo_clk 0x5D gcc_debug_mux 0x6 video_cc_debug_mux;
"

if [ $# -lt 1 ]; then
	echo "No clock name passed"
	return 0
fi

_measure $1
