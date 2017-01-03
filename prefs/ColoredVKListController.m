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
#import <Social/SLComposeViewController.h>
#import <Social/SLServiceTypes.h>
#import "headers/PSSpecifier.h"

#define language [NSBundle mainBundle].preferredLocalizations.firstObject
static NSString *const tweakPreferencePath = @"/User/Library/Preferences/com.daniilpashin.coloredvk.plist";


@implementation ColoredVKListController
- (id)specifiers
{
    if(!_specifiers) {
        NSMutableArray *specifiersArray = [[self loadSpecifiersFromPlistName:@"ColoredVK" target:self] copy];
        if (specifiersArray.count > 1) [specifiersArray insertObject:[self footer] atIndex:specifiersArray.count-1];
        else [specifiersArray addObject:[self footer]];
        
        _specifiers = specifiersArray;
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

- (void) viewDidLoad
{
    [super viewDidLoad];
    [UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    [UISwitch appearanceWhenContainedIn:self.class, nil].tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    self.title = @"";
}

- (void) tweet:(id)sender
{
    NSString *text = @"";
    if ([language isEqualToString:@"ru"]) text = @"Я использую #ColoredVK от @daniil_pashin для раскрашивания моего VKApp!";
    else text = @"I'm using #ColoredVK by @daniil_pashin to colorize my VKApp!";
    
    SLComposeViewController *composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [composeController setInitialText:text];
    [self presentViewController:composeController animated:YES completion:nil];

}

- (void) sendiMessage:(id)sender
{
    NSString *bodyText = @"";
    if ([language isEqualToString:@"ru"])       bodyText = @"Здравствуйте, Даниил.\n";
    else                                        bodyText = @"Hello, Daniil.\n";

    MFMessageComposeViewController *mc = [MFMessageComposeViewController new];
    mc.messageComposeDelegate = self;
    mc.recipients = @[@"daniilpashin@icloud.com"];
    mc.body = bodyText;
    [self presentViewController:mc animated:YES completion:NULL];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void) sendMail:(id)sender
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:@"/var/tmp/dpkgl.log"]) system("/usr/bin/dpkg -l >/var/tmp/dpkgl.log");
    
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:tweakPreferencePath];

    NSString *device = (NSString *)MGCopyAnswer(kMGProductType);
    NSString *os_version = (NSString *)MGCopyAnswer(kMGProductVersion);
    NSString *os_build = (NSString *)MGCopyAnswer(kMGBuildVersion);
    NSString *vk_version = [NSString stringWithFormat:@"%@", [prefs objectForKey:@"VKVersion"]];

    MFMailComposeViewController *email = [MFMailComposeViewController new];
    email.mailComposeDelegate = self;
    email.subject = [NSString stringWithFormat:@"ColoredVK v: %@",[self getVersion]];

    
    NSString *pattern = [NSString stringWithFormat:
                         @"\n\n\n\n-----------------\n\
                         Debug Information (please don't change any values here):\n\
                         iOS Version: %@ (%@)\n\
                         Device: %@\n\
                         VKApp version: %@\n\
                         -----------------", 
                         os_version, os_build, device, vk_version];
    
    NSString *emailText = @"";
    if ([language isEqualToString:@"ru"]) emailText = [@"Здравствуйте, Даниил. " stringByAppendingString:pattern];
    else emailText = [@"Hello, Daniil. " stringByAppendingString:pattern];

    [email setMessageBody:emailText isHTML:NO];
    [email setToRecipients:@[@"daniilpashin@icloud.com"]];
    [email addAttachmentData:[NSData dataWithContentsOfFile: @"/var/tmp/cydia.log"] mimeType:@"text/plain" fileName:@"cydia.log"];
    [email addAttachmentData:[NSData dataWithContentsOfFile:@"/var/tmp/dpkgl.log"] mimeType:@"text/plain" fileName:@"dpkgl.log"];
    [email addAttachmentData:[NSData dataWithContentsOfFile:@"/private/var/mobile/Library/Preferences/com.daniilpashin.coloredvk.plist"] mimeType:@"text/plain" fileName:@"prefs.plist"];

    [self.rootController presentViewController:email animated:YES completion:nil];

}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self.rootController dismissViewControllerAnimated:YES completion:nil];
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
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    [task setArguments:[NSArray arrayWithObjects: @"-c", @"dpkg -s com.daniilpashin.coloredvk | grep 'Version'", nil]];
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    [task launch];

    NSData *data = [[[task standardOutput] fileHandleForReading] readDataToEndOfFile];
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

- (void) openCJBGroup:(id)sender
{
    NSURL *vkurl = [NSURL URLWithString:@"vk://vk.com/corejailbreak"];
    if ([[UIApplication sharedApplication] canOpenURL:vkurl]) [[UIApplication sharedApplication] openURL:vkurl];
}
@end
