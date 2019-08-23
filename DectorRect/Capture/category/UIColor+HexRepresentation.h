//
//  UIColor+HexRepresentation.h
//  MMCamScanner
//
//  Created by mac on 12/06/15.
//  Copyright (c) 2015 ailink. All rights reserved.
//

#import <UIKit/UIKit.h>


#undef  RGBCOLOR
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

#undef  RGBACOLOR
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]


#define kWhiteColor RGBCOLOR(255.0, 255.0, 255.0)
#define kBlackColor RGBCOLOR(0, 0, 0)
#define kBlueColor  RGBCOLOR(0, 0, 255)
#define kRedColor   RGBCOLOR(255, 0, 0)
#define kGreenColor RGBCOLOR(0, 255, 0)
#define kGrayColor  RGBCOLOR(128, 128, 128)
#define kCyanColor  RGBCOLOR(0, 255, 255)
#define kYellowColor RGBCOLOR(255, 255, 0)
#define kPinkColor  RGBCOLOR(255, 0, 255)



@interface UIColor (HexRepresentation)
+(UIColor*)colorWithHexString:(NSString*)hex;
@end
