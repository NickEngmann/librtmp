VERSION=v2.2e

CC=$(CROSS_COMPILE)gcc
LD=$(CROSS_COMPILE)ld

SYS=posix
#SYS=mingw

CRYPTO=OPENSSL
#CRYPTO=POLARSSL
#CRYPTO=GNUTLS
LIB_GNUTLS=-lgnutls -lgcrypt
LIB_OPENSSL=-lssl -lcrypto
LIB_POLARSSL=-lpolarssl
CRYPTO_LIB=$(LIB_$(CRYPTO))
DEF_=-DNO_CRYPTO
CRYPTO_DEF=$(DEF_$(CRYPTO))

DEF=-DRTMPDUMP_VERSION=\"$(VERSION)\" $(CRYPTO_DEF) $(XDEF)
OPT=-O2
CFLAGS=-Wall $(XCFLAGS) $(INC) $(DEF) $(OPT)
LDFLAGS=-Wall $(XLDFLAGS)

LIBS_posix=
LIBS_mingw=-lws2_32 -lwinmm -lgdi32
LIBS=$(CRYPTO_LIB) -lz $(LIBS_$(SYS))

THREADLIB_posix=-lpthread
THREADLIB_mingw=
THREADLIB=$(THREADLIB_$(SYS))
SLIBS=$(THREADLIB) $(LIBS)

LIBRTMP=librtmp/librtmp.a
INCRTMP=librtmp/rtmp_sys.h librtmp/rtmp.h librtmp/log.h librtmp/amf.h

EXT_posix=
EXT_mingw=.exe
EXT=$(EXT_$(SYS))

all:	$(LIBRTMP) progs

progs:	rtmpdump rtmpgw rtmpsrv rtmpsuck

clean:
	rm -f *.o rtmpdump$(EXT) rtmpgw$(EXT) rtmpsrv$(EXT) rtmpsuck$(EXT)
	@cd librtmp; $(MAKE) clean

FORCE:

$(LIBRTMP): FORCE
	@cd librtmp; $(MAKE) $(MF) all

# note: $^ is GNU Make's equivalent to BSD $>
# we use both since either make will ignore the one it doesn't recognize

rtmpdump: rtmpdump.o $(LIBRTMP)
	$(CC) $(LDFLAGS) $^ $> -o $@$(EXT) $(LIBS)

rtmpsrv: rtmpsrv.o thread.o $(LIBRTMP)
	$(CC) $(LDFLAGS) $^ $> -o $@$(EXT) $(SLIBS)

rtmpsuck: rtmpsuck.o thread.o $(LIBRTMP)
	$(CC) $(LDFLAGS) $^ $> -o $@$(EXT) $(SLIBS)

rtmpgw: rtmpgw.o thread.o $(LIBRTMP)
	$(CC) $(LDFLAGS) $^ $> -o $@$(EXT) $(SLIBS)

rtmpgw.o: rtmpgw.c $(INCRTMP) Makefile
rtmpdump.o: rtmpdump.c $(INCRTMP) Makefile
rtmpsrv.o: rtmpsrv.c $(INCRTMP) Makefile
rtmpsuck.o: rtmpsuck.c $(INCRTMP) Makefile
thread.o: thread.c thread.h
