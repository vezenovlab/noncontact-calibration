#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.


// *** calculations of Gamma


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀↓↓↓
//	↓↓↓	DESCRIPTIVE COMMENT
Function/C circfunc(x)
	variable x
	
	variable/C circfunc
	variable/C i=sqrt(-1)

	circfunc= 1+((4*i*besselk(1,x)*(-i*sqrt(i*x)))/(sqrt(i*x)*besselk(0,x)*(-i*sqrt(i*x))))
	
	return circfunc
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀↓↓↓
//	↓↓↓	DESCRIPTIVE COMMENT
Function/C GammaImFlexSader(Re)
	variable Re
	
	variable tau=log(Re)

	variable real_Num=0.91324
	real_Num-=0.48274*tau
	real_Num+=0.46842*tau^2
	real_Num-=0.12886*tau^3
	real_Num+=0.044055*tau^4
	real_Num-=0.0035117*tau^5
	real_Num+=0.00069085*tau^6
	
	variable real_Den=1
	real_Den-=0.56964*tau
	real_Den+=0.48690*tau^2
	real_Den-=0.13444*tau^3
	real_Den+=0.045155*tau^4
	real_Den-=0.0035862*tau^5
	real_Den+=0.00069085*tau^6
	
	variable imag_Num=-0.024134
	imag_Num-=0.029256*tau
	imag_Num+=0.016294*tau^2
	imag_Num-=0.00010961*tau^3
	imag_Num+=0.000064577*tau^4
	imag_Num-=0.000044510*tau^5
	
	variable imag_Den=1
	imag_Den-=0.59702*tau
	imag_Den+=0.55182*tau^2
	imag_Den-=0.18357*tau^3
	imag_Den+=0.079156*tau^4
	imag_Den-=0.014369*tau^5
	imag_Den+=0.0028361*tau^6
	
	
	return cmplx(real_Num/real_Den, imag_Num/imag_Den)//*circfunc(Re)
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀↓↓↓
//	↓↓↓	DESCRIPTIVE COMMENT

Function/C GammaFunc(wGi_coef, wGr_coef, delta)
	wave wGi_coef, wGr_coef
	variable delta
	
	variable Gr=funcGreal(wGr_coef,delta)
	variable Gi=funcGimag(wGi_coef,delta)

	return cmplx(Gr, Gi)

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀↓↓↓
//	↓↓↓	DESCRIPTIVE COMMENT

ThreadSafe Function/C GammaZ(visc, dens,  width, frequency)
	variable visc, dens, width, frequency
	
	variable delta=sqrt(2*visc/(dens*2*pi*frequency))
	delta/=width
	
	return cmplx(aZ1+aZ2*delta, bZ1*delta+bZ2*delta^2)

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀↓↓↓
//	↓↓↓	DESCRIPTIVE COMMENT

ThreadSafe Function/C GammaX(visc, dens,  width, frequency)
	variable visc, dens, width, frequency
	
	variable delta=sqrt(2*visc/(dens*2*pi*frequency))
	delta/=width
	
	return cmplx(aX1+aX2*delta, bX1*delta+bX2*delta^2)

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀↓↓↓
//	↓↓↓	DESCRIPTIVE COMMENT
ThreadSafe Function/C GammaZkappa(Relog,norm_mode_Point)
	variable Relog,norm_mode_Point
	
	variable gammazIm=GammaZimag(Relog,norm_mode_Point)
	variable gammazRe=GammaZreal(Relog,norm_mode_Point)
	
	return cmplx(gammazRe, gammazIm)

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀↓↓↓
//	↓↓↓	DESCRIPTIVE COMMENT

ThreadSafe Function GammaZreal(Relog,norm_mode_Point)
	variable Relog,norm_mode_Point
	

	WAVE GammaFvs_Re_modeRe=root:Packages:AFM_Calibration:GammaFvs_Re_modeRe

	return Interp2D(GammaFvs_Re_modeRe, Relog, norm_mode_Point)
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀↓↓↓
//	↓↓↓	DESCRIPTIVE COMMENT
ThreadSafe Function GammaZimag(Relog,norm_mode_Point)
	variable Relog,norm_mode_Point
	

	WAVE GammaFvs_Re_modeIm=root:Packages:AFM_Calibration:GammaFvs_Re_modeIm

	return Interp2D(GammaFvs_Re_modeIm, Relog, norm_mode_Point)
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


