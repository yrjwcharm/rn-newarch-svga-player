#import <React/RCTViewComponentView.h>
#import <UIKit/UIKit.h>
#import <SVGAPlayer/SVGAPlayer.h>

#ifndef RNSvgaPlayerNativeComponent_h
#define RNSvgaPlayerNativeComponent_h

NS_ASSUME_NONNULL_BEGIN

@interface RCTSvgaPlayer : RCTViewComponentView <SVGAPlayerDelegate>

// Commands
- (void)startAnimation;
- (void)stopAnimation;

@end

NS_ASSUME_NONNULL_END

#endif /* RNSvgaPlayerNativeComponent_h */
