#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.


Function DensityAir(temp, patm, RH)
	variable temp, patm, RH
	
	// calculate saturated water vapor pressure using Antoine Equation p=10^(A-B/(C+T)), where T is in C
	
	variable pH2Osat=10^(8.07131-1730.63/(233.426+temp-273.15))
	
	variable d=patm/287.05+RH/100*pH2Osat*(1/461.495-1/287.05)
	
	d/=temp
	
	return d


end

Function ViscAir(Temp,pressure)
	variable temp, pressure

	variable visc=1.47e-6
	
	visc*=Temp^(3/2)/(Temp+113)
	visc*=1+1.53e-4*(Temp/113-1)^2
	if(numtype(pressure)==0)
		visc*=pressure/101325
	endif
	
	return visc


end

Function ViscWater(Temp)
	variable temp

	variable visc=2.414e-5
	
	visc*=10^(247.8/(Temp-140))
	
	return visc


end

// Cragoe’s equation for viscosity of water
// from Dean J.A. - Lange's Handbook of Chemistry (15ed., MGH, 1999)
// page 5.138


Function ViscWater2a(Temp)
	variable temp

	variable visc, A
	
	temp-=273.15
	
	A=1.2348*(20-Temp)-0.001467*(temp-20)^2
	A/=temp+96
	
	visc=10^A
	visc*=1.0019e-3
	
	return visc


end


// Cragoe’s equation for viscosity of water
// using coefficents from "Viscosity of Water at Various Temperatures"
// J. Phys. Chem. 1969, 73, 34 


Function ViscWater2b(Temp)
	variable temp

	variable visc, A
	
	temp-=273.15
	
	A=1.2348*(20-Temp)-0.001467*(temp-20)^2
	A/=temp+96
	
	visc=10^A
	visc*=1.0019e-3
	
	return visc


end


// R. C. Weast, 1983, CRC Handbook of Chemistry
// and Physics, 64th edition, CRC Press, Boca Raton, FL

Function ViscWater3(Temp)
	variable temp

	variable visc, A
	
	temp-=273.15
	

	if(temp<20)
		A=1301
		A/=998.333+8.1855*(temp-20)+0.00585*(temp-20)^2
		A-=1.30223
		
		visc=10^A
		visc*=1.00e-3
	else
		A=1.3272*(20-Temp)-0.001053*(temp-20)^2
		A/=temp+105

		visc=10^A
		visc*=1.002e-3
	endif
	
	return visc


end



// from the paper on the modern results 
// for the density of standard ocean water
// Tanaka, M., et al. (2001). 
// "Recommended table for the density of water between 0 degrees C and 40 degrees C 
// based on recent experimental reports." Metrologia 38(4): 301-309.

Function DensityWater(temp)

	variable temp
	
	temp-=273.15
	
	variable d=999.974950
	
	d*=1-(temp-3.98035)^2*(temp+301.797)/522528.9/(temp+69.34881)
	
	// correct for air saturation
	
	d+=-4.612+0.106*temp
	
	
	return d


end


Function DenVisc_WaterMix(temp, mixtureName, component1x, DataType)
	variable temp
	string mixtureName
	variable component1x
	string DataType
	
	variable val
	
	wave mixture=root:packages:SolventData:$mixtureName

// mixture is a 3D wave 
// columns: 0=mole fraction of component 2, 1=density, 2=viscosity

// *************** DATA SOURCES *******************************************

// layers: temperature: 293.15 K, 298.15 K, 303.15 K for water-MeOH and water-EtOH

// Data on binary water alcohol mixtures from
// Begona Gonzalez, Noelia Calvar,  Elena Gomez, Angeles Dominguez
// J. Chem. Thermodynamics 39 (2007) 1578–1588
// "Density,  dynamic  viscosity, and derived properties  of binary  mixtures
// of methanol  or ethanol  with water, ethyl acetate, and methyl acetate 
// at T = (293.15, 298.15, and 303.15) K"


// water-EG, dioxane-EG

// layers: temperature: 293.15 K, 298.15 K, 303.15 K, 308.15 K, 313.5 K for water-EG, dioxane-EG

//	Olga IULIAN and Oana CIOCÎRLAN
//	I. BINARY SYSTEMS
//	Rev. Roum. Chim. 2010, 55(1), 45-53
//	VISCOSITY AND DENSITY OF SYSTEMS WITH WATER, 1,4-DIOXANE
//	AND ETHYLENE GLYCOL BETWEEN (293.15 AND 313.15) K.


// dioxane-water

// layers: temperature: 311.15 K, 316.15 K, 320.15 K for dioxane-water

// N. Ouerfelli · Z. Barhoumi · O. Iulian
//	J Solution Chem (2012) 41:458–474
//	DOI 10.1007/s10953-012-9812-9
//	Viscosity Arrhenius Activation Energy and Derived
//	Partial Molar Properties in 1,4-Dioxane + Water Binary
//	Mixtures from 293.15 to 323.15 K

// EtEG-water

// layers: temperature: 293.15 K, 303.15 K, 313.15 K, 323.15 K, 333.15 K for EtEG-water

