package com.rnsketchview;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.view.MotionEvent;
import android.view.View;
import java.util.LinkedList;

import com.rnsketchview.tools.SketchTool;
import com.rnsketchview.tools.EraseSketchTool;
import com.rnsketchview.tools.PenSketchTool;
import com.rnsketchview.tools.RectangleTool;
import com.rnsketchview.tools.ArrowTool;
import com.rnsketchview.tools.TextTool;


public class SketchView extends View {

    SketchViewContainer mContainer;
    int maxUndo = 10;
    SketchTool currentTool;
    PenSketchTool penTool;
    EraseSketchTool eraseTool;
    RectangleTool rectangleTool;
    ArrowTool arrowTool;
    TextTool textTool;

    Bitmap incrementalImage;
    LinkedList<Bitmap> stack;

    public SketchView(Context context, SketchViewContainer container) {
        super(context);

        mContainer = container;
        stack = new LinkedList<Bitmap>();
        penTool = new PenSketchTool(this);
        eraseTool = new EraseSketchTool(this);
        rectangleTool = new RectangleTool(this);
        arrowTool = new ArrowTool(this);
        textTool = new TextTool(this);

        setToolType(SketchTool.TYPE_PEN);
        setBackgroundColor(Color.TRANSPARENT);
    }

    public void setToolType(int toolType) {

        // clear/commit current tool
        commit();

        switch (toolType) {
            case SketchTool.TYPE_PEN:
                currentTool = penTool;
                break;
            case SketchTool.TYPE_ERASE:
                currentTool = eraseTool;
                break;
            case SketchTool.TYPE_RECTANGLE:
                currentTool = rectangleTool;
                break;
            case SketchTool.TYPE_ARROW:
                currentTool = arrowTool;
                break;
            case SketchTool.TYPE_TEXT:
                currentTool = textTool;
                break;
            default:
                currentTool = penTool;
        }
    }

    void setMaxUndo(int max){
        maxUndo = max;

        synchronized(this){
            int initialSize = stack.size();

            while(stack.size() >= maxUndo){
                stack.pollFirst();
            }
            if(initialSize != stack.size()){
                mContainer.onDrawSketch(stack.size());
            }
        }
    }

    // keep pen tool as the source of truth
    // but set all that might need use color
    public void setToolColor(int toolColor) {
        penTool.setToolColor(toolColor);
        rectangleTool.setToolColor(toolColor);
        arrowTool.setToolColor(toolColor);
        textTool.setToolColor(toolColor);
    }

    public int getToolColor() {
        return penTool.getToolColor();
    }

    public void setViewImage(Bitmap bitmap) {
        synchronized(this){
            if(incrementalImage != null){
                if(stack.size() >= maxUndo){
                    stack.pollFirst();
                }
                stack.addLast(incrementalImage);
            }
            // if prev image is null,
            // add a dummy stack element so we can undo it too
            else{
                stack.addLast(null);
            }
        }
        incrementalImage = bitmap;
        invalidate();
        mContainer.onDrawSketch(stack.size());
    }

    Bitmap drawBitmap() {
        Bitmap viewBitmap = Bitmap.createBitmap(getWidth(), getHeight(), Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(viewBitmap);
        draw(canvas);
        return viewBitmap;
    }

    public void clear() {
        synchronized(this){
            // clear stack as well
            stack = new LinkedList<Bitmap>();
        }
        incrementalImage = null;
        currentTool.clear();
        invalidate();
        mContainer.onDrawSketch(stack.size());
    }

    public void undo() {
        // null is also handled
        Bitmap prev = stack.pollLast();
        incrementalImage = prev;
        currentTool.clear();
        invalidate();
        mContainer.onDrawSketch(stack.size());
    }

    public void commit() {
        if(currentTool != null){

            if(currentTool.hasData()){
                setViewImage(drawBitmap());
                currentTool.clear();
            }
            else{
                currentTool.clear();
                invalidate();
            }
        }
    }

    public void promptData() {
        if(currentTool != null){
            currentTool.promptData();
        }
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        if(incrementalImage != null)
            canvas.drawBitmap(incrementalImage, getLeft(), getTop(), null);
        if(currentTool != null)
            currentTool.render(canvas);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        boolean value = false;

        int action = event.getAction();

        switch (action) {
            case MotionEvent.ACTION_DOWN:
                value = currentTool.onTouchDown(event);
                break;
            case MotionEvent.ACTION_MOVE:
                value = currentTool.onTouchMove(event);
                break;
            case MotionEvent.ACTION_UP:
                value = currentTool.onTouchUp(event);
                break;
            case MotionEvent.ACTION_CANCEL:
                value = currentTool.onTouchCancel(event);
                break;
        }

        if(value && (action == MotionEvent.ACTION_CANCEL || action == MotionEvent.ACTION_UP)) {
            setViewImage(drawBitmap());
            currentTool.clear();
        }

        return true;
    }

}
