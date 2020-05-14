
# Polymaker
Polymaker is a flutter package used to get a list of locations for polygon google maps.

### Tools Feature:
- Get Current Location
- Entering Edit Mode
- Closing Edit Mode
- Done Editing
- Undo Editing to Previous Location
- Realtime polygon to view result

<p>
  <img src="https://i.ibb.co/x3SRTn6/Whats-App-Image-2020-05-14-at-15-36-26-1.jpg" width=265/>
  <img src="https://i.ibb.co/ZVCGB3c/Whats-App-Image-2020-05-14-at-15-36-26.jpg" width=265 />
</p>

# Billing
You must enable some API in google cloud to use this features
- Google Maps for Android/iOS

## Setup

####  ANDROID
Adding Permission in **android/app/src/main/AndroidManifest.xml**
```xml
<uses-permission  android:name="android.permission.INTERNET"/>
<uses-permission  android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission  android:name="android.permission.ACCESS_FINE_LOCATION" />
```

Insert Google Maps Key in **android/app/src/main/AndroidManifest.xml**
```xml
<application
android:name="io.flutter.app.FlutterApplication"
android:label="example"
android:icon="@mipmap/ic_launcher">
	.....
	<meta-data android:name="com.google.android.geo.API_KEY"
		android:value="<YOUR API KEY>"/>
        <meta-data  android:name="com.google.android.gms.version" 
	        android:value="@integer/google_play_services_version" />
</application>
```

#### IOS
Specify your API key in the application delegate `ios/Runner/AppDelegate.m`:

```objectivec
#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "GoogleMaps/GoogleMaps.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GMSServices provideAPIKey:@"YOUR API KEY"];
  [GeneratedPluginRegistrant registerWithRegistry:self];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
@end
```

Or in your swift code, specify your API key in the application delegate `ios/Runner/AppDelegate.swift`
```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR API KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

Setting your permission in `Info.plist`

Opt-in to the embedded views preview by adding a boolean property to the app's `Info.plist` file
with the key `io.flutter.embedded_views_preview` and the value `YES`; you need also to define `NSLocationWhenInUseUsageDescription`

```plist
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>This app needs your location to test the location feature of the Google Maps location picker plugin.</string>
  <key>io.flutter.embedded_views_preview</key>
  <true/>
```

## How To Use
Using polymaker is very easy and only needs to use one line of code 
```dart
import  'package:polymaker/polymaker.dart' as polymaker;

// Open polymaker and get return List<LocationPolygon>
var result =  await polymaker.getLocation(context);
```

## Custom Property in getLocation()
|Property|Description  |Data Type
|--|--|--|
|**toolColor**  |Property to customize tool color  |Color
|**polygonColor**  |Property to customize polygon color  |Color
|**iconLocation**  |Property to customize location icon  |IconData
|**iconEditMode**  |Property to customize edit mode icon  |IconData
|**iconCloseEdit**  |Property to customize close tool icon  |IconData
|**iconDoneEdit**  |Property to customize done icon  |IconData
|**iconUndoEdit**  |Property to cusstomize undo icon  |IconData

