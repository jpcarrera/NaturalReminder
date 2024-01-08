//
//  BottomFieldText.swift
//  NaturalReminder
//
//  Created by Juan Carrera on 08.10.2023.
//

import Foundation
import SwiftUI

struct BottomTextField: View {
    @Binding var inputText: String
    var onCommit: () -> Void

    var body: some View {
        TextField("Type reminder here...", text: $inputText, onCommit: onCommit)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
    }
}
