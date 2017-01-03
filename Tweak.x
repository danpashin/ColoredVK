
#import <UIKit/UIKit.h>

BOOL enabled = YES;
BOOL enabledBarColor = YES;
BOOL enabledBarImage = NO;
BOOL enabledBarButtonsColor = NO;
BOOL enabledBackgroundColor = NO;
BOOL enabledWriteLineColor = NO;
BOOL enabledSBColor = NO;
BOOL showBar = NO;
BOOL enabledBlackKB = NO;
BOOL enabledToolBarColor = NO;


CGFloat HueBar;
CGFloat SatBar;
CGFloat BriBar;

CGFloat HueBarButtons;
CGFloat SatBarButtons;
CGFloat BriBarButtons;

CGFloat HueBackground;
CGFloat SatBackground;
CGFloat BriBackground;

CGFloat HueWriteLine;
CGFloat SatWriteLine;
CGFloat BriWriteLine;

CGFloat HueSBColorFore;
CGFloat SatSBColorFore;
CGFloat BriSBColorFore;

CGFloat HueSBColorBack;
CGFloat SatSBColorBack;
CGFloat BriSBColorBack;

CGFloat HueToolBar;
CGFloat SatToolBar;
CGFloat BriToolBar;

CGFloat HueToolBarBG;
CGFloat SatToolBarBG;
CGFloat BriToolBarBG;



%hook NewsFeedController
- (BOOL) VKMTableFullscreenEnabled
{
    if (enabled && showBar) return NO;
    return %orig;
}
- (BOOL) VKMScrollViewFullscreenEnabled
{
    if (enabled && showBar) return NO;
    return %orig;
}
%end

%hook PhotoFeedController
- (BOOL) VKMTableFullscreenEnabled
{
    if (enabled && showBar) return NO;
    return %orig;
}
- (BOOL) VKMScrollViewFullscreenEnabled
{
    if (enabled && showBar) return NO;
    return %orig;
}
%end



%hook UINavigationBar
- (void) setBarTintColor:(UIColor *)barTintColor
{
    if (enabled && enabledBarColor) {
        if (enabledBarImage) barTintColor = [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:@"/private/var/mobile/Library/Preferences/navBarImage.png"]];
        else barTintColor = [UIColor colorWithHue:HueBar saturation:SatBar brightness:BriBar alpha:1];
    }
    %orig;
}

- (void) setTintColor:(UIColor *)tintColor
{
    if (enabled && enabledBarButtonsColor) tintColor = [UIColor colorWithHue:HueBarButtons saturation:SatBarButtons brightness:BriBarButtons alpha:1];
    %orig;
}
%end



%hook UITextInputTraits
- (void) setInsertionPointColor:(UIColor *)pointColor
{
    if (enabled && enabledWriteLineColor) pointColor = [UIColor colorWithHue:HueWriteLine saturation:SatWriteLine brightness:BriWriteLine alpha:1];
    %orig;
}

- (long long) keyboardAppearance
{ 
    if (enabled && enabledBlackKB) return 1;
    return %orig; 
}
%end


%hook UIStatusBarNewUIStyleAttributes
- (void) initWithRequest:(id)arg1 backgroundColor:(UIColor *)backgroundColor foregroundColor:(UIColor *)foregroundColor
{
    if (enabled && enabledSBColor) foregroundColor = [UIColor colorWithHue:HueSBColorFore saturation:SatSBColorFore brightness:BriSBColorFore alpha:1];
    %orig;
}
%end



%hook UIToolbar
- (void) setTintColor:(UIColor *)tintColor
{
    if (enabled && enabledToolBarColor) tintColor = [UIColor colorWithHue:HueToolBar saturation:SatToolBar brightness:BriToolBar alpha:1];
    %orig;
}

- (void) setBarTintColor:(UIColor *)barTintColor
{
    if (enabled && enabledToolBarColor) barTintColor = [UIColor colorWithHue:HueToolBarBG saturation:SatToolBarBG brightness:BriToolBarBG alpha:1];
    %orig;
}
%end