// 		The Gamma theta function below
//	This function serves to do blank
//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀↓↓↓
Function/C GammaXkappa(Relog,norm_mode_Point)
	variable Relog,norm_mode_Point
	
	variable gammaxIm=GammaXimag(Relog,norm_mode_Point)
	variable gammaxRe=GammaXReal(Relog,norm_mode_Point)
	
	return cmplx(gammaxRe, gammaxIm)

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
ThreadSafe Function GammaXreal(Relog,norm_mode_Point)
	variable Relog,norm_mode_Point
	
	WAVE GammaTvs_Re_modeRe=root:Packages:AFM_Calibration:GammaTvs_Re_modeRe

	return Interp2D(GammaTvs_Re_modeRe, Relog, norm_mode_Point)
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
ThreadSafe Function GammaXimag(Relog,norm_mode_Point)
	variable Relog,norm_mode_Point
	
	WAVE GammaTvs_Re_modeIm=root:Packages:AFM_Calibration:GammaTvs_Re_modeIm

	return Interp2D(GammaTvs_Re_modeIm, Relog, norm_mode_Point)
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑

// *** end calculations of Gamma

// *** calculations of sensitiviities

//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function OLSGaussBeam(x0, c)
	variable x0, c
	
	make/O/N=100 wOLS, wI0	
	SetScale/I x 0,1,"", wOLS, wI0
	wOLS=3/2*x*(2-x)*exp(-c*(x-x0)^2)
	
	wI0=exp(-c*(x-x0)^2)
	
	variable OLS=area(wOLS)/area(wI0)
	KillWAves/Z wOLS, wI0
	
	return OLS

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
// Calculates (dw/dx)/w for a picket-shaped cantilever
// when the laser beam is positioned on a rectangular section  
// L1 = length of the rectangular section (normalized by total length) measured from base
// p=(1-b1/b0) = sharpness of the end, p=1 for a pointed end
// xtip = tip position
Function OLSrect(L1, p, xtip,x)
	variable L1, p, xtip, x
	
	
	variable a=p/(1-L1)
	variable OLS=1/2
	variable wtip=0
	variable ksitip=1-a*(xtip-L1)
	
	OLS*=2*xtip*x-x*x
	wtip=L1*(L1^2/3-L1*xtip+xtip^2)
	wtip+=1/2/a^3*(1-ksitip)*(1-3*ksitip)
	wtip-=1/a^3*ksitip^2*ln(ksitip)

	return OLS/wtip

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
// Calculates (dw/dx)/w for a picket-shaped cantilever
// when the laser beam is positioned on a triangular section  
// L1 = length of the rectangular section (normalized by total length) measured from base
// p=(1-b1/b0) = sharpness of the end, p=1 for a pointed end
// xtip = tip position
Function OLStri(L1, p, xtip,x)
	variable L1, p, xtip, x
	
	
	variable a=p/(1-L1)
	variable OLS=0
	variable wtip=0
	variable ksi=1-a*(x-L1)
	variable ksitip=1-a*(xtip-L1)
	
	OLS=L1*(xtip-L1/2)+(x-L1)/a+1/a^2*ksitip*ln(ksi)
	wtip=L1*(L1^2/3-L1*xtip+Xtip^2)
	wtip+=1/2/a^3*(1-ksitip)*(1-3*ksitip)
	wtip-=1/a^3*ksitip^2*ln(ksitip)

	return OLS/wtip

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
// Calculates (dw/dx)/w for a picket-shaped cantilever
// Determines which section (rectangular or triangular) the laser beam is positioned on
// L1 = length of the rectangular section (normalized by total length) measured from base
// p=(1-b1/b0) = sharpness of the end, p=1 for a pointed end
// xtip = tip position

// for now assume rectangualr shape

Function OLSpicket(L1, p, xtip, x)
	variable L1, p, xtip, x
	
//	return OLSrect(L1, p, xtip, x)*(x<=L1)+OLStri(L1, p, xtip, x)*(x>L1)

	variable Sz=3/2*xtip/x*(2-xtip/x)

	return 1/Sz

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑

// *** end of calculations of sensitiviities

// *** calculations of cantilever parameters


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Calc_thickness(a, b, L, E, density, n, freq)
	variable a, b, L, E, density, n, freq
	
	
	variable thickness=2*pi*3*sqrt(2)*(L/C_n(n))^2*sqrt(density/E)/sqrt(1+2*a*b/(a+b)^2)*freq
	
	return thickness	

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Calc_spring0(a, b, L, thick, E)
	variable a, b, L, thick, E
	
	
	variable spring=1/12*E*(thick/L)^3*(a^2+4*a*b+b^2)/(a+b)
	
	return spring	

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Volume_Cone(height, angle)
	variable height, angle

 	return pi/3*height^3*(tan(angle/180*pi))^2
 
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑



//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Calc_angle(a, b, t)
	variable a, b, t
	
	return atan(2*t/abs(b-a))*180/pi

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Calc_thick_PlainDim(a, b, angle)
	variable a, b, angle
	
	return tan(angle*pi/180)*(b-a)/2

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
// mass of cant from tau
Function m_cant(rhof, width, length, mf2mc)
	variable rhof, width, length, mf2mc
	
	variable mf=rhof*pi*(width/2)^2*length
	
	return mf/mf2mc

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
// mass of cant from density and dimensions
Function m_cant2(rho, width, length, thick)
	variable rho, width, length, thick
	
	return rho*width*length*thick

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
// Calculates moment of inertia
Function Calc_I(a, b, t)
	variable a, b, t
	
	variable I=(a+b)/2*t^3/12
	// correct for non-rectangular shape
	variable r=a/b
	I*=2/3*(1+2*r/(1+r)^2)
	
	return I

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
// calculates ratio of moments of inertia 
// for trapezoid with base widths a and b 
// versus rectangular cross-section having the width (a+b)/2
Function Calc_I_Trap2Rect(r)
	variable r
	
	variable ratio
	
	ratio=2/3*(1+2*r/(1+r)^2)
	
	return ratio

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
// Calculates polar moment of inertia
Function Calc_Ip(a, b, t)
	variable a, b, t
	
	variable Ip=b^3*t/12
	// correct for non-rectangular shape
	variable r=a/b
	Ip*=(1+r)*(1+r^2)/4+(2*r+(1+r^2)/3/(1+r))*(t/b)^2
	
	return Ip

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
// calculates ratio of polar moments of inertia 
// for trapezoid with base widths a and b 
// versus rectangular cross-section having the width (a+b)/2
// and thickness to b side width ratio t2b
Function Calc_Ip_Trap2Rect(r, t2b)
	variable r, t2b
	
	variable ratio
	
	ratio=(1+r)*(1+r^2)/4+(2*r+(1+r^2)/3/(1+r))*t2b^2
	ratio/=((1+r)/2)^3
	
	return ratio

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Calc_Tip2Cant_Ratio(a, b, t, L, TipH, TipAngle)
	variable a, b, t, L, TipH, TipAngle
	
	variable vol_Cant=(a+b)/2*t*L
	variable vol_Tip=Volume_Cone(TipH, TipAngle)
	return vol_Tip/vol_Cant

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Thickness_from_Res(a, b, L, TipH, TipAngle, cant_mode_num, density, E, freq)
	variable a, b, L, TipH, TipAngle, cant_mode_num, density, E, freq
	
	make/O/N=3 W_coef
	
	variable width_avg=(a+b)/2
	variable delta=1/3*((1-a/b)/(1+a/b))^2
	W_coef[2]=Volume_Cone(TipH, TipAngle)
	W_coef[1]=3/C_n(cant_mode_num)^4*L*width_avg
	W_coef[0]=E*width_avg*(1-delta)/(4*density*L^3*(2*pi*freq)^2)
	
	FindRoots/B=0/L=1e-7/H=50e-6 /Q PolyForThick, W_coef
	
	return V_Root

	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function PolyForThick(w, x)
	wave w
	variable x
	
	return w[0]*x^3-w[1]*x-w[2]
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Cnvsmend(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = y0+(a+b*x)*atan(c*(x-x0))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 5
	//CurveFitDialog/ w[0] = a
	//CurveFitDialog/ w[1] = x0
	//CurveFitDialog/ w[2] = y0
	//CurveFitDialog/ w[3] = b
	//CurveFitDialog/ w[4] = c

	return w[2]+(w[0]+w[3]*x)*atan(w[4]*(x-w[1]))
End
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
ThreadSafe Function doubleExp(w,x)
	wave w
	variable x
		
	return w[0]+w[1]*exp(-w[2]*x)+w[3]*exp(-w[4]*x)

end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑





// ********************** interpolation inside fit function ***************


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
// this fit function uses interpolation to get values of Gamma
ThreadSafe Function SFO2Z(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation2:
	//CurveFitDialog/ f(x) = A*tau*Gi*x/((v0^2-(1+tau*Gr*x^2))^2+(tau*Gi*x^2)^2)
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
	NVAR/SDFR=dfcal L=cant_length
	NVAR/SDFR=dfcal D=cant_D

	variable Relog=log(dens*2*pi*x*w[3]^2/visc)
	variable mode_norm=C_n(w[4])*w[3]/(L-D/2)
	variable norm_mode_Point=11.357-7.0231*exp(-0.15569*mode_norm)-4.3563*exp(-1.9175*mode_norm)
	variable Gi=GammaZimag(Relog,norm_mode_Point)
	variable Gr=GammaZreal(Relog,norm_mode_Point)

	Relog=log(dens*2*pi*w[1]*w[3]^2/visc)
	variable Gi0=GammaZimag(Relog,norm_mode_Point)
	variable Gr0=GammaZreal(Relog,norm_mode_Point)

	variable result=w[0]
	result*=w[2]*Gi0*w[1]*w[2]*Gi*x*w[1]^2
	result/=(((1+w[2]*Gr0)*w[1]^2-(1+w[2]*Gr)*x^2)^2+(w[2]*Gi)^2*x^4)

	return result
End


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
// this fit function uses interpolation to get values of Gamma
ThreadSafe Function SFO2vnZ(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation2:
	//CurveFitDialog/ f(x) = A*tau*Gi*x/((v0^2-(1+tau*Gr*x^2))^2+(tau*Gi*x^2)^2)
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
	NVAR/SDFR=dfcal L=cant_length
	NVAR/SDFR=dfcal D=cant_D

	variable ReNum=(dens*2*pi*x*w[3]^2)/visc
	variable Relog=log(ReNum)
	variable mode_norm=C_n(w[4])*w[3]/(L-D/2)
	variable norm_mode_Point=11.357-7.0231*exp(-0.15569*mode_norm)-4.3563*exp(-1.9175*mode_norm)
	variable Gi=GammaZimag(Relog,norm_mode_Point)
	variable Gr=GammaZreal(Relog,norm_mode_Point)

	variable result=w[0]*w[2]*Gi*(x)/((w[1]^2-(1+w[2]*Gr)*(x)^2)^2+(w[2]*Gi)^2*(x)^4)

	return result
End


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
// this fit function uses interpolation to get values of Gamma
ThreadSafe Function SFO2X(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation2:
	//CurveFitDialog/ f(x) = A*tau*Gi*x/((v0^2-(1+tau*Gr*x^2))^2+(tau*Gi*x^2)^2)
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
	NVAR/SDFR=dfcal L=cant_length
	NVAR/SDFR=dfcal D=cant_D

	variable Relog=log(dens*2*pi*x*w[3]^2/visc)
	variable mode_norm=C_n(w[4])*w[3]/(L-D/2)
	variable norm_mode_Point=11.357-7.0231*exp(-0.15569*mode_norm)-4.3563*exp(-1.9175*mode_norm)
	variable Gi=GammaXimag(Relog,norm_mode_Point)
	variable Gr=GammaXreal(Relog,norm_mode_Point)
	
	Relog=log(dens*2*pi*w[1]*w[3]^2/visc)
	variable Gi0=GammaXimag(Relog,norm_mode_Point)
	variable Gr0=GammaXreal(Relog,norm_mode_Point)

	variable result=w[0]
	result*=w[2]*Gi0*w[1]*w[2]*Gi*x*w[1]^2
	result/=(((1+w[2]*Gr0)*w[1]^2-(1+w[2]*Gr)*x^2)^2+(w[2]*Gi)^2*x^4)

	return result
End


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
// this fit function uses interpolation to get values of Gamma
ThreadSafe Function SFO2vnX(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation2:
	//CurveFitDialog/ f(x) = A*tau*Gi*x/((v0^2-(1+tau*Gr*x^2))^2+(tau*Gi*x^2)^2)
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
	NVAR/SDFR=dfcal L=cant_length
	NVAR/SDFR=dfcal D=cant_D

	variable ReNum=(dens*2*pi*x*w[3]^2)/visc
	variable Relog=log(ReNum)
	variable mode_norm=C_n(w[4])*w[3]/(L-D/2)
	variable norm_mode_Point=11.357-7.0231*exp(-0.15569*mode_norm)-4.3563*exp(-1.9175*mode_norm)
	variable Gi=GammaXimag(Relog,norm_mode_Point)
	variable Gr=GammaXreal(Relog,norm_mode_Point)

	variable result=w[0]*w[2]*Gi*(x)/((w[1]^2-(1+w[2]*Gr)*(x)^2)^2+(w[2]*Gi)^2*(x)^4)

	return result
End

