#import "RCTSvgaPlayer.h"

#import <react/renderer/components/RNSvgaPlayerSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNSvgaPlayerSpec/EventEmitters.h>
#import <react/renderer/components/RNSvgaPlayerSpec/Props.h>
#import <react/renderer/components/RNSvgaPlayerSpec/RCTComponentViewHelpers.h>

#import <SVGAPlayer/SVGAPlayer.h>
#import <SVGAPlayer/SVGAParser.h>
#import <SVGAPlayer/SVGAVideoEntity.h>
#import <CommonCrypto/CommonDigest.h>

using namespace facebook::react;

@interface RCTSvgaPlayer() <RCTRNSvgaPlayerViewProtocol, SVGAPlayerDelegate>

@end

@implementation RCTSvgaPlayer {
    SVGAPlayer * _svgaPlayer;
    NSString * _currentSource;
    BOOL _autoPlay;
    NSInteger _loops;
    BOOL _clearsAfterStop;
    SVGAVideoEntity * _currentVideoItem;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
    return concreteComponentDescriptorProvider<RNSvgaPlayerComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const RNSvgaPlayerProps>();
    _props = defaultProps;

    _svgaPlayer = [[SVGAPlayer alloc] init];
    _svgaPlayer.delegate = self;
    _svgaPlayer.loops = 0; // 默认无限循环
    _svgaPlayer.clearsAfterStop = YES; // 默认停止后清空画布
    _svgaPlayer.contentMode = UIViewContentModeScaleAspectFit;

    _autoPlay = NO; // 默认不自动播放，等待 props 更新
    _loops = 0; // 默认无限循环
    _clearsAfterStop = YES; // 默认停止后清空画布

    self.contentView = _svgaPlayer;
  }

  return self;
}

-(void)layoutSubviews
{
  [super layoutSubviews];
  _svgaPlayer.frame = self.bounds;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
    const auto &oldViewProps = *std::static_pointer_cast<RNSvgaPlayerProps const>(_props);
    const auto &newViewProps = *std::static_pointer_cast<RNSvgaPlayerProps const>(props);

    // 处理 autoPlay 属性 (包括初始设置)
    if (oldProps == nullptr || oldViewProps.autoPlay != newViewProps.autoPlay) {
        _autoPlay = newViewProps.autoPlay;
    }

    // 处理 loops 属性 (包括初始设置)
    if (oldProps == nullptr || oldViewProps.loops != newViewProps.loops) {
        _loops = newViewProps.loops;
        _svgaPlayer.loops = _loops;
    }

    // 处理 clearsAfterStop 属性 (包括初始设置)
    if (oldProps == nullptr || oldViewProps.clearsAfterStop != newViewProps.clearsAfterStop) {
        _clearsAfterStop = newViewProps.clearsAfterStop;
        _svgaPlayer.clearsAfterStop = _clearsAfterStop;
    }

    // 处理 align 属性 (包括初始设置)
    if (oldProps == nullptr || oldViewProps.align != newViewProps.align) {
        [self updateContentModeWithAlign:newViewProps.align];
    }

    // 处理 source 属性 (包括初始设置)
    if (oldProps == nullptr || oldViewProps.source != newViewProps.source) {
        NSString *newSource = newViewProps.source.empty() ? nil : [[NSString alloc] initWithUTF8String:newViewProps.source.c_str()];
        if (newSource && ![newSource isEqualToString:_currentSource]) {
            _currentSource = newSource;
            [self loadSVGAFromSource:newSource];
        } else if (newSource == nil && _currentSource != nil) {
            // 清空源 - 彻底清理
            _currentSource = nil;
            [self cleanup];
            // 显式地清空画布
            if (_svgaPlayer) {
                [_svgaPlayer clear];
            }
        }
    }

    [super updateProps:props oldProps:oldProps];
}

Class<RCTComponentViewProtocol> SvgaPlayerViewCls(void)
{
    return RCTSvgaPlayer.class;
}

