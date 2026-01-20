import Flutter
import UIKit
import Vision

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let ocrChannel = FlutterMethodChannel(name: "com.refi.ocr/text_recognition",
                                          binaryMessenger: controller.binaryMessenger)
    
    ocrChannel.setMethodCallHandler { (call, result) in
      if call.method == "extractText" {
        if let args = call.arguments as? [String: Any],
           let path = args["path"] as? String {
          self.extractText(from: path, result: result)
        } else {
          result(FlutterError(code: "NO_PATH", message: "No image path provided", details: nil))
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func extractText(from path: String, result: @escaping FlutterResult) {
    let url = URL(fileURLWithPath: path)
    guard let image = CIImage(contentsOf: url) else {
        result(FlutterError(code: "INVALID_IMAGE", message: "Cannot load image", details: nil))
        return
    }

    let request = VNRecognizeTextRequest { (request, error) in
      if let err = error {
        result(FlutterError(code: "OCR_FAILED", message: err.localizedDescription, details: nil))
        return
      }

      let observations = request.results as? [VNRecognizedTextObservation] ?? []
      let text = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
      
      // Return text or empty string (don't return error message)
      result(text.isEmpty ? "" : text)
    }
    
    // Arabic language support
    request.recognitionLanguages = ["ar", "en"]
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true

    let handler = VNImageRequestHandler(ciImage: image, options: [:])
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        try handler.perform([request])
      } catch {
        result(FlutterError(code: "OCR_FAILED", message: error.localizedDescription, details: nil))
      }
    }
  }
}
