#pragma rtGlobals=1		// Use modern global access method.
// Cross Hair profile
// 20151030 - WJL - Added shortcut to menu option


Menu "Vezenov Lab"
	SubMenu "Microscope Controls"
		"Cross-Hair Profile", /Q, XHair_AddHairTop("line") 
		"Free-Hand Profile", /Q, XHair_AddHairTop("free") 
	End
End
Menu "PacMan"
	SubMenu "Kill Packs"
		"Profile Controls", /Q, Execute/P "DELETEINCLUDE \"Cross Hair Profile\""; Execute/P "COMPILEPROCEDURES "
	End
End
//===========================================================================

	// Finds the first graph with an image, brings it to front and returns image name
Function/S XHair_GetTopImageName()

	String imagePlot = ""
	String imagelist = ""
	String NameOfGraph = ""
	String ListOfGraphs = WinList("*", ";", "WIN:1")
	variable i=0
	do
		NameOfGraph = StringFromList(i,ListOfGraphs, ";")
		imagelist = ImageNameList(NameOfGraph,";")
		imagePlot = StringFromList(0,imagelist, ";")
		if(strlen(imagePlot))
			wave image = ImageNameToWaveRef(NameOfGraph, imagePlot)
			imagePlot = GetWavesDataFolder(image, 2)
			DoWindow/F $NameOfGraph
			break
		endif
		i += 1
	while(strlen(NameOfGraph))

	return imagePlot
end
//===========================================================================

// Append cross-hair to the first image
Function XHair_CrossHairLive(ctrlName) : ButtonControl
	String ctrlName

	XHair_AddHairTop(ctrlName)
end
//===========================================================================

Function XHair_AddHairTop(style) 
	String style

	string image=XHair_GetTopImageName()

	if(strlen(image))
		wave/C w=$image
		string ListOfAxis=AxisList("")

		String savdf=GetDataFolder(1)
		string df=GetWavesDataFolder(w,1)
		SetDataFolder $df
		NewDataFolder/O/S Profiles
		NewDataFolder/O/S $WinName(0,1)
		string/G WinImg=WinName(0,1)
		SVAR WinImg
		string/G axisType="", axisName=""
		variable i
		
		NVAR/Z Ax, Ay, Bx, By
		variable istopaxis=0
		for(i=0;i<4;i+=1)
			axisName=StringFromList(i,ListOfAxis)
			axisType=StringByKey("AXTYPE", AxisInfo("",axisName))
			GetAxis/Q $axisName
			strswitch(axisType)
				case "left":
				case "right":
					if(NVAR_Exists(Ay)==0)
						variable/G Ay=(V_min+V_max)/2.1		// different from 2 so that A and B  
						variable/G By=(V_min+V_max)/1.9		// are not on top of one another
					endif
				break

				case "top":
					istopaxis=1
				case "bottom":
					if(NVAR_Exists(Ax)==0)
						variable/G Ax=(V_min+V_max)/2.1
						variable/G Bx=(V_min+V_max)/1.9
					endif
				break
				
			endswitch
		endfor
		
		make/O/N=(DimSize(w,0)) ProfileX
		make/O/N=(DimSize(w,1)) ProfileY
//		if(WaveExists(ProfileXY)==0)
			make/O/N=0 ProfileXY
			make/O/N=2 PathX={Ax, Bx}, PathY={Ay, By}
//		endif

		SetScale/P x, DimOffset(w,0), DimDelta(w,0), WaveUnits(w,0), ProfileX, ProfileXY
		SetScale/P x, DimOffset(w,1), DimDelta(w,1), WaveUnits(w,1), ProfileY
//		SetScale/P d, 0, 0, WaveUnits(w,-1), ProfileX, ProfileY, ProfileXY
		CheckDisplayed PathY
		if(V_flag==0)
			if(istopaxis)
				AppendToGraph/T PathY vs PathX
			else
				AppendToGraph PathY vs PathX
			endif
			ModifyGraph live=1
			ModifyGraph/Z lsize(PathY)=0
		endif

		df=GetDataFolder(1)

		Variable/G gUpdt_Profile
		NVAR gUpdt_Profile
		SVAR/Z ProfWin
		if(SVAR_Exists(ProfWin)==0)
			string/G ProfWin=UniqueName("Profile", 6,0)
			SVAR ProfWin
		endif

		SetFormula gUpdt_Profile, "XHair_UpdateProfile(Ax,Ay,Bx,By,"+image+",\""+ProfWin+"\")"
