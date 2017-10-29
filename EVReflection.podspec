Pod::Spec.new do |s|
  s.name         = "EVReflection"
  s.version      = "5.1.6"
  s.summary      = "Reflection based (Dictionary, CKRecord, NSManagedObject, Realm, JSON and XML) object mapping with extensions for Alamofire and Moya with RxSwift or ReactiveSwift"

  s.description  = <<-EOS
[Reflection](https://github.com/evermeer/EVReflection) based object mapping (dictionary, Json, XML, CKRecord)
including extensions for [Alamofire](https://github.com/Alamofire/Alamofire) and [Moya](https://github.com/Moya/Moya) for network abstraction. And on top of that extension for [RxSwift](https://github.com/ReactiveX/RxSwift/) and [ReactiveSwift]
EOS

  s.homepage     = "https://github.com/evermeer/EVReflection"
  s.license      = { :type => "MIT", :file => "License" }
  s.author             = { "Edwin Vermeer" => "edwin@evict.nl" }
  s.social_media_url   = "http://twitter.com/evermeer"

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.11'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }

  s.source       = { :git => "https://github.com/evermeer/EVReflection.git", :tag => s.version }
  s.default_subspec = "Core"

# This is the core EVReflection library
  s.subspec "Core" do |ss|
    ss.source_files  = "Source/*.swift"
    ss.framework  = "Foundation"
  end

# Extending EVReflection with XMLDictionary functions.
  s.subspec "XML" do |ss|
    ss.source_files  = "Source/XML/*.swift"
    ss.dependency "EVReflection/Core"
    ss.dependency "XMLDictionary"
  end

# Extending EVReflection with Realm functions.
  s.subspec "Realm" do |ss|
    ss.source_files  = "Source/Realm/*.swift"
    ss.dependency "EVReflection/Core"
    ss.dependency "RealmSwift"
  end

# Extending EVReflection with mapping functions for CKRecord (CloudKit)
  s.subspec "CloudKit" do |ss|
    # CloudKit needs Watch OS version 3.0
    ss.ios.deployment_target = '8.0'
    ss.osx.deployment_target = '10.11'
    ss.watchos.deployment_target = '3.0'
    ss.tvos.deployment_target = '9.0'
    ss.source_files  = "Source/CloudKit/*.swift"
    ss.dependency "EVReflection/Core"
    ss.framework  = "CloudKit"
  end

# Extending EVReflection with mapping functions for NSManagedObject (CoreData)
  s.subspec "CoreData" do |ss|
    ss.source_files  = "Source/CoreData/*.swift"
    ss.dependency "EVReflection/Core"
    ss.framework  = "CoreData"
  end

# Adding easy Json to object mapping to Alamofire using EVReflection
  s.subspec "Alamofire" do |ss|
    ss.source_files  = "Source/Alamofire/*.swift"
    ss.dependency "EVReflection/Core"
    ss.dependency "Alamofire"
  end

# Adding easy XML to object mapping to Alamofire using XMLDictionary and EVReflection
  s.subspec "AlamofireXML" do |ss|
    ss.source_files  = "Source/Alamofire/XML/*.swift"
    ss.dependency "EVReflection/XML"
    ss.dependency "EVReflection/Alamofire"
  end

# Adding easy Json to object mapping to Moya using EVReflection
  s.subspec "Moya" do |ss|
    ss.source_files  = "Source/Alamofire/Moya/*.swift"
    ss.dependency "Moya"
    ss.dependency "EVReflection/Alamofire"
  end

# Adding easy XML to object mapping to Moya using XMLDictionary and EVReflection
  s.subspec "MoyaXML" do |ss|
    ss.source_files  = "Source/Alamofire/Moya/XML/*.swift"
    ss.dependency "EVReflection/AlamofireXML"
    ss.dependency "EVReflection/Moya"
  end

# Adding RxSwift functionality to the Moya extension
  s.subspec "MoyaRxSwift" do |ss|
    ss.source_files = "Source/Alamofire/Moya/RxSwift/*.swift"
    ss.dependency "Moya/RxSwift"
    ss.dependency "EVReflection/Moya"
  end

# Adding RxSwift functionality to the MoyaXML extension
  s.subspec "MoyaRxSwiftXML" do |ss|
    ss.source_files = "Source/Alamofire/Moya/RxSwift/XML/*.swift"
    ss.dependency "EVReflection/MoyaRxSwift"
    ss.dependency "EVReflection/MoyaXML"
  end

# Adding ReactiveSwift functionality to the Moya extension
  s.subspec "MoyaReactiveSwift" do |ss|
    ss.source_files = "Source/Alamofire/Moya/ReactiveSwift/*.swift"
    ss.dependency "Moya/ReactiveSwift"
    ss.dependency "EVReflection/Moya"
  end

# Adding ReactiveSwift functionality to the MoyaXML extension
  s.subspec "MoyaReactiveSwiftXML" do |ss|
    ss.source_files = "Source/Alamofire/Moya/ReactiveSwift/XML/*.swift"
    ss.dependency "EVReflection/MoyaReactiveSwift"
    ss.dependency "EVReflection/MoyaXML"
  end
end