static void reloadPrefs()
{
    NSString *dictPath = @"/User/Library/Preferences/com.daniilpashin.coloredvk.plist";
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:dictPath];
    
    [prefs setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forKey:@"VKVersion"];
    [prefs writeToFile:dictPath atomically:YES];

        
    enabled = ([prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"]  boolValue] : enabled);
    enabledBarColor = ([prefs objectForKey:@"enabledBarColor"] ? [[prefs objectForKey:@"enabledBarColor"]  boolValue] : enabledBarColor);
    enabledBarImage = ([prefs objectForKey:@"enabledImage"] ? [[prefs objectForKey:@"enabledImage"]  boolValue] : enabledBarImage);
    enabledBarButtonsColor = ([prefs objectForKey:@"enabledBarButtonsColor"] ? [[prefs objectForKey:@"enabledBarButtonsColor"]  boolValue] : enabledBarButtonsColor);
    enabledBackgroundColor = ([prefs objectForKey:@"enabledBackgroundColor"] ? [[prefs objectForKey:@"enabledBackgroundColor"]  boolValue] : enabledBackgroundColor);
    enabledWriteLineColor = ([prefs objectForKey:@"enabledWriteLineColor"] ? [[prefs objectForKey:@"enabledWriteLineColor"]  boolValue] : enabledWriteLineColor);
    enabledSBColor = ([prefs objectForKey:@"enabledSBColor"] ? [[prefs objectForKey:@"enabledSBColor"]  boolValue] : enabledSBColor);
    showBar = ([prefs objectForKey:@"showBar"] ? [[prefs objectForKey:@"showBar"]  boolValue] : showBar);
    
    enabledBlackKB = ([prefs objectForKey:@"enabledBlackKB"] ? [[prefs objectForKey:@"enabledBlackKB"]  boolValue] : enabledBlackKB);
    enabledToolBarColor = ([prefs objectForKey:@"enabledToolBarColor"] ? [[prefs objectForKey:@"enabledToolBarColor"]  boolValue] : enabledToolBarColor);
    
    HueBar = [[prefs valueForKey:@"HueBar"]  floatValue];
    SatBar = [[prefs valueForKey:@"SatBar"]  floatValue];
    BriBar = [[prefs valueForKey:@"BriBar"]  floatValue];
    
    HueBarButtons = [[prefs valueForKey:@"HueBarButtons"]  floatValue];
    SatBarButtons = [[prefs valueForKey:@"SatBarButtons"]  floatValue];
    BriBarButtons = [[prefs valueForKey:@"BriBarButtons"]  floatValue];
    
    HueBackground = [[prefs valueForKey:@"HueBackground"]  floatValue];
    SatBackground = [[prefs valueForKey:@"SatBackground"]  floatValue];
    BriBackground = [[prefs valueForKey:@"BriBackground"]  floatValue];
    
    HueWriteLine = [[prefs valueForKey:@"HueWriteLine"]  floatValue];
    SatWriteLine = [[prefs valueForKey:@"SatWriteLine"]  floatValue];
    BriWriteLine = [[prefs valueForKey:@"BriWriteLine"]  floatValue];
    
    HueSBColorFore = [[prefs valueForKey:@"HueSBColorFore"]  floatValue];
    SatSBColorFore = [[prefs valueForKey:@"SatSBColorFore"]  floatValue];
    BriSBColorFore = [[prefs valueForKey:@"BriSBColorFore"]  floatValue];

    HueSBColorBack = [[prefs valueForKey:@"HueSBColorBack"]  floatValue];
    SatSBColorBack = [[prefs valueForKey:@"SatSBColorBack"]  floatValue];
    BriSBColorBack = [[prefs valueForKey:@"BriSBColorBack"]  floatValue];
    
    HueToolBar = [[prefs valueForKey:@"HueToolBar"]  floatValue];
    SatToolBar = [[prefs valueForKey:@"SatToolBar"]  floatValue];
    BriToolBar = [[prefs valueForKey:@"BriToolBar"]  floatValue];
    
    HueToolBarBG = [[prefs valueForKey:@"HueToolBarBG"]  floatValue];
    SatToolBarBG = [[prefs valueForKey:@"SatToolBarBG"]  floatValue];
    BriToolBarBG = [[prefs valueForKey:@"BriToolBarBG"]  floatValue];
}

static void PostNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) { reloadPrefs(); }

%ctor {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PostNotification, CFSTR("com.daniilpashin.coloredvk.prefs.changed"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    
    reloadPrefs();
    
    [pool drain];
}
