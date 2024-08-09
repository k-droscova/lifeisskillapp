//
//  LocationStatusBarView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 06.08.2024.
//

import SwiftUI

struct LocationStatusBarView<ViewModel: LocationStatusBarViewModeling>: View {
    @StateObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        HStack {
            locationText
                .frame(width: LocationStatusBarViewConstants.locationTextWidth, alignment: .leading)
            Spacer()
            statusIndicators
            Spacer()
            appVersionText
        }
        .foregroundStyle(CustomColors.LocationStatusBar.foreground.color)
        .locationCaption
        .padding([.leading, .trailing])
    }
    
    @ViewBuilder
    private var locationText: some View {
        if let location = viewModel.userLocation, viewModel.isGpsOk {
            Text(location.description)
        } else {
            Text("locationStatusBar.waiting")
        }
    }
    
    private var statusIndicators: some View {
        HStack(spacing: 16) {
            StatusView(
                status: $viewModel.isOnline,
                textOn: "ONLINE",
                textOff: "OFFLINE",
                colorOn: CustomColors.LocationStatusBar.statusOn.color,
                colorOff: CustomColors.LocationStatusBar.statusOff.color
            )
            StatusView(
                status: $viewModel.isGpsOk,
                textOn: "GPS OK",
                textOff: "GPS OFF",
                colorOn: CustomColors.LocationStatusBar.statusOn.color,
                colorOff: CustomColors.LocationStatusBar.statusOff.color
            )
        }
    }
    
    private var appVersionText: some View {
        Text(viewModel.appVersion)
    }
}

struct LocationStatusBarViewConstants {
    static let locationTextWidth: CGFloat = 180
}

/*class MockLocationStatusBarViewModel: BaseClass, LocationStatusBarViewModeling, ObservableObject {
    required init(dependencies: any HasUserDefaultsStorage & HasLoggers & HasLocationManager) {
        // Mock implementation - no actual initialization needed for dependencies
        super.init()
    }
    
    @Published var appVersion: String = "1.0.0"
    @Published var isOnline: Bool = true
    @Published var isGpsOk: Bool = true
    @Published var userLocation: UserLocation? = UserLocation(latitude: 49.132, longitude: 20.35007, altitude: 726.1, accuracy: 24.6, timestamp: Date())
}

struct LocationStatusBarView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide dummy dependencies for the mock
        let dependencies = MockDependencies()
        LocationStatusBarView(viewModel: MockLocationStatusBarViewModel(dependencies: dependencies))
    }
}

struct MockDependencies: HasUserDefaultsStorage & HasLoggers & HasLocationManager {
    var logger: LoggerServicing = MockLogger()
    var userDefaultsStorage: UserDefaultsStoraging = MockUserDefaultsStorage()
    var locationManager: LocationManaging = MockLocationManager()
}

class MockLogger: LoggerServicing {
    func _log(message: String?, event: (any Loggable)?) {
        print("Mock log: \(String(describing: message))")
    }
}

class MockUserDefaultsStorage: UserDefaultsStoraging {
    var locationStream: AsyncStream<UserLocation?> {
        AsyncStream { continuation in
            // Provide mock GPS data
            continuation.yield(nil)
        }
    }
    
    var appId: String?
    var location: UserLocation?
    var checkSumData: CheckSumData?
    
    // Add other properties and methods as required...
}

class MockLocationManager: LocationManaging {
    var delegate: LocationManagerFlowDelegate?
    
    var gpsStream: AsyncStream<Bool> {
        AsyncStream { continuation in
            // Provide mock GPS data
            continuation.yield(true)
        }
    }
    
    var gpsStatus: Bool = true
    
    func checkLocationAuthorization() {
        // Mock implementation
    }
}
*/
