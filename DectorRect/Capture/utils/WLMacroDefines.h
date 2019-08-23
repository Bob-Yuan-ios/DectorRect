//
//  WLMacroDefines.h
//  DectorRect
//
//  Created by mac on 2017/11/8.
//  Copyright © 2017年 mac. All rights reserved.
//

#ifndef WLMacroDefines_h
#define WLMacroDefines_h

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define NAV_WIDTH    SCREEN_WIDTH
#define NAV_HEIGHT   (44)

#define HEX_RGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kBaseColor      HEX_RGB(0x32343d)

#endif /* WLMacroDefines_h */
