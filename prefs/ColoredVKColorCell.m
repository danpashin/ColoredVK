//
//  ColoredVKColorCell.m
//  ColoredVK
//
//  Copyright (c) 2015 Daniil Pashin. All rights reserved.
//  

#import "ColoredVKColorCell.h"
#import <Foundation/Foundation.h>
#import "headers/PSSpecifier.h"

#define tweakPreferencePath @"/User/Library/Preferences/com.daniilpashin.coloredvk.plist"


@implementation ColoredVKColorCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];
    if (self) {
        [self updateColorCellForIdentifier:[specifier identifier]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateColorCell:) name:@"com.daniilpashin.coloredvk.prefs.colorUpdate" object:nil];
    }
    return self;
}

- (void)updateColorCell:(NSNotification *)notification
{
    NSString *identifier = notification.userInfo[@"CVKColorCellIdentifier"];
    if (identifier == [self.specifier identifier]) [self updateColorCellForIdentifier:identifier];
}

- (void)updateColorCellForIdentifier:(NSString *)identifier
{
    UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 28.0f, 28.0f)];
    colorView.layer.cornerRadius = 14.0f;
    colorView.backgroundColor = [self savedCustomColor:identifier];
    self.accessoryView = colorView;
}

- (UIColor *)savedCustomColor:(NSString *)identifier
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