//		print GetFormula(gUpdt_Profile)

		if(strlen(WinList(ProfWin, ";", "WIN:1" ))==0)
			Display/W=(20,20,300,200)/K=1 ProfileX as "Profiles: "+NameOfWave(w)
			DoWindow/C $ProfWin
			AutoPositionWindow/E/M=1 $ProfWin

			AppendToGraph/T=YProfile ProfileY 

			ModifyGraph freePos(YProfile)=0
			ModifyGraph rgb(ProfileY)=(0,0,65535), mirror(left)=2
			ModifyGraph notation=0, standoff=0, live=1
			ModifyGraph margin(bottom)=38, margin(top)=38, margin(left)=40, margin(right)=16
			ModifyGraph axRGB(bottom)=(65535,0,0), tlblRGB(bottom)=(65535,0,0), alblRGB(bottom)=(65535,0,0)
			ModifyGraph axRGB(YProfile)=(0,0,65535), tlblRGB(YProfile)=(0,0,65535), alblRGB(YProfile)=(0,0,65535)

			Label left " "
			Label bottom "Profile X"
			Label YProfile "Profile Y"
			ModifyGraph lblPos(YProfile)=32
		else
			DoWindow/F $ProfWin
		endif
		
		SetWindow $ProfWin, hook=XHair_ProfilesHook

		DoWindow/F $WinImg
		
		strswitch(style)
		
			case "line":
				if(strlen(CsrWave(A))==0)
					Cursor/I/F A  $NameOfWave(w), Ax, Ay
					Cursor/M/S=0/L=1/C=(65535,0,0) A
					Cursor/M/H=1 A
					CheckDisplayed/W=$ProfWin ProfileX, ProfileY
					if(V_flag==0)
						AppendToGraph/W=$ProfWin ProfileX, ProfileY
						ModifyGraph/W=$ProfWin rgb(ProfileY)=(0,0,65535)
					endif
					ModifyGraph/W=$WinImg/Z lsize(PathY)=0
				else
					Cursor/M/S=0/L=1/C=(65535,0,0) A
				endif
		
				Cursor/K B
				Cursor/M/H=1 A
				ModifyGraph/W=$WinImg/Z lsize(PathY)=0
				CheckDisplayed/W=$ProfWin ProfileX
				if(V_flag==0)
					AppendToGraph/W=$ProfWin ProfileX
					ModifyGraph/W=$ProfWin rgb(ProfileX)=(65535,0,0)
					ModifyGraph/W=$ProfWin axRGB(bottom)=(65535,0,0), tlblRGB(bottom)=(65535,0,0), alblRGB(bottom)=(65535,0,0)
				endif
				CheckDisplayed/W=$ProfWin ProfileY
				if(V_flag==0)
					AppendToGraph/W=$ProfWin/T=YProfile ProfileY 
					ModifyGraph/W=$ProfWin freePos(YProfile)=0
					ModifyGraph/W=$ProfWin rgb(ProfileY)=(0,0,65535)
					ModifyGraph/W=$ProfWin axRGB(YProfile)=(0,0,65535), tlblRGB(YProfile)=(0,0,65535), alblRGB(YProfile)=(0,0,65535)
					GetAxis/W=$WinImg/Q left
					if(V_flag==0)
						SetAxis/W=$ProfWin/Z YProfile, V_min, V_max
					else
						GetAxis/W=$WinImg/Q right
						if(V_flag==0)
							SetAxis/W=$ProfWin/Z YProfile, V_min, V_max
						endif
					endif
				endif
				ModifyGraph/W=$ProfWin mirror(left)=2
				RemoveFromGraph/W=$ProfWin/Z ProfileXY
				Label/W=$ProfWin bottom "Profile X"
				Label/W=$ProfWin YProfile "Profile Y"
				ModifyGraph/W=$ProfWin lblPos(YProfile)=32
			
				break
			
			case "free":
		
				if(strlen(CsrWave(B))==0)
					Cursor/I/F A  $NameOfWave(w), Ax, Ay
					Cursor/I/F B  $NameOfWave(w), Bx, By
					Cursor/M/S=0/L=0/C=(65535,0,0) A
					Cursor/M/S=0/L=0/C=(65535,0,0) B
					Cursor/M/H=0 A
					Cursor/M/H=0 B
					ModifyGraph/W=$WinImg/Z lsize(PathY)=2
					CheckDisplayed/W=$ProfWin ProfileXY
					if(V_flag==0)
						AppendToGraph/W=$ProfWin ProfileXY
					endif
					Label/W=$ProfWin bottom "Profile XY"
					RemoveFromGraph/W=$ProfWin/Z ProfileX, ProfileY
				endif
		
				break
		
		endswitch
		
		SetDataFolder $savdf
	endif


end
//===========================================================================

Function XHair_ProfilesHook(infoStr)
	String infoStr

	variable status=0
	String event= StringByKey("EVENT",infoStr)
	string ProfWin=StringByKey("WINDOW",infoStr)
	
	strswitch(event)
		case "kill":
			// kill dependency
			wave w=WaveRefIndexed("",0,1) 	// Returns first Y wave in the top graph.
			SetFormula $(GetWavesDataFolder(w,1)+"gUpdt_Profile"), ""
			// get the name of the image window and remove cursors
			SVAR win=$(GetWavesDataFolder(w,1)+"WinImg")
			DoWindow/F $win
			if(V_flag==0)
				return 1
			endif
			Cursor/K/W=$win A
			Cursor/K/W=$win B
			RemoveFromGraph/W=$win/Z PathY
			HideInfo/W=$win
			RemoveFromGraph/W=$ProfWin/Z ProfileX, ProfileY, ProfileXY
			KillDataFolder/Z GetWavesDataFolder(w,1)
		break
	endswitch

	return status				// 0 if nothing done, else 1 or 2
