export GO_EASY_ON_ME := 1
export ARCHS = armv7 arm64
TARGET_IPHONEOS_DEPLOYMENT_VERSION=7.0
THEOS_BUILD_DIR = Packages
PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)

include theos/makefiles/common.mk

TWEAK_NAME = ColoredVK
ColoredVK_FILES = Tweak.x
ColoredVK_FRAMEWORKS = UIKit Foundation
ColoredVK_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
