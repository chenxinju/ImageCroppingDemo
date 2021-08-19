//
//  ViewController.m
//  ImageCroppingDemo
//
//  Created by iOS1 on 2021/8/16.
//

#import "ViewController.h"
#import "CXImageCropper.h"
#import "CXImagePicker.h"
#import "CXImagePickerVc.h"

@interface ViewController ()<CXImageCroppingDelegate>

@property(nonatomic,strong)UIImageView *imageView;
@property(nonatomic,strong) CXImageCropper * cropper;

@end


static const CGFloat kBottomHeight = 44;
static const CGFloat kBaseTag = 200;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.cropper= [[CXImageCropper alloc]init];

    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self setupUI];
}

-(void)setupUI{
    
    //按钮
    NSArray *titlesArray = @[@"圆形裁剪",@"矩形裁剪"];
    for (int i = 0; i<2; i++) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2*i, SCREEN_HEIGHT-kBottomHeight, SCREEN_WIDTH/2, kBottomHeight)];
        [button setTag:kBaseTag+i];
        [button setBackgroundColor: [UIColor colorWithRed:arc4random_uniform(256)/255.f green:arc4random_uniform(256)/255.f blue:arc4random_uniform(256)/255.f alpha:1.0f]];
        [button setTitle:titlesArray[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
    
    //图片显示区域
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width-300)/2, 100, 300, 300)];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    //[self.imageView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.imageView];
}

-(void)buttonClick:(UIButton *)sender{
    
    __weak typeof(self) weakSelf = self;
    
     //封装好的选择系统相册 内部压缩好图片
    [[CXImagePickerVc shareImagePicker]showActionSheetWithPresentViewController:self didFinishWithCompletion:^(UIImagePickerController *picker, NSDictionary *mediaInfo, UIImage *image, NSData *imageData) {
        [weakSelf jumpImageCropperWithImage:image buttonClick:sender];
    }];

    /*
    //直接选择相册
    [[CXImagePickerVc shareImagePicker] openPhotoLibraryWithPresentViewController:self didFinishWithCompletion:^(UIImagePickerController *picker, NSDictionary *mediaInfo, UIImage *image, NSData *imageData) {
            
        [weakSelf jumpImageCropperWithImage:image buttonClick:sender];
        
    } compressionQuality:0 allowsEditing:NO];
    
    
    
    //方式二 封装系统相册选择器
    [CXImagePicker showPickerMaxPixel:500 ImageBlock:^(UIImage *image, id picker) {

        [weakSelf jumpImageCropperWithImage:image buttonClick:sender];

    } dataBlock:^(NSData *data, id picker) {

    }];
     */
    
   
     
    
    
}

- (void)jumpImageCropperWithImage:(UIImage *)image buttonClick:(UIButton *)sender{
    
    self.cropper = [[CXImageCropper alloc]init];
    //设置代理
    self.cropper.delegate = self;
    //设置图片
    self.cropper.image = image;
    //设置自定义裁剪区域大小
    self.cropper.cropSize = CGSizeMake(self.view.frame.size.width - 60, (self.view.frame.size.width-60)*960/1280);
    self.cropper.isRound = sender.tag - kBaseTag == 0;
    self.cropper.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:self.cropper animated:YES completion:nil];
}

#pragma mark - Delegate
-(void)cxImageCroppingDidCancle:(CXImageCropper *)cropping {
    
    NSLog(@"取消");
}

-(void)cxImageCropping:(CXImageCropper *)cropping didCropImage:(UIImage *)image {
    
    [self.imageView setImage:image];
}

  
@end