// 辅助方法：根据 align 属性设置 contentMode
- (void)updateContentModeWithAlign:(RNSvgaPlayerAlign)align
{
    UIViewContentMode contentMode;

    // 根据 align 枚举值设置对应的 contentMode
    if (align == RNSvgaPlayerAlign::Top) {
        contentMode = UIViewContentModeTop;
    } else if (align == RNSvgaPlayerAlign::Bottom) {
        contentMode = UIViewContentModeBottom;
    } else { // Center 或默认值
        contentMode = UIViewContentModeScaleAspectFit;
    }

    _svgaPlayer.contentMode = contentMode;
}

// 辅助方法：发送事件
- (void)sendErrorEvent:(NSString *)errorMessage
{
    // 清空当前的 VideoItem 和画布
    [_svgaPlayer stopAnimation];
    [_svgaPlayer setVideoItem:nil];
    [_svgaPlayer clear];
    _currentVideoItem = nil;

    if (_eventEmitter != nullptr) {
        std::dynamic_pointer_cast<const facebook::react::RNSvgaPlayerEventEmitter>(_eventEmitter)
            ->onError(facebook::react::RNSvgaPlayerEventEmitter::OnError{
                .error = std::string([errorMessage UTF8String])
            });
    }
}

- (void)sendLoadedEvent
{
    if (_eventEmitter != nullptr) {
        std::dynamic_pointer_cast<const facebook::react::RNSvgaPlayerEventEmitter>(_eventEmitter)
            ->onLoaded(facebook::react::RNSvgaPlayerEventEmitter::OnLoaded{});
    }
}

// 辅助方法：处理文件路径
- (NSString *)resolveFilePath:(NSString *)source
{
    if (!source || source.length == 0) {
        return nil;
    }

    // 如果已经是完整的 file:// URL，直接返回
    if ([source hasPrefix:@"file://"]) {
        return source;
    }

    // 如果是绝对路径，转换为 file:// URL
    if ([source hasPrefix:@"/"]) {
        return [NSString stringWithFormat:@"file://%@", source];
    }

    // 如果是相对路径，尝试在文档目录中查找
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if (documentPaths.count > 0) {
        NSString *documentsDirectory = documentPaths[0];
        NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:source];
        return [NSString stringWithFormat:@"file://%@", fullPath];
    }

    return nil;
}

// 辅助方法：生成缓存键
- (NSString *)generateCacheKeyForFileURL:(NSURL *)fileURL
{
    // 使用文件的绝对路径作为缓存键的基础
    NSString *absolutePath = fileURL.absoluteString;

    // 简单的 MD5 哈希生成（类似 SVGAParser 内部实现）
    const char *cstr = [absolutePath UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, (CC_LONG)strlen(cstr), result);

    NSString *cacheKey = [NSString stringWithFormat:
                         @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                         result[0], result[1], result[2], result[3],
                         result[4], result[5], result[6], result[7],
                         result[8], result[9], result[10], result[11],
                         result[12], result[13], result[14], result[15]];

    return cacheKey;
}

// SVGA 播放器方法
- (void)loadSVGAFromSource:(NSString *)source
{
    if (!source || source.length == 0) {
        return;
    }

    SVGAParser *parser = [[SVGAParser alloc] init];

    // 判断文件类型并加载（与 Android 端保持一致）
    if ([source hasPrefix:@"http://"] || [source hasPrefix:@"https://"]) {
        // 远程 URL
        [self loadSVGAFromURL:source withParser:parser];
    } else if ([source hasPrefix:@"file://"] || [source hasPrefix:@"/"] || [source containsString:@"/"]) {
        // file:// 协议的本地文件、绝对路径或包含路径分隔符的相对路径
        NSString *resolvedPath = [self resolveFilePath:source];
        if (resolvedPath) {
            [self loadSVGAFromFileURL:resolvedPath withParser:parser];
        } else {
            [self sendErrorEvent:[NSString stringWithFormat:@"Could not resolve file path: %@", source]];
        }
    } else {
        // Assets 文件（默认情况）
        [self loadSVGAFromBundle:source withParser:parser];
    }
}

