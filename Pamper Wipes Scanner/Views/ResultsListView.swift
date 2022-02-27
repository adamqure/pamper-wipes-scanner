//
//  ResultsListView.swift
//  Pamper Wipes Scanner
//
//  Created by Adam Ure on 2/22/22.
//

import SwiftUI

struct ResultsListView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        List {
            Section(header: Text("Possible Codes").font(.largeTitle)) {
                ForEach(Array(viewModel.possibleCodes), id: \.self) { code in
                    HStack {
                        Text(code).font(.title2).fontWeight(.medium)
                        Spacer()
                        Button(action: {
                            let pasteBoard = UIPasteboard.general
                            pasteBoard.string = code
                        }) {
                            Image(systemName: "doc.on.clipboard").padding()
                        }.background(Color.gray).clipShape(Circle())
                    }.padding(.horizontal, 16).padding(.vertical)
                }
            }
        }.listStyle(.grouped).padding(.vertical)
    }
}

struct ResultsListView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsListView(viewModel: ContentViewModel())
    }
}
