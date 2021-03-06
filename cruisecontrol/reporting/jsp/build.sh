#!/bin/sh

################################################################################
# CruiseControl, a Continuous Integration Toolkit
# Copyright (c) 2001, ThoughtWorks, Inc.
# 200 E. Randolph, 25th Floor
# Chicago, IL 60601 USA
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions
# are met:
# 
#     + Redistributions of source code must retain the above copyright 
#       notice, this list of conditions and the following disclaimer. 
#       
#     + Redistributions in binary form must reproduce the above 
#       copyright notice, this list of conditions and the following 
#       disclaimer in the documentation and/or other materials provided 
#       with the distribution. 
#       
#     + Neither the name of ThoughtWorks, Inc., CruiseControl, nor the 
#       names of its contributors may be used to endorse or promote 
#       products derived from this software without specific prior 
#       written permission. 
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR 
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR 
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
################################################################################

#--------------------------------------------
# You may modify the default values below.
#--------------------------------------------

# The name of the build file to use
BUILDFILE=build.xml

# Root directory for the project
PROJECTDIR=.

# Directory where necessary build Java libraries are found
LIBDIR=${PROJECTDIR}/lib

#--------------------------------------------
# set JAVA_HOME on Mac OSX
#--------------------------------------------
case "`uname`" in
  Darwin*)
    if [ -z "$JAVA_HOME" ] ; then
      JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home
    fi
    ;;
esac

#--------------------------------------------
# No need to edit anything past here
#--------------------------------------------

CLASSPATH=lib/ant.jar:lib/ant-junit.jar:lib/ant-launcher.jar:lib/junit.jar:lib/xercesImpl-2.8.0.jar:lib/xml-apis-2.8.0.jar

# Try to find Java Home directory, from JAVA_HOME environment 
# or java executable found in PATH

if test -z "${JAVA_HOME}" ; then
   echo "ERROR: JAVA_HOME not found in your environment."
   echo "Please, set the JAVA_HOME variable in your environment to match the"
   echo "location of the Java Virtual Machine you want to use."
   exit
fi

# convert the existing path to unix
if [ `uname | grep -n CYGWIN` ]; then
   JAVA_HOME=`cygpath --path --unix "$JAVA_HOME"`
fi

# Define the java executable path
if [ "$JAVABIN" = "" ] ; then
  JAVABIN=${JAVA_HOME}/bin/java
fi

# Try to include tools.jar for compilation
if test -f "${JAVA_HOME}/lib/tools.jar" ; then
    CLASSPATH=${CLASSPATH}:${JAVA_HOME}/lib/tools.jar
fi

# convert the unix path to windows
if [ `uname | grep -n CYGWIN` ]; then
   CLASSPATH=`cygpath --path --windows "$CLASSPATH"`
fi

echo ${CLASSPATH}

# Call Ant
exec "${JAVABIN}" -cp "${CLASSPATH}" org.apache.tools.ant.Main \
           -buildfile "${BUILDFILE}" "$@"
