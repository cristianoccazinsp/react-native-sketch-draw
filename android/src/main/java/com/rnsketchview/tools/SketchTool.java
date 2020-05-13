package com.rnsketchview.tools;

import android.graphics.Canvas;
import android.view.MotionEvent;
import android.view.View;


public abstract class SketchTool {

    public static final int TYPE_PEN = 0;
    public static final int TYPE_ERASE = 1;
    public static final int TYPE_RECTANGLE = 2;
    public static final int TYPE_ARROW = 3;
    public static final int TYPE_TEXT = 4;

    View touchView;

    SketchTool(View touchView) {
        this.touchView = touchView;
    }

    public abstract void render(Canvas canvas);
    public abstract void clear();

    // Implement this to hint that the tool has pending data
    // and it should commit before clearing / switching
    public boolean hasData(){
        return false;
    }

    public void promptData(){
        // dummy
    }


    // Result will be used for snapshoting purposes
    public abstract boolean onTouchDown(MotionEvent event);

    public abstract boolean onTouchMove(MotionEvent event);

    public abstract boolean onTouchUp(MotionEvent event);

    public abstract boolean onTouchCancel(MotionEvent event);

}
