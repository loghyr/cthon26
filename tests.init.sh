#!/bin/sh

FSTYPE=${1:-nfs}
OS=${2:-`uname -s`}
Initfile=tests.init

cat <<EOF >$Initfile
#
#       @(#)tests.init	1.26 2003/12/30 Connectathon testsuite
#
MNTOPTIONS="rw,hard,intr"
# Dummy MNTPOINT definition; should get overriden by server script.
MNTPOINT="/mnt/$FSTYPE"

SERVER=""
SERVPATH="/server"
TEST="-a"
TESTARG="-t"

EOF

# set MOUNTCMD and UMOUNTCMD
echo "# set MOUNTCMD and UMOUNTCMD" >>$Initfile
case $OS in
SVR3)
cat <<\EOF >>$Initfile
# Use this mount command if using:
#	SVR3
MOUNTCMD='./domount -f NFS,$MNTOPTIONS $SERVER\:$SERVPATH $MNTPOINT'
EOF
;;
SVR4|Solaris2.x)
cat <<\EOF >>$Initfile
# Use this mount command if using:
#	SVR4
#	Solaris 2.x
MOUNTCMD='./domount -F nfs -o $MNTOPTIONS $SERVER\:$SERVPATH $MNTPOINT'
CFSMOUNTCMD='./domount -F cachefs -o $MNTOPTIONS $SERVER\:$SERVPATH $MNTPOINT'
EOF
;;
*BSD|SunOS4.x|Tru64UNIX|HPUX|Linux|AIX|MacOSX)
cat <<\EOF >>$Initfile
# Use this mount command if using:
#	BSD
#	SunOS 4.X
#	Tru64 UNIX
#	HPUX
#	Linux
#	AIX
#	Mac OS X
# At least some BSD systems don't recognize "hard" (since that's the
# default), so you might also want to use this definition of MNTOPTIONS.
MNTOPTIONS="rw,intr"
MOUNTCMD='./domount -o $MNTOPTIONS $SERVER\:$SERVPATH $MNTPOINT'
EOF
;;
DG/UX)
cat <<\EOF >>$Initfile
# Use this mount command if using:
#	DG/UX
MOUNTCMD='./domount -t nfs -o $MNTOPTIONS $SERVER\:$SERVPATH $MNTPOINT'
EOF
;;
esac

if test $FSTYPE = cifs; then
	cat <<\EOF >>$Initfile
# Use this mount command if using:
#	SMB/CIFS
MOUNTCMD='./domount -t cifs -o $MNTOPTIONS //$SERVER/$SERVPATH $MNTPOINT'
EOF
fi
cat <<\EOF >>$Initfile
UMOUNTCMD='./domount -u $MNTPOINT'

EOF

# set DASHN and BLC
echo "# set DASHN and BLC" >>$Initfile
case $OS in
SVR3|SVR4|Solaris2.x|HPUX)
cat <<\EOF >>$Initfile
# Use the next two lines if using:
#	SVR3
#	SVR4
#	Solaris 2.x
#	HPUX
DASHN=
BLC=\\c
EOF
;;
*BSD|SunOS4.x|Linux|Tru64UNIX|MacOSX)
cat <<\EOF >>$Initfile
# Use the next two lines if using:
#	BSD
#	SunOS 4.X
#	Linux
#	Tru64 UNIX
#	Mac OS X
DASHN=-n
BLC=
EOF
;;
esac

# set PATH
echo >>$Initfile
echo "# set PATH" >>$Initfile
case $OS in
Solaris2.x)
cat <<\EOF >>$Initfile
# Use this path for:
#	Solaris 2.x
PATH=/opt/SUNWspro/bin:/usr/ccs/bin:/sbin:/bin:/usr/bin:/usr/ucb:/etc:.

# Use this path for:
#	Solaris 2.x with GCC
#PATH=/opt/gnu/bin:/usr/ccs/bin:/sbin:/bin:/usr/bin:/usr/ucb:/etc:.

EOF
;;

HPUX)
cat <<\EOF >>$Initfile
# Use this path for:
#	HPUX
PATH=/bin:/usr/bin:/etc:/usr/etc:/usr/local/bin:/usr/contrib/bin:.

EOF
;;

*BSD|SunOS4.x)
cat <<\EOF >>$Initfile
# Use this path for:
#	BSD
#	SunOS 4.X
PATH=/bin:/usr/bin:/usr/ucb:/etc:/usr/etc:.

