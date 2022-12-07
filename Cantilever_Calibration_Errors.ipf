#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.


Function Err_Init()

	SetDataFolder root:

	NewDataFolder/O root:SavedCal

	NewDataFolder/O/S packages
	NewDataFolder/O/S AFM_Calibration
	NewDataFolder/O/S Errors
	
	// input uncertainty
	variable/G D_b
	variable/G D_L
	variable/G D_t
	variable/G D_Xtip
	variable/G D_Xlaser
	variable/G D_H
	variable/G D_Sz_cont
	variable/G D_Sy_cont

	// uncertainty calculated from PSD fitting
	variable/G D_v0n
	variable/G D_Q
	variable/G D_Gi
	variable/G D_Gr
	variable/G D_A
	variable/G D_tau
	
	// auxilary uncertainty
	variable/G D_Xtip_R
	variable/G D_Xlaser_R
	variable/G D_H_R
	variable/G D_Sz_cont_R
	variable/G D_Szn_cont_R
	variable/G D_CorrFactorZ_R
	variable/G D_CorrFactorY_R
	variable/G D_DwDx_R
	variable/G D_DphiDx_R

	// output uncertainty
	// spring constants
	variable/G D_kzn_R
	variable/G D_kc_R
	variable/G D_kzs_R
	
	variable/G D_kcEqTh_R

	variable/G D_kzs_theory_R
	variable/G D_kzs_EqTh_R	
	variable/G D_kzs_Sader_R
	variable/G D_kzs_FluidStruc_R

	variable/G D_kthetan_R
	variable/G D_ktheta_R
	variable/G D_kthetas_R

	variable/G D_kthetas_theory_R
	variable/G D_kthetas_EqTh_R	
	variable/G D_kthetas_Sader_R
	variable/G D_kthetas_FluidStruc_R

	variable/G D_ky_R

	variable/G D_kys_theory_R
	variable/G D_kys_EqTh_R	
	variable/G D_kys_Sader_R
	variable/G D_kys_FluidStruc_R

	// sensitivitites
	variable/G D_Sz_cont_R
	variable/G D_Sthetaf_cont_R
	variable/G D_SFf_cont_R

	variable/G D_Sz_noncont_R
	variable/G D_Sthetaf_noncont_R
	variable/G D_SFf_noncont_R
	
	variable/G D_Sy_cont_R
	variable/G D_Sthetat_cont_R
	variable/G D_SFt_cont_R

	variable/G D_Sy_noncont_R
	variable/G D_Sthetat_noncont_R
	variable/G D_SFt_noncont_R

	SetDataFolder root:

end

