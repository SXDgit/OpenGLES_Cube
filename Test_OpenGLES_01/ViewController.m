//
//  ViewController.m
//  Test_OpenGLES_01
//
//  Created by 桑协东 on 2019/6/4.
//  Copyright © 2019 ZB_Demo. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "ViewController.h"

typedef struct {
    GLKVector3 positionCoord;       // 顶点坐标
    GLKVector2 textureCoord;        // 纹理坐标
    GLKVector3 normal;              // 法线坐标
} ZBVertex;
// 顶点个数
static NSInteger const KCoordCount = 36;

@interface ViewController () <GLKViewDelegate>

@property (nonatomic, strong) GLKView *glkView;
@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, assign) ZBVertex *vertices;

// 计时器
@property (nonatomic, strong) CADisplayLink *displayLink;
// 弧度
@property (nonatomic, assign) NSInteger angle;
// 顶点缓存区标识符ID
@property (nonatomic, assign) GLuint vertexBuffer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self configOpenGLESInit];
    
    [self vertexDataSetup];
    
    [self addCADisplayLink];
    
    
}

- (void)configOpenGLESInit {
    // 1.创建context
    EAGLContext *context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:context];
    
    // 2.创建GLKView并设置代理
    CGRect frame = CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.width);
    self.glkView = [[GLKView alloc]initWithFrame:frame context:context];
    self.glkView.backgroundColor = [UIColor redColor];
    self.glkView.delegate = self;
    
    // 3. 使用深度缓冲区
    self.glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    self.glkView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    
    // 默认为（0，1），这里用于翻转z轴，是正方形朝屏幕外
//    glDepthRangef(1, 0);
    
    [self.view addSubview:self.glkView];
    
    NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"timg.jpeg"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft : @(YES)};
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:[image CGImage] options:options error:nil];
    
    // 使用苹果GLKit提供GLKBaseEffect完成着色器工作（顶点/片元）
    self.baseEffect = [[GLKBaseEffect alloc]init];
    self.baseEffect.texture2d0.name = textureInfo.name;
    self.baseEffect.texture2d0.target = textureInfo.target;
    
}

- (void)vertexDataSetup {
    // 开辟顶点数据空间（数据结构SenceVertex 大小 * 顶点个数kCoordCount）
    self.vertices = malloc(sizeof(ZBVertex) * KCoordCount);
    
    // 前面
    self.vertices[0] = (ZBVertex){{-0.5, 0.5, 0.5},  {0, 1}};
    self.vertices[1] = (ZBVertex){{-0.5, -0.5, 0.5}, {0, 0}};
    self.vertices[2] = (ZBVertex){{0.5, 0.5, 0.5},   {1, 1}};
    
    self.vertices[3] = (ZBVertex){{-0.5, -0.5, 0.5}, {0, 0}};
    self.vertices[4] = (ZBVertex){{0.5, 0.5, 0.5},   {1, 1}};
    self.vertices[5] = (ZBVertex){{0.5, -0.5, 0.5},  {1, 0}};
    
    // 上面
    self.vertices[6] = (ZBVertex){{0.5, 0.5, 0.5},    {1, 1}};
    self.vertices[7] = (ZBVertex){{-0.5, 0.5, 0.5},   {0, 1}};
    self.vertices[8] = (ZBVertex){{0.5, 0.5, -0.5},   {1, 0}};
    self.vertices[9] = (ZBVertex){{-0.5, 0.5, 0.5},   {0, 1}};
    self.vertices[10] = (ZBVertex){{0.5, 0.5, -0.5},  {1, 0}};
    self.vertices[11] = (ZBVertex){{-0.5, 0.5, -0.5}, {0, 0}};
    
    // 下面
    self.vertices[12] = (ZBVertex){{0.5, -0.5, 0.5},    {1, 1}};
    self.vertices[13] = (ZBVertex){{-0.5, -0.5, 0.5},   {0, 1}};
    self.vertices[14] = (ZBVertex){{0.5, -0.5, -0.5},   {1, 0}};
    self.vertices[15] = (ZBVertex){{-0.5, -0.5, 0.5},   {0, 1}};
    self.vertices[16] = (ZBVertex){{0.5, -0.5, -0.5},   {1, 0}};
    self.vertices[17] = (ZBVertex){{-0.5, -0.5, -0.5},  {0, 0}};
    
    // 左面
    self.vertices[18] = (ZBVertex){{-0.5, 0.5, 0.5},    {1, 1}};
    self.vertices[19] = (ZBVertex){{-0.5, -0.5, 0.5},   {0, 1}};
    self.vertices[20] = (ZBVertex){{-0.5, 0.5, -0.5},   {1, 0}};
    self.vertices[21] = (ZBVertex){{-0.5, -0.5, 0.5},   {0, 1}};
    self.vertices[22] = (ZBVertex){{-0.5, 0.5, -0.5},   {1, 0}};
    self.vertices[23] = (ZBVertex){{-0.5, -0.5, -0.5},  {0, 0}};
    
    // 右面
    self.vertices[24] = (ZBVertex){{0.5, 0.5, 0.5},    {1, 1}};
    self.vertices[25] = (ZBVertex){{0.5, -0.5, 0.5},   {0, 1}};
    self.vertices[26] = (ZBVertex){{0.5, 0.5, -0.5},   {1, 0}};
    self.vertices[27] = (ZBVertex){{0.5, -0.5, 0.5},   {0, 1}};
    self.vertices[28] = (ZBVertex){{0.5, 0.5, -0.5},   {1, 0}};
    self.vertices[29] = (ZBVertex){{0.5, -0.5, -0.5},  {0, 0}};
    
    // 后面
    self.vertices[30] = (ZBVertex){{-0.5, 0.5, -0.5},   {0, 1}};
    self.vertices[31] = (ZBVertex){{-0.5, -0.5, -0.5},  {0, 0}};
    self.vertices[32] = (ZBVertex){{0.5, 0.5, -0.5},    {1, 1}};
    self.vertices[33] = (ZBVertex){{-0.5, -0.5, -0.5},  {0, 0}};
    self.vertices[34] = (ZBVertex){{0.5, 0.5, -0.5},    {1, 1}};
    self.vertices[35] = (ZBVertex){{0.5, -0.5, -0.5},   {1, 0}};
    
    // 开辟顶点缓存区
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(ZBVertex) * KCoordCount, self.vertices, GL_STATIC_DRAW);
    
    // 顶点数据
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(ZBVertex), NULL + offsetof(ZBVertex, positionCoord));
    
    // 纹理数据
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(ZBVertex), NULL + offsetof(ZBVertex, textureCoord));
    
}

- (void)addCADisplayLink {
    self.angle = 0;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(reDisplay)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

#pragma mark - GLKViewDelegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glEnable(GL_DEPTH_TEST);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self.baseEffect prepareToDraw];
    
    glDrawArrays(GL_TRIANGLES, 0, KCoordCount);
}

- (void)reDisplay {
    self.angle = (self.angle + 1) % 360;
    
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(self.angle), 0.3, 1, -0.7);
    [self.glkView display];
}

- (void)dealloc {
    if ([EAGLContext currentContext] == self.glkView.context) {
        [EAGLContext setCurrentContext:nil];
    }
    if (_vertices) {
        free(_vertices);
        _vertexBuffer = 0;
    }
    //displayLink 失效
    [self.displayLink invalidate];
}

@end
