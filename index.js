
import React, { Component } from 'react';
import PropTypes from 'prop-types';
import {
  requireNativeComponent,
  View,
  UIManager,
  findNodeHandle,
  ColorPropType
} from 'react-native';

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
      <RNSketchView {...this.props} onSaveSketch={this.onSaveSketch}/>
    );
  }

  clearSketch() {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      UIManager.getViewManagerConfig('RNSketchView').Commands.clearSketch,
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
  localSourceImagePath: PropTypes.string
};

let RNSketchView = requireNativeComponent('RNSketchView', SketchView, {
  nativeOnly: { onSaveSketch: true }
});

export default SketchView;
