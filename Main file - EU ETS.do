//clear past data
//change directory
//import datafile
//set log

//declare data as time series
tsset Date1, monthly
gen Date2=tm(2014,m1)+ _n - 1
format Date2 %tm
tsset Date2
//tsfill
//tsset timevar
estat archlm, lags(1)

//run VAR + diagnostics
var EUA_D COAL NORDRES GAS TEMPDEV PRECIP FTSE GASFUT,lags(1/4)

//check autocorrelation of lags
varlmar, mlag(4)
varsoc EUA COAL NORDRES GAS TEMPDEV PRECIP FTSE GASFUT, maxlag(6)
varsoc EUA_D COAL NORDRES GAS TEMPDEV PRECIP FTSE GASFUT, maxlag(6)

//run regression
reg EUA COAL NORDRES GAS TEMPDEV PRECIP FTSE, robust

//Regression with logs
reg LOG_EUA LOG_COAL LOG_NORDRES LOG_GASFUT
reg LOG_EUA LOG_COAL LOG_NORDRES LOG_GAS

//regression with lagged variables
gen GASLAG1 = GAS[_n-1]
gen COALLAG1 = COAL[_n-1]
gen GASFUTLAG1 = GASFUT[_n-1]
gen NORDRESLAG1 = NORDRES[_n-1]

gen LOG_GASLAG1 = LOG_GAS[_n-1]
gen LOG_COALLAG1 = LOG_COAL[_n-1]
gen LOG_GASFUTLAG1 = LOG_GASFUT[_n-1]
gen LOG_NORDRESLAG1 = LOG_NORDRES[_n-1]

reg EUA COALLAG1 NORDRESLAG1 GASLAG1 PRECIP TEMPDEV

reg LOG_EUA LOG_GASLAG1 LOG_COALLAG1 LOG_NORDRESLAG1

//heteroskedasticity tests
hettest
imtest, white

//het-robust OLS
reg EUA COAL NORDRES GASFUT, robust

//Stationarity tests
//dfuller EUA


//create extension variables
//Create lagged and 1st dif fuel and EUA 

//1st dif
gen D_EUA = EUA[_n]-EUA[_n-1]
gen D_COAL = COAL[_n]-COAL[_n-1]
gen D_GAS = GAS[_n]-GAS[_n-1]
gen D_GASFUT = GASFUT[_n]-GASFUT[_n-1]
gen D_FTSE = FTSE[_n]-FTSE[_n-1]
gen D_NORDRES = NORDRES[_n]-NORDRES[_n-1]

//lagged 1st dif
gen L_D_EUA = D_EUA[_n-1]
gen L2_D_EUA = L_D_EUA[_n-1]
gen L3_D_EUA = L2_D_EUA[_n-1]

gen L_D_GAS = D_GAS[_n-1]
gen L2_D_GAS = L_D_GAS[_n-1]
gen L3_D_GAS = L2_D_GAS[_n-1]

gen L_D_GASFUT = D_GASFUT[_n-1]
gen L2_D_GASFUT = L_D_GASFUT[_n-1]
gen L3_D_GASFUT = L2_D_GASFUT[_n-1]

gen L_D_COAL = D_COAL[_n-1]
gen L2_D_COAL = L_D_COAL[_n-1]
gen L3_D_COAL = L2_D_COAL[_n-1]

//create squared variables
gen PRECIPsq = (PRECIP)^2
gen NORDRESsq = (NORDRES)^2
gen TEMPDEVsq = (TEMPDEV)^2

gen D_NORDRESsq = (D_NORDRES)^2


//create interaction terms
gen D_GASFUTxTEMPDEV = (D_GASFUT)*(TEMPDEV)
gen D_GASFUTxPRECIP = (D_GASFUT)*(PRECIP)
gen D_GASFUTxNORDRES = (D_GASFUT)*(NORDRES)
gen D_GASFUTxD_NORDRES = (D_GASFUT)*(D_NORDRES)

gen D_COALxTEMPDEV = (D_COAL)*(TEMPDEV)
gen D_COALxPRECIP = (D_COAL)*(PRECIP)
gen D_COALxNORDRES = (D_COAL)*(NORDRES)
gen D_COALxD_NORDRES = (D_COAL)*(D_NORDRES)




//1st extension equation
reg D_EUA D_GASFUT D_COAL TEMPDEV PRECIPsq NORDRES NORDRESsq D_GASFUTxTEMPDEV D_GASFUTxPRECIP D_GASFUTxNORDRES D_COALxTEMPDEV D_COALxPRECIP D_COALxNORDRES, robust
estimates table, star(.05 .01 .001)
estat ic

//2nd extension equation
//adds lagged gas and coal
reg D_EUA D_GASFUT L_D_GASFUT L2_D_GASFUT D_GAS L_D_GAS L2_D_GAS D_COAL L_D_COAL L2_D_COAL TEMPDEV PRECIPsq NORDRES NORDRESsq D_GASFUTxTEMPDEV D_GASFUTxPRECIP D_GASFUTxNORDRES D_COALxTEMPDEV D_COALxPRECIP D_COALxNORDRES, robust
estimates table, star(.05 .01 .001)
estat ic

