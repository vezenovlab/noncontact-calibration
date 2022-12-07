#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//
// BENDING
//

//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
ThreadSafe Function C_n(n)
	variable n
	
	make/O/N=1 w
	FindRoots /B=0 /H=((n-1/2)*pi+pi/8)  /L=((n-1/2)*pi-pi/8) /Q CosCosh, w
	
	Killwaves/Z w

	return V_Root
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
ThreadSafe Function CosCosh(w, x)
	wave w
	variable x
	
	return 1+cos(x)*cosh(x)
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function C_n_m(n, m_tip)
	variable n, m_tip
	
	make/O/N=1 w
	w[0]=m_tip
	if(m_tip>=0)
		FindRoots /B=0 /H=((n-1/2)*pi+pi/3)  /L=((n-1/2)*pi-pi/1.3) /Q CosCosh_m, w
	else
		FindRoots /B=0 /H=((n-1/2)*pi+pi/1.3)  /L=((n-1/2)*pi-pi/3) /Q CosCosh_m, w
	endif

	Killwaves/Z w

	return V_Root
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function/D CosCosh_m(w, x)
	wave w
	variable x
	
	return 1+cos(x)*cosh(x)+w[0]*x*(cos(x)*sinh(x)-sin(x)*cosh(x))
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
//
// very hard to bracket
// the algortith below is settled via try and error
// if root is missing because Igor could not bracket the root
// i.e. min and max both have the same sign
// then slide the brackets to the right slowly
//
Function C_n_m_I(n, m_tip, I_tip)
	variable n, m_tip, I_tip
	
	variable Cn

	make/O/D/N=2 w
	w[0]=m_tip
	w[1]=I_tip
	
	variable high=pi
	variable low=0
	
	variable i,j

	for(i=1;i<n+1;i+=1)

		FindRoots /B=0 /H=(high)  /L=(low) /Q CosCosh_m_I, w
		
	
		if(V_flag)
			high=Cn+pi*17/16
			low=Cn+pi/16
	
			FindRoots /B=0 /H=(high)  /L=(low) /Q CosCosh_m_I, w
			
		endif

		for(j=0;j<32;j+=1)
			if(V_flag)
				high+=pi/32
				low+=pi/32
		
				FindRoots /B=0 /H=(high)  /L=(low) /Q CosCosh_m_I, w
				
			else
				break				
			endif
		endfor

		Cn=V_Root
		high=Cn+pi*6/5
		low=Cn+pi/5

		
	endfor
	

	return Cn
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑



//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function/D CosCosh_m_I(w, x)
	wave w
	variable x
	
	variable f=1+cos(x)*cosh(x)
	f+=w[0]*x*(cos(x)*sinh(x)-sin(x)*cosh(x))
	f-=w[1]*x^3*(cos(x)*sinh(x)+sin(x)*cosh(x))
	f+=w[0]*w[1]*x^4*(1-cos(x)*cosh(x))
	
	return f
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


// MODE SHAPE
// All mode shape functions are non-normalized
// use normalization coef function to calculate Nn


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Phi_n_Coef(Cn)
	variable Cn
	
	variable coef=sin(Cn)-sinh(Cn)
	coef/=cos(Cn)+cosh(Cn)
	
	return coef
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑



//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Phi_n_Coef_m(Cn,mend2mc)
	variable Cn,mend2mc
	
	variable coef=(sin(Cn)-sinh(Cn))+mend2mc*Cn*(cos(Cn)-cosh(Cn))
	coef/=(cos(Cn)+cosh(Cn))-mend2mc*Cn*(sin(Cn)-sinh(Cn))
	
	return coef
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑



//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Phi_n_Coef_I(Cn,Iend2Ic)
	variable Cn,Iend2Ic
	
	variable coef=(cos(Cn)+cosh(Cn))-Iend2Ic*Cn^3*(sin(Cn)+sinh(Cn))
	coef/=(sin(Cn)+sinh(Cn))+Iend2Ic*Cn^3*(cos(Cn)-cosh(Cn))
	coef*=-1
	
	return coef
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑



//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Phi_n(n,x)
	variable n, x
	
	variable Cn=C_n(n)
	
	variable phi=cos(Cn*x)-cosh(Cn*x)
	phi+=(sin(Cn*x)-sinh(Cn*x))*Phi_n_Coef(Cn)
	
	return phi
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Phi_n_m(n,x,mend2mc)
	variable n, x, mend2mc
	
	variable Cn=C_n_m(n, mend2mc)
	
	variable phi=(cos(Cn*x)-cosh(Cn*x))
	phi+=(sin(Cn*x)-sinh(Cn*x))*Phi_n_Coef_m(Cn,mend2mc)
	
	return phi
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Phi_n_m_I(n,x,mend2mc, Iend2Ic)
	variable n, x, mend2mc, Iend2Ic
	
	variable Cn=C_n_m_I(n, mend2mc, Iend2Ic)
	
	variable phi=(cos(Cn*x)-cosh(Cn*x))
	phi+=(sin(Cn*x)-sinh(Cn*x))*Phi_n_Coef_m(Cn,mend2mc)
	
	return phi
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


// MODE SHAPE DERIVATIVES
// All derivatiaves are non-normalized
// use normalization coef function to calculate Nn

//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
// derivative dphi/dx
Function dPhidx(n,x)
	variable n, x
	
	variable Cn=C_n(n)
	
	variable phider=-sin(Cn*x)-sinh(Cn*x)
	
	variable coef=(sin(Cn)-sinh(Cn))
	coef/=(cos(Cn)+cosh(Cn))

	phider+=(cos(Cn*x)-cosh(Cn*x))*coef
	phider*=-Cn
	
	return phider
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
// derivative dphi/dx
Function dPhidx_m(n,x,mend2mc)
	variable n, x, mend2mc
	
	variable Cn=C_n_m(n, mend2mc)
	
	variable phider=-sin(Cn*x)-sinh(Cn*x)
	
	phider+=(cos(Cn*x)-cosh(Cn*x))*Phi_n_Coef_m(Cn,mend2mc)
	phider*=-Cn
	
	return phider
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
// derivative dphi/dx
Function dPhidx_m_I(n,x,mend2mc, Iend2Ic)
	variable n, x, mend2mc, Iend2Ic
	
	variable Cn=C_n_m_I(n, mend2mc, Iend2Ic)
	
	variable phider=-sin(Cn*x)-sinh(Cn*x)

	phider+=(cos(Cn*x)-cosh(Cn*x))*Phi_n_Coef_m(Cn,mend2mc)
	phider*=-Cn
	
	return phider
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	NORMALIZATION


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Phi_n2Norm_m(n1, n2, mend2mc)
	variable n1, n2, mend2mc
	
	make/D/O/N=101 wphi1, wphi2, wphi_sq
	SetScale/I x 0,1,"", wphi1, wphi2, wphi_sq
	
	wphi1=Phi_n_m(n1,x,mend2mc)
	wphi2=Phi_n_m(n2,x,mend2mc)
	
	variable phix1=wphi1(1)
	variable phix2=wphi2(1)
	
	wphi_sq=wphi1*wphi2
	
	variable Nnm
	
	Nnm=area(wphi_sq,0,1)+mend2mc*phix1*phix2
	
	return sqrt(1/abs(Nnm))
	
	
end	
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Phi_n2Norm_m_I(n1, n2, mend2mc, Iend2Ic)
	variable n1, n2, mend2mc, Iend2Ic
	
	make/D/O/N=101 wphi1, wphi2, wphi_sq
	SetScale/I x 0,1,"", wphi1, wphi2, wphi_sq
	
	wphi1=Phi_n_m_I(n1,x,mend2mc, Iend2Ic)
	wphi2=Phi_n_m_I(n2,x,mend2mc, Iend2Ic)
	
	variable phix1=wphi1(1)
	variable phix2=wphi2(1)
	
	variable dphidx1=dPhidx_m_I(n1,1,mend2mc,Iend2Ic)
	variable dphidx2=dPhidx_m_I(n2,1,mend2mc,Iend2Ic)

	wphi_sq=wphi1*wphi2
	
	variable Nnm
	
	Nnm=area(wphi_sq,0,1)+mend2mc*phix1*phix2+Iend2Ic*dphidx1*dphidx2
	
	return sqrt(1/abs(Nnm))
	
	
