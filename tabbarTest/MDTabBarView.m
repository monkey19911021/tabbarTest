//
//  tabbarView.m
//  tabbarTest
//
//  Created by Kevin Lee on 13-5-6.
//  Copyright (c) 2013年 Kevin. All rights reserved.
//

#import "MDTabbarView.h"
#import "DRNRealTimeBlurView.h"
#import <Foundation/Foundation.h>

@implementation tabbarView
{
    int buttonNumbers;
    NSMutableArray *buttonArray;
    NSMutableArray *tabButtonArray;
    DRNRealTimeBlurView *moreContentView;
    
    UIButton *_button_center;
    
    MyTabBarButton *userPanningBtn;
    
    BOOL unLockMoreCntentView;
    
    int buttonCount;
    
    CGPoint centerPoints[MAXBUTTONNUMBERS];//隐藏的按钮的位置
    CGPoint tabButtonCenter[4];//底部4个按钮的位置
    
    CGPoint centerBeforeMove;
    
    BOOL isSetCenter;
    
    UIScrollView *invisibleView;
    UIButton *invisibleBtn;
    
    UIPageControl *pageControl;
    
    float timeCount;
    NSTimer *timeCounter;
    BOOL isComeInto;
}

-(id)initWithFrame:(CGRect)frame andButtonNumbers:(int)numbers
{
    self = [super initWithFrame:CGRectMake(frame.origin.x,  frame.origin.y, 320, 60)];
    if (self) {
        // Initialization code
        buttonNumbers = numbers;
        if(numbers >= MAXBUTTONNUMBERS){
            buttonNumbers = MAXBUTTONNUMBERS;
        }
        [self setFrame:CGRectMake(frame.origin.x,  frame.origin.y, 320, 60)];
        [self layoutView];
    }
    return self;
}

-(void)layoutView
{
    buttonCount = 0;
    isSetCenter = NO;
    timeCount = 0;
    timeCounter = nil;
    isComeInto = NO;
    unLockMoreCntentView = YES;
    userPanningBtn = nil;
    
    //创建更多内容视图
    moreContentView = [[DRNRealTimeBlurView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 300)];
    moreContentView.center = CGPointMake(160, SCREENHEIGHT-240);
    moreContentView.tint = [UIColor blackColor];
    moreContentView.alpha = 0;
    
    //不可见全屏视图
    CGFloat invisibleViewHeight;
    if(SCREENHEIGHT == 568){
        invisibleViewHeight = SCREENHEIGHT-moreContentView.center.y+150;
    }else{
        invisibleViewHeight = SCREENHEIGHT-moreContentView.center.y+130;
    }
    invisibleView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, moreContentView.center.y-150, SCREENWIDTH, invisibleViewHeight)];
    invisibleView.contentOffset = CGPointMake(0, 0);
    invisibleView.showsHorizontalScrollIndicator = NO;
    invisibleView.contentSize = CGSizeMake(SCREENWIDTH*((buttonNumbers-4)/6 + (int)((buttonNumbers-4)%6>0?1:0)), invisibleView.bounds.size.height);
    invisibleView.pagingEnabled = YES;
    invisibleView.delegate = self;
    invisibleView.backgroundColor = [UIColor clearColor];
    [invisibleView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionOld context:nil];
    
    invisibleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-invisibleView.bounds.size.height)];
    [invisibleBtn addTarget:self action:@selector(showMore) forControlEvents:UIControlEventTouchDown];
    
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    pageControl.center = CGPointMake(moreContentView.center.x, 270);
    pageControl.hidesForSinglePage = YES;
    pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:1 alpha:0.7];
    [moreContentView addSubview:pageControl];
    
    buttonArray = [[NSMutableArray alloc] initWithCapacity:1];
    tabButtonArray = [[NSMutableArray alloc] initWithCapacity:1];
    for(int i=0; i<invisibleView.contentSize.width/320*6; i++){
        centerPoints[i] = CGPointMake(72+(i-i/6*6)%3*88+320*(i/6), 110+(i-i/6*6)/3*84);
    }
    tabButtonCenter[0] = CGPointMake(30, 30);
    tabButtonCenter[1] = CGPointMake(97, 30);
    tabButtonCenter[2] = CGPointMake(234, 30);
    tabButtonCenter[3] = CGPointMake(299, 30);
    
    _tabbarView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tabbar_0"]];
    [_tabbarView setFrame:CGRectMake(0, 9, _tabbarView.bounds.size.width, 51)];
    [_tabbarView setUserInteractionEnabled:YES];
    
    _tabbarViewCenter = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tabbar_mainbtn_bg"]];

    _tabbarViewCenter.center = CGPointMake(self.center.x, self.bounds.size.height/2.0);
    
    [_tabbarViewCenter setUserInteractionEnabled:YES];
    
    _button_center = [UIButton buttonWithType:UIButtonTypeCustom];
    _button_center.adjustsImageWhenHighlighted = YES;
    [_button_center setBackgroundImage:[UIImage imageNamed:@"tabbar_mainbtn"] forState:UIControlStateNormal];
    [_button_center addTarget:self action:@selector(showMore) forControlEvents:UIControlEventTouchUpInside];
    [_button_center setFrame:CGRectMake(0, 0, 46, 46)];
    
    _button_center.center =CGPointMake(_tabbarViewCenter.bounds.size.width/2.0, _tabbarViewCenter.bounds.size.height/2.0 + 5) ;
    
    [_tabbarViewCenter addSubview:_button_center];
    
    [self addSubview:_tabbarView];
    [self addSubview:_tabbarViewCenter];
    
    //初始化所有按钮
    [self layoutBtn];
}

