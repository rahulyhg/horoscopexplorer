<%@ page language="java" import="java.util.*" errorPage="" %>
<%@ page language="java" import="java.io.*" errorPage="" %>
<%@ page language="java" import="swisseph.*" errorPage="" %>

<%   
	/* Declare swisseph classes */
	SweDate sd=new SweDate();
  	SwissData swed=new SwissData();
  	SwissEph sw=new SwissEph();
	
	/* set path Swiss Ephemeris data files */
	sw.swe_set_ephe_path("/usr/share/sweph/ephe");

	/* Declare page variables */
    String sp, sdate="", snam, strReturn = "Mak";
	snam = null;
    StringBuffer serr=new StringBuffer();
	double tjd, te, x2[]=new double[6];
    long iflag, iflgret;
    int p, hsys = (int)'P';
	double cusp[]=new double[13], ascmc[]=new double[10];
		
	/* Declare input variables */
	int jday = 23, jmon = 10, jyear = 1925;
	int jhour = 7, jmin = 15;
	String jtzone = "-06:00";
	int summerTime = 0;	
	int lngd = 94, lngm = 44;
	int latd = 40, latm = 59;
	String lng = "w", lat = "n";
	
	/* Get input data as string, split them and set input variables */
	String strData = request.getParameter("data"); 
	if (strData != null) {
		String[] data = strData.split("\\^");
		strReturn = strReturn+strData+"|";
		jmon = Integer.parseInt(data[1]);
		jday = Integer.parseInt(data[2]);
		jyear = Integer.parseInt(data[3]);
		jhour = Integer.parseInt(data[4]);
		jmin = Integer.parseInt(data[5]);
		jtzone = data[6];		
		summerTime = Integer.parseInt(data[7]);
		lngd = Integer.parseInt(data[8]);
		lngm = Integer.parseInt(data[9]);
		lng = data[10];
		latd = Integer.parseInt(data[11]);
		latm = Integer.parseInt(data[12]);
		lat = data[13];
	}
	
	// convert time to decimal hours
	double jut = (double)jhour+(jmin/60.0);
	if (summerTime > 0) 
		jut = jut - (double)summerTime;
	// split tzone time
	String[] splits = jtzone.split(":");
	// convert time to UT
	jut = jut + (-1.0)*Double.parseDouble(splits[0]);
	if (Integer.parseInt(splits[0]) < 0) {
		jut = jut + (-1.0)*(Double.parseDouble(splits[1])/60.0);
	} else {
		jut = jut + (Double.parseDouble(splits[1])/60.0);
	}
/* 
geographic longitude, in degrees
eastern longitude is positive,
western longitude is negative,
northern latitude is positive,
southern latitude is negative 
*/
	double jlng = (double)lngd+(lngm/60.0);
	if (lng.equals("w")) 
		jlng = -1.0*jlng;
	double jlat = (double)latd+(latm/60.0);
	if (lat.equals("s")) 
		jlat = -1.0*jlat;	
	
	iflag = SweConst.SEFLG_SPEED;
	sd.setDate(jyear,jmon,jday,jut);
    sd.setCalendarType(sd.SE_GREG_CAL,sd.SE_KEEP_DATE);
    tjd=sd.getJulDay();
	te = tjd + sd.getDeltaT(tjd);
	
//	out.print("tjd = "+tjd+"<br>");
//	out.print("te = "+te+"<br>");
	
	for (p = SweConst.SE_SUN; p <= SweConst.SE_CHIRON; p++) {
        if (p == SweConst.SE_EARTH) continue;
        /*
         * do the coordinate calculation for this planet p
         */
        iflgret = sw.swe_calc(tjd, p, (int)iflag, x2, serr);
        /*
         * if there is a problem, a negative value is returned and an
         * errpr message is in serr.
         */
        if (iflgret < 0)
  	  		out.print("error: "+serr.toString()+"<br>");
        else if (iflgret != iflag)
          	out.print("warning: iflgret != iflag. "+serr.toString()+"<br>");
        /*
         * get the name of the planet p and add speed and position
         */
        snam = sw.swe_get_planet_name(p);
		strReturn = strReturn+snam+"^"+x2[3]+" "+x2[0]+"|";
        /*
         * print the coordinates
         */
/*
		 out.print(p+". "+snam+"\t"+x2[0]+"\t");
		 for (int i = 0; i < 6; i++) {
		 	out.print(" "+x2[i]);
		 }
		out.print("<br>");
 */
      }
	  
	  iflgret = sw.swe_houses(tjd, 0, jlat, jlng, hsys, cusp, ascmc);
   	  
	  // add Vertex data
	  strReturn = strReturn + "Vertex " + ascmc[3] + "|";
	  
	  // add houses positions
	  for (int h=1; h <= 12; h++) {
	  	strReturn = strReturn+h;
		if (h == 1) strReturn = strReturn + "ST ";
		if (h == 2) strReturn = strReturn + "ND ";
		if (h == 3) strReturn = strReturn + "RD ";
		if (h > 3) strReturn = strReturn + "TH ";
		strReturn = strReturn+cusp[h] + "|";
	  	
//		out.print(h+". "+cusp[h]+"<br>");
	  }
