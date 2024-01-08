//
//  ToggleButton.swift
//  NaturalReminder
//
//  Created by Juan Carrera on 08.10.2023.
//

import Foundation
import SwiftUI

struct ToggleButton: View {
    var isToggled: Bool
    var toggleAction: () -> Void
    var trueColor: Color
    var falseColor: Color

    var body: some View {
        Button(action: toggleAction) {
            Text("\u{2714}").foregroundColor(isToggled ? trueColor : falseColor)
        }
    }
}
