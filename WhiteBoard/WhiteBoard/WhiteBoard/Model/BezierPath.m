//
//  BezierPath.m
//  NPS_iOS
//
//  Created by lxf on 2017/7/3.
//  Copyright © 2017年 LXF. All rights reserved.
//

#import "BezierPath.h"

@implementation BezierPath




- (NSMutableArray *)pointsArray {
    
    if (_pointsArray == nil) {
        _pointsArray = [NSMutableArray array];
        CGPathApply(self.CGPath, (__bridge void *)_pointsArray, getPointsFromBezier);
    }
    return _pointsArray ;
    
}




void getPointsFromBezier(void *info,const CGPathElement *element){
    NSMutableArray *bezierPoints = (__bridge NSMutableArray *)info;
    CGPathElementType type = element->type;
    CGPoint *points = element->points;
    
    if (type != kCGPathElementCloseSubpath) {
        [bezierPoints addObject:[NSValue valueWithCGPoint:points[0]]];
        if ((type != kCGPathElementAddLineToPoint) && (type != kCGPathElementMoveToPoint)) {
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[1]]];
        }
    }
    
    if (type == kCGPathElementAddCurveToPoint) {
        [bezierPoints addObject:[NSValue valueWithCGPoint:points[2] ]];
    }
    
}



@end
