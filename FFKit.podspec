#
# Be sure to run `pod lib lint FFKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FFKit'
  s.version          = '0.1.0'
  s.summary          = 'A short description of FFKit.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Pancf/FFKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Pancf' => 'panchenfeng@stu.xmu.edu.cn' }
  s.source           = { :git => 'https://github.com/Pancf/FFKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'FFKit/Classes/**/*'
  
  # s.resource_bundles = {
  #   'FFKit' => ['FFKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
