source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!
workspace 'EVReflection'

# Our Libraries (just include everything for the demo)
def libraries
  pod 'EVReflection/CloudKit', :path => "./"
  pod 'EVReflection/MoyaRxSwiftXML', :path => "./"
  pod 'EVReflection/MoyaReactiveSwiftXML', :path => "./"
end

target 'PerformanceTest' do
  project 'PerformanceTest/PerformanceTest'
  platform :ios, '8.0'
  pod 'EVReflection/Core', :path => "./"
end


target 'UnitTestsiOS' do
    project 'UnitTests/UnitTests'
    platform :ios, '9.0'
    libraries
end

target 'UnitTestsOSX' do
    project 'UnitTests/UnitTests'
    platform :osx, '10.10'
    libraries
end

target 'UnitTestsTVOS' do
    project 'UnitTests/UnitTests'
    platform :tvos, '9.0'
    libraries
end

target 'Demo' do
    project 'Demo/Demo'
    platform :ios, '8.0'
    libraries
end



