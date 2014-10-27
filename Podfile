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
  pod 'libextobjc/EXTScope'
  pod 'KIF'
  pod 'Fingertips'
  pod 'Stubbilino'
end
target 'Unit Tests' do
  xcodeproj 'Tests/Tests.xcodeproj'
  pod 'MSDynamicsDrawerViewController', :path => './MSDynamicsDrawerViewController.podspec'
  pod 'OCMockito'
  pod 'Aspects'
end
target 'Test Host' do
  xcodeproj 'Tests/Tests.xcodeproj'
  pod 'MSDynamicsDrawerViewController', :path => './MSDynamicsDrawerViewController.podspec'
  pod 'Fingertips'
end
