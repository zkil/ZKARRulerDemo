//
//  ZKLineSCNNode.m
//  ZKARRulerDemo
//
//  Created by pang on 2018/1/5.
//  Copyright © 2018年 zk. All rights reserved.
//

#import "ZKLineSCNNode.h"
@interface ZKLineSCNNode ()
@property (nonatomic,strong) SCNText *textGeometry;
@end

@implementation ZKLineSCNNode


- (instancetype)initWithStartVector3:(SCNVector3)startVector pointOfView:(SCNNode *)pointOfView {
    if (self = [super init]) {
        //圆点模型
        _startVector3 = startVector;
        SCNSphere *sphere = [SCNSphere sphereWithRadius:0.5];
        sphere.firstMaterial.diffuse.contents = [UIColor redColor]; //填充色
        sphere.firstMaterial.lightingModelName = SCNLightingModelConstant; //表明光亮
        sphere.firstMaterial.doubleSided = YES;
        
        //开始节点
        SCNNode *startNode = [SCNNode nodeWithGeometry:sphere];
        startNode.scale = SCNVector3Make(1/500.0, 1/500.0, 1/500.0);
        startNode.position = startVector;
        [self addChildNode:startNode];
        _startNode = startNode;
        
        //结束节点
        SCNNode *endNode = [SCNNode nodeWithGeometry:sphere];
        endNode.scale = SCNVector3Make(1/500.0, 1/500.0, 1/500.0);
        endNode.position = startVector;
        [self addChildNode:endNode];
        _endNode = endNode;
        
        //文本
        SCNText *textGeometry = [SCNText textWithString:@"" extrusionDepth:0.1];
        textGeometry.font = [UIFont systemFontOfSize:6];
        textGeometry.firstMaterial.diffuse.contents = [UIColor redColor];
        textGeometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
        textGeometry.firstMaterial.doubleSided = YES;
        textGeometry.alignmentMode = kCAAlignmentCenter;
        textGeometry.truncationMode = kCATruncationMiddle;
        self.textGeometry = textGeometry;
        
        SCNNode *textNode = [SCNNode nodeWithGeometry:textGeometry];
        textNode.eulerAngles = SCNVector3Make(0, M_PI, 0);
        textNode.scale = SCNVector3Make(1/500.0, 1/500.0, 1/500.0);
        
        _textNode = [SCNNode node];
        [_textNode addChildNode:textNode];
        SCNLookAtConstraint *constraint = [SCNLookAtConstraint lookAtConstraintWithTarget:pointOfView];
        constraint.gimbalLockEnabled = YES;
        _textNode.constraints = @[constraint];
        [self addChildNode:_textNode];
    }
    return self;
}

- (void)updateEndNodeWithEndVector3:(SCNVector3)endVector3 {
    //移除旧线
    [_lineNode removeFromParentNode];
    //创建新的线
    SCNNode *newLineNode = [self getNewLineNodeWithVector:endVector3];
    [self addChildNode:newLineNode];
    _lineNode = newLineNode;
    
    //更新終點圓點位置
    self.endNode.position = endVector3;
    _endVector3 = endVector3;
    
    //更新文本
    self.textGeometry.string = [NSString stringWithFormat:@"%.2f",self.lenght * 100];
    //更新文本位置
    self.textNode.position = SCNVector3Make((self.startVector3.x + endVector3.x)/2, (self.startVector3.y + endVector3.y)/2, (self.startVector3.z + endVector3.z)/2);
    
    
}

- (SCNNode *)getNewLineNodeWithVector:(SCNVector3)endVector {
    SCNVector3 vectors[] = {self.startVector3, endVector};
    SCNGeometrySource *soure = [SCNGeometrySource geometrySourceWithVertices:vectors count:2];
    int indicies[] = {0, 1};
    NSData *indexData = [NSData dataWithBytes:indicies length:sizeof(indicies)];
    SCNGeometryElement *element = [SCNGeometryElement geometryElementWithData:indexData primitiveType:SCNGeometryPrimitiveTypeLine primitiveCount:2 bytesPerIndex:sizeof(int)];
    SCNGeometry *line = [SCNGeometry geometryWithSources:@[soure] elements:@[element]];
    line.firstMaterial.diffuse.contents = [UIColor redColor];
    
    return [SCNNode nodeWithGeometry:line];
}

- (double)lenght {
    return sqrt(pow(self.startVector3.x - self.endVector3.x, 2) + pow(self.startVector3.y - self.endVector3.y, 2) + pow(self.startVector3.z - self.endVector3.z, 2));
}

@end
