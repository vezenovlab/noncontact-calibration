#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.


Function/C GetSFOParams(kappa,tau,d0,pcoef,qcoef,HoldStr,spectrum_type)
	variable kappa,tau,d0,pcoef,qcoef
	string HoldStr,spectrum_type
	
	// make PSD wave and frequency wave with log scaling
	make/D/O/N=10000 wPSDdel, wPSDdel_X
	SetScale/I x -4,4,"", wPSDdel, wPSDdel_X
	wPSDdel_X=10^x
	
	// calculate hydrodynamic function coefficients wGr_coef and wGi_Coef
	//Calc_Gamma2(spectrum_type, kappa, use_Fitted_Coef, -4, 4, fitType, V_delta_max)
	Calc_Gamma2(spectrum_type, kappa, 0, -4, 4, 1, 2)
	
	DFREF dfcal=root:Packages:AFM_Calibration:
				
	WAVE/SDFR=dfcal wGr_coef 
	WAVE/SDFR=dfcal wGi_coef 

//	wave wGr_coef
//	wave wGi_coef
//
	// make coef wave
	// area, delta0, tau
	make/D/O/N=3 w_coefDel={1,d0,tau}
	
	// Calculate PSD
	// Need to use wGr_coef and wGi_Coef
	wPSDdel=dSFOfull_k_v0(w_coefDel,wPSDdel_X)
	
	// calculate Q0
	variable Gr0=funcGreal(wGr_coef,d0)
	variable Gi0=funcGimag(wGi_coef,d0)
	variable Q0=(1+tau*Gr0)/(tau*Gi0)
	//print Q0

	// make fit coef wave
	// area, delta0, Q0, p, q
	Make/D/O/N=5 W_coefPSD
	W_coefPSD = {1,d0,Q0,pcoef,qcoef}


	FuncFit/L=10000/Q/N/W=2/H="000"+HoldStr  dSFO_pq W_coefPSD wPSDdel /X=wPSDdel_X /D 

	wave fitX_wPSDdel,fit_wPSDdel

	variable AInt=areaXY(wPSDdel_X,wPSDdel)
	variable AInt_fit=areaXY(fitX_wPSDdel,fit_wPSDdel)
	
	return cmplx(AInt,AInt_fit)

	
end

Function Calc_AQpq(kappa,d0min, d0max, taumin, taumax, NOP, spectrum_type)
	variable kappa, d0min, d0max, taumin, taumax, NOP
	string spectrum_type


	Make/O/N=(NOP,NOP) AInt, AInt_fit, Q0, A_fit, d0_fit, p_fit, q_fit, Q0_fit, wtau0, wd0
	SetScale/I x taumin,taumax,"", AInt, AInt_fit, Q0, A_fit, d0_fit, p_fit, q_fit, Q0_fit
	SetScale/I y d0min,d0max,"", AInt, AInt_fit, Q0, A_fit, d0_fit, p_fit, q_fit, Q0_fit
	
	Make/O/N=(NOP+1) wtau0, wd0
	SetScale/I x d0min,d0max,"", wd0
	SetScale/I x taumin,taumax,"", wtau0
	
//	wd0=x
//	wtau0=x

	wtau0=10^(log(taumin)+p*(log(taumax)-log(taumin))/NOP)
	wd0=10^(log(d0min)+p*(log(d0max)-log(d0min))/NOP)
	
	DoWindow/F GraphPSDdel
	if(V_flag==0)
		GetSFOParams(kappa,wtau0[0],wd0[0],0,1,"00",spectrum_type)
		wave wPSDdel_X,wPSDdel
		Display wPSDdel vs wPSDdel_X
		ModifyGraph rgb(wPSDdel)=(0,0,65535)
		ModifyGraph log=1
		DoWindow/C GraphPSDdel
	endif

	variable i,j
	
	variable/C fitResult
	
	NewPanel /N=ProgressPanel /W=(285,111,739,193)
	ValDisplay valdisp0,pos={18,32},size={342,18},limits={0,(NOP-1)^2,0},barmisc={0,0}
	ValDisplay valdisp0,value= _NUM:0
	ValDisplay valdisp0,mode= 3	// bar with no fractional part

	Button bStop,pos={375,32},size={50,20},title="Stop"
	DoUpdate /W=ProgressPanel /E=1	// mark this as our progress window

	for(i=0;i<NOP;i+=1)
		for(j=0;j<NOP;j+=1)

			fitResult=GetSFOParams(kappa,wtau0[i],wd0[j],0,1,"00",spectrum_type)
			
			AInt[i][j]=Real(fitResult)
			AInt_fit[i][j]=Imag(fitResult)

			wave/SDFR=dfcal W_coefPSD

			A_fit[i][j]=W_coefPSD[0]
			d0_fit[i][j]=W_coefPSD[1]
			Q0_fit[i][j]=W_coefPSD[2]
			p_fit[i][j]=W_coefPSD[3]
			q_fit[i][j]=W_coefPSD[4]
			
			ValDisplay valdisp0,value= _NUM:i*NOP+j+1,win=ProgressPanel
		
			DoUpdate /W=ProgressPanel
			if( V_Flag == 2 )	// we only have one button and that means stop
				break
			endif

		endfor

		if( V_Flag == 2 )
			break
		endif
		

	endfor

