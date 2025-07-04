require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

# folly_version = '2021.07.22.00'
# folly_compiler_flags = '-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1 -Wno-comma -Wno-shorten-64-to-32'

Pod::Spec.new do |s|
  s.name         = "rn-newarch-svga-player"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  这是一款使用ReactNative[`Android,`iOS`]加载Svga动画的播放器插件
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
  s.source_files    = "ios/**/*.{h,m,mm,swift}"
  install_modules_dependencies(s)

  # s.dependency "React-Core"
  # s.compiler_flags = folly_compiler_flags + " -DRCT_NEW_ARCH_ENABLED=1"
  # s.pod_target_xcconfig    = {
  #   "HEADER_SEARCH_PATHS" => "\"$(PODS_ROOT)/boost\"",
  #   "OTHER_CPLUSPLUSFLAGS" => "-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1",
  #   "CLANG_CXX_LANGUAGE_STANDARD" => "c++17"
  # }

  # s.dependency "React-RCTFabric"
  # s.dependency "React-Codegen"
  # s.dependency "RCT-Folly", folly_version
  # s.dependency "RCTRequired"
  # s.dependency "RCTTypeSafety"
  # s.dependency "ReactCommon/turbomodule/core"
end