EOF
;;

Tru64UNIX|SVR4|Linux)
cat <<\EOF >>$Initfile
# Use this path for:
#	Tru64 UNIX
#	SVR4
#	Linux
PATH=/bin:/usr/bin:/usr/ucb:/usr/ccs/bin:/sbin:/usr/sbin:.

EOF
;;

DG/UX)
cat <<\EOF >>$Initfile
# Use this path for:
#	DG/UX
PATH=/bin:/usr/bin:/usr/ucb:/etc:/usr/etc:.

EOF
;;

IRIX)
cat <<\EOF >>$Initfile
# Use this path for:
#	IRIX
PATH=/bin:/usr/bin:/usr/bsd:/etc:/usr/etc:.

EOF
;;

AIX)
cat <<\EOF >>$Initfile
# Use this path for:
#	AIX
PATH=/usr/bin:/etc:/usr/sbin:/usr/ucb:/usr/bin/X11:/sbin:.

EOF
;;

MacOSX)
cat <<\EOF >>$Initfile
# Use this path for:
#	Mac OS X
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/X11R6/bin:.
EOF
;;
esac

#===============================================================================

cat <<\EOF >>$Initfile
# -----------------------------------------------
# Defines for various variables used in scripts and makefiles.
#
# Do not remove the following three lines.  They may be overridden by
# other configuration parameters lower in this file, but these three
# variables must be defined.
CC=cc
CFLAGS=
LIBS=
LOCKTESTS=tlock
EOF

case $OS in
SVR3)
cat <<\EOF >>$Initfile
# Use with SVR3 systems.
# Add -TR2 to CFLAGS for use on Amdahl UTS systems.
CFLAGS=-DSVR3
LIBS=`echo -lrpc -lsocket`
EOF
;;

*BSD)
cat <<\EOF >>$Initfile
# Use with BSD systems.
CC=cc
CFLAGS=`echo -DBSD -DSTDARG`
# dirdmp accesses opaque DIR struct internals; skip it on modern BSD.
DIRDMP=
MOUNT=/sbin/mount
UMOUNT=/sbin/umount
EOF
;;

SVR4)
cat <<\EOF >>$Initfile
# Use with SVR4 systems.
CFLAGS=-DSVR4
LIBS=`echo -lsocket -lnsl`
EOF
;;

SunOS4.x)
cat <<\EOF >>$Initfile
# Use with SunOS 4.X systems
CC=/usr/5bin/cc
CFLAGS=`echo -DSUNOS4X -DNEED_STRERROR`
EOF
;;

Solaris2.x)
cat <<\EOF >>$Initfile
# Use with Solaris 2.x systems.  Need the 5.0 C compiler (or later)
# for 64-bit mode.
#CC=/opt/SUNWspro/bin/cc
# Use this with GCC
#CC=/opt/gnu/bin/gcc
# Use this through Solaris 2.6.  For Solaris 2.7 and later, use
# this for 32-bit mode applications.
#CFLAGS=`echo -DSVR4 -DMMAP -DSOLARIS2X -DSTDARG`
# Use this with gcc (32-bit binaries):
#CFLAGS=`echo -DSVR4 -DMMAP -DSOLARIS2X -DSTDARG -mcpu=ultrasparc`
# For Solaris 2.7 and later, use this for 64-bit mode applications
# (Sun compiler).
#CFLAGS=`echo -DSVR4 -DMMAP -DSOLARIS2X -DSTDARG -xO0 -xarch=v9 -dalign -Xt -L/usr/lib/sparcv9`
# Use this to make 64-bit binaries with gcc (3.1 or later; untested): 
#CFLAGS=`echo -DSVR4 -DMMAP -DSOLARIS2X -DSTDARG -m64`
LIBS=`echo -lsocket -lnsl`
# Use this through Solaris 2.5.1.
#LOCKTESTS=`echo tlock`
# Use with 2.6 and later systems, 32-bit mode.
LOCKTESTS=`echo tlocklfs tlock64`
# Use with 2.7 and later, 64-bit mode.
#LOCKTESTS=`echo tlocklfs`
EOF
;;

