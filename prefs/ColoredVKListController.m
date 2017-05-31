//
//  ColoredVKListController.m
//  ColoredVK
//
//  Copyright (c) 2015 Daniil Pashin. All rights reserved.
//  

#import "ColoredVKListController.h"
#import <UIKit/UIKit.h>
#import <MobileGestalt/MobileGestalt.h>
#import "headers/NSTask.h"
#import "headers/PSSpecifier.h"
#import <Social/SLComposeViewController.h>
#import <Social/SLServiceTypes.h>

static NSString *const tweakPreferencePath = @"/User/Library/Preferences/com.daniilpashin.coloredvk.plist";


@implementation ColoredVKListController

- (id)specifiers
{
    if(!_specifiers) {
        NSMutableArray *specifiersArray = [[self loadSpecifiersFromPlistName:@"ColoredVK" target:self] mutableCopy];
        if (specifiersArray.count > 1) [specifiersArray insertObject:[self footer] atIndex:specifiersArray.count-1];
        else [specifiersArray addObject:[self footer]];
        
        _specifiers = [specifiersArray copy];
    }
    return _specifiers;
}

- (id)readPreferenceValue:(PSSpecifier*)specifier
{
    NSDictionary *tweakSettings = [NSDictionary dictionaryWithContentsOfFile:tweakPreferencePath];
    if (!tweakSettings[specifier.properties[@"key"]]) return specifier.properties[@"default"];
    return tweakSettings[specifier.properties[@"key"]];
}


- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:tweakPreferencePath]];
    [defaults setObject:value forKey:specifier.properties[@"key"]];
    [defaults writeToFile:tweakPreferencePath atomically:YES];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.prefs.changed"), NULL, NULL, YES);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    [UISwitch appearanceWhenContainedIn:self.class, nil].tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    self.title = @"";
}

- (void)actionTweet
{
    NSString *text = @"I'm using #ColoredVK by @daniil_pashin to colorize my VKApp!";
    
    if ([[NSBundle mainBundle].preferredLocalizations.firstObject containsString:@"ru"])
        text = @"Я использую #ColoredVK от @daniil_pashin для раскрашивания моего VKApp!";
    
    SLComposeViewController *composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [composeController setInitialText:text];
    [self presentViewController:composeController animated:YES completion:nil];

}

- (void)actionSendMail
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:@"/var/tmp/dpkgl.log"]) system("/usr/bin/dpkg -l >/var/tmp/dpkgl.log");
    
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:tweakPreferencePath];

    NSString *device = (__bridge NSString *)MGCopyAnswer(kMGProductType);
    NSString *os_version = (__bridge NSString *)MGCopyAnswer(kMGProductVersion);
    NSString *os_build = (__bridge NSString *)MGCopyAnswer(kMGBuildVersion);
    NSString *vk_version = [NSString stringWithFormat:@"%@", [prefs objectForKey:@"VKVersion"]];

    self.email = [MFMailComposeViewController new];
    self.email.mailComposeDelegate = self;
    self.email.subject = [NSString stringWithFormat:@"ColoredVK v: %@", [self getVersion]];

    
    NSString *pattern = [NSString stringWithFormat:
                         @"\n\n\n\n-----------------\n\
                         Debug Information (please don't change any values here):\n\
                         iOS Version: %@ (%@)\n\
                         Device: %@\n\
                         VKApp version: %@\n\
                         -----------------", 
                         os_version, os_build, device, vk_version];
    
    NSString *emailText = [@"Hello, Daniil. " stringByAppendingString:pattern];
    
    if ([[NSBundle mainBundle].preferredLocalizations.firstObject containsString:@"ru"])
        emailText = [@"Здравствуйте, Даниил. " stringByAppendingString:pattern];

    [self.email setMessageBody:emailText isHTML:NO];
    [self.email setToRecipients:@[@"daniilpashin@icloud.com"]];
    [self.email addAttachmentData:[NSData dataWithContentsOfFile: @"/var/tmp/cydia.log"] mimeType:@"text/plain" fileName:@"cydia.log"];
    [self.email addAttachmentData:[NSData dataWithContentsOfFile:@"/var/tmp/dpkgl.log"] mimeType:@"text/plain" fileName:@"dpkgl.log"];
    [self.email addAttachmentData:[NSData dataWithContentsOfFile:@"/private/var/mobile/Library/Preferences/com.daniilpashin.coloredvk.plist"] mimeType:@"text/plain" fileName:@"prefs.plist"];

    [self.navigationController presentViewController:self.email animated:YES completion:nil];

}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (PSSpecifier *)footer
{
    PSSpecifier *footer = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
    [footer setProperty:[NSString stringWithFormat:@"v: %@\n© Daniil Pashin %@", [self getVersion],[self dynamicYear]] forKey:@"footerText"];
    [footer setProperty:@"1" forKey:@"footerAlignment"];

    return footer;
}

- (NSString *)getVersion
{
    NSTask *task = [NSTask new];
    task.launchPath = @"/bin/sh";
    task.arguments = [NSArray arrayWithObjects: @"-c", @"dpkg -s com.daniilpashin.coloredvk | grep 'Version'", nil];
    task.standardOutput = [NSPipe pipe];
    [task launch];

    NSData *data = [[task.standardOutput fileHandleForReading] readDataToEndOfFile];
    NSString *version = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    version = [version stringByReplacingOccurrencesOfString:@"Version: " withString:@""];
    version = [version stringByReplacingOccurrencesOfString:@"\n" withString:@""];

    return version;
}

- (NSString *)dynamicYear
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy";
    
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    return dateString;
}

@end
