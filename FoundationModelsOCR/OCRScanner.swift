import Foundation
import Vision
import UIKit

struct RecognizedWord: Codable {
    let text: String
    let x: CGFloat
    let y: CGFloat
}

class OCRScanner {
    
    /// Scans an invoice image and returns a JSON representation of the recognized words.
    /// - Parameter image: The UIImage of the invoice document.
    /// - Returns: JSON string representing the recognized words with their positions.
    func scanInvoice(from image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "OCRScanner", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot get CGImage from UIImage"])
        }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        return try await withCheckedThrowingContinuation { continuation in
            do {
                try handler.perform([request])
            } catch {
                return continuation.resume(throwing: error)
            }
            guard let observations = request.results else {
                return continuation.resume(throwing: NSError(domain: "OCRScanner", code: 2, userInfo: [NSLocalizedDescriptionKey: "No text found in image"]))
            }

            let recognizedWords = observations.compactMap { obs -> RecognizedWord? in
                guard let candidate = obs.topCandidates(1).first else { return nil }
                let bbox = obs.boundingBox
                return RecognizedWord(text: candidate.string, x: bbox.midX, y: bbox.midY)
            }

            do {
                let jsonData = try JSONEncoder().encode(recognizedWords)
                let jsonString = String(data: jsonData, encoding: .utf8) ?? "[]"
                continuation.resume(returning: jsonString)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
