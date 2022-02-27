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

import SwiftUI

struct ContentView: View {
    private struct Constants {
        static let horizontalPadding: CGFloat = 32
        static let buttonSize: CGFloat = 80
    }
    
    let viewFinder: some View = CameraFinderView().padding(.horizontal, Constants.horizontalPadding)
    
    @StateObject private var model = ContentViewModel()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if model.frame != nil {
                    ZStack {
                        FrameView(image: model.frame)
                        VStack {
                            Spacer()
                            // Add frame for the user to put the code in
                            Text("Make sure your code is clearly visible in the frame. When you are ready, press the capture button.").multilineTextAlignment(.center).padding(.horizontal)
                            Button(action: {
                                model.processImage(image: model.frame?.cropping(to: CGRect(
                                    x: geometry.size.width / 2,
                                    y: geometry.size.height / 2 + 300,
                                    width: geometry.size.width * 1.7,
                                    height: 300
                                )))
                            }) {
                                Circle().fill(Color.gray).frame(width: Constants.buttonSize, height: Constants.buttonSize, alignment: .center)
                            }.padding(.bottom, Constants.horizontalPadding)
                        }
                        viewFinder.position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    }.edgesIgnoringSafeArea(.all)
                }
                ErrorView(error: model.error)
            }.sheet(isPresented: $model.shouldShowResults, onDismiss: nil, content: {
                ResultsListView(viewModel: model)
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
