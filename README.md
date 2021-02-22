# Polymaker

[![Fork](https://img.shields.io/github/forks/yusriltakeuchi/polymaker?style=social)](https://github.com/yusriltakeuchi/polymaker/fork)&nbsp; [![Star](https://img.shields.io/github/stars/yusriltakeuchi/polymaker?style=social)](https://github.com/yusriltakeuchi/polymaker/star)&nbsp; [![Watches](https://img.shields.io/github/watchers/yusriltakeuchi/polymaker?style=social)](https://github.com/yusriltakeuchi/polymaker/)&nbsp; [![Get the library](https://img.shields.io/badge/Get%20library-pub-blue)](https://pub.dev/packages/polymaker)&nbsp; [![Example](https://img.shields.io/badge/Example-Ex-success)](https://pub.dev/packages/polymaker#-example-tab-)

Polymaker is a flutter package to make it easier to map polygon locations in Google Maps, because the appearance is realtime when in Edit Mode, so we know the exact position without guessing through the backend system.
Polymaker can be run with only one line of code, and returns the location's List value.

### Tools Feature:

- Get Current Location
- Entering Edit Mode
- Closing Edit Mode
- Done Editing
- Undo Editing to Previous Location
- Realtime polygon to view result
- Custom Marker as Pointing Number
- Point Distance
- Tracking Mode LINEAR & PLANAR
- Custom Map Type

<p>
<img src="https://i.imgur.com/pjJdUvw.jpg" height="480px">
<img src="https://i.imgur.com/nfyJked.jpg" height="480px">
</p>
  
# Billing

You must enable some API in google cloud to use this features
- Google Maps for Android/iOS

## Setup

#### ANDROID

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
	<meta-data  android:name="com.google.android.geo.API_KEY"
		android:value="<YOUR API KEY>"/>
	<meta-data  android:name="com.google.android.gms.version"
		android:value="@integer/google_play_services_version" />
</application>
```

Setup your SDK Version to the latest in **android/app/build.gradle**

    compileSdkVersion 29
    ....
    defaultConfig {
      ....
      targetSdkVersion 29
      ....
    }

#### IOS

Specify your API key in the application delegate `ios/Runner/AppDelegate.m`:

```objectivec
#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "GoogleMaps/GoogleMaps.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GMSServices provideAPIKey:@"YOUR KEY HERE"];
  [GeneratedPluginRegistrant registerWithRegistry:self];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
@end
```

Or in your swift code, specify your API key in the application delegate `ios/Runner/AppDelegate.swift`:

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
    GMSServices.provideAPIKey("YOUR KEY HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```
Opt-in to the embedded views preview by adding a boolean property to the app's `Info.plist` file
with the key `io.flutter.embedded_views_preview` and the value `YES`; you need also to define `NSLocationWhenInUseUsageDescription`

```
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>This app needs your location to test the location feature of the Google Maps location picker plugin.</string>
  <key>io.flutter.embedded_views_preview</key>
  <true/>
```

## How To Use

  Using polymaker is very easy and only needs to use one line of code

```dart
import  'package:polymaker/polymaker.dart'  as polymaker;

// Open polymaker and get return List<LatLng>
var result =  await polymaker.getLocation(context);
```

## Custom Property in getLocation()

|Property|Description |Data Type
|--|--|--|
|**toolColor** |Property to customize tool color |Color
|**polygonColor** |Property to customize polygon color |Color
|**iconLocation** |Property to customize location icon |IconData
|**iconEditMode** |Property to customize edit mode icon |IconData
|**iconCloseEdit** |Property to customize close tool icon |IconData
|**iconDoneEdit** |Property to customize done icon |IconData
|**iconUndoEdit** |Property to customize undo icon |IconData
|**iconGPSPoint** |Property to use GPS data as tracking point |IconData
|**autoEditMode** |Automatic enable edit mode |Boolean
|**pointDistance** |Enable / Disable Point Distance |Boolean
|**trackingMode** |Choose Tracking mode between polygon or polyline |TrackingMode
|**targetCameraPosition** |Set initial camera locations |LatLng
|**enableDragMarker** |Enabling drag to marker position |Boolean