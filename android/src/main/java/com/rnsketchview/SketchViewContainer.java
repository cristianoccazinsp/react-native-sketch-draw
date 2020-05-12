package com.rnsketchview;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.widget.LinearLayout;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.events.RCTEventEmitter;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.UUID;



public class SketchViewContainer extends LinearLayout {

    public SketchView sketchView;

    public SketchViewContainer(Context context) {
        super(context);
        sketchView = new SketchView(context, this);
        addView(sketchView);
    }

    public SketchFile saveToLocalCache(String format, int quality) throws IOException {

        Bitmap viewBitmap = Bitmap.createBitmap(sketchView.getWidth(), sketchView.getHeight(), Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(viewBitmap);
        draw(canvas);

        File cacheFile;
        if(format.equals("PNG")){
            cacheFile = File.createTempFile("sketch_", UUID.randomUUID().toString() + ".png");
            FileOutputStream imageOutput = new FileOutputStream(cacheFile);
            viewBitmap.compress(Bitmap.CompressFormat.PNG, quality, imageOutput);
        }
        else{
            cacheFile = File.createTempFile("sketch_", UUID.randomUUID().toString() + ".jpg");
            FileOutputStream imageOutput = new FileOutputStream(cacheFile);
            viewBitmap.compress(Bitmap.CompressFormat.JPEG, quality, imageOutput);
        }


        SketchFile sketchFile = new SketchFile();
        sketchFile.localFilePath = cacheFile.getAbsolutePath();;
        sketchFile.width = viewBitmap.getWidth();
        sketchFile.height = viewBitmap.getHeight();
        return sketchFile;

    }

    public boolean openSketchFile(String localFilePath) {

        BitmapFactory.Options bitmapOptions = new BitmapFactory.Options();
        bitmapOptions.outWidth = sketchView.getWidth();
        Bitmap bitmap = BitmapFactory.decodeFile(localFilePath, bitmapOptions);
        if(bitmap != null) {
            sketchView.setViewImage(bitmap);
            return true;
        }
        return false;
    }

    public void onDrawSketch(int stackCount){
        WritableMap event = Arguments.createMap();
        event.putInt("stackCount", stackCount);

        ReactContext reactContext = (ReactContext)getContext();

        reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
            getId(),
            RNSketchViewManager.EVENT_ON_DRAW_SKETCH,
            event
        );
    }

}
