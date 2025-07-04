import React, {useRef, forwardRef} from 'react';
import SvgaPlayerView, {
  SvgaPlayerProps,
} from './specs/SvgaPlayerNativeComponent';
export type GeneratedSampleComponentRef = {
  load: (source: string) => void;
  startAnimation: () => void;
  pauseAnimation: () => void;
  stopAnimation: () => void;
  // stepToFrame: (toFrame: number, andPlay: boolean) => void;
  // stepToPercentage: (toPercentage: number, andPlay: boolean) => void;
};

interface ISvgaPlayerProps {
  style?: StyleProp<ViewStyle>;
  source: string;
  loops?: number;
  toFrame: number;
  currentState: string;
  toPercentage: number;
  onFinished?: () => void;
  onFrame?: (value: number) => void;
  onPercentage?: (value: number) => void;
}
import {
  findNodeHandle,
  HostComponent,
  StyleProp,
  UIManager,
  ViewStyle,
} from 'react-native';
export const SvgaPlayer = forwardRef<
  GeneratedSampleComponentRef,
  ISvgaPlayerProps
>((props, ref) => {
  const svgaPlayerRef = useRef<React.ComponentRef<
    HostComponent<SvgaPlayerProps>
  > | null>(null);
  React.useImperativeHandle(
    ref,
    () => ({
      load(source: string) {
        if (svgaPlayerRef?.current) {
          UIManager.dispatchViewManagerCommand(
            findNodeHandle(svgaPlayerRef.current),
            'load',
            [source],
          );
        }
      },
      startAnimation() {
        if (svgaPlayerRef?.current) {
          UIManager.dispatchViewManagerCommand(
            findNodeHandle(svgaPlayerRef.current),
            'startAnimation',
            [],
          );
        }
      },
      pauseAnimation() {
        if (svgaPlayerRef?.current) {
          UIManager.dispatchViewManagerCommand(
            findNodeHandle(svgaPlayerRef.current),
            'pauseAnimation',
            [],
          );
        }
      },
      stopAnimation() {
        if (svgaPlayerRef?.current) {
          UIManager.dispatchViewManagerCommand(
            findNodeHandle(svgaPlayerRef.current),
            'stopAnimation',
            [],
          );
        }
      },
      // stepToFrame(toFrame: number, andPlay: boolean) {
      //   if (svgaPlayerRef?.current) {
      //     UIManager.dispatchViewManagerCommand(
      //       findNodeHandle(svgaPlayerRef.current),
      //       'stepToFrame',
      //       [toFrame, andPlay],
      //     );
      //   }
      // },
      // stepToPercentage(toPercentage: number, andPlay: boolean) {
      //   if (svgaPlayerRef?.current) {
      //     UIManager.dispatchViewManagerCommand(
      //       findNodeHandle(svgaPlayerRef.current),
      //       'stepToPercentage',
      //       [toPercentage, andPlay],
      //     );
      //   }
      // },
    }),
    [],
  );
  return (
    <SvgaPlayerView
      style={props.style}
      ref={svgaPlayerRef}
      source={props.source}
      toFrame={props.toFrame}
      loops={props.loops}
      currentState={props.currentState}
      toPercentage={props.toPercentage}
      onFinished={() => {
        props.onFinished && props.onFinished();
      }}
      onFrame={e => {
        props.onFrame && props.onFrame(e.nativeEvent.value);
      }}
      onPercentage={e => {
        props.onPercentage && props.onPercentage(e.nativeEvent.value);
      }}
    />
  );
});
export default SvgaPlayer;
