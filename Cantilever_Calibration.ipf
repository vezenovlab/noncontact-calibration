#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method.

#include "Cantilever_Calibration_ModeShape"
#include "Cantilever_Calibration_DensityViscosity"
#include "Cantilever_Calibration_MeasureImage"
#include "Cantilever_Calibration_PeakFitFunctions"
#include "Cantilever_Calibration_Errors"
#include "Cantilever_Calibration_ScanParams"
#include <PopupWaveSelector>

//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀↓↓↓
//	↓↓↓		IPFs Constants Table

constant a1=1.0553
constant a2=3.7997
constant b1=3.8018
constant b2=2.7364
constant aZ1=1.0260
constant aZ2=4.0245
constant bZ1=4.1292
constant bZ2=2.4083
constant aX1=0.076203
constant aX2=0.3591
constant bX1=0.453
constant bX2=2.0335
constant visc_H2O=0.000891	// 25 C
constant dens_H2O=997.13	// kg/m^3
constant visc_air=1.8616e-5
constant dens_air=1.1839
constant kT=4.1124e-21
constant kBoltz=1.3806503e-23

// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑
 

Menu "Vezenov Lab"
	"AFM calibration",  MakeTabbedPanel()
	"Update AFM Calibration", UpdateNewVARs()
	"AFM calibration errors", Err_Init(); MakeErrorsPanel()
	"Select PSD [Subtract dark PSD]",  PanelSubDark()
	"Measure cantilever width", PanelGetDistance()
end

Function UpdateNewVARs()
	// ignore procedure if the package hasn't been initialized
	if(DataFolderExists("root:Packages:AFM_Calibration:")==0)
		print "> No AFM Calibration folder found"
		return 1
	endif
	
	// Save current folder
	DFREF dfSav = GetDataFolderDFR()
	// Jump into the calibration folder
	DFREF dfcal=root:Packages:AFM_Calibration:
	SetDataFolder dfcal
	
	// List new NVAR or SVAR references below
	// ... NVAR fit_done for resuming calcs
	NVAR/Z fit_done
	if(!NVAR_Exists(fit_done))
		Variable/G fit_done = 0
		print "> added fit_done variable @ 0"
	endif
	// ...

	// List new NVAR or SVAR references below
	// ... NVAR fit_done for resuming calcs
	NVAR/Z k_avg_Err
	if(!NVAR_Exists(k_avg_Err))
		variable/G k_avg_Err = 0
		print "> added k_avg_Err variable @ 0"
	endif
	// ...

	// ... NVAR OLS_Converge for doing iterations of end moment
	NVAR/Z xlaser_iterate
	if(!NVAR_Exists(xlaser_iterate))
		Variable/G xlaser_iterate = 1
		print "> added variable/G xlaser_iterate variable @ 1"
	endif

	// ... NVAR Iend_NOI for doing iterations of end moment
	NVAR/Z end_m_NOI
	if(!NVAR_Exists(end_m_NOI))
		Variable/G end_m_NOI = 10
		Variable/G check_Scont_use_Snoncont_avg=1 
		Variable/G check_Scont_use_Snoncont_n1=0
		print "> added end_m_NOI variable @ 10"
	endif

	// ... NVAR Iend_NOI for doing iterations of end moment
	NVAR/Z FracMassComp1
	if(!NVAR_Exists(FracMassComp1))
		Rename FracMassComp2 FracMassComp1
//		KillVariables/Z FracMassComp2
//		Variable/G FracMassComp1 = 0
		print "> added FracMassComp1 variable @ 0"
	endif

	
	// return to current folder
	SetDataFolder dfSav

End

//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀↓↓↓
//	↓↓↓		Process Asylum raw PSD and dark background
Function PanelSubDark() : Panel

	if(DataFolderExists("root:Packages:AFM_Calibration:")==0)
		Init_CalcSens()
		init_Peaks()
	endif

	String panelName = "ProcessPSDPanel"

	DoWindow/F $panelName
	if(V_flag==1)
		return 1
	endif


	NewPanel/W=(295,512,650,687) as "Subtract dark PSD"
	DoWindow/C $panelName

	SetVariable wavePSD,pos={32.00,7.00},size={316.00,18.00},title="PSD "
	SetVariable wavePSD,value= root:packages:AFM_Calibration:S_PSD
	SetVariable wavePSDdark,pos={5.00,72.00},size={343.00,18.00},title="dark PSD "
	SetVariable wavePSDdark,value= root:packages:AFM_Calibration:S_PSD_dark
	SetVariable InvOLS_PSD,pos={217.00,30.00},size={131.00,18.00},title="Amp InvOLS"
	SetVariable InvOLS_PSD,limits={0,inf,0},value= root:packages:AFM_Calibration:AmpInvOLS
	Button SubstractBack,pos={99.00,143.00},size={160.00,24.00},proc=ButtonProc_SubtractDark,title="Rescale & subtract dark PSD"
	Button SubstractBack,fColor=(65535,49151,49151)
	CheckBox checkPSDraw,pos={220.00,120.00},size={127.00,15.00},title="dark PSD is unscaled "
	CheckBox checkPSDraw,variable= root:packages:AFM_Calibration:PSD_Dark_IsRaw,side= 1
	SetVariable InvOLS_PSDDark,pos={218.00,97.00},size={131.00,18.00},title="Amp InvOLS"
	SetVariable InvOLS_PSDDark,limits={0,inf,0},value= root:packages:AFM_Calibration:AmpInvOLSDark
	CheckBox checkPSDCorrected,pos={169.00,53.00},size={179.00,15.00},title="PSD is corrected for dark noise "
	CheckBox checkPSDCorrected,variable= root:packages:AFM_Calibration:PSD_Corrected,side= 1
	Button ButtonDisplayPSD,pos={7.00,143.00},size={83.00,24.00},proc=ButtonProc_PlotPSD,title="Plot PSD"
	Button ButtonDisplayPSD,labelBack=(65535,65535,65535),fColor=(49151,60031,65535)
	Button RestorePSD,pos={266.00,143.00},size={83.00,24.00},proc=ButtonProc_RestorePSD,title="Restore"
	Button RestorePSD,labelBack=(65535,65535,65535),fColor=(49151,65535,49151)

	Button PSDWaveSelectorList,pos={8.00,28.00},size={200,20}

	MakeButtonIntoWSPopupButton(panelName, "PSDWaveSelectorList", "ProcessPSDFunc", content = WMWS_Waves)
	PopupWS_MatchOptions(panelName, "PSDWaveSelectorList", matchStr= "*PSD*", listoptions="DIMS:1,TEXT:0,CMPLX:0")

	Button PSDDarkWaveSelectorList,pos={8.00,94.00},size={200,20}

	MakeButtonIntoWSPopupButton(panelName, "PSDDarkWaveSelectorList", "ProcessPSDFunc", content = WMWS_Waves)
	PopupWS_MatchOptions(panelName, "PSDDarkWaveSelectorList", matchStr= "*PSD*", listoptions="DIMS:1,TEXT:0,CMPLX:0")


End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ProcessPSDFunc(event, wavepath, windowName, ctrlName)
	Variable event
	String wavepath
	String windowName
	String ctrlName

//	print "Notification proc: selected item:", wavepath, "; Event Code: ", Event, "; Window: ", WindowName, "; Control: ", ctrlName

	string S_note
	wave/Z w=$wavepath
	
	if(WaveExists(w)==1)
		S_note=note(w)
	else
		return 1
	endif

	if(StringMatch(NameOfWave(w), "*raw*")==1)
		Abort "Cannot use raw back up data for analysis. Restore original PSD first."
	endif
	
	if(strsearch(S_note, "AmpSquared",0)<0)
		S_note+="AmpSquared:0\r"
	endif

	strswitch(ctrlName)
	
		case "PSDWaveSelectorList":

			SVAR S_PSD=root:packages:AFM_Calibration:S_PSD
			S_PSD=wavepath
			
			NVAR AmpInvols=root:packages:AFM_Calibration:AmpInvOLS
			AmpInvols=NumberByKey("AmpInvols", S_note, ":", "\r")
			
			if(numtype(AmpInvols)!=0)
				AmpInvols=1
			endif
			
			if(strsearch(S_note, "PSDDarkCorrected",0)<0)
				S_note+="PSDDarkCorrected:0\r"
			endif

			NVAR PSD_Corrected=root:packages:AFM_Calibration:PSD_Corrected
			PSD_Corrected=NumberByKey("PSDDarkCorrected", S_note, ":", "\r")


		break
	
		case "PSDDarkWaveSelectorList":

			SVAR S_PSD_dark=root:packages:AFM_Calibration:S_PSD_dark
			S_PSD_dark=wavepath

			NVAR AmpInvolsDark=root:packages:AFM_Calibration:AmpInvOLSDark
			AmpInvolsDark=NumberByKey("AmpInvols", S_note, ":", "\r")

			if(numtype(AmpInvolsDark)!=0)
				AmpInvolsDark=1
			endif

			NVAR PSD_Dark_IsRaw=root:packages:AFM_Calibration:PSD_Dark_IsRaw
			
			if(AmpInvolsDark==1)
				PSD_Dark_IsRaw=0
			else
				PSD_Dark_IsRaw=1
			endif

		break

	endswitch

	Note/K w
	Note w, S_note

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ButtonProc_PlotPSD(ba) : ButtonControl
	STRUCT WMButtonAction &ba


	switch( ba.eventCode )
		case 2: // mouse up
			// click code here

			SVAR S_PSD=root:packages:AFM_Calibration:S_PSD
			wave/Z w=$S_PSD

			if(WaveExists(w)==1)
			
				PlotPSD(w)
			
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
Function PlotPSD(wPSD)
	wave wPSD

	DFREF dfcal=root:Packages:AFM_Calibration:
	SVAR CurrentGraph=dfcal:CurrentGraph
	SVAR listPSD=dfcal:listPSD
	SVAR S_PSD=dfcal:S_PSD
	SVAR PSD=dfcal:PSD
	NVAR cursors_checked=dfcal:cursors_checked
	
	Display wPSD
	CurrentGraph=WinName(0,1)
	PSD=S_PSD
	ModifyGraph log=1,mirror=2
	SetAxis bottom 20,*
	Label left "PSD (V\\S2\\M/Hz)"
	Label bottom "Frequency"
	
	
	DoWindow/F Panel_Cal
	
	if(V_flag==0)
		return 1
	endif
	
	string S_popmenu
	S_popmenu=WinList("*", ";", "WIN:1")
	S_popmenu="\""+ReplaceString(CurrentGraph, S_popmenu, "\\M0: !*:"+CurrentGraph,1,1)+"\""
	PopupMenu Graph_tab1, win=Panel_Cal, value= #S_popmenu, popvalue=CurrentGraph


	string PSDname=NameOfWave(wPSD)
	listPSD=TraceNameList(currentGraph, ";",1)
	PopupMenu PSD_tab1, win=Panel_Cal, value=#"root:Packages:AFM_Calibration:listPSD"
		
	S_popmenu=listPSD
	S_popmenu="\""+ReplaceString(PSDname, S_popmenu, "\\M0: !*:"+PSDname,1,1)+"\""
	PopupMenu PSD_tab1, win=Panel_Cal,value= #S_popmenu, popvalue=PSDname

	if(cursors_checked)
		Cursor_Add2Plot()
	else
		Cursor/K A
		Cursor/K B
	endif


End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ButtonProc_RestorePSD(ba) : ButtonControl
	STRUCT WMButtonAction &ba


	switch( ba.eventCode )
		case 2: // mouse up
			// click code here

			SVAR S_PSD=root:packages:AFM_Calibration:S_PSD
			wave/Z w=$S_PSD
		
			if(WaveExists(w)==1)
				DFREF  dfPSD=GetWavesDataFolderDFR(w)
				if(WaveExists(dfPSD:PSDraw)==1)
					Duplicate/O dfPSD:PSDraw, w
				endif
			endif
			
			ProcessPSDFunc(1, S_PSD, "", "PSDWaveSelectorList")

			SVAR S_PSD_dark=root:packages:AFM_Calibration:S_PSD_dark

			wave/Z w=$S_PSD_dark

			if(WaveExists(w)==1)
				DFREF  dfPSD=GetWavesDataFolderDFR(w)
				if(WaveExists(dfPSD:PSD_Darkraw)==1)
					Duplicate/O dfPSD:PSD_Darkraw, w
				endif
			endif

			ProcessPSDFunc(1, S_PSD_dark, "", "PSDDarkWaveSelectorList")

			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ButtonProc_SubtractDark(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here

			SVAR S_PSD=root:packages:AFM_Calibration:S_PSD
			SVAR S_PSD_dark=root:packages:AFM_Calibration:S_PSD_dark
			wave/Z wPSD=$S_PSD
			wave/Z wPSD_dark=$S_PSD_dark
			NVAR AmpInvols=root:packages:AFM_Calibration:AmpInvOLS
			NVAR AmpInvolsDark=root:packages:AFM_Calibration:AmpInvOLSDark
			NVAR PSD_Dark_IsRaw=root:packages:AFM_Calibration:PSD_Dark_IsRaw
			NVAR PSD_Corrected=root:packages:AFM_Calibration:PSD_Corrected

			Process_AR_PSD(wPSD,AmpInvols,wPSD_dark,AmpInvolsDark,PSD_Dark_IsRaw)
			
			AmpInvols=1
			AmpInvolsDark=1
			PSD_Corrected=1

			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Process_AR_PSD(wPSD, AmpInvols, wPSD_dark,AmpInvolsDark,PSD_Dark_IsRaw)
	wave/Z wPSD
	variable AmpInvols
	wave/Z wPSD_dark
	variable AmpInvolsDark
	variable PSD_Dark_IsRaw
	
	if(WaveExists(wPSD)==0)
		Abort "PSD data wave not found."
	endif

	string S_note=note(wPSD)
	variable IsPSDCorrected=NumberByKey("PSDDarkCorrected", S_note, ":", "\r")
	
	if(IsPSDCorrected==1)
		Abort "PSD data is already corrected for dark noise."
	endif

	variable V_AmpInvols=NumberByKey("AmpInvols", S_note, ":", "\r")

	if(V_AmpInvols!=1)
		DFREF  dfPSD=GetWavesDataFolderDFR(wPSD)
		Duplicate/O wPSD, dfPSD:PSDraw
	endif
	
	// scale PSD data and update scaling
	wPSD/=AmpInvols
	
	S_note=ReplaceNumberByKey("AmpInvols", S_note, 1, ":", "\r")
	
	// square PSD data and update units
	variable IsSquared=NumberByKey("AmpSquared", S_note, ":", "\r")

	if(IsSquared==0)
		wPSD*=wPSD
		S_note=ReplaceNumberByKey("AmpSquared", S_note, 1, ":", "\r")
	endif
	
	Note/K wPSD
	Note wPSD, S_note

	if(WaveExists(wPSD_dark))
	
		// store copy of raw dark PSD
		if(PSD_Dark_IsRaw==1)
			DFREF  dfPSD=GetWavesDataFolderDFR(wPSD_dark)
			if(WaveExists(dfPSD:PSD_Darkraw)==0)
				Duplicate/O wPSD_dark, dfPSD:PSD_Darkraw
			endif
		endif

		// scale dark PSD and update scaling and units
		S_note=note(wPSD_dark)
		S_note=ReplaceNumberByKey("AmpInvols", S_note, 1, ":", "\r")
		
		IsSquared=NumberByKey("AmpSquared", S_note, ":", "\r")
		
		if(IsSquared==0)
			wPSD_dark/=AmpInvolsDark
			wPSD_dark*=wPSD_dark
			S_note=ReplaceNumberByKey("AmpSquared", S_note, 1, ":", "\r")
		else
			wPSD_dark/=AmpInvolsDark^2
		endif

		Note/K wPSD_dark
		Note wPSD_dark, S_note

		// Subtract dark PSD an dupdate wave note
		wPSD-=wPSD_dark(x)

		S_note=note(wPSD)
		S_note=ReplaceNumberByKey("PSDDarkCorrected", S_note, 1, ":", "\r")

		Note/K wPSD
		Note wPSD, S_note
		
	endif

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑

// Main package initialization

//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀↓↓↓
//	↓↓↓		Initialize the variables for the panel 

Function Init_CalcSens()

	SetDataFolder root:

	NewDataFolder/O root:SavedCal

	NewDataFolder/O/S packages

	NewPath/O Path_AFMCalibration, SpecialDirPath("Igor Pro User Files", 0, 0, 0)+"User Procedures:Code AFM Calibration - Shortcut"
	
	LoadData/Q/O/T=SolventData/P=Path_AFMCalibration "SolventData.pxp"

	SetDataFolder root:packages:
	NewDataFolder/O/S AFM_Calibration
	
	LoadWave/H/O/P=Path_AFMCalibration "GammaFvs_Re_modeIm.ibw"
	LoadWave/H/O/P=Path_AFMCalibration "GammaFvs_Re_modeRe.ibw"
	LoadWave/H/O/P=Path_AFMCalibration "GammaTvs_Re_modeIm.ibw"
	LoadWave/H/O/P=Path_AFMCalibration "GammaTvs_Re_modeRe.ibw"
	
	//KillPath/A

	// variable for subtract dark PSD panel
	string/G S_PSD_dark
	string/G S_PSD
	variable/G AmpInvOLS
	variable/G AmpInvOLSDark
	variable/G PSD_Corrected=0
	variable/G PSD_Dark_IsRaw=1

	// correct for different definition of hydrodynamic function: Gt=4*Gt_Sader
	wave GammaTvs_Re_modeIm
	wave GammaTvs_Re_modeRe
	GammaTvs_Re_modeIm*=4
	GammaTvs_Re_modeRe*=4
	
	String/G List_visc="air:1.8616e-5;water:0.000891;EG:1.4e-2;EtOH:0.0012"
	String/G List_dens="air:1.1839;water:997.13;EG:1113.2;EtOH:789"
	
	variable/G cant_a=50e-6
	variable/G cant_b=50e-6
	variable/G cant_width=50e-6
	variable/G cant_length=200e-6
	variable/G cant_C=0
	variable/G cant_D=0
	variable/G cant_thickness=2e-6
	variable/G cant_Xlaser=200e-6
	
	// Set effective length for arrow-shaped cantilevers
	// use in calculation of norm mode number
	// and cantilever and fluid mass
	variable/G cant_length_e
	SetFormula cant_length_e, "cant_length-cant_D/2*(1-cant_C/cant_width)"

	variable/G cant_E_modulus=169e9
	variable/G cant_G_modulus=50.9e9
	variable/G cant_Poisson_ratio=0.25
	variable/G cant_rho=2.329e3
	variable/G coat_a_thick=0, coat_b_thick=0
	variable/G coat_a_rho=19.30e3
	variable/G coat_a_E_modulus=79e9
	variable/G coat_a_G_modulus=27e9
	variable/G coat_b_rho=19.30e3
	variable/G coat_b_E_modulus=79e9
	variable/G coat_b_G_modulus=27e9
	
	variable/G cant_inclination=15
	
	variable/G coat_b_thick1=0, coat_b_thick2=0
	
	// Set effective (average) values for density, Young's modulus, thickness, and width
	variable/G cant_rho_e=2.329e3
	variable/G cant_E_modulus_e=169e9
	variable/G cant_G_modulus_e=50.9e9
	variable/G cant_thickness_e=2e-6
	
	SetFormula cant_thickness_e, "(cant_thickness+coat_a_thick+coat_b_thick)"
	SetFormula cant_E_modulus_e, "(cant_E_modulus*cant_thickness+coat_a_E_modulus*coat_a_thick+coat_b_E_modulus*coat_b_thick)/cant_thickness_e"
	SetFormula cant_G_modulus_e, "(cant_G_modulus*cant_thickness+coat_a_G_modulus*coat_a_thick+coat_b_G_modulus*coat_b_thick)/cant_thickness_e"
	SetFormula cant_rho_e, "(cant_rho*cant_thickness+coat_a_rho*coat_a_thick+coat_b_rho*coat_b_thick)/cant_thickness_e"
	
	variable/G width_is_avg=0, width_is_b=1, width_is_a=0, width_scale=1
	SetFormula cant_width, "cant_a+(cant_b-cant_a)*width_scale"
	
	string/G cant_mater="Si", coat_a_mater="Au", coat_b_mater="Au"
	string/G List_matDen="Si:2.329e3;Au:19.30e3;Al:2.70e3;Ag:10.49e3;Pt:21.45e3;"
	string/G List_matE="Si:169e9;Au:79e9;Al:70e9;Ag:83e9;Pt:168e9;"
	string/G List_matG="Si:50.9e9;Au:27e9;Al:26e9;Ag:30e9;Pt:61e9;"

	string/G Vendor="_select_"
	string/G ProbeModel="_select_"

	variable/G tip_H=10e-6
	variable/G tip_angle1=25
	variable/G tip_angle2=20
	variable/G tip_angle3=40
	variable/G tip_Xoffset=0e-6
	variable/G tip_Yoffset=0
	
	string/G tip_Shape="cone"
	
	variable/G tip_H_e
	SetFormula tip_H_e, "(tip_H+cant_thickness_e/2)"
	variable/G htip
	SetFormula htip, "tip_H_e/cant_length"

	variable/G mend2mc=0
	variable/G Iend2Ic=0
	variable/G xlaser
	variable/G xtip
	variable/G ytip
	variable/G NOP_xlaser=20, NOP_mend=20, NOP_Iend=7 
	Variable/G Range_Xlaser=0.1, Range_mend=0.1, Range_Iend=0.001
	variable/G Iend_k=4
	variable/G mend2mc_positive=1
	variable/G Iend_Sy_Coverge
	variable/G Iend_NOI
	
	SetFormula xlaser, "cant_Xlaser/cant_length"
	SetFormula xtip, "1-tip_Xoffset/cant_length"
	SetFormula ytip, "Norm_Ytip(tip_Yoffset,tip_H_e)"

	string/G medium="air"

	variable/G Medium_dens=dens_air
	variable/G Medium_visc= visc_air
	variable/G Medium_temperature=295
	variable/G p_atm=101325
	variable/G RH=50
	variable/G FracMassComp1
	
	variable/G cant_kappa=0, ReNum=100, Relog=2
	variable/G use_fixed_kappa=0, kappa=0, use_fitted_Coef=0
	variable/G DoNumericalIntegral=0
	variable/G use_mend=1
	variable/G fixQ=0
		
	variable/G kz_theory, kz_thermal, kz_Sader, kz_FluidStruc
	variable/G kTheta_theory, kTheta_thermal, kTheta_Sader, kTheta_FluidStruc
	variable/G ky_theory, ky_thermal, ky_Sader, ky_FluidStruc
	variable/G SFy_noncont=nan, Sy_noncont=nan, Sslopey_noncont=nan 
	variable/G SFz_noncont=nan, Sz_noncont=nan, Sslopez_noncont=nan
	variable/G SFz_cont=nan, Sz_cont=nan, Sslopez_cont=nan
	variable/G SFy_cont=nan, Sy_cont=nan, Sslopey_cont=nan
	variable/G Sz_CorrectionFactor=1
	variable/G Sy_CorrectionFactor=1
	variable/G check_SFcont_use_kthermal=1
	variable/G check_Scont_use_Snoncont_avg=1
	variable/G check_Scont_use_Snoncont_n1=0
	variable/G xlaser_iterate=1
	variable/G k_avg_Err = 0
	
	variable/G G_option=0
	
	variable/G V_Gamma_r=0
	variable/G V_Gamma_i=0	
	
	variable/G Detect_MTF=1
	variable/G Detect_MTF_ignore=0
	variable/G Detect_MTF_fix=0
	
	variable/G fit_done=0

	variable/G num_peaks=1, current_peak=1, num_peaksSav=1
	variable/G use_current=0
	variable/G use_1overf=0
	variable/G fitType=1
	variable/G V_BackScale=1
	variable/G V_BackScaleLog=0
	variable/G use_ScaleBack=0

	variable/G globalTau=0
	variable/G globalWidth=0
	variable/G globalpq=0
	
	variable/G Chisq=0
	variable/G iterate_do=0
	variable/G iterate_max=4
	variable/G V_delta_max=200
	variable/G V_GrealErr_avg
	variable/G V_GimagErr_avg
	
	variable/G currentpeak_checked=0
	variable/G cursors_checked=0
	variable/G fit_checked=0
	variable/G background_checked=0
	
	String/G FittingFunc="SHO"
	String/G FittingFuncBack="line"
	
	String/G model="SHO"
	String/G model_Back="constant"
	String/G CurrentGraph=""
	String/G PSD=""
	String/G listPSD=""
	String/G Spectrum_type="normal"
	String/G k_type="theory"
	String/G GammafitType="type 1"
	
	String/G DF_SavCal=""
	String/G DF_LoadCal=""
	String/G DF_DeleteCal=""
	String/G Data2Load="all"

// create wave for amplitude
	make/O/N=400 Ampl
	SetScale/I x 0,1,"", Ampl
	SetFormula Ampl, "Phi_n_m(current_peak,x,mend2mc)"
	make/O/N=1 LaserY, LaserX
	SetFormula LaserX, "cant_Xlaser/cant_length"
	SetFormula LaserY, "Ampl(cant_Xlaser/cant_length)"

	variable/G Cn, Dn
	SetFormula Cn, "C_n_m(current_peak,mend2mc)"
	SetFormula Dn, "D_n_m(current_peak,Iend2Ic)"
	
// 	Sz_CorrectionFactor=Calc_Sz_CorrectionFactor(Current_peak, xtip, xlaser,mend2mc, htip, cant_inclination)
 	Sz_CorrectionFactor=Calc_Sz_CorrectionFactor(1, xtip, xlaser, mend2mc, htip, cant_inclination)
// Calc_Sy_CorrectionFactor(n, xlaser, Iend2Ic)
	Sy_CorrectionFactor=Calc_Sy_CorrectionFactor(1, xlaser, Iend2Ic)
	
	// check_Kequip, check_KSader, check_KdiffEqSader, check_KdiffEqSadern1
	string/G S_ErrorKey="Kequip:0;KSader:0;KdiffEqSader:0;KdiffEqSadern1:0"
	variable/G k_avg_Eq, k_avg_Eq_Err
	variable/G k_avg_Sader, k_avg_Sader_Err
	variable/G k_avg_Eqn1, k_avg_Eqn1_Err
	variable/G k_avg_Sadern1, k_avg_Sadern1_Err
	variable/G DirectionDim=0
	variable/G DoInsetParamScan=1

	SetDataFolder root:

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


// End of main package initialization

// MAKING MAIN PANEL

//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function TabProc2(ctrlName,tabNum) : TabControl
	String ctrlName	
	Variable tabNum

	String controlsInATab= ControlNameList("", ";", "*_tab*")

	String curTabMatch= "*_tab"+num2istr(tabNum)
	String controlsInCurTab= ListMatch(controlsInATab, curTabMatch)
	String controlsInOtherTabs= ListMatch(controlsInATab, "!"+curTabMatch)

	ModifyControlList controlsInOtherTabs disable=1	// hide
	ModifyControlList controlsInCurTab disable=0		// show
	
	if(tabNum==0)
	else
	endif

	switch(tabNum)
	
		case 0:
			Panel_DrawTip_tab0()
			KillWindow/Z Panel_Cal#modeshape
		break
		
		
		case 1:
			Panel_DrawShape_tab1()
			KillWindow/Z Panel_Cal#PanelDrawTip
		break

		case 2:
			KillWindow/Z Panel_Cal#PanelDrawTip
			KillWindow/Z Panel_Cal#modeshape
		break
	
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function MakeTabbedPanel()

	DoWindow/F Panel_Cal
	
	if(V_flag==1)
		return 1
	endif

	NewPanel /W=(681,84,1118,720)/K=0 as "Cantilever Calibration"
	ModifyPanel fixedSize=0
	DoWindow/C Panel_Cal


	DFREF dfSav = GetDataFolderDFR()
	if(DataFolderExists("root:Packages:AFM_Calibration:")==0)
		Init_CalcSens()
		init_Peaks()
		Err_Init()
	endif

	TabControl tab,pos={6.00,4.00},size={424.00,628.00},proc=TabProc2
	TabControl tab,tabLabel(0)="Parameters",tabLabel(1)="Data & Model"
	TabControl tab,tabLabel(2)="Spring Const & Sens",value= 0

	Panel_tab0()
	Panel_tab1()
	Panel_tab2()

	ModifyControlList ControlNameList("", ";", "*_tab1") disable=1
	ModifyControlList ControlNameList("", ";", "*_tab2") disable=1
	
	Panel_DrawTip_tab0()

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function MakeTabProc() 

	//Panel_Cal_tab2()
	
	String controlsInATab= ControlNameList("", ";", "**")
	
	String NewControlsInATab=ReplaceString(";", controlsInATab, "_tab2;")

	ModifyControlList controlsInATab rename=$NewControlsInATab
	variable NOP=ItemsInList(controlsInATab)
	
	variable i=0	
	
	for(i=0;i<NOP;i+=1)
		ModifyControl/Z $StringFromList(i, controlsInATab) rename=$StringFromList(i, NewControlsInATab)
	endfor

	Print i, NOP
	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Panel_tab0() : Panel

	GroupBox cant_tab0,pos={13.00,28.00},size={198.00,319.00},title="Cantilever"
	GroupBox cant_tab0,fSize=12,fStyle=1
	SetVariable length_tab0,pos={46.00,49.00},size={155.00,18.00},bodyWidth=100,proc=SetVarProc_UpdateCantParam,title="length (L)"
	SetVariable length_tab0,format="%.3e m"
	SetVariable length_tab0,limits={0,inf,0},value= root:packages:AFM_Calibration:cant_length
	SetVariable b_tab0,pos={28.00,161.00},size={173.00,18.00},bodyWidth=100,title="top width (b)"
	SetVariable b_tab0,format="%.3e m"
	SetVariable b_tab0,limits={0,inf,0},value= root:packages:AFM_Calibration:cant_b
	SetVariable a_tab0,pos={26.00,139.00},size={175.00,18.00},bodyWidth=100,title="bot. width (a)"
	SetVariable a_tab0,format="%.3e m"
	SetVariable a_tab0,limits={0,inf,0},value= root:packages:AFM_Calibration:cant_a
	SetVariable c_tab0,pos={27.00,117.00},size={174.00,18.00},bodyWidth=100,title="end width (c)"
	SetVariable c_tab0,format="%.3e m"
	SetVariable c_tab0,limits={0,inf,0},value= root:packages:AFM_Calibration:cant_c
	SetVariable thickness_tab0,pos={35.00,236.00},size={166.00,18.00},bodyWidth=98,title="thickness (t)"
	SetVariable thickness_tab0,format="%.3e m"
	SetVariable thickness_tab0,limits={0,inf,0},value= root:packages:AFM_Calibration:cant_thickness
	SetVariable E_tab0,pos={29.00,279.00},size={172.00,18.00},bodyWidth=98,title="Young's mod"
	SetVariable E_tab0,format="%.4g Pa"
	SetVariable E_tab0,limits={0,inf,0},value= root:packages:AFM_Calibration:cant_E_modulus
	SetVariable density_tab0,pos={61.00,257.00},size={140.00,18.00},bodyWidth=98,title="density"
	SetVariable density_tab0,format="%.4g kg/m³"
	SetVariable density_tab0,limits={0,inf,0},value= root:packages:AFM_Calibration:cant_rho
	CheckBox widthMode_a_tab0,pos={26.00,215.00},size={36.00,15.00},proc=CheckProc_SelectWidth,title=" = a"
	CheckBox widthMode_a_tab0,variable= root:packages:AFM_Calibration:width_is_a,mode=1
	CheckBox widthMode_b_tab0,pos={152.00,215.00},size={37.00,15.00},proc=CheckProc_SelectWidth,title=" = b"
	CheckBox widthMode_b_tab0,variable= root:packages:AFM_Calibration:width_is_b,mode=1
	CheckBox widthMode_avg_tab0,pos={75.00,215.00},size={70.00,15.00},proc=CheckProc_SelectWidth,title=" = (a+b)/2"
	CheckBox widthMode_avg_tab0,variable= root:packages:AFM_Calibration:width_is_avg,mode=1
	SetVariable width_avg_tab0,pos={19.00,183.00},size={182.00,18.00},bodyWidth=100,proc=SetVarProc_UpdateWidth,title="effective width"
	SetVariable width_avg_tab0,format="%.3e m"
	SetVariable width_avg_tab0,limits={0,inf,0},value= root:packages:AFM_Calibration:cant_width
	GroupBox Media_Params_tab0,pos={217.00,418.00},size={204.00,180.00},title="Medium"
	GroupBox Media_Params_tab0,fStyle=1
	SetVariable Med_density_tab0,pos={265.00,480.00},size={142.00,18.00},bodyWidth=100,title="density"
	SetVariable Med_density_tab0,format="%.5g kg/m³"
	SetVariable Med_density_tab0,limits={0,inf,0},value= root:packages:AFM_Calibration:Medium_dens
	SetVariable viscosity_tab0,pos={258.00,502.00},size={149.00,18.00},bodyWidth=100,title="viscosity"
	SetVariable viscosity_tab0,format="%.5g Pa s"
	SetVariable viscosity_tab0,limits={0,inf,0},value= root:packages:AFM_Calibration:Medium_visc
	SetVariable PossionRatio_tab0,pos={31.00,300.00},size={170.00,18.00},bodyWidth=98,title="Poisson ratio"
	SetVariable PossionRatio_tab0,format="%.4g"
	SetVariable PossionRatio_tab0,limits={0,inf,0},value= root:packages:AFM_Calibration:cant_Poisson_ratio
	PopupMenu MediumPure_tab0,pos={223.00,436.00},size={80.00,19.00},bodyWidth=80,proc=PopMenuProc_SelectMediumPure
	PopupMenu MediumPure_tab0,mode=1,popvalue="Acetaldehyde",value= #"root:packages:SolventData:S_Name"
	PopupMenu Medium_tab0,pos={309.00,436.00},size={100.00,19.00},bodyWidth=100,proc=PopMenuProc_SelectMedium
	PopupMenu Medium_tab0,mode=1,popvalue="air",value= #"\"\\M0: !*:air;water;Ethanol;Methanol;water-EG;water-EtOH;water-MeOH;MeOH-water;EtOH-water;MeOH-EtOH;EtEG-water;diEG-water;glycerol-water;dioxane-water;dioxane-EG;\""
	SetVariable Medium_temperature_tab0,pos={240.00,458.00},size={167.00,18.00},bodyWidth=98,proc=SetVarProc_SetTemp,title="temperature"
	SetVariable Medium_temperature_tab0,format="%.5g K"
	SetVariable Medium_temperature_tab0,limits={0,inf,0},value= root:packages:AFM_Calibration:Medium_temperature
	SetVariable Atm_pressure_tab0,pos={233.00,525.00},size={174.00,18.00},bodyWidth=99,proc=SetVarProc_SetTemp,title="atm. pressure"
	SetVariable Atm_pressure_tab0,format="%6g Pa"
	SetVariable Atm_pressure_tab0,limits={0,inf,0},value= root:packages:AFM_Calibration:p_atm
	SetVariable RH_tab0,pos={236.00,548.00},size={171.00,18.00},bodyWidth=100,proc=SetVarProc_SetTemp,title="rel. humidity"
	SetVariable RH_tab0,format="%4g %"
	SetVariable RH_tab0,limits={0,inf,0},value= root:packages:AFM_Calibration:RH
	SetVariable FracMassComp1_tab0,pos={234.00,571.00},size={173.00,18.00},bodyWidth=100,proc=SetVarProc_SetTemp,title="component 1"
	SetVariable FracMassComp1_tab0,format="%4g (mole frac.)"
	SetVariable FracMassComp1_tab0,limits={0,1,0.05},value= root:packages:AFM_Calibration:FracMassComp1
	GroupBox tip_tab0,pos={216.00,284.00},size={206.00,132.00},title="Tip",fStyle=1
	PopupMenu TipShape_tab0,pos={230.00,301.00},size={176.00,19.00},bodyWidth=141,proc=PopMenuProc_SelectTipShape,title="Shape"
	PopupMenu TipShape_tab0,mode=4,popvalue="square piramid",value= #"\"cone;trigonal piramid;tetragonal piramid;\\M0: !*:square piramid;hollow sq. piramid\""
	SetVariable tip_H_tab0,pos={251.00,323.00},size={155.00,18.00},bodyWidth=97,title="height (H)"
	SetVariable tip_H_tab0,format="%.3e m"
	SetVariable tip_H_tab0,limits={0,inf,0},value= root:packages:AFM_Calibration:tip_H
	SetVariable tip_angle1_tab0,pos={220.00,344.00},size={119.00,20.00},bodyWidth=36,title="angle (α\\B1\\M,α\\B2\\M,α\\B3\\M)"
	SetVariable tip_angle1_tab0,format="%3.1f °"
	SetVariable tip_angle1_tab0,limits={0,90,0},value= root:packages:AFM_Calibration:tip_angle1
	SetVariable tip_angle2_tab0,pos={342.00,345.00},size={36.00,18.00},bodyWidth=36,title=" "
	SetVariable tip_angle2_tab0,format="%3.1f °"
	SetVariable tip_angle2_tab0,limits={0,90,0},value= root:packages:AFM_Calibration:tip_angle2
	SetVariable tip_angle3_tab0,pos={381.00,345.00},size={36.00,18.00},bodyWidth=36,title=" "
	SetVariable tip_angle3_tab0,format="%3.1f °"
	SetVariable tip_angle3_tab0,limits={0,90,0},value= root:packages:AFM_Calibration:tip_angle3
	SetVariable tip_Xoffset_tab0,pos={223.00,367.00},size={185.00,19.00},bodyWidth=99,title="tip X offset (\\F'Symbol'Δ\\F'Segoe UI'L)"
	SetVariable tip_Xoffset_tab0,format="%.3e m"
	SetVariable tip_Xoffset_tab0,limits={0,inf,0},value= root:packages:AFM_Calibration:tip_Xoffset
	SetVariable tip_Yoffset_tab0,pos={220.00,390.00},size={188.00,20.00},bodyWidth=99,title="tip Y offset (Y\\Btip\\M)"
	SetVariable tip_Yoffset_tab0,format="%.3e m"
	SetVariable tip_Yoffset_tab0,limits={0,inf,0},value= root:packages:AFM_Calibration:tip_Yoffset
	GroupBox Coat1_Params_tab0,pos={13.00,349.00},size={198.00,89.00},title="Coating a (bottom)"
	GroupBox Coat1_Params_tab0,fStyle=1
	Slider slider_width_tab0,pos={63.00,203.00},size={130.00,10.00},proc=SliderProc_updateWidth
	Slider slider_width_tab0,limits={0,1,0},variable= root:packages:AFM_Calibration:width_scale,live= 0,side= 0,vert= 0
	SetVariable thickness_ta_tab0,pos={32.00,366.00},size={171.00,20.00},bodyWidth=99,title="thickness (t\\Ba\\M)"
	SetVariable thickness_ta_tab0,format="%.3e m"
	SetVariable thickness_ta_tab0,limits={0,inf,0},value= root:packages:AFM_Calibration:coat_a_thick
	SetVariable thickness_tb_tab0,pos={32.00,458.00},size={171.00,20.00},bodyWidth=98,title="thickness (t\\Bb\\M)"
	SetVariable thickness_tb_tab0,format="%.3e m"
	SetVariable thickness_tb_tab0,limits={0,inf,0},value= root:packages:AFM_Calibration:coat_b_thick
	SetVariable density_ta_tab0,pos={63.00,391.00},size={140.00,18.00},bodyWidth=98,title="density"
	SetVariable density_ta_tab0,format="%.4g kg/m³"
	SetVariable density_ta_tab0,limits={0,inf,0},value= root:packages:AFM_Calibration:coat_a_rho
	SetVariable E_ta_tab0,pos={31.00,414.00},size={172.00,18.00},bodyWidth=98,title="Young's mod"
	SetVariable E_ta_tab0,format="%.4g Pa"
	SetVariable E_ta_tab0,limits={0,inf,0},value= root:packages:AFM_Calibration:coat_a_E_modulus
	SetVariable density_tb_tab0,pos={63.00,483.00},size={140.00,18.00},bodyWidth=98,title="density"
	SetVariable density_tb_tab0,format="%.4g kg/m³"
	SetVariable density_tb_tab0,limits={0,inf,0},value= root:packages:AFM_Calibration:coat_b_rho
	SetVariable E_tb_tab0,pos={31.00,506.00},size={172.00,18.00},bodyWidth=98,title="Young's mod"
	SetVariable E_tb_tab0,format="%.4g Pa"
	SetVariable E_tb_tab0,limits={0,inf,0},value= root:packages:AFM_Calibration:coat_b_E_modulus
	SetVariable D_tab0,pos={26.00,71.00},size={175.00,18.00},bodyWidth=100,title="arrow len. (D)"
	SetVariable D_tab0,format="%.3e m"
	SetVariable D_tab0,limits={0,inf,0},value= root:packages:AFM_Calibration:cant_D
	SetVariable xspot_tab0,pos={39.00,93.00},size={162.00,20.00},bodyWidth=100,proc=SetVarProc_UpdateCantParam,title="laser (X\\Blaser\\M)"
	SetVariable xspot_tab0,format="%.3e m"
	SetVariable xspot_tab0,limits={0,inf,0},value= root:packages:AFM_Calibration:cant_Xlaser
	GroupBox Coat2_Params_tab0,pos={13.00,441.00},size={197.00,90.00},title="Coating b (top)"
	GroupBox Coat2_Params_tab0,fStyle=1
	PopupMenu Material_t_tab0,pos={20.00,256.00},size={37.00,19.00},bodyWidth=37,proc=PopMenuProc_SelectMat
	PopupMenu Material_t_tab0,mode=1,popvalue="Si",value= #"\"\\M0: !*:Si;Au;Al;Ag;Pt;SiN\""
	PopupMenu Material_ta_tab0,pos={20.00,391.00},size={37.00,19.00},bodyWidth=37,proc=PopMenuProc_SelectMat
	PopupMenu Material_ta_tab0,mode=2,popvalue="Au",value= #"\"Si;\\M0: !*:Au;Al;Ag;Pt;SiN\""
	PopupMenu Material_tb_tab0,pos={20.00,483.00},size={37.00,19.00},bodyWidth=37,proc=PopMenuProc_SelectMat
	PopupMenu Material_tb_tab0,mode=2,popvalue="Au",value= #"\"Si;\\M0: !*:Au;Al;Ag;Pt;SiN\""
	GroupBox ProbeDB_tab0,pos={13.00,533.00},size={197.00,92.00},title="Probe Database"
	GroupBox ProbeDB_tab0,fStyle=1
	PopupMenu Vendor_tab0,pos={23.00,550.00},size={180.00,19.00},bodyWidth=140,proc=PopMenuProc_ProbeVendor,title="Vendor"
	PopupMenu Vendor_tab0,mode=1,popvalue="_select_",value= #"\"\\M0: !*:_select_;Budget Sensors;Bruker;Olympus\""
	PopupMenu Model_tab0,pos={26.00,574.00},size={177.00,19.00},bodyWidth=140,proc=PopMenuProc_ProbeModel,title="Model"
	PopupMenu Model_tab0,mode=1,popvalue="_select_",value= #"\"\\M0: !*:_select_;CONT75;\""
	Button LoadParamDB_tab0,pos={63.00,596.00},size={122.00,24.00},proc=ButtonProc_LoadDBProbeParams,title="Load probe params"
	Button ScanXlaserMend_tab0,pos={244.00,601.00},size={152.00,24.00},proc=ButtonProc_ScanXlaserPanel,title="Scan X\\Blaser\\M or m\\Bend\\M/m\\Bc"
	SetVariable InclinationAngle_tab0,pos={43.00,322.00},size={158.00,18.00},bodyWidth=98,title="Inclination"
	SetVariable InclinationAngle_tab0,format="%3.1f °"
	SetVariable InclinationAngle_tab0,limits={0,90,0},value= root:packages:AFM_Calibration:cant_inclination

	string S_popmenu
	variable V_mode
	
	SVAR medium = root:packages:AFM_Calibration:medium
	S_popmenu=Get_S_popmenu(medium, "Medium_tab0", "Panel_Cal")
	V_mode=Get_N_popmenu(medium, "Medium_tab0", "Panel_Cal")
	PopupMenu Medium_tab0,value= #S_popmenu,popvalue=medium,mode=V_mode

	SVAR tip_Shape = root:packages:AFM_Calibration:tip_Shape
	S_popmenu=Get_S_popmenu(tip_Shape, "TipShape_tab0", "Panel_Cal")
	V_mode=Get_N_popmenu(tip_Shape, "TipShape_tab0", "Panel_Cal")
	PopupMenu TipShape_tab0,value= #S_popmenu,popvalue=tip_Shape,mode=V_mode

	SVAR cant_mater = root:packages:AFM_Calibration:cant_mater
	S_popmenu=Get_S_popmenu(cant_mater, "Material_t_tab0", "Panel_Cal")
	V_mode=Get_N_popmenu(cant_mater, "Material_t_tab0", "Panel_Cal")
	PopupMenu Material_t_tab0,value= #S_popmenu,popvalue=cant_mater,mode=V_mode

	SVAR coat_a_mater = root:packages:AFM_Calibration:coat_a_mater
	S_popmenu=Get_S_popmenu(coat_a_mater, "Material_ta_tab0", "Panel_Cal")
	V_mode=Get_N_popmenu(coat_a_mater, "Material_ta_tab0", "Panel_Cal")
	PopupMenu Material_ta_tab0,value= #S_popmenu,popvalue=coat_a_mater,mode=V_mode

	SVAR coat_b_mater = root:packages:AFM_Calibration:coat_b_mater
	S_popmenu=Get_S_popmenu(coat_b_mater, "Material_tb_tab0", "Panel_Cal")
	V_mode=Get_N_popmenu(coat_b_mater, "Material_tb_tab0", "Panel_Cal")
	PopupMenu Material_tb_tab0,value= #S_popmenu,popvalue=coat_b_mater,mode=V_mode

	SVAR Vendor = root:packages:AFM_Calibration:Vendor
	S_popmenu=Get_S_popmenu(Vendor, "Vendor_tab0", "Panel_Cal")
	V_mode=Get_N_popmenu(Vendor, "Vendor_tab0", "Panel_Cal")
	PopupMenu Vendor_tab0,value= #S_popmenu,popvalue=Vendor,mode=V_mode

	SVAR ProbeModel = root:packages:AFM_Calibration:ProbeModel
	S_popmenu=Get_S_popmenu(ProbeModel, "Model_tab0", "Panel_Cal")
	V_mode=Get_N_popmenu(ProbeModel, "Model_tab0", "Panel_Cal")
	PopupMenu Model_tab0,value= #S_popmenu,popvalue=ProbeModel,mode=V_mode

End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Panel_DrawTip_tab0()

	string S_SubWinList=ChildWindowList("#")
	
	if(CmpStr(StringFromList(0,S_SubWinList), "PanelDrawTip")==0)
		return 0	
	endif


	NewPanel/W=(213,27,424,285)/HOST=Panel_Cal/N=PanelDrawTip
	ModifyPanel cbRGB=(65534,65534,65534), frameStyle=1
	SetDrawLayer UserBack
	SetDrawEnv fillfgc= (52428,52428,52428)
	DrawPoly 100,176,0.75,1.20588,{154,298,190,298,174,332,154,298}
	SetDrawEnv fillfgc= (52428,52428,52428)
	DrawPoly 26,49.4189189189189,0.397933,0.418919,{51,432,384,431,438,451,438,484,388,505,51,505,51,432}
	SetDrawEnv fillpat= 0,fillfgc= (65535,65534,49151)
	SetDrawEnv save
	SetDrawEnv fillpat= 1,fillfgc= (52428,52428,52428)
	DrawPoly 73,155,1,1,{65,89,159,89,144,108,79,108,65,89}
	SetDrawEnv fillpat= 1,fillfgc= (52428,52428,52428)
	DrawRect -3,19,26,114
	SetDrawEnv fillpat= 1,fillfgc= (52428,52428,52428)
	SetDrawEnv save
	SetDrawEnv fillfgc= (0,0,0)
	DrawRect 74,151,167,155
	SetDrawEnv fillfgc= (0,0,0)
	DrawRect 87,173,153,177
	SetDrawEnv linethick= 3,linefgc= (65535,54607,32768),fillfgc= (65535,32768,32768)
	DrawOval 139,58,152,71
	DrawText 45,22,"Top view"
	DrawText 45,132,"Front view"
	DrawText 103,30,"L"
	DrawText 168,101,"D"
	DrawText 182,173,"t"
	DrawText 182,204,"h"
	DrawText 117,140,"b"
	DrawText 131,205,"a"
	DrawText 191,71,"c"
	DrawText 144,239,"α"
	DrawText 188,37,"\\F'Symbol'Δ\\F'Segoe UI'L"
	DrawText 19,151,"t\\Bb"
	DrawText 39,197,"t\\Ba"
	DrawText 78,108,"X\\Blaser"
	DrawText 68,225,"Y\\Btip"
	DrawLine 115,146,115,248
	SetDrawEnv arrow= 3
	DrawLine 29,33,180,33
	SetDrawEnv arrow= 3
	DrawLine 75,143,167,143
	SetDrawEnv arrow= 3
	DrawLine 89,187,152,187
	SetDrawEnv arrow= 2
	DrawLine 115,243,139,234
	SetDrawEnv arrow= 2
	DrawLine 108,241,88,231
	SetDrawEnv arrow= 2
	DrawLine 38,154,17,154
	SetDrawEnv arrow= 2
	DrawLine 167,43,146,43
	SetDrawEnv arrow= 2
	DrawLine 181,43,199,42
	SetDrawEnv arrow= 3
	DrawLine 28,88,144,88
	SetDrawEnv arrow= 2
	DrawLine 57,176,36,176
	DrawLine 167,156,194,156
	DrawLine 154,173,194,173
	DrawLine 141,217,202,217
	DrawLine 73,138,73,156
	DrawLine 167,138,167,156
	DrawLine 87,174,87,207
	DrawLine 153,174,153,207
	DrawLine 168,60,168,71
	DrawLine 163,65,174,65
	DrawLine 116,214,109,248
	DrawLine 161,81,161,104
	DrawLine 180,25,180,104
	DrawLine 45,151,72,151
	DrawLine 45,156,72,156
	DrawLine 60,172,87,172
	DrawLine 60,177,87,177
	DrawLine 168,40,168,52
	DrawLine 146,81,146,104
	DrawLine 181,56,203,56
	DrawLine 181,71,203,71
	DrawLine 122,146,122,229
	SetDrawEnv arrow= 2
	DrawLine 107,217,86,217
	SetDrawEnv arrow= 2
	DrawLine 122,218,140,217
	SetActiveSubwindow ##

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Panel_tab1() : Panel

	GroupBox CantMode_tab1,pos={13.00,177.00},size={193.00,299.00},title="Cantilever mode"
	GroupBox CantMode_tab1,labelBack=(56576,56576,56576),fSize=12,frame=0,fStyle=1
	GroupBox Data_tab1,pos={13.00,55.00},size={193.00,119.00},title="Data"
	GroupBox Data_tab1,labelBack=(56576,56576,56576),fSize=12,frame=0,fStyle=1
	GroupBox PeakParams_tab1,pos={211.00,27.00},size={209.00,248.00},title="Peaks"
	GroupBox PeakParams_tab1,fStyle=1
	PopupMenu popup_model_tab1,pos={217.00,45.00},size={131.00,19.00},bodyWidth=94,proc=PopMenuProc_Model,title="Model"
	PopupMenu popup_model_tab1,mode=1,popvalue="SHO",value= #"\"\\M0: !*:SHO;Lorentzian;SFO (τ→0);SFO (τ→∞);SFO (full);SFO (full) vn\""
	SetVariable Num_peaks_tab1,pos={353.00,45.00},size={60.00,18.00},bodyWidth=60,proc=SetVarProc_MakePeakWaves,title=" "
	SetVariable Num_peaks_tab1,format="%g peaks"
	SetVariable Num_peaks_tab1,limits={1,inf,1},value= root:packages:AFM_Calibration:num_peaks
	SetVariable Current_peaks_tab1,pos={288.00,71.00},size={125.00,18.00},bodyWidth=55,proc=SetVarProc_SwitchPeak,title="current peak"
	SetVariable Current_peaks_tab1,limits={1,5,1},value= root:packages:AFM_Calibration:current_peak
	ListBox Peak_params_tab1,pos={217.00,97.00},size={197.00,113.00},proc=ListBoxProc_UpdatePeaks
	ListBox Peak_params_tab1,frame=2
	ListBox Peak_params_tab1,listWave=root:packages:AFM_Calibration:PeakCoef_list5
	ListBox Peak_params_tab1,selWave=root:packages:AFM_Calibration:PeakCoef_list5_Sel
	ListBox Peak_params_tab1,titleWave=root:packages:AFM_Calibration:PeakParam_Name
	ListBox Peak_params_tab1,mode= 5,widths={34,30,14}
	CheckBox fit_current_tab1,pos={301.00,552.00},size={108.00,15.00},title="current peak only"
	CheckBox fit_current_tab1,variable= root:packages:AFM_Calibration:use_current
	GroupBox BakParams_tab1,pos={211.00,276.00},size={209.00,255.00},title="Background"
	GroupBox BakParams_tab1,fStyle=1
	PopupMenu popup_back_tab1,pos={295.00,298.00},size={113.00,19.00},bodyWidth=78,proc=PopMenuProc_ModelBack,title="Shape"
	PopupMenu popup_back_tab1,mode=1,popvalue="constant",value= #"\"\\M0: !*:constant;line;poly 3;poly 4;poly 5;poly 7;poly 9;poly 13;poly 19;lor;power;exp;\""
	ListBox Back_params_tab1,pos={216.00,323.00},size={198.00,76.00},frame=2
	ListBox Back_params_tab1,listWave=root:packages:AFM_Calibration:BkgdCoef_list
	ListBox Back_params_tab1,selWave=root:packages:AFM_Calibration:BkgdCoef_list_Sel
	ListBox Back_params_tab1,titleWave=root:packages:AFM_Calibration:PeakParam_Name
	ListBox Back_params_tab1,mode= 5,widths={34,30,14}
	CheckBox checkScaleBack_tab1,pos={217.00,406.00},size={14.00,14.00},proc=CheckProc_SetScaleBack,title=""
	CheckBox checkScaleBack_tab1,variable= root:packages:AFM_Calibration:use_ScaleBack
	SetVariable setvar_ScaleBack_tab1,pos={236.00,403.00},size={61.00,18.00},proc=SetVarProc_UpdateBackScale,title="scale"
	SetVariable setvar_ScaleBack_tab1,format="%.3g"
	SetVariable setvar_ScaleBack_tab1,limits={0,10,0},value= root:packages:AFM_Calibration:V_BackScale
	Slider slider_ScaleBack_tab1,pos={302.00,409.00},size={111.00,10.00},proc=SliderProc_UpdateBackScale
	Slider slider_ScaleBack_tab1,limits={-1,1,0},variable= root:packages:AFM_Calibration:V_BackScaleLog,side= 0,vert= 0
	CheckBox add_1overf_tab1,pos={228.00,425.00},size={171.00,21.00},title="include 1/f noise (as y0+A*f\\Sp\\M)"
	CheckBox add_1overf_tab1,variable= root:packages:AFM_Calibration:use_1overf, proc=CheckProc_CheckInclude1overf
	ListBox Back_params_1overf_tab1,pos={216.00,448.00},size={198.00,76.00},frame=2
	ListBox Back_params_1overf_tab1,listWave=root:packages:AFM_Calibration:BkgdCoef_1overf_list
	ListBox Back_params_1overf_tab1,selWave=root:packages:AFM_Calibration:BkgdCoef_1overf_list_Sel
	ListBox Back_params_1overf_tab1,titleWave=root:packages:AFM_Calibration:PeakParam_Name
	ListBox Back_params_1overf_tab1,mode= 5,widths={34,30,14}
	ListBox Back_params_1overf_tab1,mode= 5,widths={34,30,14}
	Button EstimatePeak_tab1,pos={218.00,68.00},size={66.00,26.00},proc=ButtonProc_EstimatePeaks,title="Estimate"
	Button EstimatePeak_tab1,fColor=(49151,65535,65535)
	Button RevertPeak_tab1,pos={345.00,243.00},size={68.00,27.00},proc=ButtonProc_RevertPeaks,title="Revert coef"
	Button RevertPeak_tab1,fColor=(65280,65280,48896)
	Button EstimateBack_tab1,pos={217.00,293.00},size={66.00,26.00},proc=ButtonProc_EstimateBack,title="Estimate"
	Button EstimateBack_tab1,fColor=(49151,65535,65535)
	Button Fit_tab1,pos={217.00,549.00},size={76.00,25.00},proc=ButtonProc_DoFit,title="Do Fit"
	Button Fit_tab1,fColor=(65535,49151,49151)
	SetVariable Sz_CorrectionFactor_tab1,pos={35.00,237.00},size={167.00,20.00},bodyWidth=53,title="Correction factor χ\\Bz,n"
	SetVariable Sz_CorrectionFactor_tab1,format="%.4g"
	SetVariable Sz_CorrectionFactor_tab1,limits={0,inf,0},value= root:packages:AFM_Calibration:Sz_CorrectionFactor
	SetVariable Sy_CorrectionFactor_tab1,pos={34.00,260.00},size={168.00,20.00},bodyWidth=53,title="Correction factor χ\\Bθ,n"
	SetVariable Sy_CorrectionFactor_tab1,format="%.4g"
	SetVariable Sy_CorrectionFactor_tab1,limits={0,inf,0},value= root:packages:AFM_Calibration:Sy_CorrectionFactor
	PopupMenu Graph_tab1,pos={20.00,76.00},size={181.00,19.00},bodyWidth=146,proc=PopMenuProc_SelectGraph,title="Graph"
	PopupMenu Graph_tab1,mode=1,popvalue="_select_",value= #"WinList(\"*\", \";\",\"WIN:1\")"
	PopupMenu PSD_tab1,pos={31.00,103.00},size={170.00,19.00},bodyWidth=146,proc=PopMenuProc_SelectPSD,title="PSD"
	PopupMenu PSD_tab1,mode=1,popvalue="_select_",value= #"root:Packages:AFM_Calibration:listPSD"
	CheckBox AddCursors_tab1,pos={17.00,131.00},size={56.00,15.00},proc=CheckProc_ShowCursors,title="Cursors"
	CheckBox AddCursors_tab1,variable= root:packages:AFM_Calibration:cursors_checked
	CheckBox ShowFit_tab1,pos={17.00,152.00},size={59.00,15.00},proc=CheckProc_AppendFit,title="Show fit"
	CheckBox ShowFit_tab1,variable= root:packages:AFM_Calibration:fit_checked
	CheckBox ShowBack_tab1,pos={85.00,152.00},size={112.00,15.00},proc=CheckProc_AppendFit,title="Show background"
	CheckBox ShowBack_tab1,variable= root:packages:AFM_Calibration:background_checked
	CheckBox ShowCurrentPeak_tab1,pos={85.00,131.00},size={114.00,15.00},proc=CheckProc_AppendFit,title="Show current peak"
	CheckBox ShowCurrentPeak_tab1,variable= root:packages:AFM_Calibration:currentpeak_checked
	PopupMenu Type_tab1,pos={18.00,32.00},size={167.00,19.00},bodyWidth=87,proc=PopMenuProc_SelectSpectrumType,title="Spectrum type"
	PopupMenu Type_tab1,mode=1,popvalue="normal",value= #"\"\\M0: !*:normal;lateral\""
	SetVariable cant_kappa_tab1,pos={25.00,216.00},size={177.00,18.00},bodyWidth=53,title="norm. mode number κ"
	SetVariable cant_kappa_tab1,format="%.4g",valueColor=(30464,30464,30464)
	SetVariable cant_kappa_tab1,limits={1,10,0},value= root:packages:AFM_Calibration:cant_kappa,noedit= 1
	SetVariable Re_tab1,pos={22.00,196.00},size={75.00,18.00},bodyWidth=58,title="Re"
	SetVariable Re_tab1,format="%.4g",valueColor=(30464,30464,30464)
	SetVariable Re_tab1,limits={1,10,0},value= root:packages:AFM_Calibration:ReNum,noedit= 1
	SetVariable Relog_tab1,pos={106.00,195.00},size={96.00,18.00},bodyWidth=54,title="log(Re)"
	SetVariable Relog_tab1,format="%.4g",valueColor=(30464,30464,30464)
	SetVariable Relog_tab1,limits={1,10,0},value= root:packages:AFM_Calibration:Relog,noedit= 1
	GroupBox SavedCal_tab1,pos={13.00,528.00},size={195.00,96.00},title="Calibration Data"
	GroupBox SavedCal_tab1,labelBack=(56576,56576,56576),font="Segoe UI",fSize=12
	GroupBox SavedCal_tab1,frame=0,fStyle=1
	PopupMenu popup_DF_SavCal_tab1,pos={26.00,568.00},size={174.00,19.00},bodyWidth=120,proc=PopMenuProc_SelectSavCal,title="Saved Cal"
	PopupMenu popup_DF_SavCal_tab1,mode=1,popvalue="_none_",value= #"List_DFSavedCal()"
	Button SaveFit_tab1,pos={18.00,543.00},size={56.00,24.00},proc=ButtonProc_SaveFit,title="Save as"
	Button SaveFit_tab1,fColor=(65280,65280,48896)
	Button LoadFit_tab1,pos={79.00,590.00},size={56.00,24.00},proc=ButtonProc_LoadFit,title="Load"
	Button LoadFit_tab1,fColor=(65280,65280,48896)
	Button DeleteFit_tab1,pos={18.00,590.00},size={56.00,24.00},proc=ButtonProc_DeleteFit,title="Delete"
	Button DeleteFit_tab1,fColor=(65280,65280,48896)
	PopupMenu popup_LoadSavedFit_tab1,pos={139.00,593.00},size={60.00,19.00},bodyWidth=60,proc=PopMenuProc_SelectLoadType
	PopupMenu popup_LoadSavedFit_tab1,mode=1,popvalue="all",value= #"\"all;fvac;background\""
	SetVariable SavCalDF_tab1,pos={80.00,546.00},size={120.00,18.00},title=" "
	SetVariable SavCalDF_tab1,value= root:packages:AFM_Calibration:DF_SavCal
	Button Set_CopyParam_tab1,pos={304.00,213.00},size={109.00,28.00},proc=ButtonProc_CopyParam,title="\\JLCopy"
	Button Set_CopyParam_tab1,fColor=(65280,65280,48896)
	PopupMenu popup_CopyParam_tab1,pos={345.00,218.00},size={60.00,19.00},bodyWidth=60
	PopupMenu popup_CopyParam_tab1,mode=1,popvalue="τ (or η)",value= #"\"τ (or η);width;p;q\""
	CheckBox check_Hold_param_tab1,pos={219.00,249.00},size={80.00,15.00},proc=CheckProc_HoldParam,title="Hold all par."
	CheckBox check_Hold_param_tab1,value= 0
	PopupMenu popup_holdParam_tab1,pos={307.00,247.00},size={28.00,19.00}, proc=PopMenuProc_SetHoldParam
	PopupMenu popup_holdParam_tab1,mode=1,popvalue="1",value= #"\"1;2;3;4;5\""
	Button Set_mfmc_tab1,pos={217.00,213.00},size={78.00,28.00},proc=ButtonProc_Calc_mfmc,title="Calc τ (or η)"
	Button Set_mfmc_tab1,fColor=(65280,65280,48896)

	ValDisplay Chisq_tab1,pos={335.00,571.00},size={79.00,21.00},title="χ\\S2"
	ValDisplay Chisq_tab1,format="%.4g",limits={0,0,0},barmisc={0,1000}
	ValDisplay Chisq_tab1,value= #"root:Packages:AFM_Calibration:Chisq"
	CheckBox g_option_tab1,pos={23.00,330.00},size={168.00,15.00},title="adjust Γ(ν) for mode number"
	CheckBox g_option_tab1,proc=CheckProc_CheckGammaNormModeSelect,variable= root:packages:AFM_Calibration:G_option
	GroupBox Detector_tab1,pos={13.00,483.00},size={193.00,40.00},title="Detector"
	GroupBox Detector_tab1,labelBack=(56576,56576,56576),font="Segoe UI",fSize=12
	GroupBox Detector_tab1,frame=0,fStyle=1
	SetVariable DetectorMTF_tab1,pos={20.00,501.00},size={72.00,18.00},bodyWidth=44,title="MTF"
	SetVariable DetectorMTF_tab1,format="%.4g",valueColor=(30464,30464,30464)
	SetVariable DetectorMTF_tab1,limits={1,10,0},value= root:packages:AFM_Calibration:Detect_MTF,noedit= 1
	CheckBox MTF_option_tab1,pos={103.00,503.00},size={50.00,15.00},title="ignore"
	CheckBox MTF_option_tab1,variable= root:packages:AFM_Calibration:Detect_MTF_ignore
	CheckBox MTF_fix_tab1,pos={164.00,504.00},size={28.00,15.00},proc=CheckProc_fixMTF,title="fix"
	CheckBox MTF_fix_tab1,variable= root:packages:AFM_Calibration:Detect_MTF_fix
	SetVariable HydrodynFuncIm_tab1,pos={22.00,306.00},size={180.00,20.00},bodyWidth=53,title="Img. hydr. func. Γ\\Bi\\M(ν\\Bn\\M,κ)"
	SetVariable HydrodynFuncIm_tab1,format="%.4g"
	SetVariable HydrodynFuncIm_tab1,limits={0,inf,0},value= root:packages:AFM_Calibration:V_Gamma_i
	SetVariable HydrodynFuncRe_tab1,pos={23.00,283.00},size={179.00,20.00},bodyWidth=53,title="Real hydr. func. Γ\\Br\\M(ν\\Bn\\M,κ)"
	SetVariable HydrodynFuncRe_tab1,format="%.4g"
	SetVariable HydrodynFuncRe_tab1,limits={0,inf,0},value= root:packages:AFM_Calibration:V_Gamma_r
	CheckBox iterate_tab1,pos={219.00,577.00},size={49.00,15.00},title="iterate"
	CheckBox iterate_tab1,variable= root:packages:AFM_Calibration:iterate_do
	SetVariable iterate_max_tab1,pos={274.00,576.00},size={51.00,18.00},bodyWidth=38,title="N"
	SetVariable iterate_max_tab1,format="%.4g"
	SetVariable iterate_max_tab1,limits={0,inf,0},value= root:packages:AFM_Calibration:iterate_max

	GroupBox Fitting_tab1,pos={212.00,532.00},size={208.00,93.00},title="Fitting"
	GroupBox Fitting_tab1,fStyle=1
	TitleBox GlobalFitParam_tab1,pos={216.00,596.00},size={198.00,24.00},title="Global:"
	TitleBox GlobalFitParam_tab1,fixedSize=1
	CheckBox globalTau_tab1,pos={315.00,601.00},size={57.00,15.00},title=" τ (or η)"
	CheckBox globalTau_tab1,variable= root:packages:AFM_Calibration:globalTau, proc=CheckProc_SelectGlobalFitParam
	CheckBox globalWidth_tab1,pos={381.00,601.00},size={26.00,15.00},title=" b"
	CheckBox globalWidth_tab1,variable= root:packages:AFM_Calibration:globalWidth, proc=CheckProc_SelectGlobalFitParam
	CheckBox globalpq_tab1,pos={264.00,601.00},size={44.00,15.00},title=" (p,q)"
	CheckBox globalpq_tab1,variable= root:packages:AFM_Calibration:globalpq, proc=CheckProc_SelectGlobalFitParam

	PopupMenu Graph_tab1,mode=1,popvalue="_select_"
	PopupMenu PSD_tab1,mode=1,popvalue="_select_"

	string S_popmenu
	variable V_mode

	NVAR current_Peak=root:packages:AFM_Calibration:current_Peak
	string df="PeakCoef_list"+num2str(current_Peak)
	ListBox Peak_params_tab1,listWave=root:packages:AFM_Calibration:$df
	df="PeakCoef_list"+num2str(current_Peak)+"_Sel"
	ListBox Peak_params_tab1,selWave=root:packages:AFM_Calibration:$df

	NVAR num_peaks = root:packages:AFM_Calibration:num_peaks
	SetVariable Current_peaks_tab1 limits={1,num_peaks,1}, win=Panel_Cal

	SVAR model = root:packages:AFM_Calibration:model
	S_popmenu=Get_S_popmenu(model, "popup_model_tab1", "Panel_Cal")
	V_mode=Get_N_popmenu(model, "popup_model_tab1", "Panel_Cal")
	PopupMenu popup_model_tab1,value= #S_popmenu,popvalue=model,mode=V_mode

	SVAR model_Back = root:packages:AFM_Calibration:model_Back
	S_popmenu=Get_S_popmenu(model_Back, "popup_back_tab1", "Panel_Cal")
	V_mode=Get_N_popmenu(model_Back, "popup_back_tab1", "Panel_Cal")
	PopupMenu popup_back_tab1,value= #S_popmenu,popvalue=model_Back,mode=V_mode

	SVAR Spectrum_type = root:packages:AFM_Calibration:Spectrum_type
	S_popmenu=Get_S_popmenu(Spectrum_type, "Type_tab1", "Panel_Cal")
	V_mode=Get_N_popmenu(Spectrum_type, "Type_tab1", "Panel_Cal")
	PopupMenu Type_tab1,value= #S_popmenu,popvalue=Spectrum_type,mode=V_mode

	SVAR CurrentGraph=root:packages:AFM_Calibration:CurrentGraph
	if(strlen(CurrentGraph))
		V_mode=WhichListItem(CurrentGraph,WinList("*", ";","WIN:1"))
		if(V_mode<0)
			V_mode=0
		endif
		PopupMenu Graph_tab1,mode=(V_mode+1), popvalue=CurrentGraph
	endif
	
	SVAR PSD=root:Packages:AFM_Calibration:PSD
	if(strlen(PSD))
		string nPSD=NameOfWave($PSD)
		SVAR listPSD=root:Packages:AFM_Calibration:listPSD
		V_mode=WhichListItem(nPSD,listPSD)
		if(V_mode<0)
			V_mode=0
		endif
		PopupMenu PSD_tab1,mode=(V_mode+1), popvalue=nPSD
	endif

	SVAR DF_LoadCal=root:Packages:AFM_Calibration:DF_LoadCal
	if(strlen(DF_LoadCal))
		V_mode=WhichListItem(DF_LoadCal,List_DFSavedCal())
		if(V_mode<0)
			V_mode=0
		endif
		PopupMenu popup_DF_SavCal_tab1,mode=(V_mode+1),popvalue=DF_LoadCal
	endif

End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Panel_DrawShape_tab1()

	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:packages:AFM_Calibration:
	wave Ampl, LaserX, LaserY
	
	string S_SubWinList=ChildWindowList("#")
	
	if(CmpStr(StringFromList(0,S_SubWinList), "modeshape")==0)
		return 0	
	endif

	Display/W=(16,351,202,472)/HOST=#/N=modeshape  Ampl
	AppendToGraph LaserY vs LaserX
	SetDataFolder fldrSav0
	ModifyGraph margin(left)=4,margin(bottom)=4,margin(top)=4,margin(right)=4
	ModifyGraph mode(LaserY)=3
	ModifyGraph marker(LaserY)=19
	ModifyGraph msize(LaserY)=4
	ModifyGraph mrkThick(LaserY)=2
	ModifyGraph useMrkStrokeRGB(LaserY)=1
	ModifyGraph mrkStrokeRGB(LaserY)=(65535,43690,0)
	ModifyGraph tick=3
	ModifyGraph mirror=2
	ModifyGraph noLabel=2
	ModifyGraph standoff=0
//	RenameWindow #,modeshape
	SetActiveSubwindow ##
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Panel_tab2() : Panel

	GroupBox SpringConst_tab2,pos={13.00,25.00},size={153.00,349.00}
	GroupBox SpringConst_tab2,title="Spring Constant",labelBack=(56576,56576,56576)
	GroupBox SpringConst_tab2,font="Segoe UI",fSize=12,frame=0,fStyle=1
	GroupBox ky_tab2,pos={18.00,265.00},size={142.00,105.00},title="k\\By"
	GroupBox ky_tab2,labelBack=(60928,60928,60928),fStyle=1
	GroupBox kz_tab2,pos={19.00,50.00},size={142.00,108.00},title="k\\Bz"
	GroupBox kz_tab2,labelBack=(52224,52224,52224),fStyle=1
	GroupBox ktheta_tab2,pos={19.00,158.00},size={142.00,106.00},title="k\\Bθ"
	GroupBox ktheta_tab2,labelBack=(60928,60928,60928),fStyle=1
	GroupBox SensitivityZ_tab2,pos={171.00,26.00},size={250.00,145.00}
	GroupBox SensitivityZ_tab2,title="Sensitivity z",labelBack=(56576,56576,56576)
	GroupBox SensitivityZ_tab2,font="Segoe UI",fSize=12,frame=0,fStyle=1
	GroupBox SensitivityZ_noncont_tab2,pos={298.00,45.00},size={117.00,95.00}
	GroupBox SensitivityZ_noncont_tab2,title="non-contact"
	GroupBox SensitivityZ_noncont_tab2,labelBack=(65280,48896,48896),font="Arial"
	GroupBox SensitivityZ_noncont_tab2,fSize=12,fStyle=0,fColor=(65280,0,0)
	GroupBox SensitivityZ_cont_tab2,pos={176.00,45.00},size={118.00,94.00}
	GroupBox SensitivityZ_cont_tab2,title="contact",labelBack=(48896,59904,65280)
	GroupBox SensitivityZ_cont_tab2,font="Arial",fSize=12,fStyle=0
	GroupBox SensitivityZ_cont_tab2,fColor=(0,0,65280)
	GroupBox SensitivityX_tab2,pos={171.00,173.00},size={250.00,141.00}
	GroupBox SensitivityX_tab2,title="Sensitivity y",labelBack=(56576,56576,56576)
	GroupBox SensitivityX_tab2,font="Segoe UI",fSize=12,frame=0,fStyle=1
	GroupBox SensitivityX_noncont_tab2,pos={299.00,189.00},size={116.00,93.00}
	GroupBox SensitivityX_noncont_tab2,title="non-contact"
	GroupBox SensitivityX_noncont_tab2,labelBack=(65280,48896,48896),font="Arial"
	GroupBox SensitivityX_noncont_tab2,fSize=12,fStyle=0,fColor=(65280,0,0)
	GroupBox SensitivityX_cont_tab2,pos={177.00,189.00},size={118.00,94.00}
	GroupBox SensitivityX_cont_tab2,title="contact",labelBack=(48896,59904,65280)
	GroupBox SensitivityX_cont_tab2,font="Arial",fSize=12,fStyle=0
	GroupBox SensitivityX_cont_tab2,fColor=(0,0,65280)
	GroupBox Results_tab2,pos={171.00,570.00},size={251.00,49.00},title="Results"
	GroupBox Results_tab2,labelBack=(65535,60076,49151),font="Segoe UI",fSize=12
	GroupBox Results_tab2,frame=0,fStyle=1
	GroupBox Calculate_tab2,pos={171.00,317.00},size={251.00,248.00}
	GroupBox Calculate_tab2,title="Calculate",labelBack=(56576,56576,56576)
	GroupBox Calculate_tab2,font="Segoe UI",fSize=12,frame=0,fStyle=1
	GroupBox Gamma_tab2,pos={13.00,375.00},size={153.00,244.00}
	GroupBox Gamma_tab2,title="Hydrodyn. function",labelBack=(56576,56576,56576)
	GroupBox Gamma_tab2,font="Segoe UI",fSize=12,frame=0,fStyle=1
	SetVariable kz_theor_tab2,pos={26.00,68.00},size={128.00,18.00},bodyWidth=90
	SetVariable kz_theor_tab2,title="theory",format="%.4g N/m"
	SetVariable kz_theor_tab2,limits={0,inf,0},value= root:packages:AFM_Calibration:kz_theory
	SetVariable kz_therm_tab2,pos={28.00,90.00},size={127.00,18.00},bodyWidth=91
	SetVariable kz_therm_tab2,title="therm",format="%.4g N/m"
	SetVariable kz_therm_tab2,limits={0,inf,0},value= root:packages:AFM_Calibration:kz_thermal
	SetVariable kz_Sader_tab2,pos={31.00,112.00},size={124.00,18.00},bodyWidth=91
	SetVariable kz_Sader_tab2,title="Sader",format="%.4g N/m"
	SetVariable kz_Sader_tab2,limits={0,inf,0},value= root:packages:AFM_Calibration:kz_Sader
	SetVariable kz_FS_tab2,pos={38.00,134.00},size={117.00,18.00},bodyWidth=92
	SetVariable kz_FS_tab2,title="SFO",format="%.4g N/m"
	SetVariable kz_FS_tab2,limits={0,inf,0},value= root:packages:AFM_Calibration:kz_FluidStruc
	SetVariable kTheta_theor_tab2,pos={25.00,177.00},size={131.00,18.00},bodyWidth=93
	SetVariable kTheta_theor_tab2,title="theory",format="%.4g N/rad"
	SetVariable kTheta_theor_tab2,limits={0,inf,0},value= root:packages:AFM_Calibration:kTheta_theory
	SetVariable kTheta_therm_tab2,pos={27.00,198.00},size={129.00,18.00},bodyWidth=93
	SetVariable kTheta_therm_tab2,title="therm",format="%.4g N/rad"
	SetVariable kTheta_therm_tab2,limits={0,inf,0},value= root:packages:AFM_Calibration:kTheta_thermal
	SetVariable kTheta_Sader_tab2,pos={29.00,219.00},size={127.00,18.00},bodyWidth=94
	SetVariable kTheta_Sader_tab2,title="Sader",format="%.4g N/rad"
	SetVariable kTheta_Sader_tab2,limits={0,inf,0},value= root:packages:AFM_Calibration:kTheta_Sader
	SetVariable ktheta_FS_tab2,pos={37.00,240.00},size={119.00,18.00},bodyWidth=94
	SetVariable ktheta_FS_tab2,title="SFO",format="%.4g N/rad"
	SetVariable ktheta_FS_tab2,limits={0,inf,0},value= root:packages:AFM_Calibration:kTheta_FluidStruc
	SetVariable ky_theor_tab2,pos={24.00,282.00},size={129.00,18.00},bodyWidth=91
	SetVariable ky_theor_tab2,title="theory",format="%.4g N/m"
	SetVariable ky_theor_tab2,limits={0,inf,0},value= root:packages:AFM_Calibration:ky_theory
	SetVariable ky_therm_tab2,pos={26.00,303.00},size={128.00,18.00},bodyWidth=92
	SetVariable ky_therm_tab2,title="therm",format="%.4g N/m"
	SetVariable ky_therm_tab2,limits={0,inf,0},value= root:packages:AFM_Calibration:ky_thermal
	SetVariable ky_Sader_tab2,pos={29.00,325.00},size={125.00,18.00},bodyWidth=92
	SetVariable ky_Sader_tab2,title="Sader",format="%.4g N/m"
	SetVariable ky_Sader_tab2,limits={0,inf,0},value= root:packages:AFM_Calibration:ky_Sader
	SetVariable ky_FS_tab2,pos={38.00,347.00},size={116.00,18.00},bodyWidth=91
	SetVariable ky_FS_tab2,title="SFO",format="%.4g N/m"
	SetVariable ky_FS_tab2,limits={0,inf,0},value= root:packages:AFM_Calibration:ky_FluidStruc
	CheckBox use_thermal_Sz_tab2,pos={177.00,432.00},size={202.00,17.00}
	CheckBox use_thermal_Sz_tab2,title=" set S\\BF\\M(contact)=S(contact) / k\\Bthermal"
	CheckBox use_thermal_Sz_tab2,variable= root:packages:AFM_Calibration:check_SFcont_use_kthermal
	Button Calculatek_tab2,pos={177.00,334.00},size={99.00,27.00},proc=ButtonProc_CalculateSpringConst
	Button Calculatek_tab2,title="Calculate k",fColor=(65280,65280,48896)
	PopupMenu Type_tab2,pos={303.00,338.00},size={105.00,19.00},bodyWidth=78,proc=PopMenuProc_SelectSpectrumType
	PopupMenu Type_tab2,title="Type"
	PopupMenu Type_tab2,mode=2,popvalue="lateral",value= #"\"normal;\\M0: !*:lateral\""
	Button CalculateSens_tab2,pos={177.00,365.00},size={99.00,27.00},proc=ButtonProc_CalcSens
	Button CalculateSens_tab2,title="Calculate Sens",fColor=(65280,65280,48896)
	PopupMenu k_for_TLS_tab2,pos={286.00,369.00},size={123.00,19.00},bodyWidth=78,proc=PopMenuProc_SelectSpingConst
	PopupMenu k_for_TLS_tab2,title="k spring"
	PopupMenu k_for_TLS_tab2,mode=4,popvalue="FluidStruc",value= #"\"theory;thermal;Sader;\\M0: !*:FluidStruc\""
	Button ShowResults_tab2,pos={191.00,587.00},size={96.00,26.00},proc=ButtonProc_ShowResults
	Button ShowResults_tab2,title="Print Results",fColor=(65535,49151,49151)
	Button Calc_tH_tab2,pos={176.00,473.00},size={100.00,26.00},proc=ButtonProc_Calc_tH
	Button Calc_tH_tab2,title="Calculate t & H",fColor=(65280,65280,48896)
	SetVariable OLSz_cont_tab2,pos={181.00,62.00},size={107.00,20.00},bodyWidth=92
	SetVariable OLSz_cont_tab2,title="\\f01S\\Bz",format="%.4g V/m",fStyle=0
	SetVariable OLSz_cont_tab2,fColor=(0,0,52224),valueBackColor=(57346,65535,49151)
	SetVariable OLSz_cont_tab2,limits={0,inf,0},value= root:packages:AFM_Calibration:Sz_cont
	SetVariable OLSz_noncont_tab2,pos={303.00,63.00},size={106.00,20.00},bodyWidth=92
	SetVariable OLSz_noncont_tab2,title="S\\Bz",format="%.4g V/m",fColor=(65280,0,0)
	SetVariable OLSz_noncont_tab2,limits={0,inf,0},value= root:packages:AFM_Calibration:Sz_noncont
	SetVariable Sz_noncont_tab2,pos={301.00,88.00},size={108.00,22.00},bodyWidth=91
	SetVariable Sz_noncont_tab2,title="S\\BF\\Bz",format="%.4g V/N"
	SetVariable Sz_noncont_tab2,fColor=(65280,0,0)
	SetVariable Sz_noncont_tab2,limits={0,inf,0},value= root:packages:AFM_Calibration:SFz_noncont
	SetVariable Sz_cont_tab2,pos={179.00,86.00},size={109.00,22.00},bodyWidth=92
	SetVariable Sz_cont_tab2,title="S\\BF\\Bz",format="%.4g V/N",fColor=(0,0,52224)
	SetVariable Sz_cont_tab2,limits={0,inf,0},value= root:packages:AFM_Calibration:SFz_cont
	SetVariable OLSy_cont_tab2,pos={181.00,206.00},size={107.00,20.00},bodyWidth=92
	SetVariable OLSy_cont_tab2,title="\\f01S\\By",format="%.4g V/m",fStyle=0
	SetVariable OLSy_cont_tab2,fColor=(0,0,52224),valueBackColor=(57346,65535,49151)
	SetVariable OLSy_cont_tab2,limits={0,inf,0},value= root:packages:AFM_Calibration:Sy_cont
	SetVariable OLSy_noncont_tab2,pos={306.00,206.00},size={103.00,20.00},bodyWidth=89
	SetVariable OLSy_noncont_tab2,title="S\\By",format="%.4g V/m",fColor=(65535,0,0)
	SetVariable OLSy_noncont_tab2,limits={0,inf,0},value= root:packages:AFM_Calibration:Sy_noncont
	SetVariable Sy_noncont_tab2,pos={304.00,230.00},size={105.00,22.00},bodyWidth=88
	SetVariable Sy_noncont_tab2,title="S\\BF\\By",format="%.4g V/N"
	SetVariable Sy_noncont_tab2,fColor=(65535,0,0)
	SetVariable Sy_noncont_tab2,limits={0,inf,0},value= root:packages:AFM_Calibration:SFy_noncont
	SetVariable Sy_cont_tab2,pos={176.00,230.00},size={112.00,22.00},bodyWidth=92
	SetVariable Sy_cont_tab2,title=" S\\BF\\By",format="%.4g V/N",fColor=(0,0,52224)
	SetVariable Sy_cont_tab2,limits={0,inf,0},value= root:packages:AFM_Calibration:SFy_cont
	SetVariable Sz_CorrectionFactor_tab2,pos={245.00,144.00},size={167.00,20.00},bodyWidth=53
	SetVariable Sz_CorrectionFactor_tab2,title="Correction factor χ\\Bz,n"
	SetVariable Sz_CorrectionFactor_tab2,format="%.4g"
	SetVariable Sz_CorrectionFactor_tab2,limits={0,inf,0},value= root:packages:AFM_Calibration:Sz_CorrectionFactor
	SetVariable Sy_CorrectionFactor_tab2,pos={245.00,287.00},size={168.00,20.00},bodyWidth=53
	SetVariable Sy_CorrectionFactor_tab2,title="Correction factor χ\\Bθ,n"
	SetVariable Sy_CorrectionFactor_tab2,format="%.4g"
	SetVariable Sy_CorrectionFactor_tab2,limits={0,inf,0},value= root:packages:AFM_Calibration:Sy_CorrectionFactor
	SetVariable mode_tab2,pos={74.00,41.00},size={72.00,18.00},bodyWidth=37,proc=SetVarProc_SwitchPeak
	SetVariable mode_tab2,title="mode"
	SetVariable mode_tab2,limits={1,2,1},value= root:packages:AFM_Calibration:current_peak
	Button KillResults_tab2,pos={306.00,587.00},size={96.00,26.00},proc=ButtonProc_KillResults
	Button KillResults_tab2,title="Kill Results",fColor=(65535,49151,49151)
	SetVariable Sslopez_cont_tab2,pos={181.00,113.00},size={107.00,20.00},bodyWidth=92
	SetVariable Sslopez_cont_tab2,title="S\\Bθ",format="%.4g V/rad"
	SetVariable Sslopez_cont_tab2,fColor=(0,0,52224)
	SetVariable Sslopez_cont_tab2,limits={0,inf,0},value= root:packages:AFM_Calibration:Sslopez_cont
	SetVariable Sslopez_noncont_tab2,pos={304.00,114.00},size={105.00,20.00},bodyWidth=90
	SetVariable Sslopez_noncont_tab2,title="S\\Bθ",format="%.4g V/rad"
	SetVariable Sslopez_noncont_tab2,fColor=(65280,0,0)
	SetVariable Sslopez_noncont_tab2,limits={0,inf,0},value= root:packages:AFM_Calibration:Sslopez_noncont
	SetVariable Sslopex_cont_tab2,pos={178.00,256.00},size={111.00,20.00},bodyWidth=93
	SetVariable Sslopex_cont_tab2,title=" S\\Bθ",format="%.4g V/rad"
	SetVariable Sslopex_cont_tab2,fColor=(0,0,52224)
	SetVariable Sslopex_cont_tab2,limits={0,inf,0},value= root:packages:AFM_Calibration:Sslopey_cont
	SetVariable Sslopex_noncont_tab2,pos={306.00,256.00},size={102.00,20.00},bodyWidth=87
	SetVariable Sslopex_noncont_tab2,title="S\\Bθ",format="%.4g V/rad"
	SetVariable Sslopex_noncont_tab2,fColor=(65535,0,0)
	SetVariable Sslopex_noncont_tab2,limits={0,inf,0},value= root:packages:AFM_Calibration:Sslopey_noncont
	CheckBox use_mend_tab2,pos={285.00,478.00},size={130.00,15.00}
	CheckBox use_mend_tab2,title="account for end mass"
	CheckBox use_mend_tab2,variable= root:packages:AFM_Calibration:use_mend
	Button ShowGamma_tab2,pos={29.00,497.00},size={121.00,29.00},proc=ButtonProc_PlotGamma
	Button ShowGamma_tab2,title="\\JLPlot Γ versus",fColor=(65280,65280,48896)
	PopupMenu GammaX_tab2,pos={108.00,502.00},size={36.00,19.00},bodyWidth=36
	PopupMenu GammaX_tab2,mode=3,popvalue="δ",value= #"\"ν;Re;δ\""
	Button Calc_Gamma_tab2,pos={21.00,468.00},size={74.00,26.00},proc=ButtonProc_CalcGamma
	Button Calc_Gamma_tab2,title="Calculate Γ",fColor=(65280,65280,48896)
	CheckBox fixQ_tab2,pos={177.00,396.00},size={170.00,15.00},proc=CheckProc_AdjustQ
	CheckBox fixQ_tab2,title="adjust Q for peak broadening"
	CheckBox fixQ_tab2,variable= root:packages:AFM_Calibration:fixQ
	SetVariable SetKappa_tab2,pos={40.00,396.00},size={83.00,18.00},bodyWidth=44
	SetVariable SetKappa_tab2,title="set κ =",format="%.4g"
	SetVariable SetKappa_tab2,limits={0,20,0},value= root:packages:AFM_Calibration:kappa
	CheckBox set_kappa_tab2,pos={22.00,400.00},size={14.00,14.00},title=""
	CheckBox set_kappa_tab2,variable= root:packages:AFM_Calibration:use_fixed_kappa
	Button Calc_GammaCoef_tab2,pos={29.00,529.00},size={121.00,28.00},proc=ButtonProc_CalcGammaCoef
	Button Calc_GammaCoef_tab2,title="Calculate a\\Bi\\M , b\\Bi\\M vs. κ"
	Button Calc_GammaCoef_tab2,fColor=(65280,65280,48896)
	Button ShowCoef_tab2,pos={29.00,585.00},size={121.00,28.00},proc=ButtonProc_PlotCoef
	Button ShowCoef_tab2,title="\\JLPlot coefficient vs. κ"
	Button ShowCoef_tab2,fColor=(65280,65280,48896)
	PopupMenu coefList_tab2,pos={29.00,561.00},size={117.00,19.00},bodyWidth=86
	PopupMenu coefList_tab2,title="Coef."
	PopupMenu coefList_tab2,mode=5,popvalue="wGrcoef0T",value= #"Popup_CoefList()"
	CheckBox use_fitted_Coef_tab2,pos={22.00,420.00},size={132.00,15.00}
	CheckBox use_fitted_Coef_tab2,title=" use fitted coefficients"
	CheckBox use_fitted_Coef_tab2,variable= root:packages:AFM_Calibration:use_fitted_Coef
	Button Calc_tvstf_tab2,pos={176.00,503.00},size={241.00,28.00},proc=ButtonProc_Calc_t_vs_tf
	Button Calc_tvstf_tab2,title="\\JLCalculate t vs t\\Bfilm"
	Button Calc_tvstf_tab2,fColor=(65280,65280,48896)
	SetVariable tb1_tab2,pos={275.00,508.00},size={64.00,18.00},bodyWidth=52
	SetVariable tb1_tab2,title="=",format="%.4g m"
	SetVariable tb1_tab2,limits={0,inf,0},value= root:packages:AFM_Calibration:coat_b_thick1
	SetVariable tb2_tab2,pos={343.00,508.00},size={67.00,18.00},bodyWidth=52
	SetVariable tb2_tab2,title="÷ ",format="%.4g m"
	SetVariable tb2_tab2,limits={0,inf,0},value= root:packages:AFM_Calibration:coat_b_thick2
	CheckBox DoNumericInt_tab2,pos={177.00,413.00},size={179.00,17.00},proc=CheckProc_UseNumericIntegral
	CheckBox DoNumericInt_tab2,title="use numeric integral for k\\Bthermal"
	CheckBox DoNumericInt_tab2,variable= root:packages:AFM_Calibration:DoNumericalIntegral
	SetVariable setvar_ErrRe_tab2,pos={20.00,442.00},size={65.00,22.00}
	SetVariable setvar_ErrRe_tab2,title="Δ\\BΓ\\Breal",format="%.2g"
	SetVariable setvar_ErrRe_tab2,limits={-inf,inf,0},value= root:packages:AFM_Calibration:V_GrealErr_avg,noedit= 1
	SetVariable setvar_ErrRe1_tab2,pos={91.00,443.00},size={71.00,22.00}
	SetVariable setvar_ErrRe1_tab2,title="Δ\\BΓ\\Bimag",format="%.2g"
	SetVariable setvar_ErrRe1_tab2,limits={-inf,inf,0},value= root:packages:AFM_Calibration:V_GimagErr_avg,noedit= 1
	SetVariable setvar_deltaMax_tab2,pos={101.00,472.00},size={60.00,18.00}
	SetVariable setvar_deltaMax_tab2,title="δ<",format="%.3g"
	SetVariable setvar_deltaMax_tab2,limits={0,200,0},value= root:packages:AFM_Calibration:V_delta_max
	PopupMenu FitTypeList_tab2,pos={178.00,539.00},size={161.00,19.00},bodyWidth=90,proc=PopMenuProc_FitType
	PopupMenu FitTypeList_tab2,title="Γ fit function"
	PopupMenu FitTypeList_tab2,mode=1,popvalue="type 1",value= #"\"\\M0: !*:type 1;type 2; poly 2 terms; poly 4 terms\""
	Button ShowErrorsGamma_tab2,pos={347.00,534.00},size={71.00,27.00},proc=ButtonProc_PlotErrorsGamma
	Button ShowErrorsGamma_tab2,title="Plot errors",fColor=(65280,65280,48896)
	SetVariable Cn_tab2,pos={177.00,144.00},size={61.00,20.00},bodyWidth=44
	SetVariable Cn_tab2,title="C\\Bn",format="%.4g"
	SetVariable Cn_tab2,limits={0,inf,0},value= root:packages:AFM_Calibration:Cn
	SetVariable Dn_tab2,pos={178.00,287.00},size={61.00,20.00},bodyWidth=44
	SetVariable Dn_tab2,title="D\\Bn",format="%.4g"
	SetVariable Dn_tab2,limits={0,inf,0},value= root:packages:AFM_Calibration:Dn
	CheckBox set_S_cont2S_noncont_avg_tab2,pos={178.00,452.00},size={193.00,17.00},proc=CheckProc_Check_Scont
	CheckBox set_S_cont2S_noncont_avg_tab2,title="S\\Bz,y\\M(contact)=S\\Bz,y\\M(non-cont.): avg ", mode=1
	CheckBox set_S_cont2S_noncont_avg_tab2,variable= root:packages:AFM_Calibration:check_Scont_use_Snoncont_avg,side= 1
	CheckBox set_S_cont2S_noncont_n1_tab2,pos={375.00,454.00},size={40.00,15.00},proc=CheckProc_Check_Scont
	CheckBox set_S_cont2S_noncont_n1_tab2,title="n=1 ", mode=1
	CheckBox set_S_cont2S_noncont_n1_tab2,variable= root:packages:AFM_Calibration:check_Scont_use_Snoncont_n1,side= 1

	DFREF dfcal=root:Packages:AFM_Calibration:

	NVAR/SDFR=dfcal num_peaks
	SetVariable mode_tab2 limits={1,num_peaks,1}, win=Panel_Cal

	SVAR/SDFR=dfcal Spectrum_type
	SVAR/SDFR=dfcal k_type
	SVAR/SDFR=dfcal GammafitType

	string S_popmenu
	variable V_mode

	S_popmenu=Get_S_popmenu(Spectrum_type, "Type_tab2", "Panel_Cal")
	V_mode=Get_N_popmenu(Spectrum_type, "Type_tab2", "Panel_Cal")
	PopupMenu Type_tab2,value= #S_popmenu,popvalue=Spectrum_type,mode=V_mode

	S_popmenu=Get_S_popmenu(k_type, "k_for_TLS_tab2", "Panel_Cal")
	V_mode=Get_N_popmenu(k_type, "k_for_TLS_tab2", "Panel_Cal")
	PopupMenu k_for_TLS_tab2,value= #S_popmenu,popvalue=k_type,mode=V_mode

	S_popmenu=Get_S_popmenu(GammafitType, "FitTypeList_tab2", "Panel_Cal")
	V_mode=Get_N_popmenu(GammafitType, "FitTypeList_tab2", "Panel_Cal")
	PopupMenu FitTypeList_tab2,value= #S_popmenu,popvalue=GammafitType,mode=V_mode

End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑

// END OF MAKING MAIN PANEL



//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀↓↓↓
//	↓↓↓		Normalization of tip Y offset
Function Norm_Ytip(tip_Yoffset,tip_H_e)
	variable tip_Yoffset,tip_H_e
	
	if(tip_H_e>0)
		return tip_Yoffset/tip_H_e
	else
		return 0
	endif

end 
 

// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀↓↓↓
//	↓↓↓		SRUCTURES 
Structure cantilever

	NVAR cant_a
	NVAR cant_b
	NVAR cant_C
	NVAR cant_D
	NVAR cant_width
	NVAR cant_length
	NVAR cant_length_e
	NVAR cant_thickness
	NVAR cant_thickness_e
	NVAR cant_Xlaser

	NVAR mend2mc
	NVAR Iend2Ic

	NVAR xlaser
	NVAR xtip
	NVAR ytip

	NVAR cant_E_modulus
	NVAR cant_G_modulus
	NVAR cant_Poisson_ratio
	NVAR cant_rho

	NVAR cant_rho_e
	NVAR cant_E_modulus_e
	NVAR cant_G_modulus_e

	NVAR coat_a_thick
	NVAR coat_a_rho
	NVAR coat_a_E_modulus
	NVAR coat_a_G_modulus

	NVAR coat_b_thick
	NVAR coat_b_rho
	NVAR coat_b_E_modulus
	NVAR coat_b_G_modulus
	
	NVAR cant_inclination
	
	NVAR coat_b_thick1
	NVAR coat_b_thick2
	
	NVAR cant_kappa	

endStructure


Structure Tip

	NVAR tip_H
	NVAR tip_H_e
	NVAR htip

	NVAR tip_angle1
	NVAR tip_angle2
	NVAR tip_angle3

	NVAR tip_Xoffset
	NVAR tip_Yoffset
	
	NVAR xtip
	NVAR ytip

	SVAR tip_Shape
	
endStructure


Structure SpringConst

	NVAR kz_theory, kz_thermal, kz_Sader, kz_FluidStruc
	NVAR kTheta_theory, kTheta_thermal, kTheta_Sader, kTheta_FluidStruc
	NVAR ky_theory, ky_thermal, ky_Sader, ky_FluidStruc
	
	SVAR k_type
	
endStructure


Structure Sens

	NVAR SFz_noncont, Sz_noncont, Sslopez_noncont
	NVAR SFy_noncont, Sy_noncont, Sslopey_noncont

	NVAR SFz_cont, Sz_cont, Sslopez_cont
	NVAR SFy_cont, Sy_cont, Sslopey_cont

	NVAR Sz_CorrectionFactor
	NVAR Sy_CorrectionFactor

endStructure
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑

// END STRUCTURES


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
// calculate tau=mf/mc or =If/Ic
Function Calc_mfmc()

	DFREF dfcal=root:Packages:AFM_Calibration:
	NVAR/SDFR=dfcal cant_width
	NVAR/SDFR=dfcal cant_thickness_e
	NVAR/SDFR=dfcal cant_rho_e
	NVAR/SDFR=dfcal medium_dens
	SVAR/SDFR=dfcal spectrum_type
	
	if(numtype(cant_thickness_e)!=0)
		Abort "Set cantilever thickness estimate."
	endif
	
	variable tau=pi/4*cant_width/cant_thickness_e*medium_dens/cant_rho_e
	
	if(CmpStr(spectrum_type, "lateral")==0)
		tau*=3/2
	endif
	
	return tau

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑

// CORRECTION FACTORS

//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
// n = mode number
// xtip = tip position
// xlaser = laser spot position
// htip = normalized tip height (H_tip/L)
// inclAngle = cantilever inclination angle
Function Calc_Sz_CorrectionFactor(n, xtip, xlaser, mend2mc, htip, inclAngle)
	variable n, xtip, xlaser, mend2mc, htip, inclAngle
	
	variable Sz_CorrectionFactor, chi_N
	
	chi_N=1-htip/xtip*tan(inclAngle/180*pi)

	Sz_CorrectionFactor=dPhidx_m(n,xlaser, mend2mc)
	Sz_CorrectionFactor*=Phi_n2Norm_m(n,n,mend2mc)
	Sz_CorrectionFactor*=(3*chi_N-1)/3
	Sz_CorrectionFactor*=xtip*xtip/xlaser/(2*chi_N-xlaser/xtip)
	//Sz_CorrectionFactor*=cos(inclAngle/180*pi)

	return abs(Sz_CorrectionFactor)

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
// n = mode number
// xtip = tip position
// xlaser = laser spot position
// htip = normalized tip height (H_tip/L)
// inclAngle = cantilever inclination angle
Function Calc_Sz_CorrectionFactor2(n, xtip, xlaser, mend2mc, Iend2Ic, htip, inclAngle)
	variable n, xtip, xlaser, mend2mc, Iend2Ic, htip, inclAngle
	
	variable Sz_CorrectionFactor, chi_N
	
	chi_N=1-htip/xtip*tan(inclAngle/180*pi)

	Sz_CorrectionFactor=dPhidx_m_I(n,xlaser, mend2mc, Iend2Ic)
	Sz_CorrectionFactor*=Phi_n2Norm_m_I(n,n,mend2mc, Iend2Ic)
	Sz_CorrectionFactor*=(3*chi_N-1)/3
	Sz_CorrectionFactor*=xtip*xtip/xlaser/(2*chi_N-xlaser/xtip)
	//Sz_CorrectionFactor*=cos(inclAngle/180*pi)

	return abs(Sz_CorrectionFactor)

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Calc_Sy_CorrectionFactor(n, xlaser, Iend2Ic)
	variable n, xlaser, Iend2Ic
	
	variable Sy_CorrectionFactor
	
	Sy_CorrectionFactor=Psi_n_m(n,xlaser, Iend2Ic)
	Sy_CorrectionFactor*=Psi_n2Norm_m(n, Iend2Ic)

	return abs(Sy_CorrectionFactor)

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑

// END CORRECTION FACTORS

//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ButtonProc_Calc_t_vs_tf(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
				Calc_k_theory_vs_thick()
				
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Calc_k_theory_vs_thick()

	DFREF dfSav = GetDataFolderDFR()

	DFREF dfcal=root:Packages:AFM_Calibration:
	SetDataFolder dfcal
	
	SVAR Spectrum_type
	
	NVAR cant_thickness
	NVAR tip_H

	NVAR coat_a_thick
	NVAR coat_b_thick
	
	NVAR coat_b_thick1
	NVAR coat_b_thick2
	
	NVAR kz_theory
	NVAR ktheta_theory
	NVAR ky_theory
	
	variable coat_b_thickSav=coat_b_thick
	variable coat_a_thickSav=coat_a_thick
	
	coat_a_thick=0
	
	variable i, dt=(coat_b_thick2-coat_b_thick1)/10
	
	make/O/N=11 wthickS, wcoat_b_thickS, wtipHS, wkz_theoryS, wktheta_theoryS, wky_theoryS
	
	for(i=0;i<11;i+=1)
	
		coat_b_thick=i*dt
	
		// need to run DoUpdate for dependencies
		// for effective Young modulus, density, and thicknesses
		// kx runs iteratively for  t_film(f_res,t_film)
		// need to execute a few times for good convergences
		DoUpdate
		Calc_tH_from_fres()
		DoUpdate
		Calc_tH_from_fres()
		DoUpdate
		Calc_tH_from_fres()
		DoUpdate
		
		wthickS[i]=cant_thickness
		wcoat_b_thickS[i]=coat_b_thick
		
		wtipHS[i]=tip_H
		
		wkz_theoryS[i]=kz_theory
		wktheta_theoryS[i]=ktheta_theory
		wky_theoryS[i]=ky_theory
		
	endfor
	
	coat_b_thick=coat_b_thickSav
	coat_a_thick=coat_a_thickSav

	DoUpdate
	Calc_tH_from_fres()
	DoUpdate
	Calc_tH_from_fres()
	DoUpdate
	Calc_tH_from_fres()
	DoUpdate
	
	DoWindow/F kztheory

	if(V_flag==0)
		Display/K=1 /W=(354,48.5,748.5,257) wcoat_b_thickS vs wkz_theoryS
		DoWindow/C kztheory
		ModifyGraph mode=3
		ModifyGraph marker=19
		ModifyGraph mirror=2
		ModifyGraph minor=1
		ModifyGraph sep=10
		ModifyGraph gaps=0
		Label bottom "Spring constant (total) k\\Bz\\M (N/m)"
		Label left "Coating thickness (\\Em)"
		CurveFit/Q/TBOX=768 poly 3, wcoat_b_thickS /X=wkz_theoryS /F={0.95,4} /D
		TextBox/C/N=CF_wcoat_b_thickS/A=RB/X=0.00/Y=0.00
		// duplicate fit wave in case we want to fit t vs kx
		// b/c fit wave will be over written
		wave fit_wcoat_b_thickS
		Duplicate/O fit_wcoat_b_thickS, fit_wcoat_b_thickSz
		ReplaceWave trace=fit_wcoat_b_thickS, fit_wcoat_b_thickSz
	endif
	

	DoWindow/F kytheory

	if(V_flag==0)
		Display/K=1 /W=(354,48.5,748.5,257) wky_theoryS vs wcoat_b_thickS
		DoWindow/C kytheory
		ModifyGraph mode=3
		ModifyGraph marker=19
		ModifyGraph mirror=2
		ModifyGraph minor=1
		ModifyGraph sep=10
		ModifyGraph gaps=0
		Label bottom "Coating thickness (total) (\\Em)"
		Label left "Spring constant k\\Bx\\M (N/m)"
		Duplicate/O wcoat_b_thickS,fit_tfilmvskx
		CurveFit/Q/TBOX=768 poly 3, wky_theoryS /X=wcoat_b_thickS /F={0.95,4} /D
		TextBox/C/N=CF_wky_theoryS/A=RB/X=0.00/Y=0.00
//		wave fit_wky_theoryS
//		Duplicate/O fit_wky_theoryS, fit_wky_theorySx
//		ReplaceWave trace=fit_wky_theoryS, fit_wky_theorySx
	endif
	
//	if(V_flag==0)
//		Display/K=1 /W=(354,48.5,748.5,257) wcoat_b_thickS vs wky_theoryS
//		DoWindow/C kytheory
//		ModifyGraph mode=3
//		ModifyGraph marker=19
//		ModifyGraph mirror=2
//		ModifyGraph minor=1
//		ModifyGraph sep=10
//		ModifyGraph gaps=0
//		Label bottom "Spring constant k\\Bx\\M (N/m)"
//		Label left "Coating thickness (\\Em)"
//		Duplicate/O wcoat_b_thickS,fit_tfilmvskx
//		CurveFit/Q/TBOX=768 poly 3, wcoat_b_thickS /X=wky_theoryS /D
//		TextBox/C/N=CF_wcoat_b_thickS/A=RB/X=0.00/Y=0.00
//		wave fit_wcoat_b_thickS
//		Duplicate/O fit_wcoat_b_thickS, fit_wcoat_b_thickSx
//		ReplaceWave trace=fit_wcoat_b_thickS, fit_wcoat_b_thickSx
//	endif

	DoWindow/F TipH

	if(V_flag==0)
		Display/K=1 /W=(354,48.5,748.5,257) wtipHS vs wcoat_b_thickS
		DoWindow/C TipH
		ModifyGraph mode=3
		ModifyGraph marker=19
		ModifyGraph mirror=2
		ModifyGraph minor=1
		ModifyGraph sep=10
		ModifyGraph gaps=0
		Label bottom "Coating thickness (total) (\\Em)"
		Label left "Tip height H (\\Em)"
		CurveFit/Q/TBOX=768 poly 3, wtipHS /X=wcoat_b_thickS /F={0.95,4} /D
		TextBox/C/N=CF_wtipHS/A=RB/X=0.00/Y=0.00
//		wave fit_wtipHS
//		Duplicate/O fit_wtipHS, fit_wtipHSz
//		ReplaceWave trace=fit_wtipHS, fit_wtipHSz
	endif

	SetDataFolder dfSav

End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//		CALCULATION OF SPRING CONSTANTS FROM DIFFERENT MODELS


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Calc_spring(a, b, L, thick, E)
	variable a, b, L, thick, E
	
	
	variable width_avg=(a+b)/2
	variable delta=1/3*((1-a/b)/(1+a/b))^2
	variable spring=1/4*E*(thick/L)^3*width_avg*(1-delta)
	
	return spring	

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
// Calculates torsional constant for a trapezoid
Function Calc_J(a, b, t)
	variable a, b, t
	
	variable r=a/b
	variable J=(a+b)/2*t^3/6
	J*=1+2*r/(1+r)
	// correct for non-zero t/b
	J*=1-0.630247*t/((a+b)/2)
	
	return J

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Calc_k_theory()

	DFREF dfSav = GetDataFolderDFR()

	DFREF dfcal=root:Packages:AFM_Calibration:
	SetDataFolder dfcal

	STRUCT cantilever cant
	StructFill /SDFR=dfcal cant 

	STRUCT SpringConst k
	StructFill /SDFR=dfcal k 

	STRUCT Tip tip
	StructFill /SDFR=dfcal tip 

	k.kz_theory=Calc_spring(cant.cant_a, cant.cant_b, cant.cant_length_e, cant.cant_thickness_e, cant.cant_E_modulus_e)
	// convert to static spring constant
	k.kz_theory/=(cant.xtip)^3

	k.ktheta_theory=cant.cant_G_modulus_e
	k.ktheta_theory*=Calc_J(cant.cant_a, cant.cant_b, cant.cant_thickness_e)/cant.cant_length_e
	// convert to static spring constant
	k.ktheta_theory/=cant.xtip

	variable h=tip.tip_H_e*sqrt(1+tip.ytip^2)

	k.ky_theory=k.ktheta_theory/h^2

	SetDataFolder dfSav
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Calc_k_Sader()

	DFREF dfSav = GetDataFolderDFR()

	DFREF dfcal=root:Packages:AFM_Calibration:
	SetDataFolder dfcal

	STRUCT cantilever cant
	StructFill /SDFR=dfcal cant 

	STRUCT SpringConst k
	StructFill /SDFR=dfcal k 

	STRUCT Tip tip
	StructFill /SDFR=dfcal tip 

	SVAR model
	SVAR Spectrum_type

	NVAR Medium_dens
	NVAR Current_peak
	
	NVAR fixQ
	
	wave/C/Z wG
	if(WaveExists(wG)==0)
		return 1
	endif

	wave wf0
	wave wQ
	wave mode
	variable i=Current_peak-1
	
// if newly made peak with no fit, skip calculation
	if(numpnts(mode)<=i)
		return 1
	endif
	
	wave/Z PeakCoef=$("PeakCoef"+num2str(Current_peak))
	if(WaveExists(PeakCoef)==0)
		return 1
	endif

	if(strsearch(model, "SFO (full)",0)>=0)
		return 1
	endif

	variable Q=wQ[i]
	
	if(fixQ)
		SVAR PSD
		wave wPSD=$PSD
		variable alpha=pi/2/Q*wf0[i]/deltax(wPSD)
//		print alpha

//		Q*=1+12*(pi/alpha)^2+(12*(pi/alpha)^2)^2
		Q*=alpha*(1-sqrt(1-2/alpha))
	endif
	
	variable tau=2/(Q*imag(wG[i])-real(wG[i]))
	strswitch(Spectrum_type)
	
		case "normal":

			// peak was ignored
			if(PeakCoef[0]==0)
				k.kz_Sader=nan
				return 1
			endif

			k.kz_Sader= pi^3*medium_dens*cant.cant_width^2*cant.cant_length_e*wf0[i]^2*Q*imag(wG[i])

			k.kz_Sader*=3/C_n_m_I(Current_peak,cant.mend2mc,cant.Iend2Ic)^4
			k.kz_Sader/=(cant.xtip)^3
		break
	
		case "lateral":

			// peak was ignored
			if(PeakCoef[0]==0)
				k.kTheta_Sader=nan
				k.ky_Sader=nan
				return 1
			endif

			variable h=tip.tip_H_e*sqrt(1+tip.ytip^2)

			k.kTheta_Sader= pi^3/8*medium_dens*cant.cant_width^4*cant.cant_length_e*wf0[i]^2*Q*imag(wG[i])

			k.kTheta_Sader/=D_n_m(Current_peak,cant.Iend2Ic)^2
			k.kTheta_Sader/=cant.xtip
			k.ky_Sader=k.kTheta_Sader/h^2
		break

	endswitch
	
	SetDataFolder dfSav

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Calc_k_FluidStruc()

	DFREF dfSav = GetDataFolderDFR()

	DFREF dfcal=root:Packages:AFM_Calibration:
	SetDataFolder dfcal

	STRUCT cantilever cant
	StructFill /SDFR=dfcal cant 

	STRUCT SpringConst k
	StructFill /SDFR=dfcal k 

	STRUCT Tip tip
	StructFill /SDFR=dfcal tip 

	SVAR model
	SVAR Spectrum_type

	NVAR Medium_dens
	NVAR Current_peak
	
	wave wfvac
	
	// if newly made peak with no fit, skip calculation
	if(numpnts(wfvac)<=Current_peak-1)
		return 1
	endif
		
	wave/Z PeakCoef=$("PeakCoef"+num2str(Current_peak))
	if(WaveExists(PeakCoef)==0)
		return 1
	endif
			
	if(strsearch(model, "SFO (full)",0)<0)
		return 1
	endif

	// PeakCoef[2] is tau=mf/mc
	strswitch(Spectrum_type)
	
		case "normal":

			// peak was ignored
			if(PeakCoef[0]==0)
				k.kz_FluidStruc=nan
				return 1
			endif

			// ratio of kc to mc: kc/mc=3/Cn^4*wn^2
			k.kz_FluidStruc=(2*pi*wfvac[Current_peak-1])^2*3/C_n_m_I(Current_peak,cant.mend2mc,cant.Iend2Ic)^4
			// multiply by mc=mf/tau
			k.kz_FluidStruc*=pi*(cant.cant_width/2)^2*cant.cant_length_e*medium_dens
			k.kz_FluidStruc/=PeakCoef[2]
			// convert to static spring constant
			k.kz_FluidStruc/=(cant.xtip)^3
		break
	
		case "lateral":

			// peak was ignored
			if(PeakCoef[0]==0)
				k.kTheta_FluidStruc=nan
				k.ky_FluidStruc=nan
				return 1
			endif

			variable h=tip.tip_H_e*sqrt(1+tip.ytip^2)

			// ratio of kTheta to Ic: kTheta/Ic=1/Dn^2*wn^2
			k.kTheta_FluidStruc=(2*pi*wfvac[Current_peak-1]/D_n_m(Current_peak,cant.Iend2Ic))^2
			// multiply by Ic=If/tau
			k.kTheta_FluidStruc*=1/8*pi*(cant.cant_width/2)^2*cant.cant_length_e*medium_dens*(cant.cant_width)^2
			k.kTheta_FluidStruc/=PeakCoef[2]
			// convert to static spring constant
			k.kTheta_FluidStruc/=cant.xtip
			// convert kTheta to ky
			k.ky_FluidStruc=k.kTheta_FluidStruc/h^2
		break

	endswitch
	
	SetDataFolder dfSav

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Calc_k_thermal()

	DFREF dfSav = GetDataFolderDFR()

	DFREF dfcal=root:Packages:AFM_Calibration:
	SetDataFolder dfcal

	STRUCT cantilever cant
	StructFill /SDFR=dfcal cant 

	STRUCT Sens S
	StructFill /SDFR=dfcal S 

	STRUCT SpringConst k
	StructFill /SDFR=dfcal k 

	STRUCT Tip tip
	StructFill /SDFR=dfcal tip 

	SVAR model
	SVAR Spectrum_type
	NVAR Current_peak
	NVAR Medium_temperature

	wave/Z PeakCoef=$("PeakCoef"+num2str(Current_peak))
	if(WaveExists(PeakCoef)==0)
		return 1
	endif
	
	variable peakarea=Calc_peakArea(model, PeakCoef)

	strswitch(Spectrum_type)
	
		case "normal":
		
			k.kz_thermal=kBoltz*Medium_temperature
			// S.Sz_cont is the experimental sample displacement sens SN=Sz/cos(alpha)
			k.kz_thermal*=(S.Sz_cont*cos(cant.cant_inclination/180*pi)*S.Sz_CorrectionFactor)^2/peakarea
			k.kz_thermal*=3/C_n_m_I(Current_peak,cant.mend2mc,cant.Iend2Ic)^4

			// convert to static spring constant
			k.kz_thermal/=(cant.xtip)^3

		break
	
		case "lateral":
		
			variable h=tip.tip_H_e*sqrt(1+tip.ytip^2)
			
			variable Stheta_cont=S.Sy_cont*h*cant.xtip/cant.xlaser
			
			k.kTheta_thermal=kBoltz*Medium_temperature
			k.kTheta_thermal*=(Stheta_cont*S.Sy_CorrectionFactor)^2/peakarea
			k.kTheta_thermal*=1/D_n_m(Current_peak,cant.Iend2Ic)^2

			// convert to static spring constant
			k.kTheta_thermal/=cant.xtip

			k.ky_thermal=k.kTheta_thermal/h^2

		break
		
	endswitch


	SetDataFolder dfSav

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑

// 		End calculation of spring constants


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
//		Calculation of peak area
Function Calc_peakArea(model, PeakCoef)
	string model
	wave PeakCoef

	DFREF dfcal=root:Packages:AFM_Calibration:
	
	SVAR/SDFR=dfcal Spectrum_type

	NVAR/SDFR=dfcal DoNumericalIntegral
	NVAR/SDFR=dfcal G_option
	NVAR/SDFR=dfcal dens=medium_dens
	NVAR/SDFR=dfcal visc=medium_visc

	variable peakarea, V_Gr, V_Gi, fres

	variable Re, delta

	strswitch(model)
		case "SHO":
			peakarea=PeakCoef[0]
		break
	
		case "Lorentzian":
			peakarea=PeakCoef[0]*(1/2+atan(2*PeakCoef[2])/pi)
		break

		case "SFO (τ→0)":
			peakarea=PeakCoef[0]*(1/2+atan(PeakCoef[2])/pi)
		break

		case "SFO (τ→∞)":
		

			DoNumericalIntegral=1
				
			fres=PeakCoef[1]
		
			make/D/O/N=20000 FS_PSD
			SetScale/I x, 1, fres*3, FS_PSD	
			FS_PSD=SFO_pq(PeakCoef,x)
			WaveTransform zapNaNs  FS_PSD

			peakarea=area(FS_PSD,1,fres*3)
			KillWaves/Z FS_PSD
			
			//print "Integral=", peakarea, "A=", PeakCoef[0]
					
		break


		case "SFO (full)":
		

			switch(DoNumericalIntegral)
			
				case 0:
			
					peakarea=PeakCoef[0]
				
				break
					
				case 1:
				
					fres=PeakCoef[1]
				
					make/D/O/N=20000 FS_PSD
					SetScale/I x, 1, fres*3, FS_PSD
						
					switch(G_option)
					
						case 0:
						
							FS_PSD=SFOfull_k0_v0(PeakCoef,x)

						break
						
						case 1:
		
							FS_PSD=SFOfull_k_v0(PeakCoef,x)
							WaveTransform zapNaNs  FS_PSD

						break
						
					endswitch	
						
						
					peakarea=area(FS_PSD,1,fres*3)
					KillWaves/Z FS_PSD
					
					break
				
				endswitch
					
			break

		case "SFO (full) vn":
		
		switch(DoNumericalIntegral)
		
			case 0:

				peakarea=PeakCoef[0]
				
				break
				
			case 1:
		
					// need to calculate resonance frequency from Gamma
					// to set the range for the peak
					switch(G_option)
					
						case 0:
		
							wave/SDFR=dfcal wGr_coef=wGr_coefInf
//							wave/SDFR=dfcal wGi_coef=wGi_coefInf
							
						break

						case 1:
		
							wave/SDFR=dfcal wGr_coef=$("wGr_coef"+num2str(PeakCoef[4]))
//							wave/SDFR=dfcal wGi_coef=$("wGi_coef"+num2str(PeakCoef[4]))
							
						break

					endswitch			
				
					Re=dens*2*pi*PeakCoef[1]*PeakCoef[3]^2/visc
					delta=sqrt(2/Re)
					V_Gr=funcGreal(wGr_coef,delta)
	
					fres=PeakCoef[1]/sqrt(1+PeakCoef[2]*V_Gr)
//					print "res freq=", wres, "Gr=", Gr
				
					make/D/O/N=20000 FS_PSD
					SetScale/I x, 1, fres*3, FS_PSD
					
					switch(G_option)
					
						case 0:
	
							FS_PSD=SFOfull_k0_vn(PeakCoef,x)
							WaveTransform zapNaNs  FS_PSD
	
						break
						
						case 1:
	
							FS_PSD=SFOfull_k_vn(PeakCoef,x)
							WaveTransform zapNaNs  FS_PSD
									
						break
						
					endswitch	
						
					peakarea=area(FS_PSD,1,fres*3)
					KillWaves/Z FS_PSD
				
				break
				
			endswitch
			
		break

	endswitch


	// correct for decay in the detector sensitivity with frequency
	// this correction is good for sharp peaks but will be inadequate for overdampped peaks
	// in the latter case fix detector scale first then perfom the fit again on flattened data
	NVAR/SDFR=dfcal Detect_MTF_ignore
	if(Detect_MTF_ignore==0)
		NVAR/SDFR=dfcal Current_peak
		SVAR/SDFR=dfcal Model_Back
		wave/SDFR=dfcal/Z BkgdCoef
		wave/SDFR=dfcal/Z BkgdCoef_1overf
		NVAR/SDFR=dfcal use_1overf

		if(WaveExists(BkgdCoef))
			make/O/N=10000 backAdj
			SetScale/I x, 0, 2.5e6, backAdj
			// don't use 1/f noise , scaling is irrelevant since we are taking the ratio at two frequencies
			Make_Bkgd(model_Back, BkgdCoef, backAdj, BkgdCoef_1overf, 0, 1)

			if(numtype(PeakCoef[1])==0)
				//PeakCoef[1] is v0
				peakarea*=backAdj(0)/backAdj(PeakCoef[1])
			endif
			KillWaves/Z backAdj

		endif
	endif

	if(peakarea==0)
		peakarea=nan
	endif

	return peakarea

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function PopMenuProc_SelectSpectrumType(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr

			DFREF dfcal=root:Packages:AFM_Calibration:
			SVAR/SDFR=dfcal Spectrum_type
			SVAR/SDFR=dfcal model
			
			string S_popmenu="\"normal;lateral\""
			S_popmenu=ReplaceString(pa.popStr, S_popmenu, "\\M0: !*:"+pa.popStr,1,1)
			PopupMenu Type_tab1, mode=popNum, popvalue=popStr, value= #S_popmenu
			PopupMenu Type_tab2, mode=popNum, popvalue=popStr, value= #S_popmenu

			if(CmpStr(Spectrum_type, pa.popStr)!=0)
				Spectrum_type=pa.popStr
				FillPeakParams(model)
			else
				// no change, nothing to do
				return 0		
			endif

			wave/SDFR=dfcal Ampl
			
			strswitch(Spectrum_type)
			
				case "normal":
			
					SetFormula Ampl, "Phi_n(current_peak,x)"
					
					ModifyControl/Z mend disable=0, win=PanelScanXlaserMend
					ModifyControl/Z NOPmend disable=0, win=PanelScanXlaserMend
					ModifyControl/Z mendRange disable=0, win=PanelScanXlaserMend
					ModifyControl/Z ScanMend disable=0, win=PanelScanXlaserMend
					ModifyControl/Z Iend title="I\\Bend\\M/m\\Bc\\ML\\S2", win=PanelScanXlaserMend
					ModifyControl/Z IendRange title="∆I\\Bend\\M/m\\Bc\\ML\\S2\\M (±)", win=PanelScanXlaserMend
					ModifyControl/Z ScanXlaserMend title="Scan x\\Blaser\\M & m\\Bend\\M/m\\Bc", win=PanelScanXlaserMend
					ModifyControl/Z ScanXlaserMendIend disable=0, win=PanelScanXlaserMend
					ModifyControl/Z Iend_index disable=0, win=PanelScanXlaserMend
					ModifyControl/Z ScanIendY rename=ScanIendZ, win=PanelScanXlaserMend  
					ModifyControl/Z ScanIendZ title="Scan I\\Bend\\M/m\\Bc\\ML\\S2", win=PanelScanXlaserMend
							
					break
					
				case "lateral":
				
					SetFormula Ampl, "Psi_n(current_peak,x)"
				
					ModifyControl/Z mend disable=2, win=PanelScanXlaserMend
					ModifyControl/Z NOPmend disable=2, win=PanelScanXlaserMend
					ModifyControl/Z mendRange disable=2, win=PanelScanXlaserMend
					ModifyControl/Z ScanMend disable=2, win=PanelScanXlaserMend
					ModifyControl/Z Iend title="I\\Bend\\M/I\\Bc", win=PanelScanXlaserMend
					ModifyControl/Z IendRange title="∆I\\Bend\\M/I\\Bc\\M (±)", win=PanelScanXlaserMend
					ModifyControl/Z ScanXlaserMend title="Scan x\\Blaser\\M & I\\Bend\\M/I\\Bc", win=PanelScanXlaserMend
					ModifyControl/Z ScanXlaserMendIend disable=2, win=PanelScanXlaserMend
					ModifyControl/Z Iend_index disable=2, win=PanelScanXlaserMend
					ModifyControl/Z ScanIendZ rename=ScanIendY, win=PanelScanXlaserMend  
					ModifyControl/Z ScanIendY title="Scan I\\Bend\\M/I\\Bc", win=PanelScanXlaserMend
										
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
Function Load_SavedCoef()

	DFREF dfSav = GetDataFolderDFR()

	DFREF dfcal=root:Packages:AFM_Calibration:
	SetDataFolder dfcal
	
	NVAR num_peaks=dfcal:num_peaks

	string S_dfSavCoef="root:Packages:AFM_Calibration:SavCoef:"
	DFREF dfSavCoef=$S_dfSavCoef
	
	if(DataFolderExists(S_dfSavCoef)==0)
		Abort "Coefficients have not been saved." 
	endif
	
	// Make sure the model is correct
	SVAR model
	SVAR/SDFR=dfSavCoef SavModel=SavModel
	model=SavModel

	SVAR model_Back
	SVAR/SDFR=dfSavCoef SavModel_Back=SavModel_Back
	model_Back=SavModel_Back

	FillPeakParams(model)
	
	variable i
	for(i=1;i<num_peaks+1;i+=1)
		wave/T list= $("PeakCoef_list"+num2str(i))
		wave Coef=$("PeakCoef"+num2str(i))

		Duplicate/O dfSavCoef:$NameOfWave(Coef), Coef

		list[][1]=num2str(Coef[p])
		// restore dependency
		SetFormula Coef, "str2num(PeakCoef_list"+num2str(i)+"[p][1])"
	
	endfor

	// make sure dimensions match in poly
	FillBackParams(model_Back)
	
	wave BkgdCoef
	Duplicate/O dfSavCoef:$NameOfWave(BkgdCoef), BkgdCoef

	wave BkgdCoef_list
	Duplicate/O dfSavCoef:$NameOfWave(BkgdCoef_list), BkgdCoef_list

	wave BkgdCoef_list_Sel
	Duplicate/O dfSavCoef:$NameOfWave(BkgdCoef_list_Sel), BkgdCoef_list_Sel

//	wave/T  listB=BkgdCoef_list
//	Redimension/N=(numpnts(BkgdCoef),-1) listB
//	listB[][1]=num2str(BkgdCoef[p])
//	
//	wave/T  listB_Sel=BkgdCoef_list_Sel
//	Redimension/N=(numpnts(BkgdCoef),-1) listB_Sel

	wave BkgdCoef_1overf
	if(WaveExists(dfSavCoef:$NameOfWave(BkgdCoef_1overf))==1)
		Duplicate/O dfSavCoef:$NameOfWave(BkgdCoef_1overf), BkgdCoef_1overf
	endif

	wave/T  listB_1overf=BkgdCoef_1overf_list
	listB_1overf[][1]=num2str(BkgdCoef_1overf[p])
	
	// restore dependency
	SetFormula BkgdCoef_1overf, "str2num(BkgdCoef_1overf_list[p][1])"
	SetFormula BkgdCoef, "str2num(BkgdCoef_list[p][1])"
	
	Update_CurrentPeak()
	Update_BackGrnd()

	SetDataFolder dfSav

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑

// FITTING 

//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ButtonProc_DoFit(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			SVAR currentGraph=root:packages:AFM_Calibration:CurrentGraph
			DoWindow/F $currentGraph
			if(V_flag==0)
				Abort "The PSD "+currentGraph+" is not displayed."			
			endif

			if(strlen(CsrInfo(A,currentGraph)) == 0 || strlen(CsrInfo(B,currentGraph)) == 0 )
				KillWindow/Z myProgress
				Abort "Use cursors to set fitting range." 
				return 1
			endif
		
			ProgressBar(currentGraph, "Fitting PSD", "PSD fit", DoFit)
		break

	endswitch

End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑

Function DoLongCalc()

end

//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ProgressBar(win2block, S_PanelTitle, S_WhatIsProgress, func2exe)
	string win2block, S_PanelTitle, S_WhatIsProgress
	FUNCREF DoLongCalc func2exe
	
	variable w=340, h=60, yc, xc
	
	GetWindow/Z $win2block wsize
	xc=(V_left+V_right)/2
	yc=(V_top+V_bottom)/2
	// left, top, right, bottom
	//print V_left, V_top, V_right, V_bottom
	GetWindow/Z kwFrameOuter wsize
	variable VL, VR, VT, VB
	VL=V_left+(ScreenResolution/72)*(xc-w/2)
	VT=V_top+(ScreenResolution/72)*(yc-h/2)
	VR=V_left+(ScreenResolution/72)*(xc+w/2)
	VB=V_top+(ScreenResolution/72)*(yc+h/2)
	NewPanel/FLT /N=myProgress/W=(VL, VT, VR, VB) as S_PanelTitle
	// "Fitting PSD"

	SetDrawLayer UserBack
	SetDrawEnv textrgb= (39321,1,1), fsize= 16
//	DrawText 98,26,"PSD fit is in progress. Please wait..."
	DrawText 98,26, S_WhatIsProgress+" is in progress. Please wait..."
	ValDisplay valdisp0,pos={18,41},size={340,20},limits={0,100,0},barmisc={0,0}
	ValDisplay valdisp0,value= _NUM:0
	ValDisplay valdisp0,mode= 4	// candy stripe
	Button bStop,pos={375,38},size={50,24},title="Abort"
	SetActiveSubwindow _endfloat_
	DoUpdate/W=myProgress/E=1		// mark this as our progress window
	
	SetWindow myProgress,hook(spinner)=MySpinHook
	
	strswitch(S_WhatIsProgress)
	
		case "PSD fit":

			variable V_chisq=DoFit()
			// update results if fit was not aborted
			// otherwise do nothing
			if(V_chisq)
				Calc_Results(0)
			endif
	
		break
		
		case "Parameter scan":
	
			func2exe()

		break
		
	
	endswitch

	KillWindow/Z myProgress

End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function MySpinHook(s)
	STRUCT WMWinHookStruct &s
	
	if( s.eventCode == 23 )
		ValDisplay valdisp0,value= _NUM:1,win=$s.winName
		DoUpdate/W=$s.winName
		if( V_Flag == 2 )	// we only have one button and that means abort
			KillWindow $s.winName
			return 1
		endif
	endif
	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function DoFit()

	DFREF dfSav = GetDataFolderDFR()

	DFREF dfcal=root:Packages:AFM_Calibration:
	
	SetDataFolder dfcal
	
	STRUCT cantilever cant
	StructFill /SDFR=dfcal cant 
	
	SVAR Spectrum_type
	SVAR model
	SVAR model_Back
	SVAR PSD
	SVAR CurrentGraph
	
	NVAR num_peaks
	NVAR use_current
	NVAR current_peak
	NVAR use_1overf
	NVAR V_BackScale
	NVAR use_ScaleBack
	
	NVAR medium_visc
	NVAR medium_dens
	
	NVAR G_option
	NVAR ReNum
	NVAR Relog
	
	NVAR Chisq
	NVAR iterate_do
	NVAR iterate_max

	NVAR use_fitted_Coef
	NVAR fitType
	NVAR V_delta_max
	
	String SumOfFunctions=""
	String/G FittingFunc=""
	String/G FittingFuncBack=""
	
	NVAR globalTau
	NVAR globalWidth
	NVAR globalpq
	
	variable Sav_Current_Peak=Current_Peak
	
	NewDataFolder/O SavCoef			
	DFREF dfSavCoef=root:Packages:AFM_Calibration:SavCoef:
	// save the name of the model
	String/G dfSavCoef:SavModel
	String/G dfSavCoef:SavModel_Back
	SVAR/SDFR=dfSavCoef SavModel
	SVAR/SDFR=dfSavCoef SavModel_Back
	SavModel=model
	SavModel_Back=Model_Back

	wave wPSD=$PSD

	DoWindow/F $CurrentGraph

	if(V_flag==0)
		SetDataFolder dfSav
		KillWindow/Z myProgress
		Abort "Graph not displayed." 
		return 1
	endif

	if(strlen(CsrInfo(A,CurrentGraph)) == 0 || strlen(CsrInfo(B,CurrentGraph)) == 0 )
		SetDataFolder dfSav
		KillWindow/Z myProgress
		Abort "Use cursors to set fitting range." 
		return 1
	endif


	// assign fitting function
	strswitch(model)
		case "SHO":
			FittingFunc="SHO"
		break
	
		case "Lorentzian":
			FittingFunc="Lorentzian"
		break

		case "SFO (τ→0)":
			FittingFunc="SFO"
		break

		case "SFO (τ→∞)":
			FittingFunc="SFO_pq"
		break

		case "SFO (full)":
		
			switch(G_option)
			
				case 0:
					FittingFunc="SFOfull_k0_v0"
				break
				
				case 1:
					FittingFunc="SFOfull_k_v0"
				break

			endswitch
			
		break

		case "SFO (full) vn":
		
			switch(G_option)
			
				case 0:
					FittingFunc="SFOfull_k0_vn"
				break
				
				case 1:
					FittingFunc="SFOfull_k_vn"
				break

			endswitch
			
		break

	endswitch

	string wnCoef="PeakCoef_list"
	string PeakCoef="PeakCoef"
	string hold=""

	variable X0=min(hcsr(A, CurrentGraph),hcsr(B, CurrentGraph))
	variable X1=max(hcsr(A, CurrentGraph),hcsr(B, CurrentGraph))
	
	X0=GetExactX(wPSD, X0)
	X1=GetExactX(wPSD, X1)
	
	variable i, j
	
	variable startPeak, NumPeaks2fit
	
	if(use_current)
		startPeak=current_peak
		NumPeaks2fit=1
	else
		startPeak=1
		NumPeaks2fit=num_peaks
	endif
	
	// create coef wave for calculations of Gamma in the infinite beam approximation (kappa = 0)
	// always make it in case evaluation of integral is done after fit with non-zero kappa
	// reduce the range of delta to < 2 (usually to freq. > 500 Hz)
	// improves agreement between fitted and numerical Gamma for kappa=0
	// mode adjusted Gamma is evaluated for each peak below
	Calc_Gamma2(spectrum_type, 0, use_fitted_Coef, -4, 4, fitType, 2) 
	wave wGi_coef						
	wave wGr_coef
	Duplicate/O 	wGi_coef, wGi_coefInf					
	Duplicate/O 	wGr_coef, wGr_coefInf

	variable Re, delta
	variable Gr_avg=0

	// figure out if all peaks are within region defined by cursors
	// and build sum of fit functions with respective hold parameters
	// Make constraints wave if fitting to Fluid-Struc models
	// where amplitude and mf/mc ratio should stay positive
	Make/O/T/N=0 ConstrTextWave1=""
	Make/O/T/N=0 ConstrTextWave2=""
	Make/O/T/N=0 ConstrTextWave3=""
	wave/T ConstrTextWave1
	wave/T ConstrTextWave2
	wave/T ConstrTextWave3
	
	variable NumOfCoef=0

	for(i=startPeak;i<startPeak+NumPeaks2fit;i+=1)
		wave/T list= $(wnCoef+num2str(i))
		Make/O/N=(DimSize(list,0)) $(PeakCoef+num2str(i))
		wave Coef=$(PeakCoef+num2str(i))
		Coef=str2num(list[p][1])
		wave list_sel= $(wnCoef+num2str(i)+"_Sel")
		
		// Save coef to reverse fit results in the next step if chosen
		Duplicate/O Coef, dfSavCoef:$NameOfWave(Coef)

		// if peak is ignored, A=0, and all other coef must be const
		if(Coef[0]==0)
			list_sel[][2]=48
		endif
			
		strswitch(spectrum_type)
		
			case "normal":
			
				if(strsearch(model, "SFO (full)", 0) >=0)
					cant.cant_kappa=C_n_m_I(Coef[4],cant.mend2mc,cant.Iend2Ic)*Coef[3]/cant.cant_length_e				
				else
					cant.cant_kappa=C_n_m_I(i,cant.mend2mc,cant.Iend2Ic)*cant.cant_width/cant.cant_length_e
				endif
				
			break

		
			case "lateral":
		
				if(strsearch(model, "SFO (full)", 0) >=0)
					cant.cant_kappa=D_n_m(Coef[4],cant.Iend2Ic)*Coef[3]/cant.cant_length_e
				else
					cant.cant_kappa=D_n_m(i,cant.Iend2Ic)*cant.cant_width/cant.cant_length_e
				endif
				
			break

		endswitch

		// check if all peaks are within range set by cursors
		strswitch(model)

			case "SFO (τ→∞)":
						
				// peak is ignored if A=0 and all coef are held constant
				// in this case const coef take priority
				// otherwise global fit parameter takes priority -- issue warning
				
				if(Coef[0]>0)
				
					// cannot hold coef constant and constrained
					if((i-startPeak)>0)

						if(list_sel[3][2]==32)
							Redimension/N=(numpnts(ConstrTextWave2)+2) ConstrTextWave2
							ConstrTextWave2[numpnts(ConstrTextWave2)-2]="K"+num2str(3+(i-startPeak)*5)+">=K3"
							ConstrTextWave2[numpnts(ConstrTextWave2)-1]="K"+num2str(3+(i-startPeak)*5)+"<=K3"
						endif
	
						if(list_sel[4][2]==32)
							Redimension/N=(numpnts(ConstrTextWave3)+2) ConstrTextWave3
							ConstrTextWave3[numpnts(ConstrTextWave3)-2]="K"+num2str(4+(i-startPeak)*5)+">=K4"
							ConstrTextWave3[numpnts(ConstrTextWave3)-1]="K"+num2str(4+(i-startPeak)*5)+"<=K4"
						endif

					endif

				endif

			break

			case "SFO (full) vn":
						
				// peak is ignored if A=0 and all coef are held constant
				// in this case const coef take priority
				// otherwise global fit parameter takes priority -- issue warning
				
				if(Coef[0]>0)
				
					// cannot hold coef constant and constrained
					if((i-startPeak)>0)
						if(list_sel[2][2]==32)
							Redimension/N=(numpnts(ConstrTextWave1)+2) ConstrTextWave1
							ConstrTextWave1[numpnts(ConstrTextWave1)-2]="K"+num2str(2+(i-startPeak)*5)+">=K2"
							ConstrTextWave1[numpnts(ConstrTextWave1)-1]="K"+num2str(2+(i-startPeak)*5)+"<=K2"
						endif

						if(list_sel[3][2]==32)
							Redimension/N=(numpnts(ConstrTextWave2)+2) ConstrTextWave2
							ConstrTextWave2[numpnts(ConstrTextWave2)-2]="K"+num2str(3+(i-startPeak)*5)+">=K3"
							ConstrTextWave2[numpnts(ConstrTextWave2)-1]="K"+num2str(3+(i-startPeak)*5)+"<=K3"
						endif
	
					endif

				endif

				// if adjusting for mode number, we need to create
				// separate waves containing fit coefficients for Gamma for each peak
				// these Gamma coefficients will be used by the fit function
				// one-time calculation of coefficients => used multiple times during fit
				// this approach avoids a fit for each point in PSD to get Gamma values
				// or interpolation for each point in PSD 
				// if no fitting of Gamma is used (i.e. direct look up from Sader's table)
				
				// Coef[3]=width
				// Coef[4]=mode
				if(g_Option==1)
					//cant_kappa=C_n(Coef[4])*Coef[3]/cant_length_e
					Calc_Gamma2(spectrum_type, cant.cant_kappa, use_fitted_Coef, -4, 4, fitType, V_delta_max) 
					wave wGi_coef						
					wave wGr_coef
					Duplicate/O 	wGi_coef, $("wGi_coef"+num2str(i))					
					Duplicate/O 	wGr_coef, $("wGr_coef"+num2str(i))
				else
					// we already have Gamma for infinite beam
					cant.cant_kappa=0
				endif				

				// for model "SFO (full) vn"
				// peak freq is fitted to value in vacuum
				// estimate resonance freq in fluid from freq in vacuum
				Re=medium_dens*2*pi*((X0+X1)/2)*cant.cant_width^2/medium_visc
				delta=sqrt(2/Re)
				//Gr_avg=funcGimag(wGr_coef,delta)
				Gr_avg=funcGreal(wGr_coef,delta)
				
				variable wres=Coef[1]/sqrt(1+Coef[2]*Gr_avg)
				//print "peak", i, "wres=", wres
			
				if(wres<X0 || wres>X1)
					SetDataFolder dfSav
					KillWindow/Z myProgress
					Abort "Peak "+num2str(i)+" is outside of the range defined by cursors."
				endif

			break
			
			case "SFO (full)":

				if(Coef[1]<X0 || Coef[1]>X1)
					SetDataFolder dfSav
					KillWindow/Z myProgress
					Abort "Peak "+num2str(i)+" is outside of the range defined by cursors."
				endif
				
				// peak is ignored if A=0 and all coef are held constant
				// in this case const coef take priority
				// otherwise global fit parameter takes priority -- issue warning
				
				if(Coef[0]>0)
				
					// cannot hold coef constant and constrained
					if((i-startPeak)>0)
						if(list_sel[2][2]==32)
							Redimension/N=(numpnts(ConstrTextWave1)+2) ConstrTextWave1
							ConstrTextWave1[numpnts(ConstrTextWave1)-2]="K"+num2str(2+(i-startPeak)*5)+">=K2"
							ConstrTextWave1[numpnts(ConstrTextWave1)-1]="K"+num2str(2+(i-startPeak)*5)+"<=K2"
						endif

						if(list_sel[3][2]==32)
							Redimension/N=(numpnts(ConstrTextWave2)+2) ConstrTextWave2
							ConstrTextWave2[numpnts(ConstrTextWave2)-2]="K"+num2str(3+(i-startPeak)*5)+">=K3"
							ConstrTextWave2[numpnts(ConstrTextWave2)-1]="K"+num2str(3+(i-startPeak)*5)+"<=K3"
						endif
	
					endif

				endif


				// if adjusting for mode number, we need to create
				// separate waves containing fit coefficients for Gamma for each peak
				// these Gamma coefficients will be used by the fit function
				// one-time calculation of coefficients => used multiple times during fit
				// this approach avoids a fit for each point in PSD to get Gamma values
				// or interpolation for each point in PSD 
				// if no fitting of Gamma is used (i.e. direct look up from Sader's table)
				
				// Coef[3]=width
				// Coef[4]=mode
				if(g_Option==1)
					//cant_kappa=C_n(Coef[4])*Coef[3]/cant_length_e
					Calc_Gamma2(spectrum_type, cant.cant_kappa, use_fitted_Coef, -4, 4, fitType, V_delta_max) 
					wave wGi_coef						
					wave wGr_coef
					Duplicate/O 	wGi_coef, $("wGi_coef"+num2str(i))					
					Duplicate/O 	wGr_coef, $("wGr_coef"+num2str(i))
				else
					// we already have Gamma for infinite beam
					cant.cant_kappa=0
				endif				

			break

			default:
			
				if(Coef[1]<X0 || Coef[1]>X1)
					SetDataFolder dfSav
					KillWindow/Z myProgress
					Abort "Peak "+num2str(i)+" is outside of the range defined by cursors."
				endif
				
				Redimension/N=(2*NumPeaks2fit) ConstrTextWave1
				// A and Q must be positive
				ConstrTextWave1[(i-startPeak)*2]="K"+num2str(0+(i-startPeak)*3)+">0"
				ConstrTextWave1[(i-startPeak)*2+1]="K"+num2str(2+(i-startPeak)*3)+">0"
				
				// tau and width are not parameters for SHO fits
				globalTau=0
				globalWidth=0						
			
			break
		
		endswitch

		hold=""
		for(j=0;j<DimSize(list_sel,0);j+=1)
			hold+=num2str((list_sel[j][2]-32)/16)
		endfor

		NumOfCoef+=j
		
		SumOfFunctions+="{"+FittingFunc+","+(PeakCoef+num2str(i))+", hold=\""+hold+"\"}"

	endfor


	//  make proper constraint wave 
	if(globalpq==1)
		print "WARNING: Fitting global (p,q). (p,q) cannot be held constant and global. Abort fit to choose constant (p,q)."
		concatenate/NP/O {ConstrTextWave2, ConstrTextWave3}, ConstrTextWave
	endif

	if(globalTau==1 && globalWidth==1)
		print "WARNING: Fitting global tau. Tau cannot be held constant and global. Abort fit to choose constant tau."
		print "WARNING: Fitting global width. Width cannot be held constant and global. Abort fit to choose constant width."
		concatenate/NP/O {ConstrTextWave1, ConstrTextWave2}, ConstrTextWave
	endif

	if(globalTau==1 && globalWidth==0 && globalpq==0)
		print "WARNING: Fitting global tau. Tau cannot be held constant and global. Abort fit to choose constant tau."
		Duplicate/O ConstrTextWave1, ConstrTextWave
	endif

	if(globalTau==0 && globalWidth==1 && globalpq==0)
		print "WARNING: Fitting global width. Width cannot be held constant and global. Abort fit to choose constant width."
		Duplicate/O ConstrTextWave2, ConstrTextWave
	endif

	if(globalTau==0 && globalWidth==0 && globalpq==0)
		Duplicate/O ConstrTextWave1, ConstrTextWave
	endif
	
	if(globalTau==1 || globalWidth==1 || globalpq==1)
		print "Constraints:", ConstrTextWave
	endif


	// constraint wave for global fit params (tau)
	wave/T ConstrTWave=$"ConstrTextWave"
	// constraint wave for local fit params
	make/T/N=1/O ConstrTextWaveLocalParam
	wave/T ConstrTextWaveLocalParam
	ConstrTextWaveLocalParam[0]=""

	// do 1/f first
	wave/T  list=BkgdCoef_1overf_list
	Make/O/N=(DimSize(list,0))/D BkgdCoef_1overf
	wave BkgdCoef_1overf
	BkgdCoef_1overf=str2num(list[p][1])

	// add 1/f noise fit, if selected
	if(use_1overf==1)

		// Save coef for 1/f noise to reverse fit results in the next step if chosen
		Duplicate/O BkgdCoef_1overf, dfSavCoef:$NameOfWave(BkgdCoef_1overf)

		wave list_sel=BkgdCoef_1overf_list_Sel
		variable NOConst=0
		variable AConst=0
		
		hold=""
		for(j=0;j<DimSize(list_sel,0);j+=1)
			hold+=num2str((list_sel[j][2]-32)/16)
			if(j==2)
				AConst=(list_sel[j][2]-32)/16
			endif
			NOConst+=(list_sel[j][2]-32)/16
		endfor
	
		SumOfFunctions+="{power, BkgdCoef_1overf, hold=\""+hold+"\"}"
		
		// the 1/f noise cannot increase with freq
		// must have positive A
		// skipe if all params are held constant
//		if(AConst==1 && NOConst<3)
//			variable NOPConW=numpnts(ConstrTWave)
//			Redimension/N=(NOPConW+1) ConstrTWave
//			ConstrTWave[NOPConW]="K"+num2str(NumOfCoef+1)+">0"
//			ConstrTextWaveLocalParam[0]="K"+num2str(NumOfCoef+1)+">0"
//		endif
		
		print "Constraints 1/f:", ConstrTextWaveLocalParam

		
	endif
// do 1/f first

	wave/T  list=BkgdCoef_list
	wave list_sel= BkgdCoef_list_Sel
	
	Make/O/N=(DimSize(list,0))/D BkgdCoef
	wave BkgdCoef
	BkgdCoef=str2num(list[p][1])

	// Save coef to reverse fit results in the next step if chosen
	String/G SavModel_Back
	SavModel_Back=model_Back
	Duplicate/O BkgdCoef, dfSavCoef:$NameOfWave(BkgdCoef)
	Duplicate/O list, dfSavCoef:$NameOfWave(list)
	Duplicate/O list_sel, dfSavCoef:$NameOfWave(list_sel)

	hold=""
	for(j=0;j<DimSize(list_sel,0);j+=1)
		hold+=num2str((list_sel[j][2]-32)/16)
	endfor

	FittingFuncBack=model_Back
	
	strswitch(model_Back)

		case "constant":
			FittingFuncBack="line"
			Redimension/N=2 BkgdCoef	// needed to fix up coefficient wave for line fit used to fit a constant
			BkgdCoef[1]=0
			hold[1]="1"
			use_ScaleBack=0
		break

	endswitch

	if(use_ScaleBack)

		if(strsearch(model_Back, "poly", 0)>=0)
			FittingFuncBack="ScaledPoly"
		else
			FittingFuncBack="Scaled"+model_Back
		endif
		Redimension/N=(numpnts(BkgdCoef)+1) BkgdCoef
		BkgdCoef[numpnts(BkgdCoef)-1]=V_BackScale
		
		hold+="0"
	
	endif

	// add fit function for noise
	SumOfFunctions+="{"+FittingFuncBack+", BkgdCoef, hold=\""+hold+"\"}"
		
	print SumOfFunctions
	string/G SOF
	SOF=SumOfFunctions

	Duplicate/O wPSD, $("fit_"+NameOfWave(wPSD))
	wave wfit=$("fit_"+NameOfWave(wPSD))
	Duplicate/O wPSD, $("Res_"+NameOfWave(wPSD))
	wave wResid=$("Res_"+NameOfWave(wPSD))
	
	variable NOP=(X1-X0)/deltax(wPSD)+1
//	Variable V_fitOptions=0
	variable/G V_FitError=0

	variable timerRefNum=StartMsTimer

	// NOTE: potential IGOR BUG
	// for some reason constraint wave screws up generation of the fit and residual waves by IGOR
	// if 1/f background coef are held constant AND constriant is used

	// can iterate only for SFO (full) models
	if(strsearch(model, "SFO (full)",0)>=0)
		variable mcmf_avg=0, width_avg=0
		variable mcmf_avgSav=0, width_avgSav=0
	
		// calculate average values from the coef
		for(i=startPeak;i<startPeak+NumPeaks2fit;i+=1)
			wave Coef=$(PeakCoef+num2str(i))
			
			mcmf_avg+=Coef[2]
			width_avg+=Coef[3]
		endfor
	
		mcmf_avg/=NumPeaks2fit
		width_avg/=NumPeaks2fit
					
		cant.cant_width=width_avg
	
		//	Do fit
		if(iterate_do)
		
			mcmf_avgSav=mcmf_avg
			width_avgSav=width_avg
	
			for(j=0;j<iterate_max;j+=1)
								
				for(i=startPeak;i<startPeak+NumPeaks2fit;i+=1)
					wave Coef=$(PeakCoef+num2str(i))
					
					// recalculate Gamma
					// Coef[3]=width
					// Coef[4]=mode
					if(g_Option==1)
						//cant_kappa=C_n(Coef[4])*Coef[3]/cant_length_e
						Calc_Gamma2(spectrum_type, cant.cant_kappa, use_fitted_Coef, -4, 4, fitType, V_delta_max) 
						wave wGi_coef						
						wave wGr_coef
						Duplicate/O 	wGi_coef, $("wGi_coef"+num2str(i))					
						Duplicate/O 	wGr_coef, $("wGr_coef"+num2str(i))
					else
						// we already have Gamma for infinite beam
						cant.cant_kappa=0
					endif				

					// set initial params to average values from the last fit
					Coef[2]=mcmf_avg
					Coef[3]=width_avg


				endfor
			
				if((globalTau==1 || globalWidth==1))
					//FuncFit/Q/L=(NOP) {string = SumOfFunctions} wPSD(X0,X1) /D=wfit /R=wResid /F={0.95, 4} /C=ConstrTextWave
					FuncFit/Q/L=(NOP) {string = SumOfFunctions} wPSD(X0,X1) /D=wfit /R=wResid /C=ConstrTWave
				else
					//FuncFit/Q/L=(NOP) {string = SumOfFunctions} wPSD(X0,X1) /D=wfit /R=wResid /F={0.95, 4}
					if(NOConst==3)
					// all 1/f coef held const, cannot constraint
						FuncFit/Q/L=(NOP) {string = SumOfFunctions} wPSD(X0,X1) /D=wfit /R=wResid
					else
						FuncFit/Q/L=(NOP) {string = SumOfFunctions} wPSD(X0,X1) /D=wfit /R=wResid //C=ConstrTextWaveLocalParam
					endif
				endif
				
				// calculate average values from the last fit
				mcmf_avg=0
				width_avg=0
				for(i=startPeak;i<startPeak+NumPeaks2fit;i+=1)
					wave Coef=$(PeakCoef+num2str(i))
					
					mcmf_avg+=Coef[2]
					width_avg+=Coef[3]
				endfor
				
				mcmf_avg/=NumPeaks2fit
				width_avg/=NumPeaks2fit
				
				print "iteration ", j
				print "m convergence", abs(mcmf_avgSav-mcmf_avg)/mcmf_avgSav
				print "w convergence", abs(width_avgSav-width_avg)/width_avgSav
				
				if( abs(mcmf_avgSav-mcmf_avg)/mcmf_avgSav<0.001  &&  abs(width_avgSav-width_avg)/width_avgSav<0.001)
					break
				endif
				
				mcmf_avgSav=mcmf_avg
				width_avgSav=width_avg
				
				cant.cant_width=width_avg
			
			endfor
		
		else
		// SFO (full) model, but no iteration

			if(globalTau==1 || globalWidth==1 || globalpq==1)
				//FuncFit/Q/L=(NOP) {string = SumOfFunctions} wPSD(X0,X1) /D=wfit /R=wResid /F={0.95, 4} /C=ConstrTextWave
				FuncFit/Q/L=(NOP) {string = SumOfFunctions} wPSD(X0,X1) /D=wfit /R=wResid /C=ConstrTWave
			else
				if(NOConst==3)
				// all 1/f coef held const, cannot constraint
					FuncFit/Q/L=(NOP) {string = SumOfFunctions} wPSD(X0,X1) /D=wfit /R=wResid
				else
					FuncFit/Q/L=(NOP) {string = SumOfFunctions} wPSD(X0,X1) /D=wfit /R=wResid //C=ConstrTextWaveLocalParam
				endif
			endif

		endif
		
	// this is an approximate model
	// no iteration, just fit once
	// the only globals possible for approximate models are (p,q)
	else
	
		iterate_do=0
		
		if(globalpq==1)
			//FuncFit/Q/L=(NOP) {string = SumOfFunctions} wPSD(X0,X1) /D=wfit /R=wResid /F={0.95, 4} /C=ConstrTextWave
			FuncFit/Q/L=(NOP) {string = SumOfFunctions} wPSD(X0,X1) /D=wfit /R=wResid /C=ConstrTWave
		else
			//FuncFit/Q/L=(NOP) {string = SumOfFunctions} wPSD(X0,X1) /D=wfit /R=wResid /F={0.95, 4}
			//FuncFit/Q/L=(NOP) {string = SumOfFunctions} wPSD(X0,X1) /D=wfit /R=wResid /C=ConstrTextWave
			
			if(NOConst==3)
			// all 1/f coef held const, cannot constraint
				FuncFit/Q/L=(NOP) {string = SumOfFunctions} wPSD(X0,X1) /D=wfit /R=wResid
			else
				FuncFit/Q/L=(NOP) {string = SumOfFunctions} wPSD(X0,X1) /D=wfit /R=wResid //C=ConstrTextWaveLocalParam
			endif
		endif

	endif

	
	if(V_FitError==3)
		DoAlert 0, "Fit error: fit function returned NaN or INF value. Try holding some or all 1/f noise parameters or exclude 1/f noise."
		//return 1
	endif
	if(V_FitError==1)
		DoAlert 0, "Fit error: singular matrix. Review hold params for 1/f noise parameters or exclude 1/f noise."
		//return 1
	endif
	//print "V_FitError=", V_FitError

	// mess around with output wave to get the right region for the fit
	Duplicate/O/R=(X0, X1) wfit, $("fit0_"+NameOfWave(wPSD))
	wave wfit0=$("fit0_"+NameOfWave(wPSD))
	Duplicate/O wfit0, wfit
	KillWaves/Z wfit0
	// mess around with output residuals wave to get the right region for the residuals
	Duplicate/O/R=(X0, X1) wResid, $("Res0_"+NameOfWave(wPSD))
	wave wResid0=$("Res0_"+NameOfWave(wPSD))
	Duplicate/O wResid0, wResid
	KillWaves/Z wResid0
	
	ChiSq=V_chisq
	
	WaveStats/Q wResid
	GetAxis/W=$(CurrentGraph)/Q Res_Left
	if(V_flag==1)
		AppendToGraph/L=Res_Left wResid
		Label Res_Left "Residuals"
		ModifyGraph axisEnab(left)={0,0.8}
		ModifyGraph axisEnab(left)={0,0.8},axisEnab(Res_Left)={0.8,1},freePos(Res_Left)=0	
		ModifyGraph mirror=2
		ModifyGraph lblPos(Res_Left)=80
	endif
	SetAxis Res_Left -5*V_sdev,+5*V_sdev
	ModifyGraph zero(Res_Left)=1
	
	// needed to fix up coefficient wave for line fit used to fit a constant
	strswitch(model_Back)
		case "constant":
			Redimension/N=1 BkgdCoef		
			Redimension/N=(1,-1) list
			Redimension/N=(1,-1) list_sel
		break
		
	endswitch

	if(use_ScaleBack)
		V_BackScale=BkgdCoef[numpnts(BkgdCoef)-1]
		print "background scaled by", num2str(V_BackScale)
		Redimension/N=(numpnts(BkgdCoef)-1) BkgdCoef
	else
		V_BackScale=1
	endif

	// create background wave using fit coefficients
	// set resolution to that of original PSD
	
	
	string StrCoef=""

	wave/T  list=BkgdCoef_list

	for(i=0;i<DimSize(list,0);i+=1)
		sprintf StrCoef, "%.6g", BkgdCoef[i]
		list[i][1]=StrCoef
	endfor
	
//	list[][1]=num2str(BkgdCoef[p])

	wave/T  list=BkgdCoef_1overf_list

	for(i=0;i<DimSize(list,0);i+=1)
		sprintf StrCoef, "%.6g", BkgdCoef_1overf[i]
		list[i][1]=StrCoef
	endfor

//	list[][1]=num2str(BkgdCoef_1overf[p])

	SetFormula BkgdCoef_1overf, "str2num(BkgdCoef_1overf_list[p][1])"
	SetFormula BkgdCoef, "str2num(BkgdCoef_list[p][1])"

	// FuncFit appends the fit -- we need to check the "show fit" box
	NVAR fit_checked
	fit_checked=1
	
	// set status variable need for smooth initialization
	NVAR fit_done
	fit_done=1

	// make sure the fit is indeed displayed
	CheckDisplayed/W=$CurrentGraph wPSD, wFit

	if(V_flag==1)
		AppendToGraph/W=$CurrentGraph wFit
		// change color of the fit wave
		ModifyGraph lsize($("fit_"+NameOfWave(wPSD)))=2,rgb($("fit_"+NameOfWave(wPSD)))=(0,0,65280)
	endif
				
	// set resolution of the background wave to match that of PSD and fit
	Duplicate/O wfit, $("Back_"+NameOfWave(wPSD))
	wave back=$("Back_"+NameOfWave(wPSD))
	
	Make_Bkgd(model_Back, BkgdCoef, back, BkgdCoef_1overf, use_1overf, V_BackScale)
	
	// create some waves with results for future use
	DoFit_CalcResults(startPeak,NumPeaks2fit)
	
	// create current peak wave using fit coefficients
	Current_Peak=Sav_Current_Peak
	Update_CurrentPeak()
	
	wnCoef="PeakCoef_list"+num2str(Current_Peak)
	ListBox Peak_params_tab1,listWave=root:Packages:AFM_Calibration:$(wnCoef), win=Panel_Cal
	ListBox Peak_params_tab1,selWave=root:Packages:AFM_Calibration:$(wnCoef+"_Sel"), win=Panel_Cal
	ListBox Peak_params_tab1, titleWave=root:Packages:AFM_Calibration:PeakParam_Name, win=Panel_Cal

	SetDataFolder dfSav
	
	ControlUpdate/W=Panel_Cal iterate_tab1

	print "calculation time", StopMSTimer(timerRefNum)/1e6, "sec"
	print "V_chisq =", V_chisq

	return V_chisq

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
// Process results 
// and store them in Results DF for future use and analysis
Function DoFit_CalcResults(startPeak,NumPeaks2fit)
	variable startPeak,NumPeaks2fit
	
	DFREF dfSav = GetDataFolderDFR()

	DFREF dfcal=root:Packages:AFM_Calibration:
	
	SetDataFolder dfcal
	
	STRUCT cantilever cant
	StructFill /SDFR=dfcal cant 

	STRUCT Sens S
	StructFill /SDFR=dfcal S 

	STRUCT SpringConst k
	StructFill /SDFR=dfcal k 

	SVAR Spectrum_type
	SVAR model
	SVAR model_Back
	SVAR PSD
	NVAR num_peaks
	NVAR current_peak
	NVAR use_1overf
	
	NVAR medium_visc
	NVAR medium_dens
	
	NVAR G_option
	NVAR Chisq
	NVAR iterate_do
	NVAR iterate_max
	
	NVAR ReNum
	NVAR Relog
	NVAR cant_kappa
	
	// update listing of coef
	// make auxilary waves for 1/w^2, C/a^4, area of the peak, etc.

	Make/O/N=(num_peaks) w2Inv, wCn4Inv, wCn, wDn, mode
	Make/O/N=(num_peaks) wpeakarea
	Make/O/N=(num_peaks) wf0, wfvac, wQ, wtau, wSNR
	Make/O/N=(num_peaks) wlogRe, wnorm_mode, wDelta
	Make/O/N=(num_peaks)/C wG, wG_Error
	
	make/O/N=(num_peaks) wSz_CorrectionFactor, wSy_CorrectionFactor 
	make/O/N=(num_peaks) wkz_thermal, wkz_Sader, wkz_FluidStruc 
	make/O/N=(num_peaks) wSFz_cont, wSz_Sader, wSz_FluidStruc 
	make/O/N=(num_peaks) wkTheta_thermal, wkTheta_Sader, wkTheta_FluidStruc
	make/O/N=(num_peaks) wky_thermal, wky_Sader, wky_FluidStruc
	make/O/N=(num_peaks) wSFy_cont, wSx_Sader, wSx_FluidStruc 

	// make waves for errors
	make/O/N=(num_peaks) wkz_thermal_Del, wkz_Sader_Del, wkz_FluidStruc_Del 
	make/O/N=(num_peaks) wSFz_cont_Del, wSz_Sader_Del, wSz_FluidStruc_Del 
	make/O/N=(num_peaks) wkTheta_thermal_Del, wkTheta_Sader_Del, wkTheta_FluidStruc_Del
	make/O/N=(num_peaks) wky_thermal_Del, wky_Sader_Del, wky_FluidStruc_Del
	make/O/N=(num_peaks) wSFy_cont_Del, wSx_Sader_Del, wSx_FluidStruc_Del 

	variable norm_mode_Point, ampl

	mode=p+1

	string wnCoef="PeakCoef_list"
	string PeakCoef="PeakCoef"
	
	wave wPSD=$PSD
	Duplicate/O wPSD, wPeak
	
	variable width
	variable i
	variable delta
	variable Q_coef

	// populate auxilary weaves using results of the fits
	for(i=startPeak-1;i<startPeak-1+NumPeaks2fit;i+=1)
		wave/T list= $(wnCoef+num2str(i+1))
		wave/SDFR=dfcal Coef=$(PeakCoef+num2str(i+1))
		list[][1]=num2str(Coef[p])
		SetFormula Coef, "str2num("+wnCoef+num2str(i+1)+"[p][1])"

		wave/SDFR=dfcal Sigma=$("W_sigma_"+num2str(i))
		// Convert to 95 % CL
		// comment out if St. dev. is preffered
		Sigma*=StatsInvStudentCDF(0.975, numpnts(wPSD))
		Duplicate/O Sigma, $("Sigma_"+PeakCoef+num2str(i+1))
		//KillWaves/Z Sigma

		wpeakarea[i]=Calc_peakarea(model,Coef)
		
		// Calculate hydrodynamic function for use with Sader formula
		if(strsearch(model, "SFO (full)",0)>=0)
			width=Coef[3]
		else
			width=cant.cant_width
		endif
		
		strswitch(Spectrum_type)
				
			case "normal":
				wnorm_mode[i]=C_n_m_I(mode[i],cant.mend2mc,cant.Iend2Ic)*width/cant.cant_length_e
						
				break
					
			case "lateral":
				wnorm_mode[i]=D_n_m(mode[i],cant.Iend2Ic)*width/cant.cant_length_e
				
				break
					
		endswitch	

		switch(G_option)
		
			// no adjustment for normalized mode
			// calculate from the fit to Gamma for kappa=0

			case 0:
			
				wave wGi_coef=wGi_coefInf						
				wave wGr_coef=wGr_coefInf
						
			break
			
			// adjustment for normalized mode
			// calculate from the fit to Gamma
			case 1:

				//  coef wave is created for every peak 
				wave wGi_coef=$("wGi_coef"+num2str(i+1))						
				wave wGr_coef=$("wGr_coef"+num2str(i+1))
								
			break
		
		endswitch
		
		// assign resonance frequency
		wf0[i]=Coef[1]

		wCn[i]=C_n_m_I(i+1,cant.mend2mc,cant.Iend2Ic)
		wDn[i]=D_n_m(i+1,cant.Iend2Ic)

		wCn4Inv[i]=3/wCn[i]^4

		ReNum=(medium_dens*2*pi*wf0[i]*width^2)/medium_visc
		Relog=log(ReNum)
		wlogRe[i]=Relog
		wDelta[i]=sqrt(2/ReNum)

		// make proper assignment for Q and vacuum frequency
		strswitch(model)
		
			// we know Q and res freq
			case "SHO":
			case "Lorentzian":
			case "SFO (τ→0)":
				wf0[i]=Coef[1]
				// sometimes SHO fits results in negative Q
				if(Coef[2]<0)
					Coef[2]=abs(Coef[2])
				endif
				wQ[i]=Coef[2]

				// calculate gamma at resonance
				wG[i]=cmplx(funcGreal(wGr_coef,wDelta[i]),funcGimag(wGi_coef,wDelta[i]))
				// calculate tau=mf/mc
				wtau[i]=1/(wQ[i]*imag(wG[i])-real(wG[i]))
				// calculate vacuum frequency
				wfvac[i]=wf0[i]*sqrt(1+wtau[i]*real(wG[i]))
			break
			
			// use approximate formulas for tau and fvac
			case "SFO (τ→∞)":
				wf0[i]=Coef[1]
				// sometimes SHO fits results in negative Q
				if(Coef[2]<0)
					Coef[2]=abs(Coef[2])
				endif
				wQ[i]=Coef[2]

				// calculate gamma at resonance
				wG[i]=cmplx(funcGreal(wGr_coef,wDelta[i]),funcGimag(wGi_coef,wDelta[i]))
				// calculate tau=mf/mc
				wtau[i]=1/(wQ[i]*imag(wG[i])-real(wG[i]))

				// correction for approximation of the Q in the fit to (p,q)
				if(wtau[i]<0.1)
					Q_coef=Calc_QLightLoad(Coef[3])
				else
					Q_coef=Calc_QHeavyLoad(Spectrum_type, wDelta[i], Coef[3], Coef[4])
				endif

				wQ[i]=Coef[2]/Q_coef
				wtau[i]=1/(wQ[i]*imag(wG[i])-real(wG[i]))
				// calculate vacuum frequency
				wfvac[i]=wf0[i]*sqrt(1+wtau[i]*real(wG[i]))
			break

			// we know tau and res freq
			case "SFO (full)":
				wtau[i]=Coef[2]
				wf0[i]=Coef[1]
				// calculate gamma at resonance
				wG[i]=cmplx(funcGreal(wGr_coef,wDelta[i]),funcGimag(wGi_coef,wDelta[i]))
				// calculate quality factor
				wQ[i]=(1+wtau[i]*real(wG[i]))/(wtau[i]*imag(wG[i]))
				// calculate natural freq in vacuum
				wfvac[i]=wf0[i]*sqrt(1+wtau[i]*real(wG[i]))
			break

			// we know tau and vacuum res freq
			case "SFO (full) vn":
				
				switch(G_option)
				
					case 0:

						wPeak=SFOfull_k0_vn(Coef,x)

					break
					
					case 1:

						wPeak=SFOfull_k_vn(Coef,x)

				endswitch

				// natural freq in vacuum
				wfvac[i]=Coef[1]
				wtau[i]=Coef[2]
				
				// get the resonance frequency from the position of the maximum
				WaveStats/Q wPeak
				wf0[i]=V_maxloc
				print "vac freq 1 = ", wf0[i]

				ReNum=(medium_dens*2*pi*wf0[i]*width^2)/medium_visc
				Relog=log(ReNum)
				wlogRe[i]=Relog
				wDelta[i]=sqrt(2/ReNum)

				// calculate gamma at resonance
				wG[i]=cmplx(funcGreal(wGr_coef,wDelta[i]),funcGimag(wGr_coef,wDelta[i]))

				wQ[i]=(1+wtau[i]*real(wG[i]))/(wtau[i]*imag(wG[i]))
				wf0[i]=wfvac[i]/sqrt(1+wtau[i]*real(wG[i]))
				print "vac freq 1 = ", wf0[i]

			break

		endswitch

		// calculate 1/w^2 for fit of 1/w^2 vs 3/Cn^4 to get kc/mc ratio
		w2Inv[i]=1/(2*pi*wfvac[i])^2


		// Calculate signal-to-noise ratio
		// calculate P(v0) from coef A 
		wSNR[i]=Coef[0]*wQ[i]/wf0[i]*2/pi
		// get noise level from the residuals away from the peak
		WaveStats/Q/R=(wf0[i]*(1+2/wQ[i]),wf0[i]*(1+3/wQ[i])) $("Res_"+NameOfWave(wPSD))
		//print wf0[i]*(1+2/wQ[i]),wf0[i]*(1+3/wQ[i])
		wSNR[i]/=V_sdev

		// estimate error in Gamma due to approximate shape
		// cant_kappa=wnorm_mode[i]
		// norm_mode_Point=Calc_NormP(cant_kappa)

		norm_mode_Point=Calc_NormP(wnorm_mode[i])
		print "log(Re) =", wlogRe[i],"norm point num =", norm_mode_Point, "Gamma =", wG[i]

		strswitch(Spectrum_type)

			case "normal":
			
				wave wGammaIm=GammaFvs_Re_modeIm
				wave wGammaRe=GammaFvs_Re_modeRe
				
			break
			
			case "lateral":
			
				wave wGammaIm=GammaTvs_Re_modeIm
				wave wGammaRe=GammaTvs_Re_modeRe
				
			break
		
		endswitch
		
		variable Gi
		variable Gr
		
		if(G_option==0)
			norm_mode_Point=0		
		endif
				
		Gi=Interp2D(wGammaIm,wlogRe[i],norm_mode_Point)
		Gr=Interp2D(wGammaRe,wlogRe[i],norm_mode_Point)
		wG_Error[i]=cmplx(Gr,Gi)-wG[i]
		
		// +++++++++++++++
		current_peak=i+1
		Update_CurrentPeak()

		wSz_CorrectionFactor[i]=S.Sz_CorrectionFactor
		wSy_CorrectionFactor[i]=S.Sy_CorrectionFactor

		// thermal and Sader constants can be calculated for all models
		k.k_type="thermal"
		Calc_k_thermal()
		wkz_thermal[i]=k.kz_thermal
		wSFz_cont[i]=S.SFz_cont

		k.k_type="Sader"
		Calc_k_Sader()
		wkz_Sader[i]=k.kz_Sader
		Update_Sens()
		wSz_Sader[i]=S.SFz_noncont

		strswitch(model)
			case "SHO":
			case "Lorentzian":
			case "SFO (τ→0)":
			case "SFO (τ→∞)":

			break
			
			case "SFO (full)":
			case "SFO (full) vn":
				k.k_type="FluidStruc"
				Calc_k_FluidStruc()
				wkz_FluidStruc[i]=k.kz_FluidStruc

				Update_Sens()
				wSz_FluidStruc[i]=S.SFz_noncont
				
			break
		endswitch
		//+++++++++++++++++

	endfor

	SetDataFolder dfSav

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑

Function Calc_QLightLoad(pexp)
	variable pexp
	
	variable c1, c2, c3
	variable coef
	
	c1=1
	
	c2=0.5547
	
	c3=0.4453
			
	coef=c1*(1+c2*pexp+c3*pexp^3)
	
	return coef

end


Function Calc_QHeavyLoad(spectrumType, delta0, pexp, qexp)
	string spectrumType
	variable delta0, pexp, qexp
	
	variable c1, c2, c3, c4, c5, c6
	variable coef
	
	c4=0
	c5=0
	c6=0
	
	strswitch(spectrumType)
	
		case "normal":

			c1=0.9862-0.4923*delta0+0.2144*delta0^2
			
			c2=0.5387+0.4827*delta0+0.5478*delta0^2
			
			c3=0.4366+0.2093*delta0
			
			break
	
		case "lateral":
		
		
			c1=0.9272+0.5539*delta0-8.2396*delta0^2+9.0947*delta0^3

			if(delta0<0.3)
				
				c2=0.6110-0.9081*delta0+11.315*delta0^2
				
				c3=0.4209+0.5607*delta0
			
			else

				c2=-1.1895+8.5545*delta0
				
				c3=1.3445-5.4691*delta0+9.8405*delta0^2

			
			endif

			c4=0.1723-4.4321*delta0+24.233*delta0^2-14.348*delta0^3

			c5=-0.2802+7.2417*delta0-39.771*delta0^2+34.604*delta0^3

			c6=0.1351-3.2834*delta0+20.367*delta0^2-21.476*delta0^3
			
			break

	endswitch

	coef=c1*(1+c2*pexp+c3*pexp^3)*(1+c4*qexp+c5*qexp^2+c6*qexp^3)
	
	return coef

end

// END FITTING

//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Make_Bkgd(model_Back, BkgdCoef, back, BkgdCoef_1overf, use_1overf, V_BackScale)
	string model_Back
	wave BkgdCoef
	wave back
	wave/Z BkgdCoef_1overf
	variable use_1overf
	variable V_BackScale


	strswitch(model_Back)

		case "constant":
			back=BkgdCoef[0]
		break
			
		case "line":
			back=BkgdCoef[0]+BkgdCoef[1]*x
		break
	
		case "poly 3":
		case "poly 4":
		case "poly 5":
		case "poly 7":
		case "poly 9":
		case "poly 13":
		case "poly 19":
			back=poly(BkgdCoef, x)
		break

		case "Lor":
			back=BkgdCoef[0]+BkgdCoef[1]/((x-BkgdCoef[2])^2+BkgdCoef[3])
		break

		case "power":
			back=BkgdCoef[0]+BkgdCoef[1]*x^BkgdCoef[2]
		break
	
		case "exp":
			back=BkgdCoef[0]+BkgdCoef[1]*exp(-BkgdCoef[2]*x)
		break

	endswitch
	
	back*=V_BackScale

	if(use_1overf==1 && WaveExists(BkgdCoef_1overf)==1)
		back+=BkgdCoef_1overf[0]+BkgdCoef_1overf[1]*x^BkgdCoef_1overf[2]
	endif
	

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function RunFSFits(mfmc_start, mfmc_end, SumOfFunctions)
	variable mfmc_start, mfmc_end
	string SumOfFunctions

	DFREF dfSav = GetDataFolderDFR()

	DFREF dfcal=root:Packages:AFM_Calibration:
	SetDataFolder dfcal
	NVAR num_peaks=dfcal:num_peaks
	SVAR PSD=dfcal:PSD
	
	wave wPSD=$PSD

	variable mfmc_del=(mfmc_end-mfmc_start)/10
	
	string PeakCoef="PeakCoef"

	variable i,j
	
	make/O/N=10 wchisq
	SetScale/I x mfmc_start, mfmc_end,"", wchisq
	
	for(i=1;i<num_peaks+1;i+=1)
		make/O/N=10  $("wpeak"+num2str(i))
		wave wpeak=$("wpeak"+num2str(i))
		SetScale/I x mfmc_start, mfmc_end,"", wpeak
	endfor 

	
	for(j=0;j<10;j+=1)
	
		Load_SavedCoef()
	
		for(i=1;i<num_peaks+1;i+=1)
			wave Coef=$(PeakCoef+num2str(i))
			Coef[2]=mfmc_start+mfmc_del*j
		endfor 
	
		FuncFit/L=2000 /W=2 /Q {string = SumOfFunctions} wPSD(hcsr(A),hcsr(B)) /D /R
		wchisq[j]=V_chisq
		
		for(i=1;i<num_peaks+1;i+=1)
			wave wpeak=$("wpeak"+num2str(i))
			wave Coef=$(PeakCoef+num2str(i))
			wpeak[j]=Coef[1]
			print wpeak[j]
		endfor
		 
		print wchisq[j]

	endfor

	SetDataFolder dfSav

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function CheckProc_ShowCursors(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	DFREF dfcal=root:Packages:AFM_Calibration:
	SVAR/SDFR=dfcal CurrentGraph
	DoWindow/F $CurrentGraph
	
	NVAR/SDFR=dfcal cursors_checked

	if(V_flag==0)
		cursors_checked=0
		DoAlert 0, "Graph ["+CurrentGraph+"] is not displayed."
		return 1
	endif

	if(checked)
		Cursor_Add2Plot()
	else
		Cursor/K A
		Cursor/K B
	endif
	
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Cursor_Add2Plot()

	DFREF dfcal=root:Packages:AFM_Calibration:
	SVAR/SDFR=dfcal PSD
	SVAR/SDFR=dfcal CurrentGraph
	NVAR/SDFR=dfcal cursors_checked

	wave wPSD=$PSD

	DoWindow/F $CurrentGraph
	CheckDisplayed/W=$CurrentGraph wPSD 
	
	if(V_flag==1)
		string wn=NameOfWave(wPSD)
		Cursor/P/F/S=0/H=2 A $wn  0.25, 0.05 
		Cursor/P/F/S=0/H=2 B $wn  0.75, 0.25
	else
		cursors_checked=0
		DoAlert 0, "PSD wave is not displayed."
	endif
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function CheckProc_AppendFit(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba


	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked

			DFREF dfcal=root:Packages:AFM_Calibration:
			SVAR/SDFR=dfcal PSD
			SVAR/SDFR=dfcal CurrentGraph
			wave wPSD=$(PSD)

			wave/SDFR=dfcal/Z Fit=$("fit_"+NameOfWave(wPSD))
			wave/SDFR=dfcal/Z FitX=$("fitX_"+NameOfWave(wPSD))
			wave/SDFR=dfcal/Z CurrentPeak
			NVAR/SDFR=dfcal current_peak
			SVAR/SDFR=dfcal model
			
			NVAR/SDFR=dfcal currentpeak_checked
			NVAR/SDFR=dfcal fit_checked
			NVAR/SDFR=dfcal background_checked

			wave/SDFR=dfcal/Z Back=$("Back_"+NameOfWave(wPSD))
			SVAR/SDFR=dfcal model_Back
			wave/SDFR=dfcal/Z BkgdCoef
			wave/SDFR=dfcal/Z BkgdCoef_1overf
			NVAR/SDFR=dfcal use_1overf
			NVAR/SDFR=dfcal V_BackScale

			DoWindow/F $CurrentGraph
			
			variable GraphShown=V_flag
			

			strswitch(cba.ctrlName)
			
				case "ShowFit_tab1":

					if(GraphShown==0)
						fit_checked=0
						return 1
					endif
		
		
					if(WaveExists(Fit)==0)
						fit_checked=0
						Abort "Peform fitting first."
					endif

					if(checked)
						
						CheckDisplayed/W=$CurrentGraph wPSD, Fit
					
						if(V_flag==1)
							AppendToGraph/W=$CurrentGraph Fit
							ModifyGraph lsize($("fit_"+NameOfWave(wPSD)))=2,rgb($("fit_"+NameOfWave(wPSD)))=(0,0,65280)
						endif
					else
						RemoveFromGraph/W=$CurrentGraph/Z $NameOfWave(Fit)
					endif
					
				break
					
				case "ShowCurrentPeak_tab1":
				
					if(GraphShown==0)
						currentpeak_checked=0
						return 1
					endif
		
		
					if(checked)
						if(WaveExists(CurrentPeak)==0)
							currentpeak_checked=0
							Abort "Estimate peak parameters first."
						endif
						AppendToGraph/W=$CurrentGraph CurrentPeak
						ModifyGraph lsize($(NameOfWave(CurrentPeak)))=2,rgb($(NameOfWave(CurrentPeak)))=(0,65280,0)
						Update_CurrentPeak()
					else
						RemoveFromGraph/W=$CurrentGraph/Z $NameOfWave(CurrentPeak)
					endif
				
				break
				
				case "ShowBack_tab1":
				
					if(GraphShown==0)
						background_checked=0
						return 1
					endif

					if(WaveExists(Back)==0)
						background_checked=0
						Abort "Perform background estimation or spectrum fitting first."
					endif
		
					if(checked)
					
						variable X0, X1
						if(strlen(CsrInfo(A))>0 && strlen(CsrInfo(A))>0)
							X0=hcsr(A, currentGraph)
							X1=hcsr(B, currentGraph)
							
							X0=GetExactX(wPSD, X0)
							X1=GetExactX(wPSD, X1)
			
							variable NOP=abs(X1-X0)/deltax(wPSD)+1
							Redimension/N=(NOP) Back
							SetScale/P x, min(X0, X1), deltax(wPSD), "Hz", Back
						endif
		
						Make_Bkgd(model_Back, BkgdCoef, back, BkgdCoef_1overf, use_1overf, V_BackScale)
		
						CheckDisplayed/W=$CurrentGraph wPSD, Back
					
						if(V_flag==1)
							AppendToGraph/W=$CurrentGraph Back
							ModifyGraph lsize($("Back_"+NameOfWave(wPSD)))=2,rgb($("Back_"+NameOfWave(wPSD)))=(0,0,0)
						endif
					else
						RemoveFromGraph/W=$CurrentGraph/Z $NameOfWave(Back)
					endif
		
					break				
				
				break
					
			endswitch

		break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function PopMenuProc_Model(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	
	switch( pa.eventCode )
		case 2: // mouse up

//			string S_popmenu="\"SHO;Lorentzian;SFO (τ→0);SFO (τ→∞);SFO (full);SFO (full) vn\""
//			S_popmenu=ReplaceString(pa.popStr, S_popmenu, "\\M0: !*:"+pa.popStr,1,1)
//			PopupMenu popup_model_tab1,value= #S_popmenu

			string S_popmenu=Get_S_popmenu(pa.popStr, pa.ctrlName, "Panel_Cal")
			variable V_mode=Get_N_popmenu(pa.popStr, pa.ctrlName, "Panel_Cal")
			PopupMenu $pa.ctrlName,value= #S_popmenu,popvalue=pa.popStr,mode=V_mode

			FillPeakParams(pa.popStr)

			DFREF dfcal=root:Packages:AFM_Calibration:
			SVAR k_type=dfcal:k_type
			
			strswitch(pa.popStr)
			
				case "SHO":
				case "Lorentzian":
				case "SFO (τ→0)":
				case "SFO (τ→∞)":
				
					k_type="Sader"
				
				break
				
				case "SFO (full)":
				case "SFO (full) vn":
				
					k_type="FluidStruc"
				
				break

			endswitch
			
			S_popmenu=Get_S_popmenu(k_type, "k_for_TLS_tab2", "Panel_Cal")
			V_mode=Get_N_popmenu(k_type, "k_for_TLS_tab2", "Panel_Cal")
			PopupMenu k_for_TLS_tab2,value= #S_popmenu,popvalue=k_type,mode=V_mode
			
			Update_SpringConst()
			Update_Sens()
			
		break

	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function FillPeakParams(modelSelect)
	string modelSelect

	DFREF dfSav = GetDataFolderDFR()
	
	DFREF dfcal=root:Packages:AFM_Calibration:
	SetDataFolder dfcal
	SVAR model
	NVAR num_peaks
	NVAR cant_b
	NVAR cant_width
	NVAR g_Option
	SVAR spectrum_type
	
	NVAR globalpq
	NVAR globaltau
	NVAR globalwidth

	string modelSav=model
	model = modelSelect

	string wnCoefList="PeakCoef_list"
	string wnCoef="PeakCoef"
	
	variable i=1
	for(i=1;i<num_peaks+1;i+=1)
	
		strswitch(model)
		
			case "SHO":
			case "Lorentzian":
			case "SFO (τ→0)":
				redimension/N=(3,-1) $(wnCoef+num2str(i))
				redimension/N=(3,-1) $(wnCoefList+num2str(i))
				redimension/N=(3,-1) $(wnCoefList+num2str(i)+"_Sel")
				wave/T list= $(wnCoefList+num2str(i))
				list[0][0]="A"
				list[1][0]="Res freq (Hz)"
				list[2][0]="Q"
				wave list_Sel=$(wnCoefList+num2str(i)+"_Sel")
				list_Sel[][0]=0
				list_Sel[][1]=0x02
				list_Sel[][2]=0x20

				if(strsearch(modelSav,"SFO (full)",0)>=0)
					wave/C/Z wG
					wave/Z wtau
					if(WaveExists(wG))
						list[2][1]=num2str( (1+wtau[i-1]*real(wG[i-1]))/wtau[i-1]/imag(wG[i-1]) )
					else
						list[2][1]=num2str(1/Calc_mfmc())				
					endif
				endif
				
				globalpq=0
				globaltau=0
				globalwidth=0
			break
			
			case "SFO (τ→∞)":
				redimension/N=(5,-1) $(wnCoef+num2str(i))
				redimension/N=(5,-1) $(wnCoefList+num2str(i))
				redimension/N=(5,-1) $(wnCoefList+num2str(i)+"_Sel")
				wave/T list= $(wnCoefList+num2str(i))
				list[0][0]="A"
				list[1][0]="Res freq (Hz)"
				list[2][0]="Q"
				list[3][0]="p"
				list[4][0]="q"
				wave list_Sel=$(wnCoefList+num2str(i)+"_Sel")
				list_Sel[][0]=0
				list_Sel[][1]=0x02
				list_Sel[][2]=0x20
				list_Sel[4][2]=0x20
				list_Sel[3][2]=0x20
// fixed values
//				list_Sel[4][2]=0x20+0x10
//				list_Sel[3][2]=0x20+0x10

				if(strsearch(modelSav,"SFO (full)",0)>=0)
					wave/C/Z wG
					wave/Z wtau
					if(WaveExists(wG))
						list[2][1]=num2str( (1+wtau[i-1]*real(wG[i-1]))/wtau[i-1]/imag(wG[i-1]) )
					else
						list[2][1]=num2str(1/Calc_mfmc())				
					endif
				endif
				
				list[3][1]="0"
				list[4][1]="0"
				
				
				globalpq=1
				globaltau=0
				globalwidth=0
				
			break

			case "SFO (full)":
				redimension/N=(5,-1) $(wnCoef+num2str(i))
				redimension/N=(5,-1) $(wnCoefList+num2str(i))
				redimension/N=(5,-1) $(wnCoefList+num2str(i)+"_Sel")
				wave/T list= $(wnCoefList+num2str(i))
				list[0][0]="A"
				list[1][0]="Res freq (Hz)"
				list[2][0]="τ (or η)"
				list[3][0]="width (m)"
				list[4][0]="mode"
				
				// set A
				//list[0][1]=num2str(10^i)
				// set vac res freq
				//list[1][1]=""
				// set mf/mc
				list[2][1]=num2str(Calc_mfmc())
				// set default value for width
				list[3][1]=num2str(cant_width)
				// set value for mode
				list[4][1]=num2str(i)
				
				wave list_Sel=$(wnCoefList+num2str(i)+"_Sel")
				list_Sel[][0]=0
				list_Sel[][1]=0x02
				list_Sel[][2]=0x20
				list_Sel[4][2]=0x20+0x10
				list_Sel[3][2]=0x20+0x10
				list_Sel[1][2]=0x20
//				list_Sel[1][2]=0x20+0x10

				globalpq=0
				globaltau=1
				globalwidth=0
			break
									
			case "SFO (full) vn":
				redimension/N=(5,-1) $(wnCoef+num2str(i))
				redimension/N=(5,-1) $(wnCoefList+num2str(i))
				redimension/N=(5,-1) $(wnCoefList+num2str(i)+"_Sel")
				wave/T list= $(wnCoefList+num2str(i))
				list[0][0]="A"
				list[1][0]="Vac freq (Hz)"
				list[2][0]="τ (or η)"
				
				// set A
				//list[0][1]=num2str(10^i)
				// set vac res freq
				//list[1][1]=""
				// set mf/mc
				list[2][1]=num2str(Calc_mfmc())
				// set default value for width
				list[3][1]=num2str(cant_width)
				// set value for mode
				list[4][1]=num2str(i)
				
				wave list_Sel=$(wnCoefList+num2str(i)+"_Sel")
				list_Sel[][0]=0
				list_Sel[][1]=0x02
				list_Sel[][2]=0x20
				list_Sel[4][2]=0x20+0x10
				list_Sel[3][2]=0x20+0x10
				list_Sel[1][2]=0x20
//				list_Sel[1][2]=0x20+0x10

				globalpq=0
				globaltau=1
				globalwidth=0
			break

		endswitch
		
		//list[][1]=num2str(Coef[p])
		wave Coef=$(wnCoef+num2str(i))
		SetFormula Coef, "str2num("+wnCoefList+num2str(i)+"[p][1])"
		

	endfor

	DoUpdate/W=Panel_Cal
	SetDataFolder dfSav

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ListBoxProc_UpdatePeaks(lba) : ListBoxControl
	STRUCT WMListboxAction &lba

	Variable row = lba.row
	Variable col = lba.col
	WAVE/T/Z listWave = lba.listWave
	WAVE/Z selWave = lba.selWave

	switch( lba.eventCode )
		case -1: // control being killed
			break
		case 1: // mouse down
			break
		case 3: // double click
			break
		case 4: // cell selection
		case 5: // cell selection plus shift key
			break
		case 6: // begin edit
			break
		case 7: // finish edit
		
			DFREF dfcal=root:Packages:AFM_Calibration:
			NVAR/SDFR=dfcal currentpeak_checked
			
			if(currentpeak_checked)
				Update_CurrentPeak()
			endif
			
			break
		case 13: // checkbox clicked (Igor 6.2 or later)
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ListBoxProc_UpdateBack(lba) : ListBoxControl
	STRUCT WMListboxAction &lba

	Variable row = lba.row
	Variable col = lba.col
	WAVE/T/Z listWave = lba.listWave
	WAVE/Z selWave = lba.selWave

	switch( lba.eventCode )
		case -1: // control being killed
			break
		case 1: // mouse down
			break
		case 3: // double click
			break
		case 4: // cell selection
		case 5: // cell selection plus shift key
			break
		case 6: // begin edit
			break
		case 7: // finish edit
		
			
			DFREF dfcal=root:Packages:AFM_Calibration:
			NVAR/SDFR=dfcal background_checked
			NVAR/SDFR=dfcal currentpeak_checked
	
			DoUpdate
			
			if(background_checked)
				Update_BackGrnd()
			endif

			if(currentpeak_checked)
				Update_CurrentPeak()
			endif
			
	
			break
		case 13: // checkbox clicked (Igor 6.2 or later)
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ButtonProc_EstimatePeaks(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			DFREF dfSav = GetDataFolderDFR()
			
			DFREF dfcal=root:Packages:AFM_Calibration:
			SetDataFolder dfcal

			NVAR fit_done
			SVAR model
			SVAR CurrentGraph
			NVAR num_peaks
			NVAR current_peak
			NVAR cant_width
			NVAR cant_length
			NVAR cant_D
			NVAR g_Option
			NVAR Medium_visc
			NVAR Medium_dens
			SVAR spectrum_type

			SVAR PSD
			wave wPSD=$(PSD)
			
			NVAR cant_kappa
			NVAR use_fitted_Coef
			NVAR fitType
			NVAR V_delta_max

			string wnCoef="PeakCoef_list"

			GetAxis/W=$(currentGraph)/Q bottom
			variable X0=V_min, X1=V_min
			if(strlen(CsrInfo(A))>0 && strlen(CsrInfo(A))>0)
				X0=min(hcsr(A, currentGraph), hcsr(B, currentGraph))
				X1=max(hcsr(A, currentGraph), hcsr(B, currentGraph))
			endif

			variable PeakPos, PeakWidth, MaxAmpl, QualityFactor

			WaveStats /M=1 /Q /R=(X0, X1)/Z wPSD
			MaxAmpl=V_max//-V_min

			variable V_fitError=0

			CurveFit/M=2/N=1/W=2/Q gauss, wPSD(X0, X1)

			if(V_fitError)
			// no peak found
			// give a rough estimate based on cursor range
				PeakPos=(X0+X1)/2
				PeakWidth=(X1-X0)/10
				QualityFactor=PeakPos/PeakWidth/4
			else
			// peak is found
				wave W_coef
				MaxAmpl=W_coef[1]
				PeakPos=W_coef[2]
				PeakWidth=abs(W_coef[3])
				QualityFactor=PeakPos/PeakWidth
				
				Tag/C/N=$("peak"+num2str(current_peak))/F=0/L=0/B=1/X=2.00/Y=1.00 $NameOfWave(wPSD), PeakPos, num2str(current_peak)
			endif

			make/O/N=2000 CurrentPeak
			wave  CurrentPeak
			SetScale/I x, X0, X1, "Hz", CurrentPeak
			string NameFitFunc=""

			// if adjusting for mode number, we need to create
			// separate waves containing fit coefficients for Gamma for each peak
			// these Gamma coefficients will be used by the fit function
			// one-time calculation of coefficients => used multiple times during fit
			// this approach avoids a fit for each point in PSD to get Gamma values
			// or interpolation for each point in PSD 
			// if no fitting of Gamma is used (i.e. direct look up from Sader's table)
			
			//	Calc_Gamma2(type, kappa, use_fitted_Coef, XL, XR, fitType, delta_max)

			// need a rough estimate of Gi
			NVAR V_Gamma_r
			NVAR V_Gamma_i

			NVAR ReNum
			ReNum=(medium_dens*2*pi*PeakPos*cant_width^2)/medium_visc
			NVAR Relog
			Relog=log(ReNum)
			variable delta=sqrt(2/ReNum)
			
///			if(g_Option==0)

				Calc_Gamma2(spectrum_type, 0, use_fitted_Coef, -4, 4, fitType, 2) 
				wave wGi_coef						
				wave wGr_coef
				
				V_Gamma_i=funcGimag(wGi_coef, delta)
				V_Gamma_r=funcGreal(wGr_coef, delta)
				Duplicate/O 	wGi_coef, wGi_coefInf					
				Duplicate/O 	wGr_coef, wGr_coefInf
				
///			else
				Calc_Gamma2(spectrum_type, cant_kappa, use_fitted_Coef, -4, 4, fitType, V_delta_max) 
				wave wGi_coef						
				wave wGr_coef
				
				V_Gamma_i=funcGimag(wGi_coef, delta)
				V_Gamma_r=funcGreal(wGr_coef, delta)
				Duplicate/O 	wGi_coef, $("wGi_coef"+num2str(current_peak))					
				Duplicate/O 	wGr_coef, $("wGr_coef"+num2str(current_peak))
///			endif				

			print "Gamma (Re, Im) = (", V_Gamma_r, ",", V_Gamma_i, ")"
			// set model type
			strswitch(model)
				case "SHO":
					NameFitFunc="SHO"
				break
				
				case "Lorentzian":
					NameFitFunc="Lorentzian"
				break
				
				case "SFO (τ→0)":
					NameFitFunc="SFO"
				break
				
				case "SFO (τ→∞)":
					NameFitFunc="SFO_pq"
				break


				case "SFO (full)":
					
					switch(g_Option)
					
						case 0:
							NameFitFunc="SFOfull_k0_v0"
						break
					
						case 1:
							NameFitFunc="SFOfull_k_v0"


						break

					endswitch							
							
				break

				case "SFO (full) vn":
					
					switch(g_Option)
					
						case 0:
							NameFitFunc="SFOfull_k0_vn"
						break
					
						case 1:
							NameFitFunc="SFOfull_k_vn"
						break

					endswitch							
							
				break

			endswitch
				
			strswitch(NameFitFunc)
				case "SHO":
				case "Lorentzian":
				case "SFO":
					make/O/N=3 $("PeakCoef"+num2str(current_peak))
					wave PeakCoef=$("PeakCoef"+num2str(current_peak))
					wave/T list= $(wnCoef+num2str(current_peak))
					// Amplitude at res freq
					list[0][1]=num2str(MaxAmpl*pi/2*PeakPos/QualityFactor)
					// Res freq (Hz)
					list[1][1]=num2str(PeakPos)
					// Q
					list[2][1]=num2str(QualityFactor)
					SetFormula PeakCoef, "str2num("+wnCoef+num2str(current_peak)+"[p][1])"
				break
				
				case "SFO_pq":
					make/O/N=5 $("PeakCoef"+num2str(current_peak))
					wave PeakCoef=$("PeakCoef"+num2str(current_peak))
					wave/T list= $(wnCoef+num2str(current_peak))
					// Amplitude at res freq
					list[0][1]=num2str(MaxAmpl*pi/2*PeakPos/QualityFactor)
					// Res freq (Hz)
					list[1][1]=num2str(PeakPos)
					// Q
					list[2][1]=num2str(QualityFactor)
					
					if(Medium_dens>500)
					
						strswitch(spectrum_type)
							
							case "normal":
								// p
								list[3][1]="0.1"
								// q
								list[4][1]="0.4"						
							break
						
							case "lateral":
								// p
								list[3][1]="0.15"
								// q
								list[4][1]="0.4"						
							break
	
						endswitch
					
					else
					
						list[3][1]="0"
						list[4][1]="0"						
					
					endif
					
					SetFormula PeakCoef, "str2num("+wnCoef+num2str(current_peak)+"[p][1])"
				break

				case "SFOfull_k0_v0":
				case "SFOfull_k_v0":
					make/O/N=5 $("PeakCoef"+num2str(current_peak))
					wave PeakCoef=$("PeakCoef"+num2str(current_peak))
					wave/T list= $(wnCoef+num2str(current_peak))
					// Amplitude at res freq
					QualityFactor=(1+Calc_mfmc()*V_Gamma_r)/(Calc_mfmc()*V_Gamma_i)

					list[0][1]=num2str(MaxAmpl*pi/2*PeakPos/QualityFactor)
					// Res freq (Hz)
					list[1][1]=num2str(PeakPos)
					// m(f)/m(c)
					list[2][1]=num2str(Calc_mfmc())
					// width (m)
					list[3][1]=num2str(cant_width)
					// mode
					list[4][1]=num2str(current_peak)
					SetFormula PeakCoef, "str2num("+wnCoef+num2str(current_peak)+"[p][1])"
				break


				case "SFOfull_k0_vn":
				case "SFOfull_k_vn":
					make/O/N=5 $("PeakCoef"+num2str(current_peak))
					wave PeakCoef=$("PeakCoef"+num2str(current_peak))
					wave/T list= $(wnCoef+num2str(current_peak))
					
					// Amplitude
					// Amplitude value at v0=vn/sqrt(1+tau*Gr) is PVn=A*2/pi*Q/v0
					// Quality factor Q=(1+tau*Gr)/tau*Gi
					QualityFactor=(1+Calc_mfmc()*V_Gamma_r)/(Calc_mfmc()*V_Gamma_i)
					
					list[0][1]=num2str(MaxAmpl*pi/2*PeakPos/QualityFactor)
					// Vacuum res freq (Hz)
					list[1][1]=num2str(PeakPos*sqrt(1+Calc_mfmc()*V_Gamma_r))
					// m(f)/m(c)
					list[2][1]=num2str(Calc_mfmc())
					// width (m)
					list[3][1]=num2str(cant_width)
					// mode
					list[4][1]=num2str(current_peak)
					SetFormula PeakCoef, "str2num("+wnCoef+num2str(current_peak)+"[p][1])"
				break

			endswitch

			// fit is done
			fit_done=1

			Update_CurrentPeak()
			
			// move to next peak because it is easy to forget to incrememnt
			if(current_peak<num_peaks)
				current_peak+=1
			endif

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
Function init_Peaks()

		DFREF dfSav = GetDataFolderDFR()
		
		DFREF dfcal=root:Packages:AFM_Calibration:
		SetDataFolder dfcal
		SVAR model_Back	
		NVAR num_peaks
		SVAR model

		Make/O/N=3/T PeakParam_Name={"Parameter", "Value", "Hold?"}

		// set up background params
		model_Back = "constant"
		string wnCoef="BkgdCoef_list"
		make/O/N=1 BkgdCoef=0
		
		make/O/N=(1,3)/T $(wnCoef)
		wave/T list= $(wnCoef)
		list[0][0]="a"
		list[0][1]="0"
		list[0][2]=""

		make/O/N=(1,3)/U $(wnCoef+"_Sel")
		wave list_Sel= $(wnCoef+"_Sel")
		list_Sel[][0]=0
		list_Sel[][1]=0x02
		list_Sel[][2]=0x20

		SetFormula BkgdCoef, "str2num(BkgdCoef_list[p][1])"

		// set up 1 over f background params
		wnCoef="BkgdCoef_1overf_list"
		make/O/N=3 BkgdCoef_1overf=0
		
		make/O/N=(3,3)/T $(wnCoef)
		wave/T list= $(wnCoef)
		list[0][0]="y0"
		list[1][0]="A"
		list[2][0]="p"
		list[0][1]="0"
		list[1][1]="0"
		list[2][1]="-1"
		list[0][2]=""

		make/O/N=(3,3)/U $(wnCoef+"_Sel")
		wave list_Sel= $(wnCoef+"_Sel")
		list_Sel[][0]=0
		list_Sel[][1]=0x02
		list_Sel[0][2]=48
		list_Sel[1][2]=0x20
		list_Sel[2][2]=48

		SetFormula BkgdCoef_1overf, "str2num(BkgdCoef_1overf_list[p][1])"

		// set up peak params
		model = "SHO"
		wnCoef="PeakCoef"
		variable i=1
		make/O/N=3 $(wnCoef+num2str(i))
		wnCoef="PeakCoef_list"
		make/O/N=(3,3)/T $(wnCoef+num2str(i))
		wave/T list= $(wnCoef+num2str(i))
		list[0][0]="A"
		list[1][0]="Res freq (Hz)"
		list[2][0]="Q"
		list[][1]=""
		list[][2]=""

		make/O/N=(3,3)/U $(wnCoef+num2str(i)+"_Sel")
		wave list_Sel=$(wnCoef+num2str(i)+"_Sel")
		list_Sel[][0]=0
		list_Sel[][1]=0x02
		list_Sel[][2]=0x20

		SetDataFolder dfSav

end 
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function PopMenuProc_ModelBack(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			FillBackParams(pa.popStr)
		break
	endswitch

	return 0
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function FillBackParams(modelBackSelect)
	string modelBackSelect

			DFREF dfSav = GetDataFolderDFR()
			
			DFREF dfcal=root:Packages:AFM_Calibration:
			SetDataFolder dfcal
			SVAR model_Back	
			NVAR num_peaks

			// for poly -- reuse coeff
			string SavModel_Back=model_Back
			wave/T BkgdCoef_list
			variable NOP_Sav=DimSize(BkgdCoef_list,0)
			variable NOP=0
			Make/O/N=(NOP_Sav)/D SavBkgdCoef
			SavBkgdCoef=str2num(BkgdCoef_list[p][1])

			model_Back = modelBackSelect
			string wnCoef="BkgdCoef_list"
			
			strswitch(model_Back)

				case "constant":
					make/O/N=1 BkgdCoef
					make/O/N=(1,3)/T $(wnCoef)
					make/O/N=(1,3)/U $(wnCoef+"_Sel")
					wave/T list= $(wnCoef)
					list[0][0]="a"
					list[][1]="0"
				break

				case "line":
					make/O/N=2 BkgdCoef
					make/O/N=(2,3)/T $(wnCoef)
					make/O/N=(2,3)/U $(wnCoef+"_Sel")
					wave/T list= $(wnCoef)
					list[0][0]="a"
					list[1][0]="b"
					list[][1]="0"
				break

				case "poly 3":
					make/O/N=3 BkgdCoef
					make/O/N=(3,3)/T $(wnCoef)
					make/O/N=(3,3)/U $(wnCoef+"_Sel")
					wave/T list= $(wnCoef)
					list[][0]="a"+num2str(p)
					list[][1]="0"
					NOP=3
				break

				case "poly 4":
					make/O/N=4 BkgdCoef
					make/O/N=(4,3)/T $(wnCoef)
					make/O/N=(4,3)/U $(wnCoef+"_Sel")
					wave/T list= $(wnCoef)
					list[][0]="a"+num2str(p)
					list[][1]="0"
					NOP=4
				break

				case "poly 5":
					make/O/N=5 BkgdCoef
					make/O/N=(5,3)/T $(wnCoef)
					make/O/N=(5,3)/U $(wnCoef+"_Sel")
					wave/T list= $(wnCoef)
					list[][0]="a"+num2str(p)
					list[][1]="0"
					NOP=5
				break

				case "poly 7":
					make/O/N=7 BkgdCoef
					make/O/N=(7,3)/T $(wnCoef)
					make/O/N=(7,3)/U $(wnCoef+"_Sel")
					wave/T list= $(wnCoef)
					list[][0]="a"+num2str(p)
					list[][1]="0"
					NOP=7
				break

				case "poly 9":
					make/O/N=9 BkgdCoef
					make/O/N=(9,3)/T $(wnCoef)
					make/O/N=(9,3)/U $(wnCoef+"_Sel")
					wave/T list= $(wnCoef)
					list[][0]="a"+num2str(p)
					list[][1]="0"
					NOP=9
				break

				case "poly 13":
					make/O/N=13 BkgdCoef
					make/O/N=(13,3)/T $(wnCoef)
					make/O/N=(13,3)/U $(wnCoef+"_Sel")
					wave/T list= $(wnCoef)
					list[][0]="a"+num2str(p)
					list[][1]="0"
					NOP=13
				break

				case "poly 19":
					make/O/N=19 BkgdCoef
					make/O/N=(19,3)/T $(wnCoef)
					make/O/N=(19,3)/U $(wnCoef+"_Sel")
					wave/T list= $(wnCoef)
					list[][0]="a"+num2str(p)
					list[][1]="0"
					NOP=19
				break

				case "lor":
					make/O/N=4 BkgdCoef
					make/O/N=(4,3)/T $(wnCoef)
					make/O/N=(4,3)/U $(wnCoef+"_Sel")
					wave/T list= $(wnCoef)
					list[0][0]="y0"
					list[1][0]="A"
					list[2][0]="x0"
					list[3][0]="B"
					list[0][1]="5e-12"
					list[1][1]="10"
					list[2][1]="-5e4"
					list[3][1]="5e11"
				break

				case "exp":
					make/O/N=3 BkgdCoef
					make/O/N=(3,3)/T $(wnCoef)
					make/O/N=(3,3)/U $(wnCoef+"_Sel")
					wave/T list= $(wnCoef)
					list[0][0]="y0"
					list[1][0]="A"
					list[2][0]="invTau"
					list[0][1]="0"
					list[1][1]="1e-11"
					list[2][1]="1e-6"
				break

				case "power":
					make/O/N=3 BkgdCoef
					make/O/N=(3,3)/T $(wnCoef)
					make/O/N=(3,3)/U $(wnCoef+"_Sel")
					wave/T list= $(wnCoef)
					list[0][0]="y0"
					list[1][0]="A"
					list[2][0]="power"
					list[0][1]="1e-11"
					list[1][1]="-1e-14"
					list[2][1]="0.5"
				break

			endswitch

			// reuse coef if both models are poly
			if(strsearch(model_Back, "poly",0)>=0 && strsearch(SavModel_Back, "poly",0)>=0)
				//list[][1]=SelectString(p<NOP_Sav,"0",num2str(SavBkgdCoef[p]))
				//BkgdCoef= p<=NOP_Sav ? SavBkgdCoef[p] : 0
				//BkgdCoef_list[][1]=num2str(BkgdCoef[p])
				variable i
				for(i=0;i<min(NOP_Sav,NOP);i+=1)
					BkgdCoef_list[i][1]=num2str(SavBkgdCoef[i])
				endfor
			endif

			wave BkgdCoef
			SetFormula BkgdCoef, "str2num(BkgdCoef_list[p][1])"

			list[][2]=""

			wave list_Sel= $(wnCoef+"_Sel")
			list_Sel[][0]=0
			list_Sel[][1]=0x02
			list_Sel[][2]=0x20

			SetDataFolder dfSav

			string S_popmenu="\"constant;line;poly 3;poly 4;poly 5;poly 7;poly 9;poly 13;poly 19;lor;power;exp;\""
			S_popmenu=ReplaceString(modelBackSelect, S_popmenu, "\\M0: !*:"+modelBackSelect,1,1)
			variable V_mode=Get_N_popmenu(model_Back, "popup_back_tab1", "Panel_Cal")
			PopupMenu popup_back_tab1,value= #S_popmenu,popvalue=model_Back,mode=V_mode

End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function CheckProc_CheckInclude1overf(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked

			Update_BackGrnd()
			Update_CurrentPeak()

			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ButtonProc_EstimateBack(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here


			DFREF dfSav = GetDataFolderDFR()
	
			DFREF dfcal=root:Packages:AFM_Calibration:
			SetDataFolder dfcal
			
			NVAR fit_done
			SVAR model
			SVAR model_Back
			SVAR PSD
			SVAR CurrentGraph
			NVAR use_1overf
			NVAR num_peaks
			NVAR current_peak
			NVAR V_BackScale
			
			String FittingFuncBack=""
			
			DoWindow/F $CurrentGraph

			if(V_flag==0)
				SetDataFolder dfSav
				Abort "Graph not displayed." 
				return 1
			endif

			wave wPSD=$PSD

			variable X0, X1

			if(strlen(CsrInfo(A)) > 0 && strlen(CsrInfo(B)) > 0 )
				X0=min(hcsr(A, CurrentGraph),hcsr(B, CurrentGraph))
				X1=max(hcsr(A, CurrentGraph),hcsr(B, CurrentGraph))
			else
				X0=leftx(wPSD)
				X1=rightx(wPSD)				
			endif
			
			X0=GetExactX(wPSD, X0)
			X1=GetExactX(wPSD, X1)

			wave/T  list=BkgdCoef_list
			Make/O/N=(DimSize(list,0))/D BkgdCoef
			wave BkgdCoef
			BkgdCoef=str2num(list[p][1])

			// Save coef to reverse fit results in the next step if chosen
			NewDataFolder/O SavCoef			
			DFREF dfSavCoef=root:Packages:AFM_Calibration:SavCoef:
			Duplicate/O BkgdCoef, dfSavCoef:BkgdCoef

			wave list_sel= BkgdCoef_list_Sel
			
			variable j
			string hold=""
			
			for(j=0;j<DimSize(list_sel,0);j+=1)
				hold+=num2str((list_sel[j][2]-32)/16)
			endfor

			FittingFuncBack=model_Back
			
			// needed to fix up coefficient wave for line fit used to fit a constant
			strswitch(model_Back)
				case "constant":
					FittingFuncBack="line"
					Redimension/N=2 BkgdCoef
					Redimension/N=(2,-1) list
					REdimension/N=(2,-1) list_sel
					BkgdCoef[1]=0
					hold[1]="1"
				break
				
			endswitch

			string SumOfFunctions="{"+FittingFuncBack+", BkgdCoef, hold=\""+hold+"\"}"

			// add 1 over f noise fit if selected
			wave/T  list_1f=BkgdCoef_1overf_list
			Make/O/N=(DimSize(list_1f,0))/D BkgdCoef_1overf
			wave BkgdCoef_1overf
			BkgdCoef_1overf=str2num(list_1f[p][1])

			// Save coef to reverse fit results in the next step if chosen
			Duplicate/O BkgdCoef_1overf, dfSavCoef:BkgdCoef_1overf

			if(use_1overf==1)

				wave list_sel_1f= BkgdCoef_1overf_list_Sel
				
				hold=""
				for(j=0;j<DimSize(list_sel_1f,0);j+=1)
					hold+=num2str((list_sel_1f[j][2]-32)/16)
				endfor
			
				SumOfFunctions+="{power, BkgdCoef_1overf, hold=\""+hold+"\"}"
				
			endif

			// need to set background wave coef to zero when calculating peaks
			// Update_currentPeak() will add background by default
			Duplicate/O BkgdCoef, wSav_BkgdCoef
			BkgdCoef=0
			
			Duplicate/O/R=(1.001*X0,0.999*X1) wPSD, wPSDBackOnly
			
			variable Sav_current_peak=current_peak
			variable error=0

			for(current_peak=1;current_peak<=num_peaks;current_peak+=1)
				error=Update_CurrentPeak()
				wave/Z CurrentPeak
				if(WaveExists(CurrentPeak)==1 && error==0)
					wPSDBackOnly-=CurrentPeak(x)
				endif
			endfor
			
			BkgdCoef=wSav_BkgdCoef

			print SumOfFunctions

			DoWindow/F $CurrentGraph
			
			FuncFit /W=2 /Q {string = SumOfFunctions} wPSDBackOnly
			
			// fit is done
			fit_done=1

			// needed to fix up coefficient wave for line fit used to fit a constant
			strswitch(model_Back)
				case "constant":
					Redimension/N=1 BkgdCoef		
					Redimension/N=(1,-1) list
					REdimension/N=(1,-1) list_sel
				break
				
			endswitch

			list[][1]=num2str(BkgdCoef[p])
			SetFormula BkgdCoef, "str2num(BkgdCoef_list[p][1])"
	
			list_1f[][1]=num2str(BkgdCoef_1overf[p])
			SetFormula BkgdCoef_1overf, "str2num(BkgdCoef_1overf_list[p][1])"

//			wave Fit=$("fit_"+NameOfWave(wPSD))
			variable NOP=(X1-X0)/deltax(wPSD)+1
			Make/O/N=(NOP) $("Back_"+NameOfWave(wPSD))
			wave back=$("Back_"+NameOfWave(wPSD))
			SetScale/I x, X0, X1, back
			
			Make_Bkgd(model_Back, BkgdCoef, back, BkgdCoef_1overf, use_1overf, V_BackScale)

			// Appends the background -- we need to check the "show back" box
			NVAR background_checked
			background_checked=1
			
			CheckDisplayed/W=$CurrentGraph wPSD, Back
		
			if(V_flag==1)
				AppendToGraph/W=$CurrentGraph Back
				ModifyGraph lsize($NameOfWave(back))=2,rgb($NameOfWave(back))=(0,0,0)
			endif

			current_peak=Sav_current_peak
			Update_CurrentPeak()
						
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ButtonProc_RevertPeaks(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			Load_SavedCoef()
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function GetExactX(w,x)
	wave w
	variable x
	
	variable p=x2pnt(w, x)
	x=pnt2x(w, p)
	
	return x

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Calc_ResFreq_once(wGr_coef, tau, fvac, f0, dens, visc, cant_width)
	wave wGr_coef
	variable tau, fvac, f0, dens, visc, cant_width
	
	variable ReNum=2*pi*f0*dens*cant_width^2/visc
	variable delta=sqrt(2/ReNum)

	variable Gr=funcGreal(wGr_coef, delta)
	
	f0=fvac/sqrt((1+tau*Gr))
	
	return f0
	

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
// iterate calculation of resonant frequency f0 from tau(f0) and vacuum resonant frequency
// tau depends on f0 
Function Calc_ResFreq(wGr_coef, tau, fvac, f0, dens, visc, cant_width)
	wave wGr_coef
	variable tau, fvac, f0, dens, visc, cant_width
	
	variable i=0
	
	for(i=0;i<8;i+=1)
		f0=Calc_ResFreq_once(wGr_coef, tau, fvac, f0, dens, visc, cant_width)
	endfor
	
	return f0
	

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function SetVarProc_SwitchPeak(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable peak = sva.dval
			
			DFREF dfcal=root:Packages:AFM_Calibration:
			NVAR/SDFR=dfcal num_peaks
			NVAR/SDFR=dfcal current_peak
			if(peak>num_peaks)
				current_peak=num_peaks
				peak=num_peaks
			endif

			string wnCoef="PeakCoef_list"+num2str(peak)
			ListBox Peak_params_tab1,listWave=root:Packages:AFM_Calibration:$(wnCoef), win=Panel_Cal
			ListBox Peak_params_tab1,selWave=root:Packages:AFM_Calibration:$(wnCoef+"_Sel"), win=Panel_Cal
			ListBox Peak_params_tab1, titleWave=root:Packages:AFM_Calibration:PeakParam_Name, win=Panel_Cal

			Update_CurrentPeak()
			Update_Sens()
		break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function SetVarProc_MakePeakWaves(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	DFREF dfSav = GetDataFolderDFR()
	
	DFREF dfcal=root:Packages:AFM_Calibration:
	SetDataFolder dfcal
	SVAR model
	NVAR current_peak
	NVAR num_peaks
	NVAR num_peaksSav
	NVAR fit_done

	variable i

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			string wnCoef="PeakCoef_list"
			SetVariable Current_peaks_tab1 limits={1,num_peaks,1}, win=Panel_Cal
			SetVariable mode_tab2 limits={1,num_peaks,1}, win=Panel_Cal
			
			// number of peaks did not change
			if(num_peaks==num_peaksSav)
				break
			endif
			
			// number of peaks decreased
			// make sure current peak is not out of range
			if(num_peaks<num_peaksSav)
			
				i=num_peaksSav
				for(i=num_peaksSav;i>num_peaks;i-=1)
					Tag/K/N=$("peak"+num2str(i))
					// Kill waves for unused peaks
					wave/Z Coef=$("PeakCoef"+num2str(i))
					wave/Z Coef_Sel=$(wnCoef+num2str(i)+"_Sel")
					wave/T/Z list= $(wnCoef+num2str(i))
					KillWaves/Z Coef, Coef_Sel
					KillWaves/Z list
				endfor 

				num_peaksSav=num_peaks

				if(current_peak>num_peaks)
					current_peak=num_peaks
					wave Coef=$("PeakCoef"+num2str(current_peak))
					wave/T list= $(wnCoef+num2str(current_peak))
					if(numtype(Coef[0])==0)
						list[][1]=num2str(Coef[p])
					else
						list[][1]=""
					endif
					
					ListBox Peak_params_tab1,listWave=root:Packages:AFM_Calibration:$(wnCoef+num2str(current_peak)), win=Panel_Cal
					ListBox Peak_params_tab1,selWave=root:Packages:AFM_Calibration:$(wnCoef+num2str(current_peak)+"_Sel"), win=Panel_Cal
					
					Update_CurrentPeak()
				endif
										
				break
			endif


			// number of peaks increased
			// make more coeff waves
			i=1
			for(i=num_peaksSav+1;i<num_peaks+1;i+=1)
				strswitch(model)
					case "SHO":
					case "Lorentzian":
					case "SFO (τ→0)":
						make/O/N=3 $("PeakCoef"+num2str(i))
						make/O/N=(3,3)/T $(wnCoef+num2str(i))
						make/O/N=(3,3)/U $(wnCoef+num2str(i)+"_Sel")
						wave/T list= $(wnCoef+num2str(i))
						list[0][0]="Apml(res freq)"
						list[1][0]="Res freq (Hz)"
						list[2][0]="Q"
	
						list[][1]=""

						wave list_Sel= $(wnCoef+num2str(i)+"_Sel")
						list_Sel[][0]=0
						list_Sel[][1]=0x02
						list_Sel[][2]=0x20

					break
									
					case "SFO (τ→∞)":
						make/O/N=5 $("PeakCoef"+num2str(i))
						make/O/N=(5,3)/T $(wnCoef+num2str(i))
						make/O/N=(5,3)/U $(wnCoef+num2str(i)+"_Sel")
						wave/T list= $(wnCoef+num2str(i))
						list[0][0]="Apml(res freq)"
						list[1][0]="Res freq (Hz)"
						list[2][0]="Q"
						list[3][0]="p"
						list[4][0]="q"

	
						list[][1]=""
						list[3][1]="0"
						list[4][1]="0"

						wave list_Sel= $(wnCoef+num2str(i)+"_Sel")
						list_Sel[][0]=0
						list_Sel[][1]=0x02
						list_Sel[][2]=0x20
						list_Sel[4][2]=0x20+0x10
						list_Sel[3][2]=0x20+0x10
					break
	
						case "SFO (full)":
						make/O/N=5 $("PeakCoef"+num2str(i))
						make/O/N=(5,3)/T $(wnCoef+num2str(i))
						make/O/N=(5,3)/U $(wnCoef+num2str(i)+"_Sel")
						wave/T list= $(wnCoef+num2str(i))
						list[0][0]="Apml(res freq)"
						list[1][0]="Res freq (Hz)"
						list[2][0]="m(f)/m(c)"
						list[3][0]="width (m)"
						list[4][0]="mode"
	
						list[][1]=""
						list[4][1]=num2str(i)

						wave list_Sel=$(wnCoef+num2str(i)+"_Sel")
						list_Sel[][0]=0
						list_Sel[][1]=0x02
						list_Sel[][2]=0x20
						list_Sel[4][2]=0x20+0x10
						list_Sel[3][2]=0x20+0x10
						//list_Sel[1][2]=0x20+0x10
					break

					case "SFO (full) vn":
						make/O/N=5 $("PeakCoef"+num2str(i))
						make/O/N=(5,3)/T $(wnCoef+num2str(i))
						make/O/N=(5,3)/U $(wnCoef+num2str(i)+"_Sel")
						wave/T list= $(wnCoef+num2str(i))
						list[0][0]="Apml"
						list[1][0]="Vac freq (Hz)"
						list[2][0]="m(f)/m(c)"
						list[3][0]="width (m)"
						list[4][0]="mode"

						wave list_Sel=$(wnCoef+num2str(i)+"_Sel")
						list_Sel[][0]=0
						list_Sel[][1]=0x02
						list_Sel[][2]=0x20
						list_Sel[4][2]=0x20+0x10
						list_Sel[3][2]=0x20+0x10
						//list_Sel[1][2]=0x20+0x10
	
						list[][1]=""
						list[4][1]=num2str(i)
						
						fit_done=0

					break


				endswitch
				
				// clear "value" and "hold" columns

				//list[][1]=""
				list[][2]=""
				
				wave Coef=$("PeakCoef"+num2str(i))
				SetFormula Coef, "str2num("+wnCoef+num2str(i)+"[p][1])"

			endfor
			
			current_peak=i-1

			num_peaksSav=num_peaks
			
			ListBox Peak_params_tab1,listWave=root:Packages:AFM_Calibration:$(wnCoef+num2str(current_peak)), win=Panel_Cal
			ListBox Peak_params_tab1,selWave=root:Packages:AFM_Calibration:$(wnCoef+num2str(current_peak)+"_Sel"), win=Panel_Cal

			break
	endswitch

	SetDataFolder dfSav

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function CheckProc_SelectGlobalFitParam(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			
			string ctrlName=cba.ctrlName
			
			DFREF dfcal=root:Packages:AFM_Calibration:
			NVAR/SDFR=dfcal globaltau
			NVAR/SDFR=dfcal globalwidth
			NVAR/SDFR=dfcal globalpq
			
			strswitch(ctrlName)
			
				case "globaltau_tab1":
				case "globalwidth_tab1":
				
					if(checked)
						globalpq=0
					endif
				
				break			
			
				case "globalpq_tab1":
				
					if(checked)
						globaltau=0
						globalwidth=0
					endif
					
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
Function ButtonProc_CalcSens(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			Update_Sens()
		
		break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ButtonProc_CalculateSpringConst(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			Update_SpringConst()

		break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑

// UPDATE FUNCTIONS

//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Update_SpringConst()

	DFREF dfcal=root:Packages:AFM_Calibration:
	SVAR/SDFR=dfcal model

	STRUCT SpringConst k
	StructFill /SDFR=dfcal k 

	Calc_k_theory()
	Calc_k_thermal()
	//Calc_k_Sader()
	
	strswitch(model)
		case "SHO":
		case "Lorentzian":
		case "SFO (τ→0)":
		case "SFO (τ→∞)":
			Calc_k_Sader()
			k.kz_FluidStruc=NaN
			k.ky_FluidStruc=NaN
			k.kTheta_FluidStruc=NaN
		break
		
		case "SFO (full)":
		case "SFO (full) vn":
			Calc_k_FluidStruc()
			k.kz_Sader=NaN
			k.ky_Sader=NaN
			k.kTheta_Sader=NaN
		break
	endswitch
	
	Calc_Error_k()

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Update_Sens()
			
	DFREF dfcal=root:Packages:AFM_Calibration:

	SVAR k_type=dfcal:k_type
	SVAR Spectrum_type=dfcal:Spectrum_type
	SVAR model=dfcal:model
	NVAR current_peak=dfcal:current_peak
	NVAR Medium_temperature=dfcal:Medium_temperature
	
	STRUCT cantilever cant
	StructFill /SDFR=dfcal cant 

	STRUCT Sens S
	StructFill /SDFR=dfcal S 

	STRUCT SpringConst k
	StructFill /SDFR=dfcal k 

	STRUCT Tip tip
	StructFill /SDFR=dfcal tip

	NVAR check_SFcont_use_kthermal=dfcal:check_SFcont_use_kthermal
	
	string ZorY=""
	
	strswitch(Spectrum_type)
		case "normal":
			ZorY="z"
		break
		
		case "lateral":
			ZorY="Theta"
		break
	endswitch


	strswitch(k_type)
	
		case "theory":
			NVAR spring=dfcal:$("k"+ZorY+"_theory")
		break
		
		case "thermal":
			NVAR spring=dfcal:$("k"+ZorY+"_thermal")
		break

		case "Sader":
			NVAR spring=dfcal:$("k"+ZorY+"_Sader")
		break
		
		case "FluidStruc":
			NVAR spring=dfcal:$("k"+ZorY+"_FluidStruc")
		break

	endswitch
	
	wave/SDFR=dfcal Coef=$("PeakCoef"+num2str(current_peak))

	variable peakArea=Calc_peakArea(model, Coef)

	variable kc=spring
	variable ktheta=spring
	variable cosa=cos(cant.cant_inclination/180*pi)
	variable chi_N=1-tip.htip/cant.xtip*tan(cant.cant_inclination/180*pi)
	variable w_dwdx=(3*chi_N-1)/3*cant.xtip*cant.xtip/cant.xlaser/(2*chi_N-cant.xlaser/cant.xtip)

	strswitch(Spectrum_type)
		case "normal":
		
			// Contact sensitivity Sz_cont must be provided
			// spring can be k(z,s) of any flavor: theory, thermal, Sader, or SFO
			// S.Sz_cont is experimental sens SN (i.e. due to smapel z displacment) Sz=SN*cos(alpha)
			if(check_SFcont_use_kthermal)
				S.SFz_cont=S.Sz_cont*cosa/k.kz_thermal
			else
				S.SFz_cont=S.Sz_cont*cosa/spring
			endif
			
			S.Sslopez_cont=S.Sz_cont*cosa
			S.Sslopez_cont*=w_dwdx*cant.cant_length
			
			// convert from  static spring const ks to kc
			kc*=(cant.xtip)^3

			S.Sz_noncont=sqrt(kc/3*C_n_m_I(current_peak, cant.mend2mc,cant.Iend2Ic)^4*peakArea/(kBoltz*Medium_temperature))
			S.Sz_noncont*=1/S.Sz_CorrectionFactor

			S.SFz_noncont=S.Sz_noncont/spring

			S.Sslopez_noncont=S.Sz_noncont
			S.Sslopez_noncont*=w_dwdx*cant.cant_length

			// S.Sz_noncont is actual Sz=SN*cos(alpha)
			// store sample sens SN
			S.Sz_noncont/=cosa
			
		break
		
		case "lateral":

			variable h=tip.tip_H_e*sqrt(1+tip.ytip^2)
			
			// Contact sensitivity Sy_cont must be provided
			// spring can be k(theta,s) of any flavor: theory, thermal, Sader, or SFO
			if(check_SFcont_use_kthermal)
				S.SFy_cont=S.Sy_cont/k.ky_thermal
			else
				S.SFy_cont=S.Sy_cont/(spring/h^2)
			endif

			S.Sslopey_cont=S.Sy_cont*h*cant.xtip/cant.xlaser

			// convert from  static spring const (i.e. ktheta,s) to ktheta
			ktheta*=cant.xtip

			S.Sslopey_noncont=sqrt(ktheta*D_n_m(current_peak, cant.Iend2Ic)^2*peakArea/(kBoltz*Medium_temperature))
			S.Sslopey_noncont*=1/S.Sy_CorrectionFactor

			S.SFy_noncont=S.Sslopey_noncont*h/ktheta*cant.xlaser

			S.Sy_noncont=S.Sslopey_noncont/h*cant.xlaser/cant.xtip
			
		break
	endswitch

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Update_BackGrnd()

	DFREF dfcal=root:Packages:AFM_Calibration:
	
	NVAR/SDFR=dfcal fit_done
	if(fit_done==0)
		return 1
	endif
	
	SVAR/SDFR=dfcal PSD
	wave/SDFR=dfcal/Z wPSD=$PSD
	
	SVAR/SDFR=dfcal model_Back
	wave/SDFR=dfcal/Z BkgdCoef
	wave/SDFR=dfcal/Z back=$("Back_"+NameOfWave(wPSD))
	wave/SDFR=dfcal/Z BkgdCoef_1overf
	NVAR/SDFR=dfcal/Z use_1overf
	NVAR/SDFR=dfcal V_BackScale
	NVAR/SDFR=dfcal use_ScaleBack

	if(use_ScaleBack)
		Make_Bkgd(model_Back, BkgdCoef, back, BkgdCoef_1overf, use_1overf, V_BackScale)
	else
		Make_Bkgd(model_Back, BkgdCoef, back, BkgdCoef_1overf, use_1overf, 1)
	endif

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Update_CurrentPeak()
	DFREF dfSav = GetDataFolderDFR()
	
	DFREF dfcal=root:Packages:AFM_Calibration:
	SetDataFolder dfcal
	
	NVAR/SDFR=dfcal fit_done
	if(fit_done==0)
		return 1
	endif

	STRUCT cantilever cant
	StructFill /SDFR=dfcal cant 

	STRUCT Sens S
	StructFill /SDFR=dfcal S 

	STRUCT SpringConst k
	
	StructFill /SDFR=dfcal k 

	SVAR model
	SVAR CurrentGraph
	SVAR PSD
	NVAR current_peak
	
	SVAR Spectrum_type

	NVAR dens=medium_dens
	NVAR visc=medium_visc
	NVAR g_Option
	
	NVAR ReNum
	NVAR Relog
	
	NVAR V_Gamma_r
	NVAR V_Gamma_i
	
	NVAR Detect_MTF
	
	NVAR htip

//	Calc_Sz_CorrectionFactor(n, xtip, xlaser, mend2mc, htip, inclAngle)
	S.Sz_CorrectionFactor=Calc_Sz_CorrectionFactor2(Current_peak, cant.xtip, cant.xlaser, cant.mend2mc, cant.Iend2Ic, htip, cant.cant_inclination)
	S.Sy_CorrectionFactor=Calc_Sy_CorrectionFactor(Current_peak, cant.xlaser, cant.Iend2Ic)

	WAVE/Z CurrentPeak
	if(WaveExists(CurrentPeak)==0)
		SetDataFolder dfSav
		return 1
	endif
							
	wave wPSD=$PSD
	wave/SDFR=dfcal Coef=$("PeakCoef"+num2str(current_peak))
	wave/SDFR=dfcal/Z Back=$("Back_"+NameOfWave(wPSD))
	
	WaveStats/Q Coef
	if(V_numNaNs>0)
		SetDataFolder dfSav
		return 1
	endif

	variable t0=ticks
	
	variable X0=leftx(wPSD), X1=rightx(wPSD)

	DoWindow/F $CurrentGraph
	if(V_flag==1)
	
		if(strlen(CsrInfo(A)) > 0 && strlen(CsrInfo(B)) > 0 )
			X0=min(hcsr(A, CurrentGraph),hcsr(B, CurrentGraph))
			X1=max(hcsr(A, CurrentGraph),hcsr(B, CurrentGraph))
		else
			X0=leftx(wPSD)
			X1=rightx(wPSD)				
		endif


		X0=GetExactX(wPSD, X0)
		X1=GetExactX(wPSD, X1)
	
	endif

	variable NOP=abs(X1-X0)/deltax(wPSD)+1
	Redimension/N=(NOP) CurrentPeak
	SetScale/P x, min(X0, X1), deltax(wPSD), "Hz", CurrentPeak

	// populate width and mode values for fit coef if not present
	variable width=cant.cant_width
	variable mode=current_peak

	if(strsearch(model, "SFO (full)",0)>=0)
		if(numtype(Coef[3])==0)
			width=Coef[3]
		else
			Coef[3]=width
		endif

		if(numtype(Coef[4])==0)
			mode=Coef[4]
		else
			Coef[4]=mode
		endif

	endif

	// update globals for gamma
	strswitch(Spectrum_type)
	
		case "normal":
			cant.cant_kappa=C_n_m_I(mode,cant.mend2mc,cant.Iend2Ic)*width/cant.cant_length_e
		break
	
		case "lateral":
			cant.cant_kappa=D_n_m(mode,cant.Iend2Ic)*width/cant.cant_length_e
		break

	endswitch

	NVAR ReNum
	NVAR Relog

	variable delta
	
	// if normalized mode is assumed zero (infinitely long beam)
	// only one set of coefficients is needed
	// it was calculated for kappa=0
	switch(g_Option)
	
		case 0:
	
			wave/SDFR=dfcal wGr_coef=wGr_coefInf
			wave/SDFR=dfcal wGi_coef=wGi_coefInf
			
		break
		
		case 1:
		
			wave/SDFR=dfcal wGr_coef=$("wGr_coef"+num2str(current_peak))
			wave/SDFR=dfcal wGi_coef=$("wGi_coef"+num2str(current_peak))

		break
		
	endswitch

	// calculate delta for all models
	// adjust it for "SFO (full) vn"
	// because we don't know the resonant frequency
	ReNum=2*pi*Coef[1]*dens*cant.cant_width^2/visc
	Relog=log(ReNum)
	delta=sqrt(2/ReNum)
	
	strswitch(model)
	
		case "SHO":
			CurrentPeak=SHO(Coef,x)
		break							
	
		case "Lorentzian":
			CurrentPeak=Lorentzian(Coef,x)
		break
	
		case "SFO (τ→0)":
			CurrentPeak=SFO(Coef,x)
		break							

		case "SFO (τ→∞)":
			CurrentPeak=SFO_pq(Coef,x)
		break							

		case "SFO (full)":

			switch(g_Option)
			
				case 0:

					CurrentPeak=SFOfull_k0_v0(Coef,x)
					
				break
				
				case 1:
					
					CurrentPeak=SFOfull_k_v0(Coef,x)

				break
				
			endswitch
			
		break

		case "SFO (full) vn":
			
			variable f=Calc_ResFreq(wGr_coef, Coef[2], Coef[1], Coef[1], dens, visc, cant.cant_width)

			ReNum=2*pi*f*dens*cant.cant_width^2/visc
			Relog=log(ReNum)
			delta=sqrt(2/ReNum)
	
			switch(g_Option)
			
				case 0:

					CurrentPeak=SFOfull_k0_vn(Coef,x)

				break
					
				case 1:
					
					CurrentPeak=SFOfull_k_vn(Coef,x)

				break
				
			endswitch
			
		break

	endswitch
	
//	wave wDelta
//	wave wGreal
//	wave wGimag
//
//	wGreal=funcGreal(wGr_coef, wDelta)
//	wGimag=funcGimag(wGi_coef, wDelta)
	
	V_Gamma_r=funcGreal(wGr_coef, delta)
	V_Gamma_i=funcGimag(wGi_coef, delta)

	// see if backbground was fitted
	if(WaveExists(Back))
	
		SVAR model_Back
		wave/Z BkgdCoef
		wave/Z BkgdCoef_1overf
		NVAR use_1overf
		NVAR V_BackScale
		NVAR use_ScaleBack
	
		Duplicate/O CurrentPeak, PeakBack
		wave PeakBack
		if(use_ScaleBack)
			Make_Bkgd(model_Back, BkgdCoef, PeakBack, BkgdCoef_1overf, use_1overf, V_BackScale)
		else
			Make_Bkgd(model_Back, BkgdCoef, PeakBack, BkgdCoef_1overf, use_1overf, 1)
		endif
		
		CurrentPeak+=PeakBack(x)
		KillWaves/Z PeakBack

		// evaluate MTF of the detector
		if(WaveExists(BkgdCoef))
			make/O/N=10000 backAdj
			SetScale/I x, 0, 2.5e6, backAdj
			Make_Bkgd(model_Back, BkgdCoef, backAdj, BkgdCoef_1overf, 0, V_BackScale)
			if(numtype(Coef[1])==0)
				Detect_MTF=backAdj(Coef[1])/backAdj(0)
			endif
			KillWaves/Z backAdj
		endif

	endif

	Update_SpringConst()
	Update_Sens()
	
	SetDataFolder dfSav

	return 0

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑

Function Update_WidthFit(width)
	variable width

	Update_FitParam("width", width)

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


Function Update_FitParam(S_ParamName, param_Value)
	string S_ParamName
	variable param_Value

	DFREF dfcal=root:Packages:AFM_Calibration:
	NVAR/SDFR=dfcal current_peak
	NVAR/SDFR=dfcal num_peaks
	SVAR/SDFR=dfcal model
	
	wave/SDFR=dfcal/T list= $("PeakCoef_list"+num2str(current_peak))
	string S_param_Value
	variable param_Index
	variable i

	strswitch(S_ParamName)
	
		case "τ (or η)":
			if(strsearch(model, "SFO (full)", 0)<0)
				break
			endif
			param_Index=2
		break
		
		case "width":
			if(strsearch(model, "SFO (full)", 0)<0)
				break
			endif
			param_Index=3
		break
		
	
		case "p":
			if(strsearch(model, "τ→∞", 0)<0)
				break
			endif
			param_Index=3
		break

		case "q":
			if(strsearch(model, "τ→∞", 0)<0)
				break
			endif
			param_Index=4
		break
		
		default:
			return 0
		break

	endswitch

	if(param_Value<0)
		S_param_Value=list[param_Index][1]
	else
		S_param_Value=num2str(param_Value)
	endif
	
	for(i=1;i<num_peaks+1;i+=1)
		wave/SDFR=dfcal/T list=$("PeakCoef_list"+num2str(i))
		list[param_Index][1]=S_param_Value
	endfor 

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑

// END OF UPDATE FUNCTIONS


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function PopMenuProc_SelectGraph(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			DFREF dfcal=root:Packages:AFM_Calibration:
			SVAR CurrentGraph=dfcal:CurrentGraph
			CurrentGraph=popStr
			SVAR listPSD=dfcal:listPSD
			
			listPSD=TraceNameList(currentGraph, ";",1)
			PopupMenu PSD_tab1, win=Panel_Cal, value=#"root:Packages:AFM_Calibration:listPSD"
				
			string S_popmenu=WinList("*", ";", "WIN:1")
			S_popmenu="\""+ReplaceString(CurrentGraph, S_popmenu, "\\M0: !*:"+CurrentGraph,1,1)+"\""
			PopupMenu $pa.ctrlName,value= #S_popmenu

			DoWindow/F/Z $CurrentGraph
			ModifyGraph/W=$CurrentGraph/Z log=1,mirror=2
			SetAxis bottom 20,*
			Label left "PSD (V\\S2\\M/Hz)"
			Label bottom "Frequency"
			
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function PopMenuProc_SelectPSD(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			DFREF dfcal=root:Packages:AFM_Calibration:
			SVAR CurrentGraph=dfcal:CurrentGraph
			SVAR listPSD=dfcal:listPSD
			SVAR PSD=dfcal:PSD

			wave/Z trace=TraceNameToWaveRef(CurrentGraph, popStr)
			PSD=GetWavesDataFolder(trace,2)
			string PSDname=NameOfWave($PSD)
			
			string S_popmenu=listPSD
			S_popmenu="\""+ReplaceString(PSDname, S_popmenu, "\\M0: !*:"+PSDname,1,1)+"\""
			PopupMenu $pa.ctrlName,value= #S_popmenu

			NVAR cursors_checked=dfcal:cursors_checked

			if(cursors_checked)
				Cursor_Add2Plot()
			else
				Cursor/K A
				Cursor/K B
			endif
			
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function/S Get_S_popmenu(popStr, ctrlName, win)
	string popStr, ctrlName, win

	ControlInfo/W=$win $ctrlName
	string S_popmenu=StringByKey("value",S_recreation,"= #",",")
	S_popmenu=ReplaceString("\"", S_popmenu, "")
	S_popmenu=ReplaceString("\r", S_popmenu, "")
	S_popmenu=ReplaceString("\\M0: !*:", S_popmenu, "")
	S_popmenu=ReplaceString("\\", S_popmenu, "")
	S_popmenu="\""+ReplaceString(popStr, S_popmenu, "\\M0: !*:"+popStr,1,1)+"\""
	
	return S_popmenu

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Get_N_popmenu(popStr, ctrlName, win)
	string popStr, ctrlName, win

	ControlInfo/W=$win $ctrlName
	string S_popmenu=StringByKey("value",S_recreation,"= #",",")
	S_popmenu=ReplaceString("\"", S_popmenu, "")
	S_popmenu=ReplaceString("\r", S_popmenu, "")
	S_popmenu=ReplaceString("\\M0: !*:", S_popmenu, "")
	S_popmenu=ReplaceString("\\", S_popmenu, "")

	variable V_mode=WhichListItem(popStr,S_popmenu)+1
	
	return V_mode

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function PopMenuProc_SelectMedium(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			
			DFREF dfcal=root:Packages:AFM_Calibration:
			SVAR medium=dfcal:medium
			
			medium=popStr
			
			string S_popmenu=Get_S_popmenu(popStr, pa.ctrlName, pa.win)
			PopupMenu $pa.ctrlName,value= #S_popmenu, mode=1, popvalue=medium

			SetDensity()
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function SetVarProc_SetTemp(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval

			SetDensity()

			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function SetDensity()

	DFREF dfcal=root:Packages:AFM_Calibration:

	SVAR List_visc=root:packages:SolventData:S_Name_Visc
	SVAR List_dens=root:packages:SolventData:S_Name_Dens

	NVAR Medium_temperature=dfcal:Medium_temperature			
	SVAR medium=dfcal:medium
	NVAR Medium_visc=dfcal:Medium_visc
	NVAR Medium_dens=dfcal:Medium_dens
	NVAR p_atm=dfcal:p_atm
	NVAR RH=dfcal:RH
	NVAR FracMassComp1=dfcal:FracMassComp1
	
	string NameMix
	variable DataMixture=0

	strswitch(medium)
	
		case "air":
			
			Medium_dens=DensityAir(Medium_temperature, p_atm, RH)
			Medium_visc=ViscAir(Medium_temperature,p_atm)
			
		break
	
	
		case "water":
			
			Medium_dens=DensityWater(Medium_temperature)
			Medium_visc=ViscWater3(Medium_temperature)
			
		break
		
		case "water-EG":
			
			NameMix="H2OEG"
			DataMixture=1
					
		break

		case "water-EtOH":
			
			NameMix="H2OEtOH"
			DataMixture=1
			
		break

		case "water-MeOH":
			
			NameMix="H2OMeOH"
			DataMixture=1
			
		break

		case "MeOH-water":
			
			NameMix="MeOHH2O"
			DataMixture=1
			
		break

		case "EtOH-water":
			
			NameMix="EtOHH2O"
			DataMixture=1
			
		break

		case "MeOH-EtOH":
			
			NameMix="MeOHEtOH"
			DataMixture=1
			
		break

		case "EtEG-water":
			
			NameMix="EtEGH2O"
			DataMixture=1
			
		break

		case "diEG-water":
			
			NameMix="diEGH2O"
			DataMixture=1
			
		break


		case "dioxane-EG":
			
			NameMix="dioxaneEG"
			DataMixture=1
			
		break

		case "glycerol-water":
			
			NameMix="GlycerolH2O"
			DataMixture=1
			
		break

		case "dioxane-water":
			
			NameMix="dioxaneH2O"
			DataMixture=1
			
		break

		case "diEG-water":
			
			NameMix="diEGH2O"
			DataMixture=1
			
		break

		// pure liquid at 298 K
		default:
			
			// mPa s
			Medium_visc=NumberByKey(medium, List_visc)*1e-3
			// g/mL
			Medium_dens=NumberByKey(medium, List_dens)*1e3
		
		break
		
	endswitch


	if(DataMixture==1)
		Medium_dens=DenVisc_WaterMix(Medium_temperature,NameMix,FracMassComp1,"density")
		Medium_visc=DenVisc_WaterMix(Medium_temperature,NameMix,FracMassComp1,"viscosity")
	endif



end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ButtonProc_ShowResults(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			Calc_Results(1)
			break
		case -1: // control being killed
			break
	endswitch

	return 0

end			
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Calc_Results(displayResults)
	variable displayResults
	
	
	DFREF dfSav = GetDataFolderDFR()
	DFREF dfcal=root:Packages:AFM_Calibration:
	
	SetDataFolder dfcal

	// if not a single fit has been done, 
	// no results are available
	// just quit
	
	NVAR fit_done
	if(fit_done==0)
		return 1
	endif


	STRUCT cantilever cant
	StructFill /SDFR=dfcal cant 

	STRUCT Sens S
	StructFill /SDFR=dfcal S 

	STRUCT SpringConst k
	StructFill /SDFR=dfcal k 

	NVAR num_peaks

	SVAR Spectrum_type
	SVAR model
	SVAR CurrentGraph
	SVAR PSD
	NVAR current_peak

	NVAR Detect_MTF
	
	NVAR G_option
	
	SVAR FittingFunc
	SVAR FittingFuncBack
	NVAR Chisq

	wave wPSD=$PSD

	if(DataFolderRefStatus(dfcal:Errors)==0)
		Err_Init()
	endif
	
	SetDataFolder dfcal:Errors
	// spring constants

	NVAR D_kzs_theory_R
	NVAR D_kzs_EqTh_R	
	NVAR D_kzs_Sader_R
	NVAR D_kzs_FluidStruc_R

	NVAR D_kthetas_theory_R
	NVAR D_kthetas_EqTh_R	
	
	NVAR D_kthetas_Sader_R
	NVAR D_kthetas_FluidStruc_R

	NVAR D_kys_theory_R
	NVAR D_kys_EqTh_R	
	NVAR D_kys_Sader_R
	NVAR D_kys_FluidStruc_R

	// sensitivitites
	NVAR D_Sz_cont_R
	NVAR D_Sthetaf_cont_R
	NVAR D_SFf_cont_R

	NVAR D_Sz_noncont_R
	NVAR D_Sthetaf_noncont_R
	NVAR D_SFf_noncont_R
	
	NVAR D_Sy_cont_R
	NVAR D_Sthetat_cont_R
	NVAR D_SFt_cont_R

	NVAR D_Sy_noncont_R
	NVAR D_Sthetat_noncont_R
	NVAR D_SFt_noncont_R

	SetDataFolder dfcal

	NewDataFolder/O/S Results
	
	make/O/N=(num_peaks) wSz_CorrectionFactor, wSy_CorrectionFactor 

	make/O/N=(num_peaks) wDetector_MTF 

	make/O/N=(num_peaks) wkz_Sader, wkz_thermal, wkz_FluidStruc 
	make/O/N=(num_peaks) wSFz_noncont, wSFz_cont 
	make/O/N=(num_peaks) wSz_noncont, wSz_cont 
	make/O/N=(num_peaks) wSthetaz_noncont, wSthetaz_cont 

	make/O/N=(num_peaks) wkTheta_Sader, wkTheta_thermal, wkTheta_FluidStruc

	make/O/N=(num_peaks) wky_Sader, wky_thermal, wky_FluidStruc
	make/O/N=(num_peaks) wSFy_noncont, wSFy_cont
	make/O/N=(num_peaks) wSy_noncont, wSy_cont 
	make/O/N=(num_peaks) wSthetay_noncont, wSthetay_cont 

	Duplicate/O dfcal:wCn, wCn
	Duplicate/O dfcal:wDn, wDn
	Duplicate/O dfcal:wPeakArea, wPeakArea
	
	Duplicate/O dfcal:mode, mode
	Duplicate/O dfcal:wf0, wf0
	Duplicate/O dfcal:wfvac, wfvac
	Duplicate/O dfcal:wQ, wQ
	Duplicate/O dfcal:wtau, wtau
	Duplicate/O dfcal:wSNR, wSNR
	
	Duplicate/O dfcal:wnorm_mode, wnorm_mode
	Duplicate/O dfcal:wlogRe, wlogRe
	Duplicate/O dfcal:wDelta, wDelta
	Duplicate/O dfcal:wG, wG
	Duplicate/O dfcal:wG_Error, wG_Error

	// output uncertainty
	// spring constants: kz, ktheta, and ky
	make/O/N=(num_peaks) wD_kzs_theory_R, wD_kzs_EqTh_R, wD_kzs_Sader_R, wD_kzs_FluidStruc_R
	make/O/N=(num_peaks) wD_kthetas_theory_R, wD_kthetas_EqTh_R, wD_kthetas_Sader_R, wD_kthetas_FluidStruc_R
	make/O/N=(num_peaks) wD_kys_theory_R, wD_kys_EqTh_R, wD_kys_Sader_R, wD_kys_FluidStruc_R

	// sensitivitites
	// Sz contact and Sz non-contact
	make/O/N=(num_peaks) wD_Sz_cont_R, wD_Sthetaf_cont_R, wD_SFf_cont_R
	make/O/N=(num_peaks) wD_Sz_noncont_R, wD_Sthetaf_noncont_R, wD_SFf_noncont_R
	
	// Sy contact and Sy non-contact
	make/O/N=(num_peaks) wD_Sy_cont_R, wD_Sthetat_cont_R, wD_SFt_cont_R
	make/O/N=(num_peaks) wD_Sy_noncont_R, wD_Sthetat_noncont_R, wD_SFt_noncont_R

	variable SavCurrent_peak=current_peak
	string Savk_type=k.k_type

	string PeakCoef="PeakCoef"
	// write NVARs to waves for all peaks
	variable i=0
	for(i=0;i<num_peaks;i+=1)

		current_peak=i+1
		// peak update includes update to all spring constants
		Update_CurrentPeak()
		
		wave/SDFR=dfcal Coef=$("PeakCoef"+num2str(current_peak))
		Duplicate/O Coef, $("PeakCoef"+num2str(current_peak))
		
		wave/SDFR=dfcal Sigma=$("Sigma_"+PeakCoef+num2str(current_peak))
		Duplicate/O Sigma, $("Sigma_"+PeakCoef+num2str(current_peak))

		
		wDetector_MTF[i]=Detect_MTF

		wSz_CorrectionFactor[i]=S.Sz_CorrectionFactor
		wSy_CorrectionFactor[i]=S.Sy_CorrectionFactor	

		strswitch(Spectrum_type)
		
			case "normal":

		
				wkz_thermal[i]=k.kz_thermal
				wkz_Sader[i]=k.kz_Sader
				wkz_FluidStruc[i]=k.kz_FluidStruc

				Update_Sens()

				wSz_cont[i]=S.Sz_cont
				wSFz_cont[i]=S.SFz_cont
				wSthetaz_cont[i]=S.Sslopez_cont
		
				wSFz_noncont[i]=S.SFz_noncont
				wSz_noncont[i]=S.Sz_noncont
				wSthetaz_noncont[i]=S.Sslopez_noncont
				
				// errors in kz
				wD_kzs_theory_R[i]=D_kzs_theory_R
				wD_kzs_EqTh_R[i]=D_kzs_EqTh_R
				wD_kzs_Sader_R[i]=D_kzs_Sader_R
				wD_kzs_FluidStruc_R[i]=D_kzs_FluidStruc_R
				
				// errors in sens
				// contact
				wD_Sz_cont_R[i]=D_Sz_cont_R
				wD_Sthetaf_cont_R[i]=D_Sthetaf_cont_R
				wD_SFf_cont_R[i]=D_SFf_cont_R
				// non-contact
				wD_Sz_noncont_R[i]=D_Sz_noncont_R
				wD_Sthetaf_noncont_R[i]=D_Sthetaf_noncont_R
				wD_SFf_noncont_R[i]=D_SFf_noncont_R
		
				break
				
			case "lateral":

				wky_thermal[i]=k.ky_thermal
				wky_Sader[i]=k.ky_Sader
				wky_FluidStruc[i]=k.ky_FluidStruc
				
				wkTheta_thermal[i]=k.kTheta_thermal
				wkTheta_Sader[i]=k.kTheta_Sader
				wkTheta_FluidStruc[i]=k.kTheta_FluidStruc

				Update_Sens()

				wSy_cont[i]=S.Sy_cont
				wSFy_cont[i]=S.SFy_cont
				wSthetay_cont[i]=S.Sslopey_cont
		
				wSFy_noncont[i]=S.SFy_noncont
				wSy_noncont[i]=S.Sy_noncont
				wSthetay_noncont[i]=S.Sslopey_noncont
				
				// errors in ktheta
				wD_kthetas_theory_R[i]=D_kthetas_theory_R
				wD_kthetas_EqTh_R[i]=D_kthetas_EqTh_R
				wD_kthetas_Sader_R[i]=D_kthetas_Sader_R
				wD_kthetas_FluidStruc_R[i]=D_kthetas_FluidStruc_R
				
				// errors in ky
				wD_kys_theory_R[i]=D_kys_theory_R
				wD_kys_EqTh_R[i]=D_kys_EqTh_R
				wD_kys_Sader_R[i]=D_kys_Sader_R
				wD_kys_FluidStruc_R[i]=D_kys_FluidStruc_R
				
				// errors in sens
				// contact
				wD_Sy_cont_R[i]=D_Sy_cont_R
				wD_Sthetat_cont_R[i]=D_Sthetat_cont_R
				wD_SFt_cont_R[i]=D_SFt_cont_R
				// noncontact
				wD_Sy_noncont_R[i]=D_Sy_noncont_R
				wD_Sthetat_noncont_R[i]=D_Sthetat_noncont_R
				wD_SFt_noncont_R[i]=D_SFt_noncont_R
				
				break
								
		endswitch

	endfor
			
	if(displayResults)
		PlotResults()
	endif

	// restore variables
	current_peak=SavCurrent_peak
	Update_CurrentPeak()
	
	SetDataFolder dfSav

End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function PlotResults()

	DFREF dfSav = GetDataFolderDFR()
	DFREF dfcal=root:Packages:AFM_Calibration:
	DFREF dfcalResults=root:Packages:AFM_Calibration:Results
	DFREF dfcalErrors=root:Packages:AFM_Calibration:Errors
	
	SetDataFolder dfcal

	NVAR num_peaks
	NVAR kz_Sader, kz_thermal, kz_FluidStruc, kz_theory 
	NVAR ky_Sader, ky_thermal, ky_FluidStruc, ky_theory 
	NVAR G_option
	NVAR Chisq

	SVAR Spectrum_type
	SVAR model
	SVAR FittingFunc
	SVAR FittingFuncBack
	
	SetDataFolder dfcal:Results
	
	string ZorY=""
	
	strswitch(Spectrum_type)
		case "normal":
			ZorY="z"
		break
		
		case "lateral":
			ZorY="x"
		break
	endswitch

	wave wkz_thermal
	wave wkz_Sader
	wave wkz_FluidStruc

	wave wSz_cont
	wave wSz_noncont

	wave wSFz_cont
	wave wSFz_noncont

	wave wSthetaz_cont
	wave wSthetaz_noncont

	wave wky_thermal
	wave wky_Sader
	wave wky_FluidStruc

	wave wktheta_thermal
	wave wktheta_Sader
	wave wktheta_FluidStruc

	wave wSy_cont
	wave wSy_noncont

	wave wSFy_cont
	wave wSFy_noncont

	wave wSthetay_cont
	wave wSthetay_noncont

	wave wD_kzs_theory_R, wD_kzs_EqTh_R, wD_kzs_Sader_R, wD_kzs_FluidStruc_R
	wave wD_kthetas_theory_R, wD_kthetas_EqTh_R, wD_kthetas_Sader_R, wD_kthetas_FluidStruc_R
	wave wD_kys_theory_R, wD_kys_EqTh_R, wD_kys_Sader_R, wD_kys_FluidStruc_R

	wave wD_Sz_cont_R, wD_Sthetaf_cont_R, wD_SFf_cont_R
	wave wD_Sz_noncont_R, wD_Sthetaf_noncont_R, wD_SFf_noncont_R
	
	wave wD_Sy_cont_R, wD_Sthetat_cont_R, wD_SFt_cont_R
	wave wD_Sy_noncont_R, wD_Sthetat_noncont_R, wD_SFt_noncont_R

	NVAR/SDFR=dfcalErrors D_kzs_theory_R
	NVAR/SDFR=dfcalErrors D_kys_theory_R

	NVAR/SDFR=dfcalErrors D_Sz_cont_R
	NVAR/SDFR=dfcalErrors D_Sy_cont_R

	NVAR/SDFR=dfcalErrors D_Sthetaf_cont_R
	NVAR/SDFR=dfcalErrors D_Sthetat_cont_R

	String/G S_ResultsOut=""
	
	S_ResultsOut+="spectrum type = "+Spectrum_type+"\r"
	S_ResultsOut+="model = "+model+"\r"
	S_ResultsOut+="Fitting func. = "+FittingFunc+"\r"
	S_ResultsOut+="Fitting func. background = "+FittingFuncBack+"\r"
	S_ResultsOut+="G option = "+num2str(G_option)+" \r(0 -- infinitely long beam; 1 -- finite length, adjust for mode number)\r"
	S_ResultsOut+="Number of peaks n = "+num2str(num_peaks)+"\r"
	S_ResultsOut+="Chi squared = "+num2str(Chisq)+"\r"
	S_ResultsOut+="\r**********************\r"

	SetDataFolder dfcal

	string/G NVAR_list=VariableList("!*_checked", ";", 4)
	NVAR_list=RemoveFromList(VariableList("V_*", ";", 4), NVAR_list)
	NVAR_list=RemoveFromList(VariableList("width_*", ";", 4), NVAR_list)
	NVAR_list=SortList(NVAR_list, ";", 8)
	variable numOfVars=ItemsInList(NVAR_list)
	
	SetDataFolder dfcal:Results

	make/O/N=(numOfVars)/T Cant_param_names
	make/O/N=(numOfVars) Cant_param_values
	Cant_param_names=StringFromList(p, NVAR_list, ";")
	Cant_param_values=Return_GlobalVarValue(dfcal, Cant_param_names[p])

	DoWindow/F Table_Vars
	if(V_flag==0)
		Edit/K=0/W=(21,128,270,1380) Cant_param_names, Cant_param_values
		DoWindow/C Table_Vars
		ModifyTable /W=Table_Vars autosize={1, 0, -1, 0, 0 }
	endif

	wave/SDFR=dfcal/T BkgdCoef_list
	wave/SDFR=dfcal BkgdCoef

	make/O/N=(DimSize(BkgdCoef_list,0))/T BackCoefList
	BackCoefList=BkgdCoef_list[p][0]

	DoWindow/F Table_BackgroundCoef
	if(V_flag==0)
		Edit/K=0/W=(4,40,180,40+22+22*DimSize(BkgdCoef_list,0))  BackCoefList
		DoWindow/C Table_BackgroundCoef
	endif

	AppendToTable  /W=Table_BackgroundCoef BkgdCoef
	ModifyTable /W=Table_BackgroundCoef autosize={1, 0, -1, 0, 0 }

	wave/SDFR=dfcal/T ListCoef=PeakCoef_list1
	make/O/N=(DimSize(ListCoef,0))/T PeakCoefList
	PeakCoefList=ListCoef[p][0]
	
	DoWindow/F Table_PeakCoef
	if(V_flag==0)
		Edit/K=0/W=(4,40,4+80+num_peaks*80*2,40+24+24*DimSize(PeakCoefList,0))  PeakCoefList
		DoWindow/C Table_PeakCoef
	endif
	
	variable i=1
	for(i=1;i<num_peaks+1;i+=1)
		wave/SDFR=dfcalResults Coef=$("PeakCoef"+num2str(i))
		wave/SDFR=dfcalResults Sigma_Coef=$("Sigma_PeakCoef"+num2str(i))
		AppendToTable  /W=Table_PeakCoef Coef
		AppendToTable  /W=Table_PeakCoef Sigma_Coef
	endfor
	
	ModifyTable /W=Table_PeakCoef autosize={1, 0, -1, 0, 0 }

	DoWindow/F Table_peakParams1
	if(V_flag==0)
		wave mode,wf0,wfvac,wtau,wQ,wSNR,wSz_CorrectionFactor,wSy_CorrectionFactor,wPeakArea,wDetector_MTF
		Edit/W=(4,40,720,40+24+24*num_peaks) mode,wf0,wfvac,wtau,wQ,wSNR,wSz_CorrectionFactor,wSy_CorrectionFactor,wPeakArea,wDetector_MTF
		ModifyTable format(Point)=1,width(mode)=36,width(wf0)=68,width(wfvac)=66,width(wtau)=57
		ModifyTable width(wQ)=47,width(wSNR)=47,width(wSz_CorrectionFactor)=68,width(wSy_CorrectionFactor)=68
		ModifyTable width(wPeakArea)=76, width(wDetector_MTF)=76
		DoWindow/C Table_peakParams1
	endif
	
	DoWindow/F Table_peakParams2
	if(V_flag==0)
		wave wCn,wDn,wnorm_mode,wlogRe,wDelta, wG
		Edit/W=(4,40,504,40+24+24*num_peaks) wCn,wDn,wnorm_mode,wlogRe,wDelta,wG
		ModifyTable format(Point)=1,width=60
		DoWindow/C Table_peakParams2
		AutoPositionWindow/M=1/R=Table_peakParams1 Table_peakParams2
	endif

	S_ResultsOut+="error are 95 % confidence intervals from the results of multi-peak fits\r"
	S_ResultsOut+="\r**********************\r"

	S_ResultsOut+="kz(theory) = "+num2str(kz_theory)+" ± "+num2str(D_kzs_theory_R*kz_theory)+" N/m\r"
	S_ResultsOut+="error kz(theory) = "+num2str(D_kzs_theory_R*100)+" %\r"

	S_ResultsOut+="ky(theory) = "+num2str(ky_theory)+" ± "+num2str(D_kys_theory_R*ky_theory)+" N/m\r"
	S_ResultsOut+="error ky(theory) = "+num2str(D_kys_theory_R*100)+" %\r"

	S_ResultsOut+="\r**********************\r"

	variable Err_k, Err_S
	
	strswitch(Spectrum_type)
	
		case "normal":

			WaveStats/Q wkz_thermal
			
			Err_k=V_sem*StatsInvStudentCDF(0.975, V_npnts)		
			S_ResultsOut+="kz(thermal) = "+num2str(V_avg)+" ± "+num2str(Err_k)+" N/m\r"
		
			WaveStats/Q wkz_Sader
			Err_k=V_sem*StatsInvStudentCDF(0.975, V_npnts)
			S_ResultsOut+="kz(Sader) = "+num2str(V_avg)+" ± "+num2str(Err_k)+" N/m\r"
				
			WaveStats/Q wkz_FluidStruc
			Err_k=V_sem*StatsInvStudentCDF(0.975, V_npnts)
			S_ResultsOut+="kz(FluidStruc) = "+num2str(V_avg)+" ± "+num2str(Err_k)+" N/m\r"
			
			S_ResultsOut+="\r**********************\r"
		
			// same value for all peaks
			// obtained from the FCs 
			S_ResultsOut+="Sz(contact) = "+num2str(wSz_cont[0])+" ± "+num2str(D_Sz_cont_R*wSz_cont[0])+" V/m\r"
		
			WaveStats/Q wSz_noncont
			Err_S=V_sem*StatsInvStudentCDF(0.975, V_npnts)		
			S_ResultsOut+="Sz(non-contact) = "+num2str(V_avg)+" ± "+num2str(Err_S)+" V/m\r"

			WaveStats/Q wSFz_cont
			Err_S=V_sem*StatsInvStudentCDF(0.975, V_npnts)		
			S_ResultsOut+="SF(contact) = "+num2str(V_avg)+" ± "+num2str(Err_S)+" V/N\r"
		
			WaveStats/Q wSFz_noncont
			Err_S=V_sem*StatsInvStudentCDF(0.975, V_npnts)		
			S_ResultsOut+="SF(non-contact) = "+num2str(V_avg)+" ± "+num2str(Err_S)+" V/N\r"
				
			S_ResultsOut+="Stheta(contact) = "+num2str(wSthetaz_cont[0])+" ± "+num2str(D_Sthetaf_cont_R*wSthetaz_cont[0])+" V/rad\r"
		
			WaveStats/Q wSthetaz_noncont
			Err_S=V_sem*StatsInvStudentCDF(0.975, V_npnts)		
			S_ResultsOut+="Stheta(non-contact) = "+num2str(V_avg)+" ± "+num2str(Err_S)+" V/rad\r"

			S_ResultsOut+="\r**********************\r"
			
			print S_ResultsOut

			if(strsearch(model, "SFO (full)",0)>=0)
			
				DoWindow/F Table_k
				if(V_flag==0)
					Edit/W=(60,100,484,100+24+24*num_peaks) wkz_thermal,wD_kzs_EqTh_R,wkz_FluidStruc,wD_kzs_FluidStruc_R
					ModifyTable format(Point)=1
					DoWindow/C Table_k
					AutoPositionWindow/M=1/R=Table_peakParams2 Table_k
				endif

			else

				DoWindow/F Table_k
				if(V_flag==0)
					Edit/W=(60,100,484,100+24+24*num_peaks) wkz_thermal,wD_kzs_EqTh_R,wkz_Sader,wD_kzs_Sader_R
					ModifyTable format(Point)=1
					DoWindow/C Table_k
					AutoPositionWindow/M=1/R=Table_peakParams2 Table_k
				endif
				
			endif

			DoWindow/F Table_Sens_cont
			if(V_flag==0)
				Edit/W=(60,100,660,100+24+24*num_peaks) wSz_cont,wD_Sz_cont_R,wSFz_cont,wD_SFf_cont_R
				AppendToTable wSthetaz_cont,wD_Sthetaf_cont_R
				ModifyTable format(Point)=1
				DoWindow/C Table_Sens_cont
				AutoPositionWindow/M=1/R=Table_k Table_Sens_cont
			endif


			DoWindow/F Table_Sens_noncont
			if(V_flag==0)
				Edit/W=(60,100,660,100+24+24*num_peaks) wSz_noncont,wD_Sz_noncont_R,wSFz_noncont,wD_SFf_noncont_R
				AppendToTable wSthetaz_noncont,wD_Sthetaf_noncont_R
				ModifyTable format(Point)=1
				DoWindow/C Table_Sens_noncont
				AutoPositionWindow/M=1/R=Table_Sens_cont Table_Sens_noncont
			endif

		break
		
		case "lateral":
		
			WaveStats/Q wktheta_thermal
			Err_S=V_sem*StatsInvStudentCDF(0.975, V_npnts)		
			S_ResultsOut+="ktheta(thermal) = "+num2str(V_avg*1e9)+" ± "+num2str(Err_S*1e9)+" nN/rad\r"
		
			WaveStats/Q wktheta_Sader
			Err_S=V_sem*StatsInvStudentCDF(0.975, V_npnts)		
			S_ResultsOut+="ktheta(Sader) = "+num2str(V_avg*1e9)+" ± "+num2str(Err_S*1e9)+" nN/rad\r"
				
			WaveStats/Q wktheta_FluidStruc
			Err_S=V_sem*StatsInvStudentCDF(0.975, V_npnts)		
			S_ResultsOut+="ktheta(FluidStruc) = "+num2str(V_avg*1e9)+" ± "+num2str(Err_S*1e9)+" nN/rad\r"
			
			S_ResultsOut+="\r**********************\r"

			WaveStats/Q wky_thermal
			Err_S=V_sem*StatsInvStudentCDF(0.975, V_npnts)		
			S_ResultsOut+="ky(thermal) = "+num2str(V_avg)+" ± "+num2str(Err_S)+" N/m\r"
		
			WaveStats/Q wky_Sader
			Err_S=V_sem*StatsInvStudentCDF(0.975, V_npnts)		
			S_ResultsOut+="ky(Sader) = "+num2str(V_avg)+" ± "+num2str(Err_S)+" N/m\r"
				
			WaveStats/Q wky_FluidStruc
			Err_S=V_sem*StatsInvStudentCDF(0.975, V_npnts)		
			S_ResultsOut+="ky(FluidStruc) = "+num2str(V_avg)+" ± "+num2str(Err_S)+" N/m\r"
			
			S_ResultsOut+="\r**********************\r"
		
			// same value for all peaks
			// obtained from the FCs 
			S_ResultsOut+="Sy(contact) = "+num2str(wSy_cont[0])+" ± "+num2str(D_Sy_cont_R*wSy_cont[0])+" V/m\r"
		
			WaveStats/Q wSy_noncont
			Err_S=V_sem*StatsInvStudentCDF(0.975, V_npnts)		
			S_ResultsOut+="Sy(non-contact) = "+num2str(V_avg)+" ± "+num2str(Err_S)+" V/m\r"

			WaveStats/Q wSFy_cont
			Err_S=V_sem*StatsInvStudentCDF(0.975, V_npnts)		
			S_ResultsOut+="SF(contact) = "+num2str(V_avg)+" ± "+num2str(Err_S)+" V/N\r"
		
			WaveStats/Q wSFy_noncont
			Err_S=V_sem*StatsInvStudentCDF(0.975, V_npnts)		
			S_ResultsOut+="SF(non-contact) = "+num2str(V_avg)+" ± "+num2str(Err_S)+" V/N\r"
				
			S_ResultsOut+="Stheta(contact) = "+num2str(wSthetay_cont[0])+" ± "+num2str(D_Sthetat_cont_R*wSthetay_cont[0])+" V/rad\r"
		
			WaveStats/Q wSthetay_noncont
			Err_S=V_sem*StatsInvStudentCDF(0.975, V_npnts)		
			S_ResultsOut+="Stheta(non-contact) = "+num2str(V_avg)+" ± "+num2str(Err_S)+" V/rad\r"

			S_ResultsOut+="\r**********************\r"
			
			print S_ResultsOut

			if(strsearch(model, "SFO (full)",0)>=0)
			
				DoWindow/F Table_ktheta
				if(V_flag==0)
					Edit/W=(60,100,484,100+24+24*num_peaks) wktheta_thermal,wD_kthetas_EqTh_R,wktheta_FluidStruc,wD_kthetas_FluidStruc_R
					ModifyTable format(Point)=1
					DoWindow/C Table_ktheta
					AutoPositionWindow/M=1/R=Table_peakParams2 Table_ktheta
				endif

				DoWindow/F Table_k
				if(V_flag==0)
					Edit/W=(60,100,484,100+24+24*num_peaks) wky_thermal,wD_kys_EqTh_R,wky_FluidStruc,wD_kys_FluidStruc_R
					ModifyTable format(Point)=1
					DoWindow/C Table_k
					AutoPositionWindow/M=1/R=Table_ktheta Table_k
				endif

			else

				DoWindow/F Table_ktheta
				if(V_flag==0)
					Edit/W=(60,100,484,100+24+24*num_peaks) wktheta_thermal,wD_kthetas_EqTh_R,wktheta_Sader,wD_kthetas_Sader_R
					ModifyTable format(Point)=1
					DoWindow/C Table_ktheta
					AutoPositionWindow/M=1/R=Table_peakParams2 Table_ktheta
				endif

				DoWindow/F Table_k
				if(V_flag==0)
					Edit/W=(60,100,484,100+24+24*num_peaks) wky_thermal,wD_kys_EqTh_R,wky_Sader,wD_kys_Sader_R
					ModifyTable format(Point)=1
					DoWindow/C Table_k
					AutoPositionWindow/M=1/R=Table_ktheta Table_k
				endif
				
			endif

			DoWindow/F Table_Sens_cont
			if(V_flag==0)
				Edit/W=(60,100,660,100+24+24*num_peaks) wSy_cont,wD_Sy_cont_R,wSFy_cont,wD_SFt_cont_R
				AppendToTable wSthetay_cont,wD_Sthetat_cont_R
				ModifyTable format(Point)=1
				DoWindow/C Table_Sens_cont
				AutoPositionWindow/M=1/R=Table_k Table_Sens_cont
			endif

			DoWindow/F Table_Sens_noncont
			if(V_flag==0)
				Edit/W=(60,100,660,100+24+24*num_peaks) wSy_noncont,wD_Sy_noncont_R,wSFy_noncont,wD_SFt_noncont_R
				AppendToTable wSthetay_noncont,wD_Sthetat_noncont_R
				ModifyTable format(Point)=1
				DoWindow/C Table_Sens_noncont
				AutoPositionWindow/M=1/R=Table_Sens_cont Table_Sens_noncont
			endif

		break	
	
	endswitch

	printNB()

	SetDataFolder dfSav


end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function KillResults()

	KillWindow/Z Table_k
	KillWindow/Z Table_ktheta
	KillWindow/Z Table_Sens_cont
	KillWindow/Z Table_Sens_noncont
	KillWindow/Z Table_peakParams1
	KillWindow/Z Table_peakParams2
	KillWindow/Z Table_BackgroundCoef
	KillWindow/Z Table_PeakCoef
	KillWindow/Z Table_Vars
	KillWindow/Z kztheory
	KillWindow/Z kytheory
	KillWindow/Z TipH

	KillWindow/Z PSDfit

end

Function ButtonProc_KillResults(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			KillResults()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function PrintNB()
	DFREF dfSav = GetDataFolderDFR()
	DFREF dfcal=root:Packages:AFM_Calibration:
	
	SVAR/SDFR=dfcal spectrum_type


// === All below are for outputting results of analysis ===
// Begin writing out the Notebook

// Generate NB name	
	String/G nb = "PSDfit"
// Check if NB already exists
	DoWindow/F $nb
	if (V_flag == 0)
		NewNotebook/F=1/N=$nb
	endif	
// This line serves to overwrite NB if already written to.	
	Notebook $nb selection={startOfFile, endOfFile}
// Let's define some rulers
	Notebook $nb newruler=text, justification=0
	Notebook $nb newruler=figures, justification=0	
	Notebook $nb newruler=title, justification=1
	Notebook $nb newruler=caption, justification=0
// Title Screen	
	Notebook $nb ruler=title	
	Notebook $nb fstyle=1, justification=1, fSize=16, text="PSD fit parameters\r\r"	
//	=============================================	
	SVAR/SDFR=dfcal:Results S_ResultsOut
	string S_out=S_ResultsOut

	S_out+="\r\r"
	Notebook $nb ruler=text, fstyle=0, fSize=12, text=S_out

	// PSD plot
	SVAR currentGraph=dfcal:currentGraph	
	DoWindow/F $currentGraph
	GetWindow $currentGraph wsize //Outer
	ModifyGraph width=72*8,height={Aspect,0.75}
	Notebook $nb ruler=figures, scaling={50,50}, picture={$currentGraph,-5,1}
	Notebook $nb ruler=caption, fstyle=1+2, text="\r\rFigure 1. "
	Notebook $nb ruler=text, fstyle=2, text="PSD plot.\r\r\r\r"
	ModifyGraph width=0,height=0
	MoveWindow V_left, V_top, V_right, V_bottom

	// Peak parameters	
	Notebook $nb ruler=title, fstyle=1+2,  text="Table 1. "
	Notebook $nb ruler=text, fstyle=2, text="Peak parameters\r\r"
	Notebook $nb ruler=figures, scaling={100,100}, picture={Table_peakParams1,-5,1}
	Notebook $nb text="\r\r"

	// Peak parameters	
	Notebook $nb ruler=title, fstyle=1+2, text="Table 2. "
	Notebook $nb ruler=text, fstyle=2, text="Peak parameters\r\r"
	Notebook $nb ruler=figures, scaling={100,100}, picture={Table_peakParams2,-5,1}
	Notebook $nb text="\r\r"

	// Spring constants	
	Notebook $nb ruler=title, fstyle=1+2, text="Table 3. "
	Notebook $nb ruler=text, fstyle=2, text="Spring constants\r\r"
	Notebook $nb ruler=figures, scaling={100,100}, picture={Table_k,-5,1}
	Notebook $nb text="\r\r"

	if(CmpStr(spectrum_type, "lateral")==0)
		// Spring constants	
		Notebook $nb ruler=title, fstyle=1+2, text="Table 3-2. "
		Notebook $nb ruler=text, fstyle=2, text="Spring constants\r\r"
		Notebook $nb ruler=figures, scaling={100,100}, picture={Table_ktheta,-5,1}
		Notebook $nb text="\r\r"
	endif

	// Contact sensitivities	
	Notebook $nb ruler=title, fstyle=1+2, text="Table 4. "
	Notebook $nb ruler=text, fstyle=2, text="Contact sensitivities\r\r"
	Notebook $nb ruler=figures, scaling={100,100}, picture={Table_Sens_cont,-5,1}
	Notebook $nb text="\r\r"

	// Non-contact sensitivities	
	Notebook $nb ruler=title, fstyle=1+2, text="Table 5. "
	Notebook $nb ruler=text, fstyle=2, text="Non-contact sensitivities\r\r"
	Notebook $nb ruler=figures, scaling={100,100}, picture={Table_Sens_noncont,-5,1}
	Notebook $nb text="\r\r"

	// Cantilever parameters	
	DoWindow/F Panel_Cal
	TabProc2("Panel_Cal",0)
	TabControl tab,value= 0
	SavePict/SNAP=1/E=(-5)/WIN=Panel_Cal as "Clipboard"
	LoadPict/Q "Clipboard" PanelTab0
	TabProc2("Panel_Cal",2)

	Notebook $nb ruler=figures, scaling={100,100}, picture={PanelTab0,-5,1}
	Notebook $nb ruler=caption, fstyle=1+2, text="\r\rFigure 2. "
	Notebook $nb ruler=text, fstyle=2, text="Cantilever parameters\r\r\r\r"

	KillPicts PanelTab0

	// Peak coef	
	Notebook $nb ruler=title, fstyle=1+2, text="Table 6. "
	Notebook $nb ruler=text, fstyle=2, text="Peak fit coefficients\r\r"
	Notebook $nb ruler=figures, scaling={100,100}, picture={Table_PeakCoef,-5,1}
	Notebook $nb text="\r\r"

	// Background coef	
	Notebook $nb ruler=title, fstyle=1+2, text="Table 7. "
	Notebook $nb ruler=text, fstyle=2, text="Background fit coefficients\r\r"
	Notebook $nb ruler=figures, scaling={100,100}, picture={Table_BackgroundCoef,-5,1}
	Notebook $nb text="\r\r"

	// All variables	
	Notebook $nb ruler=title, fstyle=1+2, text="Table 8. "
	Notebook $nb ruler=text, fstyle=2, text="Global variables\r\r"
	Notebook $nb ruler=title, fstyle=0

//	Notebook $nb ruler=figures, scaling={70,70}, picture={Table_Vars,1,1}
//	Notebook $nb text="\r\r"
	
	wave/T/SDFR=dfcal:Results Cant_param_names//=Cant_params_names
	wave/SDFR=dfcal:Results Cant_param_values//=Cant_params_values
	
	variable i=0, NOP=numpnts(Cant_param_values)
	for(i=0;i<NOP;i+=1)
		S_out=Cant_param_names[i]+":"+num2str(Cant_param_values[i])+"\r"
		Notebook $nb ruler=text, text=S_out
	endfor

		Notebook $nb text="\r\r"

//	SaveNotebook/O/S=4 $nb as (nb+".rtf")
	
	// coating thick vs kz and kx plot
	DoWindow/F kztheory
	if(V_flag)
		Notebook $nb ruler=figures, scaling={120,120}, picture={kztheory,-5,1}
		Notebook $nb ruler=caption, fstyle=1+2, text="\r\rFigure 3. "
		Notebook $nb ruler=text, fstyle=2, text="Coating thickness vs. kz.\r\r\r\r"
	endif
	
	DoWindow/F kytheory
	if(V_flag)
		Notebook $nb ruler=figures, scaling={120,120}, picture={kytheory,-5,1}
		Notebook $nb ruler=caption, fstyle=1+2, text="\r\rFigure 4. "
		Notebook $nb ruler=text, fstyle=2, text="kx vs. coating thickness.\r\r\r\r"
	endif

	DoWindow/F TipH
	if(V_flag)
		Notebook $nb ruler=figures, scaling={120,120}, picture={TipH,-5,1}
		Notebook $nb ruler=caption, fstyle=1+2, text="\r\rFigure 5. "
		Notebook $nb ruler=text, fstyle=2, text="Tip height vs. coating thickness.\r\r\r\r"
	endif

	SetDataFolder dfSav

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Return_GlobalVarValue(var_folder, var_name)
	DFREF var_folder
	string var_name
	
	NVAR/SDFR=var_folder var=$var_name
	return var

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function SetVarProc_UpdateWidth(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval

			DFREF dfcal=root:Packages:AFM_Calibration:
			NVAR cant_b=dfcal:cant_b
			NVAR cant_a=dfcal:cant_a
			NVAR width_scale=dfcal:width_scale
			
			width_scale=(dval-cant_a)/(cant_b-cant_a)

			DoUpdate
			Update_WidthFit(dval)
			
			DoUpdate
			Calc_k_Sader()
			Update_Sens()				

			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function SliderProc_updateWidth(sa) : SliderControl
	STRUCT WMSliderAction &sa

	switch( sa.eventCode )
		case -1: // control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set
				Variable curval = sa.curval

				DFREF dfcal=root:Packages:AFM_Calibration:
				NVAR cant_width=dfcal:cant_width

				DoUpdate
				Update_WidthFit(cant_width)

				DoUpdate
				Calc_k_Sader()
				Update_Sens()				


			endif
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function CheckProc_SelectWidth(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			DFREF dfcal=root:Packages:AFM_Calibration:
			NVAR width_is_avg=dfcal:width_is_avg
			NVAR width_is_b=dfcal:width_is_b
			NVAR width_is_a=dfcal:width_is_a
			NVAR width_scale=dfcal:width_scale
			
			NVAR cant_width=dfcal:cant_width
			
			strswitch(cba.ctrlName)
			
				case "widthMode_a_tab0":
					width_is_b=0
					width_is_avg=0
					width_scale=0
				break

				case "widthMode_b_tab0":
					width_is_a=0
					width_is_avg=0
					width_scale=1
				break
			
				case "widthMode_avg_tab0":
					width_is_b=0
					width_is_a=0
					width_scale=0.5
				break

			endswitch
			
			DoUpdate
			Update_WidthFit(cant_width)

			DoUpdate
			Calc_k_Sader()				
			Update_Sens()				

			break
		case -1: // control being killed
			break
	endswitch

	DoUpdate

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function PopMenuProc_SelectTipShape(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr

			DFREF dfcal=root:Packages:AFM_Calibration:
			SVAR tip_Shape=dfcal:tip_Shape
			tip_Shape=popStr 

			string S_popmenu=Get_S_popmenu(popStr, pa.ctrlName, pa.win)
			PopupMenu $pa.ctrlName,value= #S_popmenu
			
//			strswitch(tip_Shape)
//			
//			
//				case "tetragonal piramid":
//				case "trigonal piramid":
//				
//					Setvariable tip_angle2_tab0, disable=0
//					Setvariable tip_angle3_tab0, disable=0
//				
//				break
//			
//				default:
//				
//					Setvariable tip_angle2_tab0, disable=2
//					Setvariable tip_angle3_tab0, disable=2
//				
//				break
//			
//			endswitch

			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function PopMenuProc_SelectSpingConst(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
	
			DFREF dfcal=root:Packages:AFM_Calibration:
			SVAR k_type=dfcal:k_type
			k_type=popStr 
			Update_Sens()
			
			string S_popmenu=Get_S_popmenu(popStr, pa.ctrlName, pa.win)
			PopupMenu $pa.ctrlName,value= #S_popmenu
					
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function CheckProc_Check_Scont(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			
			if(checked)

				DFREF dfcal=root:Packages:AFM_Calibration:
				
				SVAR/SDFR=dfcal Spectrum_type 
				NVAR/SDFR=dfcal check_Scont_use_Snoncont_avg 
				NVAR/SDFR=dfcal check_Scont_use_Snoncont_n1 
				
				strswitch(Spectrum_type)
				
					case "normal":
					
						WAVE/SDFR=dfcal:Results wSens=wSz_noncont
						NVAR/SDFR=dfcal V_Sens=Sz_cont 
						
					break
					
					case "lateral":
					
						WAVE/SDFR=dfcal:Results wSens=wSy_noncont
						NVAR/SDFR=dfcal V_Sens=Sy_cont 
						
					break
					
	
				endswitch

				strswitch(cba.CtrlName)
				
					case "set_S_cont2S_noncont_avg_tab2":
					
						check_Scont_use_Snoncont_n1=0
						
						WaveStats/Q/M=1 wSens
						V_Sens=V_avg
						
					break
					
					case "set_S_cont2S_noncont_n1_tab2":
					
						check_Scont_use_Snoncont_avg=0
						
						V_Sens=wSens[0]

					break
				
				endswitch
				
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
Function/S Popup_CoefList()

	DFREF dfSav = GetDataFolderDFR()

	DFREF dfcal=root:Packages:AFM_Calibration:
	SetDataFolder dfcal
	

	string List=WaveList("wGrcoef*",";", "" )
	List+=WaveList("wGicoef*",";", "" )

	SetDataFolder dfSav

	return List

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Calc_tH_from_fres()

	DFREF dfSav = GetDataFolderDFR()

	DFREF dfcal=root:Packages:AFM_Calibration:
	SetDataFolder dfcal
	
	STRUCT cantilever cant
	StructFill /SDFR=dfcal cant 

	NVAR tip_H
	
	NVAR num_peaks
	SVAR model
	SVAR Spectrum_type
	
	NVAR current_peak
	
	wave wfvac

	strswitch(Spectrum_type)
	
		case "normal":
	
			if(num_peaks<2)
				SetDataFolder dfSav
				Abort "Need at least two peaks for calculation of t and H."
			endif
					
			Duplicate/O wfvac, wn2exp
		
			wn2exp=(wfvac/wfvac[0])^2
					
			make/O/N=(num_peaks) Cn4
			wave Cn4
			
			Cn4=C_n(p+1)^4/C_n(1)^4
			
			Duplicate/O wn2exp, wn2explog
			Duplicate/O Cn4, Cn4log
			 
			SetFormula wn2explog, "ln(wn2exp)"
			SetFormula Cn4log, "ln(Cn4)"
			
			variable Pmax=min(numpnts(wn2explog),2)
			CurveFit/M=2/W=0/Q line, wn2explog[0,Pmax]/X=Cn4log[0,Pmax]/D
			wave W_coef
			
			variable a=W_coef[0], b=W_coef[1]
			
			cant.mend2mc=Calc_mend2mc(a,b)
			variable mc2kc=Calc_mc2kc(a,b,2*pi*wfvac[0])
	
			cant.cant_thickness=Calc_t(mc2kc)
			tip_H=Calc_H(cant.mend2mc)
			
//			print "cant_thickness=", cant_thickness, "mc2kc=", mc2kc

		break
			
			
		case "lateral":
		
			cant.cant_thickness=2*pi*wfvac[current_peak-1]/D_n(current_peak)
			cant.cant_thickness*=cant.cant_length_e*cant.cant_width/2
			cant.cant_thickness*=sqrt(cant.cant_rho/cant.cant_G_modulus_e)
			// include correction for non-ideal shape and thin film coating
			cant.cant_thickness*=sqrt(1+(cant.coat_a_rho*cant.coat_a_thick+cant.coat_b_rho*cant.coat_b_thick)/(cant.cant_rho*cant.cant_thickness))
			cant.cant_thickness/=sqrt(1-0.630247*cant.cant_thickness_e/cant.cant_width)
		
		break
		
	endswitch

	Calc_k_theory()
	
	SetDataFolder dfSav

End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
// assume side walls are coated too
Function Calc_t(mc2kc)
	variable mc2kc
	
	DFREF dfSav = GetDataFolderDFR()

	DFREF dfcal=root:Packages:AFM_Calibration:
	SetDataFolder dfcal
	
	NVAR cant_length
	NVAR cant_a
	NVAR cant_b
	NVAR cant_rho
	NVAR cant_E_modulus
	NVAR coat_a_thick
	NVAR coat_a_rho
	NVAR coat_a_E_modulus
	NVAR coat_b_thick
	NVAR coat_b_rho
	NVAR coat_b_E_modulus

//	NVAR cant_rho_e
//	NVAR cant_E_modulus_e

	variable bavg=(cant_a+cant_b)/2
	variable r=cant_a/cant_b
	variable tf=coat_a_thick+coat_b_thick
	variable Eftf=coat_a_E_modulus*coat_a_thick+coat_b_E_modulus*coat_b_thick
	variable rho_width_t=coat_a_rho*cant_b*coat_a_thick+coat_b_rho*cant_b*coat_b_thick
	variable i=bavg/12*2/3*(1+2*r/(1+r)^2)
	
	variable C0, C1, C2, C3, C4
	
	
	C0=-rho_width_t*tf
	
	C1=-(rho_width_t+cant_rho*bavg*tf)
	
	C2=-cant_rho*bavg
	
	C3=mc2kc*3*i*Eftf/cant_length^4
	
	C4=mc2kc*3*i*cant_E_modulus/cant_length^4
	
	variable t=NaN
	
	Make/O/N=5 W_polycoef={C0,C1,C2,C3,C4}
	
	FindRoots/Q/P=W_polycoef
	wave/C W_polyRoots
	
	if(V_flag==0)
		variable j
		for(j=0;j<4;j+=1)
			if(imag(W_polyRoots[j])==0 && real(W_polyRoots[j])>0)
				t=real(W_polyRoots[j])
				break
			endif		
		endfor
	else
		t=NaN
	endif

	
	SetDataFolder dfSav

	return t
	
end	
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Calc_H(mend2mc)
	variable mend2mc
	
	DFREF dfSav = GetDataFolderDFR()

	DFREF dfcal=root:Packages:AFM_Calibration:
	SetDataFolder dfcal
	NVAR tip_H
	NVAR tip_angle1
	NVAR tip_angle2
	NVAR tip_angle3
	NVAR cant_rho
	NVAR cant_a
	NVAR cant_b
	NVAR cant_D
	NVAR cant_C
	NVAR cant_length
	NVAR cant_thickness
	NVAR cant_rho_e
	NVAR cant_thickness_e
	
	NVAR coat_a_thick
	NVAR coat_a_rho
	NVAR coat_b_thick
	NVAR coat_b_rho
	
	SVAR tip_Shape


	variable h, mtip
	
	mtip=mend2mc*cant_rho_e*(cant_a+cant_b)/2*cant_thickness_e*cant_length
	
	// add volume of removed material in the arrow section
	// mtip+=cant_rho_e*(cant_a+cant_b)/2*cant_thickness_e*cant_D*(1-(1/2+cant_C/cant_b))
	mtip+=cant_rho_e*(cant_b+cant_c)/2*cant_D*cant_thickness_e
//	mtip+=cant_rho*(cant_b+cant_c)/2*cant_D*cant_thickness
//	mtip+=coat_a_rho*(cant_b+cant_c)/2*cant_D*coat_a_thick
//	mtip+=coat_b_rho*(cant_b+cant_c)/2*cant_D*coat_b_thick
	
	// account for mass around base of the integrated tip
	// mtip*=0.5
	
	h=mtip
	// cone;trigonal piramid;tetragonal piramid;square piramid;hollow sq. piramid
	strswitch(tip_Shape)
	
		case "cone":

			// V=1/3*Abase*h
			// volume
			h/=cant_rho_e
			// h^3
			h/=pi/3*tan(tip_angle1/180*pi)^2
			// h
			h=h^(1/3)
			
		break
		
		case "trigonal piramid":
		
			h=nan

		break
		
		case "tetragonal piramid":
		
			// V=1/3*Abase*h

			// V=1/3*h^3*tan(a1)*(tan(a2)+tan(a3))
			// volume
			h/=cant_rho_e
			// h^3
			h/=1/3*tan(tip_angle1/180*pi)*(tan(tip_angle2/180*pi)+tan(tip_angle3/180*pi))
			// h
			h=h^(1/3)
		
		break

		case "square piramid":
		
			h=nan
		
		break
	
		case "hollow sq. piramid":
		
			h=nan
		
		break

	endswitch
	
	SetDataFolder dfSav

	return h
	
end	
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ButtonProc_Calc_tH(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			Calc_tH_from_fres()

			break

		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function PopMenuProc_SetHoldParam(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr

			DFREF dfcal=root:Packages:AFM_Calibration:
			NVAR/SDFR=dfcal current_peak
			
			wave/SDFR=dfcal list=$("PeakCoef_list"+num2str(current_peak)+"_Sel")

			variable param_Index=popNum-1
			
			if(DimSize(list,0)<param_Index)
				break
			endif
			
			variable i

			variable Var_checkbox=list[param_Index][2]
			
			CheckBox check_Hold_param_tab1 value=(Var_checkbox==48)

			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function CheckProc_HoldParam(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			
			DFREF dfcal=root:Packages:AFM_Calibration:
			NVAR/SDFR=dfcal current_peak
			NVAR/SDFR=dfcal num_peaks
			
			wave/SDFR=dfcal list=$("PeakCoef_list"+num2str(current_peak)+"_Sel")

			ControlInfo popup_holdParam_tab1
			variable param_Index=V_value-1
			
			if(DimSize(list,0)<param_Index)
				break
			endif
			
			variable i

			for(i=1;i<num_peaks+1;i+=1)
				wave/SDFR=dfcal list=$("PeakCoef_list"+num2str(i)+"_Sel")
				list[param_Index][2]=32+16*checked
			endfor 


			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ButtonProc_CopyParam(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			ControlInfo popup_CopyParam_tab1
			
			Update_FitParam(S_Value,-1)

			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ButtonProc_Calc_mfmc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			DFREF dfcal=root:Packages:AFM_Calibration:
			NVAR/SDFR=dfcal current_peak
			SVAR/SDFR=dfcal model

			if(strsearch(model, "SFO (full)", 0)>=0)
				wave/SDFR=dfcal/T list= $("PeakCoef_list"+num2str(current_peak))
				list[2][1]=num2str(Calc_mfmc())
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
Function PopMenuProc_SelectMat(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr

			DFREF dfcal=root:Packages:AFM_Calibration:

			SVAR/SDFR=dfcal List_matDen
			SVAR/SDFR=dfcal List_matE
			SVAR/SDFR=dfcal List_matG
			
			strswitch(pa.ctrlName)
			
				case "Material_t_tab0":
				
					SVAR/SDFR=dfcal cant_mater
					NVAR/SDFR=dfcal cant_rho
					NVAR/SDFR=dfcal cant_E_modulus
					NVAR/SDFR=dfcal cant_G_modulus
					
					cant_mater=popStr
					cant_rho=NumberByKey(cant_mater, List_matDen)
					cant_E_modulus=NumberByKey(cant_mater, List_matE)
					cant_G_modulus=NumberByKey(cant_mater, List_matG)
					

				break
			
				case "Material_ta_tab0":
				
					SVAR/SDFR=dfcal coat_a_mater
					NVAR/SDFR=dfcal coat_a_rho
					NVAR/SDFR=dfcal coat_a_E_modulus
					NVAR/SDFR=dfcal coat_a_G_modulus
					
					coat_a_mater=popStr
					coat_a_rho=NumberByKey(coat_a_mater, List_matDen)
					coat_a_E_modulus=NumberByKey(coat_a_mater, List_matE)
					coat_a_G_modulus=NumberByKey(coat_a_mater, List_matG)

				break
				
				case "Material_tb_tab0":

					SVAR/SDFR=dfcal coat_b_mater
					NVAR/SDFR=dfcal coat_b_rho
					NVAR/SDFR=dfcal coat_b_E_modulus
					NVAR/SDFR=dfcal coat_b_G_modulus
					
					coat_b_mater=popStr
					coat_b_rho=NumberByKey(coat_b_mater, List_matDen)
					coat_b_E_modulus=NumberByKey(coat_b_mater, List_matE)
					coat_b_G_modulus=NumberByKey(coat_b_mater, List_matG)

				break
				
			endswitch
			
			string S_popmenu=Get_S_popmenu(popStr, pa.ctrlName, pa.win)
			PopupMenu $pa.ctrlName,value= #S_popmenu

			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function SliderProc_UpdateBackScale(sa) : SliderControl
	STRUCT WMSliderAction &sa

	switch( sa.eventCode )
		case -3: // Control received keyboard focus
		case -2: // Control lost keyboard focus
		case -1: // Control being killed
			break
		default:

			if( sa.eventCode & 1 ) // value set
				Variable curval = sa.curval
				
				DFREF dfcal=root:Packages:AFM_Calibration:
				NVAR/SDFR=dfcal V_BackScale
				NVAR/SDFR=dfcal use_ScaleBack
				V_BackScale=10^(curval)
				
				if(use_ScaleBack)
					Update_BackGrnd()
				endif
			endif

			if( sa.eventCode & 4 ) // value set
				Update_CurrentPeak()
			endif

			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function SetVarProc_UpdateBackScale(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval

			DFREF dfcal=root:Packages:AFM_Calibration:
			NVAR/SDFR=dfcal V_BackScaleLog
			NVAR/SDFR=dfcal use_ScaleBack

			V_BackScaleLog=log(dval)

			if(use_ScaleBack)
				Update_BackGrnd()
				Update_CurrentPeak()
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
Function PopMenuProc_SelectLoadType(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			
			DFREF dfcal=root:Packages:AFM_Calibration:

			SVAR/SDFR=dfcal Data2Load
			Data2Load=popStr

			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ButtonProc_SaveFit(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			DFREF dfcal=root:Packages:AFM_Calibration:

			SVAR/SDFR=dfcal DF_SavCal
			
			if(strlen(DF_SavCal)==0)
				DF_SavCal="SavedCal"
			endif
			NewDataFolder/O/S root:SavedCal
			string newDF=UniqueName(DF_SavCal,11,0)
			newDF=CleanUpName(newDF,0)
			DuplicateDataFolder dfcal, root:SavedCal:$newDF
			SetDataFolder root:

			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ButtonProc_DeleteFit(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here

			DFREF dfcal=root:Packages:AFM_Calibration:
			SVAR/SDFR=dfcal DF_LoadCal
			SVAR/SDFR=dfcal CurrentGraph
			
			if(strlen(DF_LoadCal))
				if(DataFolderExists("root:SavedCal:"+DF_LoadCal)==0)
					Abort "Select saved calibration folder."
				endif
			endif
			
			ZapDataInFolderTree("root:SavedCal:"+DF_LoadCal)
			KillDataFolder $("root:SavedCal:"+DF_LoadCal)

			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ButtonProc_LoadFit(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here

			DFREF dfcal=root:Packages:AFM_Calibration:
			SVAR/SDFR=dfcal Data2Load
			
			strswitch(Data2Load)
			
				case "all":
					LoadCalibration_All()
				break
			
			
				case "fvac":
					LoadCalibration_ResFreq()				
				break

				case "background":
					LoadCalibration_Background()
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
Function LoadCalibration_All()


	DFREF dfcal=root:Packages:AFM_Calibration:
	SVAR/SDFR=dfcal DF_LoadCal
	SVAR/SDFR=dfcal CurrentGraph
	variable RecreatePSD=0
	string new_DF_LoadCal=DF_LoadCal
	
	if(strlen(DF_LoadCal))
		if(DataFolderExists("root:SavedCal:"+DF_LoadCal)==0)
			Abort "Calibration data folder ["+DF_LoadCal+"] not found."
		endif
	endif
	
	SetDataFolder root:packages:
	DoWindow/K Panel_Cal
	DoWindow/K $CurrentGraph
	if(V_flag==1)
		RecreatePSD=1
	endif
	
	String S_winlist = WinList("*", ";","WIN:3")
	string win="", S_wavelist=""
	
	variable i,j
	
	SetDataFolder AFM_Calibration
	for(i=0;i<ItemsInList(S_winlist);i+=1)
		win=StringFromList(i, S_winlist)
		S_wavelist=WaveList("*", ";","WIN:"+win)
		if(ItemsInList(S_wavelist)>=1)
			KillWindow /Z $win
			//S_winlist=RemoveFromList(win, S_winlist)
		endif
	endfor
	
	SetDataFolder Results
	for(i=0;i<ItemsInList(S_winlist);i+=1)
		win=StringFromList(i, S_winlist)
		S_wavelist=WaveList("*", ";","WIN:"+win)
		if(ItemsInList(S_wavelist)>=1)
			KillWindow /Z $win
			//S_winlist=RemoveFromList(win, S_winlist)
		endif
	endfor

	SetDataFolder root:packages:
	RenameDataFolder dfcal, AFM_Cal_old
	
	DuplicateDataFolder root:SavedCal:$DF_LoadCal, root:packages:AFM_Calibration

	ZapDataInFolderTree("root:Packages:AFM_Cal_old")
	KillDataFolder AFM_Cal_old

	SetDataFolder root:

	DFREF dfcal=root:Packages:AFM_Calibration:
	SVAR/SDFR=dfcal DF_LoadCal
	// update loaded calibration folder
	DF_LoadCal=new_DF_LoadCal
	SVAR/SDFR=dfcal CurrentGraph
	SVAR/SDFR=dfcal PSD
	
	wave wPSD=$PSD

	if(RecreatePSD)
		Display wPSD
		DoWindow/C $CurrentGraph
		
		ModifyGraph/W=$CurrentGraph/Z log=1,mirror=2
		Label left "PSD (V\\S2\\M/Hz)"
		Label bottom "Frequency"
	endif
	
	NVAR/SDFR=dfcal cursors_checked
	cursors_checked=0
	NVAR/SDFR=dfcal currentpeak_checked
	currentpeak_checked=0
	NVAR/SDFR=dfcal fit_checked
	fit_checked=0


	MakeTabbedPanel()


end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function LoadCalibration_ResFreq()
	
	DFREF dfSav = GetDataFolderDFR()
	
	DFREF dfcal=root:Packages:AFM_Calibration:
	SetDataFolder dfcal
	SVAR model
	NVAR current_peak
	NVAR num_peaks
	SVAR DF_LoadCal
	
	DFREF savCal=root:SavedCal:$(DF_LoadCal)
	
	if(DataFolderExists("root:SavedCal:"+DF_LoadCal)==0)
		SetDataFolder dfSav
		Abort "Calibration data folder ["+DF_LoadCal+"] not found."
	endif
	
	wave/SDFR=savCal wfvac

	variable i=1
	
	for(i=1;i<num_peaks+1;i+=1)
		wave/T list= $("PeakCoef_list"+num2str(i))
		list[1][1]=num2str(wfvac[i-1])
	endfor
		
	SetDataFolder dfSav

End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function LoadCalibration_Background()


	DFREF dfcal=root:Packages:AFM_Calibration:
	SVAR/SDFR=dfcal DF_LoadCal
	SVAR/SDFR=dfcal model_Back
	
	if(strlen(DF_LoadCal))
		if(DataFolderExists("root:SavedCal:"+DF_LoadCal)==0)
			Abort "Calibration data folder ["+DF_LoadCal+"] not found."
		endif
	endif
	
	DFREF savCal=root:SavedCal:$(DF_LoadCal)
	SVAR/SDFR=savCal Sav_model_Back=model_Back
	
	model_Back=Sav_model_Back
	PopupMenu popup_back_tab1,win=Panel_Cal, mode=(WhichListItem(model_Back,"constant;line;poly 3;poly 4;poly 5;poly 7;poly 9;poly 13;poly 19;lor;power;exp;")+1),popvalue=model_Back
	
	//wave/SDFR=savCal BkgdCoef_list
	
	Duplicate/O savCal:BkgdCoef, dfcal:BkgdCoef
	Duplicate/O savCal:BkgdCoef_list, dfcal:BkgdCoef_list
	Duplicate/O savCal:BkgdCoef_list_Sel, dfcal:BkgdCoef_list_Sel
	
	Duplicate/O savCal:BkgdCoef_1overf, dfcal:BkgdCoef_1overf
	Duplicate/O savCal:BkgdCoef_1overf_list, dfcal:BkgdCoef_1overf_list
	Duplicate/O savCal:BkgdCoef_1overf_list_Sel, dfcal:BkgdCoef_1overf_list_Sel
	
	

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function PopMenuProc_SelectSavCal(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr

			DFREF dfcal=root:Packages:AFM_Calibration:

			SVAR/SDFR=dfcal DF_LoadCal
			DF_LoadCal=popStr

			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function PopMenuProc_SelectDelCal(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr

			DFREF dfcal=root:Packages:AFM_Calibration:

			SVAR/SDFR=dfcal DF_DeleteCal
			DF_DeleteCal=popStr

			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function/S List_DFSavedCal()

	string DF_list=StringByKey("FOLDERS",DataFolderDir(1,root:SavedCal))
	DF_list=ReplaceString(",",DF_List,";")
	DF_list=SortList(DF_list, ";")
	
	return DF_List

	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ZapDataInFolderTree(path)
	String path

	DFREF saveDF = GetDataFolderDFR()
	SetDataFolder path

	KillWaves/A/Z
	KillVariables/A/Z
	KillStrings/A/Z

	Variable i
	Variable numDataFolders = CountObjects(":",4)
	for(i=0; i<numDataFolders; i+=1)
		String nextPath = GetIndexedObjName(":",4,i)
		ZapDataInFolderTree(nextPath)
	endfor

	SetDataFolder saveDF
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function CheckProc_CheckGammaNormModeSelect(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			
			print "WARNING: Gamma changed. Run new fit to update gamma values, peak parameters, and errors." 
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function CheckProc_fixMTF(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			
			DFREF dfSav = GetDataFolderDFR()

			DFREF dfcal=root:Packages:AFM_Calibration:
			SetDataFolder dfcal
			
			SVAR PSD=dfcal:PSD
			wave wPSD=$PSD
			
			
			if(checked)

				SVAR model=dfcal:model
				SVAR model_Back=dfcal:model_Back
				SVAR CurrentGraph=dfcal:CurrentGraph
				NVAR V_BackScale=dfcal:V_BackScale
		
				DoWindow/F $CurrentGraph
	
				if(V_flag==0)
					NVAR Detect_MTF_fix
					Detect_MTF_fix=0
					SetDataFolder dfSav
					Abort "Graph not displayed." 
					return 1
				endif
	
				wave BkgdCoef
				
				Duplicate/O wPSD, $(PSD+"_Sav")
				wave wPSDSav=$(PSD+"_Sav")
				Duplicate/O wPSD, AdjBack
				wave AdjBack
				
				Make_Bkgd(model_Back, BkgdCoef, AdjBack, BkgdCoef, 0, V_BackScale)
				
				wPSD=wPSDSav*AdjBack[0]/AdjBack
				
			else
			
				wave wPSDSav=$(PSD+"_Sav")
				Duplicate/O wPSDSav, wPSD				
				
			endif

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
Function PopMenuProc_ProbeVendor(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr

			string S_popmenu=Get_S_popmenu(popStr, pa.ctrlName, pa.win)
			PopupMenu $pa.ctrlName,value= #S_popmenu
			
			SVAR vendor=root:packages:AFM_Calibration:vendor
			vendor=popStr

			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function PopMenuProc_ProbeModel(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr

			string S_popmenu=Get_S_popmenu(popStr, pa.ctrlName, pa.win)
			PopupMenu $pa.ctrlName,value= #S_popmenu

			SVAR ProbeModel=root:packages:AFM_Calibration:ProbeModel
			ProbeModel=popStr

			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ButtonProc_LoadDBProbeParams(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Calc_Kappa()

	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:packages:AFM_Calibration:

	SVAR spectrum_type
	NVAR cant_width
	NVAR cant_length_e
	NVAR current_peak
	
	variable kappa=cant_width/cant_length_e

	strswitch(spectrum_type)
	
		case "normal":
			kappa*=C_n(current_peak)
		break
	
		case "lateral":
			kappa*=D_n(current_peak)
		break
	endswitch

	SetDataFolder fldrSav0

	return kappa

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
// returns point number for the x value in the lookup table for gamma 
Function Calc_NormP(kappa)
	variable kappa
	
	make/O/N=12 wkappa, wkappaP
	
	wkappaP=p
	wkappa={0,0.125,0.25,0.5,0.75,1,2,3,5,7,10,20}
	
//	Interpolate2/T=2/N=200/E=2/Y=wkappaP_CS wkappa, wkappaP
//	return wkappaP_CS(kappa)
	
	return interp(kappa, wkappa, wkappaP)
	
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function/C Calc_Gamma2(type, kappa, use_fitted_Coef, XL, XR, fitType, delta_max)
	string type
	variable  kappa, use_fitted_Coef, XL, XR, fitType, delta_max

	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:packages:AFM_Calibration:
	
	// set number of points near original resolution in Sader paper (N=17)
	variable NOP=round((XR-XL)/0.5)+1
	Make/O/N=(NOP) wGimag, wGreal
	Make/O/N=(NOP) wRe, wDel, wReLog
	
	// Sader data go from log(Re)=-4 to +4
	SetScale/I  x, XL, XR, wRe
	CopyScales/I wRe, wGimag, wGreal 
	CopyScales/I wRe, wDel

	wRe=10^(x)
	wDel=sqrt(2/wRe)
	
	variable pNum=Calc_NormP(kappa)
	
	variable pMax=0
	variable pMin=NOP-1

	FindLevel/P/Q/R=(XL,XR) wDel, delta_max
	if(V_flag==0)
		pMax=V_levelX
	endif
	
	variable chisqIm, chisqRe

	strswitch(type)
	
		case "normal":
			wave GammaFvs_Re_modeIm
			wave GammaFvs_Re_modeRe
			wGimag=Interp2D(GammaFvs_Re_modeIm,x,pNum)
			wGreal=Interp2D(GammaFvs_Re_modeRe,x,pNum)
			
			Duplicate/O wGimag, wGimagWeight
			Duplicate/O wGreal, wGrealWeight
			Duplicate/O wGimag, fit_wGimag
			Duplicate/O wGreal, fit_wGreal
			Variable/G V_FitTol=0.00001


			switch(fitType)
			
				case 1:
	
					Make/O/N=5/D wGi_coef
		
					wGi_coef[0] = {0,4,2,0,0}
	
					FuncFit/Q/H="10011" funcGimag, kwCWave=wGi_coef, wGimag[pMin,pMax] /X=wDel /W=wGimagWeight /I=1
					Make/O/N=1/T T_Constraints={"K0 > 0"}
					FuncFit/Q/H="00011" funcGimag, kwCWave=wGi_coef, wGimag[pMin,pMax] /X=wDel /W=wGimagWeight /I=1 /C=T_Constraints
					Make/O/N=2/T T_Constraints={"K0 > 0", "K3 > 0"}
					FuncFit/Q/H="00001" funcGimag, kwCWave=wGi_coef, wGimag[pMin,pMax] /X=wDel /W=wGimagWeight /I=1 /C=T_Constraints
					Make/O/N=3/T T_Constraints={"K0 > 0", "K3 > 0", "K4 > 0"}
					FuncFit/Q/H="00000" funcGimag, kwCWave=wGi_coef, wGimag[pMin,pMax] /X=wDel /W=wGimagWeight /I=1 /C=T_Constraints
		
//					FuncFit/Q/H="10011" funcGimag, kwCWave=wGi_coef, wGimag[pMin,pMax] /X=wDel /W=wGimagWeight /I=1
//					Make/O/N=1/T T_Constraints={"K3 > 0"}
//					FuncFit/Q/H="10001" funcGimag, kwCWave=wGi_coef, wGimag[pMin,pMax] /X=wDel /W=wGimagWeight /I=1 /C=T_Constraints
//					Make/O/N=2/T T_Constraints={"K3 > 0", "K4 > 0"}
//					FuncFit/Q/H="10000" funcGimag, kwCWave=wGi_coef, wGimag[pMin,pMax] /X=wDel /W=wGimagWeight /I=1 /C=T_Constraints

					chisqIm=V_chisq
					wGi_coef=wGi_coef[p]>1e-6 ? wGi_coef[p] : 0
					fit_wGimag=funcGimag(wGi_coef, wDel)

					Make/O/N=5/D wGr_coef
					wGr_coef[0] = {1,4,0.1,0,0}
	
					FuncFit/Q/H="00111" funcGreal, kwCWave=wGr_coef, wGreal[pMin,pMax] /X=wDel /W=wGrealWeight /I=1 
					FuncFit/Q/H="00011" funcGreal, kwCWave=wGr_coef, wGreal[pMin,pMax] /X=wDel /W=wGrealWeight /I=1 
					FuncFit/Q/H="00001" funcGreal, kwCWave=wGr_coef, wGreal[pMin,pMax] /X=wDel /W=wGrealWeight /I=1 
					Make/O/N=3/T T_Constraints={"K2 > 0", "K3 > 0", "K4 > 0"}
					FuncFit/Q/H="00000" funcGreal, kwCWave=wGr_coef, wGreal[pMin,pMax] /X=wDel /W=wGrealWeight /I=1 /C=T_Constraints
		
					chisqRe=V_chisq
					wGr_coef=wGr_coef[p]>1e-6 ? wGr_coef[p] : 0
					fit_wGreal=funcGreal(wGr_coef, wDel)

				break

				case 2:

					Make/O/N=5/D wGi_coef
		
					if(kappa<0.2)
						wGi_coef[0] = {4,2,0.2,0.02,2}
					else
						wGi_coef[0] = {4.5,2.5,2,0.8,2}
					endif
					FuncFit/Q/H="00111" funcGimag2, kwCWave=wGi_coef, wGimag[pMin,pMax] /X=wDel /W=wGimagWeight /I=1
					FuncFit/Q/H="00011" funcGimag2, kwCWave=wGi_coef, wGimag[pMin,pMax] /X=wDel /W=wGimagWeight /I=1
					FuncFit/Q/H="00001" funcGimag2, kwCWave=wGi_coef, wGimag[pMin,pMax] /X=wDel /W=wGimagWeight /I=1
					FuncFit/Q/H="00000" funcGimag2, kwCWave=wGi_coef, wGimag[pMin,pMax] /X=wDel /W=wGimagWeight /I=1
	
					chisqIm=V_chisq
					wGi_coef=wGi_coef[p]>1e-6 ? wGi_coef[p] : 0
					fit_wGimag=funcGimag2(wGi_coef, wDel)
	
					Make/O/N=5/D wGr_coef
	
					if(kappa<0.2)
						wGr_coef[0] = {1,4,0.1,0.1,2}
					else
						wGr_coef[0] = {1,4,1,1,2}
					endif
					FuncFit/Q/H="00111" funcGreal2, kwCWave=wGr_coef, wGreal[pMin,pMax] /X=wDel /W=wGrealWeight /I=1
					FuncFit/Q/H="00011" funcGreal2, kwCWave=wGr_coef, wGreal[pMin,pMax] /X=wDel /W=wGrealWeight /I=1
					FuncFit/Q/H="00001" funcGreal2, kwCWave=wGr_coef, wGreal[pMin,pMax] /X=wDel /W=wGrealWeight /I=1
					FuncFit/Q/H="00000" funcGreal2, kwCWave=wGr_coef, wGreal[pMin,pMax] /X=wDel /W=wGrealWeight /I=1
		
				
					chisqRe=V_chisq
					wGr_coef=wGr_coef[p]>1e-6 ? wGr_coef[p] : 0
					fit_wGreal=funcGreal2(wGr_coef, wDel)

				break
				
				case 3:

					Make/O/N=4/D wGi_coef
		
					wGi_coef[0] = {0,4,2,0}

					CurveFit/Q/H="1001" poly 4, kwCWave=wGi_coef, wGimag[pMin,pMax] /X=wDel /W=wGimagWeight /I=1
					//CurveFit/Q/H="1001" poly 4, kwCWave=wGi_coef, wGimag[pMin,pMax] /X=wDel
	
					chisqIm=V_chisq
					wGi_coef=wGi_coef[p]>1e-6 ? wGi_coef[p] : 0
					fit_wGimag=poly(wGi_coef, wDel)
	
					Make/O/N=4/D wGr_coef
	
					wGr_coef[0] = {1,4,0,0}

					CurveFit/Q/H="0011" poly 4, kwCWave=wGr_coef, wGreal[pMin,pMax] /X=wDel /W=wGrealWeight /I=1
					//CurveFit/Q/H="0011" poly 4, kwCWave=wGr_coef, wGreal[pMin,pMax] /X=wDel
						
					chisqRe=V_chisq
					wGr_coef=wGr_coef[p]>1e-6 ? wGr_coef[p] : 0
					fit_wGreal=poly(wGr_coef, wDel)

				break

				case 4:

					Make/O/N=4/D wGi_coef
		
					wGi_coef[0] = {0,4,2,-0.001}

					CurveFit/Q/H="0000" poly 4, kwCWave=wGi_coef, wGimag[pMin,pMax] /X=wDel /W=wGimagWeight /I=1
					//CurveFit/Q/H="0000" poly 4, kwCWave=wGi_coef, wGimag[pMin,pMax] /X=wDel
	
					chisqIm=V_chisq
					//wGi_coef=wGi_coef[p]>1e-6 ? wGi_coef[p] : 0
					fit_wGimag=poly(wGi_coef, wDel)
	
					Make/O/N=4/D wGr_coef
	
					wGr_coef[0] = {1,4,0.3,0}

					CurveFit/Q/H="0000" poly 4, kwCWave=wGr_coef, wGreal[pMin,pMax] /X=wDel /W=wGrealWeight /I=1
						
					chisqRe=V_chisq
					//wGr_coef=wGr_coef[p]>1e-6 ? wGr_coef[p] : 0
					fit_wGreal=poly(wGr_coef, wDel)

				break

			endswitch
			
			break
			
		case "lateral":
			wave GammaTvs_Re_modeIm
			wave GammaTvs_Re_modeRe
			wGimag=Interp2D(GammaTvs_Re_modeIm,x,pNum)
			wGreal=Interp2D(GammaTvs_Re_modeRe,x,pNum)
			
			Duplicate/O wGimag, wGimagWeight
			Duplicate/O wGreal, wGrealWeight
			
			Variable/G V_FitTol=0.00001

			switch(fitType)
			
				case 1:
		
					Make/O/N=5/D wGi_coef

					wGi_coef[0] = {0,2.5,8,2,2}
					FuncFit/Q/H="10011" funcGimag, kwCWave=wGi_coef, wGimag[pMin,pMax] /X=wDel /W=wGimagWeight /I=1 
					FuncFit/Q/H="10001" funcGimag, kwCWave=wGi_coef, wGimag[pMin,pMax] /X=wDel /W=wGimagWeight /I=1 
					FuncFit/Q/H="10000" funcGimag, kwCWave=wGi_coef, wGimag[pMin,pMax] /X=wDel /W=wGimagWeight /I=1 
					Make/O/N=3/T T_Constraints={"K0 > 0", "K3 > 0", "K4 > 0"}
					FuncFit/Q/H="00000" funcGimag, kwCWave=wGi_coef, wGimag[pMin,pMax] /X=wDel /W=wGimagWeight /I=1 /C=T_Constraints 
//					Make/O/N=2/T T_Constraints={"K3 > 0", "K4 > 0"}
//					FuncFit/Q/H="10000" funcGimag, kwCWave=wGi_coef, wGimag[pMin,pMax] /X=wDel /W=wGimagWeight /I=1 /C=T_Constraints 
		
					Duplicate/O wGimag, fit_wGimag
	
					chisqIm=V_chisq
					wGi_coef=wGi_coef[p]>1e-6 ? wGi_coef[p] : 0
					fit_wGimag=funcGimag(wGi_coef, wDel)

					Make/O/N=5/D wGr_coef
		
					wGr_coef[0] = {0,2,2,2,2}
					FuncFit/Q/H="00111" funcGreal, kwCWave=wGr_coef, wGreal[pMin,pMax] /X=wDel /W=wGrealWeight /I=1 
					FuncFit/Q/H="00011" funcGreal, kwCWave=wGr_coef, wGreal[pMin,pMax] /X=wDel /W=wGrealWeight /I=1 
					FuncFit/Q/H="00001" funcGreal, kwCWave=wGr_coef, wGreal[pMin,pMax] /X=wDel /W=wGrealWeight /I=1 
					Make/O/N=3/T T_Constraints={"K2 > 0", "K3 > 0", "K4 > 0"}
					FuncFit/Q/H="00000" funcGreal, kwCWave=wGr_coef, wGreal[pMin,pMax] /X=wDel /W=wGrealWeight /I=1 /C=T_Constraints
		
					Duplicate/O wGimag, fit_wGreal

					chisqRe=V_chisq
					wGr_coef=wGr_coef[p]>1e-6 ? wGr_coef[p] : 0
					fit_wGreal=funcGreal(wGr_coef, wDel)
	
				break

				case 2:

					Make/O/N=5/D wGi_coef
		
					wGi_coef[0] = {2.5,8,1,2,2}
					FuncFit/Q/H="00000" funcGimag2, kwCWave=wGi_coef, wGimag[pMin,pMax] /X=wDel /W=wGimagWeight /I=1 
	
					Duplicate/O wGimag, fit_wGimag
	
					chisqIm=V_chisq
					wGi_coef=wGi_coef[p]>1e-6 ? wGi_coef[p] : 0
					fit_wGimag=funcGimag2(wGi_coef, wDel)
		
					Make/O/N=5/D wGr_coef
	
					wGr_coef[0] = {0,2,0.9,2,2}
					FuncFit/Q/H="00000" funcGreal2, kwCWave=wGr_coef, wGreal[pMin,pMax] /X=wDel /W=wGrealWeight /I=1
		
					Duplicate/O wGimag, fit_wGreal

					chisqRe=V_chisq
					wGr_coef=wGr_coef[p]>1e-6 ? wGr_coef[p] : 0
					fit_wGreal=funcGreal2(wGr_coef, wDel)
				
				break
						
				case 3:

					Make/O/N=4/D wGi_coef
		
					wGi_coef[0] = {0,2,8,0}

					CurveFit/Q/H="1001" poly 4, kwCWave=wGi_coef, wGimag[pMin,pMax] /X=wDel /W=wGimagWeight /I=1
	
					chisqIm=V_chisq
					//wGi_coef=wGi_coef[p]>1e-6 ? wGi_coef[p] : 0
					fit_wGimag=poly(wGi_coef, wDel)
	
					Make/O/N=4/D wGr_coef
	
					wGr_coef[0] = {1,4,0,0}

					CurveFit/Q/H="0011" poly 4, kwCWave=wGr_coef, wGreal[pMin,pMax] /X=wDel /W=wGrealWeight /I=1
						
					chisqRe=V_chisq
					//wGr_coef=wGr_coef[p]>1e-6 ? wGr_coef[p] : 0
					fit_wGreal=poly(wGr_coef, wDel)

				break

				case 4:

					Make/O/N=4/D wGi_coef
		
					wGi_coef[0] = {0,2,8,-0.001}

					CurveFit/Q/H="0000" poly 4, kwCWave=wGi_coef, wGimag[pMin,pMax] /X=wDel /W=wGimagWeight /I=1
	
					chisqIm=V_chisq
					//wGi_coef=wGi_coef[p]>1e-6 ? wGi_coef[p] : 0
					fit_wGimag=poly(wGi_coef, wDel)
	
					Make/O/N=4/D wGr_coef
	
					wGr_coef[0] = {1,4,0.3,0}

					CurveFit/Q/H="0000" poly 4, kwCWave=wGr_coef, wGreal[pMin,pMax] /X=wDel /W=wGrealWeight /I=1
						
					chisqRe=V_chisq
					//wGr_coef=wGr_coef[p]>1e-6 ? wGr_coef[p] : 0
					fit_wGreal=poly(wGr_coef, wDel)

				break

			endswitch
			
			break
			
	endswitch
	
	duplicate/O wGimag, wGimagErr
	wGimagErr=abs(wGimag-fit_wGimag)/wGimag
	if(pMax>0)
		wGimagErr[0,pMax]=NaN
	endif
	WaveStats/Q wGimagErr
	
	variable/G V_GimagErr_avg=V_avg
	variable/G V_GimagErr_max=V_max
	
	duplicate/O wGreal, wGrealErr
	wGrealErr=abs(wGreal-fit_wGreal)/wGreal
	if(pMax>0)
		wGrealErr[0,pMax]=NaN
	endif
	WaveStats/Q wGrealErr
	
	variable/G V_GrealErr_avg=V_avg
	variable/G V_GrealErr_max=V_max
		
	SetDataFolder fldrSav0
	
	return cmplx(chisqIm, chisqRe)
	
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Calc_GammaCoeff(type, fitType, V_delta_max)
	string type
	variable fitType, V_delta_max

	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:packages:AFM_Calibration:

	Make/N=12/O wkappa
	wkappa={0,0.125,0.25,0.5,0.75,1,2,3,5,7,10,20}

	variable i

	strswitch(type)
	
		case "normal":
			Make/N=12/O wGicoef0F, wGicoef1F, wGicoef2F, wGicoef3F, wGicoef4F
			Make/N=12/O wGrcoef0F, wGrcoef1F, wGrcoef2F, wGrcoef3F, wGrcoef4F
			Make/N=12/O wGiErr_avg, wGrErr_avg, wGiErr_max, wGrErr_max 
			Make/N=12/O/C wchisqF
			for(i=0;i<12;i+=1)
				wchisqF[i]=Calc_Gamma2(type, wkappa[i],0,-4,4,fitType, V_delta_max)
				wave wGi_coef
				wGicoef0F[i]=wGi_coef[0]
				wGicoef1F[i]=wGi_coef[1]
				wGicoef2F[i]=wGi_coef[2]
				wGicoef3F[i]=wGi_coef[3]
				wGicoef4F[i]=wGi_coef[4]
				NVAR V_GimagErr_avg
				NVAR V_GimagErr_max
				wGiErr_avg[i]=V_GimagErr_avg
				wGiErr_max[i]=V_GimagErr_max

				wave wGr_coef
				wGrcoef0F[i]=wGr_coef[0]
				wGrcoef1F[i]=wGr_coef[1]
				wGrcoef2F[i]=wGr_coef[2]
				wGrcoef3F[i]=wGr_coef[3]
				wGrcoef4F[i]=wGr_coef[4]
				NVAR V_GrealErr_avg
				NVAR V_GrealErr_max
				wGrErr_avg[i]=V_GrealErr_avg
				wGrErr_max[i]=V_GrealErr_max
			endfor
			
		break
		
		case "lateral":
			Make/N=12/O wGicoef0T, wGicoef1T, wGicoef2T, wGicoef3T, wGicoef4T
			Make/N=12/O wGrcoef0T, wGrcoef1T, wGrcoef2T, wGrcoef3T, wGrcoef4T
			Make/N=12/O wGiErr_avg, wGrErr_avg, wGiErr_max, wGrErr_max 
			Make/N=12/O/C wchisqT
			for(i=0;i<12;i+=1)
				wchisqT[i]=Calc_Gamma2(type, wkappa[i],0,-4,4,fitType, V_delta_max)
				wave wGi_coef
				wGicoef0T[i]=wGi_coef[0]
				wGicoef1T[i]=wGi_coef[1]
				wGicoef2T[i]=wGi_coef[2]
				wGicoef3T[i]=wGi_coef[3]
				wGicoef4T[i]=wGi_coef[4]
				NVAR V_GimagErr_avg
				NVAR V_GimagErr_max
				wGiErr_avg[i]=V_GimagErr_avg
				wGiErr_max[i]=V_GimagErr_max

				wave wGr_coef
				wGrcoef0T[i]=wGr_coef[0]
				wGrcoef1T[i]=wGr_coef[1]
				wGrcoef2T[i]=wGr_coef[2]
				wGrcoef3T[i]=wGr_coef[3]
				wGrcoef4T[i]=wGr_coef[4]
				NVAR V_GrealErr_avg
				NVAR V_GrealErr_max
				wGrErr_avg[i]=V_GrealErr_avg
				wGrErr_max[i]=V_GrealErr_max
			endfor
			
		break
				
	endswitch

	SetDataFolder fldrSav0
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Calc_Err()

	NVAR V_GrealErr_avg
	NVAR V_GrealErr_max
	NVAR V_GimagErr_avg
	NVAR V_GimagErr_max

	print "Err(Re): avg =", V_GrealErr_avg
	print "Err(Im): avg =", V_GimagErr_avg
	print "Err(Re): max =", V_GrealErr_max
	print "Err(Im): max =", V_GimagErr_max


end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function PlotGamma() : Graph

	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:packages:AFM_Calibration:
	
	wave/Z wGimag,wGreal
	if(WaveExists(wGimag)==0)
		Abort "Calculate Hydrodynamic function first."
	endif
	
	NVAR medium_visc
	NVAR medium_dens
	NVAR cant_width

	wave wRe, wDel
	
	Duplicate/O wRe, wFreq
	wave wFreq
	wFreq=wRe/(2*pi*medium_dens*cant_width^2/medium_visc)
//	wFreq=(2/wDel^2)/(2*pi*medium_dens*cant_width^2/medium_visc)

	NVAR g_Option

	
	Display/K=1 /W=(646,66,1146,408) 
	ControlInfo/W=Panel_Cal GammaX_tab2
	
	strswitch(S_Value)
	
		case "ν":
			//AppendToGraph wGimag,wGreal
			AppendToGraph wGimag vs wFreq
			AppendToGraph wGreal vs wFreq
			ModifyGraph mirror=2
			ModifyGraph lSize=2
			ModifyGraph grid=1
			Label bottom "Frequency (Hz)"
		break
		
		
		case "Re":
			AppendToGraph wGimag vs wRe
			AppendToGraph wGreal vs wRe
			
//			if(g_Option==1)
				wave fit_wGreal, fit_wGimag
				AppendToGraph fit_wGreal vs wRe
				AppendToGraph fit_wGimag vs wRe
				ModifyGraph lSize(fit_wGreal)=2,lSize(fit_wGimag)=2
				ModifyGraph rgb(fit_wGimag)=(0,0,65535)
				ModifyGraph mode(wGimag)=3,mode(wGreal)=3
//			else
//				ModifyGraph mode(wGimag)=4,mode(wGreal)=4
//			endif
			
			AppendToGraph/T=FreqAxis wGimag vs wFreq
			ModifyGraph mirror(left)=2
			ModifyGraph margin(top)=54
			ModifyGraph marker(wGimag)=19,marker(wGreal)=8
			ModifyGraph lSize=2, mrkThick=2, msize=2
			ModifyGraph opaque(wGreal)=1,lstyle(wGreal)=3
			ModifyGraph grid(left)=1,grid(bottom)=1
			ModifyGraph lSize(wGimag#1)=0
			ModifyGraph lblPos(FreqAxis)=48
			ModifyGraph freePos(FreqAxis)=2
			ModifyGraph grid(left)=1,grid(bottom)=1
			Label bottom "Reynolds number"
			Label FreqAxis "Frequency (Hz)"
		break
		
		
		case "δ":
			AppendToGraph wGimag vs wDel
			AppendToGraph wGreal vs wDel

//			if(g_Option==1)
				wave fit_wGreal, fit_wGimag
				AppendToGraph fit_wGreal vs wDel
				AppendToGraph fit_wGimag vs wDel
				ModifyGraph lSize(fit_wGreal)=2,lSize(fit_wGimag)=2
				ModifyGraph lstyle(fit_wGreal)=3
				ModifyGraph rgb(fit_wGimag)=(0,0,65535)
				ModifyGraph mode(wGimag)=3,mode(wGreal)=3
//			else
//				ModifyGraph mode(wGimag)=4,mode(wGreal)=4
//			endif
			
			AppendToGraph/T=FreqAxis wGimag vs wFreq
			ModifyGraph mirror(left)=2
			ModifyGraph margin(top)=54
			ModifyGraph marker(wGimag)=19,marker(wGreal)=8
			ModifyGraph lSize=2, mrkThick=2, msize=2
			ModifyGraph opaque(wGreal)=1,lstyle(wGreal)=3
			ModifyGraph lSize(wGimag#1)=0
			ModifyGraph lblPos(FreqAxis)=48
			ModifyGraph freePos(FreqAxis)=2
			ModifyGraph grid(left)=1,grid(bottom)=1
			Label bottom "δ=(2μ/ρωb\\S2\\M)\\S1/2"
			Label FreqAxis "Frequency (Hz)"
			SetAxis/A/R FreqAxis
		break
	
	endswitch
	
	ModifyGraph standoff=0
	ModifyGraph rgb(wGimag)=(1,16019,65535)
	ModifyGraph log=1
	ModifyGraph fSize=12
	ModifyGraph axOffset(left)=-1.14286,axOffset(bottom)=0.1875
	Label left "Hydrodyn. function Γ\\Br\\M\\s(wGreal),Γ\\Bi\\M\\s(wGimag)"

	SetDataFolder fldrSav0

End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ButtonProc_PlotGamma(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			PlotGamma()
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function PopMenuProc_FitType(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr

			DFREF dfcal=root:Packages:AFM_Calibration:

			NVAR/SDFR=dfcal fitType
			fitType=popNum
			SVAR/SDFR=dfcal GammafitType
			GammafitType=popStr
			
			string S_popmenu=Get_S_popmenu(popStr, pa.ctrlName, pa.win)
			PopupMenu $pa.ctrlName,value= #S_popmenu

			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ButtonProc_CalcGamma(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here

			String fldrSav0= GetDataFolder(1)
			SetDataFolder root:packages:AFM_Calibration:
			
			NVAR medium_visc
			NVAR medium_dens
			NVAR cant_width
			NVAR current_peak
			SVAR spectrum_type
			SVAR PSD
			NVAR G_option
			
			NVAR use_fixed_kappa
			NVAR kappa
			NVAR cant_kappa
			NVAR use_Fitted_Coef
			NVAR fitType
			NVAR V_delta_max
			
//			wave/Z wPSD=$PSD
//			
//			Wave/Z CurrentPeak
//			variable XL=leftx(wPSD)
//			variable XR=rightx(wPSD)
//			
//			if(WaveExists(CurrentPeak))
//				XL=leftx(CurrentPeak)
//				XR=rightx(CurrentPeak)
//			endif			
		
			if(use_fixed_kappa==0)
				kappa=cant_kappa
			endif
			
			Calc_Gamma2(spectrum_type, kappa, use_Fitted_Coef, -4, 4, fitType, V_delta_max)

			wave wRe
			Duplicate/O wRe, wFreq
			wFreq=wRe/(2*pi*medium_dens*cant_width^2/medium_visc)

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
Function ButtonProc_CalcGammaCoef(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			String fldrSav0= GetDataFolder(1)
			SetDataFolder root:packages:AFM_Calibration:
			
			SVAR spectrum_type
			NVAR fitType
			NVAR V_delta_max
			
			Calc_GammaCoeff(spectrum_type, fitType, V_delta_max)
			
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
Function ButtonProc_PlotCoef(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			
			ControlInfo/W=Panel_Cal coefList_tab2
			//SVAR S_Value
			
			PlotCoef(S_Value)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function PlotCoef(wnCoef)
	string wnCoef
	
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:packages:AFM_Calibration:
	
	wave wkappa
	wave/Z wCoef=$wnCoef
	wave/Z wfit_Coef=$("fit_"+wnCoef)
	
	if(WaveExists(wCoef)==0)
		SVAR spectrum_type		
	endif

	
	Display/K=1 wCoef vs wkappa
	ModifyGraph width={Aspect,1.75},height=216
	ModifyGraph mode($wnCoef)=3
	ModifyGraph marker($wnCoef)=19
	ModifyGraph msize($wnCoef)=2
	ModifyGraph mirror=2
	ModifyGraph standoff(left)=0

	variable strNP=strlen(wnCoef)-1
	strswitch(wnCoef[strNP,strNP])
	
		case "F":
				Label left "Coefficient a\\B"+wnCoef[7,7]
		
			break
	
		case "T":
				Label left "Coefficient b\\B"+wnCoef[7,7]
		
			break

	endswitch

	Label bottom "Normalized mode κ"
	
	SetDataFolder fldrSav0
			
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function CheckProc_AdjustQ(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			
			Update_SpringConst()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function CheckProc_UseNumericIntegral(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			
			Update_SpringConst()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ButtonProc_PlotErrorsGamma(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			GraphErr_vs_Delta()
			GraphErr_vs_Mode()
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function GraphErr_vs_Delta() : Graph
	PauseUpdate; Silent 1		// building window...
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:packages:AFM_Calibration:
	wave/Z wGimagErr,wGrealErr,wDel

	if(WaveExists(wGimagErr)==0)
		return 1
	endif

	Display/K=1 /W=(24.75,488,569.25,629.75) wGimagErr,wGrealErr vs wDel
	SetDataFolder fldrSav0
	ModifyGraph mode=4
	ModifyGraph marker=19
	ModifyGraph rgb(wGimagErr)=(0,0,65535)
	ModifyGraph log(bottom)=1
	Label left "Error"
	Label bottom "δ=(2μ/ρωb\\S2\\M)\\S1/2"
	SetAxis/A/E=1 left
EndMacro
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function GraphErr_vs_Mode() : Graph
	PauseUpdate; Silent 1		// building window...
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:packages:AFM_Calibration:
	wave/Z wGrErr_avg,wGiErr_avg,wkappa
	
	if(WaveExists(wGrErr_avg)==0)
		return 1
	endif
	
	Display/K=1 /W=(24,658.25,571.5,796.25) wGrErr_avg,wGiErr_avg vs wkappa
	SetDataFolder fldrSav0
	ModifyGraph mode=4
	ModifyGraph marker=19
	ModifyGraph rgb(wGiErr_avg)=(0,0,65535)
	ModifyGraph log(left)=1
	Label left "Error"
	Label bottom "Normalized mode number κ"
EndMacro
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ScaledPoly(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = poly(W,x)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients n


	variable nop=numpnts(w)
	
	Duplicate/O w, w_coefBack
	Redimension/N=(nop-1) w_coefBack
	
	
	return w[nop-1]*poly(w_coefBack,x)
	
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ScaledLine(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = c*(a+b*x)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 3
	//CurveFitDialog/ w[0] = a
	//CurveFitDialog/ w[1] = b
	//CurveFitDialog/ w[2] = c

	return w[2]*(w[0]+w[1]*x)
	
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ScaledExp(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = c*(y0+A*exp(-InvTau*x))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 4
	//CurveFitDialog/ w[0] = y0
	//CurveFitDialog/ w[1] = A
	//CurveFitDialog/ w[2] = InvTau
	//CurveFitDialog/ w[3] = c


	return w[3]*(w[0]+w[1]*exp(-w[2]*x))
	
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ScaledPower(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = c*(y0+A*x^p)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 4
	//CurveFitDialog/ w[0] = y0
	//CurveFitDialog/ w[1] = A
	//CurveFitDialog/ w[2] = p
	//CurveFitDialog/ w[3] = c


	return w[3]*(w[0]+w[1]*x^w[2])
	
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ExpParabola(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = y0+a1*exp(-tau1*x)+a2*exp(-tau2*x)+b*x+c*x^2
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 7
	//CurveFitDialog/ w[0] = y0
	//CurveFitDialog/ w[1] = a1
	//CurveFitDialog/ w[2] = tau1
	//CurveFitDialog/ w[3] = a2
	//CurveFitDialog/ w[4] = tau2
	//CurveFitDialog/ w[5] = b
	//CurveFitDialog/ w[6] = c

	return w[0]+w[1]*exp(-w[2]*x)+w[3]*exp(-w[4]*x)+w[5]*x+w[6]*x^2
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
// fit for Gi=b1*delta+b2*delta^2+b3*delta^3
// both Gi (y) and delta (x) are on a log scale to ensure
// better weighing for small values
Function funcGamma_i(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = x+log( b1+b2*10^x+b3*(10^x)^2)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 3
	//CurveFitDialog/ w[0] = b1
	//CurveFitDialog/ w[1] = b2
	//CurveFitDialog/ w[2] = b3

	return x+log( w[0]+w[1]*10^x+w[2]*(10^x)^2)
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function funcGamma_i2(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = b0+x+log( b1+b2*10^x+b3*(10^x)^2) 
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 4
	//CurveFitDialog/ w[0] = b0
	//CurveFitDialog/ w[1] = b1
	//CurveFitDialog/ w[2] = b2
	//CurveFitDialog/ w[3] = b3

	return w[0]+x+log( w[1]+w[2]*10^x+w[3]*(10^x)^2) 
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
/ fit for Gr=a1+a2*delta+a3*delta^2
// both Gr (y) and delta (x) are on a log scale to ensure
// better weighing for small values
Function funcGamma_r(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = x+log( b1+b2*10^x+b3*(10^x)^2)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 3
	//CurveFitDialog/ w[0] = a1
	//CurveFitDialog/ w[1] = a2
	//CurveFitDialog/ w[2] = a3

	return log(w[0]+w[1]*10^x+w[2]*(10^x)^2)
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function ExpLine(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = y0+a1*exp(-InvTau*x)+b*x
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 4
	//CurveFitDialog/ w[0] = y0
	//CurveFitDialog/ w[1] = a1
	//CurveFitDialog/ w[2] = tau
	//CurveFitDialog/ w[3] = b
	
	return w[0]+w[1]*exp(-w[2]*x)+w[3]*x
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function PowerXOffset(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = y0+a1*(x-x0)^p1
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 4
	//CurveFitDialog/ w[0] = y0
	//CurveFitDialog/ w[1] = a1
	//CurveFitDialog/ w[2] = p1
	//CurveFitDialog/ w[3] = x0

	return w[0]+w[1]*(x-w[3])^w[2]
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function PowerXoffset2Terms(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = y0+A*(x-x0)^p1+B*(x-x0)^p2
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 6
	//CurveFitDialog/ w[0] = y0
	//CurveFitDialog/ w[1] = A
	//CurveFitDialog/ w[2] = x0
	//CurveFitDialog/ w[3] = p1
	//CurveFitDialog/ w[4] = B
	//CurveFitDialog/ w[5] = p2

	return w[0]+w[1]*(x-w[2])^w[3]+w[4]*(x-w[2])^w[5]
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function DblExpPower(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = y0+a1*exp(-tau1*x)*x^p1+a2*exp(-tau2*x)*x^p2
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 7
	//CurveFitDialog/ w[0] = y0
	//CurveFitDialog/ w[1] = a1
	//CurveFitDialog/ w[2] = tau1
	//CurveFitDialog/ w[3] = p1
	//CurveFitDialog/ w[4] = a2
	//CurveFitDialog/ w[5] = tau2
	//CurveFitDialog/ w[6] = p2

	return w[0]+w[1]*exp(-w[2]*x)*x^w[3]+w[4]*exp(-w[5]*x)*x^w[6]
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function PowerOffsetExp(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = y0+a1*(x-x0)^p1+a2*exp(-tau*(x))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 6
	//CurveFitDialog/ w[0] = y0
	//CurveFitDialog/ w[1] = a1
	//CurveFitDialog/ w[2] = x0
	//CurveFitDialog/ w[3] = p1
	//CurveFitDialog/ w[4] = a2
	//CurveFitDialog/ w[5] = tau

	return w[0]+w[1]*(x-w[2])^w[3]+w[4]*exp(-w[5]*(x))
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
ThreadSafe Function Pade23(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = a0*(1+a1*x+a2*x^2)/(1+b1*x+b2*x^2+b3*x^3)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 6
	//CurveFitDialog/ w[0] = a0
	//CurveFitDialog/ w[1] = a1
	//CurveFitDialog/ w[2] = a2
	//CurveFitDialog/ w[3] = b1
	//CurveFitDialog/ w[4] = b2
	//CurveFitDialog/ w[5] = b3

	return w[0]*(1+w[1]*x+w[2]*x^2)/(1+w[3]*x+w[4]*x^2+w[5]*x^3)
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Threadsafe Function Pade34(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = a0*(1+a1*x+a2*x^2+a3*x^3)/(1+b1*x+b2*x^2+b3*x^3+b4*x^4)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 8
	//CurveFitDialog/ w[0] = a0
	//CurveFitDialog/ w[1] = a1
	//CurveFitDialog/ w[2] = a2
	//CurveFitDialog/ w[3] = a3
	//CurveFitDialog/ w[4] = b1
	//CurveFitDialog/ w[5] = b2
	//CurveFitDialog/ w[6] = b3
	//CurveFitDialog/ w[7] = b4

	return w[0]*(1+w[1]*x+w[2]*x^2+w[3]*x^3)/(1+w[4]*x+w[5]*x^2+w[6]*x^3+w[7]*x^4)
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
ThreadSafe Function funcGimag(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = b0+b1*x/(1+b3*x+b4*x^2)+b2*x^2
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 5
	//CurveFitDialog/ w[0] = b0
	//CurveFitDialog/ w[1] = b1
	//CurveFitDialog/ w[2] = b2
	//CurveFitDialog/ w[3] = b3
	//CurveFitDialog/ w[4] = b4

//	best w[0]*x*(1+w[4]*x)/(1+w[2]*x+w[3]*x^3)+w[1]*x^2
//	return w[0]*x*(1+w[2]*x)/(1+w[3]*x+w[4]*x^2+w[5]*x^3)+w[1]*x^2
//	return w[0]*x/(1+w[2]*x+w[3]*x^2)+w[1]*x^2+w[4]
	return w[0]+w[1]*x/(1+w[3]*x+w[4]*x^2)+w[2]*x^2
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
ThreadSafe Function funcGreal(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = a0+a1*x*(1+a2*x)/(1+a3*x+a4*x^2)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 5
	//CurveFitDialog/ w[0] = a0
	//CurveFitDialog/ w[1] = a1
	//CurveFitDialog/ w[2] = a2
	//CurveFitDialog/ w[3] = a3
	//CurveFitDialog/ w[4] = a4

	return w[0]+w[1]*x*(1+w[2]*x)/(1+w[3]*x+w[4]*x^2)
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
ThreadSafe Function funcGimag2(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = b1*x/(1+b3*x+b4*x^b5)+b2*x^2
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 5
	//CurveFitDialog/ w[0] = b1
	//CurveFitDialog/ w[1] = b2
	//CurveFitDialog/ w[2] = b3
	//CurveFitDialog/ w[3] = b4
	//CurveFitDialog/ w[4] = b5

	return w[0]*x/(1+w[2]*x+w[3]*x^w[4])+w[1]*x^2
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
ThreadSafe Function funcGreal2(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = a0+a1*x*(1+a3*x)/(1+a3*x+a4*x^a5)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 5
	//CurveFitDialog/ w[0] = a0
	//CurveFitDialog/ w[1] = a1
	//CurveFitDialog/ w[2] = a2
	//CurveFitDialog/ w[3] = a3
	//CurveFitDialog/ w[4] = a4

	return w[0]+w[1]*x*(1+w[2]*x)/(1+w[2]*x+w[3]*x^w[4])
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function CheckProc_SetScaleBack(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked

			wave list_Sel=root:Packages:AFM_Calibration:BkgdCoef_list_Sel
			
			if(checked)
				list_Sel[][2]=0x30
			else
				list_Sel[][2]=0x20
			endif

			Update_BackGrnd()
			Update_CurrentPeak()

			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function SetVarProc_UpdateCantParam(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
				strswitch(sva.ctrlName)
				
					case "xlaser":
					
						NVAR cant_Xlaser=root:packages:AFM_Calibration:cant_Xlaser
						NVAR cant_length=root:packages:AFM_Calibration:cant_length
						
						cant_Xlaser=cant_length*dval
					
					break
				
				endswitch
				
				DoUpdate
				Calc_Results(0)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT


Function PopMenuProc_SelectMediumPure(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr

			DFREF dfcal=root:Packages:AFM_Calibration:
			SVAR medium=dfcal:medium
			
			medium=popStr
			
//			string S_popmenu=Get_S_popmenu(popStr, pa.ctrlName, pa.win)
//			PopupMenu $pa.ctrlName,value= #S_popmenu

			SetDensity()

			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
