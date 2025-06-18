require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

fabric_enabled = ENV['RCT_NEW_ARCH_ENABLED'] == '1'

Pod::Spec.new do |s|
  s.name         = "react-native-svga-player"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  这是一款使用ReactNative加载Svga动画的播放器插件 [Android/ios/harmony]三端统一
                   DESC
  s.homepage     = "https://github.com/yrjwcharm/react-native-svga-player"
  s.license      = "MIT"
  # s.license    = { :type => "MIT", :file => "FILE_LICENSE" }
  s.authors      = { "闫瑞锋" => "xlyanrui@sina.com" }
  s.platforms    = { :ios => "12.0" }
  s.source       = { :git => "https://github.com/yrjwcharm/react-native-svga-player.git", :tag => "#{s.version}" }
  s.requires_arc   = true
  s.dependency "SVGAPlayer"
  s.dependency 'Protobuf', '3.22.1'
  if fabric_enabled
    s.platforms       = { ios: '11.0', tvos: '11.0' }
    s.source_files    = 'ios/**/*.{h,m,mm,cpp}'
    s.requires_arc    = true
    install_modules_dependencies(s)

  else
    s.platform       = :ios, '8.0'
    s.source_files   = 'ios/**/*.{h,m,mm}'
    s.dependency     'React-Core'
  end
end