-(void)layoutBtn
{
    for(int i=0; i<invisibleView.contentSize.width/320*6+4; i++){
        [self getButton];
    }
    
    pageControl.numberOfPages = invisibleView.contentSize.width/320;
    pageControl.currentPage = 0;
}

-(void)getButton
{
    MyTabBarButton *button = [MyTabBarButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 64, 60);
    button.tag = 101 + buttonCount;
    if(button.tag < buttonNumbers+101){
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitle:[NSString stringWithFormat:@"b%d",button.tag] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [button setUserInteractionEnabled:NO];
    }
    [buttonArray addObject:button];
    
    if(button.tag >104){
        button.alpha = 0;
        button.center = centerPoints[button.tag-104-1];
        [invisibleView addSubview:button];
    }else{
        button.center = tabButtonCenter[button.tag-101];
        [_tabbarView addSubview:button];
        [tabButtonArray addObject:button];
    }
    
    buttonCount++;
}

-(void)btnClick:(id)sender
{
    MyTabBarButton *btn = (MyTabBarButton *)sender;
    NSLog(@"button.tag = %d",btn.tag);
    switch ((int)btn.center.x - (int)invisibleView.contentOffset.x) {
        case 30:
        {
            [_tabbarView setImage:[UIImage imageNamed:@"tabbar_0"]];
            break;
        }
        case 97:
        {
            [_tabbarView setImage:[UIImage imageNamed:@"tabbar_1"]];
            break;
        }
        case 234:
            [_tabbarView setImage:[UIImage imageNamed:@"tabbar_3"]];
            break;
        case 299:
            [_tabbarView setImage:[UIImage imageNamed:@"tabbar_4"]];
            break;
        default:
            break;
    }
    
    switch (btn.tag) {
        case 101:
            [self.delegate touchBtnAtIndex:0 touchBtn:btn];
            break;
            
        case 102:
            [self.delegate touchBtnAtIndex:1 touchBtn:btn];
            break;
        default:
            break;
    }
}

