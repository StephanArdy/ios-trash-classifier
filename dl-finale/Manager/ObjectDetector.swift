//
//  ObjectDetector.swift
//  dl-finale
//
//  Created by stephan on 27/05/26.
//

import Vision

class ObjectDetector {
    private var requests = [VNRequest]()
    
    init() {
        setupVision()
    }
    
    private func setupVision() {
        guard let modelURL = Bundle.main.url(forResource: "YOLOv3",
                                           withExtension: "mlmodelc") else {
            return
        }
        
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let objectRecognition = VNCoreMLRequest(model: visionModel) { request, error in
                guard let results = request.results as? [VNRecognizedObjectObservation] else {
                    return
                }
                
                self.processResults(results)
            }
            requests = [objectRecognition]
        } catch {
            print("Vision setup error: \(error.localizedDescription)")
        }
    }
    
    func detectObjects(in pixelBuffer: CVPixelBuffer) {
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        
        do {
            try handler.perform(requests)
        } catch {
            print("Detection error: \(error.localizedDescription)")
        }
    }
    
    private func processResults(_ results: [VNRecognizedObjectObservation]) {
        let detectedObjects = results.map { observation -> DetectedObject in
            let label = observation.labels.first?.identifier ?? "Unknown"
            let confidence = observation.confidence
            let boundingBox = observation.boundingBox
            
            return DetectedObject(
                label: label,
                confidence: confidence,
                boundingBox: boundingBox
            )
        }
        
        DispatchQueue.main.async {
            // Update UI with detected objects
            NotificationCenter.default.post(
                name: .detectedObjectsUpdated,
                object: detectedObjects
            )
        }
    }
}

struct DetectedObject: Identifiable {
    let id = UUID()
    let label: String
    let confidence: Float
    let boundingBox: CGRect
}
