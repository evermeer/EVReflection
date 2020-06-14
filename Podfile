source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!
workspace 'EVReflection'

# Our Libraries (just include everything for the demo)
def alllibraries
  pod 'EVReflection/MoyaRxSwiftXML', :path => "./"
  pod 'EVReflection/MoyaReactiveSwiftXML', :path => "./"
  pod 'EVReflection/Realm', :path => "./"
  pod 'EVReflection/CloudKit', :path => "./"
  pod 'EVReflection/CoreData', :path => "./"
end

target 'Performance.Test' do
  project 'PerformanceTest/PerformanceTest'
  platform :ios, '10.0'
  pod 'EVReflection/Core', :path => "./"
end

target 'UnitTestsiOS' do
    project 'UnitTests/UnitTests'
    platform :ios, '10.0'
    alllibraries
end

target 'UnitTestsOSX' do
    project 'UnitTests/UnitTests'
    platform :osx, '10.12'
    alllibraries
end

target 'UnitTestsTVOS' do
    project 'UnitTests/UnitTests'
    platform :tvos, '10.0'
    alllibraries
end

target '44Demo5' do
    project 'Demo/Demo'
    platform :ios, '10.0'
    alllibraries
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '5.0'
        end
    end
end

