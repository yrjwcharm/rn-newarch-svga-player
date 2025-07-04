

#import "RCTSvgaPlayer.h"

#import <React/RCTFabricComponentsPlugins.h>
#import <react/renderer/components/RTNSvgaPlayerSpec/ComponentDescriptors.h>
#import <react/renderer/components/RTNSvgaPlayerSpec/EventEmitters.h>
#import <react/renderer/components/RTNSvgaPlayerSpec/Props.h>
#import <react/renderer/components/RTNSvgaPlayerSpec/RCTComponentViewHelpers.h>

#import "SVGAPlayer.h"
#import "SVGAParser.h"

using namespace facebook::react;

@interface RCTSvgaPlayer()  <RCTSvgaPlayerViewViewProtocol,SVGAPlayerDelegate>
@end


@implementation RCTSvgaPlayer{
  SVGAPlayer *_aPlayer;
  NSString *_currentState;
}
  

//-(instancetype)init{
//   if(self = [super init]) {
//     _aPlayer = [[SVGAPlayer alloc] init];
//     _aPlayer.delegate = self;
//     // _aPlayer.loops = 1;
//     // _aPlayer.clearsAfterStop = YES;
//     _aPlayer.clipsToBounds = NO;
//     _aPlayer.contentMode = UIViewContentModeScaleAspectFit;
//     [self addSubview:_aPlayer];
//   }
//   return self;
// }
 - (instancetype)initWithFrame:(CGRect)frame
 {
     if (self = [super initWithFrame:frame]) {
         static const auto defaultProps = std::make_shared<const SvgaPlayerViewProps>();
         _props = defaultProps;
       _aPlayer = [[SVGAPlayer alloc] init];
       _aPlayer.delegate = self;
       // _aPlayer.loops = 1;
       // _aPlayer.clearsAfterStop = YES;
       _aPlayer.clipsToBounds = NO;
       _aPlayer.contentMode = UIViewContentModeScaleAspectFit;
       [self addSubview:_aPlayer];
     }
     return self;
 }

-(void)layoutSubviews
{
  [super layoutSubviews];
  _aPlayer.frame = self.bounds;
}

-(void)updateProps:(const facebook::react::Props::Shared &)props oldProps:(const facebook::react::Props::Shared &)oldProps{
  const auto &oldViewProps = *std::static_pointer_cast<SvgaPlayerViewProps const>(_props);
    const auto &newViewProps = *std::static_pointer_cast<SvgaPlayerViewProps const>(props);

  if (oldViewProps.source != newViewProps.source) {
     NSString *urlString = [NSString stringWithCString:newViewProps.source.c_str() encoding:NSUTF8StringEncoding];
    [self loadWithSource:urlString];
  }
  if(oldViewProps.currentState!=newViewProps.currentState){
    NSString *currentState = [NSString stringWithCString:newViewProps.currentState.c_str() encoding:NSUTF8StringEncoding];
    _currentState = currentState;
    
    if ([currentState isEqualToString:@"start"]) {
               [_aPlayer startAnimation];
           } 
           
           else if ([currentState isEqualToString:@"pause"]) {
             
               [_aPlayer pauseAnimation];
           } else if ([currentState isEqualToString:@"stop"]) {
               [_aPlayer stopAnimation];
           } else if ([currentState isEqualToString:@"clear"]) {
               [_aPlayer stopAnimation];
               [_aPlayer clear];
           }
  }
  if(oldViewProps.loops!=newViewProps.loops){
    _aPlayer.loops = newViewProps.loops;
  }
    
  if(newViewProps.toFrame>0){

    float toFrame = newViewProps.toFrame;
    if (toFrame < 0) {
           return;
       }
       [_aPlayer stepToFrame:toFrame andPlay:[_currentState isEqualToString:@"play"]];
  }
  if(newViewProps.toPercentage>0){
    float toPercent = newViewProps.toPercentage;
    if (toPercent < 0) {
           return;
       }
       [_aPlayer stepToPercentage:toPercent  andPlay:[_currentState isEqualToString:@"play"]];
  }
  [super updateProps:props oldProps:oldProps];
}
  
  - (void)loadWithSource:(NSString *)source {
      SVGAParser *parser = [[SVGAParser alloc] init];
      if ([source hasPrefix:@"http"] || [source hasPrefix:@"https"]) {
          [parser parseWithURL:[NSURL URLWithString:source]
               completionBlock:^(SVGAVideoEntity *_Nullable videoItem) {
                 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                   [self->_aPlayer setVideoItem:videoItem];
                   [self->_aPlayer startAnimation];
                 }];
               }
                  failureBlock:nil];
      } else {
          NSString *localPath = [[NSBundle mainBundle] pathForResource:source ofType:@"svga"];
          if (localPath != nil) {
              [parser parseWithData:[NSData dataWithContentsOfFile:localPath]
                           cacheKey:source
                    completionBlock:^(SVGAVideoEntity *_Nonnull videoItem) {
                      [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self->_aPlayer setVideoItem:videoItem];
                        [self->_aPlayer startAnimation];
                      }];
                    }
                       failureBlock:nil];
          }
      }
  }
  
  - (void)load:(nonnull NSString *)source {
      [self loadWithSource:source];
  
  }
  
  - (void)pauseAnimation {
    [_aPlayer pauseAnimation];
    
  }
  
  - (void)startAnimation {
    [_aPlayer startAnimation];
  }
  
  - (void)stopAnimation {
    [_aPlayer stopAnimation];
  }
