INSTALL_TARGET_PROCESSES = SpringBoard
ARCHS = arm64 arm64e 
TARGET = iphone:clang:13.3:11.0
#Un-comment this line to make it a non-debug build
#PACKAGE_VERSION=$(THEOS_PACKAGE_BASE_VERSION)

include $(THEOS)/makefiles/common.mk

SUBPROJECTS += exampletweak ExampleApp

include $(THEOS_MAKE_PATH)/aggregate.mk
