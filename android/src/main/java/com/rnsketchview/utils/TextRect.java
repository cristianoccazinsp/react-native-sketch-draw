package com.rnsketchview.utils;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Paint.FontMetricsInt;
import android.graphics.Rect;


// Taken from: https://gist.github.com/markusfisch/2655909
// Alternatives: use static layout

/**
 * Draw text in a given rectangle and automatically wrap lines.
 */
public class TextRect {
	// maximum number of lines; this is a fixed number in order
	// to use a predefined array to avoid ArrayList (or something
	// similar) because filling it does involve allocating memory
	static private int MAX_LINES = 256;

	// those members are stored per instance to minimize
	// the number of allocations to avoid triggering the
	// GC too much
	private FontMetricsInt metrics;
	private Paint paint;
	private int[] starts = new int[MAX_LINES];
	private int[] stops = new int[MAX_LINES];
	private int lines = 0;
	private int textHeight = 0;
	private Rect bounds = new Rect();
	private String text = null;
	private boolean wasCut = false;

	/**
	 * Create reusable text rectangle (use one instance per font).
	 *
	 * @param paint paint specifying the font
	 */
	public TextRect(Paint paint) {
		metrics = paint.getFontMetricsInt();
		this.paint = paint;
	}

	/**
	 * Calculate height of text block and prepare to draw it.
	 *
	 * @param text text to draw
	 * @param maxWidth maximum width in pixels
	 * @param maxHeight maximum height in pixels
	 * @returns height of text in pixels
	 */
	public int prepare(String text, int maxWidth, int maxHeight) {
		lines = 0;
		textHeight = 0;
		this.text = text;
		wasCut = false;

		// get maximum number of characters in one line
		paint.getTextBounds("i", 0, 1, bounds);

		final int maximumInLine = maxWidth / bounds.width();
		final int length = text.length();
		if (length < 1) {
			return 0;
		}

		final int lineHeight = -metrics.ascent + metrics.descent;
		int start = 0;
		int stop = Math.min(maximumInLine, length);

		for (; ; ) {
			// skip LF and spaces
			for (; start < length; ++start) {
				char ch = text.charAt(start);

				if (ch != '\n' &&
						ch != '\r' &&
						ch != '\t' &&
						ch != ' ') {
					break;
				}
			}

			for (int o = stop + 1; stop < o && stop > start; ) {
				o = stop;

				int lowest = text.indexOf("\n", start);

				paint.getTextBounds(
						text,
						start,
						stop,
						bounds);

				if ((lowest >= start && lowest < stop) ||
						bounds.width() > maxWidth) {
					--stop;

					if (lowest < start || lowest > stop) {
						int blank = text.lastIndexOf(" ", stop);
						int hyphen = text.lastIndexOf("-", stop);

						if (blank > start &&
								(hyphen < start || blank > hyphen)) {
							lowest = blank;
						} else if (hyphen > start) {
							lowest = hyphen;
						}
					}

					if (lowest >= start && lowest <= stop) {
						char ch = text.charAt(stop);

						if (ch != '\n' && ch != ' ') {
							++lowest;
						}

						stop = lowest;
					}

					continue;
				}

				break;
			}

			if (start >= stop) {
				break;
			}

			int minus = 0;

			// cut off lf or space
			if (stop < length) {
				char ch = text.charAt(stop - 1);
				if (ch == '\n' || ch == ' ') {
					minus = 1;
				}
			}

			if (textHeight + lineHeight > maxHeight) {
				wasCut = true;
				break;
			}

			starts[lines] = start;
			stops[lines] = stop - minus;

			if (++lines > MAX_LINES) {
				wasCut = true;
				break;
			}

			if (textHeight > 0) {
				textHeight += metrics.leading;
			}

			textHeight += lineHeight;

			if (stop >= length) {
				break;
			}

			start = stop;
			stop = length;
		}

		return textHeight;
	}

	/**
	 * Draw prepared text at given position.
	 *
	 * @param canvas canvas to draw text into
	 * @param left left corner
	 * @param top top corner
	 */
	public void draw(Canvas canvas, int left, int top) {
		if (textHeight == 0) {
			return;
		}

		final int before = -metrics.ascent;
		final int after = metrics.descent + metrics.leading;
		int y = top;
		int lastLine = lines - 1;

		for (int i = 0; i < lines; ++i) {
			String line;

			if (wasCut && i == lastLine && stops[i] - starts[i] > 3) {
				line = text.substring(starts[i], stops[i] - 3).concat("...");
			} else {
				line = text.substring(starts[i], stops[i]);
			}

			y += before;
			canvas.drawText(line, left, y, paint);
			y += after;
		}
	}

	/**
	 * Returns true if text was cut to fit into the maximum height
	 */
	public boolean wasCut() {
		return wasCut;
	}
}