- (void)loadSVGAFromURL:(NSString *)urlString withParser:(SVGAParser *)parser
{
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        [self sendErrorEvent:[NSString stringWithFormat:@"Invalid URL: %@", urlString]];
        return;
    }

    [parser parseWithURL:url completionBlock:^(SVGAVideoEntity * _Nullable videoItem) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (videoItem) {
                self->_currentVideoItem = videoItem;

                // 触发 onLoaded 事件
                [self sendLoadedEvent];

                // 确保delegate被正确设置
                self->_svgaPlayer.delegate = self;
                [self->_svgaPlayer setVideoItem:videoItem];

                if (self->_autoPlay) {
                    [self->_svgaPlayer startAnimation];
                }
            } else {
                [self sendErrorEvent:@"Failed to parse SVGA from URL"];
            }
        });
    } failureBlock:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self sendErrorEvent:[NSString stringWithFormat:@"Failed to load SVGA from URL: %@", error.localizedDescription]];
        });
    }];
}

- (void)loadSVGAFromFileURL:(NSString *)fileURLString withParser:(SVGAParser *)parser
{
    NSURL *fileURL = [NSURL URLWithString:fileURLString];
    if (!fileURL) {
        [self sendErrorEvent:[NSString stringWithFormat:@"Invalid file URL: %@", fileURLString]];
        return;
    }

    // 直接读取文件数据并使用 parseWithData 解析
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *readError;
        NSData *fileData = [NSData dataWithContentsOfURL:fileURL options:0 error:&readError];

        if (fileData && readError == nil) {
            // 生成缓存键，用于 SVGAParser 的缓存机制
            NSString *cacheKey = [self generateCacheKeyForFileURL:fileURL];

            // 使用 parseWithData 方法直接解析二进制数据
            [parser parseWithData:fileData
                         cacheKey:cacheKey
                  completionBlock:^(SVGAVideoEntity * _Nullable videoItem) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (videoItem) {
                        self->_currentVideoItem = videoItem;

                        // 触发 onLoaded 事件
                        [self sendLoadedEvent];

                        // 确保delegate被正确设置
                        self->_svgaPlayer.delegate = self;
                        [self->_svgaPlayer setVideoItem:videoItem];

                        if (self->_autoPlay) {
                            [self->_svgaPlayer startAnimation];
                        }
                    } else {
                        [self sendErrorEvent:@"Failed to parse SVGA data"];
                    }
                });
            } failureBlock:^(NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *errorMsg = [NSString stringWithFormat:@"Failed to parse SVGA data from '%@': %@ (Code: %ld)",
                                         fileURL.absoluteString,
                                         error ? error.localizedDescription : @"Unknown error",
                                         error ? (long)error.code : -1];
                    [self sendErrorEvent:errorMsg];
                });
            }];
        } else {
            // 文件读取失败
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *errorMsg = [NSString stringWithFormat:@"Failed to read SVGA file '%@': %@ (Code: %ld)",
                                     fileURL.absoluteString,
                                     readError ? readError.localizedDescription : @"Unknown read error",
                                     readError ? (long)readError.code : -1];
                [self sendErrorEvent:errorMsg];
            });
        }
    });
}