/*	  
	  for (int h=0; h <= 9; h++) {
	  	out.print(h+". "+ascmc[h]+"<br>");
	  }
*/	  
	  out.print(strReturn);
%>
<html>
<body>
	<br>SweDate: <%= sd.toString()%><br>
	Current Date time: <%=new java.util.Date()%><br>

------------------------<br>
Test Data:<br><br>
http://www.mak-mak.com/scripts/sweph/gethoro.asp?data=Demo1^10^23^1925^7^15^-06:00^0^94^44^w^40^59^n<br>
*MakDemo1^10^23^1925^7^15^-06:00^0^94^44^w^40^59^n|Sun^0.996 209.61488252|Moon^14.047 283.60935591|Mercury^1.557 220.15159885|Venus^1.143 253.79181227|Mars^0.656 196.11567226|Jupiter^0.129 285.66649329|Saturn^0.117 224.94416871|Uranus^-0.029 352.15752914|Neptune^0.019 144.44963266|Pluto^-0.003 104.73289722|mean Node^-0.053 119.97956759|true Node^-0.016 120.03462906|mean Apoge^0.111 124.51796552|osc. Apoge^3.408 125.77739038|Chiron^-0.047 025.87699783|Vertex 215.69135312|1ST 215.69135312|2ND 244.33281816|3RD 277.39364072|4TH 312.88593059|5TH 345.84977669|6TH 013.35466487|7TH 035.69135312|8TH 064.33281816|9TH 097.39364072|10TH 132.88593059|11TH 165.84977669|12TH 193.35466487|<br>
<!--- 
<?xml version="1.0" encoding="utf-8" ?><HoroItems><InData>Demo1^10^23^1925^7^15^-06:00^0^94^44^w^40^59^n,</InData><Sun>0.996,209.61488252,29 LIB 37,12TH,VEN,-4,4</Sun><Moon>14.047,283.60935591,13 CAP 37,3RD,SAT,-5,9</Moon><Mercury>1.557,220.15159885,10 SCO 09,1ST,MAR,0,-3</Mercury><Venus>1.143,253.79181227,13 SAG 48,2ND,JUP,1,8</Venus><Mars>0.656,196.11567226,16 LIB 07,12TH,VEN,-5,5</Mars><Jupiter>0.129,285.66649329,15 CAP 40,3RD,SAT,-2,4</Jupiter><Saturn>0.117,224.94416871,14 SCO 57,1ST,MAR,0,4</Saturn><Uranus>-0.029,352.15752914,22 PIS 09,5TH,JUP,0,1</Uranus><Neptune>0.019,144.44963266,24 LEO 27,10TH,SUN,1,12</Neptune><Pluto>-0.003,104.73289722,14 CAN 44,9TH,MOO,1,0</Pluto><S.Node>-0.016,300.03462906,00 AQU 02,3RD,SAT,0,1</S.Node><N.Node>-0.016,120.03462906,00 LEO 02,9TH,MOO,0,2</N.Node><Fortune>0.0,289.68582651,19 CAP 41,3RD,SAT,0,8</Fortune><Fate>0.0,186.86285667,06 LIB 52,11TH,MER,0,0</Fate><Chiron>-0.047,025.87699783,25 ARI 53,6TH,MAR,0,-5</Chiron><House_1ST>0.0,215.69135312,05 SCO 41,1ST,MAR,MER,SAT</House_1ST><House_2ND>0.0,244.33281816,04 SAG 20,2ND,JUP,VEN</House_2ND><House_3RD>0.0,277.39364072,07 CAP 24,3RD,SAT,MOO,JUP</House_3RD><House_4TH>0.0,312.88593059,12 AQU 53,4TH,SAT</House_4TH><House_5TH>0.0,345.84977669,15 PIS 51,5TH,JUP,URA</House_5TH><House_6TH>0.0,013.35466487,13 ARI 21,6TH,MAR</House_6TH><House_7TH>0.0,035.69135312,05 TAU 41,7TH,VEN</House_7TH><House_8TH>0.0,064.33281816,04 GEM 20,8TH,MER</House_8TH><House_9TH>0.0,097.39364072,07 CAN 24,9TH,MOO,PLU</House_9TH><House_10TH>0.0,132.88593059,12 LEO 53,10TH,SUN,NEP</House_10TH><House_11TH>0.0,165.84977669,15 VIR 51,11TH,MER</House_11TH><House_12TH>0.0,193.35466487,13 LIB 21,12TH,VEN,SUN,MAR</House_12TH><Significator>MAR</Significator><Hyleg>Neptune</Hyleg><Anareta>38.3339604,90,Mars^9.50546394999998,90,Saturn^99.50546395,180,Saturn^</Anareta><Rising_Planets>Sun,Mercury,Saturn,</Rising_Planets><Planetary_ruler>VEN</Planetary_ruler><Elevated_planet>Neptune</Elevated_planet><Midheaven_ruler>SUN</Midheaven_ruler><Moon_Phase>I</Moon_Phase><Eclipse></Eclipse><Mutual_reception>LIB-CAP</Mutual_reception><Angular>Mercury,Saturn,Neptune,</Angular><Succedent>Venus,Uranus,</Succedent><Cadent>Sun,Moon,Mars,Jupiter,Pluto,</Cadent><Fire>2</Fire><Earth>2</Earth><Air>2</Air><Water>4</Water><Cardinal>5</Cardinal><Fixed>3</Fixed><Muatable>2</Muatable><Masculine>4</Masculine><Feminine>6</Feminine><Quadrant_I>5</Quadrant_I><Quadrant_II>1</Quadrant_II><Quadrant_III>1</Quadrant_III><Quadrant_IV>3</Quadrant_IV><South>4</South><North>6</North><East>8</East><West>2</West></HoroItems>
 --->
