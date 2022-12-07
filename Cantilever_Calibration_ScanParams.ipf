#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// SCAN CANTILEVER PARAMETERS -- XLASER AND END MASS

//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ButtonProc_ScanXlaserPanel(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
				Panel_ScanXlaserMend()
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ButtonProc_ScanXlaserMend(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			strswitch(ba.ctrlName)
			
				case "ScanXlaser":
				
					Scan_Xlaser()
				
				break
				
				case "ScanMend":
				case "ScanIendY":
				
					Scan_mend()
				
				break

				case "ScanIendZ":
				
					Scan_Iend()
				
				break

				case "ScanXlaserMend":
				
					ProgressBar("PanelScanXlaserMend", "Scanning parameters", "Parameter scan", Scan_Xlaser_mend)
					//Scan_Xlaser_mend()
				
				break
				
			
				case "ScanXlaserMendIend":
				
					ProgressBar("PanelScanXlaserMend", "Scanning parameters", "Parameter scan", Scan_Xlaser_mend_Iend)
					//Scan_Xlaser_mend_Iend()
				
				break

				case "ScanIendZ_Min":
				
					ProgressBar("PanelScanXlaserMend", "Scanning parameters", "Parameter scan", Scan_Iend_Min)
					//Scan_Iend_Min()
				
				break

			endswitch
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function CheckProc_AddError2Find_k(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			
			Build_ErrorString(cba.ctrlName,checked)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function CheckProc_AppendkvsXlaser2PSD(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			
			if(checked==0)
			
				SVAR CurrentGraph=root:packages:AFM_Calibration:CurrentGraph
				DoWindow/F $CurrentGraph
			
				if(V_flag==1)
					//GetWindow/Z Graphk_xlaser
					GetWindow/Z # activeSW
					if(strsearch(S_value, "#",0)>0)
						SetActiveSubwindow ##
					endif
				
					KillWindow/Z #G0
				endif

			endif

			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Build_ErrorString(ErrType, checked)
	string ErrType
	variable checked

	SVAR S_ErrorKey=root:packages:AFM_Calibration:S_ErrorKey
	
	// ErrType:  check_Kequip, check_KSader, check_KdiffEqSader, check_KdiffEqSadern1
	// S_ErrorKey="Kequip:0;KSader:0;KdiffEqSader:0;KdiffEqSadern1:0"
	string Skey=ErrType[6,strlen(ErrType)-1]
	S_ErrorKey=ReplaceNumberByKey(Skey, S_ErrorKey, checked)
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ButtonProc_FindMinError(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			

			// Need to recalculate Sader since it can overwritten by other m_end scan

			DFREF dfSav = GetDataFolderDFR()
			DFREF dfcal=root:Packages:AFM_Calibration:
			
			SetDataFolder dfcal
			
			NVAR xtip
			NVAR Cant_length_e
			NVAR cant_width
			NVAR htip
			NVAR ytip
			NVAR tip_H_e
			NVAR mend2mc
			NVAR Iend2Ic
			
			NVAR NOP_Mend
			NVAR NOP_Iend
			NVAR Range_mend
			NVAR Range_Iend
			
			NVAR Medium_temperature
			NVAR medium_dens
			
			SVAR Spectrum_type
			SVAR model

			wave wf0, wfvac
			wave wQ, wtau
			wave/C wG
		
			wave/SDFR=dfcal wPeakArea=:Results:wPeakArea
			wave/SDFR=dfcal wCn=:Results:wCn
			wave/SDFR=dfcal wDn=:Results:wDn
			wave/SDFR=dfcal wkz_thermal=:Results:wkz_thermal
				
			//
			// process Sader method
			//
			strswitch(Spectrum_type)
		
				case "normal":
				
					wave wk_avg=wkz_vs_xm_avg
					NOP_Mend=DimSize(wk_avg,1)
					
					variable m0=DimOffset(wk_avg,1)
					variable m1=DimOffset(wk_avg,1)+(NOP_Mend-1)*DimDelta(wk_avg,1)
					
					mend2mc=(m1+m0)/2
					Range_mend=(m1-m0)/2
					
	
					make/O/N=(NOP_Mend) wkzSader_vs_mtip_avg, wkzSader_vs_mtip_D, wkzSader_vs_mtip_n1
					make/O/N=(NOP_Mend, numpnts(wkz_thermal)) wkzSader_vs_mtip
					
					SetScale/I x mend2mc-Range_mend,mend2mc+Range_mend,"", wkzSader_vs_mtip_avg, wkzSader_vs_mtip_D, wkzSader_vs_mtip_n1
					SetScale/I x mend2mc-Range_mend,mend2mc+Range_mend,"", wkzSader_vs_mtip
		
					strswitch(model)
					
						case "SFO (full)":
						case "SFO (full) vn":
		
							// ratio of kc to mc: kc/mc=3/Cn^4*wn^2
							wkzSader_vs_mtip=(2*pi*wfvac[q])^2
							// ** DO AFTER SWITCH ** wkzSader_vs_mtip*=3/C_n_m_I(q+1,x, Iend2Ic)^4
							// multiply by mc=mf/tau
							wkzSader_vs_mtip*=pi*(cant_width/2)^2*cant_length_e*medium_dens
							wkzSader_vs_mtip/=wtau[q]
						break
		
						default:
					
							wkzSader_vs_mtip=pi^3*medium_dens*cant_width^2*cant_length_e*wf0[q]^2*wQ[q]*imag(wG[q])
							// ** DO AFTER SWITCH ** wkzSader_vs_mtip*=3/C_n_m_I(q+1,x, Iend2Ic)^4
							
						break
						
					endswitch
					
					//wkzSader_vs_mtip*=3/C_n_m_I(q+1,x, Iend2Ic)^4
					if(Iend2Ic==0)
						wkzSader_vs_mtip*=3/C_n_m(q+1,x)^4
					else
						wkzSader_vs_mtip*=3/C_n_m_I(q+1,x, Iend2Ic)^4
					endif
					// correct kz for tip offset
					wkzSader_vs_mtip/=xtip^3
					
				break
				
			endswitch


			FindMinError(1)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function/S FindMinError(DoPrint)
	variable DoPrint

	DFREF dfSav = GetDataFolderDFR()
	DFREF dfcal=root:Packages:AFM_Calibration:
	
	SetDataFolder dfcal
	NVAR cant_Xlaser
	NVAR xlaser
	NVAR mend2mc
	NVAR Iend2Ic
	NVAR cant_length

	SVAR model
	SVAR Spectrum_type
	SVAR S_ErrorKey
// Kequip:0;KSader:0;KdiffEqSader:0;KdiffEqSadern1:0
	
	NVAR k_avg_Eq, k_avg_Eq_Err
	NVAR k_avg_Sader, k_avg_Sader_Err
	NVAR k_avg_Eqn1, k_avg_Eqn1_Err
	NVAR k_avg_Sadern1, k_avg_Sadern1_Err
	
	NVAR DirectionDim
	
	// 20210112 - wjl compatability check
	NVAR/Z mend2mc_positive
	if(!NVAR_Exists(mend2mc_positive))
		Variable/G mend2mc_positive = 0
	endif
	

	variable AddError=0, i=0
	
	strswitch(Spectrum_type)
		
		case "normal":
	
	
			// need to do scan xlaser/mend first
			wave/Z wkz_vs_xm_avg
			if(WaveExists(wkz_vs_xm_avg)==0)
				SetDataFolder dfSav
				Abort "Perform scan parameters calculation first."
			endif
	

			wave wk_avg=wkz_vs_xm_avg
			wave wk_avg_Sader=wkzSader_vs_mtip_avg
			wave wk_n1=wkz_vs_xm_n1
			wave wk_n1Sader=wkzSader_vs_mtip_n1
			
			wave wk_D=wkz_vs_xm_D
			wave wk_DSader=wkzSader_vs_mtip_D
			wave wk_DEqSader=wk_delEqSader
			wave wk_DEqSader_n1=wk_n1_delEqSader
			
			Duplicate/O wk_D, wkz_vs_xm_del
			wave wk_del=wkz_vs_xm_del
			
		break
			
		case "lateral":
					
			// need to do scan xlaser/mend first
			wave/Z wktheta_vs_xm_avg
			if(WaveExists(wktheta_vs_xm_avg)==0)
				SetDataFolder dfSav
				Abort "Perform scan parameters calculation first."
			endif

			wave wk_avg=wktheta_vs_xm_avg
			wave wk_avg_Sader=wkthetaSader_vs_mtip_avg
			wave wk_n1=wktheta_vs_xm_n1
			wave wk_n1Sader=wkthetaSader_vs_mtip_n1
			
			wave wk_D=wktheta_vs_xm_D
			wave wk_DSader=wkthetaSader_vs_mtip_D
			wave wk_DEqSader=wk_delEqSader
			wave wk_DEqSader_n1=wk_n1_delEqSader
			
			Duplicate/O wk_D, wktheta_vs_xm_del
			wave wk_del=wktheta_vs_xm_del			

		break
			
	endswitch		
			

	wk_del=1
	
	AddError=NumberByKey("Kequip", S_ErrorKey)
	
	if(AddError)
		wk_del*=wk_D/wk_avg
		i+=1
	endif
	
	AddError=NumberByKey("KSader", S_ErrorKey)
	
	if(AddError)
		wk_del*=wk_DSader[q]/wk_avg_Sader[q]
		i+=1
	endif
	
	AddError=NumberByKey("KdiffEqSader", S_ErrorKey)
	
	if(AddError)
		wk_del*=wk_DEqSader/((wk_avg+wk_avg_Sader[q])/2)
		i+=1
	endif
	
	AddError=NumberByKey("KdiffEqSadern1", S_ErrorKey)
	
	if(AddError)
		wk_del*=wk_DEqSader_n1/((wk_n1+wk_n1Sader[q])/2)
		i+=1
	endif
						
	wk_del=(wk_del)^(1/i)
	
	//Duplicate/O wk_del, $(NameOfWave(wk_del)+"_Back")

	ControlInfo/W=PanelScanXlaserMend MinPathDirection
	DirectionDim=V_Value-1
	
	// returns cmplx(PminDX[0],PminDY[0])
	// PminDY[0] is the optimized value
	Scan_forMinPath(wk_del, wk_avg,DirectionDim,mend2mc_positive)
	
	wave Path_MinDX, Path_MinDY
	wave PminDX, PminDY
	
	xlaser=PminDX[0]
	cant_Xlaser=xlaser*cant_length

	strswitch(Spectrum_type)
		
		case "normal":
	
			mend2mc=PminDY[0]
			
			wave wD_kzs_EqTh_R=:Results:wD_kzs_EqTh_R
			wave wD_kzs_FluidStruc_R=:Results:wD_kzs_FluidStruc_R
			wave wD_kzs_Sader_R=:Results:wD_kzs_Sader_R
			
			// all errors are relative
			k_avg_Eq=wk_avg(PminDX[0])(PminDY[0])
			k_avg_Eq_Err=wk_D(PminDX[0])(PminDY[0])
			k_avg_Sader=wk_avg_Sader(PminDY[0])
			k_avg_Sader_Err=wk_DSader(PminDY[0])
			k_avg_Eqn1=wk_n1(PminDX[0])(PminDY[0])
			k_avg_Eqn1_Err=wD_kzs_EqTh_R[0]*k_avg_Eqn1
			
			k_avg_Sadern1=wk_n1Sader(PminDY[0])
			
			if(strsearch(model, "SFO (full)",0)>=0)
				k_avg_Sadern1_Err=wD_kzs_FluidStruc_R[0]*k_avg_Eqn1
			else
				k_avg_Sadern1_Err=wD_kzs_Sader_R[0]*k_avg_Eqn1
			endif
		
		break
			
		case "lateral":
					
			Iend2Ic=PminDY[0]

			wave wD_kthetas_EqTh_R=:Results:wD_kthetas_EqTh_R
			wave wD_kthetas_FluidStruc_R=:Results:wD_kthetas_FluidStruc_R
			wave wD_kthetas_Sader_R=:Results:wD_kthetas_Sader_R
			
			// all errors are relative
			k_avg_Eq=wk_avg(PminDX[0])(PminDY[0])
			k_avg_Eq_Err=wk_D(PminDX[0])(PminDY[0])
			k_avg_Sader=wk_avg_Sader(PminDY[0])
			k_avg_Sader_Err=wk_DSader(PminDY[0])
			k_avg_Eqn1=wk_n1(PminDX[0])(PminDY[0])
			k_avg_Eqn1_Err=wD_kthetas_EqTh_R[0]*k_avg_Eqn1
			
			k_avg_Sadern1=wk_n1Sader(PminDY[0])
			
			if(strsearch(model, "SFO (full)",0)>=0)
				k_avg_Sadern1_Err=wD_kthetas_FluidStruc_R[0]*k_avg_Eqn1
			else
				k_avg_Sadern1_Err=wD_kthetas_Sader_R[0]*k_avg_Eqn1
			endif

		break
			
	endswitch


	string/G S_out="X_laser="
	S_out+=num2str(PminDX[0])+";"
	S_out+="ξ="
	S_out+=num2str(PminDY[0])+";"
	S_out+="k(avg)="
	S_out+=num2str(Interp2D(wk_avg,PminDX[0],PminDY[0]))+";"
	S_out+="kSader(avg)="
	S_out+=num2str(wk_avg_Sader(PminDY[0]))+";"
	S_out+="k(n=1)="
	S_out+=num2str(Interp2D(wk_n1,PminDX[0],PminDY[0]))+";"
	S_out+="kSader(n=1)="
	S_out+=num2str(wk_n1Sader(PminDY[0]))+";"
		

	if(DoPrint)
		print "*****************************"
		print S_out
		print "*****************************\n"
	endif

// Update 1D plots

	variable savVar=xlaser
	
	DoWindow/F Graphk_xlaser

	if(V_flag==1)
		Scan_xlaser()
		xlaser=savVar
	endif


	savVar=mend2mc
		
	DoWindow/F Graphk_mtip

	if(V_flag==1)
		Scan_mend()
		mend2mc=savVar
	endif


	SetDataFolder dfSav
	
	return S_out
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ButtonProc_PlotScanXlaserMend(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			DFREF dfSav = GetDataFolderDFR()
			DFREF dfcal=root:Packages:AFM_Calibration:
			
			SetDataFolder dfcal
		
			SVAR Spectrum_type
			NVAR DoInsetParamScan
			SVAR CurrentGraph
			string type
			
			strswitch(Spectrum_type)
			
				case "normal":
			
						type="z"
			
						ControlInfo TypeOfPlot
						
						switch(V_Value)
						
							case 1:
							
								wave wk_avg=wkz_vs_xlaser_avg
								wave wk_D=wkz_vs_xlaser_D
								wave wk_n1=wkz_vs_xlaser_n1
			
								if(DoInsetParamScan)
									DoWindow/F $CurrentGraph
								
									if(V_flag==1)
										Graph_k_vs_xlaser(wk_avg, wk_D, wk_n1, type,1)
									endif

								else

									DoWindow/F Graphk_xlaser
				
									if(V_flag==0)
										Graph_k_vs_xlaser(wk_avg, wk_D, wk_n1, type,0)
									endif
									
								endif
							
							break
							
							case 2:
							
			
								wave wk_avg=wkz_vs_mtip_avg
								wave wk_D=wkz_vs_mtip_D
								wave wk_n1=wkz_vs_mtip_n1
					
								wave wkSader_avg=wkzSader_vs_mtip_avg
								wave wkSader_D=wkzSader_vs_mtip_D
								wave wkSader_n1=wkzSader_vs_mtip_n1
			
								DoWindow/F Graphk_mtip
			
								if(V_flag==0)
									Graph_k_vs_mtip(wk_avg, wk_D, wk_n1, wkSader_avg, wkSader_D, wkSader_n1, type)
								endif
							
							break
			
							case 3:
							
								wave wk_avg=wkz_vs_xm_avg
								wave wk_D=wkz_vs_xm_del
								wave Path_MinDX, Path_MinDY
								wave PminDX, PminDY

								DoWindow/F Graphk_xm
								
								if(V_flag==0)
									Graph_kavg_AND_Deltak_VS_xm(wk_avg, wk_D, Path_MinDX, Path_MinDY, PminDX, PminDY)
								endif
							
							break
						
						endswitch
					
					break
					
					case "lateral":
						
						type="θ"
			
						ControlInfo TypeOfPlot
						
						switch(V_Value)
						
							case 1:
							
								wave wk_avg=wktheta_vs_xlaser_avg
								wave wk_D=wktheta_vs_xlaser_D
								wave wk_n1=wktheta_vs_xlaser_n1
			
			
								if(DoInsetParamScan)
									DoWindow/F $CurrentGraph
								
									if(V_flag==1)
										Graph_k_vs_xlaser(wk_avg, wk_D, wk_n1, type,1)
									endif

								else

									DoWindow/F Graphk_xlaser
				
									if(V_flag==0)
										Graph_k_vs_xlaser(wk_avg, wk_D, wk_n1, type,0)
									endif
									
								endif
							
							break
							
							case 2:
							
			
								wave wk_avg=wktheta_vs_mtip_avg
								wave wk_D=wktheta_vs_mtip_D
								wave wk_n1=wktheta_vs_mtip_n1
					
								wave wkSader_avg=wkthetaSader_vs_mtip_avg
								wave wkSader_D=wkthetaSader_vs_mtip_D
								wave wkSader_n1=wkthetaSader_vs_mtip_n1
			
								DoWindow/F Graphk_mtip
			
								if(V_flag==0)
									Graph_k_vs_mtip(wk_avg, wk_D, wk_n1, wkSader_avg, wkSader_D, wkSader_n1, type)
								endif
							
							break
			
							case 3:
							
								wave wk_avg=wktheta_vs_xm_avg
								wave wk_D=wktheta_vs_xm_del
								wave Path_MinDX, Path_MinDY
								wave PminDX, PminDY

								DoWindow/F Graphk_xm
								
								if(V_flag==0)
									Graph_kavg_AND_Deltak_VS_xm(wk_avg, wk_D, Path_MinDX, Path_MinDY, PminDX, PminDY)
								endif
							
							
							break
							
						endswitch

					break
					
			endswitch		
			
			break
			
		case -1: // control being killed
			break
	endswitch

	SetDataFolder dfSav

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ButtonProc_EditPath(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			String fldrSav0= GetDataFolder(1)
			SetDataFolder root:packages:AFM_Calibration:
			wave/Z Path_MinD,Path_MinDX,Path_MinDY,Path_avg_MinD,Path_MinDS
			if(WaveExists(Path_MinD)==0)
				Abort "Do scan parameters first."
			endif
			Edit/W=(23.25,55.25,537.75,354.5) Path_MinD,Path_MinDX,Path_MinDY,Path_MinDS,Path_avg_MinD
			ModifyTable format(Point)=1
			SetDataFolder fldrSav0			
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Panel_ScanXlaserMend() : Panel

	DoWindow/F PanelScanXlaserMend
	
	if(V_flag==1)
		return 1
	endif
	
	NewPanel /W=(851,759,1253,1159) as "Scan Xlaser & mend"
	DoWindow/C PanelScanXlaserMend

	SetDrawLayer UserBack
	GroupBox groupMin,pos={193.00,259.00},size={201.00,104.00},title="Min ∆k"
	GroupBox groupMin,labelBack=(65535,65535,65535),fColor=(1,26214,0)
	GroupBox groupSacn,pos={6.00,139.00},size={388.00,117.00},title="Scan"
	GroupBox groupSacn,labelBack=(65535,60076,49151)
	GroupBox groupRange,pos={5.00,5.00},size={390.00,133.00},title="Range"
	GroupBox groupRange,labelBack=(56797,56797,56797)
	Button ScanXlaser,pos={27.00,105.00},size={90.00,26.00},proc=ButtonProc_ScanXlaserMend
	Button ScanXlaser,title="Scan x\\Blaser",fColor=(57346,65535,49151)
	Button ScanXlaser,valueColor=(1,26214,0)
	Button ScanMend,pos={160.00,105.00},size={90.00,26.00},proc=ButtonProc_ScanXlaserMend
	Button ScanMend,title="Scan m\\Bend\\M/m\\Bc",fColor=(49151,60031,65535)
	Button ScanMend,valueColor=(1,16019,65535)
	Button ScanIendZ,pos={298.00,105.00},size={90.00,26.00},proc=ButtonProc_ScanXlaserMend
	Button ScanIendZ,title="Scan I\\Bend\\M/m\\Bc\\ML\\S2"
	Button ScanIendZ,fColor=(65535,49151,49151),valueColor=(65535,0,0)
	Button ScanXlaserMend,pos={10.00,157.00},size={118.00,28.00},proc=ButtonProc_ScanXlaserMend
	Button ScanXlaserMend,title="Scan x\\Blaser\\M & m\\Bend\\M/m\\Bc"
	SetVariable mend,pos={154.00,22.00},size={95.00,20.00},bodyWidth=46,proc=SetVarProc_UpdateCantParam
	SetVariable mend,title="m\\Bend\\M/m\\Bc",format="%.3g",fColor=(1,16019,65535)
	SetVariable mend,valueColor=(1,16019,65535)
	SetVariable mend,limits={-inf,inf,0},value= root:packages:AFM_Calibration:mend2mc
	SetVariable NOPmend,pos={144.00,50.00},size={105.00,18.00},bodyWidth=47
	SetVariable NOPmend,title="num. pnts",format="%.3g",fColor=(1,16019,65535)
	SetVariable NOPmend,valueColor=(1,16019,65535)
	SetVariable NOPmend,limits={0,inf,0},value= root:packages:AFM_Calibration:NOP_mend
	SetVariable mendRange,pos={126.00,75.00},size={123.00,20.00},bodyWidth=47
	SetVariable mendRange,title="∆m\\Bend\\M/m\\Bc\\M (±)",format="%.4g"
	SetVariable mendRange,fColor=(1,16019,65535),valueColor=(1,16019,65535)
	SetVariable mendRange,limits={-inf,inf,0},value= root:packages:AFM_Calibration:Range_mend
	SetVariable xlaser,pos={42.00,22.00},size={73.00,20.00},bodyWidth=47,proc=SetVarProc_UpdateCantParam
	SetVariable xlaser,title="x\\Blaser",format="%.4g",fColor=(1,26214,0)
	SetVariable xlaser,valueColor=(1,26214,0)
	SetVariable xlaser,limits={-inf,inf,0},value= root:packages:AFM_Calibration:xlaser
	SetVariable NOPxlaser,pos={10.00,50.00},size={105.00,18.00},bodyWidth=47
	SetVariable NOPxlaser,title="num. pnts",format="%.3g",fColor=(1,26214,0)
	SetVariable NOPxlaser,valueColor=(1,26214,0)
	SetVariable NOPxlaser,limits={0,inf,0},value= root:packages:AFM_Calibration:NOP_Xlaser
	SetVariable xlaserRange,pos={15.00,75.00},size={100.00,20.00},bodyWidth=47
	SetVariable xlaserRange,title="∆x\\Blaser\\M (±)",format="%.4g"
	SetVariable xlaserRange,fColor=(1,26214,0),valueColor=(1,26214,0)
	SetVariable xlaserRange,limits={-inf,inf,0},value= root:packages:AFM_Calibration:Range_Xlaser
	SetVariable NOPIend,pos={281.00,50.00},size={105.00,18.00},bodyWidth=47
	SetVariable NOPIend,title="num. pnts",format="%.3g",fColor=(65535,0,0)
	SetVariable NOPIend,valueColor=(65535,0,0)
	SetVariable NOPIend,limits={0,inf,0},value= root:packages:AFM_Calibration:NOP_Iend
	SetVariable Iend,pos={275.00,22.00},size={111.00,26.00},bodyWidth=60,proc=SetVarProc_UpdateCantParam
	SetVariable Iend,title="I\\Bend\\M/m\\Bc\\ML\\S2",format="%.3g"
	SetVariable Iend,fColor=(65535,0,0),valueColor=(65535,0,0)
	SetVariable Iend,limits={-inf,inf,0},value= root:packages:AFM_Calibration:Iend2Ic
	SetVariable IendRange,pos={261.00,75.00},size={125.00,26.00},bodyWidth=47
	SetVariable IendRange,title="∆I\\Bend\\M/m\\Bc\\ML\\S2\\M (±)",format="%.4g"
	SetVariable IendRange,fColor=(65535,0,0),valueColor=(65535,0,0)
	SetVariable IendRange,limits={-inf,inf,0},value= root:packages:AFM_Calibration:Range_Iend
	Button EditPath,pos={11.00,222.00},size={78.00,26.00},proc=ButtonProc_EditPath
	Button EditPath,title="Edit path",fColor=(65535,65535,65535)
	GroupBox groupErrors,pos={8.00,259.00},size={178.00,106.00},title="Errors"
	GroupBox groupErrors,labelBack=(49151,60031,65535)
	CheckBox check_Kequip,pos={15.00,279.00},size={123.00,15.00},proc=CheckProc_AddError2Find_k
	CheckBox check_Kequip,title=" ∆k/k (equipartition)",value= 1
	CheckBox check_KSader,pos={15.00,299.00},size={159.00,15.00},proc=CheckProc_AddError2Find_k
	CheckBox check_KSader,title=" ∆k/k (Sader or fluid-struc.)",value= 1
	CheckBox check_KdiffEqSader,pos={15.00,318.00},size={154.00,15.00},proc=CheckProc_AddError2Find_k
	CheckBox check_KdiffEqSader,title=" k (equip.) - k (Sader) | avg",value= 1
	Button Calc_k,pos={94.00,222.00},size={78.00,26.00},proc=ButtonProc_FindMinError
	Button Calc_k,title="Find min ∆k",fColor=(65535,65535,65535)
	SetVariable kequip,pos={199.00,276.00},size={111.00,18.00},bodyWidth=60
	SetVariable kequip,title="k (equip)",format="%.4g",fColor=(1,26214,0)
	SetVariable kequip,valueColor=(1,26214,0)
	SetVariable kequip,limits={0,inf,0},value= root:packages:AFM_Calibration:k_avg_Eq
	SetVariable kSader,pos={200.00,318.00},size={110.00,18.00},bodyWidth=60
	SetVariable kSader,title="k (Sader)",format="%.4g",fColor=(1,26214,0)
	SetVariable kSader,valueColor=(1,26214,0)
	SetVariable kSader,limits={0,inf,0},value= root:packages:AFM_Calibration:k_avg_Sader
	SetVariable kequip1,pos={208.00,297.00},size={102.00,18.00},bodyWidth=60
	SetVariable kequip1,title="k (n=1)",format="%.4g",fColor=(1,26214,0)
	SetVariable kequip1,valueColor=(1,26214,0)
	SetVariable kequip1,limits={0,inf,0},value= root:packages:AFM_Calibration:k_avg_Eqn1
	SetVariable kequip2,pos={208.00,339.00},size={102.00,18.00},bodyWidth=60
	SetVariable kequip2,title="k (n=1)",format="%.4g",fColor=(1,26214,0)
	SetVariable kequip2,valueColor=(1,26214,0)
	SetVariable kequip2,limits={0,inf,0},value= root:packages:AFM_Calibration:k_avg_Sadern1
	SetVariable kequipErr,pos={315.00,276.00},size={72.00,18.00},bodyWidth=60
	SetVariable kequipErr,title="±",format="%.4g",fColor=(1,26214,0)
	SetVariable kequipErr,valueColor=(1,26214,0)
	SetVariable kequipErr,limits={0,inf,0},value= root:packages:AFM_Calibration:k_avg_Eq_Err
	SetVariable kequipErr1,pos={315.00,297.00},size={72.00,18.00},bodyWidth=60
	SetVariable kequipErr1,title="±",format="%.4g",fColor=(1,26214,0)
	SetVariable kequipErr1,valueColor=(1,26214,0)
	SetVariable kequipErr1,limits={0,inf,0},value= root:packages:AFM_Calibration:k_avg_Eqn1_Err
	SetVariable kequipErr2,pos={315.00,318.00},size={72.00,18.00},bodyWidth=60
	SetVariable kequipErr2,title="±",format="%.4g",fColor=(1,26214,0)
	SetVariable kequipErr2,valueColor=(1,26214,0)
	SetVariable kequipErr2,limits={0,inf,0},value= root:packages:AFM_Calibration:k_avg_Sader_Err
	SetVariable kequipErr3,pos={315.00,339.00},size={72.00,18.00},bodyWidth=60
	SetVariable kequipErr3,title="±",format="%.4g",fColor=(1,26214,0)
	SetVariable kequipErr3,valueColor=(1,26214,0)
	SetVariable kequipErr3,limits={0,inf,0},value= root:packages:AFM_Calibration:k_avg_Sadern1_Err
	PopupMenu MinPathDirection,pos={180.00,226.00},size={27.00,19.00}
	PopupMenu MinPathDirection,mode=4,popvalue="-",value= #"\"X;Y;XY;-\""
	Button ScanXlaserMendIend,pos={132.00,157.00},size={184.00,28.00},proc=ButtonProc_ScanXlaserMend
	Button ScanXlaserMendIend,title="Scan x\\Blaser\\M & m\\Bend\\M/m\\Bc\\M & I\\Bend\\M/m\\Bc\\ML\\S2 "
	SetVariable Iend_index,pos={320.00,163.00},size={68.00,20.00},proc=SetVarProc_Iend_GetPlane
	SetVariable Iend_index,title="i(I\\Bend\\M) "
	SetVariable Iend_index,limits={0,inf,1},value= root:packages:AFM_Calibration:Iend_k
	Button ScanIendZ_Min,pos={278.00,189.00},size={110.00,28.00},proc=ButtonProc_ScanXlaserMend
	Button ScanIendZ_Min,title="Optimize I\\Bend\\M/m\\Bc\\ML\\S2"
	Button ScanIendZ_Min,fColor=(65535,49151,49151),valueColor=(65535,0,0)
	CheckBox check_Append2PSD,pos={242.00,373.00},size={94.00,15.00},proc=CheckProc_AppendkvsXlaser2PSD
	CheckBox check_Append2PSD,title="append to PSD"
	CheckBox check_Append2PSD,variable= root:packages:AFM_Calibration:DoInsetParamScan
	Button Plot,pos={54.00,368.00},size={71.00,26.00},proc=ButtonProc_PlotScanXlaserMend
	Button Plot,title="Plot",fColor=(65535,65535,65535)
	PopupMenu TypeOfPlot,pos={128.00,372.00},size={103.00,19.00},bodyWidth=97
	PopupMenu TypeOfPlot,title=" \\Zr075"
	PopupMenu TypeOfPlot,mode=1,popvalue="k vs. xlaser",value= #"\"k vs. xlaser;k vs. ξ;k vs. (xlaser,ξ)\""
	CheckBox check_mtip_positive,pos={223.00,228.00},size={38.00,15.00}
	CheckBox check_mtip_positive,title=" ξ>0"
	CheckBox check_mtip_positive,variable= root:packages:AFM_Calibration:mend2mc_positive
	Button ScanIendY_iterate,pos={10.00,190.00},size={71.00,27.00},proc=ButtonProc_ScanXMend_iterate
	Button ScanIendY_iterate,title="Iterate ξ",fColor=(65535,49151,49151)
	Button ScanIendY_iterate,valueColor=(65535,0,0)
	SetVariable EndMass_NOI,pos={89.00,194.00},size={97.00,18.00},title="num. iter."
	SetVariable EndMass_NOI,limits={0,inf,1},value= root:packages:AFM_Calibration:end_m_NOI
	CheckBox check_xlaser_iterate,pos={195.00,195.00},size={77.00,17.00}
	CheckBox check_xlaser_iterate,title=" iterate x\\Blaser"
	CheckBox check_xlaser_iterate,variable= root:packages:AFM_Calibration:xlaser_iterate
	CheckBox check_KdiffEqSadern1,pos={15.00,339.00},size={156.00,15.00},proc=CheckProc_AddError2Find_k
	CheckBox check_KdiffEqSadern1,title=" k (equip.) - k (Sader) | n=1",value= 1
	SetVariable k_error,pos={281.00,226.00},size={98.00,18.00},bodyWidth=41
	SetVariable k_error,title="Error ∆k/k",format="%.4g"
	SetVariable k_error,limits={0,inf,0},value= root:packages:AFM_Calibration:k_avg_Err	
	AutoPositionWindow/E/M=1/R=Panel_Cal PanelScanXlaserMend 

	SVAR Spectrum_type=root:packages:AFM_Calibration:Spectrum_type

	
	strswitch(Spectrum_type)
	
		case "normal":

			SetVariable mend disable=0
			SetVariable NOPmend disable=0
			SetVariable mendRange disable=0
			Button ScanMend disable=0
			SetVariable Iend title="I\\Bend\\M/m\\Bc\\ML\\S2"
			SetVariable IendRange title="∆I\\Bend\\M/m\\Bc\\ML\\S2\\M (±)"
			ModifyControl/Z ScanIendY rename=ScanIendZ, title="Scan I\\Bend\\M/m\\Bc\\ML\\S2"
					
			break
			
		case "lateral":

			SetVariable mend disable=2
			SetVariable NOPmend disable=2
			SetVariable mendRange disable=2
			Button ScanMend disable=2
			SetVariable Iend title="I\\Bend\\M/I\\Bc"
			SetVariable IendRange title="∆I\\Bend\\M/I\\Bc\\M (±)"
			ModifyControl/Z ScanIendZ rename=ScanIendY, title="Scan I\\Bend\\M/I\\Bc"
			
			break

		endswitch

End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function SetVarProc_Iend_GetPlane(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			DFREF dfSav = GetDataFolderDFR()
			DFREF dfcal=root:Packages:AFM_Calibration:
			
			SetDataFolder dfcal
			
			NVAR Iend_k
			
			Scan_xmi2xm(Iend_k)

			SetDataFolder dfSav

			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Scan_Xlaser_mend_Iend()

	DFREF dfSav = GetDataFolderDFR()
	DFREF dfcal=root:Packages:AFM_Calibration:
	
	SetDataFolder dfcal
	
	NVAR xtip
	NVAR xlaser
	NVAR Cant_length_e
	NVAR cant_width
	NVAR cant_inclination
	NVAR htip
	NVAR ytip
	NVAR tip_H_e
	NVAR mend2mc
	NVAR Iend2Ic
	
	NVAR NOP_Xlaser
	NVAR NOP_Mend
	NVAR NOP_Iend
	NVAR Range_Xlaser
	NVAR Range_mend
	NVAR Range_Iend
	
	NVAR Sz_cont
	NVAR Sy_cont
	NVAR Medium_temperature
	NVAR medium_dens
	
	SVAR Spectrum_type
	SVAR model

	wave wf0, wfvac
	wave wQ, wtau
	wave/C wG

	wave/SDFR=dfcal wPeakArea=:Results:wPeakArea
	wave/SDFR=dfcal wCn=:Results:wCn
	wave/SDFR=dfcal wDn=:Results:wDn
	
	variable NOP
	
	strswitch(Spectrum_type)
	
		case "normal":

				wave/SDFR=dfcal wkz_thermal=:Results:wkz_thermal
				make/O/N=(NOP_Xlaser, NOP_Mend, NOP_Iend) wkz_vs_xmi_avg, wkz_vs_xmi_D, wkz_vs_xmi_n1
				make/O/N=(NOP_Xlaser, NOP_Mend, NOP_Iend, numpnts(wkz_thermal)) wkz_vs_xmi, wSz_vs_xmi
				
				SetScale/I x max(xlaser-Range_Xlaser,0),min(xlaser+Range_Xlaser,1),"", wkz_vs_xmi_avg, wkz_vs_xmi_D, wkz_vs_xmi_n1
				SetScale/I x max(xlaser-Range_Xlaser,0),min(xlaser+Range_Xlaser,1),"", wSz_vs_xmi, wkz_vs_xmi

				SetScale/I y mend2mc-Range_mend,mend2mc+Range_mend,"", wkz_vs_xmi_avg, wkz_vs_xmi_D, wkz_vs_xmi_n1
				SetScale/I y mend2mc-Range_mend,mend2mc+Range_mend,"", wSz_vs_xmi, wkz_vs_xmi

				SetScale/I z Iend2Ic-Range_Iend,Iend2Ic+Range_Iend,"", wkz_vs_xmi_avg, wkz_vs_xmi_D, wkz_vs_xmi_n1
				SetScale/I z Iend2Ic-Range_Iend,Iend2Ic+Range_Iend,"", wSz_vs_xmi, wkz_vs_xmi

				wSz_vs_xmi=Sz_cont
				// 	Calc_Sz_CorrectionFactor(n, xtip,  xlaser, mend2mc, htip, inclAngle)
				// Calc_Sz_CorrectionFactor2(n, xtip, xlaser, mend2mc, Iend2Ic, htip, inclAngle)
				wSz_vs_xmi*=Calc_Sz_CorrectionFactor2(s+1, xtip, x, y, z, htip, cant_inclination)

				// convert Sz to SN
				wSz_vs_xmi*=cos(cant_inclination/180*pi)

				
				wkz_vs_xmi=kBoltz*Medium_temperature
				wkz_vs_xmi/=wPeakArea[s]/(wSz_vs_xmi)^2
				wkz_vs_xmi*=3/C_n_m_I(s+1,y,z)^4

				wkz_vs_xmi/=(xtip)^3
				
				make/O/N=(NOP_Mend, NOP_Iend) wkzSader_vs_mitip_avg, wkzSader_vs_mitip_D, wkzSader_vs_mitip_n1
				make/O/N=(NOP_Mend, NOP_Iend, numpnts(wkz_thermal)) wkzSader_vs_mitip
				
				SetScale/I x mend2mc-Range_mend,mend2mc+Range_mend,"", wkzSader_vs_mitip_avg, wkzSader_vs_mitip_D, wkzSader_vs_mitip_n1
				SetScale/I x mend2mc-Range_mend,mend2mc+Range_mend,"", wkzSader_vs_mitip

				SetScale/I y Iend2Ic-Range_Iend,Iend2Ic+Range_Iend,"", wkzSader_vs_mitip_avg, wkzSader_vs_mitip_D, wkzSader_vs_mitip_n1
				SetScale/I y Iend2Ic-Range_Iend,Iend2Ic+Range_Iend,"", wkzSader_vs_mitip

				strswitch(model)
				
					case "SFO (full)":
					case "SFO (full) vn":

						// ratio of kc to mc: kc/mc=3/Cn^4*wn^2
						wkzSader_vs_mitip=(2*pi*wfvac[r])^2*3/C_n_m_I(r+1,x,y)^4
						// multiply by mc=mf/tau
						wkzSader_vs_mitip*=pi*(cant_width/2)^2*cant_length_e*medium_dens
						wkzSader_vs_mitip/=wtau[r]
						// correct kz for tip offset
						wkzSader_vs_mitip/=(xtip)^3
					break

					default:
				
						wkzSader_vs_mitip=pi^3*medium_dens*cant_width^2*cant_length_e*wf0[r]^2*wQ[r]*imag(wG[r])
						wkzSader_vs_mitip*=3/C_n_m_I(r+1,x,y)^4
						wkzSader_vs_mitip/=(xtip)^3
						
					break
					
				endswitch
				
				wave wk=wkz_vs_xmi
				wave wk_avg=wkz_vs_xmi_avg
				wave wk_D=wkz_vs_xmi_D
				wave wk_n1=wkz_vs_xmi_n1

				wave wkSader=wkzSader_vs_mitip
				wave wkSader_avg=wkzSader_vs_mitip_avg
				wave wkSader_D=wkzSader_vs_mitip_D
				wave wkSader_n1=wkzSader_vs_mitip_n1
				
				wk_n1=wk[p][q][r][0]

			break
			
			case "lateral":

				return 0 // we only do normal for m(end) and I(end) 
				
			break
	
	endswitch

	variable i, j, k
	
	for(k=0;k<NOP_Iend;k+=1)
		for(j=0;j<NOP_Mend;j+=1)
			for(i=0;i<(NOP_Xlaser);i+=1)
				WaveStats/Q/W/RMD=[i][j][k][] wk
				wave M_WaveStats
				wk_avg[i][j][k]=M_WaveStats[3]
				wk_D[i][j][k]=M_WaveStats[4]
				//wk_D[i]=(M_WaveStats[25]-M_WaveStats[24])/2
			endfor
		endfor
	endfor

	// normalize st. dev.
	// wk_D/=wk_avg

	wkSader_n1=wkSader[p][q][0]
	
	for(k=0;k<NOP_Iend;k+=1)
		for(j=0;j<NOP_Mend;j+=1)
			WaveStats/Q/W/RMD=[j][k][] wkSader
			wave M_WaveStats
			wkSader_avg[j][k]=M_WaveStats[3]
			wkSader_D[j][k]=M_WaveStats[4]
			//wk_D[j][k]=(M_WaveStats[25]-M_WaveStats[24])/2
		endfor
	endfor

	// normalize st. dev.
	// wkSader_D/=wkSader_avg

	Duplicate/O wk_avg, wk_delEqSader
	
	wk_delEqSader-=wkSader[q][r]
	wk_delEqSader=abs(wk_delEqSader)
	
	// normalize error (k_Sader - k_equip)
	// wk_delEqSader/=(wk_avg+wkSader[q])/2

	Duplicate/O wk_n1, wk_n1_delEqSader
	
	wk_n1_delEqSader-=wkSader_n1[q][r]
	wk_n1_delEqSader=abs(wk_n1_delEqSader)

	// normalize error (k_Sader - k_equip)
	// wk_n1_delEqSader/=(wk_n1+wkSader_n1[q])/2

	SetDataFolder dfSav

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Scan_Iend_Min()


	DFREF dfSav = GetDataFolderDFR()
	DFREF dfcal=root:Packages:AFM_Calibration:
	
	SetDataFolder dfcal

	NVAR k_avg_Eq, k_avg_Eq_Err
	NVAR k_avg_Sader, k_avg_Sader_Err
	NVAR k_avg_Eqn1, k_avg_Eqn1_Err
	NVAR k_avg_Sadern1, k_avg_Sadern1_Err
	
	NVAR Iend2Ic
	NVAR mend2mc
	NVAR xlaser
	
	NVAR cant_Xlaser
	NVAR cant_length

	NVAR iend_k

	wave/Z wkz_vs_xmi
	
	SVAR S_ErrorKey
	
	if(WaveExists(wkz_vs_xmi)==0)
		return 1
	endif
	
	variable i0, id, NOP
	
	i0=DimOffset(wkz_vs_xmi,2)
	id=DimDelta(wkz_vs_xmi,2)
	
	NOP=DimSize(wkz_vs_xmi,2)

	make/O/N=(NOP) wkz_avg_Eq_I, wkz_avg_Eq_Err_I
	make/O/N=(NOP) wkz_avg_Sader_I, wkz_avg_Sader_Err_I
	make/O/N=(NOP) wkz_avg_Eqn1_I, wkz_avg_Eqn1_Err_I
	make/O/N=(NOP) wkz_avg_Sadern1_I, wkz_avg_Sadern1_Err_I
	make/O/N=(NOP) wkz_avg_mend_I, wkz_avg_xlaser_I
	
	
	SetScale/P x i0,id,"", wkz_avg_Eq_I, wkz_avg_Eq_Err_I, wkz_avg_Sader_I, wkz_avg_Sader_Err_I
	SetScale/P x i0,id,"", wkz_avg_Eqn1_I, wkz_avg_Eqn1_Err_I, wkz_avg_Sadern1_I, wkz_avg_Sadern1_Err_I
	SetScale/P x i0,id,"", wKz_avg_mend_I, wkz_avg_xlaser_I
		
	variable i=0
	
	for(i=0;i<NOP;i+=1)
		Scan_xmi2xm(i)
		wkz_avg_Eq_I[i]=	k_avg_Eq
		wkz_avg_Eq_Err_I[i]=k_avg_Eq_Err
		wkz_avg_Sader_I[i]=k_avg_Sader
		wkz_avg_Sader_Err_I[i]=k_avg_Sader_Err
		wkz_avg_Eqn1_I[i]=k_avg_Eqn1
		wkz_avg_Eqn1_Err_I[i]=k_avg_Eqn1_Err
		wkz_avg_Sadern1_I[i]=k_avg_Sadern1
		wkz_avg_Sadern1_Err_I[i]=k_avg_Sadern1_Err
		
		wKz_avg_mend_I[i]=mend2mc
		wkz_avg_xlaser_I[i]=xlaser
		
	endfor


// find global error min

	Duplicate/O wkz_avg_Eq_Err_I, wk_del
	wave wk_del
	
	variable AddError
	
	wk_del=1
	i=0
	
	AddError=NumberByKey("Kequip", S_ErrorKey)
	
	if(AddError)
		wk_del*=wkz_avg_Eq_Err_I/wkz_avg_Eq_I
		i+=1
	endif
	
	AddError=NumberByKey("KSader", S_ErrorKey)
	
	if(AddError)
		wk_del*=wkz_avg_Sader_Err_I/wkz_avg_Sader_I
		i+=1
	endif
	
	AddError=NumberByKey("KdiffEqSader", S_ErrorKey)
	
	if(AddError)
		wk_del*=abs(wkz_avg_Eq_I-wkz_avg_Sader_I)/((wkz_avg_Eq_I+wkz_avg_Sader_I)/2)
		i+=1
	endif
	
	AddError=NumberByKey("KdiffEqSadern1", S_ErrorKey)
	
	if(AddError)
		wk_del*=abs(wkz_avg_Eqn1_I-wkz_avg_Sadern1_I)/((wkz_avg_Eqn1_I+wkz_avg_Sadern1_I)/2)
		i+=1
	endif
						
	wk_del=(wk_del)^(1/i)

	// 20210112 - wjl compatability check
	NVAR/Z mend2mc_positive
	if(!NVAR_Exists(mend2mc_positive))
		Variable/G mend2mc_positive = 1
	endif

	if(mend2mc_positive==1)
		WaveStats/Q/R=(0,Inf) wk_del
	else
		WaveStats/Q wk_del
	endif

// end find global error min


//	waveStats/Q wkz_avg_Eq_Err_I
	iend_k=V_minRowLoc
	Iend2Ic=V_minLoc

	Scan_xmi2xm(iend_k)
	
	variable pMin=V_minRowLoc
	variable pRange=1
	
	CurveFit/Q/M=2/W=0 poly 3, wk_del[pMin-pRange,pMin+pRange] /D
	
	wave fit_wk_del
	WaveStats/Q fit_wk_del
	Iend2Ic=V_minLoc

	mend2mc=wKz_avg_mend_I(Iend2Ic)
	xlaser=wkz_avg_xlaser_I(Iend2Ic)
	

	k_avg_Eq=wkz_avg_Eq_I(Iend2Ic)
	k_avg_Eq_Err=wkz_avg_Eq_Err_I(Iend2Ic)
	k_avg_Sader=wkz_avg_Sader_I(Iend2Ic)
	k_avg_Sader_Err=wkz_avg_Sader_Err_I(Iend2Ic)
	k_avg_Eqn1=wkz_avg_Eqn1_I(Iend2Ic)
	k_avg_Eqn1_Err=wkz_avg_Eqn1_Err_I(Iend2Ic)
	k_avg_Sadern1=wkz_avg_Sadern1_I(Iend2Ic)
	k_avg_Sadern1_Err=wkz_avg_Sadern1_Err_I(Iend2Ic)

	cant_Xlaser=cant_length*xlaser

//	DoUpdate
//	Calc_Results(0)

	DoWindow/F Graphk_Itip
	if(V_flag==1)
		Checkdisplayed/W=Graphk_Itip wkz_avg_Eq_I 
		if(V_flag==0)
			KillWindow/Z Graphk_Itip
			Graph_k_vs_Itip(wkz_avg_Eq_I, wkz_avg_Eq_Err_I, wkz_avg_Eqn1_I, wkz_avg_Sader_I, wkz_avg_Sader_Err_I, wkz_avg_Sadern1_I, "z")
		endif
	else
		Graph_k_vs_Itip(wkz_avg_Eq_I, wkz_avg_Eq_Err_I, wkz_avg_Eqn1_I, wkz_avg_Sader_I, wkz_avg_Sader_Err_I, wkz_avg_Sadern1_I, "z")
	endif

	SetDataFolder dfSav

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Graph_k_vs_Itip(wk_avg, wk_D, wk_n1, wkSader_avg, wkSader_D, wkSader_n1, type)
	wave wk_avg, wk_D, wk_n1, wkSader_avg, wkSader_D, wkSader_n1
	string type

	String fldrSav0= GetDataFolder(1)
	
	Display/K=1 /W=(352.5,205.25,912,584) wk_avg, wk_n1
	AppendToGraph wkSader_avg, wkSader_n1

	DoWindow/C Graphk_Itip
	
	SetDataFolder fldrSav0
	ModifyGraph width={Aspect,1.5},height=288
	ModifyGraph lSize=2
	ModifyGraph lStyle($NameOfWave(wk_n1))=3
	ModifyGraph lStyle($NameOfWave(wkSader_n1))=3
	ModifyGraph mirror=2
	ModifyGraph minor=1
	ModifyGraph fSize=20
	ModifyGraph lowTrip(bottom)=0.0001

	ModifyGraph rgb($NameOfWave(wkSader_avg))=(0,0,65535),rgb($NameOfWave(wkSader_n1))=(0,0,65535)

	strswitch(type)
	
		case "z":
		
			Label left "Spring constant k\\B"+type+",s\\M (N/m)"
			Label bottom "End moment of inertia ξ\\Bend"
		
		break
			
		case "θ":
		
			Label left "Spring constant k\\B"+type+",s\\M (N/rad)"
			Label bottom "End moment of inertia ξ\\Bend"
		
		break
		
	endswitch

	ErrorBars $NameOfWave(wk_avg) SHADE= {0,0,(65535,54611,49151),(0,0,0,0)},wave=(wk_D,wk_D)
	ErrorBars $NameOfWave(wkSader_avg) SHADE= {0,4,(0,0,0,0),(0,0,0,0)},wave=(wkSader_D,wkSader_D)
	
	string S_legend="\\Z12Equipartition:\r\\s("+NameOfWave(wk_n1)+") k\\B"+type+",s\\M\\Z12 (n=1)\r\\s("+NameOfWave(wk_avg)+") k\\B"+type+",s\\M\\Z12 (avg)\r"
	S_legend+="Sader:\r\\s("+NameOfWave(wkSader_n1)+") k\\B"+type+",s\\M\\Z12 (n=1)\r\\s("+NameOfWave(wkSader_avg)+") k\\B"+type+",s\\M\\Z12 (avg)"
	Legend/C/N=text0/J/F=0/A=MC/X=-38/Y=32 S_legend
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
// Select 2D plane with index k (scan vs xlaser and mend)
// from the 3D wave (scan versus xlaser, mend, and Iend)
// Select correspondinf 1D wave from 2D wave
// for Sader k (scan versus mend and Iend, no xlaser dependence)
Function Scan_xmi2xm(k)
	variable k

	DFREF dfSav = GetDataFolderDFR()
	DFREF dfcal=root:Packages:AFM_Calibration:
	
	SetDataFolder dfcal
	
	NVAR Iend2Ic

	wave/Z wk=wkz_vs_xmi
	
	if(WaveExists(wk)==0)
		return 0
	endif
	
	wave wk_avg=wkz_vs_xmi_avg
	wave wk_D=wkz_vs_xmi_D
	wave wk_n1=wkz_vs_xmi_n1

	wave wkSader=wkzSader_vs_mitip
	wave wkSader_avg=wkzSader_vs_mitip_avg
	wave wkSader_D=wkzSader_vs_mitip_D
	wave wkSader_n1=wkzSader_vs_mitip_n1

	if(k>=DimSize(wk,2))
		return 0
	endif

	variable NOP0=DimSize(wk,0)
	variable NOP1=DimSize(wk,1)
	variable NOP2=DimSize(wk,3)

	Iend2Ic=DimOffset(wk,2)+DimDelta(wk,2)*k

	make/O/N=(NOP0, NOP1) wkz_vs_xm_avg, wkz_vs_xm_D, wkz_vs_xm_n1
	make/O/N=(NOP0, NOP1, NOP2) wkz_vs_xm
	
	CopyScales/I wk_avg, wkz_vs_xm_avg, wkz_vs_xm_D, wkz_vs_xm_n1
	CopyScales/I wk, wkz_vs_xm
	
	make/O/N=(NOP0) wkzSader_vs_mtip_avg, wkzSader_vs_mtip_D, wkzSader_vs_mtip_n1
	make/O/N=(NOP0, NOP2) wkzSader_vs_mtip

	CopyScales/I wkSader_avg, wkzSader_vs_mtip_avg, wkzSader_vs_mtip_D, wkzSader_vs_mtip_n1
	CopyScales/I wkSader, wkzSader_vs_mtip
	
	wkz_vs_xm=wk[p][q][k][r]
	wkz_vs_xm_avg=wk_avg[p][q][k]
	wkz_vs_xm_D=wk_D[p][q][k]
	wkz_vs_xm_n1=wk_n1[p][q][k]
	
	wkzSader_vs_mtip=wkSader[p][k][q]
	wkzSader_vs_mtip_avg=wkSader_avg[p][k]
	wkzSader_vs_mtip_D=wkSader_D[p][k]
	wkzSader_vs_mtip_n1=wkSader_n1[p][k]

	FindMinError(0)

	SetDataFolder dfSav

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Scan_Xlaser_mend()

	DFREF dfSav = GetDataFolderDFR()
	DFREF dfcal=root:Packages:AFM_Calibration:
	
	SetDataFolder dfcal
	
	NVAR xtip
	NVAR xlaser
	NVAR Cant_length_e
	NVAR cant_width
	NVAR cant_inclination
	NVAR htip
	NVAR ytip
	NVAR tip_H_e
	NVAR mend2mc
	NVAR Iend2Ic
	
	NVAR NOP_Xlaser
	NVAR NOP_Mend
	NVAR NOP_Iend
	NVAR Range_Xlaser
	NVAR Range_mend
	NVAR Range_Iend
	
	NVAR Sz_cont
	NVAR Sy_cont
	NVAR Medium_temperature
	NVAR medium_dens
	
	SVAR Spectrum_type
	SVAR model

	wave wf0, wfvac
	wave wQ, wtau
	wave/C wG

	wave/SDFR=dfcal wPeakArea=:Results:wPeakArea
	wave/SDFR=dfcal wCn=:Results:wCn
	wave/SDFR=dfcal wDn=:Results:wDn
	
	variable NOP
	
	strswitch(Spectrum_type)
	
		case "normal":

				//
				// process thermal method
				//
				wave/SDFR=dfcal wkz_thermal=:Results:wkz_thermal
				make/O/N=(NOP_Xlaser, NOP_Mend) wkz_vs_xm_avg, wkz_vs_xm_D, wkz_vs_xm_n1
				make/O/N=(NOP_Xlaser, NOP_Mend, numpnts(wkz_thermal)) wkz_vs_xm, wSz_vs_xm
				
				SetScale/I x max(xlaser-Range_Xlaser,0),min(xlaser+Range_Xlaser,1),"", wkz_vs_xm_avg, wkz_vs_xm_D, wkz_vs_xm_n1
				SetScale/I x max(xlaser-Range_Xlaser,0),min(xlaser+Range_Xlaser,1),"", wSz_vs_xm, wkz_vs_xm

				SetScale/I y mend2mc-Range_mend,mend2mc+Range_mend,"", wkz_vs_xm_avg, wkz_vs_xm_D, wkz_vs_xm_n1
				SetScale/I y mend2mc-Range_mend,mend2mc+Range_mend,"", wSz_vs_xm, wkz_vs_xm

				wSz_vs_xm=Sz_cont
				
				if(Iend2Ic==0)
					// Calc_Sz_CorrectionFactor(n, xtip, xlaser, mend2mc, htip, inclAngle)
					//variable t0=ticks
					wSz_vs_xm*=Calc_Sz_CorrectionFactor(r+1, xtip, x, y, htip, cant_inclination)
					//print "time to calc Sz = ", (ticks - t0)/60, "sec"				
				else
					// Calc_Sz_CorrectionFactor2(n, xtip, xlaser, mend2mc, Iend2Ic, htip, inclAngle)
					//variable t0=ticks
					wSz_vs_xm*=Calc_Sz_CorrectionFactor2(r+1, xtip, x, y, Iend2Ic, htip, cant_inclination)
					//print "time to calc Sz = ", (ticks - t0)/60, "sec"
				endif

				
				// convert Sz to SN
				wSz_vs_xm*=cos(cant_inclination/180*pi)

				wkz_vs_xm=kBoltz*Medium_temperature
				wkz_vs_xm/=wPeakArea[r]/wSz_vs_xm^2

				if(Iend2Ic==0)
					wkz_vs_xm*=3/C_n_m(r+1,y)^4
				else
					wkz_vs_xm*=3/C_n_m_I(r+1,y, Iend2Ic)^4
				endif

				// correct kz for tip offset
				wkz_vs_xm/=(xtip)^3
				
				//
				// process Sader method
				//
				make/O/N=(NOP_Mend) wkzSader_vs_mtip_avg, wkzSader_vs_mtip_D, wkzSader_vs_mtip_n1
				make/O/N=(NOP_Mend, numpnts(wkz_thermal)) wkzSader_vs_mtip
				
				SetScale/I x mend2mc-Range_mend,mend2mc+Range_mend,"", wkzSader_vs_mtip_avg, wkzSader_vs_mtip_D, wkzSader_vs_mtip_n1
				SetScale/I x mend2mc-Range_mend,mend2mc+Range_mend,"", wkzSader_vs_mtip

				strswitch(model)
				
					case "SFO (full)":
					case "SFO (full) vn":

						// ratio of kc to mc: kc/mc=3/Cn^4*wn^2
						wkzSader_vs_mtip=(2*pi*wfvac[q])^2
						// ** DO AFTER SWITCH ** wkzSader_vs_mtip*=3/C_n_m_I(q+1,x, Iend2Ic)^4
						// multiply by mc=mf/tau
						wkzSader_vs_mtip*=pi*(cant_width/2)^2*cant_length_e*medium_dens
						wkzSader_vs_mtip/=wtau[q]
					break

					default:
				
						wkzSader_vs_mtip=pi^3*medium_dens*cant_width^2*cant_length_e*wf0[q]^2*wQ[q]*imag(wG[q])
						// ** DO AFTER SWITCH ** wkzSader_vs_mtip*=3/C_n_m_I(q+1,x, Iend2Ic)^4
						
					break
					
				endswitch
				
				//wkzSader_vs_mtip*=3/C_n_m_I(q+1,x, Iend2Ic)^4
				if(Iend2Ic==0)
					wkzSader_vs_mtip*=3/C_n_m(q+1,x)^4
				else
					wkzSader_vs_mtip*=3/C_n_m_I(q+1,x, Iend2Ic)^4
				endif
				// correct kz for tip offset
				wkzSader_vs_mtip/=xtip^3

				wave wk=wkz_vs_xm
				wave wk_avg=wkz_vs_xm_avg
				wave wk_D=wkz_vs_xm_D
				wave wk_n1=wkz_vs_xm_n1

				wave wkSader=wkzSader_vs_mtip
				wave wkSader_avg=wkzSader_vs_mtip_avg
				wave wkSader_D=wkzSader_vs_mtip_D
				wave wkSader_n1=wkzSader_vs_mtip_n1
				
				NOP=NOP_Mend

			break
			
			case "lateral":

				wave/SDFR=dfcal wktheta_thermal=:Results:wktheta_thermal
				make/O/N=(NOP_Xlaser, NOP_Iend) wktheta_vs_xm_avg, wktheta_vs_xm_D, wktheta_vs_xm_n1
				make/O/N=(NOP_Xlaser, NOP_Iend, numpnts(wktheta_thermal)) wktheta_vs_xm, wStheta_vs_xm
				
				SetScale/I x max(xlaser-Range_Xlaser,0),min(xlaser+Range_Xlaser,1),"", wktheta_vs_xm_avg, wktheta_vs_xm_D, wktheta_vs_xm_n1
				SetScale/I x max(xlaser-Range_Xlaser,0),min(xlaser+Range_Xlaser,1),"", wStheta_vs_xm, wktheta_vs_xm

				SetScale/I y Iend2Ic-Range_Iend,Iend2Ic+Range_Iend,"", wktheta_vs_xm_avg, wktheta_vs_xm_D, wktheta_vs_xm_n1
				SetScale/I y Iend2Ic-Range_Iend,Iend2Ic+Range_Iend,"", wStheta_vs_xm, wktheta_vs_xm

				wStheta_vs_xm=Sy_cont*tip_H_e*sqrt(1+ytip^2)*xtip/xlaser
				// 	Calc_Sy_CorrectionFactor(n, xlaser, Iend2Ic)
				wStheta_vs_xm*=Calc_Sy_CorrectionFactor(r+1, x, y)
				
				wktheta_vs_xm=kBoltz*Medium_temperature
				wktheta_vs_xm/=wPeakArea[r]/(wStheta_vs_xm)^2
				wktheta_vs_xm*=1/D_n_m(r+1,y)^2

				wktheta_vs_xm/=xtip
				
				make/O/N=(NOP_Iend) wkthetaSader_vs_mtip_avg, wkthetaSader_vs_mtip_D, wkthetaSader_vs_mtip_n1
				make/O/N=(NOP_Iend, numpnts(wktheta_thermal)) wkthetaSader_vs_mtip
				
				SetScale/I x Iend2Ic-Range_mend,Iend2Ic+Range_mend,"", wkthetaSader_vs_mtip_avg, wkthetaSader_vs_mtip_D, wkthetaSader_vs_mtip_n1
				SetScale/I x Iend2Ic-Range_mend,Iend2Ic+Range_mend,"", wkthetaSader_vs_mtip

				strswitch(model)
				
					case "SFO (full)":
					case "SFO (full) vn":

						// ratio of kc to mc: kc/mc=3/Cn^4*wn^2
						wkthetaSader_vs_mtip=(2*pi*wfvac[q])^2*1/D_n_m(q+1,x)^2
						// multiply by Ic=If/tau
						wkthetaSader_vs_mtip*=pi*(cant_width/2)^2*cant_length_e*medium_dens*cant_width^2/8
						wkthetaSader_vs_mtip/=wtau[q]
						// correct ktheta for tip offset
						// wkthetaSader_vs_mtip/=xtip
					break

					default:
				
						wkthetaSader_vs_mtip=pi^3/8*medium_dens*cant_width^4*cant_length_e*wf0[q]^2*wQ[q]*imag(wG[q])
						wkthetaSader_vs_mtip*=1/D_n_m(q+1,x)^2
						// wkthetaSader_vs_mtip/=xtip
						
					break
					
				endswitch

				// correct ktheta for tip offset
				wkthetaSader_vs_mtip/=xtip

				wave wk=wktheta_vs_xm
				wave wk_avg=wktheta_vs_xm_avg
				wave wk_D=wktheta_vs_xm_D
				wave wk_n1=wktheta_vs_xm_n1

				wave wkSader=wkthetaSader_vs_mtip
				wave wkSader_avg=wkthetaSader_vs_mtip_avg
				wave wkSader_D=wkthetaSader_vs_mtip_D
				wave wkSader_n1=wkthetaSader_vs_mtip_n1

				NOP=NOP_Iend

			break
	
	endswitch

	wk_n1=wk[p][q][0]

	variable i, j
	
	for(j=0;j<NOP;j+=1)
		for(i=0;i<(NOP_Xlaser);i+=1)
			WaveStats/Q/W/RMD=[i][j][] wk
			wave M_WaveStats
			wk_avg[i][j]=M_WaveStats[3]
			wk_D[i][j]=M_WaveStats[4]
			//wk_D[i]=(M_WaveStats[25]-M_WaveStats[24])/2
		endfor
	endfor

	// normalize st. dev.
	// wk_D/=wk_avg

	wkSader_n1=wkSader[p][0]
	
	for(i=0;i<NOP;i+=1)
		WaveStats/Q/W/RMD=[i][] wkSader
		wave M_WaveStats
		wkSader_avg[i]=M_WaveStats[3]
		wkSader_D[i]=M_WaveStats[4]
		//wk_D[i]=(M_WaveStats[25]-M_WaveStats[24])/2
	endfor

	// normalize st. dev.
	// wkSader_D/=wkSader_avg

	Duplicate/O wk_avg, wk_delEqSader
	
	wk_delEqSader-=wkSader[q]
	wk_delEqSader=abs(wk_delEqSader)
	
	// normalize error (k_Sader - k_equip)
	// wk_delEqSader/=(wk_avg+wkSader[q])/2

	Duplicate/O wk_n1, wk_n1_delEqSader
	
	wk_n1_delEqSader-=wkSader_n1[q]
	wk_n1_delEqSader=abs(wk_n1_delEqSader)

	// normalize error (k_Sader - k_equip)
	// wk_n1_delEqSader/=(wk_n1+wkSader_n1[q])/2

	FindMinError(1)

	strswitch(Spectrum_type)
	
		case "normal":

			wave wk_del=wkz_vs_xm_del
			
		break
		
		case "lateral":

			wave wk_del=wktheta_vs_xm_del
			
		break

	endswitch

	wave Path_MinDX, Path_MinDY
	wave PminDX, PminDY

	DoWindow/F Graphk_xm
	
	if(V_flag==0)
		Graph_kavg_AND_Deltak_VS_xm(wk_avg, wk_del, Path_MinDX, Path_MinDY, PminDX, PminDY)
	endif

	SetDataFolder dfSav

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function/C Scan_forMinPath(w_D, w_avg, Dim, mend_positive)
	wave w_D, w_avg
	variable Dim, mend_positive
	
	variable pRange=1
	make/O/N=1 PminDX, PminDY
	variable pMin, qMin
	variable NOP

	switch(Dim)
	
		case 0:
		case 1:
		
			pRange=1
			
			variable j
			NOP=DimSize(w_D,Dim)
			
			make/O/N=(DimSize(w_D,Dim)) Path_MinD1
			SetScale/P x, DimOffset(w_D,Dim), DimDelta(w_D,Dim), Path_MinD1
			Path_MinD1=x
			
			make/O/N=(DimSize(w_D,Dim)) Path_MinD0, Path_MinD, Path_avg_MinD, Path_MinDS
			
		
			if(Dim==0)
				WaveStats/RMD=[0][]/Q w_D
				Path_MinD0[0]=V_minColLoc
			else
				WaveStats/RMD=[][0]/Q w_D
				Path_MinD0[0]=V_minRowLoc
			endif
			
			Path_MinDS[0]=0
		
			for(j=1;j<NOP;j+=1)
			
				if(Dim==0)
					WaveStats/RMD=[j][]/Q w_D
					Path_MinD0[j]=V_minColLoc
				else
					WaveStats/RMD=[][j]/Q w_D
					Path_MinD0[j]=V_minRowLoc
				endif
				
				Path_MinDS[j]=Path_MinDS[j-1]
				Path_MinDS[j]+=sqrt((Path_MinD0[j]-Path_MinD0[j-1])^2+(Path_MinD1[j]-Path_MinD1[j-1])^2)
			
			endfor
		
			if(Dim==0)
				Duplicate/O Path_MinD0, Path_MinDY
				Duplicate/O Path_MinD1, Path_MinDX
			else
				Duplicate/O Path_MinD0, Path_MinDX
				Duplicate/O Path_MinD1, Path_MinDY
			endif
		
			Smooth 1, Path_MinDX,Path_MinDY
			Path_avg_MinD=w_avg(Path_MinDX)(Path_MinDY)
			Path_MinD=w_D(Path_MinDX)(Path_MinDY)
			
			
			//WaveStats/Q/P Path_MinD
			// For end mass include only positive values
			if(mend_positive)
				WaveStats/Q/P/R=[NOP/2] Path_MinD
			else
				WaveStats/Q/P Path_MinD
			endif
			pMin=V_minRowLoc
			
			CurveFit/Q/M=2/W=0 poly 3, Path_MinD[pMin-pRange,pMin+pRange]/X=Path_MinDX[pMin-pRange,pMin+pRange] /D
			
			wave fit_Path_MinD
			WaveStats/Q fit_Path_MinD
			PminDX=V_minLoc
			
			// For end mass include only positive values
			if(mend_positive)
				WaveStats/Q/P/R=[NOP/2] Path_MinD
			else
				WaveStats/Q/P Path_MinD
			endif
			pMin=V_minRowLoc

		 	CurveFit/Q/M=2/W=0 poly 3, Path_MinD[pMin-pRange,pMin+pRange]/X=Path_MinDY[pMin-pRange,pMin+pRange] /D
			
			wave fit_Path_MinD
			WaveStats/Q fit_Path_MinD
			PminDY=V_minLoc
			
			DoWindow/F Graphk_xm
			if(V_flag==1)
				CheckDisplayed/W=Graphk_xm Path_MinDY
				if(V_flag==0)
					AppendToGraph/W=Graphk_xm Path_MinDY vs Path_MinDX
					ModifyGraph lSize(Path_MinDY)=5
					ModifyGraph lStyle(Path_MinDY)=8
				endif
			endif

			break
		
		case 2:
		
			pRange=2
			
//			Limit range to positive end mass assuming
//			the wave scaling is centered at 0
			NOP=DimSize(w_D,1)			
			if(mend_positive)
				WaveStats/Q/P/RMD=[][NOP/2,*] w_D
			else
				WaveStats/Q/P w_D
			endif
			pMin=V_minRowLoc
			qMin=V_minColLoc
			CurveFit/Q/M=2/W=0 poly2D 4, w_D[pMin-pRange,pMin+pRange][qMin-pRange,qMin+pRange] /D		
	
			wave wfit=$("fit_"+NameOfWave(w_D))
			WaveStats/Q wfit
			PminDX=V_minRowLoc
			PminDY=V_minColLoc		
		
			DoWindow/F Graphk_xm
			if(V_flag==1)
				CheckDisplayed/W=Graphk_xm wfit
				if(V_flag==1)
					RemoveContour/W=Graphk_xm $("fit_"+NameOfWave(w_D))
				endif
				RemoveFromGraph/W=Graphk_xm/Z Path_MinDY
			endif

			break
		
		case 3:
		
			pRange=2
			
//			Limit range to positive end mass assuming
//			the wave scaling is centered at 0
			NOP=DimSize(w_D,1)			
			if(mend_positive)
				WaveStats/Q/RMD=[][NOP/2,*] w_D
			else
				WaveStats/Q w_D
			endif
			PminDX=V_minRowLoc
			PminDY=V_minColLoc		
		
			DoWindow/F Graphk_xm
			if(V_flag==1)
				RemoveFromGraph/W=Graphk_xm/Z Path_MinDY
			endif

			break

	endswitch

//	print "(xlaser,ξend) min =", "(", PminDX[0], ",", PminDY[0], ")"
//	print "k(avg) =", w_avg(PminDX[0])(PminDY[0]), "N/m"

	return cmplx(PminDX[0],PminDY[0])

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Graph_kavg_AND_Deltak_VS_xm(wk_avg, wk_D, Path_MinDX, Path_MinDY, PminDX, PminDY)
	wave wk_avg, wk_D, Path_MinDX, Path_MinDY, PminDX, PminDY

	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:packages:AFM_Calibration:
	wave Path_MinD

	Display/K=1 /W=(998.25,60.5,1499.25,561.5)
	DoWindow/C Graphk_xm
	
	AppendImage/G=1 wk_avg
	ModifyImage ''#0 ctab= {*,*,Grays,0}
	AppendMatrixContour $NameOfWave(wk_D)
//	AppendMatrixContour wk_D
	ControlInfo/W=PanelScanXlaserMend MinPathDirection
	if(V_Value<3)
		AppendToGraph Path_MinDY vs Path_MinDX
		ModifyGraph lSize(Path_MinDY)=5
		ModifyGraph lStyle(Path_MinDY)=8
		// comment out 4 lines below to plot dashed red curve instead of colored circles
	//	ModifyGraph mode(Path_MinDY)=3
	//	ModifyGraph marker(Path_MinDY)=19
	//	ModifyGraph useMrkStrokeRGB(Path_MinDY)=1
	//	ModifyGraph zColor(Path_MinDY)={Path_MinD,*,*,Bathymetry9,1}
		
	endif

	AppendToGraph PminDY vs PminDX
//	ModifyContour wkz_vs_xm_D labels=0
	ModifyContour ''#0 labels=0
	ModifyContour ''#0 autoLevels={*,*,19}

	SetDataFolder fldrSav0

	ModifyGraph margin(left)=57,margin(bottom)=57,margin(top)=21,margin(right)=21,width=432
	ModifyGraph height={Aspect,1}


	ModifyGraph mode(PminDY)=3
	ModifyGraph rgb(PminDY)=(3,52428,1)
	ModifyGraph msize(PminDY)=10
	ModifyGraph mrkThick(PminDY)=3

	ModifyGraph mirror=2
	ModifyGraph nticks=4
	ModifyGraph minor=1
	ModifyGraph fSize=20
	ModifyGraph lowTrip=0.01
	ModifyGraph standoff=0
	ModifyGraph lblLatPos(left)=2
	ModifyGraph tkLblRot(left)=90
	ModifyGraph btLen=3
	ModifyGraph tlOffset=-2
	Label left "End mass ξ\\Bend"
	Label bottom "Laser spot position x\\Blaser"

End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Scan_mend()

	DFREF dfSav = GetDataFolderDFR()
	DFREF dfcal=root:Packages:AFM_Calibration:
	
	SetDataFolder dfcal
	
	NVAR xtip
	NVAR xlaser
	NVAR cant_length_e
	NVAR cant_width
	NVAR cant_inclination

	NVAR mend2mc
	NVAR Iend2Ic

	NVAR tip_H_e
	NVAR htip
	NVAR ytip
	
	NVAR medium_dens
	NVAR Medium_temperature
		
	NVAR Sz_cont
	NVAR Sy_cont
	
	SVAR Spectrum_type
	SVAR model
	
	wave wf0
	wave wfvac
	wave wQ
	wave wtau
	wave/C wG

	wave/SDFR=dfcal wPeakArea=:Results:wPeakArea
	wave/SDFR=dfcal wCn=:Results:wCn
	wave/SDFR=dfcal wDn=:Results:wDn
	
	SVAR S_ErrorKey

	NVAR k_avg_Eq, k_avg_Eq_Err
	NVAR k_avg_Sader, k_avg_Sader_Err
	NVAR k_avg_Eqn1, k_avg_Eqn1_Err
	NVAR k_avg_Sadern1, k_avg_Sadern1_Err

	string type
	
	strswitch(Spectrum_type)
	
		case "normal":

				NVAR NOP=NOP_mend
				NVAR range=Range_mend

				wave/SDFR=dfcal wkz_thermal=:Results:wkz_thermal
				make/O/N=(NOP) wkz_vs_mtip_avg, wkz_vs_mtip_D, wkz_vs_mtip_n1
				make/O/N=(NOP) wkzSader_vs_mtip_avg, wkzSader_vs_mtip_D, wkzSader_vs_mtip_n1
				make/O/N=(NOP, numpnts(wkz_thermal)) wkz_vs_mtip, wSz_vs_mtip, wkzSader_vs_mtip
				
				SetScale/I x mend2mc-range,mend2mc+range,"", wkz_vs_mtip_avg, wkz_vs_mtip_D, wkz_vs_mtip_n1
				SetScale/I x mend2mc-range,mend2mc+range,"", wSz_vs_mtip, wkz_vs_mtip
				
				
				SetScale/I x mend2mc-range,mend2mc+range,"", wkzSader_vs_mtip_avg, wkzSader_vs_mtip_D, wkzSader_vs_mtip_n1
				SetScale/I x mend2mc-range,mend2mc+range,"", wkzSader_vs_mtip
	
				wSz_vs_mtip=Sz_cont
				// 	Calc_Sz_CorrectionFactor(Current_peak, xtip,  xlaser,mend2mc, htip, cant_inclination)
				// wSz_vs_mtip*=Calc_Sz_CorrectionFactor(q+1, xtip, xlaser, x, htip, cant_inclination)
				// Calc_Sz_CorrectionFactor2(n, xtip, xlaser, mend2mc, Iend2Ic, htip, inclAngle)
				wSz_vs_mtip*=Calc_Sz_CorrectionFactor2(q+1, xtip, xlaser, x, Iend2Ic, htip, cant_inclination)
				
				// convert Sz to SN
				wSz_vs_mtip*=cos(cant_inclination/180*pi)

				wkz_vs_mtip=kBoltz*Medium_temperature
				wkz_vs_mtip/=wPeakArea[q]/(wSz_vs_mtip)^2
				wkz_vs_mtip*=3/C_n_m_I(q+1,x,Iend2Ic)^4
			
				wkz_vs_mtip/=(xtip)^3
				
				strswitch(model)
				
					case "SFO (full)":
					case "SFO (full) vn":

						// ratio of kc to mc: kc/mc=3/Cn^4*wn^2
						
						wkzSader_vs_mtip=(2*pi*wfvac[q])^2*3/C_n_m_I(q+1,x,Iend2Ic)^4
						// multiply by mc=mf/tau
						wkzSader_vs_mtip*=pi*(cant_width/2)^2*cant_length_e*medium_dens
						wkzSader_vs_mtip/=wtau[q]
						// correct kz for tip offset
						wkzSader_vs_mtip/=(xtip)^3
					break

					default:
				
						wkzSader_vs_mtip=pi^3*medium_dens*cant_width^2*cant_length_e*wf0[q]^2*wQ[q]*imag(wG[q])
						wkzSader_vs_mtip*=3/C_n_m_I(q+1,x,Iend2Ic)^4
						wkzSader_vs_mtip/=(xtip)^3
						
					break
					
				endswitch

				wave wk_vs_mtip=wkz_vs_mtip
				wave wk_avg=wkz_vs_mtip_avg
				wave wk_D=wkz_vs_mtip_D
				wave wk_n1=wkz_vs_mtip_n1

				wave wkSader_vs_mtip=wkzSader_vs_mtip
				wave wkSader_avg=wkzSader_vs_mtip_avg
				wave wkSader_D=wkzSader_vs_mtip_D
				wave wkSader_n1=wkzSader_vs_mtip_n1
				
				type="z"

			break
			
			case "lateral":

				NVAR NOP=NOP_Iend
				NVAR range=Range_Iend

				wave/SDFR=dfcal wktheta_thermal=:Results:wktheta_thermal
				make/O/N=(NOP) wktheta_vs_mtip_avg, wktheta_vs_mtip_D, wktheta_vs_mtip_n1
				make/O/N=(NOP) wkthetaSader_vs_mtip_avg, wkthetaSader_vs_mtip_D, wkthetaSader_vs_mtip_n1
				make/O/N=(NOP, numpnts(wktheta_thermal)) wktheta_vs_mtip, wStheta_vs_mtip, wkthetaSader_vs_mtip
				
				SetScale/I x Iend2Ic-range,Iend2Ic+range,"", wktheta_vs_mtip_avg, wktheta_vs_mtip_D, wktheta_vs_mtip_n1
				SetScale/I x Iend2Ic-range,Iend2Ic+range,"", wStheta_vs_mtip, wktheta_vs_mtip
				
				
				SetScale/I x Iend2Ic-range,Iend2Ic+range,"", wkthetaSader_vs_mtip_avg, wkthetaSader_vs_mtip_D, wkthetaSader_vs_mtip_n1
				SetScale/I x Iend2Ic-range,Iend2Ic+range,"", wkthetaSader_vs_mtip
	
				wStheta_vs_mtip=Sy_cont*tip_H_e*sqrt(1+ytip^2)*xtip/xlaser
				// 	Calc_Sy_CorrectionFactor(n, xlaser, Iend2Ic)
				wStheta_vs_mtip*=Calc_Sy_CorrectionFactor(q+1, xlaser, x)
				
				wktheta_vs_mtip=kBoltz*Medium_temperature
				wktheta_vs_mtip/=wPeakArea[q]/(wStheta_vs_mtip)^2
				wktheta_vs_mtip*=1/D_n_m(q+1,x)^2
				
				wktheta_vs_mtip/=xtip
				
				strswitch(model)
				
					case "SFO (full)":
					case "SFO (full) vn":

						// ratio of kc to mc: kc/mc=1/Dn^2*wn^2
						wkthetaSader_vs_mtip=(2*pi*wfvac[q])^2*1/D_n_m(q+1,x)^2
						// multiply by Ic=If/tau
						wkthetaSader_vs_mtip*=pi*(cant_width/2)^2*cant_length_e*medium_dens*cant_width^2/8
						wkthetaSader_vs_mtip/=wtau[q]
						// correct kz for tip offset
						wkthetaSader_vs_mtip/=xtip
					break

					default:
				
						wkthetaSader_vs_mtip=pi^3/8*medium_dens*cant_width^4*cant_length_e*wf0[q]^2*wQ[q]*imag(wG[q])
						wkthetaSader_vs_mtip*=1/D_n_m(q+1,x)^2
						wkthetaSader_vs_mtip/=xtip
						
					break
					
				endswitch

				wave wk_vs_mtip=wktheta_vs_mtip
				wave wk_avg=wktheta_vs_mtip_avg
				wave wk_D=wktheta_vs_mtip_D
				wave wk_n1=wktheta_vs_mtip_n1

				wave wkSader_vs_mtip=wkthetaSader_vs_mtip
				wave wkSader_avg=wkthetaSader_vs_mtip_avg
				wave wkSader_D=wkthetaSader_vs_mtip_D
				wave wkSader_n1=wkthetaSader_vs_mtip_n1

				type="θ"

			break
	
	endswitch

	wk_n1=wk_vs_mtip[p][0]
	wkSader_n1=wkSader_vs_mtip[p][0]
				
	variable i
	
	for(i=0;i<NOP;i+=1)
		WaveStats/Q/W/RMD=[i][] wk_vs_mtip
		wave M_WaveStats
		wk_avg[i]=M_WaveStats[3]
		wk_D[i]=M_WaveStats[4]
		//wk_D[i]=(M_WaveStats[25]-M_WaveStats[24])/2
	endfor

	for(i=0;i<NOP;i+=1)
		WaveStats/Q/W/RMD=[i][] wkSader_vs_mtip
		wave M_WaveStats
		wkSader_avg[i]=M_WaveStats[3]
		wkSader_D[i]=M_WaveStats[4]
		//wk_D[i]=(M_WaveStats[25]-M_WaveStats[24])/2
	endfor

	WaveStats/Q/P/R=(0,Inf) wk_D
	
	variable p0=max(V_minloc-1,0)
	variable p1=min(V_minloc+1,numpnts(wk_D))
	
	if(p1-p0<3)
		if(p0>0)
			p0-=1
		endif
		
		if(p1<numpnts(wk_D))
			p1+=1
		endif
	
	endif
	
	CurveFit/M=2/W=0/Q poly 3, wk_D[p0,p1] /D
	wave fit_k_D=$("fit_"+NameOfWave(wk_D))
	WaveStats/Q fit_k_D
	variable mtip_min=V_minloc
	
//	print "********************"
//	print "when ∆k(avg) is min: ξ =", mtip_min
//	print "k(avg)=", wk_avg(mtip_min), "±", wk_D(mtip_min)

	Duplicate/O wk_avg, wk_diff
	wk_diff=wk_avg-wk_n1
	
	FindLevel/Q/R=(10,-1) wk_diff, 0
	variable mtip_avgn1=V_levelX
	
	if(V_flag==0)
//		print "when k(avg)=k(n=1): ξ =", mtip_avgn1
//		print "k(avg)=", wk_avg(mtip_avgn1), "±", wk_D(mtip_avgn1)
	endif

// find global error min

	Duplicate/O wk_D, wk_del
	wave wk_del
	
	variable AddError
	
	wk_del=1
	i=0
	
	AddError=NumberByKey("Kequip", S_ErrorKey)
	
	if(AddError)
		wk_del*=wk_D/wk_avg
		i+=1
	endif
	
	AddError=NumberByKey("KSader", S_ErrorKey)
	
	if(AddError)
		wk_del*=wkSader_D/wkSader_avg
		i+=1
	endif
	
	AddError=NumberByKey("KdiffEqSader", S_ErrorKey)
	
	if(AddError)
		wk_del*=abs(wk_avg-wkSader_avg)/((wk_avg+wkSader_avg)/2)
		i+=1
	endif
	
	AddError=NumberByKey("KdiffEqSadern1", S_ErrorKey)
	
	if(AddError)
		wk_del*=abs(wk_n1-wkSader_n1)/((wk_n1+wkSader_n1)/2)
		i+=1
	endif
						
	wk_del=(wk_del)^(1/i)

// end find global error min

	// 20210112 - wjl compatability check
	NVAR/Z mend2mc_positive
	if(!NVAR_Exists(mend2mc_positive))
		Variable/G mend2mc_positive = 1
	endif

	if(mend2mc_positive==1)
		WaveStats/Q/R=(0,Inf) wk_del
	else
		WaveStats/Q wk_del
	endif

	mtip_min=V_minloc

	variable pMin=V_minRowLoc
	variable pRange=3
	
	CurveFit/Q/M=2/W=0 poly 4, wk_del[pMin-pRange,pMin+pRange] /D
	
	wave fit_wk_del
	WaveStats/Q fit_wk_del
//	WaveStats/Q wk_del
	mtip_min=V_minLoc

// update spring constants

	k_avg_Eq=wk_avg(mtip_min)
	k_avg_Eq_Err=wk_D(mtip_min)
	k_avg_Sader=wkSader_avg(mtip_min)
	k_avg_Sader_Err=wkSader_D(mtip_min)
	k_avg_Eqn1=wk_n1(mtip_min)
//	k_avg_Eqn1_Err
	k_avg_Sadern1=wkSader_n1(mtip_min)
//	k_avg_Sadern1_Err
	
	wave wD_kzs_EqTh_R=:Results:wD_kzs_EqTh_R
	wave wD_kzs_FluidStruc_R=:Results:wD_kzs_FluidStruc_R
	wave wD_kzs_Sader_R=:Results:wD_kzs_Sader_R
	
	k_avg_Eqn1_Err=wD_kzs_EqTh_R[0]*k_avg_Eqn1
	
	if(strsearch(model, "SFO (full)",0)>=0)
		k_avg_Sadern1_Err=wD_kzs_FluidStruc_R[0]*k_avg_Eqn1
	else
		k_avg_Sadern1_Err=wD_kzs_Sader_R[0]*k_avg_Eqn1
	endif

	SetDataFolder dfSav
		
	DoWindow/F Graphk_mtip
	
	if(V_flag==0)
		Graph_k_vs_mtip(wk_avg, wk_D, wk_n1, wkSader_avg, wkSader_D, wkSader_n1, type)
	endif

	strswitch(Spectrum_type)
	
		case "normal":

			mend2mc=mtip_min
			
			break
			
		case "lateral":
		
			Iend2Ic=mtip_min
	
			break
	
	endswitch

	return mtip_min	

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ButtonProc_ScanXMend_iterate(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			Scan_mend_iterate()
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Scan_mend_iterate()

	DFREF dfcal=root:Packages:AFM_Calibration:
	
	SVAR/SDFR=dfcal Spectrum_type 
	NVAR/SDFR=dfcal xlaser 

	NVAR/SDFR=dfcal end_m_NOI 
	NVAR/SDFR=dfcal xlaser_iterate 
	NVAR/SDFR=dfcal check_Scont_use_Snoncont_avg 
	
	STRUCT Sens S
	StructFill /SDFR=dfcal S
	
	// wave that contains the error
	// never made if this is the first optimization
	WAVE/SDFR=dfcal/Z wk_del
	WAVE/SDFR=dfcal/Z fit_wk_del
	if(WaveExists(wk_del)==0)
		Make/O/N=1 wk_del=1, fit_wk_del
	endif

	NVAR/SDFR=dfcal k_avg_Err

				
	// initialize iterations:
	
	strswitch(Spectrum_type)
	
		case "normal":
		
			WAVE/SDFR=dfcal:Results wSens=wSz_noncont
			NVAR/SDFR=dfcal V_sens=Sz_cont
			//V_Sens=S.Sz_cont
			NVAR/SDFR=dfcal mend2mc=$"mend2mc" 
			
		break
		
		case "lateral":
		
			WAVE/SDFR=dfcal:Results wSens=wSy_noncont
			NVAR/SDFR=dfcal V_sens=Sy_cont
			//V_Sens=S.Sy_cont
			NVAR/SDFR=dfcal mend2mc=$"Iend2Ic" 
			
		break				

	endswitch

	print "**************begin optimization:", "error: =", k_avg_Err

	// before the first iteration:
	// 1. set OLS using current approximate xlaser and mend
	// in the first iteration:
	// 2. redo mend
	// 3. redo k and OLS

	// update spring constants
	Calc_Results(0)

	if(check_Scont_use_Snoncont_avg==1)
		WaveStats/Q/M=1 wSens
		V_Sens=V_avg
	else
		V_Sens=wSens[0]
	endif

	// update spring constants
	Calc_Results(0)

	// end initialize

	variable i, SzSav, wk_delSav, mend2mcSav, xlaserSav

	// set relative error hihg, so there is at least one iteration
	wk_delSav=1
			
	DoWindow/F Graph_Error_k
		
	if(V_flag==0)
		Display /W=(799.5,543.5,1011,678.5) wk_del,fit_wk_del
		DoWindow/C Graph_Error_k
		ModifyGraph mode(wk_del)=3
		ModifyGraph marker(wk_del)=19
		ModifyGraph lSize(fit_wk_del)=1.5
		ModifyGraph rgb(fit_wk_del)=(1,16019,65535)
		ModifyGraph hbFill=2
		ModifyGraph standoff=0
		SetAxis/A/E=1 left
		Label bottom "End mass ξ\\Bend"
		Label left "Error ∆k/k"
		AutoPositionWindow/E/M=0/R=PanelScanXlaserMend Graph_Error_k
	endif

	for(i=0;i<end_m_NOI;i+=1)
	
		// Save previously optimized params
		SzSav=V_Sens
		xlaserSav=xlaser
		mend2mcSav=mend2mc
		
		// update end mass
		Scan_mend()
		Calc_Results(0)
		
		// update x laser
		if(xlaser_iterate==1)
			Scan_xlaser()
			Calc_Results(0)
		endif

		// update OLS
		if(check_Scont_use_Snoncont_avg==1)
			WaveStats/Q/M=1 wSens
			V_Sens=V_avg
		else
			V_Sens=wSens[0]
		endif
	
		// update error and spring constants
		Calc_Results(0)
		WaveStats/Q/M=1 wk_del
		k_avg_Err=V_min		

		print "iterations:", i+1, "errors: old =", wk_delSav, "new =", k_avg_Err

		// if the error in k gets worse, then stop 
		// and restore previous end mass and xlaser
		if(wk_delSav < k_avg_Err)
		
			// restore params from previous cycle
			V_Sens=SzSav
			xlaser=xlaserSav
			mend2mc=mend2mcSav
			k_avg_Err=wk_delSav
			
			// restore error wave wk_del
			// by redoing end mass with old mend and xlaser
			// and restoring end mass agian
			Scan_mend()
			mend2mc=mend2mcSav
		
			print "**************end optimization:", "error: =", k_avg_Err

			break
		endif
		
		// save error
		wk_delSav=k_avg_Err
		
	endfor

	if(end_m_NOI == i)
		print "iterations:", i, "calculations have not yet converged. Continue iterations."
	endif
		
	Calc_Results(0)
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Scan_Iend()

	DFREF dfSav = GetDataFolderDFR()
	DFREF dfcal=root:Packages:AFM_Calibration:
	
	SetDataFolder dfcal
	
	NVAR xtip
	NVAR xlaser
	NVAR cant_length_e
	NVAR cant_width
	NVAR cant_inclination

	NVAR mend2mc
	NVAR Iend2Ic
	NVAR iend_k

	NVAR NOP=NOP_Iend
	NVAR range=Range_Iend

	NVAR tip_H_e
	NVAR htip
	NVAR ytip
	
	NVAR medium_dens
	NVAR Medium_temperature
		
	NVAR Sz_cont
	NVAR Sy_cont
	
	SVAR Spectrum_type
	SVAR model
	
	wave wf0
	wave wfvac
	wave wQ
	wave wtau
	wave/C wG

	wave/SDFR=dfcal wPeakArea=:Results:wPeakArea
	wave/SDFR=dfcal wCn=:Results:wCn
	wave/SDFR=dfcal wDn=:Results:wDn
	
	SVAR S_ErrorKey
	
	string type
	
	strswitch(Spectrum_type)
	
		case "normal":

				wave/SDFR=dfcal wkz_thermal=:Results:wkz_thermal
				make/O/N=(NOP) wkz_vs_Itip_avg, wkz_vs_Itip_D, wkz_vs_Itip_n1
				make/O/N=(NOP) wkzSader_vs_Itip_avg, wkzSader_vs_Itip_D, wkzSader_vs_Itip_n1
				make/O/N=(NOP, numpnts(wkz_thermal)) wkz_vs_Itip, wSz_vs_Itip, wkzSader_vs_Itip
				
				SetScale/I x Iend2Ic-range,Iend2Ic+range,"", wkz_vs_Itip_avg, wkz_vs_Itip_D, wkz_vs_Itip_n1
				SetScale/I x Iend2Ic-range,Iend2Ic+range,"", wSz_vs_Itip, wkz_vs_Itip
				
				
				SetScale/I x Iend2Ic-range,Iend2Ic+range,"", wkzSader_vs_Itip_avg, wkzSader_vs_Itip_D, wkzSader_vs_Itip_n1
				SetScale/I x Iend2Ic-range,Iend2Ic+range,"", wkzSader_vs_Itip
	
				wSz_vs_Itip=Sz_cont
				// 	Calc_Sz_CorrectionFactor(Current_peak, xtip,  xlaser,mend2mc, htip, cant_inclination)
				// wSz_vs_Itip*=Calc_Sz_CorrectionFactor(q+1, xtip, xlaser, x, htip, cant_inclination)
				// Calc_Sz_CorrectionFactor2(n, xtip, xlaser, mend2mc, Iend2Ic, htip, inclAngle)
				wSz_vs_Itip*=Calc_Sz_CorrectionFactor2(q+1, xtip, xlaser, mend2mc, x, htip, cant_inclination)
				
				// convert Sz to SN
				wSz_vs_Itip*=cos(cant_inclination/180*pi)

				wkz_vs_Itip=kBoltz*Medium_temperature
				wkz_vs_Itip/=wPeakArea[q]/(wSz_vs_Itip)^2
				wkz_vs_Itip*=3/C_n_m_I(q+1, mend2mc, x)^4
			
				wkz_vs_Itip/=(xtip)^3
				
				strswitch(model)
				
					case "SFO (full)":
					case "SFO (full) vn":

						// ratio of kc to mc: kc/mc=3/Cn^4*wn^2
						wkzSader_vs_Itip=(2*pi*wfvac[q])^2*3/C_n_m_I(q+1,mend2mc,x)^4
						// multiply by mc=mf/tau
						wkzSader_vs_Itip*=pi*(cant_width/2)^2*cant_length_e*medium_dens
						wkzSader_vs_Itip/=wtau[q]
						// correct kz for tip offset
						wkzSader_vs_Itip/=(xtip)^3
					break

					default:
				
						wkzSader_vs_Itip=pi^3*medium_dens*cant_width^2*cant_length_e*wf0[q]^2*wQ[q]*imag(wG[q])
						wkzSader_vs_Itip*=3/C_n_m_I(q+1,mend2mc,x)^4
						wkzSader_vs_Itip/=(xtip)^3
						
					break
					
				endswitch

				wave wk_vs_Itip=wkz_vs_Itip
				wave wk_avg=wkz_vs_Itip_avg
				wave wk_D=wkz_vs_Itip_D
				wave wk_n1=wkz_vs_Itip_n1

				wave wkSader_vs_Itip=wkzSader_vs_Itip
				wave wkSader_avg=wkzSader_vs_Itip_avg
				wave wkSader_D=wkzSader_vs_Itip_D
				wave wkSader_n1=wkzSader_vs_Itip_n1
				
				type="z"

			break
			
			case "lateral":
			
				// we only do I_end scan for flexural motion
				// for torsion I_end is done in m_end scan
				return 1


			break
	
	endswitch

	wk_n1=wk_vs_Itip[p][0]
	wkSader_n1=wkSader_vs_Itip[p][0]
				
	variable i
	
	for(i=0;i<NOP;i+=1)
		WaveStats/Q/W/RMD=[i][] wk_vs_Itip
		wave M_WaveStats
		wk_avg[i]=M_WaveStats[3]
		wk_D[i]=M_WaveStats[4]
		//wk_D[i]=(M_WaveStats[25]-M_WaveStats[24])/2
	endfor

	for(i=0;i<NOP;i+=1)
		WaveStats/Q/W/RMD=[i][] wkSader_vs_Itip
		wave M_WaveStats
		wkSader_avg[i]=M_WaveStats[3]
		wkSader_D[i]=M_WaveStats[4]
		//wk_D[i]=(M_WaveStats[25]-M_WaveStats[24])/2
	endfor

//	WaveStats/Q/P wk_D
//	iend_k=V_minRowloc
	
	variable p0=max(V_minloc-1,0)
	variable p1=min(V_minloc+1,numpnts(wk_D))
	
	if(p1-p0<3)
		if(p0>0)
			p0-=1
		endif
		
		if(p1<numpnts(wk_D))
			p1+=1
		endif
	
	endif
	
	CurveFit/M=2/W=0/Q poly 3, wk_D[p0,p1] /D
	wave fit_k_D=$("fit_"+NameOfWave(wk_D))
	WaveStats/Q fit_k_D
	variable Itip_min=V_minloc
	
//	print "********************"
//	print "when ∆k(avg) is min: ξ =", Itip_min
//	print "k(avg)=", wk_avg(Itip_min), "±", wk_D(Itip_min)

	Duplicate/O wk_avg, wk_diff
	wk_diff=wk_avg-wk_n1
	
	FindLevel/Q/R=(10,-1) wk_diff, 0
	variable Itip_avgn1=V_levelX
	
	if(V_flag==0)
//		print "when k(avg)=k(n=1): ξ =", Itip_avgn1
//		print "k(avg)=", wk_avg(Itip_avgn1), "±", wk_D(Itip_avgn1)
	endif

// find global error min

	Duplicate/O wk_D, wk_del
	wave wk_del
	
	variable AddError
	
	wk_del=1
	i=0
	
	AddError=NumberByKey("Kequip", S_ErrorKey)
	
	if(AddError)
		wk_del*=wk_D/wk_avg
		i+=1
	endif
	
	AddError=NumberByKey("KSader", S_ErrorKey)
	
	if(AddError)
		wk_del*=wkSader_D/wkSader_avg
		i+=1
	endif
	
	AddError=NumberByKey("KdiffEqSader", S_ErrorKey)
	
	if(AddError)
		wk_del*=abs(wk_avg-wkSader_avg)/((wk_avg+wkSader_avg)/2)
		i+=1
	endif
	
	AddError=NumberByKey("KdiffEqSadern1", S_ErrorKey)
	
	if(AddError)
		wk_del*=abs(wk_n1-wkSader_n1)/((wk_n1+wkSader_n1)/2)
		i+=1
	endif
						
	wk_del=(wk_del)^(1/i)

	// 20210112 - wjl compatability check
	NVAR/Z mend2mc_positive
	if(!NVAR_Exists(mend2mc_positive))
		Variable/G mend2mc_positive = 1
	endif

	if(mend2mc_positive==1)
		WaveStats/Q/R=(0,Inf) wk_del
	else
		WaveStats/Q wk_del
	endif

	Itip_min=V_minloc

	iend_k=V_minRowloc

// end find global error min

	variable pMin=V_minRowLoc
	variable pRange=1
	
	CurveFit/Q/M=2/W=0 poly 3, wk_del[pMin-pRange,pMin+pRange] /D
	
	wave fit_wk_del
	WaveStats/Q fit_wk_del
	Itip_min=V_minLoc

	SetDataFolder dfSav
		
	DoWindow/F Graphk_Itip
	if(V_flag==1)
		Checkdisplayed/W=Graphk_Itip wk_avg 
		if(V_flag==0)
			KillWindow/Z Graphk_Itip
			Graph_k_vs_Itip(wk_avg, wk_D, wk_n1, wkSader_avg, wkSader_D, wkSader_n1, type)
		endif
	else
		Graph_k_vs_Itip(wk_avg, wk_D, wk_n1, wkSader_avg, wkSader_D, wkSader_n1, type)
	endif
	

	// need to sleect the plane first,
	// otherwise Iend2Ic is overwritten by Scan_xmi2xm()
	// also overwrites mend and xlaser
	// Scan_xmi2xm(iend_k)

	strswitch(Spectrum_type)
	
		case "normal":

			Iend2Ic=Itip_min
			
			break
			
		case "lateral":
		
			Iend2Ic=Itip_min
	
			break
	
	endswitch

	return Itip_min	

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Graph_k_vs_mtip(wk_avg, wk_D, wk_n1, wkSader_avg, wkSader_D, wkSader_n1, type)
	wave wk_avg, wk_D, wk_n1, wkSader_avg, wkSader_D, wkSader_n1
	string type

	String fldrSav0= GetDataFolder(1)
	
	Display/K=1 /W=(352.5,205.25,912,584) wk_avg, wk_n1
	AppendToGraph wkSader_avg, wkSader_n1

	DoWindow/C Graphk_mtip
	
	SetDataFolder fldrSav0
	ModifyGraph width={Aspect,1.5},height=288
	ModifyGraph lSize=2
	ModifyGraph lStyle($NameOfWave(wk_n1))=3
	ModifyGraph lStyle($NameOfWave(wkSader_n1))=3
	ModifyGraph mirror=2
	ModifyGraph minor=1
	ModifyGraph fSize=20
	ModifyGraph lowTrip(bottom)=0.01

	ModifyGraph rgb($NameOfWave(wkSader_avg))=(0,0,65535),rgb($NameOfWave(wkSader_n1))=(0,0,65535)

	strswitch(type)
	
		case "z":
		
			Label left "Spring constant k\\B"+type+",s\\M (N/m)"
			Label bottom "End mass ξ\\Bend"
		
		break
			
		case "θ":
		
			Label left "Spring constant k\\Bθ,s\\M (\\u#2nN·m/rad)"
			Label bottom "End moment of inertia ξ\\Bend"
		
		break
		
	endswitch

	ErrorBars $NameOfWave(wk_avg) SHADE= {0,0,(65535,54611,49151),(0,0,0,0)},wave=(wk_D,wk_D)
	ErrorBars $NameOfWave(wkSader_avg) SHADE= {0,4,(0,0,0,0),(0,0,0,0)},wave=(wkSader_D,wkSader_D)
	
	string S_legend="\\Z12Equipartition:\r\\s("+NameOfWave(wk_n1)+") k\\B"+type+",s\\M\\Z12 (n=1)\r\\s("+NameOfWave(wk_avg)+") k\\B"+type+",s\\M\\Z12 (avg)\r"
	S_legend+="Sader:\r\\s("+NameOfWave(wkSader_n1)+") k\\B"+type+",s\\M\\Z12 (n=1)\r\\s("+NameOfWave(wkSader_avg)+") k\\B"+type+",s\\M\\Z12 (avg)"
	Legend/C/N=text0/J/F=0/A=MC/X=-38/Y=32 S_legend
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Scan_Xlaser()

	DFREF dfSav = GetDataFolderDFR()
	DFREF dfcal=root:Packages:AFM_Calibration:
	
	SetDataFolder dfcal
	
	NVAR xtip
	NVAR xlaser
	NVAR cant_Xlaser
	NVAR Cant_length
	NVAR cant_inclination
	NVAR tip_H_e
	NVAR htip
	NVAR ytip
	NVAR mend2mc
	NVAR Iend2Ic
	
	NVAR NOP=NOP_Xlaser
	NVAR Range_Xlaser=Range_Xlaser
	SVAR CurrentGraph
	NVAR DoInsetParamScan
	
	NVAR Sz_cont
	NVAR Sy_cont
	NVAR Medium_temperature
	
	SVAR Spectrum_type

	wave/SDFR=dfcal wPeakArea=:Results:wPeakArea
	wave/SDFR=dfcal wCn=:Results:wCn
	wave/SDFR=dfcal wDn=:Results:wDn
	
	NVAR k_avg_Eq, k_avg_Eq_Err
	NVAR k_avg_Sader, k_avg_Sader_Err
	NVAR k_avg_Eqn1, k_avg_Eqn1_Err
	NVAR k_avg_Sadern1, k_avg_Sadern1_Err

	string type
	
	strswitch(Spectrum_type)
	
		case "normal":

				wave/SDFR=dfcal wkz_thermal=:Results:wkz_thermal
				make/O/N=(NOP) wkz_vs_xlaser_avg, wkz_vs_xlaser_D, wkz_vs_xlaser_n1
				make/O/N=(NOP, numpnts(wkz_thermal)) wkz_vs_xlaser, wSz_vs_xlaser
				
				SetScale/I x max(xlaser-Range_Xlaser,0),min(xlaser+Range_Xlaser,1),"", wkz_vs_xlaser_avg, wkz_vs_xlaser_D, wkz_vs_xlaser_n1
				SetScale/I x max(xlaser-Range_Xlaser,0),min(xlaser+Range_Xlaser,1),"", wSz_vs_xlaser

				wSz_vs_xlaser=Sz_cont
				// 	Calc_Sz_CorrectionFactor(Current_peak, xtip,  xlaser,mend2mc, htip, cant_inclination)
				// wSz_vs_xlaser*=Calc_Sz_CorrectionFactor(q+1, xtip, x, mend2mc, htip, cant_inclination)
				wSz_vs_xlaser*=Calc_Sz_CorrectionFactor2(q+1, xtip, x, mend2mc, Iend2Ic, htip, cant_inclination)
				
				// convert Sz to SN
				wSz_vs_xlaser*=cos(cant_inclination/180*pi)

				wkz_vs_xlaser=kBoltz*Medium_temperature
				wkz_vs_xlaser/=wPeakArea[q]/(wSz_vs_xlaser)^2
				wkz_vs_xlaser*=3/C_n_m_I(q+1,mend2mc, Iend2Ic)^4

				wkz_vs_xlaser/=(xtip)^3
				
				wave wk_vs_laser=wkz_vs_xlaser
				wave wk_avg=wkz_vs_xlaser_avg
				wave wk_D=wkz_vs_xlaser_D
				wave wk_n1=wkz_vs_xlaser_n1
				
				type="z"

			break
			
			case "lateral":

				wave/SDFR=dfcal wktheta_thermal=:Results:wktheta_thermal
				make/O/N=(NOP) wktheta_vs_xlaser_avg, wktheta_vs_xlaser_D, wktheta_vs_xlaser_n1
				make/O/N=(NOP, numpnts(wktheta_thermal)) wktheta_vs_xlaser, wStheta_vs_xlaser
				
				SetScale/I x max(xlaser-Range_Xlaser,0),min(xlaser+Range_Xlaser,1),"", wktheta_vs_xlaser_avg, wktheta_vs_xlaser_D, wktheta_vs_xlaser_n1
				SetScale/I x max(xlaser-Range_Xlaser,0),min(xlaser+Range_Xlaser,1),"", wStheta_vs_xlaser

				wStheta_vs_xlaser=Sy_cont*tip_H_e*sqrt(1+ytip^2)*xtip/xlaser
				// Calc_Sy_CorrectionFactor(n, xlaser, mend2mc)
				wStheta_vs_xlaser*=Calc_Sy_CorrectionFactor(q+1, x, Iend2Ic)
				
				wktheta_vs_xlaser=kBoltz*Medium_temperature
				wktheta_vs_xlaser/=wPeakArea[q]/(wStheta_vs_xlaser)^2
				wktheta_vs_xlaser*=1/D_n_m(q+1,Iend2Ic)^2

				wktheta_vs_xlaser/=xtip
				
				wave wk_vs_laser=wktheta_vs_xlaser
				wave wk_avg=wktheta_vs_xlaser_avg
				wave wk_D=wktheta_vs_xlaser_D
				wave wk_n1=wktheta_vs_xlaser_n1

				type="θ"

			break
	
	endswitch

	wk_n1=wk_vs_laser[p][0]
				
	variable i
	
	for(i=0;i<NOP;i+=1)
		WaveStats/Q/W/RMD=[i][] wk_vs_laser
		wave M_WaveStats
		wk_avg[i]=M_WaveStats[3]
		wk_D[i]=M_WaveStats[4]
		//wk_D[i]=(M_WaveStats[25]-M_WaveStats[24])/2
	endfor

	// normalize error
	Duplicate/O wk_D, wk_laser_del
	wk_laser_del/=wk_avg
	
	WaveStats/Q/P wk_laser_del
	
	variable p0=V_minloc-2
	variable p1=V_minloc+2

	if(V_minloc==0)
	
		p0=0
		p1=4
		
	elseif(V_minloc+2>=NOP)
		
			p0=NOP-5
			p1=NOP-1

	endif	
		
	CurveFit/M=2/W=0/Q poly 4, wk_laser_del[p0,p1] /D
	wave fit_k_D=$("fit_"+NameOfWave(wk_laser_del))
	WaveStats/Q fit_k_D
	variable xlaser_min=V_minloc
	
//	print "********************"
//	print "when ∆k(avg) is min: xlaser=", xlaser_min
//	print "k(avg)=", wk_avg(xlaser_min), "±", wk_D(xlaser_min)

	Duplicate/O wk_avg, wk_diff
	wk_diff=wk_avg-wk_n1
	// normalize error
	wk_diff/=(wk_avg+wk_n1)/2
	
	variable xlaser_avgn1
	FindLevel/Q wk_diff, 0
	if(V_flag==0)
		xlaser_avgn1=V_levelX
	else
		xlaser_avgn1=xlaser_min
	endif
	
//	print "when k(avg)=k(n=1): xlaser=", xlaser_avgn1
//	print "k(avg)=", wk_avg(xlaser_avgn1), "±", wk_D(xlaser_avgn1)

	// take and average between two minima
	xlaser_min/=2
	xlaser_min+=xlaser_avgn1/2

// update spring constants

	k_avg_Eq=wk_avg(xlaser_min)
	k_avg_Eq_Err=wk_D(xlaser_min)
	k_avg_Eqn1=wk_n1(xlaser_min)
	
	wave wD_kzs_EqTh_R=:Results:wD_kzs_EqTh_R
	
	k_avg_Eqn1_Err=wD_kzs_EqTh_R[0]*k_avg_Eqn1
	

	SetDataFolder dfSav
		
	if(DoInsetParamScan)
		DoWindow/F $CurrentGraph
	
		if(V_flag==1)
			Graph_k_vs_xlaser(wk_avg, wk_D, wk_n1, type,1)
		else
			DoInsetParamScan=0
		endif

	else

		DoWindow/F Graphk_xlaser

		if(V_flag==0)
			Graph_k_vs_xlaser(wk_avg, wk_D, wk_n1, type,0)
		endif
		
	endif

//	DoWindow/F Graphk_xlaser
//	
//	if(V_flag==0)
//		Graph_k_vs_xlaser(wk_avg, wk_D, wk_n1, type,0)
//	endif

	cant_Xlaser=xlaser_min*Cant_length
	xlaser=xlaser_min
	DoUpdate
	
	Update_SpringConst()
	Update_Sens()		

	return xlaser_min	

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Graph_k_vs_xlaser(wk_avg, wk_D, wk_n1, type, DoInset)
	wave wk_avg, wk_D, wk_n1
	string type
	variable DoInset

	if(DoInset)
	
		GetWindow/Z # activeSW
		if(strsearch(S_value, "#",0)>0)
			SetActiveSubwindow ##
		endif
		
		KillWindow/Z #G0
		Display/W=(0.17,0.20,0.60,0.55)/HOST=#  wk_avg,wk_n1
		RenameWindow #,G0
		ModifyGraph lSize=1.5
		Legend/C/N=text0/J/F=0/A=LT/X=0/Y=0 "\\Z10\\s("+NameOfWave(wk_n1)+") k\\B"+type+",s\\M\\Z10 (n=1)\r\\s("+NameOfWave(wk_avg)+") k\\B"+type+",s\\M\\Z10 (avg)"
		//SetActiveSubwindow ##
	else
		Display/K=1 /W=(352.5,205.25,912,584) wk_avg, wk_n1
		DoWindow/C Graphk_xlaser
		ModifyGraph width={Aspect,1.5},height=288
		ModifyGraph fSize=20
		ModifyGraph lSize=2
		Legend/C/N=text0/J/F=0/A=MC/X=-33.33/Y=35.94 "\\Z18\\s("+NameOfWave(wk_n1)+") k\\B"+type+",s\\M\\Z18 (n=1)\r\\s("+NameOfWave(wk_avg)+") k\\B"+type+",s\\M\\Z18 (avg)"
	endif
	
	strswitch(type)
	
		case "z":
		
			ModifyGraph lStyle(wkz_vs_xlaser_n1)=3
			Label left "Spring constant k\\B"+type+",s\\M (N/m)"
		
		break
			
		case "θ":
		
			ModifyGraph lStyle(wktheta_vs_xlaser_n1)=3
			Label left "Spring constant k\\B"+type+",s\\M (N/rad)"
		
		break
		
	endswitch
	
	ModifyGraph mirror=2
	ModifyGraph minor=1
	ModifyGraph lowTrip(bottom)=0.01
	Label bottom "Laser spot position x\\Blaser"
	ErrorBars $NameOfWave(wk_avg) SHADE= {0,0,(65535,54611,49151),(0,0,0,0)},wave=(wk_D,wk_D)

	if(DoInset)
		SetActiveSubwindow ##
	endif
	

EnD
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


// END OF SCAN CANTILEVER PARAMETERS -- XLASER AND END MASS

// Scan of resonance frequncy to get thickness and end mass

//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function make_invw(mtip2mc,n)
	variable mtip2mc,n
	
	wave w=$("w2endmass"+num2str(n))
	
	return w(mtip2mc)
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Fit_invw2vsCn4(mstart, mend, NOP, numpeaks)
	variable mstart, mend, NOP, numpeaks
	
	make/O/N=(NOP) wa, wb, wChiSq, wm, wc
	
	variable i
	variable mdel=(mend-mstart)/NOP, mend2mc
	
	
	Make/D/N=2/O W_coef
//	invw is the ratio of 1/w(n)^2 to 1/w(n=1)^2
//	wn2 is the ratio of w(n)^2 to w(n=1)^2
	make/O/N=(numpeaks) wn2, Cn4
	wave wn2, Cn4
	
	Cn4=C_n(p+1)^4/C_n(1)^4
	
	Duplicate/O wn2, wn2log
	Duplicate/O Cn4, Cn4log
	 
	SetFormula wn2log, "ln(wn2)"
	SetFormula Cn4log, "ln(Cn4)"

			
	for(i=0;i<NOP;i+=1)
	
		mend2mc=mstart+mdel*i
	
		wn2=1/make_invw(mend2mc,p+1)
		wn2*=Cn4*(1+C_n(1)^4/3*mend2mc)
		
		DoUpdate
		
		K0=0
		K1=1
//		CurveFit/H="10"/M=2/W=0/Q line, wn2/X=Cn4/D
		CurveFit/H="10"/M=2/W=0/Q line, wn2log/X=Cn4log/D
//		CurveFit/H="100"/M=2/W=0/Q poly 3, wn2log/X=Cn4log/D		
//		CurveFit/H="110"/Q Power wn2log /X=Cn4log /D
		
		wa[i]=W_coef[0]
		wb[i]=W_coef[1]
//		wc[i]=W_coef[2]


		wm[i]=mend2mc
		//NVAR V_chisq=V_chisq
		wChiSq[i]=V_chisq
		
		
	endfor

	//edit wm, wa, wb, wChiSq
		
end

// for log(w^2) vs log(Cn^4)
//	a and b
//  fit_wb= expSigmoid(W_coef,x)
//	for 5 points

//	for 3 points
//	 W_coef={1.2927,-0.13785,4.6838,1.3749,-0.3889,0.97454,-0.071371,0.029279}

// for w^2 vs Cn^4
//	a=0
//  fit_wb= expSigmoid(W_coef,x)
//	for 5 points

//	for 3 points



Function expSigmoid(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = a+exp(-x*b)+exp(-x*c)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 8
	//CurveFitDialog/ w[0] = a
	//CurveFitDialog/ w[1] = b
	//CurveFitDialog/ w[2] = c
	//CurveFitDialog/ w[3] = d
	//CurveFitDialog/ w[4] = e
	//CurveFitDialog/ w[5] = f
	//CurveFitDialog/ w[6] = g
	//CurveFitDialog/ w[7] = h
	
	variable s=1
	s/=1+exp((w[6]-x)/w[7])

	return (1-s)*(w[0]+w[1]*exp(-x*w[2]))+s*(w[3]+w[4]*exp(-x*w[5]))
End

Function lineexpSigmoid(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = a+exp(-x*b)+exp(-x*c)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 7
	//CurveFitDialog/ w[0] = a
	//CurveFitDialog/ w[1] = b
	//CurveFitDialog/ w[2] = c
	//CurveFitDialog/ w[3] = d
	//CurveFitDialog/ w[4] = e
	//CurveFitDialog/ w[5] = f
	//CurveFitDialog/ w[6] = g
	
	variable s=1
	s/=1+exp((w[5]-x)/w[6])

	return (1-s)*(w[0]+w[1]*x)+s*(w[2]+w[3]*exp(-x*w[4]))
End

// for log(w^2) vs log(Cn^4)
//	a=0
//   fit_wb= lineexpSigmoid2(W_coef,x)
//	for 5 points
//	W_coef={0.88722,3.1456,-1.814,3.8521,-2.9148,-0.051804,0.024161}
// 	for 3 points
//	W_coef={0.8735,2.518,-1.2191,4.899,-5.3657,-0.094337,0.030973}

// for w^2 vs Cn^4
//	a=0
//  fit_wb= expSigmoid(W_coef,x)
//	for 5 points

//	for 3 points


Function lineexpSigmoid2(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = a+exp(-x*b)+exp(-x*c)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 7
	//CurveFitDialog/ w[0] = a
	//CurveFitDialog/ w[1] = b
	//CurveFitDialog/ w[2] = c
	//CurveFitDialog/ w[3] = d
	//CurveFitDialog/ w[4] = e
	//CurveFitDialog/ w[5] = f
	//CurveFitDialog/ w[6] = g
	
	variable s=1
	s/=1+exp((w[5]-x)/w[6])

	return s*(w[0]+w[1]*x)+(1-s)*(w[2]+w[3]*exp(-x*w[4]))
End

// use ln(w^2) vs ln(Cn^4) fit results 
// for unconstrained linear fit
// need to use both a and b coeff.
Function Calc_mend2mc(a, b)
	variable a, b
	
	variable mend2mc
	
	make/O/N=7 W_coef
	W_coef={0.8735,2.518,-1.2191,4.899,-5.3657,-0.094337,0.030973}
	
//	wave wm
	
	b=ceil(1000*b)/1000
	if( b>0.995 && b<1.001)
		b=1.001
	endif

// first search for positive mend2mc (a>-0.01)
// then for highly negative < -0.018
// then in between -- multiple roots in this region	
	if(a>-0.01)
		FindRoots/B=0/H=0.8/L=0/Q /Z=(b) lineexpSigmoid2, W_coef
	elseif(a<-0.018)
		FindRoots/B=0/H=-0.13/L=-0.4/Q /Z=(b) lineexpSigmoid2, W_coef
	else
		FindRoots/B=0/H=-0.05/L=-0.13/Q /Z=(b) lineexpSigmoid2, W_coef
	endif
	


	if(V_flag==0)
		if(abs(V_YatRoot-b)<0.01)
			mend2mc=V_Root
		else
			mend2mc=NaN
		endif
	else
		mend2mc=NaN
	endif

	return mend2mc

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑



//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Calc_mc2kc(a,b,w1)
	variable a,b,w1

	variable mc2mend=Calc_mend2mc(a,b)
	
	return C_n(1)^4/3*1/w1^2/(1+C_n(1)^4/3*mc2mend)

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


// End scan of resonance frequncy to get thickness and end mass

