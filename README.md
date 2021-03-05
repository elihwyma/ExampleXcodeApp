# Compiling Xcode projects as jailbreak apps 

##  Setup
This guide will only work for macOS due to requiring the Xcode build system to be installed. You will need Theos installed, and you read the install guide for that [here](https://github.com/theos/theos/wiki/Installation-macOS). This will work with Cocoapods and SPM without any additional setup.

This name of the project we will be using in this guide is ExampleApp, adjust accordingly. 

## Makefile
We will first start by writing our Makefile. In the same directory as your .xcodeproj or .xcworkspace create a blank file called `Makefile`. Open it in your preferrred text editor and paste in the following. I have explained what each line does, adjust accordingly. 
```makefile
# The SDK and iOS version to target. This is specifying the iOS 14.4 SDK and minimum build target as iOS 13.0
TARGET = iphone:14.4:13.0
# The archiectures to compile for, arm64 is fine for most apps
ARCHS = arm64

# The name of the process to kill upon install, the name of your app
INSTALL_TARGET_PROCESSES = ExampleApp

include $(THEOS)/makefiles/common.mk
# The name of your Xcode project/workspace
XCODEPROJ_NAME = ExampleApp
# The scheme of your app to compile 
ExampleApp_XCODE_SCHEME = ExampleApp
# The ldid flag to sign your app with, we will make this next
ExampleApp_CODESIGN_FLAGS = -SexampleAppEntitlements.xml

include $(THEOS_MAKE_PATH)/xcodeproj.mk
```
If your app plans to target below 12.2 and uses Swift you will need to add the following line:
` ExampleApp_XCODEFLAGS = SWIFT_OLD_RPATH=/usr/lib/libswift/stable`. This is required to tell your app where to look for the standard Swift library. You will also need to add the dependency to your control file `firmware(>=12.2) | org.swift.libswift`

## Entitlements
The entitlements needed for your app will vary depending on your needs, I will list some essential and some optional you may want to use. Create your entitlement file with the same name you used in `Makefile`, in my case it's `exampleAppEntitlements.xml` (The -S is ignored). Here is a base template to paste inside with some essential entitlements
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>platform-application</key>
        <true/>
        <key>com.apple.private.skip-library-validation</key>
        <true/>
	<key>com.apple.security.iokit-user-client-class</key>
        <array>
                <string>AGXCommandQueue</string>
                <string>AGXDevice</string>
                <string>AGXDeviceUserClient</string>
                <string>AGXSharedUserClient</string>
                <string>AppleCredentialManagerUserClient</string>
                <string>AppleJPEGDriverUserClient</string>
                <string>ApplePPMUserClient</string>
                <string>AppleSPUHIDDeviceUserClient</string>
                <string>AppleSPUHIDDriverUserClient</string>
                <string>IOAccelContext</string>
                <string>IOAccelContext2</string>
                <string>IOAccelDevice</string>
                <string>IOAccelDevice2</string>
                <string>IOAccelSharedUserClient</string>
                <string>IOAccelSharedUserClient2</string>
                <string>IOAccelSubmitter2</string>
                <string>IOHIDEventServiceFastPathUserClient</string>
                <string>IOHIDLibUserClient</string>
                <string>IOMobileFramebufferUserClient</string>
                <string>IOReportUserClient</string>
                <string>IOSurfaceAcceleratorClient</string>
                <string>IOSurfaceRootUserClient</string>
                <string>RootDomainUserClient</string>
        </array>
    </dict>
</plist>
```
`platform-application` is needed for running inside `/Applications`, the system will think it's a default app.

`skip-library-validation` will skip any verification on your app or extensions. 

`iokit-user-client-class`is a new array required by system apps in iOS 14 to avoid crashing in certain situations. 

### Optional Entitlements
Allows your app to perform operations such as NSTask and posix_spawn.
```xml
<key>get-task-allow</key>
<true/>
```
Skip generation of  a container for your app. Use this if you prefer to save data to somewhere like `/var/mobile/Libary/`
```xml
 <key>com.apple.private.security.no-container</key>
 <true/>
```
Read/Write privelleges to a certain file or folder. Useful for reading a tweak preferences file, since `NSUserDefaults` won't work without lots of modification.
```xml
<key>com.apple.security.exception.files.home-relative-path.read-write</key>
<array>
	<string>/Library/Preferences/com.amywhile.exampletweak.plist</string>
</array>
```
You will also need to add any entitlements that Xcode automatically gave your app for certain functionality, such as App Groups. 

## Control
Control stuff goes here
