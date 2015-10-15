#
# A Simple Makefile
#

######

include \
$(PATSHOME)/share/atsmake-pre.mk

######

CFLAGS += -O2

######

LDFLAGS :=

######

PATSCCOMP = $(CC) -D_XOPEN_SOURCE

######

SOURCES_SATS += \
  ../../SATS/crc.sats \

SOURCES_DATS += \
  ../../DATS/crc.dats \
  main.dats \

######

MYTARGET=crc

######
#
MYPORTDIR=MYPORTDIR
#
#MYPORTCPP=MYPORTCPP
#
######

include $(PATSHOME)/share/atsmake-post.mk

######

testall:: all
testall:: cleanall

######

cleanall:: ; $(RMF) MYPORTDIR/*

######

###### end of [Makefile] ######