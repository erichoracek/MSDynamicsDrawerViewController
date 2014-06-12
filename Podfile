workspace 'MSDynamicsDrawerViewController'
platform :ios, '7.0'

xcodeproj 'Example/Example.xcodeproj'
target 'Example' do
  xcodeproj 'Example/Example.xcodeproj'
  pod 'MSDynamicsDrawerViewController', :path => '.'
  pod 'DynamicXray'
end
target 'Storyboard Example' do
  xcodeproj 'Example/Example.xcodeproj'
  pod 'MSDynamicsDrawerViewController', :path => '.'
  pod 'DynamicXray'
end

xcodeproj 'Tests/Tests.xcodeproj'
target 'Tests' do
  xcodeproj 'Tests/Tests.xcodeproj'
  pod 'MSDynamicsDrawerViewController', :path => '.'
  pod 'libextobjc/EXTScope', '~> 0.4'
  pod 'KIF', '~> 3.0'
  pod 'Fingertips', '~> 0.3'
  pod 'Stubbilino', '~> 0.1'
end
target 'Test Host' do
  xcodeproj 'Tests/Tests.xcodeproj'
  pod 'MSDynamicsDrawerViewController', :path => '.'
  pod 'Fingertips', '~> 0.3'
end
