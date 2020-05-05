
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

  render() {
    return (
      <RNSketchView {...this.props} onSaveSketch={this.onSaveSketch} {...viewResponder.panHandlers}/>
    );
  }

  clearSketch() {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      UIManager.getViewManagerConfig('RNSketchView').Commands.clearSketch,
      [],
    );
  }

  undoSketch() {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      UIManager.getViewManagerConfig('RNSketchView').Commands.undoSketch,
      [],
    );
  }

  saveSketch(format, quality) {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      UIManager.getViewManagerConfig('RNSketchView').Commands.saveSketch,
      [format || 'PNG', quality || 100],
    );
  }

  changeTool(toolId) {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      UIManager.getViewManagerConfig('RNSketchView').changeTool,
      [toolId],
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
    }
  }
};

SketchView.propTypes = {
  ...View.propTypes,
  selectedTool: PropTypes.number,
  toolColor: ColorPropType,
  localSourceImagePath: PropTypes.string,
  maxUndo: PropTypes.number
};

SketchView.defaultProps = {
  maxUndo: 10
}

let RNSketchView = requireNativeComponent('RNSketchView', SketchView, {
  nativeOnly: { onSaveSketch: true }
});

export default SketchView;
