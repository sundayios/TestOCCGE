//
//  ViewController.m
//  TestOCCGE
//Android version: https://github.com/wysaid/android-gpuimage-plus
//iOS version: https://github.com/wysaid/ios-gpuimage-plus
//  Created by Biggerlens on 2021/9/30.
//

#import "ViewController.h"
#import <cge/cge.h>
UIImage* loadImageCallback(const char* name, void* arg)
{
    NSString* filename = [NSString stringWithUTF8String:name];
    return [UIImage imageNamed:filename];
}

void loadImageOKCallback(UIImage* img, void* arg)
{
    
}

@interface ViewController (){
    CGSize dImgSize;
    CGPoint lastPanPoint;
    
//    CGE::CGELiquidationNicerFilter *liquifilter;
}

@property (nonatomic, strong) UIImage *testImg;
@property (nonatomic, strong) UIImageView *imgV;

//@property (nonatomic, strong) UIButton *quitBtn;
//@property (nonatomic, strong) UIButton *startBtn;

@property (nonatomic, assign) CGE::Vec2f lastVec2f;

@property (nonatomic, strong) GLKView* glkView;
@property (nonatomic, strong) CGEImageViewHandler* myImageView;

@property (nonatomic, strong) UISlider *slider;

@end

@implementation ViewController


- (UIImage *)testImg {
    if (!_testImg) {
        _testImg = [UIImage imageNamed:@"meinv.jpg"];
    }
    return _testImg;
}

- (UIImageView *)imgV{
    if (!_imgV) {
        _imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 500)];
    }
    return _imgV;
}


- (void)viewDidLoad {
    [super viewDidLoad];
//    cgeSetLoadImageCallback(loadImageCallback, loadImageOKCallback, nil);
//    const char *ruleString = [@"@adjust hsl 0.02 -0.31 -0.17" UTF8String];
//    UIImage* resultImage = cgeFilterUIImage_MultipleEffects(self.testImg, ruleString, 1.0f, nil);
    cgeSetLoadImageCallback(loadImageCallback, loadImageOKCallback, nil);
    
    
    CGRect rt = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 100);
    _glkView = [[GLKView alloc] initWithFrame:rt];
    _glkView.userInteractionEnabled = YES;
    [self.view addSubview:_glkView];
    
    UIImage* myImage = [UIImage imageNamed:@"meinv.jpg"];
    dImgSize = myImage.size;
    
//    liquifilter = CGE::CGELiquidationNicerFilter();
//    liquifilter = CGE::CGELiquidationFilter();
    _myImageView = [[CGEImageViewHandler alloc] initWithGLKView:_glkView withImage:myImage];
    [_myImageView setViewDisplayMode:CGEImageViewDisplayModeAspectFit];
    
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [_glkView addGestureRecognizer:panGesture];
    
    NSArray *titlesArr = @[@"start",@"quit"];
    [titlesArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *item = (NSString *)obj;
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(50 + (50 + 30) * idx, self.view.frame.size.height - 100, 50, 40)];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setTitle:item forState:UIControlStateNormal];
            [button addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = idx;
            [self.view addSubview:button];
    }];
    
    
    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(30, self.view.frame.size.height - 80, 300, 30)];
    self.slider.minimumValue = 10;
    self.slider.maximumValue = 300;
    self.slider.value = 200;
    [self.slider addTarget:self action:@selector(slideVChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.slider];
    
}



- (void)panAction:(UIPanGestureRecognizer *)gesture {
    UIView *gestView = gesture.view;
    CGPoint location = [gesture locationInView:gestView];
    CGFloat fwidth = location.x;
    CGFloat fheight = location.y;
    
    fwidth = (fwidth / gestView.frame.size.width) * dImgSize.width;
    fheight = (fheight / gestView.frame.size.height) * dImgSize.height;
    
    CGE::Vec2f newVec2f(fwidth,fheight);
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        lastPanPoint = location;
        _lastVec2f = newVec2f;
    }else{
        CGFloat xDist = (location.x - lastPanPoint.x);
        CGFloat yDist = (location.y - lastPanPoint.y);
        CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
        if (distance < 40) {
            if ((_lastVec2f.dot() != 0) && (_lastVec2f.x() != newVec2f.x()) && (_lastVec2f.y() != newVec2f.y()) ) {
                
                CGE::CGELiquidationNicerFilter *liquifilter =  CGE::getLiquidationNicerFilter(dImgSize.width, dImgSize.height, 15);
                liquifilter-> forwardDeformMesh(_lastVec2f, newVec2f, dImgSize.width, dImgSize.height, self.slider.value, 0.1);
                [_myImageView setFilter:liquifilter];
                [_myImageView flush];
                UIImage *image =  [_myImageView resultImage];
                [_myImageView setUIImage:image];
            }
        }
        
        lastPanPoint = location;
        _lastVec2f = newVec2f;
    }

}


- (void)btnAction:(UIButton *)sender {
    if (sender.tag == 0) {
        //start
        
    }else{
        //end
        
        [_myImageView clear];
        _myImageView = nil;
    }
}

- (void)slideVChanged:(UISlider *)sender {
}
@end
