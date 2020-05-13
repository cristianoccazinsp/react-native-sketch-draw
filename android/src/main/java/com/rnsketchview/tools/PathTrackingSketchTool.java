package com.rnsketchview.tools;

import android.graphics.Path;
import android.view.MotionEvent;
import android.view.View;


public abstract class PathTrackingSketchTool extends SketchTool {

    Path path = new Path();

    PathTrackingSketchTool(View touchView) {
        super(touchView);
    }

    @Override
    public void clear() {
        path.reset();
    }

    @Override
    public boolean onTouchDown(MotionEvent event) {
        path.moveTo(event.getX(), event.getY());

        return true;
    }

    @Override
    public boolean onTouchMove(MotionEvent event) {
        path.lineTo(event.getX(), event.getY());
        touchView.invalidate();

        return true;
    }

    @Override
    public boolean onTouchUp(MotionEvent event) {
        path.lineTo(event.getX(), event.getY());
        touchView.invalidate();

        return true;
    }

    @Override
    public boolean onTouchCancel(MotionEvent event) {
        return onTouchUp(event);
    }
}
