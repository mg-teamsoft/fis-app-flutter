package com.example.fis_app_flutter

import android.graphics.Bitmap
import android.graphics.Matrix
import com.google.android.gms.tasks.Tasks
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.Text
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import kotlin.math.abs
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

/** Called on the crop worker. OCR is local and previews are processed one at a time. */
internal object ReceiptOrientation {
    fun uprightPortrait(source: Bitmap): Bitmap {
        val rotations = when {
            source.width > source.height -> listOf(90, 270)
            source.width < source.height -> listOf(0, 180)
            else -> listOf(0, 90, 180, 270)
        }
        var bestRotation = rotations.first()
        var bestScore = 0.0
        val scale = min(1.0, 1600.0 / max(source.width, source.height))
        val preview = Bitmap.createScaledBitmap(
            source,
            max(1, (source.width * scale).roundToInt()),
            max(1, (source.height * scale).roundToInt()),
            true
        )
        val recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
        try {
            for (rotation in rotations) {
                val candidate = rotate(preview, rotation)
                try {
                    val text = Tasks.await(
                        recognizer.process(InputImage.fromBitmap(candidate, 0))
                    )
                    val score = score(text)
                    // Retain the existing upright direction on inconclusive or near-tied OCR.
                    if (score >= 5.0 && score > bestScore * 1.1) {
                        bestScore = score
                        bestRotation = rotation
                    }
                } catch (_: Exception) {
                    // No OCR evidence: keep the deterministic portrait orientation.
                } finally {
                    if (candidate !== preview) candidate.recycle()
                }
            }
        } finally {
            recognizer.close()
            if (preview !== source) preview.recycle()
        }
        return rotate(source, bestRotation)
    }

    private fun score(text: Text): Double = text.textBlocks.sumOf { block ->
        block.lines.sumOf { line ->
            val characters = line.text.count { it.isLetterOrDigit() }
            val box = line.boundingBox
            // Reject vertical and upside-down detections even if OCR reads their content.
            if (characters < 3 || box == null || box.width() <= box.height() || abs(line.angle) > 20f) {
                0.0
            } else {
                val confidence = line.confidence.toDouble().coerceIn(0.0, 1.0)
                min(characters, 80) * confidence * confidence
            }
        }
    }

    private fun rotate(source: Bitmap, degrees: Int): Bitmap {
        if (degrees == 0) return source
        val matrix = Matrix().apply { postRotate(degrees.toFloat()) }
        return Bitmap.createBitmap(source, 0, 0, source.width, source.height, matrix, true)
    }
}