// Event emitter convenience method
- (const SvgaPlayerViewEventEmitter &)eventEmitter
{
  return static_cast<const SvgaPlayerViewEventEmitter &>(*_eventEmitter);
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<SvgaPlayerViewComponentDescriptor>();
}

  - (void)handleCommand:(nonnull const NSString *)commandName args:(nonnull const NSArray *)args {
    if([commandName isEqualToString:@"load"]){
      [self load:args[0]];
    }else if([commandName isEqualToString:@"startAnimation"]){
      [self startAnimation];
    }else if([commandName isEqualToString:@"pauseAnimation"]){
      [self pauseAnimation];
    }else if([commandName isEqualToString:@"stopAnimation"]){
      [self stopAnimation];
    }
  }
- (void)svgaPlayerDidFinishedAnimation:(SVGAPlayer *)player {
//    if (_aPlayer) {
//      SvgaPlayerViewEventEmitter::OnFinished result = SvgaPlayerViewEventEmitter::OnFinished{SvgaPlayerViewEventEmitter::OnFinished()};
//      self.eventEmitter.onFinished((result));
//    }
 if (_eventEmitter != nullptr) {
  std::dynamic_pointer_cast<const SvgaPlayerViewEventEmitter>(_eventEmitter)
  ->onFinished(SvgaPlayerViewEventEmitter::OnFinished{});
 }
}

-(void)prepareForRecycle{
  [super prepareForRecycle];

}
- (void)svgaPlayerDidAnimatedToFrame:(NSInteger)frame {
//    if (_aPlayer) {
//      NSLog(@"frame获取值....%ld",frame);
//      SvgaPlayerViewEventEmitter::OnFrame result = SvgaPlayerViewEventEmitter::OnFrame{SvgaPlayerViewEventEmitter::OnFrame( frame )};
//        self.eventEmitter.onFrame(result);
//    }
 if (_eventEmitter != nullptr) {
  std::dynamic_pointer_cast<const SvgaPlayerViewEventEmitter>(_eventEmitter)
  ->onFrame(SvgaPlayerViewEventEmitter::OnFrame{.value=(float)frame});
 }
}

- (void)svgaPlayerDidAnimatedToPercentage:(CGFloat)percentage {
//    if (_aPlayer) {
//      SvgaPlayerViewEventEmitter::OnPercentage result = SvgaPlayerViewEventEmitter::OnPercentage{SvgaPlayerViewEventEmitter::OnPercentage( percentage )};
//        self.eventEmitter.onPercentage(result);
//
//    }
 if (_eventEmitter != nullptr) {
  std::dynamic_pointer_cast<const SvgaPlayerViewEventEmitter>(_eventEmitter)
  ->onPercentage(SvgaPlayerViewEventEmitter::OnPercentage{.value=(float)percentage});
 }
}
// 当视图从父视图移除时调用
- (void)removeFromSuperview
{
    // 从父视图移除时清理资源
    [self clean];
    [super removeFromSuperview];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview == nil) {
        [self clean];
    }
    [super willMoveToSuperview:newSuperview];
}
- (void)clean
{
    if (_aPlayer) {
        [_aPlayer stopAnimation];
        [_aPlayer setVideoItem:nil];
        [_aPlayer clear];
    }
}
- (void)dealloc {
    [self clean];
    _aPlayer.delegate = nil;
    _aPlayer = nil;
}

@end


Class<RCTComponentViewProtocol> SvgaPlayerViewCls(void)
{
   return RCTSvgaPlayer.class;
}

