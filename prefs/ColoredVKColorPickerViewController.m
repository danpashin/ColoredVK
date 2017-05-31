//
//  ColoredVKColorPickerViewController.m
//  ColoredVK
//
//  Copyright (c) 2015 Daniil Pashin. All rights reserved.
//  

#import "ColoredVKColorPickerViewController.h"
#import <Foundation/Foundation.h>

static NSString *const tweakPreferencePath = @"/User/Library/Preferences/com.daniilpashin.coloredvk.plist";


@implementation ColoredVKColorPickerViewController
- (void)colorDidChange:(UIColor *)color identifier:(NSString *)identifier
{
    self.color = color;
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

- (id)initWithIdentifier:(NSString *)identifier
{
    self = [super init];
    if (self) {
        _identifier = identifier;
        
        NKOColorPickerView *colorPickerView = [[NKOColorPickerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 340.0f) color:[self savedCustomColor:identifier] identifier:identifier delegate:self];
        colorPickerView.backgroundColor = [UIColor blackColor];
        self.view = colorPickerView;
        self.navigationItem.title = @"Select Color";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:3 target:self action:@selector(dismissPicker)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Hex" style:UIBarButtonItemStyleDone target:self action:@selector(hexWindow)];
    }
    return self;
}

- (void)dismissPicker
{
    CGFloat hue = 0, sat = 0, bri = 0;
    if ([self.color getHue:&hue saturation:&sat brightness:&bri alpha:nil]) {
        NSString *hueKey = [@"Hue" stringByAppendingString:self.identifier];
        NSString *satKey = [@"Sat" stringByAppendingString:self.identifier];
        NSString *briKey = [@"Bri" stringByAppendingString:self.identifier];

        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:tweakPreferencePath];
        [dict setValue:@(hue) forKey:hueKey];
        [dict setValue:@(sat) forKey:satKey];
        [dict setValue:@(bri) forKey:briKey];
        
        [dict writeToFile:tweakPreferencePath atomically:YES];
        
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.prefs.changed"), NULL, NULL, YES);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.daniilpashin.coloredvk.prefs.colorUpdate" object:nil userInfo:@{@"CVKColorCellIdentifier":self.identifier}];
    }
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void) hexWindow
{
    UIAlertController *alertCont = [UIAlertController alertControllerWithTitle:@"Hex" message:@"Enter a hexadecimal color code" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertCont addTextFieldWithConfigurationHandler:^(UITextField *textField) { textField.placeholder = @"#000000"; }];
    [alertCont addAction:[UIAlertAction actionWithTitle:@"Set" style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
                                                    self.color = [self colorWithHexString:alertCont.textFields[0].text alpha:1];
                                                    [self dismissPicker];
                                                }]];
    [alertCont addAction:[UIAlertAction actionWithTitle:@"Copy Hex" style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
                                                    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:tweakPreferencePath];
                                                    CGFloat myHue = [[dict objectForKey:[@"Hue" stringByAppendingString:self.identifier]] floatValue];
                                                    CGFloat mySat = [[dict objectForKey:[@"Sat" stringByAppendingString:self.identifier]] floatValue];
                                                    CGFloat myBri = [[dict objectForKey:[@"Bri" stringByAppendingString:self.identifier]] floatValue];

                                                    UIColor *color = [UIColor colorWithHue:myHue saturation:mySat brightness:myBri alpha:1];
                                                    NSString *hexString = [@"#" stringByAppendingString:[self hexStringForColor:color]];

                                                    [UIPasteboard generalPasteboard].string = hexString;
                                                }]];
    [alertCont addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) { }]];
    
    [self presentViewController:alertCont animated:YES completion:nil];
}



- (UIColor *)colorWithHexString:(NSString *)str_HEX  alpha:(CGFloat)alpha_range
{
    int red = 0;
    int green = 0;
    int blue = 0;
    sscanf([str_HEX UTF8String], "#%02X%02X%02X", &red, &green, &blue);
    return  [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha_range];
}

- (NSString *)hexStringForColor:(UIColor *)color
{
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    NSString *hexString=[NSString stringWithFormat:@"%02X%02X%02X", (int)(r * 255), (int)(g * 255), (int)(b * 255)];
    return hexString;
}
@end
