#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.



//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
ThreadSafe Function SHO(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = A*2/pi*v0^2*(v0/Q)/((x^2-v0^2)^2+(x*v0/Q)^2)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 3
	//CurveFitDialog/ w[0] = A
	//CurveFitDialog/ w[1] = v0
	//CurveFitDialog/ w[2] = Q

	return w[0]*2/pi*(w[1]^3/w[2])/((x^2-w[1]^2)^2+(x*w[1]/w[2])^2)
End


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
ThreadSafe Function Lorentzian(w,x)
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = A*2/pi*(v0/4)/((v0-x)^2+(v0/2Q)^2)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 3
	//CurveFitDialog/ w[0] = A
	//CurveFitDialog/ w[1] = v0
	//CurveFitDialog/ w[2] = Q

	return w[0]*2/pi*w[1]/(4*w[2])/((w[1]-x)^2+(w[1]/(2*w[2]))^2)
end


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
ThreadSafe Function SFO(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation2:
	//CurveFitDialog/ f(x) = A*2/pi*v0^2*(x/Q)/((v0^2-x^2)^2+(x^2/Q)^2)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 3
	//CurveFitDialog/ w[0] = A
	//CurveFitDialog/ w[1] = v0
	//CurveFitDialog/ w[2] = Q

	variable result=w[0]*2/pi*w[1]^2*x/w[2]/((w[1]^2-x^2)^2+(x^2/w[2])^2)

	return result
End



//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
ThreadSafe Function SFO_pq(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation2:
	//CurveFitDialog/ f(x) = A*2/pi*v0^2*(x/Q)/((v0^(2-p)x^p-x^2)^2+(x^2/Q)^2)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 5
	//CurveFitDialog/ w[0] = A
	//CurveFitDialog/ w[1] = v0
	//CurveFitDialog/ w[2] = Q0
	//CurveFitDialog/ w[3] = p
	//CurveFitDialog/ w[4] = q

	variable result=w[0]*2/pi*w[1]^(2-(w[3]-w[4]))*x^(w[3]-w[4])*x/w[2]
	
	result/=(w[1]^(2-w[3])*x^w[3]-x^2)^2+(w[1]^w[4]*x^(2-w[4])/w[2])^2

	return result
End


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
ThreadSafe Function SFOfull_k0_v0(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation2:
	//CurveFitDialog/ f(x) = A*2/pi*v0^2*(1+tau*Gr0)*tau*Gi*x/(((1+tau*Gr0)*v0^2-(1+tau*Gr)*x^2))^2+(tau*Gi*x^2)^2)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 5
	//CurveFitDialog/ w[0] = A
	//CurveFitDialog/ w[1] = v0
	//CurveFitDialog/ w[2] = tau
	//CurveFitDialog/ w[3] = b
	//CurveFitDialog/ w[4] = n

	DFREF dfcal=root:Packages:AFM_Calibration:
	NVAR/SDFR=dfcal dens=medium_dens
	NVAR/SDFR=dfcal visc=medium_visc

	wave/SDFR=dfcal wGi_coef=wGi_coefInf
	wave/SDFR=dfcal wGr_coef=wGr_coefInf

	variable Re=dens*2*pi*x*w[3]^2/visc
	variable delta=sqrt(2/Re)
	variable Gi=funcGimag(wGi_coef,delta)
	variable Gr=funcGreal(wGr_coef,delta)

	Re=dens*2*pi*w[1]*w[3]^2/visc
	delta=sqrt(2/Re)
	variable Gi0=funcGimag(wGi_coef,delta)
	variable Gr0=funcGreal(wGr_coef,delta)

	variable result=w[0]*2/pi*w[1]^2
	result*=(1+w[2]*Gr0)
	result*=w[2]*Gi*x
	result/=(((1+w[2]*Gr0)*w[1]^2-(1+w[2]*Gr)*x^2)^2+(w[2]*Gi)^2*x^4)

	return result
End

//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
ThreadSafe Function SFOfull_k0_vn(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation2:
	//CurveFitDialog/ f(x) = A*2/pi*vn^2*tau*Gi*x/((vn^2-(1+tau*Gr)*x^2)^2+(tau*Gi*x^2)^2)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 5
	//CurveFitDialog/ w[0] = A
	//CurveFitDialog/ w[1] = vn
	//CurveFitDialog/ w[2] = tau
	//CurveFitDialog/ w[3] = b
	//CurveFitDialog/ w[4] = n

	DFREF dfcal=root:Packages:AFM_Calibration:
	NVAR/SDFR=dfcal dens=medium_dens
	NVAR/SDFR=dfcal visc=medium_visc

	wave/SDFR=dfcal wGi_coef=wGi_coefInf
	wave/SDFR=dfcal wGr_coef=wGr_coefInf

	variable Re=dens*2*pi*x*w[3]^2/visc
	variable delta=sqrt(2/Re)
	variable Gi=funcGimag(wGi_coef,delta)
	variable Gr=funcGreal(wGr_coef,delta)

	variable result=w[0]*2/pi*w[1]^2
	result*=w[2]*Gi*x
	result/=((w[1]^2-(1+w[2]*Gr)*x^2)^2+(w[2]*Gi)^2*x^4)

	return result
End


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
ThreadSafe Function SFOfull_k_v0(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation2:
	//CurveFitDialog/ f(x) = A*2/pi*v0^2*(1+tau*Gr0)*tau*Gi*x/(((1+tau*Gr0)*v0^2-(1+tau*Gr)*x^2))^2+(tau*Gi*x^2)^2)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 5
	//CurveFitDialog/ w[0] = A
	//CurveFitDialog/ w[1] = v0
	//CurveFitDialog/ w[2] = tau
	//CurveFitDialog/ w[3] = b
	//CurveFitDialog/ w[4] = n

	DFREF dfcal=root:Packages:AFM_Calibration:
	NVAR/SDFR=dfcal dens=medium_dens
	NVAR/SDFR=dfcal visc=medium_visc

	wave/SDFR=dfcal wGi_coef=$("wGi_coef"+num2str(w[4]))
	wave/SDFR=dfcal wGr_coef=$("wGr_coef"+num2str(w[4]))

	variable Re=dens*2*pi*x*w[3]^2/visc
	variable delta=sqrt(2/Re)
	variable Gi=funcGimag(wGi_coef,delta)
	variable Gr=funcGreal(wGr_coef,delta)

	Re=dens*2*pi*w[1]*w[3]^2/visc
	delta=sqrt(2/Re)
	variable Gi0=funcGimag(wGi_coef,delta)
	variable Gr0=funcGreal(wGr_coef,delta)

	variable result=w[0]*2/pi*w[1]^2
	result*=(1+w[2]*Gr0)
	result*=w[2]*Gi*x
	result/=(((1+w[2]*Gr0)*w[1]^2-(1+w[2]*Gr)*x^2)^2+(w[2]*Gi)^2*x^4)

	return result
End


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
ThreadSafe Function SFOfull_k_vn(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation2:
	//CurveFitDialog/ f(x) = A*2/pi*vn^2*tau*Gi*x/((vn^2-(1+tau*Gr)*x^2)^2+(tau*Gi*x^2)^2)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 5
	//CurveFitDialog/ w[0] = A
	//CurveFitDialog/ w[1] = vn
	//CurveFitDialog/ w[2] = tau
	//CurveFitDialog/ w[3] = b
	//CurveFitDialog/ w[4] = n

	DFREF dfcal=root:Packages:AFM_Calibration:
	NVAR/SDFR=dfcal dens=medium_dens
	NVAR/SDFR=dfcal visc=medium_visc

	wave/SDFR=dfcal wGi_coef=$("wGi_coef"+num2str(w[4]))
	wave/SDFR=dfcal wGr_coef=$("wGr_coef"+num2str(w[4]))

	variable Re=dens*2*pi*x*w[3]^2/visc
	variable delta=sqrt(2/Re)
	variable Gi=funcGimag(wGi_coef,delta)
	variable Gr=funcGreal(wGr_coef,delta)

	variable result=w[0]*2/pi*w[1]^2
	result*=w[2]*Gi*x
	result/=((w[1]^2-(1+w[2]*Gr)*x^2)^2+(w[2]*Gi)^2*x^4)

	return result
End

// ********************** fit functions with respect to delta ***************


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
ThreadSafe Function dSFOfull_k_v0(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation2:
	//CurveFitDialog/ f(x) = A*2/pi*v0^2*(1+tau*Gr0)*tau*Gi*x/(((1+tau*Gr0)*v0^2-(1+tau*Gr)*x^2))^2+(tau*Gi*x^2)^2)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 3
	//CurveFitDialog/ w[0] = A
	//CurveFitDialog/ w[1] = d0
	//CurveFitDialog/ w[2] = tau

	DFREF dfcal=root:Packages:AFM_Calibration:

	wave/SDFR=dfcal wGi_coef
	wave/SDFR=dfcal wGr_coef

	variable Gr0=funcGreal(wGr_coef,w[1])
	variable Gr=funcGreal(wGr_coef,x)
	variable Gi=funcGimag(wGi_coef,x)

	variable delta0n=w[1]*((1+w[2]*Gr)/(1+w[2]*Gr0))^(1/4)
	variable Q=(1+w[2]*Gr)/(w[2]*Gi)

	variable result=w[0]*4/pi
	result*=delta0n^4*x^3/Q
	result/=(x^4-delta0n^4)^2+(delta0n^4/Q)^2

	return result
End


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
ThreadSafe Function dSFO_pq(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation2:
	//CurveFitDialog/ f(x) = A*2/pi*v0^2*(x/Q)/((v0^(2-p)x^p-x^2)^2+(x^2/Q)^2)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 5
	//CurveFitDialog/ w[0] = A
	//CurveFitDialog/ w[1] = d0
	//CurveFitDialog/ w[2] = Q0
	//CurveFitDialog/ w[3] = p
	//CurveFitDialog/ w[4] = q

	variable result=w[0]*4/pi*w[1]^(4+2*(w[3]-w[4]))*x^(3-2*(w[3]-w[4]))/w[2]
	
	result/=(w[1]^(2*w[3])*x^(4-2*w[3])-w[1]^4)^2+(w[1]^(4-2*w[4])*x^(2*w[4])/w[2])^2

	return result
End


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function CalcQ0(del0, tau)
	variable del0, tau


	DFREF dfcal=root:Packages:AFM_Calibration:

	wave/SDFR=dfcal wGi_coef
	wave/SDFR=dfcal wGr_coef

	variable Gr0=funcGreal(wGr_coef,del0)
	variable Gi0=funcGimag(wGi_coef,del0)

	variable Q=(1+tau*Gr0)/(tau*Gr0)
	
	return Q

end

