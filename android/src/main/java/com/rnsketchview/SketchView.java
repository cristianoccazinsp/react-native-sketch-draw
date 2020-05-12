package com.rnsketchview;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.view.MotionEvent;
import android.view.View;
import java.util.LinkedList;

import com.rnsketchview.tools.EraseSketchTool;
import com.rnsketchview.tools.PenSketchTool;
import com.rnsketchview.tools.RectangleTool;
import com.rnsketchview.tools.SketchTool;


/**
 * Created by keshav on 05/04/17.
 */

public class SketchView extends View {

    SketchViewContainer mContainer;
    int maxUndo = 10;
    SketchTool currentTool;
    PenSketchTool penTool;
    EraseSketchTool eraseTool;
    RectangleTool rectangleTool;

    Bitmap incrementalImage;
    LinkedList<Bitmap> stack;

    public SketchView(Context context, SketchViewContainer container) {
        super(context);

        mContainer = container;
        stack = new LinkedList<Bitmap>();
        penTool = new PenSketchTool(this);
        eraseTool = new EraseSketchTool(this);
        rectangleTool = new RectangleTool(this);

        setToolType(SketchTool.TYPE_PEN);
        setBackgroundColor(Color.TRANSPARENT);
    }

    public void setToolType(int toolType) {
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
        boolean value = currentTool.onTouch(this, event);
        if(event.getAction() == MotionEvent.ACTION_CANCEL || event.getAction() == MotionEvent.ACTION_UP) {
            setViewImage(drawBitmap());
            currentTool.clear();
        }
        return value;
    }

}
