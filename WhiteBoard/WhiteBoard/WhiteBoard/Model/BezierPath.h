//
//  BezierPath.h
//  NPS_iOS
//
//  Created by lxf on 2017/7/3.
//  Copyright © 2017年 LXF. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BezierPath : UIBezierPath
//画笔的颜色
@property (nonatomic,copy) UIColor *lineColor;

// 路径上点的集合数组
@property(nonatomic,strong) NSMutableArray * pointsArray ;

// 使用 CAShapeLayer , 可以不用调用drawRect , 降低CPU消耗
@property (nonatomic, strong)CAShapeLayer * layer;

@end
