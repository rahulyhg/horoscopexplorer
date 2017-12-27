<%  
String REPO_DIR = System.getProperty("OPENSHIFT_REPO_DIR");
String APP_DIR =  System.getProperty("OPENSHIFT_APP_DIR");

//if (request.getRealPath(request.getServletPath()) !=null) {
//	String []splits = request.getRealPath(request.getServletPath()).split("/");
//	for (int i = 1; i < splits.length-1; i++) {
//		myDir = myDir + "/" + splits[i];
//	}
//}

%>
<html>
<head><title>Show Request Path</title></head>
<h2>Show Path:</h2>
<b>URL: </b><%= request.getRequestURL() %><br>
<b>ServletPath: </b><%= request.getServletPath() %><br>
<b>Absolute Path: </b><%= request.getRealPath(request.getServletPath()) %><br>
<b>REPO_DIR: </b><%= REPO_DIR %><br>
<b>APP_DIR: </b><%= APP_DIR %><br>
</html>