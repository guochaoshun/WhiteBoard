//
//  ViewController.m
//  WhiteBoard
//
//  Created by 郭朝顺 on 2019/2/11星期一.
//  Copyright © 2019年 智网易联. All rights reserved.
//

#import "ViewController.h"
#import "BaiBanView.h"

#define RandomColor [UIColor colorWithRed:(arc4random_uniform(100)/ 100.0) green:(arc4random_uniform(100)/ 100.0) blue:(arc4random_uniform(100)/ 100.0) alpha:1.0]


@interface ViewController ()

@property (nonatomic,strong) BaibanView * baibanView ;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // 最简单的白板,只是原理,原项目的选择颜色和线条粗细的工具栏只是简单的写了写
    self.baibanView = [[BaibanView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:self.baibanView atIndex:0];
    
    // 是否使用图片,图片的填充方式只有填充满一种,需要自己根据图片大小设置白板的frame
//    self.baibanView.backgroundImage = [UIImage imageNamed:@"bgImage"];
    self.baibanView.backgroundImage = [UIImage imageNamed:@"121475-长号手"];

    
    
}



/// 随机颜色
- (IBAction)randomColor:(id)sender {
    
    self.baibanView.lineColor = RandomColor ;
    
}

/// 改变线宽
- (IBAction)changeLineWidth:(UIStepper *)stepper {
    
    self.baibanView.brushLineWidth = stepper.value;
}
/// 清除上一笔
- (IBAction)clearLastPath:(id)sender {
    
    [self.baibanView clearLastPath];
}

/// 清除所有笔记
- (IBAction)clearAllPath:(id)sender {
    
    [self.baibanView clearAllPath];
}

/// 橡皮擦
- (IBAction)erroser:(UIButton *)button {
    button.selected = !button.isSelected;
    self.baibanView.isErase = button.selected ;
}







@end
