#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

#include "Cross Hair Profile"


Function PanelGetDistance()

	if(DataFolderExists("root:Packages:AFM_Calibration:")==0)
		Init_CalcSens()
		init_Peaks()
	endif
	
	DFREF dfcal=root:Packages:AFM_Calibration:
	SetDataFolder dfcal
	
	variable/G b_Exp_avg
	variable/G b_Err_Exp_avg
	variable/G b_Err_CL_avg
	
	DoWindow/F PanelMeasureDist
	if(V_flag==0)
		Execute "MakePanelMeasureDist()"
		DoWindow/C PanelMeasureDist
	endif

End


Window MakePanelMeasureDist() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(818,802,1046,1009)
	SetDrawLayer UserBack
	DrawText 6,64,"\\f012-edge:\\f00 \tabs(step[C,D]-step[A,B])\r\\f011-edge:\\f00  \tX(start/end longest plateau)\r\t\t\t\t\t\t  - X(cursor pair step)\r\\f010-edge:\\f00  \tX(end profile) - X(start profile)"
	CheckBox AddCursors_tab1,pos={96.00,74.00},size={110.00,15.00},proc=CheckProc_ShowCursorsImage,title=" Cursors to profile"
	CheckBox AddCursors_tab1,variable= root:packages:AFM_Calibration:cursors_checked
	Button FitDistance,pos={6.00,97.00},size={82.00,26.00},proc=ButtonProc_FindDistance,title="Find distance"
	SetVariable setvarB_avg,pos={49.00,134.00},size={142.00,18.00},title="exp. b avg."
	SetVariable setvarB_avg,format="%.4e m"
	SetVariable setvarB_avg,limits={0,inf,0},value= root:packages:AFM_Calibration:b_Exp_avg
	SetVariable setvarB_err_avg,pos={9.00,158.00},size={183.00,18.00},title="exp. b st. dev. avg."
	SetVariable setvarB_err_avg,format="%.4e m"
	SetVariable setvarB_err_avg,limits={0,inf,0},value= root:packages:AFM_Calibration:b_Err_Exp_avg
	SetVariable setvarB_CL_avg,pos={56.00,181.00},size={136.00,18.00},title="exp. b CL"
	SetVariable setvarB_CL_avg,format="%.4e m"
	SetVariable setvarB_CL_avg,limits={0,inf,0},value= root:packages:AFM_Calibration:b_Err_CL_avg
	Button buttonReset_B_exp,pos={94.00,97.00},size={118.00,26.00},proc=ButtonProc_ResetB_Exp,title="Reset avg. & show b"
	Button AddXhair,pos={7.00,70.00},size={80.00,23.00},proc=ButtonProc_AddXHair,title="Add profile"
EndMacro

