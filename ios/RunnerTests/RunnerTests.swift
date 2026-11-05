import UIKit
import XCTest
import CoreImage
import ImageIO
@testable import Runner

class RunnerTests: XCTestCase {
  private func fixture(document: Bool, perspective: Bool = false) throws -> URL {
    let format = UIGraphicsImageRendererFormat()
    format.scale = 1
    let image = UIGraphicsImageRenderer(size: CGSize(width: 1200, height: 1600), format: format).image { context in
      UIColor.darkGray.setFill()
      context.fill(CGRect(x: 0, y: 0, width: 1200, height: 1600))
      if document {
        UIColor.white.setFill()
        let page = UIBezierPath()
        page.move(to: CGPoint(x: 200, y: 200))
        page.addLine(to: CGPoint(x: perspective ? 950 : 1000, y: perspective ? 280 : 200))
        page.addLine(to: CGPoint(x: 1000, y: 1400))
        page.addLine(to: CGPoint(x: perspective ? 250 : 200, y: 1400))
        page.close()
        page.fill()
      }
    }
    let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".png")
    try XCTUnwrap(image.pngData()).write(to: url)
    return url
  }

  func testCropsDocumentAndRemovesBackground() throws {
    let url = try fixture(document: true)
    defer { try? FileManager.default.removeItem(at: url) }
    let data = try XCTUnwrap(AppDelegate.cropDocument(path: url.path))
    let image = try XCTUnwrap(UIImage(data: data))
    XCTAssertEqual(image.size.width, 800, accuracy: 40)
    XCTAssertEqual(image.size.height, 1200, accuracy: 40)
  }

  func testCorrectsPerspective() throws {
    let url = try fixture(document: true, perspective: true)
    defer { try? FileManager.default.removeItem(at: url) }
    let data = try XCTUnwrap(AppDelegate.cropDocument(path: url.path))
    let image = try XCTUnwrap(UIImage(data: data))
    XCTAssertLessThan(image.size.width, 1000)
    XCTAssertLessThan(image.size.height, 1400)
    XCTAssertGreaterThan(image.size.height, image.size.width)
  }

  func testDoesNotReturnOriginalWhenNoRectangleExists() throws {
    let url = try fixture(document: false)
    defer { try? FileManager.default.removeItem(at: url) }
    XCTAssertNil(try AppDelegate.cropDocument(path: url.path))
  }

  func testOrientsReceiptTextAtEveryQuarterTurn() throws {
    let format = UIGraphicsImageRendererFormat()
    format.scale = 1
    let source = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 800), format: format).image { context in
      UIColor.white.setFill()
      context.fill(CGRect(x: 0, y: 0, width: 400, height: 800))
      UIColor.red.setFill()
      context.fill(CGRect(x: 20, y: 20, width: 40, height: 40))
      let text = "MARKET RECEIPT\nDATE 05.11.2026\nRECEIPT NUMBER 12345\nBREAD 10.00\nMILK 50.00\nCOFFEE 60.00\nTOTAL 120.00\nTAX 20.00\nTHANK YOU"
      (text as NSString).draw(
        in: CGRect(x: 35, y: 100, width: 350, height: 650),
        withAttributes: [.font: UIFont.systemFont(ofSize: 26), .foregroundColor: UIColor.black]
      )
    }
    let original = try XCTUnwrap(source.cgImage)
    let expected = marker(source)
    XCTAssertLessThan(expected[0], 50)
    XCTAssertGreaterThan(expected[2], 200)
    let context = CIContext()
    for rotation: CGImagePropertyOrientation in [.up, .right, .down, .left] {
      let rotated = CIImage(cgImage: original).oriented(rotation)
      let input = try XCTUnwrap(context.createCGImage(rotated, from: rotated.extent))
      let output = AppDelegate.uprightPortrait(input, context: context)
      XCTAssertLessThan(output.width, output.height)
      let actual = marker(UIImage(cgImage: output))
      for index in 0..<4 {
        XCTAssertEqual(Int(actual[index]), Int(expected[index]), accuracy: 8, "Incorrect direction for \(rotation)")
      }
    }
  }

  private func marker(_ image: UIImage) -> [UInt8] {
    let format = UIGraphicsImageRendererFormat()
    format.scale = 1
    let normalized = UIGraphicsImageRenderer(size: CGSize(width: 100, height: 200), format: format).image { _ in
      image.draw(in: CGRect(x: 0, y: 0, width: 100, height: 200))
    }.cgImage!
    let data = CFDataGetBytePtr(normalized.dataProvider!.data!)!
    let offset = 7 * normalized.bytesPerRow + 7 * 4
    return (0..<4).map { data[offset + $0] }
  }

}
