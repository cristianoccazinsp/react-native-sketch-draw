
package com.rnsketchview;

import android.graphics.Color;
import androidx.annotation.NonNull;

import com.facebook.infer.annotation.Assertions;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.uimanager.events.RCTEventEmitter;

import java.io.IOException;
import java.util.Locale;
import java.util.Map;

import javax.annotation.Nullable;

public class RNSketchViewManager extends SimpleViewManager<SketchViewContainer> {

  private static final String RN_PACKAGE = "RNSketchView";

  private static final String PROPS_TOOL_COLOR = "toolColor";

  private static final String PROPS_SELECTED_TOOL = "selectedTool";
  private static final String PROPS_MAX_UNDO = "maxUndo";
  private static final String PROPS_LOCAL_SOURCE_IMAGE_PATH  = "localSourceImagePath";

  public static final String EVENT_ON_SAVE_SKETCH = "onSaveSketch";
  public static final String EVENT_ON_DRAW_SKETCH = "onDrawSketch";


  @Override
  public String getName() {
    return RN_PACKAGE;
  }

  @Override
  protected SketchViewContainer createViewInstance(ThemedReactContext reactContext) {
    return new SketchViewContainer(reactContext);
  }

  @ReactProp(name = PROPS_SELECTED_TOOL)
  public void setSelectedTool(SketchViewContainer viewContainer, @NonNull Integer toolId) {
    viewContainer.sketchView.setToolType(toolId);
  }

  @ReactProp(name = PROPS_MAX_UNDO)
  public void setMaxUndo(SketchViewContainer viewContainer, @NonNull Integer max) {
    viewContainer.sketchView.setMaxUndo(max);
  }

  @ReactProp(name = PROPS_TOOL_COLOR, defaultInt = Color.BLACK, customType = "Color")
  public void setToolColor(SketchViewContainer viewContainer, @NonNull Integer color) {
    viewContainer.sketchView.setToolColor(color);
  }

  @ReactProp(name = PROPS_LOCAL_SOURCE_IMAGE_PATH)
  public void setLocalSourceImagePath(SketchViewContainer viewContainer, @NonNull String localSourceImagePath) {
    viewContainer.openSketchFile(localSourceImagePath);
  }

  @Override
  public void receiveCommand(SketchViewContainer root, String commandId, @Nullable ReadableArray args) {
    Assertions.assertNotNull(root);

    switch (commandId) {
      case "clearSketch":
        root.sketchView.clear();
        return;
      case "undoSketch":
        root.sketchView.undo();
        return;
      case "changeTool":
        Assertions.assertNotNull(args);
        int toolId = args.getInt(0);
        root.sketchView.setToolType(toolId);
        return;
      case "saveSketch":
        try {
          SketchFile sketchFile = root.saveToLocalCache(args.getString(0), args.getInt(1));
          onSaveSketch(root, sketchFile);
          return;
        } catch (IOException e) {
          e.printStackTrace();
        }
      case "commitSketch":
        root.sketchView.commit();
        return;
      case "promptData":
        root.sketchView.promptData();
        return;
      default:
        throw new IllegalArgumentException(String.format(Locale.ENGLISH, "Unsupported command %s.", commandId));
    }
  }

  private void onSaveSketch(SketchViewContainer root, SketchFile sketchFile) {
    WritableMap event = Arguments.createMap();
    event.putString("localFilePath", sketchFile.localFilePath);
    event.putInt("imageWidth", sketchFile.width);
    event.putInt("imageHeight", sketchFile.height);

    ReactContext reactContext = (ReactContext) root.getContext();

    reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
      root.getId(),
      EVENT_ON_SAVE_SKETCH,
      event
    );
  }

  @Override
  public @Nullable Map<String, Object> getExportedCustomDirectEventTypeConstants() {
    MapBuilder.Builder<String, Object> builder = MapBuilder.builder();

    builder.put(EVENT_ON_SAVE_SKETCH, MapBuilder.of("registrationName", EVENT_ON_SAVE_SKETCH));
    builder.put(EVENT_ON_DRAW_SKETCH, MapBuilder.of("registrationName", EVENT_ON_DRAW_SKETCH));

    return builder.build();
  }

  // if we ever need multiple events
  // @Override
  // @Nullable
  // public Map<String, Object> getExportedCustomDirectEventTypeConstants() {
  //   MapBuilder.Builder<String, Object> builder = MapBuilder.builder();
  //   for (Events event : Events.values()) {
  //     builder.put(event.toString(), MapBuilder.of("registrationName", event.toString()));
  //   }
  //   return builder.build();
  // }


}
