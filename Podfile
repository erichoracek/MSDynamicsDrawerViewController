workspace 'MSDynamicsDrawerViewController'
platform :ios, '7.0'

xcodeproj 'Example/Example.xcodeproj'
target 'Example' do
  xcodeproj 'Example/Example.xcodeproj'
  pod 'MSDynamicsDrawerViewController', :path => '.'
  pod 'DynamicXray'
  pod 'Reveal-iOS-SDK'
end
target 'Storyboard Example' do
  xcodeproj 'Example/Example.xcodeproj'
  pod 'MSDynamicsDrawerViewController', :path => '.'
  pod 'DynamicXray'
  pod 'Reveal-iOS-SDK'
end

xcodeproj 'Tests/Tests.xcodeproj'
target 'Functional Tests' do
  xcodeproj 'Tests/Tests.xcodeproj'
  pod 'MSDynamicsDrawerViewController', :path => '.'
  pod 'libextobjc/EXTScope', '~> 0.4'
  pod 'KIF', '~> 3.0'
  pod 'Fingertips', '~> 0.3'
  pod 'Stubbilino', '~> 0.1'
end
target 'Unit Tests' do
  xcodeproj 'Tests/Tests.xcodeproj'
  pod 'MSDynamicsDrawerViewController', :path => '.'
  pod 'OCMockito', '~> 1.3'
  pod 'Aspects', '~> 1.4'
end
target 'Test Host' do
  xcodeproj 'Tests/Tests.xcodeproj'
  pod 'MSDynamicsDrawerViewController', :path => '.'
  pod 'Fingertips', '~> 0.3'
end

post_install do |installer|
  installer.project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SDKROOT'] = 'iphoneos7.1'
    end
  end
end
