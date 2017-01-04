//
//  Tweak.x
//  ColoredVK
//
//  Copyright (c) 2015 Daniil Pashin. All rights reserved.
//  

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

static NSString *const tweakPreferencePath = @"/private/var/mobile/Library/Preferences/com.daniilpashin.coloredvk.plist";


BOOL enabled = YES;
BOOL enabledBarColor = YES;
BOOL enabledBarImage = NO;
BOOL enabledBarButtonsColor = NO;
BOOL showBar = NO;
BOOL enabledToolBarColor = NO;
BOOL enabledWriteLineColor = NO;
BOOL enabledSBColor = NO;
BOOL enabledBlackKB = NO;

UIColor *navbarColor;
UIColor *navbarTintColor;
UIColor *writeLineColor;
UIColor *statusbarBackColor;
UIColor *toolbarColor;
UIColor *toolbarTintColor;


static UIColor *savedColorForIdentifier(NSString *identifier)
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:tweakPreferencePath];
    NSString *hueKey = [@"Hue" stringByAppendingString:identifier];
    NSString *satKey = [@"Sat" stringByAppendingString:identifier];
    NSString *briKey = [@"Bri" stringByAppendingString:identifier];
    if (dict[hueKey] == nil || dict[satKey] == nil|| dict[briKey] == nil) return [UIColor blackColor];
    CGFloat hue, sat, bri;
    hue = [dict[hueKey] floatValue];
    sat = [dict[satKey] floatValue];
    bri = [dict[briKey] floatValue];
    UIColor *color = [UIColor colorWithHue:hue saturation:sat brightness:bri alpha:1];
    return color;
}



%hook NewsFeedController
- (BOOL)VKMTableFullscreenEnabled
{
    if (enabled && showBar) return NO;
    return %orig;
}
- (BOOL)VKMScrollViewFullscreenEnabled
{
    if (enabled && showBar) return NO;
    return %orig;
}
%end

%hook PhotoFeedController
- (BOOL)VKMTableFullscreenEnabled
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
- (void)setBarTintColor:(UIColor *)barTintColor
{
    if (enabled && enabledBarColor) {
        if (enabledBarImage) barTintColor = [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:@"/private/var/mobile/Library/Preferences/navBarImage.png"]];
        else barTintColor = navbarColor;
    }
    %orig;
}

- (void)setTintColor:(UIColor *)tintColor
{
    if (enabled && enabledBarButtonsColor) tintColor = navbarTintColor;
    %orig;
}
%end



%hook UITextInputTraits
- (void)setInsertionPointColor:(UIColor *)pointColor
{
    if (enabled && enabledWriteLineColor) pointColor = writeLineColor;
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
    if (enabled && enabledSBColor) foregroundColor = statusbarBackColor;
    %orig;
}
%end



%hook UIToolbar
- (void)setTintColor:(UIColor *)tintColor
{
    if (enabled && enabledToolBarColor) tintColor = toolbarTintColor;
    %orig;
}

- (void)setBarTintColor:(UIColor *)barTintColor
{
    if (enabled && enabledToolBarColor) barTintColor = toolbarColor;
    %orig;
}
%end



static void reloadPrefs()
{
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:tweakPreferencePath];
        
    enabled = [prefs objectForKey:@"enabled"]?[[prefs objectForKey:@"enabled"] boolValue]:enabled;
    enabledBarColor = [prefs objectForKey:@"enabledBarColor"] ? [[prefs objectForKey:@"enabledBarColor"] boolValue]:enabledBarColor;
    enabledBarImage = [prefs objectForKey:@"enabledImage"] ? [[prefs objectForKey:@"enabledImage"] boolValue] : enabledBarImage;
    enabledBarButtonsColor = [prefs objectForKey:@"enabledBarButtonsColor"]?[[prefs objectForKey:@"enabledBarButtonsColor"] boolValue]:enabledBarButtonsColor;
    showBar = [prefs objectForKey:@"showBar"]?[[prefs objectForKey:@"showBar"] boolValue]:showBar;
    enabledToolBarColor = ([prefs objectForKey:@"enabledToolBarColor"]?[[prefs objectForKey:@"enabledToolBarColor"] boolValue]:enabledToolBarColor);
    enabledWriteLineColor = [prefs objectForKey:@"enabledWriteLineColor"]?[[prefs objectForKey:@"enabledWriteLineColor"] boolValue]:enabledWriteLineColor;
    enabledSBColor = [prefs objectForKey:@"enabledSBColor"]?[[prefs objectForKey:@"enabledSBColor"] boolValue]:enabledSBColor;
    enabledBlackKB = ([prefs objectForKey:@"enabledBlackKB"]?[[prefs objectForKey:@"enabledBlackKB"] boolValue]:enabledBlackKB);
    
    navbarColor = savedColorForIdentifier(@"Bar");
    navbarTintColor = savedColorForIdentifier(@"BarButtons");
    writeLineColor = savedColorForIdentifier(@"WriteLine");
    statusbarBackColor = savedColorForIdentifier(@"SBColorBack");
    toolbarColor = savedColorForIdentifier(@"ToolBar");
    toolbarTintColor = savedColorForIdentifier(@"ToolBarBG");
}

static void PostNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    reloadPrefs();
}

%ctor {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PostNotification, CFSTR("com.daniilpashin.coloredvk.prefs.changed"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    
    reloadPrefs();
    
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:tweakPreferencePath];
    
    [prefs setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forKey:@"VKVersion"];
    [prefs writeToFile:tweakPreferencePath atomically:YES];
    
    [pool drain];
}
