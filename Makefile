# Makefile - dantto4k build for Linux (no ACAS decryption)
#
# Builds the MMT/TLV -> MPEG-2 TS remuxer only. The ACAS / smart card / AES-NI
# code is not compiled;
#  the binary always behaves as if --frontend-descrambled was specified (see DANTTO4K_NO_CAS in src/dantto4k.cpp).

PROJECT_NAME = dantto4k

SRC_DIR = src
OBJ_DIR = build-linux

CROSS_COMPILE ?=
CXX           ?= g++
ifneq ($(CROSS_COMPILE),)
CXX := $(CROSS_COMPILE)g++
endif
PKG_CONFIG ?= pkg-config
PYTHON     ?= python3

# x86-only (AES-NI) or smart card / PC/SC / asio code.
EXCLUDE = $(SRC_DIR)/acasCard.cpp \
          $(SRC_DIR)/acasHandler.cpp \
          $(SRC_DIR)/aes.cpp \
          $(SRC_DIR)/smartCard.cpp \
          $(SRC_DIR)/casProxyClient.cpp \
          $(SRC_DIR)/dllmain.cpp

# BonDriver glue: only part of the shared object, not of the command line tool.
BON_SRC  = $(SRC_DIR)/bonTuner.cpp $(SRC_DIR)/dllmainLinux.cpp
MAIN_SRC = $(SRC_DIR)/dantto4k.cpp

