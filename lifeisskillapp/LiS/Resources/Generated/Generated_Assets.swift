// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Events {
    internal static let clock = ImageAsset(name: "clock")
    internal static let eventsMarker = ImageAsset(name: "eventsMarker")
    internal static let locationMarker = ImageAsset(name: "locationMarker")
    internal static let message = ImageAsset(name: "message")
    internal static let screenEvents = ImageAsset(name: "screenEvents")
  }
  internal static let launchScreen = ImageAsset(name: "LaunchScreen")
  internal enum Map {
    internal static let ball = ImageAsset(name: "ball")
    internal static let cultureMarker = ImageAsset(name: "cultureMarker")
    internal static let environmentMarker = ImageAsset(name: "environmentMarker")
    internal static let leaf = ImageAsset(name: "leaf")
    internal static let museum = ImageAsset(name: "museum")
    internal static let sportMarker = ImageAsset(name: "sportMarker")
  }
  internal enum Onboarding {
    internal static let onboardingActivity = ImageAsset(name: "onboarding_activity")
    internal static let onboardingFind = ImageAsset(name: "onboarding_find")
    internal static let onboardingHelp = ImageAsset(name: "onboarding_help")
    internal static let onboardingPoint = ImageAsset(name: "onboarding_point")
    internal static let onboardingPrizes = ImageAsset(name: "onboarding_prizes")
    internal static let onboardingWeb = ImageAsset(name: "onboarding_web")
  }
  internal enum PointList {
    internal static let cultureIcon = ImageAsset(name: "cultureIcon")
    internal static let environmentIcon = ImageAsset(name: "environmentIcon")
    internal static let pointListBoy = ImageAsset(name: "pointListBoy")
    internal static let pointListGirl = ImageAsset(name: "pointListGirl")
    internal static let sportIcon = ImageAsset(name: "sportIcon")
  }
  internal enum Settings {
    internal static let facebook = ImageAsset(name: "facebook")
    internal static let instagram = ImageAsset(name: "instagram")
    internal static let settings = ImageAsset(name: "settings")
    internal static let settingsa = ImageAsset(name: "settingsa")
    internal static let web = ImageAsset(name: "web")
  }
  internal enum Stats {
    internal static let cumWh = ImageAsset(name: "cumWh")
    internal static let statsBoy = ImageAsset(name: "statsBoy")
    internal static let statsGirl = ImageAsset(name: "statsGirl")
    internal static let statsScreen = ImageAsset(name: "statsScreen")
    internal static let trophyBronze = ImageAsset(name: "trophyBronze")
    internal static let trophyButton = ImageAsset(name: "trophyButton")
    internal static let trophyButtonA = ImageAsset(name: "trophyButtonA")
    internal static let trophyGold = ImageAsset(name: "trophyGold")
    internal static let trophySilver = ImageAsset(name: "trophySilver")
  }
  internal enum TabBar {
    internal static let account = ImageAsset(name: "account")
    internal static let calendar = ImageAsset(name: "calendar")
    internal static let calendarAlert = ImageAsset(name: "calendarAlert")
    internal static let map = ImageAsset(name: "map")
    internal static let plus = ImageAsset(name: "plus")
    internal static let trophy = ImageAsset(name: "trophy")
  }
  internal static let check = ImageAsset(name: "check")
  internal static let close = ImageAsset(name: "close")
  internal static let closePres = ImageAsset(name: "close_pres")
  internal static let disclosure = ImageAsset(name: "disclosure")
  internal static let flashSelected = ImageAsset(name: "flash_selected")
  internal static let flashUnselected = ImageAsset(name: "flash_unselected")
  internal static let frame = ImageAsset(name: "frame")
  internal static let help = ImageAsset(name: "help")
  internal static let helpA = ImageAsset(name: "helpA")
  internal static let homeImage = ImageAsset(name: "home_image")
  internal static let loginScreen = ImageAsset(name: "loginScreen")
  internal static let pointListScreen = ImageAsset(name: "pointListScreen")
  internal static let registerScreen = ImageAsset(name: "registerScreen")
  internal static let scannedCheck = ImageAsset(name: "scanned_check")
  internal static let wrong = ImageAsset(name: "wrong")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Image {
  init(asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
