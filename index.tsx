// index.ts
import SvgaPlayer from './SvgaPlayer';

import React from 'react';
import {ViewProps} from 'react-native';

interface SVGAPlayerProps extends ViewProps {
  onFinished?: () => void;
  onFrame?: (value: number) => void;
  onPercentage?: (value: number) => void;
  source: string;
}
interface SVGAPlayerState {
  toFrame: number;
  currentState: string;
  toPercentage: number;
}
export default class RNSvgaPlayer extends React.Component<
  SVGAPlayerProps,
  SVGAPlayerState
> {
  private childRef: React.RefObject<RNSvgaPlayer>;

  constructor(props: Readonly<SVGAPlayerProps>) {
    super(props);
    this.state = {} as SVGAPlayerState;
    this.childRef = React.createRef();
  }
  load(source: string) {
    if (this.childRef.current) {
      this.childRef.current?.load(source);
    }
  }
  startAnimation() {
    if (this.childRef.current) {
      this.childRef.current?.startAnimation();
    }
  }
  pauseAnimation() {
    if (this.childRef.current) {
      this.childRef.current?.pauseAnimation();
    }
  }
  stopAnimation() {
    if (this.childRef.current) {
      this.childRef.current?.stopAnimation();
    }
  }
  stepToFrame(toFrame: number, andPlay: boolean) {
    this.setState(
      {
        currentState: andPlay === true ? 'play' : 'pause',
        toFrame: -1,
      },
      () => {
        this.setState({
          toFrame,
        });
      },
    );
  }
  stepToPercentage(toPercentage: number, andPlay: boolean) {
    this.setState(
      {
        currentState: andPlay === true ? 'play' : 'pause',
        toPercentage: -1,
      },
      () => {
          this.setState({
            toPercentage,
          });
      },
    );
  }
  componentWillUnmount() {
    this.stopAnimation();
  }
  render() {
    if (!this.props.source) {
      return null;
    }

    return <SvgaPlayer ref={this.childRef} {...this.props} {...this.state} />;
  }
}
