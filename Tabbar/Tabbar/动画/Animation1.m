//
//  Animation1.m
//  Tabbar
//
//  Created by Jion on 15/10/28.
//  Copyright © 2015年 Youjuke. All rights reserved.
//
#define r1  (arc4random_uniform(256)/255.0)
#define g1  (arc4random_uniform(256)/255.0)
#define b1  (arc4random_uniform(256)/255.0)
#define arcColor [UIColor colorWithRed:r1 green:g1  blue:b1  alpha:0.8]

#import "Animation1.h"
#import "LineView.h"
@interface Animation1 ()
{
    LineView *_layerView;
    LineView *_layerView1;
    LineView *_layerView2;
    
     CATransformLayer *s_Cube1;
     CATransformLayer *s_Cube2;
     CGPoint startPoint;
    float pix, piy;
}
@end

@implementation Animation1

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //画线
    [self lineUI];
    //绘图
    [self Mapping];
    //过渡色
    [self gradientLayerView];
    //
    [self replicatorView];
}
/**********木有看懂*******复制层ReplicatorLayer*****************/

- (void)replicatorView
{
    _layerView2 = [[LineView alloc] initWithFrame:CGRectMake(100, 200, 150, 150)];
    [self.view addSubview:_layerView2];
    
    CAReplicatorLayer *replicator = [CAReplicatorLayer layer];
    replicator.frame = _layerView2.bounds;
    [_layerView2.layer addSublayer:replicator];
    
    //配置复制，复制多少份。
    replicator.instanceCount = 20;
    //设置旋转
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DTranslate(transform, 0, -3, 0);
    transform = CATransform3DRotate(transform, M_PI/10.0, 0, 0, 1);
    transform = CATransform3DTranslate(transform, 0, 3, 0);
    replicator.instanceTransform = transform;
    //实例颜色变换
    replicator.instanceBlueOffset = -0.1;
    replicator.instanceGreenOffset = -0.1;
    //把复制层显示
    CALayer *lay = [CALayer layer];
    lay.frame = CGRectMake(5, 70, 15, 15);
    lay.backgroundColor = [arcColor CGColor];
    [replicator addSublayer:lay];
}

