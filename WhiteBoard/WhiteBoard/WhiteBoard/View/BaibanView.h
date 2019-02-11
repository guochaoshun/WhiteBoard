//
//  BaibanView.h
//  TestOC
//
//  Created by 李亚军 on 2017/2/8.
//  Copyright © 2017年 zyyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BezierPath;

@interface BaibanView : UIView

// 当前正在使用的BezierPath
@property (nonatomic,strong) BezierPath  *bezierPath;
// 存的全是 BezierPath  *bezierPath
@property (nonatomic,strong) NSMutableArray  *beziPathArrM;

//画笔的颜色
@property (nonatomic,copy) UIColor *lineColor;
// 画笔的粗细
@property (nonatomic,assign) CGFloat brushLineWidth;
// 是否是橡皮擦,说下橡皮擦的原理,就是把lineColor的颜色改成和背景色一致,然后绘制曲线.后来需求把这个砍掉了,因为不如清除上一步好用
@property (nonatomic,assign) BOOL isErase;

/**
 清空所有path
 */
- (void)clearAllPath;
/**
 清除上一步path
 */
- (void)clearLastPath;




@end