End
//===========================================================================

Function XHair_UpdateProfile(Ax, Ay, Bx, By, w, win)
	variable Ax, Ay, Bx, By
	wave/C w
	string win

	string df=GetWavesDataFolder(w,1)
	df+="Profiles:"+PossiblyQuoteName(WinName(0,1))
	if(DataFolderExists(df)==0)
		return 1
	endif
	wave/Z ProfileX=$(df+":ProfileX")
	wave/Z ProfileY=$(df+":ProfileY")
	wave/Z ProfileXY=$(df+":ProfileXY")
	wave/Z PathX=$(df+":PathX")
	wave/Z PathY=$(df+":PathY")

	String Info = ImageInfo("","",0)
	variable Layer = NumberByKey("plane",Info,"=",";")

	if(strlen(CsrWave(A)) &&strlen(CsrWave(B)) )
//		if(WaveExists(ProfileXY))
//			variable length=sqrt((Bx-Ax)^2+(By-Ay)^2)
//			variable num=sqrt(((Bx-Ax)/DimDelta(w,0))^2+((By-Ay)/DimDelta(w,1))^2)
//			variable k=(Ay-By)/(Ax-Bx)
//			variable y0=Ay-k*Ax
//			Redimension/N=(num) ProfileXY
//			SetScale/I x, Ax, Bx, WaveUnits(w,0), ProfileXY
//			ProfileXY=w(x)(k*x+y0)[layer]
//			SetScale/I x, 0, length, WaveUnits(w,0), ProfileXY
			if(strlen(WinList(win,";", "WIN:1")))
				SetAxis/W=$win/A bottom
			endif
			if(WaveExists(PathX))
				PathY[0]=Ay
				PathY[1]=By
				PathX[0]=Ax
				PathX[1]=Bx
				if(WaveDims(w)==2)
					ImageLineProfile srcWave=w, xWave=PathX, yWave=PathY
				else
					ImageLineProfile/P=(Layer) srcWave=w, xWave=PathX, yWave=PathY
				endif
				wave W_ImageLineProfile
				Duplicate/O W_ImageLineProfile, ProfileXY
				variable length=sqrt((Bx-Ax)^2+(By-Ay)^2)
				SetScale/I x, 0, length, WaveUnits(w,0), ProfileXY
				SetScale/I d, 0,0, WaveUnits(w,-1), ProfileXY
			endif
//		endif
	else
		if(WaveExists(ProfileX))
			ProfileX=w(x)(Ay)[layer]
		endif
	
		if(WaveExists(ProfileY))
			ProfileY=w(Ax)(x)[layer]
		endif
	endif
	
end
//===========================================================================

Function CursorMovedHook(info)
	string info

	string graphName=stringByKey("GRAPH", info)
	string wn=stringByKey("TNAME", info)
	wave/Z w = ImageNameToWaveRef(graphName, wn)
	if(WaveExists(w))
		String savdf=GetDataFolder(1)
		string df=GetWavesDataFolder(w,1)
		if(DataFolderExists(df+"Profiles:"+graphName))
			SetDataFolder $(df+"Profiles:"+graphName)
			if(strlen(CsrWave(A)))
				NVAR Ax, Ay 
				SVAR ProfWin
				Ax=hcsr(A)
				Ay=vcsr(A)

				string ListOfAxis=AxisList(graphName)

				variable i
				string axisName="", axisType=""
				for(i=0;i<4;i+=1)
					axisName=StringFromList(i,ListOfAxis)
					axisType=StringByKey("AXTYPE", AxisInfo("",axisName))
					GetAxis/Q $axisName
					strswitch(axisType)
						case "left":
						case "right":
							if(V_flag==0)
								if(strlen(WinList(ProfWin, ";", "WIN:1")))
									SetAxis/W=$(ProfWin)/Z YProfile, V_min, V_max
								endif
							endif
							break

						case "top":
						case "bottom":
							if(V_flag==0)
								if(strlen(WinList(ProfWin, ";", "WIN:1")))
									SetAxis/W=$(ProfWin)/Z bottom, V_min, V_max
								endif
							endif
							break
				
					endswitch
				endfor

				DoUpdate
			endif
			if(strlen(CsrWave(B)))
				NVAR Bx, By 
				Bx=hcsr(B)
				By=vcsr(B)
				DoUpdate
			endif
			SetDataFolder $savdf
		endif
	endif
	
end
//===========================================================================
