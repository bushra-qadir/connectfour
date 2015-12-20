#!/usr/bin/env bash

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

# The root of the CruiseControl directory.  The key requirement is that this is the parent
# directory of CruiseControl's lib and dist directories.

# Inspired by Ant's wrapper script

# Uncomment the following line if you have OutOfMemoryError errors
# CC_OPTS="-Xms128m -Xmx256m"

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

if [ -z "$CCDIR" ] ; then
  # resolve links - $0 may be a softlink
  PRG="$0"

  # need this for relative symlinks
  while [ -h "$PRG" ] ; do
    ls=`ls -ld "$PRG"`
    link=`expr "$ls" : '.*-> \(.*\)$'`
    if expr "$link" : '/.*' > /dev/null; then
      PRG="$link"
    else
      PRG=`dirname "$PRG"`"/$link"
    fi
  done

  saveddir=`pwd`

  CCDIR=`dirname "$PRG"`/../../main

  # make it fully qualified
  CCDIR=`cd "$CCDIR" && pwd`

  cd $saveddir
  echo Using Cruise Control at $CCDIR
fi

LIBDIR=$CCDIR/lib
DISTDIR=$CCDIR/dist
LAUNCHER=$DISTDIR/cruisecontrol-launcher.jar

if [ `uname | grep -n CYGWIN` ]; then
    # convert the existing Java path to UNIX
    JAVA_HOME=`cygpath --unix "$JAVA_HOME"`
    # convert the existing launcher path to Windows
    LAUNCHER=`cygpath --windows "$LAUNCHER"`
fi

# some of these need slashes (to get jars via -lib), others do not (conf dir)
CCDIST=$CCDIR/../contrib/distributed
CCDIST_BUILDER=$CCDIST/dist/builder/
CCDIST_CORE=$CCDIST/dist/core/
CCDIST_JINICORE=$CCDIST/jini-core/
CCDIST_JINILIBDL=$CCDIST/jini-lib-dl/jsk-dl.jar
CCDIST_CONF=$CCDIST/conf

# use existing ${CC_PID} if already defined, else define
if [ ! "${CC_PID}" ] ; then
  CC_PID=cc.pid
fi

# check ${CC_PID} is writable
if [ -f "${CC_PID}" ] ; then
  if [ ! -w "${CC_PID}" ] ; then
    echo "CruiseControl pid file not writable"
    exit 1
  fi
  if [ -f "${CC_PID}" ] ; then
   PID=`head -1 ${CC_PID}`
    # is ${CC_PID} a number
    if [ `echo ${PID} | sed 's/^$/_/g' | sed 's/[0-9]//g' | wc -c` -eq 1 ] ; then
      # is ${CC_PID} a running process and double check that it is cruisecontrol
      if [ `ps -fp ${PID} | grep -v grep | grep cruisecontrol | wc -l` -eq 1 ] ; then
        echo "CruiseControl is already running"
        exit 1
      else
        echo "CruiseControl stale pid"
      fi
    fi
  fi
fi

EXEC="$JAVA_HOME/bin/java $CC_OPTS -Djavax.management.builder.initial=mx4j.server.MX4JMBeanServerBuilder -Djava.security.policy=$CCDIST_CONF/insecure.policy -Dcc.library.dir=$LIBDIR -Dcc.dist.dir=$DISTDIR -jar $LAUNCHER -lib $JAVA_HOME/lib/tools.jar -lib $CCDIST_BUILDER:$CCDIST_CORE:$CCDIST_JINICORE:$CCDIST_JINILIBDL:$CCDIST_CONF $@"
echo $EXEC
$EXEC &
PID=$!
echo ${PID} > ${CC_PID}