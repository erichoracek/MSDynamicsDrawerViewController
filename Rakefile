desc 'Run the Cocoapods library linter on MSDynamicsDrawerViewController'
task :lint do
  sh "pod lib lint MSDynamicsDrawerViewController.podspec"
  exit $?.exitstatus
end

desc 'Run the MSDynamicsDrawerViewController Tests'
task :test do
  `xcodebuild test -scheme 'Tests' -destination 'platform=iOS Simulator,name=iPhone Retina (4-inch)' | xcpretty -c ; exit ${PIPESTATUS[0]}`
  exit $?.exitstatus
end

desc 'Create the MSDynamicsDrawerViewController Docs'
task :docs do
  sh "xcodebuild build -scheme 'Docs'"
  exit $?.exitstatus
end
