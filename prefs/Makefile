include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = LiquidGlassPrefs

LiquidGlassPrefs_FILES = LGRootListController.m
LiquidGlassPrefs_FRAMEWORKS = UIKit
LiquidGlassPrefs_PRIVATE_FRAMEWORKS = Preferences
LiquidGlassPrefs_RESOURCE_DIRS = Resources
LiquidGlassPrefs_INSTALL_PATH = /Library/PreferenceBundles
LiquidGlassPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp Resources/entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/LiquidGlassPrefs.plist$(ECHO_END)
