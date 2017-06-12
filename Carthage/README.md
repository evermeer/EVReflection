# Carthage

The only reason for this project is the configuration of the Carthage frameworks. 
Don't modify anything here accept for changing Carthage framework configuration

For Cocoapods there are 11 subspecs that each can build for all the 4 different platforms.
Making these all available in Carthage would take considerable time to set up and also for maintanance.
Instead I decide to only make the core available for all 4 platfoms and add the subspecs on demand.

So, if you want any of these subspecs available as a Carthage framework, then please:
- add a target for that in this Carthage project (and name it EVReflection_<subspec name>_<platform>)
- Add a folder named EVReflection<subspec name><platform> with the EVReflection.h and Info.plist for this target
- include the required files using a reference to the Source folder (do not copy)
- do a pull request 