------------------------<br>
http://www.mak-mak.com/scripts/sweph/gethoro.asp?data=Demo2^1^29^1964^12^0^-05:00^0^75^00^w^40^00^n<br>
*MakDemo2^1^29^1964^12^0^-05:00^0^75^00^w^40^00^n|Sun^1.015 308.82357856|Moon^13.954 138.39490221|Mercury^1.123 284.26636507|Venus^1.212 345.34338969|Mars^0.788 312.93036255|Jupiter^0.162 014.38497941|Saturn^0.118 323.60059890|Uranus^-0.036 159.21045028|Neptune^0.011 227.72366326|Pluto^-0.02 163.75431514|mean Node^-0.053 099.83589912|true Node^-0.061 101.04390948|mean Apoge^0.111 241.75764143|osc. Apoge^-2.392 260.81780846|Chiron^0.055 342.33580857|Vertex 057.50294776|1ST 057.50294776|2ND 082.57320720|3RD 103.53798151|4TH 125.47308407|5TH 152.92435572|6TH 191.23743934|7TH 237.50294776|8TH 262.57320720|9TH 283.53798151|10TH 305.47308407|11TH 332.92435572|12TH 011.23743934|<br>
<!--- 
<?xml version="1.0" encoding="utf-8" ?><HoroItems><InData>Demo2^1^29^1964^12^0^-05:00^0^75^00^w^40^00^n,</InData><Sun>1.015,308.82357856,08 AQU 49,10TH,SAT,-5,0</Sun><Moon>13.954,138.39490221,18 LEO 24,4TH,SUN,-3,2</Moon><Mercury>1.123,284.26636507,14 CAP 16,9TH,SAT,3,3</Mercury><Venus>1.212,345.34338969,15 PIS 21,11TH,JUP,4,9</Venus><Mars>0.788,312.93036255,12 AQU 56,10TH,SAT,0,-1</Mars><Jupiter>0.162,014.38497941,14 ARI 23,12TH,MAR,3,0</Jupiter><Saturn>0.118,323.60059890,23 AQU 36,10TH,SAT,0,2</Saturn><Uranus>-0.036,159.21045028,09 VIR 13,5TH,MER,-3,9</Uranus><Neptune>0.011,227.72366326,17 SCO 43,6TH,VEN,4,4</Neptune><Pluto>-0.02,163.75431514,13 VIR 45,5TH,MER,1,2</Pluto><S.Node>-0.061,281.04390948,11 CAP 03,8TH,JUP,0,-8</S.Node><N.Node>-0.061,101.04390948,11 CAN 03,2ND,MER,0,6</N.Node><Fortune>0.0,247.07427141,07 SAG 04,7TH,MAR,0,14</Fortune><Fate>0.0,46.8327114099999,16 TAU 50,12TH,MAR,0,-2</Fate><Chiron>0.055,342.33580857,12 PIS 20,11TH,JUP,0,15</Chiron><House_1ST>0.0,057.50294776,27 TAU 30,1ST,VEN</House_1ST><House_2ND>0.0,082.57320720,22 GEM 34,2ND,MER</House_2ND><House_3RD>0.0,103.53798151,13 CAN 32,3RD,MOO</House_3RD><House_4TH>0.0,125.47308407,05 LEO 28,4TH,SUN,MOO</House_4TH><House_5TH>0.0,152.92435572,02 VIR 55,5TH,MER,URA,PLU</House_5TH><House_6TH>0.0,191.23743934,11 LIB 14,6TH,VEN,NEP</House_6TH><House_7TH>0.0,237.50294776,27 SCO 30,7TH,MAR</House_7TH><House_8TH>0.0,262.57320720,22 SAG 34,8TH,JUP</House_8TH><House_9TH>0.0,283.53798151,13 CAP 32,9TH,SAT,MER</House_9TH><House_10TH>0.0,305.47308407,05 AQU 28,10TH,SAT,SUN,MAR,SAT</House_10TH><House_11TH>0.0,332.92435572,02 PIS 55,11TH,JUP,VEN</House_11TH><House_12TH>0.0,011.23743934,11 ARI 14,12TH,MAR,JUP</House_12TH><Significator>VEN</Significator><Hyleg>Venus</Hyleg><Anareta>21.74279079,360,Saturn^32.41302714,360,Mars^</Anareta><Rising_Planets></Rising_Planets><Planetary_ruler>SAT</Planetary_ruler><Elevated_planet>Sun</Elevated_planet><Midheaven_ruler>SAT</Midheaven_ruler><Moon_Phase>II</Moon_Phase><Eclipse></Eclipse><Mutual_reception>AQU-LEO</Mutual_reception><Angular>Sun,Moon,Mars,Saturn,</Angular><Succedent>Venus,Uranus,Pluto,</Succedent><Cadent>Mercury,Jupiter,Neptune,</Cadent><Fire>2</Fire><Earth>3</Earth><Air>3</Air><Water>2</Water><Cardinal>2</Cardinal><Fixed>5</Fixed><Muatable>3</Muatable><Masculine>5</Masculine><Feminine>5</Feminine><Quadrant_I>0</Quadrant_I><Quadrant_II>4</Quadrant_II><Quadrant_III>1</Quadrant_III><Quadrant_IV>5</Quadrant_IV><South>6</South><North>4</North><East>5</East><West>5</West></HoroItems>
 --->