//	Yan-Wei Wang a, Xin-Xue  Li a,⁎, Zai-Liang Zhang b, Qian Liu a, Dan Li a, Xue Wang a
//	Journal of Molecular Liquids 196 (2014) 192–197
//	Volumetric, viscosimetric and spectroscopic studies for aqueous solution of ethylene glycol monoethyl ether


// Glycerol-water

// layers: temperature: 298.15 K, 303.15 K, 308.15 K, 313.15 K, 318.15 K for Glycerol-water

//	DAWEI LAN1, LIHUA LIU, LINING DONG , WENBIN LI , QIANG LI and LIGANG YAN
// Asian Journal of Chemistry;  Vol. 25, No. 5 (2013), 2709-2712
//	Excess Molar Properties and Viscosities of Glycerol + Water  System at 298.15 to 318.15 K


// diEG-water

// layers: temperature: 293.15 K, 303.15 K, 313.15 K, 323.15 K, 333.15 K, 343.15 K, 353.15 K for diEG-water

//J. Manuel Bernal-García,†  Adriana Guzmán-López,‡  Alberto Cabrales-Torres,†  Vicente Rico-Ramírez,‡  and
//Gustavo A. Iglesias-Silva*,‡
//J. Chem. Eng. Data 2008, 53, 1028–1031
//Supplementary Densities and Viscosities of Aqueous Solutions of Diethylene
//Glycol from (283.15 to 353.15) K




// *************** DATA SOURCES *******************************************


// interpolate/extrapolate for a given temperature
// Fit density and viscosity data to power law dependence if
// outside data temp range, calculate extrapolated value

	string typeOfCalc="interpolate"

	if(Temp>DimOffset(mixture,2)+DimSize(mixture,2)*DimDelta(mixture,2))
		typeOfCalc="extrapolate"
		//Abort "The temperature is set above the upper limit in the database."
	endif
	
	if(Temp<DimOffset(mixture,2))
		typeOfCalc="extrapolate"
		//Abort "The temperature is set below the lower limit in the database."
	endif

	Make/O/N=(DimSize(mixture,0),DimSize(mixture,2)) D_Mix, D_MixXRaw
	wave D_Mix, D_MixXRaw
	
// database is in g/cm^3 for density and cP for viscosity => transform into SI units
	strswitch(DataType)
	
		case "density":
			D_Mix=mixture[p][1][q]*1e3
		break
		
		case "viscosity":
			D_Mix=mixture[p][2][q]*1e-3
		break
		
	endswitch

	D_MixXRaw=mixture[p][0][q]

//	D_Mix 			2D wave, either density or viscosity, unscaled: p -> x, q -> T
//	D_MixXRaw		2D wave, mole fraction component 1, unscaled: p -> x, q -> T
//	D_MixX			1D wave, mole fraction component 1
//	D_MixTemp		1D wave, density or visc versus T, scaled: x=T
// D_MixInvTemp	1D wave, 1/T versus T, scaled: x=T
	
	strswitch(typeOfCalc)
	
// *** interpolation

		case "interpolate":
	
			Make/O/N=(DimSize(mixture,0)) D_MixTemp, D_MixX
			wave D_MixTemp, D_MixX
			
			SetScale/P y, DimOffset(mixture,2),DimDelta(mixture,2),"K", D_Mix, D_MixXRaw
			
			D_MixTemp=Interp2D(D_Mix, p, Temp)
			D_MixX=Interp2D(D_MixXRaw, p, Temp)
//			D_MixX=mixture[p][0](Temp)
		
			val=interp(component1x,D_MixX, D_MixTemp)

		break
	
// *** interpolation only


// *** extrapolation 

		case "extrapolate":

			Make/O/N=(DimSize(mixture,0)) D_MixX
			Make/O/N=(DimSize(mixture,2)) D_MixTemp, D_MixInvTemp
			wave D_MixTemp, D_MixX, D_MixInvTemp
		
// assumes same mole fraction at all temperatures
// otherwise extrapolation is not valid

			D_MixX=mixture[p][0][0]
		
			FindLevel/Q D_MixX, component1x
			variable x2=V_LevelX
			D_MixTemp=Interp2D(D_Mix, x2, p)
			SetScale/P x, DimOffset(mixture,2),DimDelta(mixture,2),"K", D_MixTemp, D_MixInvTemp
			D_MixInvTemp=1/x
		
			CurveFit/M=2/W=2/Q Power, D_MixTemp/X=D_MixInvTemp/D
			wave W_coef
		
			val=W_coef[0]+W_coef[1]*(1/Temp)^W_coef[2]
	
// *** extrapolation 

		break

	endswitch
	
//	print DataType, "=", val
	
	KillWaves/Z D_Mix, D_MixXRaw, D_MixX, D_MixTemp,  D_MixInvTemp
	
	return val


end

// convert text table help function
// when columns were not split

Function/S convertWaveElement(str, x0, x1)
	string str
	variable x0, x1
	
	return str[x0, x1]

end

// ================== Processing databases ============================


