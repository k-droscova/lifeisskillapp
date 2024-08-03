//
//  CustomStructs.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.08.2024.
//

import SwiftUI

struct DropdownMenu<T: Identifiable & CustomStringConvertible>: View {
    @Binding private var selectedOption: T?
    private let options: [T]
    private let placeholder: Text

    init(options: [T], selectedOption: Binding<T?>, placeholder: Text = Text("home.category_selector")) {
        self.options = options
        self._selectedOption = selectedOption
        self.placeholder = placeholder
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
                if let description = selectedOption?.description {
                    Text(description)
                }
                else {
                    placeholder
                }
                Image(systemName: "chevron.down")
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .cornerRadius(8)
        }
    }
}
