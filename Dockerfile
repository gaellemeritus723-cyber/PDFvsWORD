FROM tomcat:10.1-jdk17

COPY dist/PDFvsWORD.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080