//
//  ZKLineSCNNode.h
//  ZKARRulerDemo
//
//  Created by pang on 2018/1/5.
//  Copyright © 2018年 zk. All rights reserved.
//

#import <SceneKit/SceneKit.h>

@interface ZKLineSCNNode : SCNNode

- (instancetype)initWithStartVector3:(SCNVector3) startVector pointOfView:(SCNNode *)pointOfView;

//开始点
@property (nonatomic,readonly) SCNVector3 startVector3;
@property (nonatomic,strong,readonly) SCNNode *startNode;

//结束点
@property (nonatomic,readonly) SCNVector3 endVector3;
@property (nonatomic,strong,readonly) SCNNode *endNode;

//显示文本
@property (nonatomic,strong,readonly) SCNNode *textNode;

//线节点
@property (nonatomic,strong,readonly) SCNNode *lineNode;

//更新結束點
- (void)updateEndNodeWithEndVector3:(SCNVector3)endVector3;

//长度 m
@property (nonatomic,readonly) double lenght;

@end
