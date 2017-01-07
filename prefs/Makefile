GO_EASY_ON_ME := 1
ARCHS = armv7 arm64
TARGET_IPHONEOS_DEPLOYMENT_VERSION=7.0

include theos/makefiles/common.mk

BUNDLE_NAME = ColoredVK
ColoredVK_FILES = ColoredVKListController.m ColoredVKListControllerConfig.m ColorPickerViewController.m ColoredVKHeaderCell.m CRMediaPickerController/CRMediaPickerController/CRMediaPickerController.m NKOColorPickerView.m MBProgressHUD/MBProgressHUD.m 
ColoredVK_INSTALL_PATH = /Library/PreferenceBundles
ColoredVK_FRAMEWORKS = Social UIKit MessageUI CoreGraphics Foundation AssetsLibrary MobileCoreServices Accelerate
ColoredVK_PRIVATE_FRAMEWORKS = Preferences
ColoredVK_LDFLAGS = -lMobileGestalt
ColoredVK_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp ColoredVK.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ColoredVK.plist$(ECHO_END)