- (void)loadSVGAFromBundle:(NSString *)fileName withParser:(SVGAParser *)parser
{
    // 去掉文件扩展名
    NSString *fileNameWithoutExtension = [fileName stringByDeletingPathExtension];

    // 首先尝试在主 bundle 中查找
    [parser parseWithNamed:fileNameWithoutExtension inBundle:nil completionBlock:^(SVGAVideoEntity * _Nullable videoItem) {
      dispatch_async(dispatch_get_main_queue(), ^{
        if (videoItem) {
          self->_currentVideoItem = videoItem;

          // 触发 onLoaded 事件
          [self sendLoadedEvent];

          // 确保delegate被正确设置
          self->_svgaPlayer.delegate = self;
          [self->_svgaPlayer setVideoItem:videoItem];

          if (self->_autoPlay) {
            [self->_svgaPlayer startAnimation];
          }
        } else {
          [self sendErrorEvent:[NSString stringWithFormat:@"Failed to parse SVGA from bundle: %@", fileName]];
        }
      });
    } failureBlock:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 如果在 bundle 中找不到，尝试作为文档目录中的文件
            NSString *documentsPath = [self resolveFilePath:fileName];
            if (documentsPath && ![documentsPath isEqualToString:fileName]) {
                [self loadSVGAFromFileURL:documentsPath withParser:[[SVGAParser alloc] init]];
            } else {
                [self sendErrorEvent:[NSString stringWithFormat:@"Failed to load SVGA from bundle '%@': %@ (Code: %ld)",
                                     fileName, error.localizedDescription, (long)error.code]];
            }
        });
    }];
}

// Command methods
- (void)startAnimation
{
    [_svgaPlayer startAnimation];
}

- (void)stopAnimation
{
    [_svgaPlayer stopAnimation];
}

// 处理来自 JavaScript 的命令调用
- (void)handleCommand:(const NSString *)commandName args:(const NSArray *)args
{
    if ([commandName isEqualToString:@"startAnimation"]) {
        [self startAnimation];
    } else if ([commandName isEqualToString:@"stopAnimation"]) {
        [self stopAnimation];
    }
}

// SVGAPlayerDelegate methods
- (void)svgaPlayerDidFinishedAnimation:(SVGAPlayer *)player
{
    // 检查播放器是否还有效
    if (!_svgaPlayer || player != _svgaPlayer) {
        return;
    }

    // 检查事件发送器是否还有效
    if (_eventEmitter == nullptr) {
        return;
    }

    std::dynamic_pointer_cast<const facebook::react::RNSvgaPlayerEventEmitter>(_eventEmitter)
        ->onFinished(facebook::react::RNSvgaPlayerEventEmitter::OnFinished{
            .finished = true
        });
}

// React Native Fabric 生命周期方法
- (void)prepareForRecycle
{
    [super prepareForRecycle];

    // 组件即将被回收时清理资源
    [self cleanup];
}

// 组件销毁时调用
- (void)dealloc
{
    // 组件销毁时确保资源被彻底清理
    [self finalCleanup];
}

// 当视图从父视图移除时调用
- (void)removeFromSuperview
{
    // 从父视图移除时清理资源
    [self cleanup];
    [super removeFromSuperview];
}

// 当视图被标记为即将移除时调用
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    // 如果新的父视图是 nil，说明视图即将被移除
    if (newSuperview == nil) {
        [self cleanup];
    }
    [super willMoveToSuperview:newSuperview];
}

// 常规清理方法（保持视图结构，只清理动画状态）
- (void)cleanup
{
    // 停止动画并清理所有资源
    if (_svgaPlayer) {
        [_svgaPlayer stopAnimation];
        [_svgaPlayer setVideoItem:nil];
        [_svgaPlayer clear];

        // 注意：不设置 delegate = nil，这样动画完成事件仍能正常回调
        // delegate 只在 finalCleanup (dealloc) 时设置为 nil

        // 注意：不设置 _svgaPlayer = nil，因为它是 contentView
        // 只是停止动画和清理内容，但保持视图结构
    }

    // 清理其他资源
    _currentVideoItem = nil;
    _currentSource = nil;
}

// 最终清理方法（用于 dealloc，完全释放资源）
- (void)finalCleanup
{
    // 先调用常规清理
    if (_svgaPlayer) {
        [_svgaPlayer stopAnimation];
        [_svgaPlayer setVideoItem:nil];
        [_svgaPlayer clear];
        _svgaPlayer.delegate = nil;

        // 从视图层次结构中移除
        if (_svgaPlayer.superview) {
            [_svgaPlayer removeFromSuperview];
        }

        // 在 dealloc 时可以设置为 nil
        _svgaPlayer = nil;
    }

    // 清理其他资源
    _currentVideoItem = nil;
    _currentSource = nil;
}

@end
