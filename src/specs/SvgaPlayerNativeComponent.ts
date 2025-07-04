import type {HostComponent, ViewProps} from 'react-native';
import type {
  BubblingEventHandler,
  Int32,
  WithDefault,
} from 'react-native/Libraries/Types/CodegenTypes';
import codegenNativeCommands from 'react-native/Libraries/Utilities/codegenNativeCommands';
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';

interface NativeProps extends ViewProps {
  source?: string;
  autoPlay?: boolean;
  loops?: Int32;
  clearsAfterStop?: boolean;
  align?: WithDefault<'top' | 'bottom' | 'center', 'center'>;

  // 事件回调
  onError?: BubblingEventHandler<{error: string}>;
  onFinished?: BubblingEventHandler<{finished: boolean}>;
  onLoaded?: BubblingEventHandler<{}>;
}

export type ComponentType = HostComponent<NativeProps>;

interface NativeCommands {
  startAnimation: (viewRef: React.ElementRef<ComponentType>) => void;
  // pauseAnimation: (viewRef: React.ElementRef<ComponentType>) => void;
  stopAnimation: (viewRef: React.ElementRef<ComponentType>) => void;
}

export const Commands: NativeCommands = codegenNativeCommands<NativeCommands>({
  supportedCommands: ['startAnimation', 'stopAnimation'],
});

export default codegenNativeComponent<NativeProps>('RNSvgaPlayer');
