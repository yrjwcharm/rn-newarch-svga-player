import React, { forwardRef, useImperativeHandle, useRef } from 'react';
import type { ViewProps } from 'react-native';
import RNSvgaPlayerNative, {
  Commands,
  type ComponentType,
} from './src/specs/SvgaPlayerNativeComponent';

export interface SvgaErrorEvent {
  error: string;
}

export interface SvgaPlayerProps extends ViewProps {
  source?: string;
  /**
   * 是否自动播放，默认 true
   */
  autoPlay?: boolean;
  /**
   * 循环播放次数，默认 0（无限循环）
   */
  loops?: number;
  /**
   * 动画停止后是否清空画布，默认 true
   */
  clearsAfterStop?: boolean;
  /**
   * 内容对齐方式
   */
  align?: 'top' | 'bottom' | 'center';

  // 事件回调
  onError?: (event: SvgaErrorEvent) => void;
  onFinished?: () => void;
  onLoaded?: () => void;
}

export interface SvgaPlayerRef {
  /**
   * 从第0帧开始播放动画
   */
  startAnimation: () => void;
  /**
   * 停止动画，如果 clearsAfterStop 为 true 则清空画布
   */
  stopAnimation: () => void;
}

const RNSvgaPlayer = forwardRef<SvgaPlayerRef, SvgaPlayerProps>(
  (
    {
      autoPlay = true,
      loops = 0,
      clearsAfterStop = false,
      source,
      onError,
      onFinished,
      onLoaded,
      ...restProps
    },
    ref
  ) => {
    const nativeRef = useRef<React.ElementRef<ComponentType>>(null);

    useImperativeHandle(ref, () => ({
      startAnimation: () => {
        if (nativeRef.current) {
          Commands.startAnimation(nativeRef.current);
        }
      },
      stopAnimation: () => {
        if (nativeRef.current) {
          Commands.stopAnimation(nativeRef.current);
        }
      },
      // pauseAnimation: () => {
      //   if (nativeRef.current) {
      //     Commands.pauseAnimation(nativeRef.current);
      //   }
      // },
    }));

    return (
      <RNSvgaPlayerNative
        ref={nativeRef}
        source={source}
        autoPlay={autoPlay}
        loops={loops}
        clearsAfterStop={clearsAfterStop}
        onError={(error) => onError?.(error.nativeEvent)}
        onFinished={onFinished}
        onLoaded={onLoaded}
        {...restProps}
      />
    );
  }
);

RNSvgaPlayer.displayName = 'RNSvgaPlayer';

export default RNSvgaPlayer;