/***********************产生平滑过渡色****************************/
//颜色过渡根据起始点，默认自上而下（0.5，0）->(0.5,1)，若start(0,0)->end(1,1)则成对角线分布
- (void)gradientLayerView
{
    _layerView1 = [[LineView alloc] initWithFrame:CGRectMake(50, 400, 150, 150)];
    [self.view addSubview:_layerView1];
    //创建梯度layer
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = _layerView1.bounds;
    
    [_layerView1.layer addSublayer:gradientLayer];
    
    //设置过渡色颜色
    gradientLayer.colors = @[(__bridge id)arcColor.CGColor,(__bridge id)arcColor.CGColor];
    //设置梯度变化的起,始点
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 1);
    
    //设置渐变区域(必须是单调递增的)
    gradientLayer.locations = @[[NSNumber numberWithFloat:0.3],[NSNumber numberWithFloat:0.7]];
    
}
/***********************3D效果*******************************/
- (void)Mapping
{
    _layerView = [[LineView alloc] initWithFrame:CGRectMake(120, 20, 150, 150)];
    [self.view addSubview:_layerView];
    //设置透视变换
    CATransform3D pt = CATransform3DIdentity;
    pt.m34 = -1.0/500;
    _layerView.layer.sublayerTransform = pt;
    
    //设置添加一个变换三维图1
    CATransform3D c1t = CATransform3DIdentity;
    c1t = CATransform3DTranslate(c1t, -100, 0, 0);
    CALayer *cube1 = [self cubeWithTransform:c1t];
    s_Cube1 = (CATransformLayer*)cube1;
    [_layerView.layer addSublayer:cube1];
    
    //设置添加一个变换三维图2
    CATransform3D c2t = CATransform3DIdentity;
    c2t = CATransform3DTranslate(c2t, 100, 0, 0);
    c2t = CATransform3DRotate(c2t, -M_PI_4, 1, 0, 0);
    c2t = CATransform3DRotate(c2t, -M_PI_4, 0, 1, 0);
    CALayer *cube2 = [self cubeWithTransform:c2t];
    s_Cube2 = (CATransformLayer*)cube2;
    [_layerView.layer addSublayer:cube2];
    
}
//触摸事件设置
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    startPoint = [touch locationInView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    CGPoint currentPosition = [touch locationInView:self.view];
    
    CGFloat deltaX = startPoint.x - currentPosition.x;
    
    CGFloat deltaY = startPoint.y - currentPosition.y;
    
    CATransform3D c1t = CATransform3DIdentity;
    c1t = CATransform3DTranslate(c1t, -100, 0, 0);
    c1t = CATransform3DRotate(c1t, pix+M_PI_2*deltaY/100, 1, 0, 0);
    c1t = CATransform3DRotate(c1t, piy-M_PI_2*deltaX/100, 0, 1, 0);
    
    s_Cube1.transform = c1t;
    
    CATransform3D c2t = CATransform3DIdentity;
    c2t = CATransform3DTranslate(c2t, 100, 0, 0);
    c2t = CATransform3DRotate(c2t, pix+M_PI_2*deltaY/100, 1, 0, 0);
    c2t = CATransform3DRotate(c2t, piy-M_PI_2*deltaX/100, 0, 1, 0);
    s_Cube2.transform = c2t;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    CGPoint currentPosition = [touch locationInView:self.view];
    
    CGFloat deltaX = startPoint.x - currentPosition.x;
    
    CGFloat deltaY = startPoint.y - currentPosition.y;
    
    pix = M_PI_2*deltaY/100;
    piy = -M_PI_2*deltaX/100;
}
//创建一个面
- (CALayer *)faceWithTransform:(CATransform3D)transform
{
    CALayer *face = [CALayer layer];
    face.frame = CGRectMake(-50, -50, 100, 100);
    
    face.backgroundColor = [arcColor CGColor];
    face.transform = transform;
    return face;
}
//创建三维六面
- (CALayer*)cubeWithTransform:(CATransform3D)transform
{
    CATransformLayer *cube = [CATransformLayer layer];
    //cube face 1
    CATransform3D ct = CATransform3DMakeTranslation(0, 0, 50);
    [cube addSublayer:[self faceWithTransform:ct]];
    
    //cube face 2
    ct = CATransform3DMakeTranslation(50, 0, 0);
    ct = CATransform3DRotate(ct, M_PI_2, 0, 1, 0);
    [cube addSublayer:[self faceWithTransform:ct]];
    
    //cube face 3
    ct = CATransform3DMakeTranslation(0, -50, 0);
    ct = CATransform3DRotate(ct, M_PI_2, 1, 0, 0);
    [cube addSublayer:[self faceWithTransform:ct]];
    
    //cube face 4
    ct = CATransform3DMakeTranslation(0, 50, 0);
    ct = CATransform3DRotate(ct, -M_PI_2, 1, 0, 0);
    [cube addSublayer:[self faceWithTransform:ct]];
    
    //cube face 5
    ct = CATransform3DMakeTranslation(-50, 0, 0);
    ct = CATransform3DRotate(ct, -M_PI_2, 0, 1, 0);
    [cube addSublayer:[self faceWithTransform:ct]];
    
    //cube face 6
    ct = CATransform3DMakeTranslation(0, 0, -50);
    ct = CATransform3DRotate(ct, M_PI, 0, 1, 0);
    [cube addSublayer:[self faceWithTransform:ct]];
    
    CGSize size = _layerView.bounds.size;
    cube.position = CGPointMake(size.width/2.0, size.height/2.0);
    
    cube.transform = transform;
    return cube;
    
}
/*********************绘线，绘圆******************************/
- (void)lineUI{
    /*
     画实线
     */
    CAShapeLayer *line = [CAShapeLayer layer];
    CGMutablePathRef path = CGPathCreateMutable();
    line.fillColor = [arcColor CGColor];
    line.strokeColor = [arcColor CGColor];
    line.lineWidth = 3.0;
    line.opacity = 0.5;//类似alpha
    CGPathMoveToPoint(path, NULL, 20, 265);
    CGPathAddLineToPoint(path, NULL, 300, 265);
    CGPathAddLineToPoint(path, NULL, 300, 100);
    CGPathCloseSubpath(path);
    line.path = path;
    CGPathRelease(path);
    [self.view.layer addSublayer:line];
    
    /*
     画虚线
     */
    CAShapeLayer *xuLine = [CAShapeLayer layer];
    xuLine.fillColor = [arcColor CGColor];
    xuLine.strokeColor = [arcColor CGColor];
    xuLine.lineWidth = 1.0;
    NSArray *lineArr = @[@10,@5];
    xuLine.lineDashPattern = lineArr;
    CGMutablePathRef path1 = CGPathCreateMutable();
    CGPathMoveToPoint(path1, NULL, 20, 500);
    CGPathAddLineToPoint(path1, NULL, 20, 285);
    CGPathAddLineToPoint(path1, NULL, 300, 285);
    CGPathCloseSubpath(path1);
    xuLine.path = path1;
    CGPathRelease(path1);
    [self.view.layer addSublayer:xuLine];
    /*
     画圆
     */
    CAShapeLayer *ellip = [CAShapeLayer layer];
    ellip.lineWidth = 3.0;
    ellip.fillColor = [arcColor CGColor];
    ellip.strokeColor = [arcColor CGColor];
    ellip.opacity = 0.5;
    CGMutablePathRef path2 = CGPathCreateMutable();
    CGPathAddEllipseInRect(path2, nil, CGRectMake(150, 350, 200, 200));
    ellip.path = path2;
    //设置虚线
    NSArray *eArray = @[@10,@5];
    ellip.lineDashPattern = eArray;
    //虚线的起始位置，对于圆来说无所谓了
    ellip.lineDashPhase = 1;
    CGPathRelease(path2);
    [self.view.layer addSublayer:ellip];
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