COMMON_SRC = $(filter-out $(EXCLUDE) $(BON_SRC) $(MAIN_SRC), \
             $(wildcard $(SRC_DIR)/*.cpp) $(wildcard $(SRC_DIR)/ttml/*.cpp))
tobj = $(patsubst $(SRC_DIR)/%.cpp,$(OBJ_DIR)/%.o,$1)
OBJ_FILES    = $(call tobj,$(COMMON_SRC) $(MAIN_SRC))
SO_OBJ_FILES = $(call tobj,$(COMMON_SRC) $(BON_SRC))

# Override e.g. OPT="-O3 -mcpu=native" for the target SoC.
OPT      ?= -O2
# -fPIC so the same objects can go into both the executable and the BonDriver .so.
CXXFLAGS += -std=c++20 $(OPT) -fPIC -Wall -DDANTTO4K_NO_CAS -I$(SRC_DIR) -MMD -MP
LDFLAGS  += -lpthread -ldl

TS_FILES = \
    libtscore/algo/tsAbstractOutputStream.cpp \
    libtscore/algo/tsRingNode.cpp \
    libtscore/algo/tsUID.cpp \
    libtscore/app/tsArgs.cpp \
    libtscore/app/tsConfigFile.cpp \
    libtscore/app/tsConfigSection.cpp \
    libtscore/app/tsDuckConfigFile.cpp \
    libtscore/app/tsFeatures.cpp \
    libtscore/app/tsGitHubRelease.cpp \
    libtscore/app/tsLibTSCoreVersion.cpp \
    libtscore/app/tsNames.cpp \
    libtscore/app/tsVersionInfo.cpp \
    libtscore/crypto/private/tsCRC32.accel.cpp \
    libtscore/crypto/private/tsFetchAlgorithm.cpp \
    libtscore/crypto/tsCRC32.cpp \
    libtscore/crypto/tsCryptoLibrary.cpp \
    libtscore/crypto/tsHash.cpp \
    libtscore/crypto/tsSHA1.cpp \
    libtscore/json/tsjson.cpp \
    libtscore/json/tsjsonArray.cpp \
    libtscore/json/tsjsonFalse.cpp \
    libtscore/json/tsjsonNull.cpp \
    libtscore/json/tsjsonNumber.cpp \
    libtscore/json/tsjsonObject.cpp \
    libtscore/json/tsjsonString.cpp \
    libtscore/json/tsjsonTrue.cpp \
    libtscore/json/tsjsonValue.cpp \
    libtscore/network/tsAbstractNetworkAddress.cpp \
    libtscore/network/tsIPAddress.cpp \
    libtscore/network/tsIPSocketAddress.cpp \
    libtscore/network/tsIPUtils.cpp \
    libtscore/network/tsMACAddress.cpp \
    libtscore/network/tsURL.cpp \
    libtscore/network/tsWebRequest.cpp \
    libtscore/network/tsWebRequestArgs.cpp \
    libtscore/network/unix/tsWebRequestGuts.cpp \
    libtscore/report/tsCerrReport.cpp \
    libtscore/report/tsErrCodeReport.cpp \
    libtscore/report/tsNullReport.cpp \
    libtscore/report/tsReport.cpp \
    libtscore/report/tsSeverity.cpp \
    libtscore/system/private/tsTimeConfigurationFile.cpp \
    libtscore/system/tsAbstractReadStreamInterface.cpp \
    libtscore/system/tsAbstractWriteStreamInterface.cpp \
    libtscore/system/tsApplicationSharedLibrary.cpp \
    libtscore/system/tsEnvironment.cpp \
    libtscore/system/tsFatal.cpp \
    libtscore/system/tsFileUtils.cpp \
    libtscore/system/tsForkPipe.cpp \
    libtscore/system/tsOutputPager.cpp \
    libtscore/system/tsSharedLibrary.cpp \
    libtscore/system/tsSysInfo.cpp \
    libtscore/system/tsSysUtils.cpp \
    libtscore/system/tsThread.cpp \
    libtscore/system/tsThreadAttributes.cpp \
    libtscore/system/tsTime.cpp \
    libtscore/system/unix/tsOpenSSL.cpp \
    libtscore/system/unix/tsSysCtl.cpp \
    libtscore/text/tsTLVSyntax.cpp \
    libtscore/text/tsTextFormatter.cpp \
    libtscore/text/tsTextParser.cpp \
    libtscore/text/tsTextTable.cpp \
    libtscore/types/tsAbstractNumber.cpp \
    libtscore/types/tsArgMix.cpp \
    libtscore/types/tsBCD.cpp \
    libtscore/types/tsBuffer.cpp \
    libtscore/types/tsByteBlock.cpp \
    libtscore/types/tsException.cpp \
    libtscore/types/tsIntegerUtils.cpp \
    libtscore/types/tsMemory.cpp \
    libtscore/types/tsStringifyInterface.cpp \
    libtscore/types/tsUChar.cpp \
    libtscore/types/tsUString.cpp \
    libtscore/xml/tsxmlAttribute.cpp \
    libtscore/xml/tsxmlComment.cpp \
    libtscore/xml/tsxmlDeclaration.cpp \
    libtscore/xml/tsxmlDocument.cpp \
    libtscore/xml/tsxmlElement.cpp \
    libtscore/xml/tsxmlJSONConverter.cpp \
    libtscore/xml/tsxmlModelDocument.cpp \
    libtscore/xml/tsxmlNode.cpp \
    libtscore/xml/tsxmlText.cpp \
    libtscore/xml/tsxmlTweaks.cpp \
    libtscore/xml/tsxmlUnknown.cpp \
    libtsduck/app/tsLibTSDuckVersion.cpp \
    libtsduck/dtv/atsc/tsATSCMultipleString.cpp \
    libtsduck/dtv/broadcast/tsHFBand.cpp \
    libtsduck/dtv/broadcast/tsModulation.cpp \
    libtsduck/dtv/cas/tsCAS.cpp \
    libtsduck/dtv/charset/tsARIBCharset.cpp \
    libtsduck/dtv/charset/tsARIBCharsetData.cpp \
    libtsduck/dtv/charset/tsARIBCharsetEncoding.cpp \
    libtsduck/dtv/charset/tsCharset.cpp \
    libtsduck/dtv/charset/tsDVBCharTable.cpp \
    libtsduck/dtv/charset/tsDVBCharTableSingleByte.cpp \
    libtsduck/dtv/charset/tsDVBCharTableUTF8.cpp \
    libtsduck/dtv/charset/tsDVBCharset.cpp \
    libtsduck/dtv/codec/tsCodecType.cpp \
    libtsduck/dtv/demux/tsAbstractDemux.cpp \
    libtsduck/dtv/demux/tsAbstractPacketizer.cpp \
    libtsduck/dtv/demux/tsCyclingPacketizer.cpp \
    libtsduck/dtv/demux/tsDemuxedData.cpp \
    libtsduck/dtv/demux/tsInvalidSectionHandlerInterface.cpp \
    libtsduck/dtv/demux/tsOneShotPacketizer.cpp \
    libtsduck/dtv/demux/tsPacketizer.cpp \
    libtsduck/dtv/demux/tsSectionDemux.cpp \
    libtsduck/dtv/demux/tsSectionHandlerInterface.cpp \
    libtsduck/dtv/demux/tsSectionProviderInterface.cpp \
    libtsduck/dtv/demux/tsTableHandlerInterface.cpp \
    libtsduck/dtv/descriptors/dvb/tsComponentDescriptor.cpp \
    libtsduck/dtv/descriptors/dvb/tsContentDescriptor.cpp \
    libtsduck/dtv/descriptors/dvb/tsDVBAC3Descriptor.cpp \
    libtsduck/dtv/descriptors/dvb/tsLinkageDescriptor.cpp \
    libtsduck/dtv/descriptors/dvb/tsLocalTimeOffsetDescriptor.cpp \
    libtsduck/dtv/descriptors/dvb/tsParentalRatingDescriptor.cpp \
    libtsduck/dtv/descriptors/dvb/tsServiceDescriptor.cpp \
    libtsduck/dtv/descriptors/dvb/tsServiceListDescriptor.cpp \
    libtsduck/dtv/descriptors/dvb/tsStreamIdentifierDescriptor.cpp \
    libtsduck/dtv/descriptors/isdb/tsAudioComponentDescriptor.cpp \
    libtsduck/dtv/descriptors/isdb/tsDataComponentDescriptor.cpp \
    libtsduck/dtv/descriptors/isdb/tsDataContentDescriptor.cpp \
    libtsduck/dtv/descriptors/isdb/tsDigitalCopyControlDescriptor.cpp \
    libtsduck/dtv/descriptors/isdb/tsEventGroupDescriptor.cpp \
    libtsduck/dtv/descriptors/isdb/tsExtendedBroadcasterDescriptor.cpp \
    libtsduck/dtv/descriptors/isdb/tsISDBAccessControlDescriptor.cpp \
    libtsduck/dtv/descriptors/isdb/tsLogoTransmissionDescriptor.cpp \
    libtsduck/dtv/descriptors/isdb/tsSIParameterDescriptor.cpp \
    libtsduck/dtv/descriptors/isdb/tsSeriesDescriptor.cpp \
    libtsduck/dtv/descriptors/mpeg/tsCADescriptor.cpp \
    libtsduck/dtv/descriptors/mpeg/tsRegistrationDescriptor.cpp \
    libtsduck/dtv/descriptors/tsAbstractDescriptor.cpp \
    libtsduck/dtv/dvb/tsDVB.cpp \
    libtsduck/dtv/dvb/tsMJD.cpp \
    libtsduck/dtv/dvb/tsPDS.cpp \
    libtsduck/dtv/dvb/tsServiceIdTriplet.cpp \
    libtsduck/dtv/dvb/tsTransportStreamId.cpp \
    libtsduck/dtv/epg/tsEITGenerator.cpp \
    libtsduck/dtv/epg/tsEITRepetitionProfile.cpp \
    libtsduck/dtv/pes/tsPES.cpp \
    libtsduck/dtv/signalization/tsAbstractDefinedByStandards.cpp \
    libtsduck/dtv/signalization/tsAbstractSignalization.cpp \
    libtsduck/dtv/signalization/tsAbstractTableAttachment.cpp \
    libtsduck/dtv/signalization/tsBinaryTable.cpp \
    libtsduck/dtv/signalization/tsDID.cpp \
    libtsduck/dtv/signalization/tsDescriptor.cpp \
    libtsduck/dtv/signalization/tsDescriptorContext.cpp \
    libtsduck/dtv/signalization/tsDescriptorList.cpp \
    libtsduck/dtv/signalization/tsEDID.cpp \
    libtsduck/dtv/signalization/tsPSIBuffer.cpp \
    libtsduck/dtv/signalization/tsPSIRepository.cpp \
    libtsduck/dtv/signalization/tsREGID.cpp \
    libtsduck/dtv/signalization/tsSection.cpp \
    libtsduck/dtv/signalization/tsSectionContext.cpp \
    libtsduck/dtv/signalization/tsSectionFile.cpp \
    libtsduck/dtv/signalization/tsSectionFormat.cpp \
    libtsduck/dtv/signalization/tsService.cpp \
    libtsduck/dtv/signalization/tsStreamType.cpp \
    libtsduck/dtv/signalization/tsTID.cpp \
    libtsduck/dtv/signalization/tsTablesDisplay.cpp \
    libtsduck/dtv/signalization/tsXDID.cpp \
    libtsduck/dtv/signalization/tsXTID.cpp \
    libtsduck/dtv/standards/tsDuckContext.cpp \
    libtsduck/dtv/standards/tsOUI.cpp \
    libtsduck/dtv/standards/tsStandards.cpp \
    libtsduck/dtv/tables/dvb/tsAbstractTransportListTable.cpp \
    libtsduck/dtv/tables/dvb/tsEIT.cpp \
    libtsduck/dtv/tables/dvb/tsNIT.cpp \
    libtsduck/dtv/tables/dvb/tsSDT.cpp \
    libtsduck/dtv/tables/dvb/tsTDT.cpp \
    libtsduck/dtv/tables/dvb/tsTOT.cpp \
    libtsduck/dtv/tables/isdb/tsBIT.cpp \
    libtsduck/dtv/tables/isdb/tsCDT.cpp \
    libtsduck/dtv/tables/mpeg/tsPAT.cpp \
    libtsduck/dtv/tables/mpeg/tsPMT.cpp \
    libtsduck/dtv/tables/tsAbstractLongTable.cpp \
    libtsduck/dtv/tables/tsAbstractTable.cpp \
    libtsduck/dtv/transport/tsBitRate.cpp \
    libtsduck/dtv/transport/tsTS.cpp \
    libtsduck/dtv/transport/tsTSPacket.cpp

TS_DEFS = -DTS_NO_OPENSSL -DTS_NO_PCSC -DTS_NO_CURL -DTS_NO_SRT -DTS_NO_RIST \
          -DTS_NO_DEKTEC -DTS_NO_VATEK -DTS_NO_HIDES

# All tsduck source dirs except other platforms' (header lookup is by file name).
TSDUCK_SRC = ./thirdparty/tsduck/src
TS_INC := $(addprefix -I,$(shell find $(TSDUCK_SRC)/libtscore $(TSDUCK_SRC)/libtsduck -type d \
         | grep -Ev '/(windows|mac|bsd|freebsd|netbsd|openbsd|dragonflybsd)(/|$$)'))


TS_OBJ_FILES = $(patsubst %.cpp,$(OBJ_DIR)/tsduck/%.o,$(TS_FILES))
NAMES_FILE   = $(OBJ_DIR)/tsduck.dtv.names
CXXFLAGS    += -DDANTTO4K_MINIMAL_TSDUCK $(TS_DEFS) $(TS_INC) $(EXTRA_INC)


EXEC = $(OBJ_DIR)/$(PROJECT_NAME)
BONDRIVER_SO ?= $(OBJ_DIR)/BonDriver_dantto4k.so
BONDRIVER_MAP = $(OBJ_DIR)/bondriver.map
PREFIX ?= /usr/local

all: $(EXEC) $(NAMES_FILE) $(BONDRIVER_SO)

bondriver: $(BONDRIVER_SO) $(NAMES_FILE)

$(BONDRIVER_SO): $(SO_OBJ_FILES) $(TS_OBJ_FILES) $(BONDRIVER_MAP)
	$(CXX) -shared -Wl,--version-script=$(BONDRIVER_MAP) -Wl,-Bsymbolic $(SO_OBJ_FILES) $(TS_OBJ_FILES) $(LDFLAGS) -o $@

# Export CreateBonDriver only; everything else (tsduck, std::...) stays private.
$(BONDRIVER_MAP):
	@mkdir -p $(OBJ_DIR)
	printf '{ global: CreateBonDriver; local: *; };\n' > $@

$(EXEC): $(OBJ_FILES) $(TS_OBJ_FILES)
	$(CXX) $^ $(LDFLAGS) -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(OBJ_DIR)/tsduck/%.o: $(TSDUCK_SRC)/%.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -w -c $< -o $@

$(OBJ_DIR)/tsduck.dtv.names:
	@mkdir -p $(OBJ_DIR)
	PYTHONPATH=$(TSDUCK_SRC)/../scripts $(PYTHON) $(TSDUCK_SRC)/../scripts/build-dtv-names.py \
	    $@ $(TSDUCK_SRC)/libtsduck/dtv

clean:
	rm -rf $(OBJ_DIR)

install: all
	install -D -m 0755 $(EXEC) $(DESTDIR)$(PREFIX)/bin/$(PROJECT_NAME)
ifneq ($(NAMES_FILE),)
	install -D -m 0644 $(NAMES_FILE) $(DESTDIR)$(PREFIX)/share/tsduck/tsduck.dtv.names
endif

-include $(OBJ_FILES:.o=.d) $(SO_OBJ_FILES:.o=.d) $(TS_OBJ_FILES:.o=.d)

.PHONY: all bondriver clean install
