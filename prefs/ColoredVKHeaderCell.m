//
//  ColoredVKHeaderCell.m
//  ColoredVK
//
//  Copyright (c) 2015 Daniil Pashin. All rights reserved.
//  

#import "ColoredVKHeaderCell.h"

@implementation ColoredVKHeaderCell

- (instancetype)initWithSpecifier:(PSSpecifier *)specifier
{
    return [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"headerCell" specifier:specifier];
}

- (instancetype)initWithStyle:(int)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        UILabel *heading = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 100)];
        heading.font = [UIFont fontWithName:@"Georgia" size:35];
        heading.text = @"ColoredVK";
        heading.backgroundColor = [UIColor clearColor];
        heading.textColor = [UIColor colorWithRed:70.0/255.0f green:120.0/255.0f blue:177.0/255.0f alpha:1];
        heading.textAlignment = NSTextAlignmentCenter;
        heading.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:heading];
        
        UILabel *subtitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, self.contentView.frame.size.width, 35)];
        subtitle.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        subtitle.text = @"Colorize your VK App!";
        subtitle.backgroundColor = [UIColor clearColor];
        subtitle.textColor = [UIColor grayColor];
        subtitle.textAlignment = NSTextAlignmentCenter;
        subtitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:subtitle];
    }

    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width
{
    return 120.0;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width inTableView:(id)arg2
{
    return 120.0;
}


@end
