//
//  CategorySelectorViewModelMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 19.10.2024.
//

@testable import lifeisskillapp

final class CategorySelectorViewModelMock: BaseClass, CategorySelectorViewModeling {
    
    // MARK: - Properties
    var selectedCategory: UserCategory?
    var userCategories: [UserCategory] = []
    
    // MARK: - Tracking calls
    private(set) var onAppearCalled = false
    
    // MARK: - Public Methods
    func onAppear() {
        onAppearCalled = true
        // Simulate loading of user categories if needed
    }
}
