import {HostComponent, ViewProps} from 'react-native';
import {
  BubblingEventHandler,
  Float,
  Int32,
} from 'react-native/Libraries/Types/CodegenTypes';
import codegenNativeCommands from 'react-native/Libraries/Utilities/codegenNativeCommands';
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
interface ICallbacks {
  value: Float;
}
export interface SvgaPlayerProps extends ViewProps {
  source: string;
  toFrame: Float;
  currentState: string;
  toPercentage: Float;
  loops?: Int32;
  clearsAfterStop?: boolean;
  onFinished?: BubblingEventHandler<{}>;
  onFrame?: BubblingEventHandler<ICallbacks>;
  onPercentage?: BubblingEventHandler<ICallbacks>;
}
type NativeType = HostComponent<SvgaPlayerProps>;
export interface NativeCommands {
  load: (viewRef: React.ElementRef<NativeType>, source: string) => void;
  startAnimation: (viewRef: React.ElementRef<NativeType>) => void;
  pauseAnimation: (viewRef: React.ElementRef<NativeType>) => void;
  stopAnimation: (viewRef: React.ElementRef<NativeType>) => void;
  // stepToFrame: (
  //   viewRef: React.ElementRef<NativeType>,
  //   toFrame: Float,
  //   andPlay: boolean,
  // ) => void;
  // stepToPercentage: (
  //   viewRef: React.ElementRef<NativeType>,
  //   toPercentage: Float,
  //   andPlay: boolean,
  // ) => void;
}

export const Commands: NativeCommands = codegenNativeCommands<NativeCommands>({
  supportedCommands: [
    'load',
    'startAnimation',
    'pauseAnimation',
    'stopAnimation',
    // 'stepToFrame',
    // 'stepToPercentage',
  ],
});

export default codegenNativeComponent<SvgaPlayerProps>(
  'SvgaPlayerView',
) as HostComponent<SvgaPlayerProps>;