Tru64UNIX)
cat <<\EOF >>$Initfile
# Use with Tru64 UNIX systems
#CFLAGS=`echo -O -DTRU64 -DOSF1 -DMMAP -DSTDARG`
# use the following instead of the above if using gcc
#CFLAGS=`echo -O -DTRU64 -DOSF1 -DMMAP -DSTDARG -fwritable-strings`
# 64-bit binaries with gcc (3.1 or later; untested):
#CFLAGS=`echo -O -DTRU64 -DOSF1 -DMMAP -DSTDARG -fwritable-strings -m64`
#MOUNT=/sbin/mount
#UMOUNT=/sbin/umount
EOF
;;

HPUX10B)
cat <<\EOF >>$Initfile
# Use with HPUX systems, 10.00 and earlier.
CFLAGS=-DHPUX
CC=/bin/cc
RM=/bin/rm
MAKE=/bin/make
EOF
;;

HPUX10a)
cat <<\EOF >>$Initfile
# Use with HPUX 10.01.
CFLAGS=`echo -Ae -DHPUX`
CC=/opt/ansic/bin/cc
RM=/bin/rm
MAKE=/usr/bin/make
EOF
;;

HPUX11-32)
cat <<\EOF >>$Initfile
# Use with HPUX 11.0, 32-bit machines.
CFLAGS=`echo -Ae -DHPUX -D_PSTAT64 -D_LARGEFILE64_SOURCE -DPORTMAP`
CC=/opt/ansic/bin/cc
LIBS=`echo -lnsl`
RM=/bin/rm
MAKE=/usr/bin/make
EOF
;;

HPUX11-64)
cat <<\EOF >>$Initfile
# Use with HPUX 11.0, 64-bit machines.
CFLAGS=`echo -Ae -DHPUX -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE`
CC=/opt/ansic/bin/cc
RM=/bin/rm
MAKE=/usr/bin/make
EOF
;;

DG/UX)
cat <<\EOF >>$Initfile
# Use with DG/UX systems.
CFLAGS=-DSVR4
LIBS=`echo -lsocket -lnsl`
EOF
;;

IRIX)
cat <<\EOF >>$Initfile
# Use with IRIX systems. Use HAVE_SOCKLEN_T for IRIX >= 6.5.19. 
CFLAGS=`echo -g -DHAVE_SOCKLEN_T -DSTDARG -DSVR4 -DIRIX -DMMAP`
EOF
;;

AIX)
cat <<\EOF >>$Initfile
# Use with AIX.
CC=gcc
CFLAGS=`echo -DAIX -DSTDARG -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE`
LOCKTESTS=`echo tlocklfs`
EOF
;;

MacOSX)
cat <<\EOF >>$Initfile
# Use with Mac OS X
CFLAGS=`echo -DMACOSX -DNATIVE64 -DLARGE_LOCKS`
MOUNT=/sbin/mount
UMOUNT=/sbin/umount
LOCKTESTS=`echo tlock`
EOF
;;

Linux)
cat <<\EOF >>$Initfile
MOUNT=/bin/mount
UMOUNT=/bin/umount
LOCKTESTS=`echo tlocklfs tlock64`

# Use with Linux if your distro doesn't provide a "cc".
CC=gcc

# Use with Linux 2.2 / GNU libc 2.0
#CFLAGS=`echo -DLINUX -DGLIBC=20 -DMMAP -DSTDARG -fwritable-strings`
#LIBS=`echo -lnsl`

# Use with Linux 2.4 / GNU libc 2.2
#CFLAGS=`echo -DLINUX -DGLIBC=22 -DMMAP -DSTDARG -fwritable-strings`
#LIBS=`echo -lnsl`

# Use with Linux 2.6 / gcc 4.0
CFLAGS=`echo -DLINUX -DHAVE_SOCKLEN_T -DGLIBC=22 -DMMAP -DSTDARG`
LIBS=`echo -lnsl`

EOF

glibc_version_base=2.26
glibc_version_current=`ldd --version|sed -n '1{s/.* //;p}'`
glibc_version_older=`{ echo $glibc_version_base; echo $glibc_version_current; } | sort | head -n1`
if [ "$glibc_version_older" = "$glibc_version_base" ]; then
	cat <<\EOF >>$Initfile
# Use with Linux glibc > 2.26
CFLAGS=`echo -DLINUX -DHAVE_SOCKLEN_T -DGLIBC=22 -DMMAP -DSTDARG`
CFLAGS+=`pkg-config --cflags libtirpc`
LIBS=`pkg-config --libs libtirpc`
EOF
fi

;;
esac

