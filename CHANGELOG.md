# Installation & Update

The adviced way to install EVReflection and available extensons is by using cocoapods. Just add this to your podfile:

```
pod 'EVReflection'
```

And for the extension it would be:

```
pod 'EVReflection/MoyaRxSwift'
```

For more information see the [installation instructions](https://github.com/evermeer/EVReflection#using-evreflection-in-your-own-app)

## Master

Is published as version 4.6.0

## 4.6.0 (2017-3-25)

#### Bug Fixes

* Cache access now thread safe

## 4.5.1 (2017-3-18)

#### Enhancements

* default implementation for customConverter

## 4.5.0 (2017-3-2)

#### Enhancements

* added the customConverter function

## 4.4.1 (2017-2-22)

#### Bug Fixes

* Fix for using forKeyPath with RxSwift

## 4.4.0 (2017-2-22)

#### Enhancements

* Moya + reflective can now also use keyPath

## 4.3.3 (2017-2-21)

#### Bug Fixes

* EVRaw should be public

## 4.3.2 (2017-2-20)

#### Enhancements

* auto array to object conversion if possible

## 4.3.1 (2017-2-14)

#### Enhancements

* propertyMapping function with named arguments

## 4.3.0 (2017-2-14)

#### Enhancements

* propertyConverters function with named arguments

## 4.2.1 (2017-2-4)

#### Bug Fixes

* fix for Carthage

## 4.2.0 (2017-2-3)

#### Enhancements

* Dictionary and array helper extensions

## 4.1.0 (2017-1-25)

#### Enhancements

* Added init for object mapping