Function ButtonProc_AddXHair(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			XHair_AddHairTop("free")
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProc_ResetB_Exp(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here

			DFREF dfSav = GetDataFolderDFR()
		
			DFREF dfcal=root:Packages:AFM_Calibration:
			SetDataFolder dfcal

			make/O/N=0 dfcal:b_Exp, dfcal:b_Err_Exp
			
			wave/SDFR=dfcal b_Exp
			wave/SDFR=dfcal b_Err_Exp
			
			DoWindow/F b_exp_Data
			if(V_flag==0)
				Edit/W=(471,48.5,720.75,322.25)/K=1 b_Exp, b_Err_Exp
				DoWindow/C b_exp_Data
				AutoPositionWindow/E/M=1/R=PanelMeasureDist b_exp_Data 
			endif

			NVAR b_Exp_avg
			NVAR b_Err_Exp_avg
			NVAR b_Err_CL_avg
			
			b_Exp_avg=0
			b_Err_Exp_avg=0
			b_Err_CL_avg=0

			SetDataFolder dfSav

			break
		case -1: // control being killed
			break
	endswitch

	return 0
End



Function CheckProc_ShowCursorsImage(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	string wins=WinList("Profile*", ";", "WIN:1")
	if(ItemsInList(wins)==0)
		Abort "Profile is not displayed."
	endif
	
	string WinProf=StringFromList(0, wins)
	
	DoWindow/F $WinProf

			Wave/Z profile=TraceNameToWaveRef("", "ProfileXY")
			if(WaveExists(profile)==0)
				Wave/Z profile=TraceNameToWaveRef("", "ProfileX")
				if(WaveExists(profile)==0)
					Abort "Profile not found."
				endif
			endif

	if(checked)
		Cursor/P/F/S=1/H=2 A $NameOfWave(Profile) 0.1, 0.05 
		Cursor/P/F/S=1/H=2 B $NameOfWave(Profile) 0.2, 0.25
		Cursor/P/F/S=1/H=2 C $NameOfWave(Profile) 0.8, 0.05 
		Cursor/P/F/S=1/H=2 D $NameOfWave(Profile) 0.9, 0.25
	else
		Cursor/K A
		Cursor/K B
		Cursor/K C
		Cursor/K D
	endif
	
End


Function ButtonProc_FindDistance(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			DFREF dfSav = GetDataFolderDFR()
		
			DFREF dfcal=root:Packages:AFM_Calibration:
			SetDataFolder dfcal

			string wins=WinList("Profile*", ";", "WIN:1")
			if(ItemsInList(wins)==0)
				Abort "Profile is not displayed."
			endif
			
			string WinProf=StringFromList(0, wins)
			
			DoWindow/F $WinProf

			Wave/Z profile=TraceNameToWaveRef("", "ProfileXY")
			if(WaveExists(profile)==0)
				Wave/Z profile=TraceNameToWaveRef("", "ProfileX")
				if(WaveExists(profile)==0)
					Abort "Profile not found."
				endif
			endif
			
			NVAR b_Exp_avg
			NVAR b_Err_Exp_avg
			NVAR b_Err_CL_avg
			
			variable b0
			variable b0Err
			variable b1
			variable b1Err

			RemoveFromGraph/Z Fit0,Fit1
			
			Variable abExists= strlen(CsrInfo(A))*strlen(CsrInfo(A)) > 0
			
			if(abExists)
				CurveFit/Q/M=2/W=2 Sigmoid, profile(hcsr(A),hcsr(B))/D
				
				wave W_coef
	
				wave fit=$("fit_"+NameOfWave(profile))
				Duplicate/O fit, Fit0
				ReplaceWave trace=$("fit_"+NameOfWave(profile)), Fit0
				ModifyGraph rgb(Fit0)=(0,0,0)

				b0=W_coef[2]
				b0Err=W_coef[3]
			
			endif
						
			Variable cdExists= strlen(CsrInfo(C))*strlen(CsrInfo(D)) > 0
			
			if(cdExists)
				CurveFit/Q/M=2/W=2 Sigmoid, profile(hcsr(C),hcsr(D))/D
				
				wave W_coef

				wave fit=$("fit_"+NameOfWave(profile))
				Duplicate/O fit, Fit1
				ReplaceWave trace=$("fit_"+NameOfWave(profile)), Fit1			
				ModifyGraph rgb(Fit1)=(0,0,0)

				b1=W_coef[2]
				b1Err=W_coef[3]

			endif
			
			if(abExists==0 && cdExists==0)
				b0=leftx(profile)
				b1=rightx(profile)
				b0Err=0
				b1Err=0
			elseif(abExists==0)
				b0=max(abs(rightx(profile)-b1),abs(leftx(profile)-b1))+b1 
				b0Err=0
				elseif(cdExists==0)
					b1=max(abs(rightx(profile)-b0),abs(leftx(profile)-b0))+b0 
					b1Err=0
			endif
				

			wave/SDFR=dfcal/Z b_Exp
			if(WaveExists(b_Exp)==0)
				make/O/N=0 dfcal:b_Exp, dfcal:b_Err_Exp
			endif
			
			wave/SDFR=dfcal b_Exp
			wave/SDFR=dfcal b_Err_Exp
			
			variable i=numpnts(b_Exp)
			Redimension/N=(i+1) b_Exp, b_Err_Exp
			
			b_Exp[i]=abs(b1-b0)
			b_Err_Exp[i]=sqrt(b1Err^2+b0Err^2)
			
			WaveStats/Q b_Exp
			b_Exp_avg=V_avg
	
			b_Err_CL_avg=V_sem*StatsInvStudentCDF(0.975, V_npnts-1)

			WaveStats/Q b_Err_Exp
			b_Err_Exp_avg=V_avg
			
			
			SetDataFolder dfSav

			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

