import type { HostComponent, ViewProps } from 'react-native';
import type {
  BubblingEventHandler,
  Double,
  Int32,
  WithDefault,
} from 'react-native/Libraries/Types/CodegenTypes';
import codegenNativeCommands from 'react-native/Libraries/Utilities/codegenNativeCommands';
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';

interface SvgaPlayerProps extends ViewProps {
  source: string;
  autoPlay?: boolean;
  loops?: Int32;
  clearsAfterStop?: boolean;
  align?: WithDefault<'top' | 'bottom' | 'center', 'center'>;
  // 事件回调
  onError?: BubblingEventHandler<{ error: string }>;
  onFinished?: BubblingEventHandler<{ finished: boolean }>;
  onLoaded?: BubblingEventHandler<{}>;
  onFrameChanged?: BubblingEventHandler<{ value: Double }>;
  onPercentageChanged?: BubblingEventHandler<{ value: Double }>;
}

export type ComponentType = HostComponent<SvgaPlayerProps>;

interface NativeCommands {
  startAnimation: (viewRef: React.ElementRef<ComponentType>) => void;
  stopAnimation: (viewRef: React.ElementRef<ComponentType>) => void;
  pauseAnimation: (viewRef: React.ElementRef<ComponentType>) => void;
  stepToFrame: (
    viewRef: React.ElementRef<ComponentType>,
    frame: Int32,
    andPlay: boolean
  ) => void;
  stepToPercentage: (
    viewRef: React.ElementRef<ComponentType>,
    percentage: Int32,
    andPlay: boolean
  ) => void;
  startAnimationWithRange: (
    viewRef: React.ElementRef<ComponentType>,
    location: Int32,
    length: Int32,
    reverse: boolean
  ) => void;
}

export const Commands: NativeCommands = codegenNativeCommands<NativeCommands>({
  supportedCommands: [
    'startAnimation',
    'pauseAnimation',
    'stopAnimation',
    'stepToFrame',
    'stepToPercentage',
    'startAnimationWithRange',
  ],
});

export default codegenNativeComponent<SvgaPlayerProps>('RNSvgaPlayer');
