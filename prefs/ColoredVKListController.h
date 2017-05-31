//
//  ColoredVKListController.m
//  ColoredVK
//
//  Copyright (c) 2015 Daniil Pashin. All rights reserved.
//  

#import "headers/PSListController.h"

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@interface ColoredVKListController: PSListController <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) MFMailComposeViewController *email;

@end
