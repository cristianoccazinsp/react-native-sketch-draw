package com.rnsketchview.tools;

import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;
import android.view.MotionEvent;
import android.view.View;
import java.lang.Math.*;

import com.rnsketchview.utils.ToolUtils;


public class ArrowTool extends SketchTool implements ToolThickness, ToolColor {

    private static final float DEFAULT_THICKNESS = 5;
    private static final int DEFAULT_COLOR = Color.BLACK;
    private static final double POINTER_LINE_LENGTH = 50;

    private float toolThickness;
    private int toolColor;

    private Paint paint = new Paint();
    private Path path = new Path();
    private float startX = 0;
    private float startY = 0;

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
        path.reset();
    }

    @Override
    void onTouchDown(MotionEvent event) {
        startX = event.getX();
        startY = event.getY();

        path.reset();
        touchView.invalidate();
    }

    private void drawArrow(float endX, float endY){
        path.reset();

        path.moveTo(startX, startY);
        path.lineTo(endX, endY);

        double arrowAngle = Math.PI / 4;
        double startEndAngle = Math.atan((endY - startY) / (endX - startX)) + ((endX - startX) < 0 ? Math.PI : 0);

        path.lineTo(
            endX + (float)(POINTER_LINE_LENGTH * Math.cos(Math.PI - startEndAngle + arrowAngle)),
            endY - (float)(POINTER_LINE_LENGTH * Math.sin(Math.PI - startEndAngle + arrowAngle))
        );

        path.moveTo(endX, endY);

        path.lineTo(
            endX + (float)(POINTER_LINE_LENGTH * Math.cos(Math.PI - startEndAngle - arrowAngle)),
            endY - (float)(POINTER_LINE_LENGTH * Math.sin(Math.PI - startEndAngle - arrowAngle))
        );
    }

    @Override
    void onTouchMove(MotionEvent event) {
        drawArrow(event.getX(), event.getY());
        touchView.invalidate();
    }

    @Override
    void onTouchUp(MotionEvent event) {
        drawArrow(event.getX(), event.getY());
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
