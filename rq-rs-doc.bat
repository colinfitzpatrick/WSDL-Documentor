@echo off

REM Copyright © 2012 Colin Fitzpatrick

REM Request/Response Document Generator
REM Takes a WSDL, Sample XML Request and Sample XML Response and produces:
REM HTML Documentation of XML Request.

REM Location of the XALAN XML Engine (Download: http://www.apache.org/dyn/closer.cgi/xml/xalan-j)
SET XALAN_DIR=xalan

REM Where to store the output
REM (If you change this, you'll need to change the location of the CSS file)
SET OUT_DIR=.\output

set CLASSPATH=%XALAN_DIR%\xalan.jar;%XALAN_DIR%\serializer.jar;%XALAN_DIR%\xml-apis.jar;%XALAN_DIR%\xercesImpl.jar

IF "%~1"=="" GOTO Continue
IF "%~2"=="" GOTO Continue

pushd "%~dp0"

mkdir "%OUT_DIR%\%~n1"

echo Creating HTML Markup for XML
java org.apache.xalan.xslt.Process -PARAM WSDL "%~1" -PARAM TITLE %~n2 -IN "%OUT_DIR%\%~n1\%~n2.xml" -XSL xsl\rq-rs-doc.xsl -OUT "%OUT_DIR%\%~n1\%~n2.html"

GOTO End

:Continue
echo "Command line paramters not set"
echo rq-rs-doc "WSDL" "XML Sample"

:End
popd
@echo on
