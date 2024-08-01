//
//  CustomStructs.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.08.2024.
//

import SwiftUI

struct DropdownMenu: View {
    @State private var selectedOption: String = "Option 1"
    private let options = ["Option 1", "Option 2"]

    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    selectedOption = option
                }) {
                    Text(option)
                }
            }
        } label: {
            HStack {
                Text(selectedOption)
                Image(systemName: "chevron.down")
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .cornerRadius(8)
        }
    }
}