//显示更多按钮
-(void)showMore{
    //appear moreContentView
    if(moreContentView.alpha == 0 && unLockMoreCntentView){
        [self.superview addSubview:moreContentView];
        [self.superview addSubview:invisibleBtn];
        [UIView animateWithDuration:0.3 animations:^{
            unLockMoreCntentView = NO;
            moreContentView.alpha = 1;
            for(MyTabBarButton *btn in buttonArray){
                if(btn.center.y != 30){
                    btn.alpha = 1;
                }
            }
        } completion:^(BOOL finished) {
            for(MyTabBarButton *btn in buttonArray){
                //添加长按手势
                [btn addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(makeAllButtonsMove:)]];
                
                //将底下按钮添加到同一个view上
                if(btn.center.y == 30){
                    [btn removeFromSuperview];
                    btn.center = CGPointMake(btn.center.x, invisibleView.bounds.size.height-21);
                    [invisibleView addSubview:btn];
                }
            }
            [self.superview addSubview:invisibleView];
            
            [_tabbarViewCenter removeFromSuperview];
            _tabbarViewCenter.center = CGPointMake(_tabbarViewCenter.center.x, invisibleView.bounds.size.height-_tabbarViewCenter.bounds.size.height/2);
            [invisibleView addSubview:_tabbarViewCenter];
            unLockMoreCntentView = YES;
        }];
    }else if(moreContentView.alpha == 1 && unLockMoreCntentView){
        //dismiss moreContentView
        [UIView animateWithDuration:0.3 animations:^{
            unLockMoreCntentView = NO;
            moreContentView.alpha = 0;
            for(MyTabBarButton *btn in buttonArray){
                if(btn.center.y != invisibleView.bounds.size.height-21){
                    btn.alpha = 0;
                }
            }
        } completion:^(BOOL finished) {
            [moreContentView removeFromSuperview];
            [invisibleBtn removeFromSuperview];
            
            for(MyTabBarButton *btn in buttonArray){
                [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
                [btn removeGestureRecognizer:[btn.gestureRecognizers objectAtIndex:0]];
                [btn.layer removeAllAnimations];
                if(btn.center.y == invisibleView.bounds.size.height-21){
                    [btn removeFromSuperview];
                    btn.center = CGPointMake(tabButtonCenter[[self indexOFTabButtonCenter:btn.center.x-invisibleView.contentOffset.x]].x, 30);
                    [_tabbarView addSubview:btn];
                }
            }
            
            [_tabbarViewCenter removeFromSuperview];
            _tabbarViewCenter.center = CGPointMake(self.center.x, self.bounds.size.height/2.0);
            [self addSubview:_tabbarViewCenter];
            
            [invisibleView setContentOffset:CGPointMake(0, 0)];
            [invisibleView removeFromSuperview];
            unLockMoreCntentView = YES;
        }];
    }
}

//使按钮抖动
-(void)makeAllButtonsMove:(UILongPressGestureRecognizer *)sender{
    if(sender.state == UIGestureRecognizerStateBegan){
        for(MyTabBarButton *btn in buttonArray){
            //移除可点击方法
            [btn removeTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            
            //移除长按手势
            [btn removeGestureRecognizer:[btn.gestureRecognizers objectAtIndex:0]];
            
            //添加拖拽手势
            [btn addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(buttonMove:)]];
            
            //添加抖动动画效果
            CABasicAnimation* shake = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            
            //设置抖动幅度
            shake.fromValue = [NSNumber numberWithFloat:-0.1];
            
            shake.toValue = [NSNumber numberWithFloat:+0.1];
            
            shake.duration = 0.1;
            
            shake.autoreverses = YES; //是否重复
            
            shake.repeatCount = HUGE_VALF;//设置无限重复
            
            [btn.layer addAnimation:shake forKey:@"imageView"];
            
            btn.alpha = 1.0;
            
            [UIView animateWithDuration:2.0 delay:2.0 options:UIViewAnimationOptionCurveEaseIn animations:nil completion:nil];
        }
    }
}

-(void)pageScroll:(NSTimer *)timer{
    timeCount+=0.1;
    if(timeCount >= 1){
        MyTabBarButton *tempBtn = (MyTabBarButton *)[timer.userInfo objectAtIndex:1];
        if([[timer.userInfo objectAtIndex:0] boolValue]){
            //向前滚动
            if(invisibleView.contentOffset.x+320*2 <= invisibleView.contentSize.width){
                userPanningBtn = tempBtn;
                [invisibleView setContentOffset:CGPointMake(invisibleView.contentOffset.x+320, 0) animated:YES];
            }
        }else{
            //向后滚动
            if(invisibleView.contentOffset.x-320 >= 0){
                userPanningBtn = tempBtn;
                [invisibleView setContentOffset:CGPointMake(invisibleView.contentOffset.x-320, 0) animated:YES];
            }
        }
        timeCount = 0;
    }
}