//	d0_fit = abs(AInt-1) > 0.1 ? nan : d0_fit[p][q]  
//	Q0_fit = abs(AInt-1) > 0.1 ? nan : Q0_fit[p][q]  
//	p_fit = abs(AInt-1) > 0.1 ? nan : p_fit[p][q]  
//	q_fit = abs(AInt-1) > 0.1 ? nan : q_fit[p][q]  
//	A_fit = abs(AInt-1) > 0.1 ? nan : A_fit[p][q]  
//	Q0 = abs(AInt-1) > 0.1 ? nan : Q0[p][q]  
//	AInt = abs(AInt-1) > 0.1 ? nan : AInt[p][q]
	
	DFREF dfcal=root:Packages:AFM_Calibration:
				
	WAVE/SDFR=dfcal wGr_coef 
	WAVE/SDFR=dfcal wGi_coef 

//	Q0=(1+x*funcGreal(wGr_coef,y))/(x*funcGimag(wGi_coef,y))  
	Q0=(1+wtau0[p]*funcGreal(wGr_coef,wd0[q]))/(wtau0[p]*funcGimag(wGi_coef,wd0[q]))  
	
	Q0_fit/=Q0
	d0_fit/=wd0[q]

	KillWindow ProgressPanel

end

Function Calc_AQ_fixed_pq(kappa,d0, tau, NOP, spectrum_type)
	variable kappa,d0, tau, NOP 
	string spectrum_type


	Make/O/N=(NOP,NOP) AInt, AInt_fit, A_fit, d0_fit, Q0_fit
	SetScale/I x 0,1,"", AInt, AInt_fit, A_fit, d0_fit, Q0_fit
	SetScale/I y 0,1,"", AInt, AInt_fit, A_fit, d0_fit, Q0_fit
	
	DoWindow/F GraphPSDdel
	if(V_flag==0)
		GetSFOParams(kappa,tau,d0,0,0,"11",spectrum_type)
		wave wPSDdel_X,wPSDdel
		Display wPSDdel vs wPSDdel_X
		ModifyGraph rgb(wPSDdel)=(0,0,65535)
		ModifyGraph log=1
		DoWindow/C GraphPSDdel
	endif

	variable i,j
	
	variable/C fitResult
	
	NewPanel /N=ProgressPanel /W=(285,111,739,193)
	ValDisplay valdisp0,pos={18,32},size={342,18},limits={0,(NOP-1)^2,0},barmisc={0,0}
	ValDisplay valdisp0,value= _NUM:0
	ValDisplay valdisp0,mode= 3	// bar with no fractional part

	Button bStop,pos={375,32},size={50,20},title="Stop"
	DoUpdate /W=ProgressPanel /E=1	// mark this as our progress window

	for(i=0;i<NOP;i+=1)
		for(j=0;j<NOP;j+=1)

			fitResult=GetSFOParams(kappa,tau,d0,i/(NOP-1),j/(NOP-1),"11",spectrum_type)
			
			AInt[i][j]=Real(fitResult)
			AInt_fit[i][j]=Imag(fitResult)

			wave W_coefPSD

			A_fit[i][j]=W_coefPSD[0]
			d0_fit[i][j]=W_coefPSD[1]
			Q0_fit[i][j]=W_coefPSD[2]
			
			ValDisplay valdisp0,value= _NUM:i*NOP+j+1,win=ProgressPanel
		
			DoUpdate /W=ProgressPanel
			if( V_Flag == 2 )	// we only have one button and that means stop
				break
			endif

		endfor

		if( V_Flag == 2 )
			break
		endif
		

	endfor

	DFREF dfcal=root:Packages:AFM_Calibration:
				
	WAVE/SDFR=dfcal wGr_coef 
	WAVE/SDFR=dfcal wGi_coef 

	variable Q0=(1+tau*funcGreal(wGr_coef,d0))/(tau*funcGimag(wGi_coef,d0))  
	
	Q0_fit/=Q0
	d0_fit/=d0

	KillWindow ProgressPanel

end

Function Scan_Dpq(d0start, d0end,NOP,tau)
	variable d0start, d0end,NOP,tau

	variable i, d0, dd0
	dd0=(d0end-d0start)/(NOP-1)
	
	make/O/N=(NOP) wd0scan, wp1scan, wp3scan, wq1scan,  wq2scan, wq3scan, wAscan
	
	for(i=0;i<NOP;i+=1)
	
		d0=d0start+i*dd0
		
		Calc_AQ_fixed_pq(0,d0, tau, 11, "lateral")
		wave Q0_fit
		
		Make/D/N=7/O W_coef
		W_coef[0] = {0.85,0.55,0,0.45,0,0,0}
		FuncFitMD/H="0010000"/Q Fit_SFO_vs_pq W_coef Q0_fit
		
		wd0scan[i]=d0
		wAscan[i]=W_coef[0]
		wp1scan[i]=W_coef[1]
		wp3scan[i]=W_coef[3]
		wq1scan[i]=W_coef[4]
		wq2scan[i]=W_coef[5]
		wq3scan[i]=W_coef[6]
		
	endfor


end

Function Fit_SFO_vs_pq(w,x,y) : FitFunc
	Wave w
	Variable x
	Variable y

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x,y) = A*(1+p1*x+p2*x^2+p3*x^3)*(1+q1*y+q2*y^2+q3*y^3)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 2
	//CurveFitDialog/ x
	//CurveFitDialog/ y
	//CurveFitDialog/ Coefficients 7
	//CurveFitDialog/ w[0] = A
	//CurveFitDialog/ w[1] = p1
	//CurveFitDialog/ w[2] = p2
	//CurveFitDialog/ w[3] = p3
	//CurveFitDialog/ w[4] = q1
	//CurveFitDialog/ w[5] = q2
	//CurveFitDialog/ w[6] = q3

	return w[0]*(1+w[1]*x+w[2]*x^2+w[3]*x^3)*(1+w[4]*y+w[5]*y^2+w[6]*y^3)
End
