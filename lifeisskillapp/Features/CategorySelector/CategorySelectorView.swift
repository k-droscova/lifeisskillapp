//
//  CategorySelectorView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 02.08.2024.
//

import SwiftUI

struct CategorySelectorView<ViewModel: CategorySelectorViewModeling>: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        HStack {
            Text(viewModel.username)
                .padding()
                .headline3
            Spacer()
            DropdownMenu(
                options: viewModel.userCategories,
                selectedOption: $viewModel.selectedCategory,
                placeholder: "home.category_selector"
            )
            .subheadline
            .foregroundsSecondary
        }
    }
}

// Mock CategorySelectorViewModeling
final class MockCategorySelectorViewModel: BaseClass, ObservableObject, CategorySelectorViewModeling {
    // MARK: - Public Properties
    @Published var selectedCategory: UserCategory?
    var username: String = "TestUser"
    var userCategories: [UserCategory]

    // MARK: - Initialization
    override init() {
        self.userCategories = [
            UserCategory(id: "1", name: "Category 1", detail: "Description 1", isPublic: true),
            UserCategory(id: "2", name: "Category 2", detail: "Description 2", isPublic: false),
            UserCategory(id: "3", name: "Category 3", detail: "Description 3", isPublic: true)
        ]
        self.selectedCategory = userCategories.first
    }
}

// Preview for CategorySelectorView with MockCategorySelectorViewModel
struct CategorySelectorView_Previews: PreviewProvider {
    static var previews: some View {
        let mockViewModel = MockCategorySelectorViewModel()
        CategorySelectorView(viewModel: mockViewModel)
    }
}
