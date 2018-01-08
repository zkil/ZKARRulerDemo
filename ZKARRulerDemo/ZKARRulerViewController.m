//
//  ZKARRulerViewController.m
//  ZKARRulerDemo
//
//  Created by pang on 2018/1/4.
//  Copyright © 2018年 zk. All rights reserved.
//

#import "ZKARRulerViewController.h"
#import <ARKit/ARKit.h>

#import "ZKLineSCNNode.h"

@implementation ARSCNView (zk_Addtion)

/**
将屏幕上的点转为3维坐标

 @param point 屏幕上的点坐标
 @return 3维坐标
 */
- (NSValue *)vector3WithHitPoint:(CGPoint) point {
    /*
     ARHitTestResultTypeFeaturePoint，根据距离最近的特征点检测出来的连续表面。
     ARHitTestResultTypeEstimatedHorizontalPlane，非精准方式计算出来与重力垂直的平面。
     ARHitTestResultTypeExistingPlane, 已经检测出来的平面，检测时忽略平面本身大小，把它看做一个无穷大的平面。
     ARHitTestResultTypeExistingPlaneUsingExtent, 已经检测出来的平面，检测时考虑平面本身的大小。
     检测成功则返回
    */
    NSArray *results = [self hitTest:point types:ARHitTestResultTypeFeaturePoint];
    if (results.count == 0) {
        return nil;
    }
    ARHitTestResult *hitResult = [results firstObject];
    SCNVector3 vector3;
    vector3 = SCNVector3Make(hitResult.worldTransform.columns[3].x, hitResult.worldTransform.columns[3].y, hitResult.worldTransform.columns[3].z);
    return [NSValue valueWithSCNVector3:vector3];
}

@end

@interface ZKARRulerViewController ()<ARSessionDelegate, ARSCNViewDelegate>

//AR视图：展示3D界面
@property (nonatomic,strong) ARSCNView *arSCNView;

//AR会话，负责管理相机追踪及相机坐标
@property (nonatomic,strong) ARSession *arSession;

//会话追踪配置：负责追踪相机运动
@property (nonatomic,strong) ARConfiguration *arConfiguration;

//线节点
@property (nonatomic, strong) NSMutableArray<ZKLineSCNNode *> *lineNodeArray;
//当前线
@property (nonatomic, strong) ZKLineSCNNode *currentLineNode;

@property (nonatomic,strong) UILabel *textLab;
@property (nonatomic,strong) UIImageView *targetIV;
@end

@implementation ZKARRulerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //创建会话配置，需要A9芯片
    [self initConfiguration];
    //创建会话
    [self initSession];
    //创建显示视图
    [self initSCNView];
    
    self.textLab = [UILabel new];
    self.textLab.font = [UIFont systemFontOfSize:20];
    self.textLab.textColor = [UIColor whiteColor];
    self.textLab.textAlignment = NSTextAlignmentCenter;
    self.textLab.frame = CGRectMake(0, 0, 150, 35);
    self.textLab.center = CGPointMake(self.view.center.x, 100);
    [self.view addSubview:self.textLab];
    
    UIImageView *centerIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"target_white.png"]];
    centerIV.highlightedImage = [UIImage imageNamed:@"target_green.png"];
    centerIV.frame = CGRectMake(0, 0, 80, 80);
    centerIV.center = self.view.center;
    [self.view addSubview:centerIV];
    self.targetIV = centerIV;
}

#pragma -mark- init

- (NSMutableArray<ZKLineSCNNode *> *)lineNodeArray {
    if (_lineNodeArray == nil) {
        _lineNodeArray = [NSMutableArray new];
    }
    return _lineNodeArray;
}

- (void)initConfiguration {
    ARWorldTrackingConfiguration *configuration = [[ARWorldTrackingConfiguration alloc] init];
    //设置追踪方向（追踪平面）
    //configuration.planeDetection = ARPlaneDetectionHorizontal;
    //3.自适应灯光 （相机暗到强光过度效果平缓些）
    //configuration.lightEstimationEnabled = YES;
    self.arConfiguration = configuration;
}

- (void)initSession {
    ARSession *session = [[ARSession alloc] init];
    session.delegate = self;
    self.arSession = session;
}

- (void)initSCNView {
    ARSCNView *scnView = [[ARSCNView alloc] initWithFrame:self.view.bounds];
    //自动刷新灯光（3D游戏用到，此处可忽略）
    //scnView.automaticallyUpdatesLighting = YES;
    //设置代理
    scnView.delegate = self;
    //开启debug（渲染 ARKit 检测到的特征点）
    scnView.debugOptions =  ARSCNDebugOptionShowFeaturePoints;
    //设置会话
    scnView.session = self.arSession;
    [self.view addSubview:scnView];
    
    self.arSCNView = scnView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //开启会话
    [self.arSession runWithConfiguration:self.arConfiguration];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //暂停会话
    [self.arSession pause];
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.currentLineNode == nil) {
//        UITouch *touch  = [touches anyObject];
//        CGPoint point = [touch locationInView:self.view];
        
        NSValue *vectorValue = [self.arSCNView vector3WithHitPoint:self.arSCNView.center];
        if (vectorValue == nil) {
            return;
        }
        SCNVector3 starVector3 = [vectorValue SCNVector3Value];
        ZKLineSCNNode *lineNode = [[ZKLineSCNNode alloc] initWithStartVector3:starVector3 pointOfView:self.arSCNView.pointOfView];
        [self.arSCNView.scene.rootNode addChildNode:lineNode];
        _currentLineNode = lineNode;
        [self.lineNodeArray addObject:lineNode];
    } else {
        self.currentLineNode = nil;
    }
}

#pragma -mark- ARSCNViewDelegate

//3D渲染刷新时调用
- (void)renderer:(id<SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSValue *vectorValue = [self.arSCNView vector3WithHitPoint:self.arSCNView.center];
        if (vectorValue == nil) {
            self.textLab.text = NSLocalizedString(@"初始化中...", nil);
            self.targetIV.highlighted = NO;
            return;
        }
        self.targetIV.highlighted = YES;
        if (self.currentLineNode == nil) {
            self.textLab.text = NSLocalizedString(@"初始化完成", nil);
            return;
        }
        
        SCNVector3 endVector3 = [vectorValue SCNVector3Value];
        [self.currentLineNode updateEndNodeWithEndVector3:endVector3];
        self.textLab.text = [NSString stringWithFormat:@"%.2f", self.currentLineNode.lenght * 100];
    });
}



- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    NSLog(@"session error");
}

- (void)sessionWasInterrupted:(ARSession *)session {
    NSLog(@"session interrupted");
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    NSLog(@"session interrupted end");;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
