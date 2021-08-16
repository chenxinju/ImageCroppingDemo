
#import <UIKit/UIKit.h>

@protocol CropImageDelegate <NSObject>

- (void)cropImageDidFinishedWithImage:(UIImage *)image;

@end

@interface CropImageController : UIViewController

@property (nonatomic, weak) id <CropImageDelegate> delegate;
//圆形裁剪，默认NO;
@property (nonatomic, assign) BOOL ovalClip;
@property (nonatomic, assign) BOOL isPush;
- (instancetype)initWithImage:(UIImage *)originalImage delegate:(id)delegate;

@property (nonatomic,copy)void (^cropImageDidFinishedWithImageBclock)(UIImage *image);
@end
