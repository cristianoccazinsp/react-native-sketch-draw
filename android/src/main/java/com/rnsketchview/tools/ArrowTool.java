package com.rnsketchview.tools;

import java.lang.Math.*;

import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;
import android.view.MotionEvent;
import android.view.View;

import com.rnsketchview.utils.ToolUtils;


public class ArrowTool extends SketchTool implements ToolThickness, ToolColor {

    private static final float DEFAULT_THICKNESS = 5;
    private static final int DEFAULT_COLOR = Color.BLACK;
    private static final float POINTER_LINE_LENGTH = 20;

    private float toolThickness;
    private int toolColor;

    private Paint paint = new Paint();
    private Path path = new Path();
    private float startX = 0;
    private float startY = 0;
    private boolean moved = false;

    public ArrowTool(View touchView) {
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
        moved = false;
        path.reset();
    }

    @Override
    public boolean onTouchDown(MotionEvent event) {
        startX = event.getX();
        startY = event.getY();
        moved = false;

        path.reset();
        touchView.invalidate();

        return true;
    }

    private void drawArrow(float endX, float endY){
        path.reset();

        path.moveTo(startX, startY);
        path.lineTo(endX, endY);

        double arrowAngle = Math.PI / 4;
        double startEndAngle = Math.atan((endY - startY) / (endX - startX)) + ((endX - startX) < 0 ? Math.PI : 0);

        float pointerLength = ToolUtils.ConvertDPToPixels(touchView.getContext(), POINTER_LINE_LENGTH);

        path.lineTo(
            endX + (float)(pointerLength * Math.cos(Math.PI - startEndAngle + arrowAngle)),
            endY - (float)(pointerLength * Math.sin(Math.PI - startEndAngle + arrowAngle))
        );

        path.moveTo(endX, endY);

        path.lineTo(
            endX + (float)(pointerLength * Math.cos(Math.PI - startEndAngle - arrowAngle)),
            endY - (float)(pointerLength * Math.sin(Math.PI - startEndAngle - arrowAngle))
        );
    }

    @Override
    public boolean onTouchMove(MotionEvent event) {
        moved = true;

        drawArrow(event.getX(), event.getY());
        touchView.invalidate();

        return true;
    }

    @Override
    public boolean onTouchUp(MotionEvent event) {
        if(!moved){
            touchView.invalidate();
            return false;
        }

        drawArrow(event.getX(), event.getY());
        touchView.invalidate();

        return true;
    }

    @Override
    public boolean onTouchCancel(MotionEvent event) {
        return onTouchUp(event);
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
