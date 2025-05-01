//
//  MapPointDetailViewModelTests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 19.10.2024.
//

import XCTest
import Combine
import SwiftUI
@testable import lifeisskillapp

final class MapPointDetailViewModelTests: XCTestCase {
    
    // MARK: - Mocks
    var genericPointManagerMock: GenericPointManagerMock!
    var loggerMock: LoggingServiceMock!
    
    struct Dependencies: MapPointDetailViewModel.Dependencies {
        var genericPointManager: any GenericPointManaging
        var logger: LoggerServicing
    }
    
    // ViewModel to test
    var viewModel: MapPointDetailViewModel!
    
    // MARK: - Setup
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Initialize mocks
        genericPointManagerMock = GenericPointManagerMock()
        loggerMock = LoggingServiceMock()
    }
    
    override func tearDownWithError() throws {
        genericPointManagerMock = nil
        loggerMock = nil
        viewModel = nil
        
        try super.tearDownWithError()
    }
    
    // MARK: - Tests
    
    func testViewModel_InitialValuesAreCorrect() {
        // Arrange: Create the point for this test
        let mockPoint = GenericPoint.mock(id: "123", pointName: "Test Point", pointValue: 100, pointType: .virtual, sponsorId: "random", hasDetail: true)
        let dependencies: Dependencies = .init(genericPointManager: genericPointManagerMock, logger: loggerMock)
        // Initialize the ViewModel with the specific mockPoint
        viewModel = MapPointDetailViewModel(dependencies: dependencies, point: mockPoint)
        
        // Assert that the properties are initialized correctly
        XCTAssertEqual(viewModel.pointName, "Test Point", "Expected pointName to match the mock data.")
        XCTAssertEqual(viewModel.pointValueText, "Point value: 100", "Expected pointValueText to be formatted correctly.")
        XCTAssertEqual(viewModel.sponsorText, NSLocalizedString("map.detail.sponsor", comment: ""), "Expected sponsorText to match the localized value.")
        XCTAssertTrue(viewModel.hasDetail, "Expected hasDetail to be true based on the mock point.")
        XCTAssertEqual(viewModel.icon, PointType.virtual.icon, "Expected icon to be the virtual icon.")
        
        // Test the detail URL generation
        let expectedURL = URL(string: "\(APIUrl.detailUrl)123") // Mocking a detail URL for point ID 123
        XCTAssertEqual(viewModel.detailURL, expectedURL, "Expected detail URL to be generated correctly.")
    }
    
    func testOnAppear_SuccessfulImageFetch() async {
        // Arrange
        let mockPoint = GenericPoint.mock(pointName: "Sponsor Point", pointValue: 50, pointType: .culture, sponsorId: "123", hasDetail: true)
        
        let dependencies: Dependencies = .init(genericPointManager: genericPointManagerMock, logger: loggerMock)
        viewModel = MapPointDetailViewModel(dependencies: dependencies, point: mockPoint)
        let sponsorImageExpectation = XCTestExpectation(description: "sponsorImage is set when image is fetched successfully")
        let sponsorImageCancellable = viewModel.$sponsorImage
            .dropFirst() // Skip the initial nil value
            .sink { image in
                if image != nil {
                    sponsorImageExpectation.fulfill()
                }
            }
        // Act
        viewModel.onAppear()
        
        // Wait for the sponsorImage to be set
        await fulfillment(of: [sponsorImageExpectation], timeout: 2.0)
        
        // Assert that the correct sponsorId was requested
        XCTAssertTrue(genericPointManagerMock.sponsorImageCalled, "Expected the sponsorImage method to be called.")
        XCTAssertEqual(genericPointManagerMock.sponsorIdRequest, "123", "Expected the correct sponsorId to be requested.")
        // Check that the sponsorImage is set correctly
        XCTAssertNotNil(viewModel.sponsorImage, "Expected sponsorImage to be set when the image fetch is successful.")
        sponsorImageCancellable.cancel()
    }
}
