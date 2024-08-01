//
//  CustomStructs.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.08.2024.
//

import SwiftUI

struct DropdownMenu<T: Identifiable & CustomStringConvertible>: View {
    @State private var selectedOption: T
    private let options: [T]

    init(options: [T], defaultSelection: T) {
        self.options = options
        self._selectedOption = State(initialValue: defaultSelection)
    }

    var body: some View {
        Menu {
            ForEach(options) { option in
                Button(action: {
                    selectedOption = option
                }) {
                    Text(option.description)
                }
            }
        } label: {
            HStack {
                Text(selectedOption.description)
                Image(systemName: "chevron.down")
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .cornerRadius(8)
        }
    }
}