Function BuildDataStringsNameDensVisc(Name,Density,Viscosity)
	wave/T Name
	wave Density, Viscosity
	
	string/G S_Name
	string/G S_Name_Dens
	string/G S_Name_Visc
	
	S_Name=""
	S_Name_Dens=""
	S_Name_Visc=""
	
	variable i, NOP=numpnts(Name)
	
	for(i=0;i<NOP;i+=1)
		
		// skip if no viscosity value
		if(numType(Viscosity[i])==0)
			S_Name+=Name[i]+";"
			S_Name_Dens+=Name[i]+":"+num2str(Density[i])+";"
			S_Name_Visc+=Name[i]+":"+num2str(Viscosity[i])+";"
		endif
	
	endfor

end


Function BuildDataStrings1(formula,name,Tb,delHvap)
	wave/T formula,name
	wave Tb,delHvap
	
	string/G S_Tb_Formula, S_delH_Formula
	string/G S_Tb_Name, S_delH_Name
	
	variable i, NOP=numpnts(formula)
	
	for(i=0;i<NOP;i+=1)
		
		S_Tb_Formula+=Formula[i]+":"+num2str(Tb[i]+273.15)+";"
		S_delH_Formula+=Formula[i]+":"+num2str(delHvap[i]*1e3/8.314/(Tb[i]+273.15))+";"
		S_Tb_Name+=Name[i]+":"+num2str(Tb[i]+273.15)+";"
		S_delH_Name+=Name[i]+":"+num2str(delHvap[i]*1e3/8.314/(Tb[i]+273.15))+";"
	
	endfor

end

Function BuildDataStrings2(formula,name,Tb,Tc, Pc, Vc)
	wave/T formula,name
	wave Tb,Tc, Pc, Vc
	
	string/G S_Tb_Formula, S_Tc_Formula, S_Pc_Formula, S_Vc_Formula
	string/G S_Tb_Name, S_Tc_Name, S_Pc_Name, S_Vc_Name
	
	variable i, NOP=numpnts(formula)
	
	for(i=0;i<NOP;i+=1)
		
		S_Tb_Formula+=Formula[i]+":"+num2str(Tb[i])+";"
		S_Tc_Formula+=Formula[i]+":"+num2str(Tc[i])+";"
		S_Pc_Formula+=Formula[i]+":"+num2str(Pc[i])+";"
		S_Vc_Formula+=Formula[i]+":"+num2str(Vc[i])+";"
		S_Tb_Name+=Name[i]+":"+num2str(Tb[i])+";"
		S_Tc_Name+=Name[i]+":"+num2str(Tc[i])+";"
		S_Pc_Name+=Name[i]+":"+num2str(Pc[i])+";"
		S_Vc_Name+=Name[i]+":"+num2str(Vc[i])+";"
	
	endfor

end

Function BuildDataStrings3(symbol,mass)
	wave/T symbol
	wave mass
	
	string/G S_AM_Symbol
	
	variable i, NOP=numpnts(symbol)
	
	for(i=0;i<NOP;i+=1)
		
		S_AM_Symbol+=Symbol[i]+":"+num2str(mass[i])+";"
	
	endfor

end

Function BuildDataStrings4(Name,MolarVolume)
	wave/T Name
	wave MolarVolume
	
	string/G S_Vm_Name
	
	variable i, NOP=numpnts(Name)
	
	for(i=0;i<NOP;i+=1)
		
		S_Vm_Name+=Name[i]+":"+num2str(MolarVolume[i])+";"
	
	endfor

end

Function Formula2MW(formula, S_AM)
	wave/T formula
	string S_AM
	
	variable i, j, stringlen, NOP=numpnts(formula)
	
	Make/O/N=(NOP) MW
	
	string molecule, element
	variable M_el, M_mol
	variable Natoms
	
	for(i=0;i<NOP;i+=1)
		
		molecule=formula[i]
		// get rid of whitespaces
		molecule=ReplaceString(" ", molecule, "")
		stringlen=strlen(molecule)
		M_mol=0
	
		for(j=0;j<stringlen;)
		
			// try 2 letter element first
			element=molecule[j,j+1]
			M_el=NumberByKey(element, S_AM)
			
			// element is found in the formula
			// how many atoms?
			
			if(numtype(M_el)==0)
				
				Natoms=str2num(molecule[j+2,stringlen-1])
				if(numtype(Natoms)==0)
					M_el*=Natoms
					//if(Natoms>1)
						j+=strlen(num2str(Natoms))
					//endif
				endif
			
				j+=2
			
			else			// is it 1 letter element?
				element=molecule[j,j]
				M_el=NumberByKey(element, S_AM)

				// element is found in the formula
				// how many atoms?
				
				if(numtype(M_el)==0)
				
					Natoms=str2num(molecule[j+1,stringlen-1])
					if(numtype(Natoms)==0)
						M_el*=Natoms
						//if(Natoms>1)
							j+=strlen(num2str(Natoms))
						//endif
					endif
					
					j+=1

				endif
			endif
			
			M_mol+=M_el
			
		endfor
		
		MW[i]=M_mol

		//print i
	
	endfor
	


end	

