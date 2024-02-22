ARCHS := arm64
TARGET := iphone:clang:latest:15.0

INSTALL_TARGET_PROCESSES += LWEApp

include $(THEOS)/makefiles/common.mk

XCODEPROJ_NAME += LiveWallpaperExporter

include $(THEOS_MAKE_PATH)/xcodeproj.mk

before-package::
	$(ECHO_NOTHING)ldid -SEntitlements.plist $(THEOS_STAGING_DIR)/Applications/LWEApp.app$(ECHO_END)

after-install::
	install.exec "uicache -p /Applications/LWEApp.app"