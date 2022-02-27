//
//  CameraFinderView.swift
//  Pamper Wipes Scanner
//
//  Created by Adam Ure on 2/22/22.
//

import SwiftUI

struct CameraFinderView: View {
    private struct Constants {
        static let cornerRadius: CGFloat = 32
        static let frameHeight: CGFloat = 150
        static let borderWidth: CGFloat = 4
    }

    var body: some View {
        RoundedRectangle(cornerRadius: Constants.cornerRadius).fill(Color.clear).overlay(
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .stroke(Color.gray, lineWidth: Constants.borderWidth)
        ).frame(height: Constants.frameHeight, alignment: .center)

    }
}

struct CameraFinderView_Previews: PreviewProvider {
    static var previews: some View {
        CameraFinderView()
    }
}
