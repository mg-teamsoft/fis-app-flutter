import Flutter
import UIKit
import Vision
import CoreImage
import ImageIO

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let cropQueue = DispatchQueue(label: "fis_app.receipt_crop", qos: .userInitiated)

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let registrar = registrar(forPlugin: "ReceiptDocumentCropper") {
      let channel = FlutterMethodChannel(name: "fis_app/receipt_crop", binaryMessenger: registrar.messenger())
      channel.setMethodCallHandler { [weak self] call, result in
        guard call.method == "cropDocument" else {
          result(FlutterMethodNotImplemented)
          return
        }
        guard let arguments = call.arguments as? [String: Any],
              let path = arguments["path"] as? String else {
          result(FlutterError(code: "invalid_image", message: "Image path is required", details: nil))
          return
        }
        self?.cropQueue.async {
          autoreleasepool {
            do {
              let data = try Self.cropDocument(path: path)
              DispatchQueue.main.async { result(data.map { FlutterStandardTypedData(bytes: $0) }) }
            } catch {
              DispatchQueue.main.async {
                result(FlutterError(code: "crop_failed", message: error.localizedDescription, details: nil))
              }
            }
          }
        }
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  static func cropDocument(path: String) throws -> Data? {
    guard let image = CIImage(contentsOf: URL(fileURLWithPath: path), options: [.applyOrientationProperty: true]) else {
      throw NSError(domain: "ReceiptCrop", code: 1, userInfo: [NSLocalizedDescriptionKey: "Image could not be decoded"])
    }
    let context = CIContext()
    let normalized = image.transformed(by: CGAffineTransform(translationX: -image.extent.minX, y: -image.extent.minY))
    guard let cgImage = context.createCGImage(normalized, from: normalized.extent) else { return nil }
    let request = VNDetectRectanglesRequest()
    request.minimumAspectRatio = 0.05 // Include long, narrow till receipts.
    request.maximumAspectRatio = 1
    request.minimumSize = 0.08
    request.minimumConfidence = 0.6
    request.maximumObservations = 8
    request.quadratureTolerance = 35
    try VNImageRequestHandler(cgImage: cgImage, orientation: .up).perform([request])
    // Prefer the largest document-shaped region, not text boxes inside it.
    let rectangles = (request.results ?? []).filter {
      let area = rectangleArea($0)
      return area >= 0.08 && area <= 0.98
    }
    guard let rectangle = rectangles.max(by: { rectangleArea($0) < rectangleArea($1) }) else { return nil }
    let extent = normalized.extent
    func vector(_ point: CGPoint) -> CIVector {
      CIVector(x: point.x * extent.width, y: point.y * extent.height)
    }
    let crop = normalized.applyingFilter("CIPerspectiveCorrection", parameters: [
      "inputTopLeft": vector(rectangle.topLeft),
      "inputTopRight": vector(rectangle.topRight),
      "inputBottomRight": vector(rectangle.bottomRight),
      "inputBottomLeft": vector(rectangle.bottomLeft)
    ])
    let scale = min(1, 2560 / max(crop.extent.width, crop.extent.height))
    let resized = crop.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
    guard let output = context.createCGImage(resized, from: resized.extent) else { return nil }
    // Lossless intermediate; the shared pipeline applies JPEG quality 88 once.
    return UIImage(cgImage: uprightPortrait(output, context: context)).pngData()
  }

  // OCR is used only for orientation. The lossless full-size image is rotated
  // before the shared pipeline writes the final JPEG.
  static func uprightPortrait(_ source: CGImage, context: CIContext = CIContext()) -> CGImage {
    let orientations: [CGImagePropertyOrientation]
    if source.width > source.height {
      orientations = [.right, .left]
    } else if source.width < source.height {
      orientations = [.up, .down]
    } else {
      orientations = [.up, .right, .down, .left]
    }
    let original = CIImage(cgImage: source)
    var bestOrientation = orientations[0]
    var bestScore = 0.0
    for orientation in orientations {
      let candidate = original.oriented(orientation)
      let scale = min(1, 1600 / max(candidate.extent.width, candidate.extent.height))
      let preview = candidate.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
      guard let cgPreview = context.createCGImage(preview, from: preview.extent) else { continue }
      let request = VNRecognizeTextRequest()
      request.recognitionLevel = .accurate
      request.usesLanguageCorrection = false
      request.recognitionLanguages = ["en-US"] // Latin receipt text; no network request.
      do {
        try VNImageRequestHandler(cgImage: cgPreview, orientation: .up).perform([request])
        let score = (request.results ?? []).reduce(0.0) { score, observation in
          guard let text = observation.topCandidates(1).first else { return score }
          let characters = text.string.unicodeScalars.filter { CharacterSet.alphanumerics.contains($0) }.count
          let dx = observation.topRight.x - observation.topLeft.x
          let dy = observation.topRight.y - observation.topLeft.y
          // Only credit left-to-right, horizontal text, not auto-read inverted text.
          guard characters >= 3, dx > 0, abs(dy) < dx * 0.36 else { return score }
          let confidence = Double(text.confidence)
          return score + Double(min(characters, 80)) * confidence * confidence
        }
        if score >= 5 && score > bestScore * 1.1 {
          bestScore = score
          bestOrientation = orientation
        }
      } catch {
        // With no OCR evidence, retain the deterministic portrait orientation.
      }
    }
    let upright = original.oriented(bestOrientation)
    return context.createCGImage(upright, from: upright.extent) ?? source
  }

  private static func rectangleArea(_ rectangle: VNRectangleObservation) -> CGFloat {
    let points = [rectangle.topLeft, rectangle.topRight, rectangle.bottomRight, rectangle.bottomLeft]
    var area: CGFloat = 0
    for index in 0..<4 {
      let next = points[(index + 1) % 4]
      area += points[index].x * next.y - next.x * points[index].y
    }
    return abs(area) / 2
  }
}
