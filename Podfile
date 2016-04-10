source 'https://github.com/CocoaPods/Specs.git'

platform :ios, "7.0"

target "hackfoldr-iOS" do
  pod 'AFNetworking', '~> 2.3'
  pod 'AFNetworking/UIKit'
  pod 'Bolts', '~> 1.0'
  pod 'AFCSVParserResponseSerializer'
  pod 'MagicalRecord', '~> 2.2'

  pod 'QuickDialog', :git => 'https://github.com/escoz/QuickDialog', :branch => 'master'
  pod 'TOWebViewController'

  pod 'React', :git => 'https://github.com/facebook/react-native/',
      :subspecs => [
        'ART',
        'RCTActionSheet',
        'RCTAdSupport',
        'RCTGeolocation',
        'RCTImage',
        'RCTLinkingIOS',
        'RCTNetwork',
        'RCTSettings',
        'RCTText',
        'RCTVibration',
        'RCTWebSocket'
      ], :tag => 'v0.23.1'

  # Track crash
  pod 'Fabric'
  pod 'Crashlytics'
end

target "hackfoldr-iOSTests" do
  pod 'OHHTTPStubs'
  pod 'OHHTTPStubs/XCTestExpectation'
end