// do calculations of errors for the current peak
// need to iterate through all peaks when compiling
// the results of the PSD fitting
Function Calc_Error_k()
	DFREF dfSav = GetDataFolderDFR()

	if(DataFolderExists("root:Packages:AFM_Calibration:Results")==0)
		return 1
		Abort "Plot results first."
	endif
	
	DFREF dfcal=root:Packages:AFM_Calibration:
	
	SetDataFolder dfcal
	
	SVAR model
	SVAR Spectrum_type
	
	NVAR kz_thermal
	NVAR kz_Sader
	NVAR ky_Sader
	NVAR kTheta_Sader

	NVAR cant_rho_e
	NVAR cant_a
	NVAR cant_b
	NVAR cant_width
	NVAR cant_length
	NVAR cant_D
	NVAR cant_thickness_e

	NVAR tip_H
	NVAR xtip
	NVAR xlaser

	NVAR Medium_visc
	NVAR Medium_dens
	NVAR Current_peak
	NVAR ReNum
	NVAR Relog
	NVAR cant_kappa
	
	NVAR Sz_cont
	NVAR Sy_cont
	
	NVAR Cn
	NVAR Dn

	NVAR G_option
	
	if(DataFolderRefStatus(dfcal:Errors)==0)
		Err_Init()
	endif

	SetDataFolder dfcal:Errors
	// input uncertainty
	NVAR D_b
	NVAR D_L
	NVAR D_t

	NVAR D_Xtip
	NVAR D_H
	NVAR D_Xlaser
	
	NVAR D_Sz_cont

	// auxilary uncertainty
	NVAR D_CorrFactorZ_R
	NVAR D_CorrFactorY_R
	NVAR D_DwDx_R
	NVAR D_DphiDx_R

	// uncertainty calculated from PSD fitting
	NVAR D_v0n
	NVAR D_Q
	NVAR D_Gi
	NVAR D_Gr
	NVAR D_A
	NVAR D_tau

	// output uncertainty
	// spring constants
	NVAR D_kzn_R
	NVAR D_kc_R

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
	NVAR D_Sz_cont
	NVAR D_Sy_cont
	
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

	variable cant_L=cant_length-cant_D/2
	
	// spring const auxilary
	variable D_kc_cont_R
	variable D_kc_noncont_R

	variable D_ktheta_cont_R
	variable D_ktheta_noncont_R

	variable D_ky_cont_R
	variable D_ky_noncont_R

	wave/C/Z/SDFR=dfcal:Results wG
	
	// no fitting done, nothing to calculate
	if(WaveExists(wG)==0)
		return 1
	endif

	wave/SDFR=dfcal wPeakArea
	wave/SDFR=dfcal wf0
	wave/SDFR=dfcal wQ
	wave/C/SDFR=dfcal wG
	wave/C/SDFR=dfcal wG_Error
	
	wave/Z/SDFR=dfcal mode
	wave/Z/SDFR=dfcal wDelta	
	wave/Z/SDFR=dfcal wtau	
	wave/Z/SDFR=dfcal wlogRe

	wave/SDFR=dfcal Coef=$("PeakCoef"+num2str(Current_peak))
	wave/SDFR=dfcal Sigma=$("Sigma_PeakCoef"+num2str(Current_peak))
	D_A=Sigma[0]
	D_v0n=Sigma[1]
	
	if(strsearch(model, "SFO (full)",0)<0)
		D_Q=Sigma[2]
		D_tau=0
	else
		D_tau=Sigma[2]
		D_Q=0
	endif
	
	// calculate error in Gamma
	switch(G_option)
	
		// no adjustment for normalized mode
		// calculate from the fit to Gamma for kappa=0

		case 0:
		
			wave/SDFR=dfcal wGi_coef=wGi_coefInf						
			wave/SDFR=dfcal wGr_coef=wGr_coefInf
					
		break
		
		// adjustment for normalized mode
		// calculate from the fit to Gamma
		case 1:

			//  coef wave is created for every peak 
			wave/SDFR=dfcal wGi_coef=$("wGi_coef"+num2str(Current_peak))						
			wave/SDFR=dfcal wGr_coef=$("wGr_coef"+num2str(Current_peak))
							
		break
	
	endswitch
	
	// new peak
	if(numpnts(wDelta)<Current_peak)
		return 1
	endif
	
	variable i=Current_peak-1

	D_Gi=funcGimag(wGi_coef,1.001*wDelta[i])
	D_Gi-=funcGimag(wGi_coef,0.999*wDelta[i])
	D_Gi/=0.002
	D_Gi*=D_v0n/(2*wf0[i])
		
	D_Gr=funcGimag(wGr_coef,1.001*wDelta[i])
	D_Gr-=funcGimag(wGr_coef,0.999*wDelta[i])
	D_Gr/=0.002
	D_Gr*=D_v0n/(2*wf0[i])
		
	wave/SDFR=dfcal wGimagErr=wGimagErr						
	wave/SDFR=dfcal wGrealErr=wGrealErr

	// choose the greater of the two errors: 
	// due to approximation to Gamma or error in peak freq
	D_Gi=max(D_Gi,abs(imag(wG_Error[i])))
	D_Gr=max(D_Gr,abs(real(wG_Error[i])))

	// calculate errors in k

	// normal
	// theory
	D_kzs_theory_R=1/2*(D_b/cant_width)^2
	D_kzs_theory_R+=(3*D_L/cant_L)^2			
	D_kzs_theory_R+=(3*D_t/cant_thickness_e)^2			
	// correct for tip position
	D_kzs_theory_R+=(3*D_Xtip/cant_L/xtip)^2
	// convert from squared errors to linear
	D_kzs_theory_R=sqrt(D_kzs_theory_R)

	// lateral
	// theory
	D_kthetas_theory_R=1/2*(D_b/cant_width)^2
	D_kthetas_theory_R+=(D_L/cant_L)^2			
	D_kthetas_theory_R+=(3*D_t/cant_thickness_e)^2			
	// correct for tip position
	D_kthetas_theory_R+=(D_Xtip/cant_L/xtip)^2

	D_kys_theory_R=D_kthetas_theory_R
	D_kys_theory_R+=(2*D_H/Tip_H)^2
	
	// convert from squared errors to linear
	D_kthetas_theory_R=sqrt(D_kthetas_theory_R)
	D_kys_theory_R=sqrt(D_kys_theory_R)

	strswitch(Spectrum_type)
	
		case "normal":
		
			// auxilary errors
