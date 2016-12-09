#import <AssetsLibrary/AssetsLibrary.h>
#import <Cordova/CDV.h>
#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVInvokedUrlCommand.h>

#import "CameraPreview.h"
#define CDV_PHOTO_PREFIX @"silentshot_photo_"

@implementation CameraPreview
//static cameraIsReady = NO;

- (void) startCamera:(CDVInvokedUrlCommand*)command {
    //        [self.commandDelegate runInBackground:^{
    //                            sleep(3);
    //
    
    CDVPluginResult *pluginResult;
    
    if (self.sessionManager != nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Camera already started!"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    if (command.arguments.count > 3) {
        CGFloat x = (CGFloat)[command.arguments[0] floatValue] + self.webView.frame.origin.x;
        CGFloat y = (CGFloat)[command.arguments[1] floatValue] + self.webView.frame.origin.y;
        CGFloat width = (CGFloat)[command.arguments[2] floatValue];
        CGFloat height = (CGFloat)[command.arguments[3] floatValue];
        NSString *defaultCamera = command.arguments[4];
        BOOL tapToTakePicture = (BOOL)[command.arguments[5] boolValue];
        BOOL dragEnabled = (BOOL)[command.arguments[6] boolValue];
        BOOL toBack = (BOOL)[command.arguments[7] boolValue];
        CGFloat alpha  = (CGFloat)[command.arguments[8] floatValue];
        BOOL toGallery = (BOOL)[command.arguments[9] boolValue];
        CGFloat compression = ((CGFloat)[command.arguments[10] floatValue])/100.0;
        self.storeToGalery = toGallery;
        self.compression = compression;
        // sleep(3);
        // Create the session manager
        self.sessionManager = [[CameraSessionManager alloc] init];
        
        //render controller setup
        //            self.cameraRenderController = [[CameraRenderController alloc] init];
        self.cameraRenderController = [[CameraRenderController alloc] initWithWebView:self.webView];//  [[CameraRenderController alloc] init];
        self.cameraRenderController.dragEnabled = dragEnabled;
        self.cameraRenderController.tapToTakePicture = tapToTakePicture;
        self.cameraRenderController.sessionManager = self.sessionManager;
        self.cameraRenderController.view.frame = CGRectMake(x, y, width, height);
        self.cameraRenderController.delegate = self;
        
        [self.viewController addChildViewController:self.cameraRenderController];
        
        
        //                dispatch_async(dispatch_get_main_queue(), ^{
        //display the camera bellow the webview
        if (toBack) {
            //make transparent
            self.webView.opaque = NO;
            self.webView.backgroundColor = [UIColor clearColor];
            
            //                            self.webView.layer.zPosition = 4;
            //                            self.viewController.view.layer.zPosition = 1;
            //                            self.cameraRenderController.view.layer.zPosition = 4;
            
            [self.viewController.view insertSubview:self.cameraRenderController.view atIndex:0];
            //                        [self.viewController.view bringSubviewToFront:self.cameraRenderController.view];
            
        } else {
            self.cameraRenderController.view.alpha = alpha;
            
            [self.viewController.view addSubview:self.cameraRenderController.view];
        }
        //       });
        // Setup session
        
        self.sessionManager.delegate = self.cameraRenderController;
        [self.sessionManager setupSession:defaultCamera];
        
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid number of parameters"];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
    //            }];
}

- (void) stopCamera:(CDVInvokedUrlCommand*)command {
    NSLog(@"stopCamera");
    CDVPluginResult *pluginResult;
    
    if(self.sessionManager != nil) {
        [self.cameraRenderController.view removeFromSuperview];
        [self.cameraRenderController removeFromParentViewController];
        self.cameraRenderController = nil;
        
        [self.sessionManager.session stopRunning];
        self.sessionManager = nil;
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Camera not started"];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
- (void) focusCamera:(CDVInvokedUrlCommand*)command {
    CDVPluginResult *pluginResult;
    if (self.sessionManager != nil) {
        [self.sessionManager focusCamera];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Camera not started"];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    //                [[videoDeviceInput device] focusPointOfInterest];
    // TODO: Make camera focus.
    
    // if (self.cameraRenderController != nil) {
    //     [self.cameraRenderController.view setHidden:YES];
    // }
}
- (void) hideCamera:(CDVInvokedUrlCommand*)command {
    NSLog(@"hideCamera");
    CDVPluginResult *pluginResult;
    
    if (self.cameraRenderController != nil) {
        [self.cameraRenderController.view setHidden:YES];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Camera not started"];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) showCamera:(CDVInvokedUrlCommand*)command {
    NSLog(@"showCamera");
    CDVPluginResult *pluginResult;
    
    if (self.cameraRenderController != nil) {
        [self.cameraRenderController.view setHidden:NO];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Camera not started"];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) switchCamera:(CDVInvokedUrlCommand*)command {
    NSLog(@"switchCamera");
    CDVPluginResult *pluginResult;
    
    if (self.sessionManager != nil) {
        [self.sessionManager switchCamera];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Camera not started"];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) takePicture:(CDVInvokedUrlCommand*)command {
    NSLog(@"takePicture");
    CDVPluginResult *pluginResult;
    
    if (self.cameraRenderController != NULL) {
        CGFloat maxW = (CGFloat)[command.arguments[0] floatValue];
        CGFloat maxH = (CGFloat)[command.arguments[1] floatValue];
        [self invokeTakePicture:maxW withHeight:maxH];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Camera not started"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

-(void) setOnPictureTakenHandler:(CDVInvokedUrlCommand*)command {
    NSLog(@"setOnPictureTakenHandler");
    self.onPictureTakenHandlerId = command.callbackId;
}

-(void) setColorEffect:(CDVInvokedUrlCommand*)command {
    NSLog(@"setColorEffect");
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    NSString *filterName = command.arguments[0];
    
    if ([filterName isEqual: @"none"]) {
        dispatch_async(self.sessionManager.sessionQueue, ^{
            [self.sessionManager setCiFilter:nil];
        });
    } else if ([filterName isEqual: @"mono"]) {
        dispatch_async(self.sessionManager.sessionQueue, ^{
            CIFilter *filter = [CIFilter filterWithName:@"CIColorMonochrome"];
            [filter setDefaults];
            [self.sessionManager setCiFilter:filter];
        });
    } else if ([filterName isEqual: @"negative"]) {
        dispatch_async(self.sessionManager.sessionQueue, ^{
            CIFilter *filter = [CIFilter filterWithName:@"CIColorInvert"];
            [filter setDefaults];
            [self.sessionManager setCiFilter:filter];
        });
    } else if ([filterName isEqual: @"posterize"]) {
        dispatch_async(self.sessionManager.sessionQueue, ^{
            CIFilter *filter = [CIFilter filterWithName:@"CIColorPosterize"];
            [filter setDefaults];
            [self.sessionManager setCiFilter:filter];
        });
    } else if ([filterName isEqual: @"sepia"]) {
        dispatch_async(self.sessionManager.sessionQueue, ^{
            CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone"];
            [filter setDefaults];
            [self.sessionManager setCiFilter:filter];
        });
    } else if ([filterName isEqual: @"frame"]) {
        dispatch_async(self.sessionManager.sessionQueue, ^{
            CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectProcess"]; //CIPhotoEffectTransfer? CIPhotoEffectInstant?
            [filter setDefaults];
            [self.sessionManager setCiFilter:filter];
        });
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Filter not found"];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
- (void) invokeTakePicture {
    [self invokeTakePicture:0.0 withHeight:0.0];
}
+ (NSString *) applicationDocumentsDirectoryOld
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}
+ (NSString *)applicationDocumentsDirectory {
    return [[[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory
                                                    inDomains:NSUserDomainMask] lastObject].path stringByAppendingPathComponent:@"NoCloud"];
}

+ (NSString *)saveImage:(UIImage *)image withName:(NSString *)name withCompression:(CGFloat )compression{
    NSData *data = UIImageJPEGRepresentation(image, compression);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fullPath = [[CameraPreview applicationDocumentsDirectory] stringByAppendingPathComponent:name];
    [fileManager createFileAtPath:fullPath contents:data attributes:nil];
    
    return fullPath;
}

+ (UIImage *)normalizedImage:(UIImage *)image {
    if (image.imageOrientation == UIImageOrientationUp) return image;
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:(CGRect){0, 0, image.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

- (UIImage*)imageByScalingAndCroppingForSize:(UIImage*)anImage toSize:(CGSize)targetSize
{
    UIImage* sourceImage = anImage;
    UIImage* newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor; // scale to fit height
        } else {
            scaleFactor = heightFactor; // scale to fit width
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if (newImage == nil) {
        NSLog(@"could not scale image");
    }
    
    // pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage*)imageCorrectedForCaptureOrientation:(UIImage*)anImage
{
    float rotation_radians = 0;
    bool perpendicular = false;
    
    switch ([anImage imageOrientation]) {
        case UIImageOrientationUp :
        rotation_radians = 0.0;
        break;
        
        case UIImageOrientationDown:
        rotation_radians = M_PI; // don't be scared of radians, if you're reading this, you're good at math
        break;
        
        case UIImageOrientationRight:
        rotation_radians = M_PI_2;
        perpendicular = true;
        break;
        
        case UIImageOrientationLeft:
        rotation_radians = -M_PI_2;
        perpendicular = true;
        break;
        
        default:
        break;
    }
    
    UIGraphicsBeginImageContext(CGSizeMake(anImage.size.width, anImage.size.height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Rotate around the center point
    CGContextTranslateCTM(context, anImage.size.width / 2, anImage.size.height / 2);
    CGContextRotateCTM(context, rotation_radians);
    
    CGContextScaleCTM(context, 1.0, -1.0);
    float width = perpendicular ? anImage.size.height : anImage.size.width;
    float height = perpendicular ? anImage.size.width : anImage.size.height;
    CGContextDrawImage(context, CGRectMake(-width / 2, -height / 2, width, height), [anImage CGImage]);
    
    // Move the origin back since the rotation might've change it (if its 90 degrees)
    if (perpendicular) {
        CGContextTranslateCTM(context, -anImage.size.height / 2, -anImage.size.width / 2);
    }
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage*)imageByScalingNotCroppingForSize:(UIImage*)anImage toSize:(CGSize)frameSize
{
    UIImage* sourceImage = anImage;
    UIImage* newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = frameSize.width;
    CGFloat targetHeight = frameSize.height;
    CGFloat scaleFactor = 0.0;
    CGSize scaledSize = frameSize;
    
    if (CGSizeEqualToSize(imageSize, frameSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        // opposite comparison to imageByScalingAndCroppingForSize in order to contain the image within the given bounds
        if (widthFactor > heightFactor) {
            scaleFactor = heightFactor; // scale to fit height
        } else {
            scaleFactor = widthFactor; // scale to fit width
        }
        scaledSize = CGSizeMake(MIN(width * scaleFactor, targetWidth), MIN(height * scaleFactor, targetHeight));
    }
    
    UIGraphicsBeginImageContext(scaledSize); // this will resize
    
    [sourceImage drawInRect:CGRectMake(0, 0, scaledSize.width, scaledSize.height)];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if (newImage == nil) {
        NSLog(@"could not scale image");
    }
    
    // pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}


- (void) invokeTakePicture:(CGFloat) maxWidth withHeight:(CGFloat) maxHeight {
    AVCaptureConnection *connection = [self.sessionManager.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    [self.sessionManager.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef sampleBuffer, NSError *error) {
        NSLog(@"Done creating still image");
        
        if (error) {
            NSLog(@"%@", error);
        } else {
            
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            UIImage *capturedImage = [self imageCorrectedForCaptureOrientation:image];
            ///result!!!
            UIImage* scaledImage = nil;
            
            if ((self.cameraRenderController.view.frame.size.width > 0) && (self.cameraRenderController.view.frame.size.height > 0)) {
                
                scaledImage = [self imageByScalingNotCroppingForSize:capturedImage toSize:CGSizeMake(self.cameraRenderController.view.frame.size.width * 2, self.cameraRenderController.view.frame.size.height * 2)];
            }
            
            UIImage* returnedImage = (scaledImage == nil ? capturedImage : scaledImage);
            
            
            // Get the image data (blocking; around 1 second)
            NSData* data = UIImageJPEGRepresentation(returnedImage, self.compression);
            NSString* docsPath = [NSTemporaryDirectory()stringByStandardizingPath];
            NSError* err = nil;
            NSFileManager* fileMgr = [[NSFileManager alloc] init]; // recommended by apple (vs [NSFileManager defaultManager]) to be threadsafe
            // generate unique file name
            NSString* filePath;
            
            int i = 1;
            do {
                filePath = [NSString stringWithFormat:@"%@/%@%03d.%@", docsPath, CDV_PHOTO_PREFIX, i++, @"jpg"];
            } while ([fileMgr fileExistsAtPath:filePath]);
            
            if (![data writeToFile:filePath options:NSAtomicWrite error:&err]) {
                
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION messageAsString:[err localizedDescription]];
                [pluginResult setKeepCallbackAsBool:true];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:nil];
            } else {
                dispatch_group_t group = dispatch_group_create();
                dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    NSMutableArray *params = [[NSMutableArray alloc] init];
                    
                    [params addObject:filePath];
                    
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:params];
                    [pluginResult setKeepCallbackAsBool:true];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.onPictureTakenHandlerId];
                });
                
            }
            
            
            
        }
    }];
    
    
    
}
@end
