<%@ page language="java" import="java.util.*" errorPage="" %>
<%@ page language="java" import="java.io.*" errorPage="" %>
<%@ page language="java" import="swisseph.*" errorPage="" %>
<%   
String pageDir = "";

if (request.getRealPath(request.getServletPath()) !=null) {
	String []dirs = request.getRealPath(request.getServletPath()).split("/");
	for (int i = 1; i < dirs.length-1; i++) {
		pageDir = pageDir + "/" + dirs[i];
	}
}
		
	/* Declare swisseph classes */
	SweDate sd=new SweDate();
  	SwissData swed=new SwissData();
  	SwissEph sw=new SwissEph();
	
	/* set path Swiss Ephemeris data files */
//	sw.swe_set_ephe_path("/usr/share/sweph/ephe");
	sw.swe_set_ephe_path("/var/lib/openshift/637c3086bc6747a694434a9cf559efae/app-root/repo/src/main/resources/ephe");
	
	/* Set page path */

	
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
	} else {
		strReturn = strReturn+"^"+jmon;
		strReturn = strReturn+"^"+jday;
		strReturn = strReturn+"^"+jyear;
		strReturn = strReturn+"^"+jhour;
		strReturn = strReturn+"^"+jmin;
		strReturn = strReturn+"^"+jtzone;
		strReturn = strReturn+"^"+summerTime;
		strReturn = strReturn+"^"+lngd;
		strReturn = strReturn+"^"+lngm;
		strReturn = strReturn+"^"+lng;
		strReturn = strReturn+"^"+latd;
		strReturn = strReturn+"^"+latm;
		strReturn = strReturn+"^"+lat+"|";
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