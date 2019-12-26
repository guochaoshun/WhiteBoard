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
@property (nonatomic,strong) UIImage * stretchedImage ;


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

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    
    //将变换后的图片设置为背景色,如果背景图是透明色的话,需要再处理下,把透明色处理成白色
//    [self setBackgroundColor:[[UIColor alloc] initWithPatternImage:self.stretchedImage]];
    //View的图层设置为原始图片，这里会自动翻转，经过这步后图层显示和橡皮背景都设置为正确的图片。
    self.layer.contents = (_Nullable id)_backgroundImage.CGImage;
    
}
// 先使图片翻转,
- (UIImage *)stretchedImage {
    
    if (_stretchedImage==nil) {
        //创建一个新的Context,使用这个擦除的时候不会变糊
        UIGraphicsBeginImageContextWithOptions(self.frame.size,YES,[[UIScreen mainScreen] scale]);
        //获得当前Context
        CGContextRef context = UIGraphicsGetCurrentContext();
        //CTM变换，调整坐标系，*重要*，否则橡皮擦使用的背景图片会发生翻转。
        CGContextScaleCTM(context, 1, -1);
        CGContextTranslateCTM(context, 0, -self.bounds.size.height);
        //图片适配到当前View的矩形区域，会有拉伸
        [_backgroundImage drawInRect:self.bounds];
        //获取拉伸并翻转后的图片
        _stretchedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

    }
    return _stretchedImage;
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

    if (self.isErase) {
        
        if (self.backgroundImage == nil) {
            // 橡皮擦方案1 : 如果没有背景图片,直接设置橡皮擦的颜色为背景色即可
            self.bezierPath.lineColor = [UIColor whiteColor];
        } else {
            // 橡皮擦方案2 : 如果有背景图片,需要把lineColor的颜色设置成背景图片的颜色
            // 原理大致是:backgroundImage正常显示,然后是橡皮擦的时候,把背景图片上的颜色覆盖上去,给用户的感觉就是擦掉了笔迹
            // https://blog.csdn.net/sonysuqin/article/details/81092574?utm_source=blogxgwz9
            self.bezierPath.lineColor = [UIColor colorWithPatternImage:self.stretchedImage];
        }
        
        self.bezierPath.lineWidth = 15 ;
    }
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
