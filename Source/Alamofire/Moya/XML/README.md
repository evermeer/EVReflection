EVReflection/AlamofireXML
============

This is the sub specification for a Alamofire with XML Response extension for EVReflection

# Installation

## CocoaPods

```ruby
pod 'EVReflection/Alamofire'
```

# Usage

Create a class which has `EVNetworkingObject` as it's base class.

```
class WeatherResponse: EVNetworkingObject {
var location: String?
var three_day_forecast: [Forecast] = [Forecast]()
}

class Forecast: EVNetworkingObject {
var day: String?
var temperature: NSNumber?
var conditions: String?
}

class AlamofireJsonToObjectsTests: XCTestCase { 
func testResponseObject() {
let URL = "https://raw.githubusercontent.com/evermeer/AlamofireJsonToObjects/master/AlamofireJsonToObjectsTests/sample_json"
Alamofire.request(URL)
.responseObject { (response: DataResponse<WeatherResponse>) in
if let result = response.result.value {
// That was all... You now have a WeatherResponse object with data
}
}
waitForExpectationsWithTimeout(10, handler: { (error: NSError!) -> Void in
XCTAssertNil(error, "\(error)")
})
}
}
```

The code above will pass the folowing json to the objects:

```
{  
"location": "Toronto, Canada",    
"three_day_forecast": [
{ 
"conditions": "Partly cloudy",
"day" : "Monday",
"temperature": 20 
}, { 
"conditions": "Showers",
"day" : "Tuesday",
"temperature": 22 
}, { 
"conditions": "Sunny",
"day" : "Wednesday",
"temperature": 28 
}
]
}
```


## Handling HTTP status >= 300
When a network call returns a [HTTP error status](https://en.wikipedia.org/wiki/List_of_HTTP_status_codes) (300 or highter) then this will be added to the evReflectionStatuses as a custom error. see the unit test testErrorResponse as a sample. In order to make this work, you do have to set EVNetworkingObject as your bass class and not EVObject. You then also have to be aware that if you override the initValidation or the propertyMapping function, that you also have to call the super for that function.

