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
	cam_cc_bps_ahb_clk 0x46 gcc_debug_mux 0xE cam_cc_debug_mux;
	cam_cc_bps_areg_clk 0x46 gcc_debug_mux 0xD cam_cc_debug_mux;
	cam_cc_bps_axi_clk 0x46 gcc_debug_mux 0xC cam_cc_debug_mux;
	cam_cc_bps_clk 0x46 gcc_debug_mux 0xB cam_cc_debug_mux;
	cam_cc_camnoc_axi_clk 0x46 gcc_debug_mux 0x2D cam_cc_debug_mux;
	cam_cc_cci_clk 0x46 gcc_debug_mux 0x2A cam_cc_debug_mux;
	cam_cc_core_ahb_clk 0x46 gcc_debug_mux 0x3A cam_cc_debug_mux;
	cam_cc_cpas_ahb_clk 0x46 gcc_debug_mux 0x2C cam_cc_debug_mux;
	cam_cc_csi0phytimer_clk 0x46 gcc_debug_mux 0x5 cam_cc_debug_mux;
	cam_cc_csi1phytimer_clk 0x46 gcc_debug_mux 0x7 cam_cc_debug_mux;
	cam_cc_csi2phytimer_clk 0x46 gcc_debug_mux 0x9 cam_cc_debug_mux;
	cam_cc_csiphy0_clk 0x46 gcc_debug_mux 0x6 cam_cc_debug_mux;
	cam_cc_csiphy1_clk 0x46 gcc_debug_mux 0x8 cam_cc_debug_mux;
	cam_cc_csiphy2_clk 0x46 gcc_debug_mux 0xA cam_cc_debug_mux;
	cam_cc_icp_apb_clk 0x46 gcc_debug_mux 0x32 cam_cc_debug_mux;
	cam_cc_icp_clk 0x46 gcc_debug_mux 0x26 cam_cc_debug_mux;
	cam_cc_icp_cti_clk 0x46 gcc_debug_mux 0x30 cam_cc_debug_mux;
	cam_cc_ife_0_axi_clk 0x46 gcc_debug_mux 0x1B cam_cc_debug_mux;
	cam_cc_ife_0_clk 0x46 gcc_debug_mux 0x17 cam_cc_debug_mux;
	cam_cc_ife_0_cphy_rx_clk 0x46 gcc_debug_mux 0x1A cam_cc_debug_mux;
	cam_cc_ife_0_csid_clk 0x46 gcc_debug_mux 0x19 cam_cc_debug_mux;
	cam_cc_ife_0_dsp_clk 0x46 gcc_debug_mux 0x18 cam_cc_debug_mux;
	cam_cc_ife_1_axi_clk 0x46 gcc_debug_mux 0x21 cam_cc_debug_mux;
	cam_cc_ife_1_clk 0x46 gcc_debug_mux 0x1D cam_cc_debug_mux;
	cam_cc_ife_1_cphy_rx_clk 0x46 gcc_debug_mux 0x20 cam_cc_debug_mux;
	cam_cc_ife_1_csid_clk 0x46 gcc_debug_mux 0x1F cam_cc_debug_mux;
	cam_cc_ife_1_dsp_clk 0x46 gcc_debug_mux 0x1E cam_cc_debug_mux;
	cam_cc_ife_lite_clk 0x46 gcc_debug_mux 0x22 cam_cc_debug_mux;
	cam_cc_ife_lite_cphy_rx_clk 0x46 gcc_debug_mux 0x24 cam_cc_debug_mux;
	cam_cc_ife_lite_csid_clk 0x46 gcc_debug_mux 0x23 cam_cc_debug_mux;
	cam_cc_ipe_0_ahb_clk 0x46 gcc_debug_mux 0x12 cam_cc_debug_mux;
	cam_cc_ipe_0_areg_clk 0x46 gcc_debug_mux 0x11 cam_cc_debug_mux;
	cam_cc_ipe_0_axi_clk 0x46 gcc_debug_mux 0x10 cam_cc_debug_mux;
	cam_cc_ipe_0_clk 0x46 gcc_debug_mux 0xF cam_cc_debug_mux;
	cam_cc_jpeg_clk 0x46 gcc_debug_mux 0x25 cam_cc_debug_mux;
	cam_cc_lrme_clk 0x46 gcc_debug_mux 0x2B cam_cc_debug_mux;
	cam_cc_mclk0_clk 0x46 gcc_debug_mux 0x1 cam_cc_debug_mux;
	cam_cc_mclk1_clk 0x46 gcc_debug_mux 0x2 cam_cc_debug_mux;
	cam_cc_mclk2_clk 0x46 gcc_debug_mux 0x3 cam_cc_debug_mux;
	cam_cc_mclk3_clk 0x46 gcc_debug_mux 0x4 cam_cc_debug_mux;
	cam_cc_soc_ahb_clk 0x46 gcc_debug_mux 0x2E cam_cc_debug_mux;
	cam_cc_sys_tmr_clk 0x46 gcc_debug_mux 0x33 cam_cc_debug_mux;
	disp_cc_mdss_ahb_clk 0x47 gcc_debug_mux 0x1B disp_cc_debug_mux;
	disp_cc_mdss_byte0_clk 0x47 gcc_debug_mux 0x12 disp_cc_debug_mux;
	disp_cc_mdss_byte0_intf_clk 0x47 gcc_debug_mux 0x13 disp_cc_debug_mux;
	disp_cc_mdss_dp_aux_clk 0x47 gcc_debug_mux 0x1A disp_cc_debug_mux;
	disp_cc_mdss_dp_crypto_clk 0x47 gcc_debug_mux 0x17 disp_cc_debug_mux;
	disp_cc_mdss_dp_link_clk 0x47 gcc_debug_mux 0x15 disp_cc_debug_mux;
	disp_cc_mdss_dp_link_intf_clk 0x47 gcc_debug_mux 0x16 disp_cc_debug_mux;
	disp_cc_mdss_dp_pixel1_clk 0x47 gcc_debug_mux 0x19 disp_cc_debug_mux;
	disp_cc_mdss_dp_pixel_clk 0x47 gcc_debug_mux 0x18 disp_cc_debug_mux;
	disp_cc_mdss_esc0_clk 0x47 gcc_debug_mux 0x14 disp_cc_debug_mux;
	disp_cc_mdss_mdp_clk 0x47 gcc_debug_mux 0xE disp_cc_debug_mux;
	disp_cc_mdss_mdp_lut_clk 0x47 gcc_debug_mux 0x10 disp_cc_debug_mux;
	disp_cc_mdss_non_gdsc_ahb_clk 0x47 gcc_debug_mux 0x1C disp_cc_debug_mux;
	disp_cc_mdss_pclk0_clk 0x47 gcc_debug_mux 0xD disp_cc_debug_mux;
	disp_cc_mdss_rot_clk 0x47 gcc_debug_mux 0xF disp_cc_debug_mux;
	disp_cc_mdss_rscc_ahb_clk 0x47 gcc_debug_mux 0x1E disp_cc_debug_mux;
	disp_cc_mdss_rscc_vsync_clk 0x47 gcc_debug_mux 0x1D disp_cc_debug_mux;
	disp_cc_mdss_vsync_clk 0x47 gcc_debug_mux 0x11 disp_cc_debug_mux;
	disp_cc_xo_clk 0x47 gcc_debug_mux 0x25 disp_cc_debug_mux;
	gcc_aggre_ufs_phy_axi_clk 0x11D gcc_debug_mux;
	gcc_aggre_usb2_sec_axi_clk 0x1C8 gcc_debug_mux;
	gcc_aggre_usb3_prim_axi_clk 0x11B gcc_debug_mux;
	gcc_ahb2phy_east_clk 0x73 gcc_debug_mux;
	gcc_ahb2phy_west_clk 0x6F gcc_debug_mux;
	gcc_apc_vs_clk 0x1B9 gcc_debug_mux;
	gcc_boot_rom_ahb_clk 0x94 gcc_debug_mux;
	gcc_camera_ahb_clk 0x3A gcc_debug_mux;
	gcc_camera_hf_axi_clk 0x40 gcc_debug_mux;
	gcc_camera_xo_clk 0x43 gcc_debug_mux;
	gcc_ce1_ahb_clk 0xA9 gcc_debug_mux;
	gcc_ce1_axi_clk 0xA8 gcc_debug_mux;
	gcc_ce1_clk 0xA7 gcc_debug_mux;
	gcc_cfg_noc_usb2_sec_axi_clk 0x1C7 gcc_debug_mux;
	gcc_cfg_noc_usb3_prim_axi_clk 0x1D gcc_debug_mux;
	gcc_cpuss_ahb_clk 0xCE gcc_debug_mux;
	gcc_cpuss_gnoc_clk 0xCF gcc_debug_mux;
	gcc_ddrss_gpu_axi_clk 0xBB gcc_debug_mux;
	gcc_disp_ahb_clk 0x3B gcc_debug_mux;
	gcc_disp_gpll0_div_clk_src 0x152 gcc_debug_mux;
	gcc_disp_hf_axi_clk 0x41 gcc_debug_mux;
	gcc_disp_xo_clk 0x44 gcc_debug_mux;
	gcc_emac_axi_clk 0x16D gcc_debug_mux;
	gcc_emac_ptp_clk 0x1D3 gcc_debug_mux;
	gcc_emac_rgmii_clk 0x16A gcc_debug_mux;
	gcc_emac_slv_ahb_clk 0x16C gcc_debug_mux;
	gcc_gp1_clk 0xDE gcc_debug_mux;
	gcc_gp2_clk 0xDF gcc_debug_mux;
	gcc_gp3_clk 0xE0 gcc_debug_mux;
	gcc_gpu_cfg_ahb_clk 0x142 gcc_debug_mux;
	gcc_gpu_gpll0_clk_src 0x148 gcc_debug_mux;
	gcc_gpu_gpll0_div_clk_src 0x149 gcc_debug_mux;
	gcc_gpu_memnoc_gfx_clk 0x145 gcc_debug_mux;
	gcc_gpu_snoc_dvm_gfx_clk 0x147 gcc_debug_mux;
	gcc_pcie0_phy_refgen_clk 0x1F3 gcc_debug_mux;
	gcc_pcie_0_aux_clk 0xE5 gcc_debug_mux;
	gcc_pcie_0_cfg_ahb_clk 0xE4 gcc_debug_mux;
	gcc_pcie_0_mstr_axi_clk 0xE3 gcc_debug_mux;
	gcc_pcie_0_pipe_clk 0xE6 gcc_debug_mux;
	gcc_pcie_0_slv_axi_clk 0xE2 gcc_debug_mux;
	gcc_pcie_0_slv_q2a_axi_clk 0xE1 gcc_debug_mux;
	gcc_pcie_phy_aux_clk 0xEF gcc_debug_mux;
	gcc_pdm2_clk 0x8E gcc_debug_mux;
	gcc_pdm_ahb_clk 0x8C gcc_debug_mux;
	gcc_pdm_xo4_clk 0x8D gcc_debug_mux;
	gcc_prng_ahb_clk 0x8F gcc_debug_mux;
	gcc_qmip_camera_nrt_ahb_clk 0x3D gcc_debug_mux;
	gcc_qmip_disp_ahb_clk 0x3E gcc_debug_mux;
	gcc_qmip_pcie_ahb_clk 0xE8 gcc_debug_mux;
	gcc_qmip_video_vcodec_ahb_clk 0x15C gcc_debug_mux;
	gcc_qspi_cnoc_periph_ahb_clk 0x168 gcc_debug_mux;
	gcc_qspi_core_clk 0x169 gcc_debug_mux;
	gcc_qupv3_wrap0_core_2x_clk 0x77 gcc_debug_mux;
	gcc_qupv3_wrap0_core_clk 0x76 gcc_debug_mux;
	gcc_qupv3_wrap0_s0_clk 0x78 gcc_debug_mux;
	gcc_qupv3_wrap0_s1_clk 0x79 gcc_debug_mux;
	gcc_qupv3_wrap0_s2_clk 0x7A gcc_debug_mux;
	gcc_qupv3_wrap0_s3_clk 0x7B gcc_debug_mux;
	gcc_qupv3_wrap0_s4_clk 0x7C gcc_debug_mux;
	gcc_qupv3_wrap0_s5_clk 0x7D gcc_debug_mux;
	gcc_qupv3_wrap1_core_2x_clk 0x194 gcc_debug_mux;
	gcc_qupv3_wrap1_core_clk 0x193 gcc_debug_mux;
	gcc_qupv3_wrap1_s0_clk 0x195 gcc_debug_mux;
	gcc_qupv3_wrap1_s1_clk 0x196 gcc_debug_mux;
	gcc_qupv3_wrap1_s2_clk 0x197 gcc_debug_mux;
	gcc_qupv3_wrap1_s3_clk 0x198 gcc_debug_mux;
	gcc_qupv3_wrap1_s4_clk 0x199 gcc_debug_mux;
	gcc_qupv3_wrap1_s5_clk 0x19A gcc_debug_mux;
	gcc_qupv3_wrap_0_m_ahb_clk 0x74 gcc_debug_mux;
	gcc_qupv3_wrap_0_s_ahb_clk 0x75 gcc_debug_mux;
	gcc_qupv3_wrap_1_m_ahb_clk 0x191 gcc_debug_mux;
	gcc_qupv3_wrap_1_s_ahb_clk 0x192 gcc_debug_mux;
	gcc_sdcc1_ahb_clk 0x1F0 gcc_debug_mux;
	gcc_sdcc1_apps_clk 0x1CB gcc_debug_mux;
	gcc_sdcc1_ice_core_clk 0x185 gcc_debug_mux;
	gcc_sdcc2_ahb_clk 0x71 gcc_debug_mux;
	gcc_sdcc2_apps_clk 0x70 gcc_debug_mux;
	gcc_sdr_core_clk 0x65 gcc_debug_mux;
	gcc_sdr_csr_hclk 0x69 gcc_debug_mux;
	gcc_sdr_pri_mi2s_clk 0x1A1 gcc_debug_mux;
	gcc_sdr_sec_mi2s_clk 0x1A2 gcc_debug_mux;
	gcc_sdr_wr0_mem_clk 0x66 gcc_debug_mux;
	gcc_sdr_wr1_mem_clk 0x67 gcc_debug_mux;
	gcc_sdr_wr2_mem_clk 0x68 gcc_debug_mux;
	gcc_sys_noc_cpuss_ahb_clk 0xC gcc_debug_mux;
	gcc_ufs_phy_ahb_clk 0xFC gcc_debug_mux;
	gcc_ufs_phy_axi_clk 0xFB gcc_debug_mux;
	gcc_ufs_phy_ice_core_clk 0x102 gcc_debug_mux;
	gcc_ufs_phy_phy_aux_clk 0x103 gcc_debug_mux;
	gcc_ufs_phy_rx_symbol_0_clk 0xFE gcc_debug_mux;
	gcc_ufs_phy_tx_symbol_0_clk 0xFD gcc_debug_mux;
	gcc_ufs_phy_unipro_core_clk 0x101 gcc_debug_mux;
	gcc_usb20_sec_master_clk 0x1AF gcc_debug_mux;
	gcc_usb20_sec_mock_utmi_clk 0x1B1 gcc_debug_mux;
	gcc_usb20_sec_sleep_clk 0x1B0 gcc_debug_mux;
	gcc_usb2_sec_phy_aux_clk 0x1BD gcc_debug_mux;
	gcc_usb2_sec_phy_com_aux_clk 0x1BE gcc_debug_mux;
	gcc_usb2_sec_phy_pipe_clk 0x1BF gcc_debug_mux;
	gcc_usb30_prim_master_clk 0x5F gcc_debug_mux;
	gcc_usb30_prim_mock_utmi_clk 0x61 gcc_debug_mux;
	gcc_usb30_prim_sleep_clk 0x60 gcc_debug_mux;
	gcc_usb3_prim_phy_aux_clk 0x62 gcc_debug_mux;
	gcc_usb3_prim_phy_com_aux_clk 0x63 gcc_debug_mux;
	gcc_usb3_prim_phy_pipe_clk 0x64 gcc_debug_mux;
	gcc_vdda_vs_clk 0x10E gcc_debug_mux;
	gcc_vddcx_vs_clk 0x10C gcc_debug_mux;
	gcc_vddmx_vs_clk 0x10D gcc_debug_mux;
	gcc_video_ahb_clk 0x39 gcc_debug_mux;
	gcc_video_axi0_clk 0x3F gcc_debug_mux;
	gcc_video_xo_clk 0x42 gcc_debug_mux;
	gcc_vs_ctrl_ahb_clk 0x110 gcc_debug_mux;
	gcc_vs_ctrl_clk 0x10F gcc_debug_mux;
	gcc_wcss_vs_clk 0x113 gcc_debug_mux;
	gpu_cc_ahb_clk 0x144 gcc_debug_mux 0x10 gpu_cc_debug_mux;
	gpu_cc_crc_ahb_clk 0x144 gcc_debug_mux 0x11 gpu_cc_debug_mux;
	gpu_cc_cx_apb_clk 0x144 gcc_debug_mux 0x14 gpu_cc_debug_mux;
	gpu_cc_cx_gfx3d_clk 0x144 gcc_debug_mux 0x1A gpu_cc_debug_mux;
	gpu_cc_cx_gfx3d_slv_clk 0x144 gcc_debug_mux 0x1B gpu_cc_debug_mux;
	gpu_cc_cx_gmu_clk 0x144 gcc_debug_mux 0x18 gpu_cc_debug_mux;
	gpu_cc_cx_snoc_dvm_clk 0x144 gcc_debug_mux 0x15 gpu_cc_debug_mux;
	gpu_cc_cxo_aon_clk 0x144 gcc_debug_mux 0xA gpu_cc_debug_mux;
	gpu_cc_cxo_clk 0x144 gcc_debug_mux 0x19 gpu_cc_debug_mux;
	gpu_cc_gx_gfx3d_clk 0x144 gcc_debug_mux 0xB gpu_cc_debug_mux;
	gpu_cc_gx_gmu_clk 0x144 gcc_debug_mux 0xF gpu_cc_debug_mux;
	gpu_cc_sleep_clk 0x144 gcc_debug_mux 0x16 gpu_cc_debug_mux;
	measure_only_cnoc_clk 0x15 gcc_debug_mux;
	measure_only_ipa_2x_clk 0x128 gcc_debug_mux;
	measure_only_mccc_clk 0xff mc_cc_debug_mux;
	measure_only_mmmc_clk 0xC2 gcc_debug_mux;
	measure_only_snoc_clk 0x7 gcc_debug_mux;
	video_cc_apb_clk 0x48 gcc_debug_mux 0x8 video_cc_debug_mux;
	video_cc_sleep_clk 0x48 gcc_debug_mux 0xD video_cc_debug_mux;
	video_cc_vcodec0_axi_clk 0x48 gcc_debug_mux 0x6 video_cc_debug_mux;
	video_cc_vcodec0_core_clk 0x48 gcc_debug_mux 0x3 video_cc_debug_mux;
	video_cc_venus_ahb_clk 0x48 gcc_debug_mux 0x9 video_cc_debug_mux;
	video_cc_venus_ctl_axi_clk 0x48 gcc_debug_mux 0x5 video_cc_debug_mux;
	video_cc_venus_ctl_core_clk 0x48 gcc_debug_mux 0x1 video_cc_debug_mux;
	video_cc_xo_clk 0x48 gcc_debug_mux 0xC video_cc_debug_mux;
"

if [ $# -lt 1 ]; then
	echo "No clock name passed"
	return 0
fi

_measure $1
