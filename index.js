
import React, { Component } from 'react';
import PropTypes from 'prop-types';
import {
  requireNativeComponent,
  View,
  PanResponder,
  Alert,
  UIManager,
  findNodeHandle,
  ColorPropType
} from 'react-native';

// so events are not bubbled to the top elements
let viewResponder = PanResponder.create({
  onStartShouldSetPanResponder: (evt, gestureState) => true,
  onStartShouldSetPanResponderCapture: (evt, gestureState) => true,
  onMoveShouldSetPanResponder: (evt, gestureState) => true,
  onMoveShouldSetPanResponderCapture: (evt, gestureState) => true,
  onPanResponderTerminationRequest: (evt, gestureState) => {
    return true;
  },
  onShouldBlockNativeResponder: (evt, gestureState) => false,
  onPanResponderRelease: (evt, gestureState) => {
  },
  onPanResponderTerminate: (evt, gestureState) => {
  },
});

class SketchView extends Component {
  constructor(props) {
    super(props);
    this.onSaveSketch = this.onSaveSketch.bind(this);
    this.onDrawSketch = this.onDrawSketch.bind(this);
  }

  onSaveSketch(event) {

    if (!this.props.onSaveSketch) {
      return;
    }

    this.props.onSaveSketch({
      localFilePath: event.nativeEvent.localFilePath,
      imageWidth: event.nativeEvent.imageWidth,
      imageHeight: event.nativeEvent.imageHeight
    });
  }

  onDrawSketch(event){
    if(this.props.onDrawSketch){
      this.props.onDrawSketch({
        stackCount: event.nativeEvent.stackCount
      })
    }
  }

  render() {
    return (
      <RNSketchView
        {...this.props}
        onSaveSketch={this.onSaveSketch}
        onDrawSketch={this.onDrawSketch}
        {...viewResponder.panHandlers}
      />
    );
  }

  clearSketch() {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      'clearSketch',
      [],
    );
  }

  undoSketch() {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      'undoSketch',
      [],
    );
  }

  saveSketch(format, quality) {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      'saveSketch',
      [format || 'PNG', quality || 100],
    );
  }

  commitSketch() {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      'commitSketch',
      [],
    );
  }

  promptData() {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      'promptData',
      [],
    );
  }
}

SketchView.constants = {
  toolType: {
    pen: {
      id: 0,
      name: 'Pen',
    },
    eraser: {
      id: 1,
      name: 'Eraser'
    },
    rectangle: {
      id: 2,
      name: 'Rectangle'
    },
    arrow: {
      id: 3,
      name: 'Arrow'
    },
    text: {
      id: 4,
      name: 'Text'
    }
  }
};

SketchView.propTypes = {
  ...View.propTypes,
  selectedTool: PropTypes.number,
  toolColor: ColorPropType,
  localSourceImagePath: PropTypes.string,
  maxUndo: PropTypes.number,
  onDrawSketch: PropTypes.func
};

SketchView.defaultProps = {
  maxUndo: 10
}

let RNSketchView = requireNativeComponent('RNSketchView', SketchView, {
  nativeOnly: {
    onSaveSketch: true,
    onDrawSketch: true
  }
});

export default SketchView;
