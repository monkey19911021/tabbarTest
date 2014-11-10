//
//  tabbarView.h
//  tabbarTest
//
//  Created by Kevin Lee on 13-5-6.
//  Copyright (c) 2013年 Kevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDTabBarButton.h"

#define MAXBUTTONNUMBERS 100

@protocol tabbarDelegate <NSObject>

-(void)touchBtnAtIndex:(NSInteger)index touchBtn:(MyTabBarButton *)btn;//实现所有点击按钮触发的方法

@end

@interface tabbarView : UIView <UIScrollViewDelegate>

@property(nonatomic,strong) UIImageView *tabbarView;
@property(nonatomic,strong) UIImageView *tabbarViewCenter;


@property(nonatomic,weak) id<tabbarDelegate> delegate;

-(id)initWithFrame:(CGRect)frame andButtonNumbers:(int)numbers;

-(NSArray *)getAllButtons;

@end