//			variable Cn=C_n(Current_peak)
//			variable Cnx=C_n(Current_peak*xlaser)
//			D_DphiDx_R=(cos(Cnx)+cosh(Cnx))/(cos(Cn)+cosh(Cn))
//			D_DphiDx_R-=(sin(Cnx)+sinh(Cnx))/(sin(Cn)+sinh(Cn))
//			D_DphiDx_R/=(sin(Cnx)+sinh(Cnx))/(cos(Cn)+cosh(Cn))+(cos(Cnx)-cosh(Cnx))/(sin(Cn)+sinh(Cn))
//			D_DphiDx_R*=D_xlaser/cant_L

			D_DphiDx_R=dPhidx(Current_peak,xlaser+D_xlaser/cant_L/2)
			D_DphiDx_R-=dPhidx(Current_peak,xlaser-D_xlaser/cant_L/2)
			D_DphiDx_R/=dPhidx(Current_peak,xlaser)
			D_DphiDx_R*=D_DphiDx_R
			
			D_DwDx_R=3*xlaser/xtip*(1-xlaser/xtip)
			D_DwDx_R*=D_DwDx_R
			D_DwDx_R*=(D_xtip/cant_L/xtip)^2+(D_xlaser/cant_L/xlaser)^2

			D_CorrFactorZ_R=D_DphiDx_R+D_DwDx_R

			// convert from squared errors to linear
			D_DwDx_R=sqrt(D_DwDx_R)
			D_CorrFactorZ_R=sqrt(D_CorrFactorZ_R)

			// thermal
			D_kzs_EqTh_R=(D_A/Coef[0])^2
			D_kzs_EqTh_R+=(2*D_Sz_cont/Sz_cont)^2
			// save kc
			D_kc_cont_R=sqrt(D_kzs_EqTh_R)
			// correct for tip position
			D_kzs_EqTh_R+=(3*D_Xtip/cant_L/xtip)^2
			// convert from squared errors to linear
			D_kzs_EqTh_R=sqrt(D_kzs_EqTh_R)
			
			if(strsearch(model, "SFO (full)",0)<0)
				// Sader
				D_kzs_Sader_R=(2*D_b/cant_width)^2
				D_kzs_Sader_R+=(D_L/cant_L)^2			
				D_kzs_Sader_R+=(2*D_v0n/wf0[i])^2			
				D_kzs_Sader_R+=(D_Q/wQ[i])^2			
				D_kzs_Sader_R+=(D_Gi/imag(wG[i]))^2	
				// save kc
				D_kc_noncont_R=sqrt(D_kzs_Sader_R)
				// correct for tip position
				D_kzs_Sader_R+=(3*D_Xtip/cant_L/xtip)^2
				
				// convert from squared errors to linear
				D_kzs_Sader_R=sqrt(D_kzs_Sader_R)
			else
				// Fluid-Structure
				D_kzs_FluidStruc_R=(2*D_b/cant_width)^2
				D_kzs_FluidStruc_R+=(D_L/cant_L)^2			
				D_kzs_FluidStruc_R+=(2*D_v0n/wf0[i])^2			
				D_kzs_FluidStruc_R+=(D_tau/wtau[i])^2			
				// save kc
				D_kc_noncont_R=sqrt(D_kzs_FluidStruc_R)
				// correct for tip position
				D_kzs_FluidStruc_R+=(3*D_Xtip/cant_L/xtip)^2
				
				// convert from squared errors to linear
				D_kzs_FluidStruc_R=sqrt(D_kzs_FluidStruc_R)
			endif


			// sensitivity
			// contact
			D_Sz_cont_R=D_Sz_cont/Sz_cont
			
			D_SFf_cont_R=D_Sz_cont_R^2
			D_SFf_cont_R+=(D_kc_cont_R)^2
			
			D_Sthetaf_cont_R=D_Sz_cont_R^2+(D_DwDx_R)^2
			
			// convert from squared errors to linear
			D_SFf_cont_R=sqrt(D_SFf_cont_R)
			D_Sthetaf_cont_R=sqrt(D_Sthetaf_cont_R)

			// sensitivity
			// non-contact
			D_Sz_noncont_R=D_CorrFactorZ_R^2+(1/2*D_kc_noncont_R)^2+(1/2*D_A/Coef[0])^2
			
			D_SFf_noncont_R=D_Sz_noncont_R+D_kc_noncont_R^2

			D_Sthetaf_noncont_R=D_Sz_noncont_R+(D_DwDx_R)^2

			// convert from squared errors to linear
			D_Sz_noncont_R=sqrt(D_Sz_noncont_R)
			D_SFf_noncont_R=sqrt(D_SFf_noncont_R)
			D_Sthetaf_noncont_R=sqrt(D_Sthetaf_noncont_R)
			

		break
	
		case "lateral":
		

			// auxilary errors
			D_CorrFactorY_R=Dn*cot(Dn*xlaser)*D_xlaser/cant_L

			// sensitivity
			// contact
			D_Sthetat_cont_R=(D_Sy_cont/Sy_cont)^2
			D_Sthetat_cont_R+=(D_H/Tip_H)^2
			D_Sthetat_cont_R+=(D_xtip/cant_L/Tip_H)^2
			D_Sthetat_cont_R+=(D_xlaser/cant_L/xlaser)^2
			
			// convert from squared errors to linear
			D_Sthetat_cont_R=sqrt(D_Sthetat_cont_R)


			// thermal
			D_kthetas_EqTh_R=(D_A/Coef[0])^2
			D_kthetas_EqTh_R+=(2*D_Sy_cont/Sy_cont)^2
			// save ktheta
			D_ktheta_cont_R=sqrt(D_kthetas_EqTh_R)
			// correct for tip position
			D_kthetas_EqTh_R+=(D_Xtip/cant_L/xtip)^2
			// convert from squared errors to linear
			D_kthetas_EqTh_R=sqrt(D_kthetas_EqTh_R)

			// thermal
			D_kys_EqTh_R=(D_A/Coef[0])^2
			D_kys_EqTh_R+=(2*D_Sy_cont/Sy_cont)^2
			// save ky
			D_ky_cont_R=sqrt(D_kys_EqTh_R)
			// correct for tip position
			D_kys_EqTh_R+=(D_Xtip/cant_L/xtip)^2
			// convert from squared errors to linear
			D_kys_EqTh_R=sqrt(D_kys_EqTh_R)

			if(strsearch(model, "SFO (full)",0)<0)

				// Sader ktheta
				D_kthetas_Sader_R=(4*D_b/cant_width)^2
				D_kthetas_Sader_R+=(D_L/cant_L)^2			
				D_kthetas_Sader_R+=(2*D_v0n/wf0[i])^2			
				D_kthetas_Sader_R+=(D_Q/wQ[i])^2			
				D_kthetas_Sader_R+=(D_Gi/imag(wG[i]))^2			
				// save ktheta
				D_ktheta_noncont_R=sqrt(D_kthetas_Sader_R)
				// correct for tip position
				D_kthetas_Sader_R+=(D_Xtip/cant_L/xtip)^2

				// convert from squared errors to linear
				D_kthetas_Sader_R=sqrt(D_kthetas_Sader_R)

				// Sader ky
				D_kys_Sader_R=D_kthetas_Sader_R
				D_kys_Sader_R+=(2*D_H/Tip_H)^2
				
				// convert from squared errors to linear
				D_kys_Sader_R=sqrt(D_kys_Sader_R)
			else
				// Fluid-Structure
				D_kthetas_FluidStruc_R=(4*D_b/cant_width)^2
				D_kthetas_FluidStruc_R+=(D_L/cant_L)^2			
				D_kthetas_FluidStruc_R+=(2*D_v0n/wf0[i])^2			
				D_kthetas_FluidStruc_R+=(D_tau/wtau[i])^2			
				// save ktheta
				D_ktheta_noncont_R=sqrt(D_kthetas_FluidStruc_R)
				// correct for tip position
				D_kthetas_FluidStruc_R+=(D_Xtip/cant_L/xtip)^2
				
				// convert from squared errors to linear
				D_kthetas_FluidStruc_R=sqrt(D_kthetas_FluidStruc_R)

				// Sader ky
				D_kys_FluidStruc_R=D_kthetas_FluidStruc_R
				D_kys_FluidStruc_R+=(2*D_H/Tip_H)^2
				
				// convert from squared errors to linear
				D_kys_FluidStruc_R=sqrt(D_kys_FluidStruc_R)

			endif


			// sensitivity
			// contact
			D_Sy_cont_R=D_Sy_cont/Sy_cont
			
			D_SFt_cont_R=D_Sthetat_cont_R^2
			D_SFt_cont_R+=D_ktheta_cont_R^2
			D_SFt_cont_R+=(D_H/Tip_H)^2
			D_SFt_cont_R+=(D_Xlaser/cant_L/xlaser)^2
			
			// convert from squared errors to linear
			D_SFt_cont_R=sqrt(D_SFt_cont_R)

			// sensitivity
			// non-contact
			D_Sthetat_noncont_R=D_CorrFactorY_R^2
			D_Sthetat_noncont_R+=(1/2*D_ktheta_noncont_R)^2
			D_Sthetat_noncont_R+=(1/2*D_A/Coef[0])^2

			D_Sy_noncont_R=D_Sthetat_noncont_R
			D_Sy_noncont_R+=(D_H/Tip_H)^2
			D_Sy_noncont_R+=(D_Xtip/cant_L/xtip)^2
			D_Sy_noncont_R+=(D_Xlaser/cant_L/xlaser)^2
			
			D_SFt_noncont_R=D_Sthetat_noncont_R
			D_SFt_noncont_R+=D_ktheta_noncont_R^2
			D_SFt_noncont_R+=(D_H/Tip_H)^2
			D_SFt_noncont_R+=(D_Xlaser/cant_L/xlaser)^2


			// convert from squared errors to linear
			D_Sy_noncont_R=sqrt(D_Sy_noncont_R)
			D_SFt_noncont_R=sqrt(D_SFt_noncont_R)
			D_Sthetat_noncont_R=sqrt(D_Sthetat_noncont_R)
			

		break

	endswitch
	
	SetDataFolder dfSav

