package com.example.fis_app_flutter

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import androidx.exifinterface.media.ExifInterface
import org.opencv.android.OpenCVLoader
import org.opencv.android.Utils
import org.opencv.core.*
import org.opencv.imgproc.Imgproc
import java.io.ByteArrayOutputStream
import kotlin.math.*

/** Local, background-only document detection. Never returns the original photo. */
internal object ReceiptDocumentCropper {
    fun crop(path: String): ByteArray? {
        check(OpenCVLoader.initLocal()) { "OpenCV could not be initialized" }
        val decoded = BitmapFactory.decodeFile(path) ?: error("Image could not be decoded")
        val exif = ExifInterface(path)
        val matrix = Matrix().apply {
            if (exif.isFlipped) postScale(-1f, 1f)
            postRotate(exif.rotationDegrees.toFloat())
        }
        val bitmap = Bitmap.createBitmap(decoded, 0, 0, decoded.width, decoded.height, matrix, true)
        val source = Mat()
        val preview = Mat()
        val gray = Mat()
        val edges = Mat()
        val hierarchy = Mat()
        val kernel = Imgproc.getStructuringElement(Imgproc.MORPH_RECT, Size(5.0, 5.0))
        val contours = mutableListOf<MatOfPoint>()
        try {
            Utils.bitmapToMat(bitmap, source)
            val scale = min(1.0, 1600.0 / max(source.cols(), source.rows()))
            Imgproc.resize(source, preview, Size(), scale, scale, Imgproc.INTER_AREA)
            Imgproc.cvtColor(preview, gray, Imgproc.COLOR_RGBA2GRAY)
            Imgproc.GaussianBlur(gray, gray, Size(5.0, 5.0), 0.0)
            Imgproc.Canny(gray, edges, 40.0, 120.0)
            Imgproc.morphologyEx(edges, edges, Imgproc.MORPH_CLOSE, kernel)
            Imgproc.findContours(edges, contours, hierarchy, Imgproc.RETR_LIST, Imgproc.CHAIN_APPROX_SIMPLE)
            val frameArea = preview.cols().toDouble() * preview.rows()
            var best: Array<Point>? = null
            var bestArea = 0.0
            for (contour in contours) {
                val curve = MatOfPoint2f(*contour.toArray())
                val approximation = MatOfPoint2f()
                try {
                    Imgproc.approxPolyDP(curve, approximation, Imgproc.arcLength(curve, true) * 0.02, true)
                    val points = approximation.toArray()
                    if (points.size != 4) continue
                    val polygon = MatOfPoint(*points)
                    val area: Double
                    val convex: Boolean
                    try {
                        area = abs(Imgproc.contourArea(polygon))
                        convex = Imgproc.isContourConvex(polygon)
                    } finally { polygon.release() }
                    // Ignore tiny text boxes and contours that merely follow the photo border.
                    if (!convex || area < frameArea * 0.08 || area > frameArea * 0.98 || area <= bestArea) continue
                    val ordered = order(points) ?: continue
                    val lengths = ordered.indices.map { distance(ordered[it], ordered[(it + 1) % 4]) }
                    if (lengths.minOrNull()!! < 20.0 || lengths.minOrNull()!! / lengths.maxOrNull()!! < 0.05) continue
                    best = ordered
                    bestArea = area
                } finally { curve.release(); approximation.release() }
            }
            val corners = best?.map { Point(it.x / scale, it.y / scale) }?.toTypedArray() ?: return null
            val width = max(distance(corners[0], corners[1]), distance(corners[3], corners[2]))
            val height = max(distance(corners[0], corners[3]), distance(corners[1], corners[2]))
            // Warp directly to the final resolution to keep native memory bounded.
            val outputScale = min(1.0, 2560.0 / max(width, height))
            val w = max(1, (width * outputScale).roundToInt())
            val h = max(1, (height * outputScale).roundToInt())
            val from = MatOfPoint2f(*corners)
            val to = MatOfPoint2f(Point(0.0, 0.0), Point(w - 1.0, 0.0), Point(w - 1.0, h - 1.0), Point(0.0, h - 1.0))
            val transform = Imgproc.getPerspectiveTransform(from, to)
            val cropped = Mat()
            try {
                Imgproc.warpPerspective(source, cropped, transform, Size(w.toDouble(), h.toDouble()), Imgproc.INTER_CUBIC)
                val output = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
                try {
                    Utils.matToBitmap(cropped, output)
                    val upright = ReceiptOrientation.uprightPortrait(output)
                    try {
                        return ByteArrayOutputStream().use {
                            // Lossless intermediate; the shared Dart pipeline encodes JPEG only once.
                            check(upright.compress(Bitmap.CompressFormat.PNG, 100, it))
                            it.toByteArray()
                        }
                    } finally {
                        if (upright !== output) upright.recycle()
                    }
                } finally { output.recycle() }
            } finally { from.release(); to.release(); transform.release(); cropped.release() }
        } finally {
            contours.forEach { it.release() }
            source.release(); preview.release(); gray.release(); edges.release(); hierarchy.release(); kernel.release()
            if (bitmap !== decoded) bitmap.recycle()
            decoded.recycle()
        }
    }

    private fun distance(a: Point, b: Point) = hypot(a.x - b.x, a.y - b.y)

    private fun order(points: Array<Point>): Array<Point>? {
        val center = Point(points.map { it.x }.average(), points.map { it.y }.average())
        val around = points.sortedBy { atan2(it.y - center.y, it.x - center.x) }
        val start = around.indices.minByOrNull { around[it].x + around[it].y } ?: return null
        return Array(4) { around[(start + it) % 4] }
    }
}
