//
//  BaibanView.m
//  TestOC
//
//  Created by LI  on 2017/2/8.
//  Copyright © 2017年 zyyj. All rights reserved.


#import "BaibanView.h"
#import "BezierPath.h"

/**
 *  rgb颜色转换
 参数  0x0085fe
 */
#define UIColorFrom16RGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface BaibanView()
{
    CGPoint pts [5] ; // 保存最近的画的5个点 , 用来计算3次贝塞尔曲线
    int  ctr  ; // 一个标志位, 记录已经存在的点
}


@end


@implementation BaibanView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.lineColor = UIColorFrom16RGB(0x000000);
        self.brushLineWidth = 3 ;
        self.clipsToBounds = YES ;
    }
    return self;
}



#pragma mark - 操作栏方法
// 撤销
- (void)clearLastPath {
    if(self.beziPathArrM.count>0){
        
        BezierPath * path = self.beziPathArrM.lastObject;
        [path.layer removeFromSuperlayer];
        [self.beziPathArrM removeLastObject];
    }
    
}
// 清空
- (void)clearAllPath {
  
//    [self.beziPathArrM makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    for (BezierPath * path in self.beziPathArrM) {
        [path.layer removeFromSuperlayer];
    }
    [self.beziPathArrM removeAllObjects];

}


#pragma mark - 画画
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    self.bezierPath = [[BezierPath alloc] init];
    self.bezierPath.lineColor = self.lineColor;
    self.bezierPath.lineWidth = self.brushLineWidth ;
    self.bezierPath.isErase = self.isErase;
    [self.bezierPath moveToPoint:currentPoint];
    self.bezierPath.lineCapStyle = kCGLineCapRound ;
    self.bezierPath.lineJoinStyle = kCGLineJoinRound ;
    
    self.bezierPath.layer = [self setUpLayerFromBezierPath:self.bezierPath];
    
    [self.beziPathArrM addObject:self.bezierPath];
    ctr = 0 ;
    pts[ctr] = currentPoint ;

}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];

    // 方案1 ,  有尖刺 , 实时性比较强
//    CGPoint lastPoint = [touch previousLocationInView:self];
//    [self.bezierPath addQuadCurveToPoint:currentPoint controlPoint:CGPointMake(lastPoint.x/2+currentPoint.x/2, lastPoint.y/2+currentPoint.y/2) ];
//    self.bezierPath.layer.path = self.bezierPath.CGPath;

    // 方案2 , 无尖刺 , 实时跟踪比1略差
    [self drawBezierPath:self.bezierPath withPoint:currentPoint] ;
    

}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    [self.bezierPath addLineToPoint:currentPoint];
  

    // 小于4个点,用3次贝塞尔曲线就画不出来了,用最原始的方法
    if (self.bezierPath.pointsArray.count <= 4) {
        CGPoint firstPoint = [self.bezierPath.pointsArray.firstObject CGPointValue] ;
        [self.bezierPath moveToPoint:firstPoint];
        
        for (int i = 1; i<self.bezierPath.pointsArray.count; i++) {
            [self.bezierPath addLineToPoint: [self.bezierPath.pointsArray[i] CGPointValue] ];
        }
        self.bezierPath.layer = [self setUpLayerFromBezierPath:self.bezierPath] ;

    }

    
    ctr = 0 ;

   
}


- (CAShapeLayer *) setUpLayerFromBezierPath:(BezierPath *)path {
    CAShapeLayer * slayer = [CAShapeLayer layer];
    slayer.backgroundColor = [UIColor clearColor].CGColor;
    slayer.fillColor = [UIColor clearColor].CGColor;
    slayer.lineCap = kCALineCapRound;
    slayer.lineJoin = kCALineJoinRound;
    slayer.strokeColor = path.lineColor.CGColor;
    slayer.lineWidth = path.lineWidth;
    slayer.cornerRadius = path.lineWidth/2 ;
    slayer.path = path.CGPath;
    [self.layer addSublayer:slayer];
    return slayer ;
    
}

// 拿到点,开始画贝塞尔曲线
- (void)drawBezierPath:(BezierPath *)path withPoint:(CGPoint )currentPoint{
    
    ctr++;
    pts[ctr] = currentPoint ;
    if (ctr == 4)
    {
        pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0);
        
        [path addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]];
        
        pts[0] = pts[3];
        pts[1] = pts[4];
        ctr = 1;
        path.layer.path = path.CGPath;
    }
}


-(NSMutableArray *)beziPathArrM{
    if(_beziPathArrM==nil){
        _beziPathArrM=[NSMutableArray array];
    }
    return  _beziPathArrM;
}



@end