//3rd extension
//adds lagged EUA
reg D_EUA L_D_EUA L2_D_EUA L3_D_EUA D_GASFUT L_D_GASFUT L2_D_GASFUT D_GAS L_D_GAS L2_D_GAS D_COAL L_D_COAL L2_D_COAL TEMPDEV PRECIPsq NORDRES NORDRESsq D_GASFUTxTEMPDEV D_GASFUTxPRECIP D_GASFUTxNORDRES D_COALxTEMPDEV D_COALxPRECIP D_COALxNORDRES, robust
estimates table, star(.05 .01 .001)
estat ic


//test for arch effects
reg D_EUA D_COAL D_NORDRES D_GASFUT TEMPDEV PRECIP D_FTSE
estat archlm


//create ARCH model
arch D_EUA COAL NORDRES GASFUT TEMPDEV PRECIPDEV FTSE, arch(1) vce(robust)
estimates table, star(.05 .01 .001)
estat ic

//create ARCH model with differences
arch D_EUA D_COAL D_NORDRES D_GASFUT TEMPDEV PRECIP D_FTSE, arch(1) vce(robust)
estimates table, star(.05 .01 .001)
estat ic


//ARCH extension 1
arch D_EUA D_GASFUT D_COAL TEMPDEV PRECIPsq NORDRES NORDRESsq D_GASFUTxTEMPDEV D_GASFUTxPRECIP D_GASFUTxNORDRES D_COALxTEMPDEV D_COALxPRECIP D_COALxNORDRES, arch(1) vce(robust)
estimates table, star(.05 .01 .001)
estat ic

//ARCH extension 2
arch D_EUA D_GASFUT L_D_GASFUT L2_D_GASFUT D_GAS L_D_GAS L2_D_GAS D_COAL L_D_COAL L2_D_COAL TEMPDEV PRECIPsq NORDRES NORDRESsq D_GASFUTxTEMPDEV D_GASFUTxPRECIP D_GASFUTxNORDRES D_COALxTEMPDEV D_COALxPRECIP D_COALxNORDRES, arch(1)
estimates table, star(.05 .01 .001)
estat ic

//ARCH Extension 3
arch D_EUA L_D_EUA L2_D_EUA L3_D_EUA D_GASFUT L_D_GASFUT L2_D_GASFUT D_GAS L_D_GAS L2_D_GAS D_COAL L_D_COAL L2_D_COAL TEMPDEV PRECIPsq NORDRES NORDRESsq D_GASFUTxTEMPDEV D_GASFUTxPRECIP D_GASFUTxNORDRES D_COALxTEMPDEV D_COALxPRECIP D_COALxNORDRES, arch(1)
estimates table, star(.05 .01 .001)
estat ic

//trying to achieve convergence of ARCH model
//modified extensions

//Extension 1, omit squared variables
arch D_EUA D_GASFUT D_COAL TEMPDEV NORDRES D_GASFUTxTEMPDEV D_GASFUTxPRECIP D_GASFUTxNORDRES D_COALxTEMPDEV D_COALxPRECIP D_COALxNORDRES, arch(1) vce(robust)
estimates table, star(.05 .01 .001)
estat ic

//Extension 2, omit sq variables
arch D_EUA D_GASFUT L_D_GASFUT L2_D_GASFUT D_GAS L_D_GAS L2_D_GAS D_COAL L_D_COAL L2_D_COAL TEMPDEV D_NORDRES D_GASFUTxTEMPDEV D_GASFUTxPRECIP D_GASFUTxD_NORDRES D_COALxTEMPDEV D_COALxPRECIP D_COALxD_NORDRES, arch(1) 
estimates table, star(.05 .01 .001)
estat ic

//Ext 2 without cross terms with sq vars
arch D_EUA D_GASFUT L_D_GASFUT L2_D_GASFUT D_GAS L_D_GAS L2_D_GAS D_COAL L_D_COAL L2_D_COAL D_FTSE TEMPDEV D_NORDRES PRECIP, arch(1) vce(robust)
estimates table, star(.05 .01 .001)
estat ic

//Extension 3, omit sq variables, all precip, , D_GASFUTxTEMPDEV   D_COALxNORDRES 
arch D_EUA L_D_EUA L2_D_EUA L3_D_EUA D_GASFUT L_D_GASFUT L2_D_GASFUT D_GAS L_D_GAS L2_D_GAS D_COAL L_D_COAL L2_D_COAL TEMPDEV NORDRES D_GASFUTxNORDRES D_COALxTEMPDEV D_GASFUTxTEMPDEV, arch(1) vce(robust)
estimates table, star(.05 .01 .001)
estat ic

//Ext 3 Modified ext 2 with added EUA lags
arch D_EUA L_D_EUA L2_D_EUA L3_D_EUA D_GASFUT L_D_GASFUT L2_D_GASFUT D_GAS L_D_GAS L2_D_GAS D_COAL L_D_COAL L2_D_COAL D_FTSE TEMPDEV D_NORDRES PRECIP, arch(1) vce(robust)
estimates table, star(.05 .01 .001)
estat ic


//Extension 1 add squared variables, omit xterms D_GASFUTxTEMPDEV D_NORDRESsq D_NORDRES D_GASFUTxTEMPDEV D_GASFUTxPRECIP D_COALxTEMPDEV
arch D_EUA D_GASFUT D_FTSE D_COAL TEMPDEV D_NORDRES PRECIP PRECIPsq TEMPDEVsq D_NORDRESsq, arch(1) vce(robust)
estimates table, star(.05 .01 .001)
estat ic


//stop logging
log close
