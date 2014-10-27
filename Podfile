source 'https://github.com/CocoaPods/Specs'

workspace 'MSDynamicsDrawerViewController'
platform :ios, '7.0'

xcodeproj 'Example/Example.xcodeproj'
target 'Example' do
  xcodeproj 'Example/Example.xcodeproj'
  pod 'MSDynamicsDrawerViewController', :path => './MSDynamicsDrawerViewController.podspec'
end
target 'Storyboard Example' do
  xcodeproj 'Example/Example.xcodeproj'
  pod 'MSDynamicsDrawerViewController', :path => './MSDynamicsDrawerViewController.podspec'
end

xcodeproj 'Tests/Tests.xcodeproj'
target 'Functional Tests' do
  xcodeproj 'Tests/Tests.xcodeproj'
  pod 'MSDynamicsDrawerViewController', :path => './MSDynamicsDrawerViewController.podspec'
  pod 'libextobjc/EXTScope', '~> 0.4'
  pod 'KIF', '~> 3.0'
  pod 'Fingertips', '~> 0.3'
  pod 'Stubbilino', '~> 0.1'
end
target 'Unit Tests' do
  xcodeproj 'Tests/Tests.xcodeproj'
  pod 'MSDynamicsDrawerViewController', :path => './MSDynamicsDrawerViewController.podspec'
  pod 'OCMockito', '~> 1.3'
  pod 'Aspects', '~> 1.4'
end
target 'Test Host' do
  xcodeproj 'Tests/Tests.xcodeproj'
  pod 'MSDynamicsDrawerViewController', :path => './MSDynamicsDrawerViewController.podspec'
  pod 'Fingertips', '~> 0.3'
end
