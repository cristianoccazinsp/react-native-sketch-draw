package com.rnsketchview.tools;

import java.lang.Math.*;

import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.os.Looper;
import android.view.MotionEvent;
import android.view.View;
import android.content.Context;
import android.content.DialogInterface;
import androidx.appcompat.widget.AppCompatEditText;
import androidx.appcompat.app.AlertDialog;
import android.view.Gravity;
import android.text.InputType;
import android.view.inputmethod.InputMethodManager;
import android.os.Handler;

import com.rnsketchview.utils.ToolUtils;
import com.rnsketchview.utils.TextRect;


public class TextTool extends SketchTool implements ToolThickness, ToolColor {

    private static final float DEFAULT_THICKNESS = 1;
    private static final int DEFAULT_COLOR = Color.BLACK;
    private static final int TOOL_FONT_SIZE = 35;
    private static final String TOOL_INSTRUCTIONS = "The following text will be added. After pressing add, press and hold on the screen to drag and drop the text.";
    private static final int DEFAULT_PADDING = 20;

    private float toolThickness;
    private int toolColor;

    private int padding = DEFAULT_PADDING;
    private int fontSize = TOOL_FONT_SIZE;

    private Paint paint = new Paint();
    private float startX = 0;
    private float startY = 0;

    private float drawX = 0;
    private float drawY = 0;
    private boolean drawn = false;
    private String prompted = null;


    public TextTool(View touchView) {
        super(touchView);

        setToolColor(DEFAULT_COLOR);
        setToolThickness(DEFAULT_THICKNESS);

        paint.setStyle(Paint.Style.FILL);
        paint.setAntiAlias(true);
        padding = (int)ToolUtils.ConvertDPToPixels(touchView.getContext(), DEFAULT_PADDING);
        fontSize = (int)ToolUtils.ConvertDPToPixels(touchView.getContext(), TOOL_FONT_SIZE);
    }

    @Override
    public void render(Canvas canvas) {
        if(drawn && prompted != null){
            paint.setTextSize(fontSize);

            // add some sanity checks
            int width = (int)Math.floor(Math.max(touchView.getWidth() - drawX, 1));
            int height = (int)Math.floor(Math.max(touchView.getHeight() - drawY, 1));

            TextRect rect = new TextRect(paint);
            rect.prepare(prompted, width, height);
            rect.draw(canvas, (int)drawX, (int)drawY);
        }
    }

    @Override
    public boolean hasData(){
        return prompted != null && drawn;
    }

    @Override
    public void clear() {
        drawn = false;
        prompted = null;
    }

    private void drawPoint(float endX, float endY){
        drawX = endX;
        drawY = endY;
        drawn = true;
    }

    private void setPrompted(String text){
        prompted = text;

        // use default location to force the user to drag it
        float x, y;
        x = touchView.getX() + touchView.getWidth() / 2;
        y = touchView.getY() + touchView.getHeight() / 2;
        drawPoint(x, y);

        touchView.invalidate();
    }

    @Override
    public void promptData(){
        // prompt here

        AlertDialog.Builder builder = new AlertDialog.Builder(touchView.getContext());
        builder.setTitle("Add Text");
        builder.setMessage(TOOL_INSTRUCTIONS);

        // Set up the input
        final AppCompatEditText input = new AppCompatEditText(touchView.getContext());
        input.setPadding(padding, padding / 2, padding, 0);

        input.setHint("Text...");
        input.setGravity(Gravity.LEFT);
        input.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_FLAG_CAP_SENTENCES);

        // Specify the type of input expected; this, for example, sets the input as a password, and will mask the text
        builder.setView(input);

        // Set up the buttons
        builder.setPositiveButton("Add", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                String text = input.getText().toString();
                if(text != null && text.length() > 0){
                    TextTool.this.setPrompted(text);
                }
            }
        });


        final AlertDialog dialog = builder.show();

        // all this gibberish to focus keyboard
        new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
            @Override
            public void run() {
            try {
                input.requestFocus();
                Context context = touchView.getContext();
                InputMethodManager imm = (InputMethodManager) context.getSystemService(Context.INPUT_METHOD_SERVICE);
                imm.toggleSoftInput(InputMethodManager.SHOW_IMPLICIT, 0);
            }
            catch (Exception e){
                // do nothing if focus/keyboard not available
            }
            }
        }, 200);
    }

    @Override
    public boolean onTouchDown(MotionEvent event) {
        startX = event.getX();
        startY = event.getY();

        if(prompted == null){
            promptData();
        }
        else{
            drawPoint(startX, startY);
            touchView.invalidate();
        }

        return true;
    }


    @Override
    public boolean onTouchMove(MotionEvent event) {
        if(prompted != null){
            drawPoint(event.getX(), event.getY());
            touchView.invalidate();
        }

        return true;
    }

    @Override
    public boolean onTouchUp(MotionEvent event) {
        if(prompted != null){
            drawPoint(event.getX(), event.getY());
            touchView.invalidate();
        }

        // this tool has to be committed manually
        return false;
    }

    @Override
    public boolean onTouchCancel(MotionEvent event) {
        return onTouchUp(event);
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