------------------------<br>
http://www.mak-mak.com/scripts/sweph/gethoro.asp?data=Demo3^5^11^1946^12^0^-06:00^0^84^2^w^43^4^n<br>
*MakDemo3^5^11^1946^12^0^-06:00^0^84^2^w^43^4^n|Sun^0.965 050.42389888|Moon^12.327 182.11038441|Mercury^1.677 030.24499739|Venus^1.215 074.98197951|Mars^0.494 128.86325551|Jupiter^-0.094 199.13245829|Saturn^0.085 110.32722162|Uranus^0.055 075.93048168|Neptune^-0.018 186.18277775|Pluto^0.009 129.51894710|mean Node^-0.053 082.55004031|true Node^-0.076 081.18912170|mean Apoge^0.111 240.72390333|osc. Apoge^3.084 226.11437819|Chiron^-0.054 195.82831441|Vertex 152.77292462|1ST 152.77292462|2ND 175.50917306|3RD 203.63060538|4TH 237.05671949|5TH 272.50277804|6TH 304.95549501|7TH 332.77292462|8TH 355.50917306|9TH 023.63060538|10TH 057.05671949|11TH 092.50277804|12TH 124.95549501|<br>
<!--- 
<?xml version="1.0" encoding="utf-8" ?><HoroItems><InData>Demo3^5^11^1946^12^0^-06:00^0^84^2^w^43^4^n,</InData><Sun>0.965,050.42389888,20 TAU 25,9TH,MAR,0,2</Sun><Moon>12.327,182.11038441,02 LIB 07,2ND,MER,0,6</Moon><Mercury>1.677,030.24499739,00 TAU 15,9TH,MAR,3,3</Mercury><Venus>1.215,074.98197951,14 GEM 59,10TH,VEN,0,10</Venus><Mars>0.494,128.86325551,08 LEO 52,12TH,SUN,3,0</Mars><Jupiter>-0.094,199.13245829,19 LIB 08,2ND,MER,0,8</Jupiter><Saturn>0.085,110.32722162,20 CAN 20,11TH,MOO,-5,9</Saturn><Uranus>0.055,075.93048168,15 GEM 56,10TH,VEN,3,14</Uranus><Neptune>-0.018,186.18277775,06 LIB 11,2ND,MER,0,2</Neptune><Pluto>0.009,129.51894710,09 LEO 31,12TH,SUN,0,-5</Pluto><S.Node>-0.076,261.1891217,21 SAG 11,4TH,MAR,4,2</S.Node><N.Node>-0.076,081.18912170,21 GEM 11,10TH,VEN,4,8</N.Node><Fortune>0.0,284.45941015,14 CAP 28,5TH,SAT,0,4</Fortune><Fate>0.0,171.30895851,21 VIR 19,1ST,MER,0,4</Fate><Chiron>-0.054,195.82831441,15 LIB 50,2ND,MER,0,14</Chiron><House_1ST>0.0,152.77292462,02 VIR 46,1ST,MER</House_1ST><House_2ND>0.0,175.50917306,25 VIR 31,2ND,MER,MOO,JUP,NEP</House_2ND><House_3RD>0.0,203.63060538,23 LIB 38,3RD,VEN</House_3RD><House_4TH>0.0,237.05671949,27 SCO 03,4TH,MAR</House_4TH><House_5TH>0.0,272.50277804,02 CAP 30,5TH,SAT</House_5TH><House_6TH>0.0,304.95549501,04 AQU 57,6TH,SAT</House_6TH><House_7TH>0.0,332.77292462,02 PIS 46,7TH,JUP</House_7TH><House_8TH>0.0,355.50917306,25 PIS 31,8TH,JUP</House_8TH><House_9TH>0.0,023.63060538,23 ARI 38,9TH,MAR,SUN,MER</House_9TH><House_10TH>0.0,057.05671949,27 TAU 03,10TH,VEN,VEN,URA</House_10TH><House_11TH>0.0,092.50277804,02 CAN 30,11TH,MOO,SAT</House_11TH><House_12TH>0.0,124.95549501,04 LEO 57,12TH,SUN,MAR,PLU</House_12TH><Significator>MER</Significator><Hyleg>Uranus</Hyleg><Anareta>37.06722617,90,Mars^55.60326006,90,Saturn^</Anareta><Rising_Planets></Rising_Planets><Planetary_ruler>VEN</Planetary_ruler><Elevated_planet>Sun</Elevated_planet><Midheaven_ruler>VEN</Midheaven_ruler><Moon_Phase>III</Moon_Phase><Eclipse></Eclipse><Mutual_reception>TAU-LIB</Mutual_reception><Angular>Venus,Uranus,</Angular><Succedent>Moon,Jupiter,Saturn,Neptune,</Succedent><Cadent>Sun,Mercury,Mars,Pluto,</Cadent><Fire>2</Fire><Earth>2</Earth><Air>5</Air><Water>1</Water><Cardinal>4</Cardinal><Fixed>4</Fixed><Muatable>2</Muatable><Masculine>7</Masculine><Feminine>3</Feminine><Quadrant_I>3</Quadrant_I><Quadrant_II>0</Quadrant_II><Quadrant_III>2</Quadrant_III><Quadrant_IV>5</Quadrant_IV><South>7</South><North>3</North><East>8</East><West>2</West></HoroItems>
 --->
------------------------<br>
</body>
</html>