end

Function MakeErrorsPanel()

	DoWindow/F Errors
	
	if(V_flag==0)
		Execute "PanelErrors()"
		DoWindow/C Errors
	endif

end


Function PanelErrors() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel/K=1 /W=(531,60,1135,424) as "Errors"
	GroupBox cant,pos={6.00,5.00},size={170.00,109.00},title="Cantilever, ∆"
	GroupBox cant,labelBack=(49151,53155,65535),fSize=12,fStyle=1
	GroupBox cant,fColor=(0,0,65535)
	SetVariable length,pos={37.00,22.00},size={130.00,18.00},bodyWidth=75,title="length (L)"
	SetVariable length,format="%.2e m"
	SetVariable length,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_L
	SetVariable xspot,pos={32.00,88.00},size={137.00,20.00},bodyWidth=75,title="laser (X\\Blaser\\M)"
	SetVariable xspot,format="%.2e m"
	SetVariable xspot,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_Xlaser
	SetVariable b,pos={20.00,44.00},size={147.00,18.00},bodyWidth=74,title="top width (b)"
	SetVariable b,format="%.2e m"
	SetVariable b,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_b
	SetVariable thickness,pos={26.00,66.00},size={143.00,18.00},bodyWidth=75,title="thickness (t)"
	SetVariable thickness,format="%.2e m"
	SetVariable thickness,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_t
	GroupBox tip,pos={7.00,116.00},size={170.00,63.00},title="Tip, ∆"
	GroupBox tip,labelBack=(49151,53155,65535),fStyle=1,fColor=(0,0,65535)
	SetVariable tip_H,pos={36.00,132.00},size={134.00,18.00},bodyWidth=76,title="height (H)"
	SetVariable tip_H,format="%.2e m"
	SetVariable tip_H,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_H
	SetVariable tip_offset,pos={18.00,154.00},size={153.00,19.00},bodyWidth=77,title="offset (\\F'Symbol'Δ\\F'Segoe UI'L;Y\\Btip\\M)"
	SetVariable tip_offset,format="%.2e m"
	SetVariable tip_offset,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_Xtip
	GroupBox SensitivityZ,pos={347.00,61.00},size={250.00,145.00},title="Sensitivity z, ∆S/S"
	GroupBox SensitivityZ,labelBack=(56576,56576,56576),font="Segoe UI"
	GroupBox SensitivityZ,fSize=12,frame=0,fStyle=1
	GroupBox SensitivityZ_noncont,pos={474.00,80.00},size={117.00,95.00},title="non-contact"
	GroupBox SensitivityZ_noncont,labelBack=(65280,48896,48896),font="Arial"
	GroupBox SensitivityZ_noncont,fSize=12,fStyle=0,fColor=(65280,0,0)
	GroupBox SensitivityZ_cont,pos={352.00,80.00},size={118.00,94.00},title="contact"
	GroupBox SensitivityZ_cont,labelBack=(48896,59904,65280),font="Arial"
	GroupBox SensitivityZ_cont,fSize=12,fStyle=0,fColor=(0,0,65280)
	GroupBox SensitivityY,pos={347.00,212.00},size={250.00,141.00},title="Sensitivity y, ∆S/S"
	GroupBox SensitivityY,labelBack=(56576,56576,56576),font="Segoe UI"
	GroupBox SensitivityY,fSize=12,frame=0,fStyle=1
	GroupBox SensitivityY_noncont,pos={475.00,228.00},size={116.00,93.00},title="non-contact"
	GroupBox SensitivityY_noncont,labelBack=(65280,48896,48896),font="Arial"
	GroupBox SensitivityY_noncont,fSize=12,fStyle=0,fColor=(65280,0,0)
	GroupBox SensitivityY_cont,pos={353.00,228.00},size={118.00,94.00},title="contact"
	GroupBox SensitivityY_cont,labelBack=(48896,59904,65280),font="Arial"
	GroupBox SensitivityY_cont,fSize=12,fStyle=0,fColor=(0,0,65280)
	SetVariable Sz_cont,pos={358.00,96.00},size={106.00,20.00},bodyWidth=92,title="S\\Bz"
	SetVariable Sz_cont,format="%.4g",fColor=(0,0,52224)
	SetVariable Sz_cont,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_Sz_cont_R
	SetVariable Sz_noncont,pos={479.00,98.00},size={106.00,20.00},bodyWidth=92,title="S\\Bz"
	SetVariable Sz_noncont,format="%.4g",fColor=(65280,0,0)
	SetVariable Sz_noncont,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_Sz_noncont_R
	SetVariable SFz_noncont,pos={477.00,123.00},size={108.00,22.00},bodyWidth=91,title="S\\BF\\Bz"
	SetVariable SFz_noncont,format="%.4g",fColor=(65280,0,0)
	SetVariable SFz_noncont,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_SFf_noncont_R
	SetVariable SFz_cont,pos={355.00,121.00},size={109.00,22.00},bodyWidth=92,title="S\\BF\\Bz"
	SetVariable SFz_cont,format="%.4g",fColor=(0,0,52224)
	SetVariable SFz_cont,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_SFf_cont_R
	SetVariable Sy_cont,pos={359.00,245.00},size={106.00,20.00},bodyWidth=92,title="S\\By"
	SetVariable Sy_cont,format="%.4g",fColor=(0,0,52224)
	SetVariable Sy_cont,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_Sy_cont_R
	SetVariable Sy_noncont,pos={482.00,245.00},size={103.00,20.00},bodyWidth=89,title="S\\By"
	SetVariable Sy_noncont,format="%.4g",fColor=(65535,0,0)
	SetVariable Sy_noncont,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_Sy_noncont_R
	SetVariable SFy_noncont,pos={480.00,269.00},size={105.00,22.00},bodyWidth=88,title="S\\BF\\By"
	SetVariable SFy_noncont,format="%.4g",fColor=(65535,0,0)
	SetVariable SFy_noncont,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_SFt_noncont_R
	SetVariable SFy_cont,pos={352.00,269.00},size={112.00,22.00},bodyWidth=92,title=" S\\BF\\By"
	SetVariable SFy_cont,format="%.4g",fColor=(0,0,52224)
	SetVariable SFy_cont,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_SFt_cont_R
	SetVariable Sz_CorrectionFactor,pos={386.00,179.00},size={204.00,20.00},bodyWidth=56,title="Correction factor ∆χ\\Bz,n\\M/χ\\Bz,n"
	SetVariable Sz_CorrectionFactor,format="%.2e"
	SetVariable Sz_CorrectionFactor,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_CorrFactorZ_R
	SetVariable Sy_CorrectionFactor,pos={386.00,326.00},size={204.00,20.00},bodyWidth=56,title="Correction factor ∆χ\\Bθ,n\\M/χ\\Bθ,n"
	SetVariable Sy_CorrectionFactor,format="%.2e"
	SetVariable Sy_CorrectionFactor,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_CorrFactorY_R
	SetVariable Sslopez_cont,pos={357.00,148.00},size={107.00,20.00},bodyWidth=92,title="S\\Bθ"
	SetVariable Sslopez_cont,format="%.4g",fColor=(0,0,52224)
	SetVariable Sslopez_cont,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_Sthetaf_cont_R
	SetVariable Sslopez_noncont,pos={480.00,149.00},size={105.00,20.00},bodyWidth=90,title="S\\Bθ"
	SetVariable Sslopez_noncont,format="%.4g",fColor=(65280,0,0)
	SetVariable Sslopez_noncont,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_Sthetaf_noncont_R
	SetVariable Sslopey_cont,pos={354.00,295.00},size={111.00,20.00},bodyWidth=93,title=" S\\Bθ"
	SetVariable Sslopey_cont,format="%.4g",fColor=(0,0,52224)
	SetVariable Sslopey_cont,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_Sthetat_cont_R
	SetVariable Sslopey_noncont,pos={482.00,295.00},size={102.00,20.00},bodyWidth=87,title="S\\Bθ"
	SetVariable Sslopey_noncont,format="%.4g",fColor=(65535,0,0)
	SetVariable Sslopey_noncont,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_Sthetat_noncont_R

	GroupBox Sensitivity,pos={347.00,5.00},size={252.00,52.00},title="Sensitivity, ∆S"
	GroupBox Sensitivity,labelBack=(56576,56576,56576),font="Segoe UI"
	GroupBox Sensitivity,fSize=12,frame=0,fStyle=1
	SetVariable Sz_contExp,pos={358.00,27.00},size={106.00,20.00},bodyWidth=92,title="S\\Bz"
	SetVariable Sz_contExp,format="%.4g V/m",fColor=(0,0,52224)
	SetVariable Sz_contExp,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_Sz_cont
	SetVariable Sy_contExp,pos={479.00,27.00},size={106.00,20.00},bodyWidth=92,title="S\\By"
	SetVariable Sy_contExp,format="%.4g V/m",fColor=(0,0,52224)
	SetVariable Sy_contExp,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_Sy_cont

	GroupBox SpringConst,pos={185.00,6.00},size={153.00,349.00},title="Spring Constant, ∆k/k"
	GroupBox SpringConst,labelBack=(56576,56576,56576),font="Segoe UI",fSize=12
	GroupBox SpringConst,frame=0,fStyle=1
	GroupBox ky,pos={190.00,246.00},size={142.00,105.00},title="k\\By"
	GroupBox ky,labelBack=(60928,60928,60928),fStyle=1
	GroupBox kz,pos={191.00,31.00},size={142.00,108.00},title="k\\Bz"
	GroupBox kz,labelBack=(61166,61166,61166),fStyle=1
	GroupBox ktheta,pos={191.00,139.00},size={142.00,106.00},title="k\\Bθ"
	GroupBox ktheta,labelBack=(60928,60928,60928),fStyle=1
	SetVariable kz_theor,pos={198.00,50.00},size={128.00,18.00},bodyWidth=90,title="theory"
	SetVariable kz_theor,format="%.4g"
	SetVariable kz_theor,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_kzs_theory_R
	SetVariable kz_therm,pos={200.00,71.00},size={127.00,18.00},bodyWidth=91,title="therm"
	SetVariable kz_therm,format="%.4g"
	SetVariable kz_therm,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_kzs_EqTh_R
	SetVariable kz_Sader,pos={203.00,93.00},size={124.00,18.00},bodyWidth=91,title="Sader"
	SetVariable kz_Sader,format="%.4g"
	SetVariable kz_Sader,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_kzs_Sader_R
	SetVariable kz_FS,pos={196.00,115.00},size={131.00,18.00},bodyWidth=92,title="Flu-Str"
	SetVariable kz_FS,format="%.4g"
	SetVariable kz_FS,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_kzs_FluidStruc_R
	SetVariable kTheta_theor,pos={197.00,158.00},size={131.00,18.00},bodyWidth=93,title="theory"
	SetVariable kTheta_theor,format="%.4g"
	SetVariable kTheta_theor,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_kthetas_theory_R
	SetVariable kTheta_therm,pos={199.00,179.00},size={129.00,18.00},bodyWidth=93,title="therm"
	SetVariable kTheta_therm,format="%.4g"
	SetVariable kTheta_therm,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_kthetas_EqTh_R
	SetVariable kTheta_Sader,pos={200.00,200.00},size={127.00,18.00},bodyWidth=94,title="Sader"
	SetVariable kTheta_Sader,format="%.4g"
	SetVariable kTheta_Sader,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_kthetas_Sader_R
	SetVariable ktheta_FS,pos={195.00,220.00},size={133.00,18.00},bodyWidth=94,title="Flu-Str"
	SetVariable ktheta_FS,format="%.4g"
	SetVariable ktheta_FS,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_kthetas_FluidStruc_R
	SetVariable ky_theor,pos={196.00,263.00},size={129.00,18.00},bodyWidth=91,title="theory"
	SetVariable ky_theor,format="%.4g"
	SetVariable ky_theor,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_kys_theory_R
	SetVariable ky_therm,pos={198.00,284.00},size={128.00,18.00},bodyWidth=92,title="therm"
	SetVariable ky_therm,format="%.4g"
	SetVariable ky_therm,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_kys_EqTh_R
	SetVariable ky_Sader,pos={201.00,306.00},size={125.00,18.00},bodyWidth=92,title="Sader"
	SetVariable ky_Sader,format="%.4g"
	SetVariable ky_Sader,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_kys_Sader_R
	SetVariable ky_FS,pos={196.00,328.00},size={130.00,18.00},bodyWidth=91,title="Flu-Str"
	SetVariable ky_FS,format="%.4g"
	SetVariable ky_FS,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_kys_FluidStruc_R
	SetVariable mode,pos={246.00,22.00},size={72.00,18.00},bodyWidth=37,proc=SetVarProc_SwitchPeak,title="mode"
	SetVariable mode,limits={1,5,1},value= root:packages:AFM_Calibration:current_peak
	GroupBox CantMode,pos={7.00,180.00},size={170.00,67.00},title="Hydrodyn. func., ∆Γ"
	GroupBox CantMode,labelBack=(56797,56797,56797),fSize=12,fStyle=1
	SetVariable HydrodynFuncIm,pos={40.00,221.00},size={133.00,20.00},bodyWidth=76,title="Im Γ\\Bi\\M(ν\\Bn\\M,κ)"
	SetVariable HydrodynFuncIm,format="%.4g"
	SetVariable HydrodynFuncIm,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_Gi
	SetVariable HydrodynFuncRe,pos={39.00,197.00},size={133.00,20.00},bodyWidth=76,title="Re Γ\\Br\\M(ν\\Bn\\M,κ)"
	SetVariable HydrodynFuncRe,format="%.4g"
	SetVariable HydrodynFuncRe,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_Gr
	GroupBox Peak,pos={8.00,249.00},size={169.00,107.00},title="Peak, ∆"
	GroupBox Peak,labelBack=(56797,56797,56797),fSize=12,fStyle=1
	SetVariable PeakArea,pos={66.00,266.00},size={103.00,18.00},bodyWidth=75,title="Area"
	SetVariable PeakArea,format="%.2e V²"
	SetVariable PeakArea,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_A
	SetVariable tau,pos={86.00,332.00},size={85.00,18.00},bodyWidth=75,title="τ"
	SetVariable tau,format="%.4g"
	SetVariable tau,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_tau
	SetVariable freq,pos={70.00,288.00},size={99.00,18.00},bodyWidth=74,title="freq"
	SetVariable freq,format="%.2g Hz"
	SetVariable freq,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_v0n
	SetVariable Qfactor,pos={83.00,310.00},size={88.00,18.00},bodyWidth=75,title="Q"
	SetVariable Qfactor,format="%g"
	SetVariable Qfactor,limits={0,inf,0},value= root:packages:AFM_Calibration:Errors:D_Q
EndMacro
