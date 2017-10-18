source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!
workspace 'EVReflection'

# Our Libraries (just include everything for the demo)
def alllibraries
    #temp Swift 4 force version
    # pod 'RxSwift', :git => 'https://github.com/ReactiveX/RxSwift.git', :branch => '4.0.0-rc.0'
    pod 'Moya', :git => 'https://github.com/Moya/Moya.git', :branch => '10.0.0-dev'
  
  pod 'EVReflection/MoyaRxSwiftXML', :path => "./"
  pod 'EVReflection/MoyaReactiveSwiftXML', :path => "./"
  pod 'EVReflection/Realm', :path => "./"
  pod 'EVReflection/CloudKit', :path => "./"
  pod 'EVReflection/CoreData', :path => "./"
end

target 'Performance.Test' do
  project 'PerformanceTest/PerformanceTest'
  platform :ios, '9.0'
  pod 'EVReflection/Core', :path => "./"
end


target 'UnitTestsiOS' do
    project 'UnitTests/UnitTests'
    platform :ios, '9.0'
    alllibraries
end

target 'UnitTestsOSX' do
    project 'UnitTests/UnitTests'
    platform :osx, '10.11'
    alllibraries
end

target 'UnitTestsTVOS' do
    project 'UnitTests/UnitTests'
    platform :tvos, '9.0'
    alllibraries
end

target 'Demo' do
    project 'Demo/Demo'
    platform :ios, '9.0'
    alllibraries
end



