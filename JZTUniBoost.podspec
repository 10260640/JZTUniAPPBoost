#
# Be sure to run `pod lib lint JZTUniBoost.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JZTUniBoost'
  s.version          = '1.0.1'
  s.summary          = 'A short description of JZTUniBoost.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/8772037@qq.com/JZTUniBoost'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '8772037@qq.com' => '8772037@qq.com' }
  s.source           = { :git => '', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'JZTUniBoost/Classes/**/*'
  s.xcconfig = { 'USER_HEADER_SEARCH_PATHS' => 'JZTUniBoost/Classes/UniApp/Headers/**/*.{h}' }
  s.static_framework = true
  s.ios.vendored_libraries = 'JZTUniBoost/SDKs/libraries/*.a'
  s.ios.vendored_frameworks = 'JZTUniBoost/SDKs/frameworks/*.framework'
  s.libraries ='c++'
  s.frameworks ='JavaScriptCore','CoreMedia','MediaPlayer','AVFoundation','AVKit','GLKit','OpenGLES','CoreText','QuartzCore','CoreGraphics','QuickLook','CoreTelephony','AssetsLibrary','CoreLocation','AddressBook','Photos'
  s.resources = 'JZTUniBoost/Assets/Resources/*.*'

  # s.resource_bundles = {
  #   'JZTUniBoost' => ['JZTUniBoost/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'AFNetworking', '~> 3.2.0'
#  s.dependency 'YYKit', '~> 1.0.9'
#  s.dependency 'SDWebImage', '~> 4.3.2'

end
