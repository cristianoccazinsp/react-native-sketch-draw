package com.rnsketchview.tools;

import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;
import android.view.MotionEvent;
import android.view.View;

import com.rnsketchview.utils.ToolUtils;

/**
 * Created by keshav on 08/04/17.
 */
public class RectangleTool extends SketchTool implements ToolThickness, ToolColor {

    private static final float DEFAULT_THICKNESS = 5;
    private static final int DEFAULT_COLOR = Color.BLACK;

    private float toolThickness;
    private int toolColor;

    private Paint paint = new Paint();
    private Path path = new Path();
    private float startX = 0;
    private float startY = 0;

    public RectangleTool(View touchView) {
        super(touchView);

        setToolColor(DEFAULT_COLOR);
        setToolThickness(DEFAULT_THICKNESS);

        paint.setStyle(Paint.Style.STROKE);
        paint.setAntiAlias(true);
        paint.setStrokeJoin(Paint.Join.ROUND);
        paint.setStrokeCap(Paint.Cap.ROUND);
    }

    @Override
    public void clear() {
        path.reset();
    }

    @Override
    void onTouchDown(MotionEvent event) {
        startX = event.getX();
        startY = event.getY();

        path.reset();
        RectF rect = new RectF(startX, startY, startX + 10, startY + 10);
        path.addRect(rect, Path.Direction.CW);
        touchView.invalidate();
    }

    private void drawRect(float endX, float endY){
        path.reset();
        RectF rect = new RectF(startX, startY, endX, endY);
        rect.sort();
        path.addRect(rect, Path.Direction.CW);
    }

    @Override
    void onTouchMove(MotionEvent event) {
        drawRect(event.getX(), event.getY());
        touchView.invalidate();
    }

    @Override
    void onTouchUp(MotionEvent event) {
        drawRect(event.getX(), event.getY());
        touchView.invalidate();
    }

    @Override
    void onTouchCancel(MotionEvent event) {
        onTouchUp(event);
    }

    @Override
    public void render(Canvas canvas) {
        canvas.drawPath(path, paint);
    }

    @Override
    public void setToolThickness(float toolThickness) {
        this.toolThickness = toolThickness;
        paint.setStrokeWidth(ToolUtils.ConvertDPToPixels(touchView.getContext(), toolThickness));
    }

    @Override
    public float getToolThickness() {
        return toolThickness;
    }

    @Override
    public void setToolColor(int toolColor) {
        this.toolColor = toolColor;
        paint.setColor(toolColor);
    }

    @Override
    public int getToolColor() {
        return toolColor;
    }
}