end	
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Phi_n2Integral(n1,n2,mend2mc,Iend2Ic)
	variable n1,n2,mend2mc,Iend2Ic
	
	
	variable Cn_1=C_n_m_I(n1, mend2mc,Iend2Ic)
	variable Cn_2=C_n_m_I(n2, mend2mc,Iend2Ic)

	variable Integ	
	

	make/D/O/N=101 wphi1, wphi2, wphi_sq
	SetScale/I x 0,1,"", wphi1, wphi2, wphi_sq
	
	wphi1=Phi_n_m_I(n1,x,mend2mc,Iend2Ic)
	wphi2=Phi_n_m_I(n2,x,mend2mc,Iend2Ic)
	wphi_sq=wphi1*wphi2

	variable phix1=wphi1(1)
	variable phix2=wphi2(1)

	variable dphidx1=dPhidx_m_I(n1,1,mend2mc,Iend2Ic)
	variable dphidx2=dPhidx_m_I(n2,1,mend2mc,Iend2Ic)

	Integ=area(wphi_sq,0,1)+mend2mc*phix1*phix2+Iend2Ic*dphidx1*dphidx2
	
	if(n1==n2)
		Integ*=Phi_n2Norm_m_I(n1,n2,mend2mc,Iend2Ic)^2
	endif
	
	return Integ


end	
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//
// TORSION
//


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function D_n(n)
	variable n
	
	return pi*(2*n-1)/2
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑



//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function D_n_m(n, Iend2Ic)
	variable n, Iend2Ic
	
	make/O/N=1 w
	w[0]=Iend2Ic

	FindRoots /B=0 /H=(pi*(2*n-1)/2+0.99*pi/2)  /L=(pi*(2*n-1)/2-0.99*pi/2) /Q CotanX2X, w

	Killwaves/Z w

	return V_Root
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Psi_n(n,x)
	variable n, x
	
	variable Dn=D_n(n)
	
	return sin(Dn*x)
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Psi_n_m(n,x, Iend2Ic)
	variable n, x, Iend2Ic
	
	variable Dn=D_n_m(n,Iend2Ic)
	
	return sin(Dn*x)
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function CotanX2X(w, x)
	wave w
	variable x
	
	return cot(x)-w[0]*x
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Psi_n2Norm_m(n, Iend2Ic)
	variable n, Iend2Ic
	
	
	variable Dn=D_n_m(n, Iend2Ic)
	variable n2=2
	n2/=1+Iend2Ic*sin(Dn)^2
//	n2/=1-0.5*sin(2*Dn)+2*mend2mc*sin(Dn)^2
	
	return sqrt(n2)
	
	
end	
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Psi_n2Integral_m(n1,n2,Iend2Ic)
	variable n1,n2,Iend2Ic
	
	
	variable Dn_1=D_n_m(n1, Iend2Ic)
	variable Dn_2=D_n_m(n2, Iend2Ic)

	variable Integ	
	

	make/D/O/N=1001 wpsi1, wpsi2, wpsi_sq
	SetScale/I x 0,1,"", wpsi1, wpsi2, wpsi_sq
	
	wpsi1=Psi_n_m(n1,x,Iend2Ic)
	wpsi2=Psi_n_m(n2,x,Iend2Ic)
	wpsi_sq=wpsi1*wpsi2

	variable psix1=wpsi1(1)
	variable psix2=wpsi2(1)

	Integ=area(wpsi_sq,0,1)+Iend2Ic*psix1*psix2
	
	if(n1==n2)
		Integ*=Psi_n2Norm_m(n1, Iend2Ic)^2
	endif

	return Integ


