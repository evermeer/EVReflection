Please take notice that:

I switched master to Swift 4

Unfortunately I'm not allowed to push a new version for this to cocoapods because there now is a dependency to Moya 10.0 which is still in beta. 

In order to use this using cocoapods you have to specify the git pad so that it will use master
`pod 'EVReflection', :git => 'https://github.com/evermeer/EVReflection.git'`

If you also use Moya, then you also have to add this:
`pod 'Moya', :git => 'https://github.com/Moya/Moya.git', :branch => '10.0.0-dev'`
