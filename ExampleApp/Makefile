export TARGET = iphone:13.3:10.0
export ARCHS = arm64

INSTALL_TARGET_PROCESSES = ExampleApp

include $(THEOS)/makefiles/common.mk

XCODEPROJ_NAME = ExampleApp

ExampleApp_XCODEFLAGS = SWIFT_OLD_RPATH=/usr/lib/libswift/stable
ExampleApp_XCODE_SCHEME = ExampleApp
ExampleApp_CODESIGN_FLAGS = -SexampleAppEntitlements.xml

include $(THEOS_MAKE_PATH)/xcodeproj.mk