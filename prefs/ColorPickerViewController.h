//
//  ColorPickerViewController.h
//  ColoredVK
//
//  Copyright (c) 2015 Daniil Pashin. All rights reserved.
//  

#import <UIKit/UIKit.h>
#import "NKOColorPickerView.h"

@interface ColorPickerViewController : UIViewController <NKOColorPickerViewDelegate>
@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic, readonly) NSString *identifier;
- (instancetype)initWithIdentifier:(NSString *)identifier;
@end
