
Pod::Spec.new do |spec|
  spec.name         = "BentrockCharts"
  spec.version      = "0.1.0"
  spec.summary      = "A library created in swift to draw chats."
  spec.description  = <<-DESC
  This library is created to render the chart based on the data provided in json format.
                   DESC
  spec.homepage     = "https://github.com/Ronaldksunny/BentrockCharts/blob/master/README.md"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author     = { "Ronald K Sunny" => "ronaldksunny@gmail.com" }
  spec.ios.deployment_target = "11.0"
  spec.swift_version = "4.2"
  spec.source       = { :git => "https://github.com/Ronaldksunny/BentrockCharts.git", :tag => "#{spec.version}" }
  spec.public_header_files = "SDK/BentrockCharts.xcframework/ios-armv7_arm64/BentrockCharts.framework/Headers/*.h"
  spec.source_files = "SDK/BentrockCharts.xcframework/ios-armv7_arm64/BentrockCharts.framework/Headers/*.h"
  spec.vendored_frameworks = "SDK/BentrockCharts.xcframework"
end