-(void)buttonMove:(UIPanGestureRecognizer *)sender
{
    MyTabBarButton *currentButton = (MyTabBarButton *)sender.view;
    CGPoint centerAfterMove = [sender locationInView:currentButton.superview];
    isComeInto =NO;
    
    //按钮重叠判断
    if(sender.state == UIGestureRecognizerStateBegan){
        
        centerBeforeMove = currentButton.center;
        
    }else if(sender.state == UIGestureRecognizerStateEnded){
        userPanningBtn = nil;
        
        NSTimeInterval duration = sqrt(pow((centerAfterMove.x-centerBeforeMove.x), 2)+pow((centerAfterMove.y-centerBeforeMove.y), 2))/700;
        
        [UIView animateWithDuration:duration animations:^{
            currentButton.center = centerBeforeMove;
        }];
        if(timeCounter != nil){
            [timeCounter invalidate];
            timeCounter = nil;
        }
    }else{
        
        currentButton.center = centerAfterMove;
        
        for(MyTabBarButton *btn in buttonArray){
            
            if(btn.tag != sender.view.tag){
                //移进某个按钮的frame范围
                if([self isGetIntoFrame:centerAfterMove centerPoint:btn.center]){
                    
                    [UIView animateWithDuration:0.3 animations:^{
                        //交换中心点
                        currentButton.center =btn.center;
                        btn.center = centerBeforeMove;
                        centerBeforeMove = currentButton.center;
                    }];
                    if(currentButton.center.y > invisibleView.bounds.size.height-70 && btn.center.y < invisibleView.bounds.size.height-70){
                        [tabButtonArray replaceObjectAtIndex:[tabButtonArray indexOfObject:btn] withObject:currentButton];
                    }else if(currentButton.center.y < invisibleView.bounds.size.height-70 && btn.center.y > invisibleView.bounds.size.height-70){
                        [tabButtonArray replaceObjectAtIndex:[tabButtonArray indexOfObject:currentButton] withObject:btn];
                    }
                    break;
                }
            }
            
        }
        
        //按钮拖拽到边界判断，添加计时器判断
        if(currentButton.center.y < moreContentView.center.y+moreContentView.bounds.size.width/2 && centerBeforeMove.y < SCREENHEIGHT-70){
            if(centerAfterMove.x > invisibleView.contentOffset.x+300 && centerAfterMove.x < invisibleView.contentSize.width-20){
                isComeInto = YES;
                if(timeCounter == nil){
                    timeCounter = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(pageScroll:) userInfo:@[@"1",currentButton] repeats:YES];
                }
            }else if(centerAfterMove.x < invisibleView.contentOffset.x+20 && invisibleView.contentOffset.x != 0){
                isComeInto = YES;
                if(timeCounter == nil){
                    timeCounter = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(pageScroll:) userInfo:@[@"0",currentButton] repeats:YES];
                }
            }
        }
        
        if(timeCounter != nil && isComeInto == NO){
            [timeCounter invalidate];
            timeCounter = nil;
        }
        
    }
}

//被拖拽按钮的中心点是否进入另一个按钮的frame范围
-(BOOL)isGetIntoFrame:(CGPoint)movingPoint centerPoint:(CGPoint)centerPoint
{
    return (movingPoint.x <= centerPoint.x+32 && movingPoint.x >= centerPoint.x-32 && movingPoint.y >= centerPoint.y-30 && movingPoint.y <= centerPoint.y+30);
}

//监听scrollView的内容偏移量属性
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    pageControl.currentPage = invisibleView.contentOffset.x/320;
    float oldX= [[[[[NSString stringWithFormat:@"%@",[change objectForKey:@"old"]] substringFromIndex:10] componentsSeparatedByString:@","] objectAtIndex:0] floatValue];//上次的x点偏移量
    if([keyPath isEqualToString:@"contentOffset"]){
        if([_tabbarViewCenter.superview isEqual:invisibleView]){
            _tabbarViewCenter.center = CGPointMake(self.center.x+invisibleView.contentOffset.x,_tabbarViewCenter.center.y);
            for(MyTabBarButton *btn in tabButtonArray){
                btn.center = CGPointMake(tabButtonCenter[[self indexOFTabButtonCenter:btn.center.x-oldX]].x+invisibleView.contentOffset.x, btn.center.y);//底下的按钮都跟着移动
            }
        }
    }
    if(userPanningBtn != nil){
        userPanningBtn.center = CGPointMake(userPanningBtn.center.x + invisibleView.contentOffset.x - oldX, userPanningBtn.center.y);
    }
}

-(int)indexOFTabButtonCenter:(float)xPoint;
{
    int index=0;
    for(int i=0; i<4; i++){
        if(xPoint > tabButtonCenter[i].x){
            index++;
        }
    }
    return index;
}

-(NSArray *)getAllButtons
{
    if(buttonArray.count != 0){
        return [buttonArray subarrayWithRange:NSMakeRange(0, buttonNumbers)];
    }
    return nil;
}

@end
