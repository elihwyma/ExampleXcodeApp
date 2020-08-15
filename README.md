## A simple guide on how to build your Xcode apps into .deb files

**This guide will work regardless of ObjC or Swift, and supports using workspaces for Cocoapods etc**

This guide will consist of two parts, first just building a deb with the app, and then I will cover how to bundle tweaks with it.

This guide is assuming that the Xcode app is called `ExampleApp` and that the tweak is `exampletweak`

---
### The Xcode Project: 
1. In your project root, containing the folder `ExampleApp/` and `ExampleApp.xcodeproj` or `ExampleApp.xcworkspace`, create a blank text file and name it `Makefile`.

The base contents of the Makefile should contain the following:

```
TARGET = iphone:13.3:10.0
ARCHS = arm64
INSTALL_TARGET_PROCESSES = ExampleApp

include $(THEOS)/makefiles/common.mk

XCODEPROJ_NAME = ExampleApp
ExampleApp_XCODEFLAGS = SWIFT_OLD_RPATH=/usr/lib/libswift/stable
ExampleApp_XCODE_SCHEME = ExampleApp
ExampleApp_CODESIGN_FLAGS = -SexampleAppEntitlements.xml

include $(THEOS_MAKE_PATH)/xcodeproj.mk
```
2. In your project root again, create another text file, and call it something along the lines of `exampleAppEntitlements.xml`, this is also what you put in the `CODESIGN_FLAGS` of the `Makefile`. The base contents of your entitlements file should be: 

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>platform-application</key>
        <true/>
        <key>com.apple.private.security.no-container</key>
        <true/>
        <key>com.apple.private.skip-library-validation</key>
        <true/>
    </dict>
</plist>
```

**Now at this point, if you would like to not bundle any tweaks, you should follow this part, if you would, skip this step**

3. In your project root, create a file called control, and it's base contents should be: 

```
Package: com.charliewhile.exampleapp
Name: ExampleApp
Version: 0.0.1
Architecture: iphoneos-arm
Description: An awesome MobileSubstrate tweak!
Maintainer: Charlie While
Author: Charlie While
Section: Tweaks
Depends: mobilesubstrate (>= 0.9.5000), firmware(>=12.2) | org.swift.libswift (>=5.0)
```
It should be noted here that if your app is Swift based, and you plan to support iOS 12 or below, you will need to add `firmware(>=12.2) | org.swift.libswift (>=5.0)` to your control file.

Congratulations, just running `make package` will create your deb file, which you can distribute on package repos. 

### Bundling tweaks

**There are multiple approaches to bundling tweaks with your app, however this is my preferred method. This guide assumes you already have a tweak setup and working, made with Theos**

1. Create a master folder, which will contain your app, and the tweak/s you are bundling with your app. The layout should be as following: 

```
MyTweakFolder/ 
	ExampleApp/
		ExampleApp/
		ExampleApp.xcodeproj
		Makefile
		exampleAppEntitlements.xml
	exampletweak/
		Tweak.x
		Makefile
		exampletweak.plist
```

2. Inside the master folder, `MyTweakFolder`, create a `Makefile` and a `control` file. The contents of the Makefile will be: 

```
INSTALL_TARGET_PROCESSES = SpringBoard
ARCHS = arm64 arm64e 
TARGET = iphone:clang:13.3:11.0
#Un-comment this line to make it a non-debug build
#PACKAGE_VERSION=$(THEOS_PACKAGE_BASE_VERSION)

include $(THEOS)/makefiles/common.mk

SUBPROJECTS += exampletweak ExampleApp

include $(THEOS_MAKE_PATH)/aggregate.mk
```
The `SUBPROJECTS` part of your Makefile are a list of the 2 folders you have

The contents of the control file will be the same as the one listed earlier, including the libSwift dependency if applicable. 

---

### Congratulations, if you followed everything correctly, you now can just run `make package` inside of your master folder

