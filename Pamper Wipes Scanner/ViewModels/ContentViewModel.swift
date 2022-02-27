/// Copyright (c) 2021 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import CoreImage
import Vision

class ContentViewModel: ObservableObject {
    @Published var error: Error?
    @Published var frame: CGImage?
    @Published var possibleCodes = Set<String>()
    @Published var shouldShowResults: Bool = false

    private let context = CIContext()
    

    private let cameraManager = CameraManager.shared
    private let frameManager = FrameManager.shared
    
    var inputImage: CIImage?

    init() {
        setupSubscriptions()
    }

    func setupSubscriptions() {
        // swiftlint:disable:next array_init
        cameraManager.$error
          .receive(on: RunLoop.main)
          .map { $0 }
          .assign(to: &$error)

        frameManager.$current
          .receive(on: RunLoop.main)
          .compactMap { buffer in
            guard let image = CGImage.create(from: buffer) else {
                return nil
            }

            let ciImage = CIImage(cgImage: image)

            return self.context.createCGImage(ciImage, from: ciImage.extent)
        }
        .assign(to: &$frame)
    }

    func processImage(image: CGImage?) {
        guard let image = image else {
            return
        }
        
        self.inputImage = CIImage(cgImage: image, options: nil)
        
        let imageRequestHandler = VNImageRequestHandler(ciImage: inputImage ?? CIImage(), options: [:])
        let request = VNRecognizeTextRequest(completionHandler: self.handleDetection)
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en_US"]

        let requests = [
            request
        ]

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform(requests)
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
                return
            }
        }
    }
    
    func handleDetection(request: VNRequest?, error: Error?) {
        if let error = error {
            self.error = error
            return
        }
        guard let results = request?.results, results.count > 0 else {
            print("No text found")
            return
        }

        for result in results {
            if let observation = result as? VNRecognizedTextObservation {
                for text in observation.topCandidates(1) {
                    NSLog("Observed string: \(text.string)")
                    self.addResultCandidates(string: text.string)
                }
                
                if !possibleCodes.isEmpty {
                    self.shouldShowResults.toggle()
                }
            }
        }
    }
    
    func addResultCandidates(string: String) {
        let subStrings = string.split(separator: " ")
        
        for subString in subStrings {
            if validateCandidate(string: String(subString)) {
                NSLog("Added \(String(subString)) as a possible code")
                self.possibleCodes.insert(String(subString))
                NSLog("Possible Codes: \(self.possibleCodes)")
            }
        }
        
        var testString = string
        testString.removeAll(where: { !$0.isLetter && !$0.isNumber })
        if validateCandidate(string: testString) {
            NSLog("Added \(testString) as a possible code")
            self.possibleCodes.insert(testString)
            NSLog("Possible Codes: \(self.possibleCodes)")
        }
        
    }
    
    func validateCandidate(string: String) -> Bool {
        return 14 ... 16 ~= string.count
    }
}