end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑

//	END TORSION

//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function C_n3A(n, m_tip, I_tip)
	variable n, m_tip, I_tip
	
	variable Cn=C_n_m(1, m_tip)

	make/O/D/N=2 w
	w[0]=m_tip
	w[1]=I_tip
	
	variable high=Cn
	variable low=Cn
	
	variable i,j

	for(i=1;i<n+1;i+=1)

		if(I_tip>=0)
			high+=pi/1.4
			low-=pi/3
			else
				high+=pi/4
				low-=pi/1.1
		endif
	
		FindRoots /B=0 /H=(high)  /L=(low) /Q CosCosh_m_I, w
		
		for(j=0;j<128;j+=1)
			if(V_flag)
				high-=pi/256
				low+=pi/256
		
				FindRoots /B=0 /H=(high)  /L=(low) /Q CosCosh_m_I, w
				
			else
				break				
			endif
		endfor
		
		Cn=V_Root+pi
		high=Cn
		low=Cn

	endfor
	


//	Killwaves/Z w

	return V_Root
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑



//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function C_n3(n, m_tip, I_tip)
	variable n, m_tip, I_tip
	
	make/O/D/N=2 w
	w[0]=m_tip
	w[1]=I_tip
	
	variable high=(n-1/2)*pi
	variable low=high
	
	
	if(m_tip>=0)
		//FindRoots /B=0 /H=((n-1/2)*pi+pi/3)  /L=((n-1/2)*pi-pi/1.2) /Q CosCosh_m_I, w

		if(I_tip>=0)
			high+=pi/3
			low-=pi/1.2
		else
			high-=pi/3
			low-=pi/1.0
		endif


	else
		//FindRoots /B=0 /H=((n-1/2)*pi+pi/1.2)  /L=((n-1/2)*pi-pi/3) /Q CosCosh_m_I, w

		if(I_tip>=0)
			high+=pi/1.2
			low-=pi/3
		else
			high+=pi/4.5
			low-=pi/1.2
		endif


	endif

	FindRoots /B=0 /H=(high)  /L=(low) /Q CosCosh_m_I, w



	if(V_flag)
		high+=pi/16
		low+=pi/8	
		FindRoots /B=0 /H=(high)  /L=(low) /Q CosCosh_m_I, w
	endif

	if(V_flag)
		high+=pi/8
		//low+=pi/4	
		FindRoots /B=0 /H=(high)  /L=(low) /Q CosCosh_m_I, w
	endif

	if(V_flag)
		high+=pi/8
		//low+=pi/4	
		FindRoots /B=0 /H=(high)  /L=(low) /Q CosCosh_m_I, w
	endif


//	Killwaves/Z w

	return V_Root
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑



//
// KRYLOV FUNCTIONS
//


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Krylov_Q(x)
	variable x
	
	return (cosh(x)+cos(x))
	
end

Function Krylov_R(x)
	variable x
	
	return (sinh(x)+sin(x))
	
end

Function Krylov_S(x)
	variable x
	
	return (cosh(x)-cos(x))
	
end

Function Krylov_T(x)
	variable x
	
	return (sinh(x)-sin(x))
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Phi_nA(n,x)
	variable n, x
	
	variable Cn=C_n(n)
	
	variable phi=-Krylov_T(Cn)/Krylov_Q(Cn)*Krylov_T(Cn*x)+Krylov_S(Cn*x)
	
	return phi
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑


//	▄▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
//		DESCRIPTIVE COMMENT
Function Phi_n2A(n,x, mend2mc)
	variable n, x, mend2mc
	
	variable Cn=C_n_m(n,mend2mc)
	
	variable phi=Krylov_T(Cn)+mend2mc*Cn*Krylov_S(Cn)
	phi/=Krylov_Q(Cn)+mend2mc*Cn*Krylov_T(Cn)
	phi*=-1
	phi*=Krylov_T(Cn*x)
	phi+=Krylov_S(Cn*x)
	
	return phi
	
end
// ▀▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄↑↑↑

