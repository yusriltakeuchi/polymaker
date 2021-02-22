import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:math' as math;
import 'dart:math' show cos, sqrt, asin;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:polymaker/core/models/trackingmode.dart';

class MapProvider extends ChangeNotifier {
  //------------------------//
  //   PROPERTY SECTIONS    //
  //------------------------//

  //Property tracking Mode;

  ///Property zoom camera
  double _cameraZoom = 16;
  double get cameraZoom => _cameraZoom;

  ///Property camera position
  CameraPosition _cameraPosition;
  CameraPosition get cameraPosition => _cameraPosition;

  ///Property camera tilt
  double _cameraTilt = 0;
  double get cameraTilt => _cameraTilt;

  ///Property camera bearing
  double _cameraBearing = 0;
  double get cameraBearing => _cameraBearing;

  ///Property my location data
  LatLng _sourceLocation;
  LatLng get sourceLocation => _sourceLocation;

  ///Property Google Map Controller completer
  Completer<GoogleMapController> _completer = Completer();
  Completer<GoogleMapController> get completer => _completer;

  ///Property Google Map Controller
  GoogleMapController _controller;
  GoogleMapController get controller => _controller;

  ///Property to save all markers
  Set<Marker> _markers = {};
  Set<Marker> get markers => _markers;

  ///Property to mapStyle
  String _mapStyle;
  String get mapStyle => _mapStyle;

  ///Property location services
  Location location = new Location();

  ///Property to handle edit mode
  bool _isEditMode = false;
  bool get isEditMode => _isEditMode;

  ///Property temporary polygon list
  Set<Polygon> _tempPolygons = new Set();
  Set<Polygon> get tempPolygons => _tempPolygons;

  ///Property polygon list
  Set<Polygon> _polygons = new Set();
  Set<Polygon> get polygons => _polygons;

  //Property temporary polyline list
  Set<Polyline> _tempPolylines = new Set();
  Set<Polyline> get tempPolylines => _tempPolylines;

  Set<Polyline> _polylines = new Set();
  Set<Polyline> get polylines => _polylines;

  ///Property temporary location
  List<LatLng> _tempLocation = new List();
  List<LatLng> get tempLocation => _tempLocation;

  ///Property to save distance location
  List<LatLng> _distanceLocation = new List();
  List<LatLng> get distanceLocation => _distanceLocation;

  ///Propoerty to save end location
  LatLng _endLoc;
  LatLng get endLoc => _endLoc;

  ///Property to get uniqueId for markers
  String _uniqueID = "";
  String get uniqueID => _uniqueID;

  ///Property to polygon color
  Color _polygonColor;
  Color get polygonColor => _polygonColor;

  ///Property to custom marker
  Uint8List _customMarker;
  Uint8List get customMarker => _customMarker;

  ///Custom key for custom marker
  final markerKey = GlobalKey();
  final distanceKey = GlobalKey();

  ///Value to show distance between two location
  String _distance = "0";
  String get distance => _distance;

  ///Property for enable point distance
  bool _pointDistance = true;
  bool get pointDistance => _pointDistance;

  ///Save current tracking mode
  TrackingMode _trackingMode;
  TrackingMode get trackingMode => _trackingMode;

  ///Enabling draggable marker
  bool _enableDragMarker = false;
  bool get enableDragMarker => _enableDragMarker;

  //------------------------//
  //   FUNCTION SECTIONS   //
  //------------------------//

  ///Function to initialize camera
  void initCamera(bool autoEditMode, bool pointDist,
      {LatLng targetCameraPosition, bool dragMarker}) async {
    if (targetCameraPosition != null) {
      _sourceLocation = targetCameraPosition;
      //notifyListeners();
    } else {
      ///Get current locations
      await initLocation();
    }

    ///Get current locations

    ///Set current location to camera
    _cameraPosition = CameraPosition(
        zoom: cameraZoom,
        bearing: cameraBearing,
        tilt: cameraTilt,
        target: sourceLocation);

    ///Auto mode on
    if (autoEditMode) {
      _isEditMode = !_isEditMode;
    }

    //Enable or Disable point distance
    if (pointDist == false) {
      _pointDistance = false;
    }

    if (dragMarker != null) {
      _enableDragMarker = dragMarker;
    }

    notifyListeners();
  }

  ///Function to init polygon color
  void setPolygonColor(Color color) async {
    _polygonColor = await getPolyColor(color);
    notifyListeners();
  }

  ///Assign polygon color
  Future<Color> getPolyColor(Color color) async {
    return color;
  }

  ///Function to get current locations
  Future<void> initLocation() async {
    var locData = await location.getLocation();
    _sourceLocation = LatLng(locData.latitude, locData.longitude);

    notifyListeners();
  }

  ///Function to handle when maps created
  void onMapCreated(GoogleMapController controller) async {
    ///Loading map style
    _mapStyle =
        await rootBundle.loadString("packages/polymaker/assets/map_style.txt");

    _completer.complete(controller);
    _controller = controller;

    ///Set style to map
    _controller.setMapStyle(_mapStyle);

    notifyListeners();
  }

  ///Function to change camera position
  void changeCameraPosition(LatLng location) {
    ///Moving maps camera
    _controller.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(
          location.latitude,
          location.longitude,
        ),
        cameraZoom));

    notifyListeners();
  }

  ///Function to change toggle edit mode
  void changeEditMode() {
    _isEditMode = !_isEditMode;

    if (_isEditMode == false) {
      //* When editing mode done
      _uniqueID = "";
      _tempPolygons.clear();
      _tempLocation.clear();
      _distanceLocation.clear();
      _markers.clear();
    } else {
      _markers.clear();
    }
    notifyListeners();
  }

  ///Function to undo select location in edit mode
  void undoLocation() {
    if (_tempLocation.length > 0) {
      _markers.removeWhere((mark) => mark.position == _tempLocation.last);

      if (pointDistance) {
        ///Remove previous distance first point to last point
        _markers.removeWhere((mark) => mark.position == _endLoc);
      }

      _tempLocation.removeLast();
      if (_tempLocation.length == 0) {
        _tempPolygons.clear();
      }

      if (_tempLocation.length > 1 && pointDistance) {
        //Create distance marker for first point to last point
        createEndLoc(_tempLocation[0], _tempLocation.last);
      }
    }

    if (_distanceLocation.length > 0) {
      _markers.removeWhere((mark) => mark.position == _distanceLocation.last);
      _distanceLocation.removeLast();
    }

    notifyListeners();
  }

  ///Function to create distance marker
  Future<void> createDistanceMarker(
      LatLng startLocation, LatLng _location) async {
    LatLng center = await getCenterLatLong([startLocation, _location]);
    String dist = await calculateDistance(startLocation, _location);
    _distance = dist;
    _distanceLocation.add(center);
    notifyListeners();

    ///Create distance marker function
    await Future.delayed((Duration(milliseconds: 100)));
    Uint8List distanceIcon = await getUint8List(distanceKey);
    setMarkerLocation(dist, center, distanceIcon);
    notifyListeners();
  }

  ///Function to set end location marker
  Future<void> createEndLoc(LatLng startLocation, LatLng _location) async {
    LatLng center = await getCenterLatLong([startLocation, _location]);
    String dist = await calculateDistance(startLocation, _location);
    _distance = dist;
    _endLoc = center;
    notifyListeners();

    ///Create distance marker function
    await Future.delayed((Duration(milliseconds: 100)));
    Uint8List distanceIcon = await getUint8List(distanceKey);
    setMarkerLocation(distance, center, distanceIcon);
    notifyListeners();
  }

  Future<void> removeMarker(LatLng _loc) async {
    _markers.removeWhere((mark) => mark.position == _loc);
  }

  ///Function to handle onTap Map and get location
  void onTapMap(LatLng _location,
      {TrackingMode mode = TrackingMode.PLANAR}) async {
    if (isEditMode == true) {
      ///Find center position between two coordinate
      if (_tempLocation.length > 0) {
        if (_tempLocation.length > 1 && pointDistance) {
          ///Remove previous distance first point to last point
          await removeMarker(_endLoc);

          ///Create distance marker for first point to last point
          await createEndLoc(_tempLocation[0], _location);
        }

        if (pointDistance) {
          ///Create distance marker for last positions
          await createDistanceMarker(_tempLocation.last, _location);
        }
      }

      ///Adding new locations
      _tempLocation.add(_location);
      if (_uniqueID == "") {
        _uniqueID = Random().nextInt(10000).toString();
      }

      ///Create marker point
      Uint8List markerIcon = await getUint8List(markerKey);
      setMarkerLocation(_tempLocation.length.toString(), _location, markerIcon);
      ///Set current tracking mode
      ///so we can use this variable in every function
      setTrackingMode(mode);
      if (trackingMode == TrackingMode.PLANAR) {
        setTempToPolygon();
      } else {
        setTempToPolyline();
      }
    }
    notifyListeners();
  }

  ///TODO: add function to add location from gps
  void addGpsLocation({TrackingMode mode = TrackingMode.PLANAR}) async {
    var _locationData = await location.getLocation();
    var _location = new LatLng(_locationData.latitude, _locationData.longitude);
    if (isEditMode == true) {
      ///Find center position between two coordinate
      if (_tempLocation.length > 0) {
        if (_tempLocation.length > 1 && pointDistance) {
          ///Remove previous distance first point to last point
          await removeMarker(_endLoc);

          ///Create distance marker for first point to last point
          await createEndLoc(_tempLocation[0], _location);
        }

        if (pointDistance) {
          ///Create distance marker for last positions
          await createDistanceMarker(_tempLocation.last, _location);
        }
      }

      ///Adding new locations
      _tempLocation.add(_location);
      if (_uniqueID == "") {
        _uniqueID = Random().nextInt(10000).toString();
      }

      ///Create marker point
      Uint8List markerIcon = await getUint8List(markerKey);
      setMarkerLocation(_tempLocation.length.toString(), _location, markerIcon);
      ///Set current tracking mode
      ///so we can use this variable in every function
      setTrackingMode(mode);
      if (trackingMode == TrackingMode.PLANAR) {
        setTempToPolygon();
      } else {
        setTempToPolyline();
      }
    }
    notifyListeners();
  }

  ///Function to set marker locations
  void setMarkerLocation(String id, LatLng _location, Uint8List markerIcon,
      {String title}) async {
    _markers.add(Marker(
        markerId: MarkerId("${uniqueID + id}"),
        position: _location,
        draggable: enableDragMarker,
        icon: BitmapDescriptor.fromBytes(markerIcon),
        onDragEnd: (newLoc) {
          if (enableDragMarker) {
            updateNewMarkerLocation(id, newLoc);
          }
        },
        infoWindow: title != null
            ? InfoWindow(title: title, snippet: "Area Polygon Nomor $id")
            : null));

    notifyListeners();
  }

  ///Remove marker by latlong
  void removeMarkerByLatlong(LatLng _location) {
    _markers.removeWhere((_marker) => _marker.position == _location);
    notifyListeners();
  }

  ///Updating new marker and polygon location 
  ///when the marker is dragged
  void updateNewMarkerLocation(String id, LatLng _newLoc) async {
    _tempLocation[int.parse(id)-1] = _newLoc;

    if (trackingMode == TrackingMode.PLANAR) {
      setTempToPolygon();
    } else {
      setTempToPolyline();
    }

    ///Refresh distance marker
    for (var distance in _distanceLocation) {
      removeMarkerByLatlong(distance);
    }
    _distanceLocation.clear();
    for (int i=0; i<_tempLocation.length; i++) {
      if (i+1 < _tempLocation.length) {
        await createDistanceMarker(_tempLocation[i], _tempLocation[i+1]);
      }
    }

    if (_tempLocation.length > 1 && pointDistance) {
      ///Remove previous distance first point to last point
      await removeMarker(_endLoc);

      ///Create distance marker for first point to last point
      await createEndLoc(_tempLocation[0], _tempLocation.last);
    }
    notifyListeners();
  }

  ///Function to set temporary polygons to polygons
  void setTempToPolygon() {
    if (_tempPolygons != null) {
      _tempPolygons
          .removeWhere((poly) => poly.polygonId.toString() == uniqueID);
    }

    _tempPolygons.add(Polygon(
        polygonId: PolygonId(uniqueID),
        points: _tempLocation,
        strokeWidth: 3,
        fillColor: _polygonColor.withOpacity(0.3),
        strokeColor: _polygonColor));
    _polygons = _tempPolygons;
    notifyListeners();
  }

  void setTempToPolyline() {
    if (_tempPolylines != null) {
      _tempPolylines
          .removeWhere((line) => line.polylineId.toString() == uniqueID);
    }

    _tempPolylines.add(
      Polyline(
        polylineId: PolylineId(uniqueID),
        points: _tempLocation,
        width: 8,
        color: _polygonColor.withOpacity(0.3),
      ),
    );
    _polylines = _tempPolylines;
    notifyListeners();
  }

  ///Function to save tracking points to database
  void saveTracking(BuildContext context) {
    if (_tempLocation.length > 0) {
      Navigator.pop(context, _tempLocation);
    } else {
      Navigator.pop(context, null);
    }
  }

  ///Converting Widget to PNG
  Future<Uint8List> getUint8List(GlobalKey widgetKey) async {
    RenderRepaintBoundary boundary =
        widgetKey.currentContext.findRenderObject();
    var image = await boundary.toImage(pixelRatio: 2.0);
    ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
    return byteData.buffer.asUint8List();
  }

  ///Set current tracking mode
  void setTrackingMode(TrackingMode mode) {
    _trackingMode = mode;
    notifyListeners();
  }

  ///Function to get center location between two coordinate
  Future<LatLng> getCenterLatLong(List<LatLng> latLongList) async {
    double pi = math.pi / 180;
    double xpi = 180 / math.pi;
    double x = 0, y = 0, z = 0;

    if (latLongList.length == 1) {
      return latLongList[0];
    }

    for (int i = 0; i < latLongList.length; i++) {
      double latitude = latLongList[i].latitude * pi;
      double longitude = latLongList[i].longitude * pi;
      double c1 = math.cos(latitude);
      x = x + c1 * math.cos(longitude);
      y = y + c1 * math.sin(longitude);
      z = z + math.sin(latitude);
    }

    int total = latLongList.length;
    x = x / total;
    y = y / total;
    z = z / total;

    double centralLongitude = math.atan2(y, x);
    double centralSquareRoot = math.sqrt(x * x + y * y);
    double centralLatitude = math.atan2(z, centralSquareRoot);

    return LatLng(centralLatitude * xpi, centralLongitude * xpi);
  }

  ///Calculate distance between two location
  Future<String> calculateDistance(
      LatLng firstLocation, LatLng secondLocation) async {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((secondLocation.latitude - firstLocation.latitude) * p) / 2 +
        c(firstLocation.latitude * p) *
            c(secondLocation.latitude * p) *
            (1 - c((secondLocation.longitude - firstLocation.longitude) * p)) /
            2;
    var distance = 12742 * asin(sqrt(a));

    if (distance < 1) {
      return (double.parse(distance.toStringAsFixed(3)) * 1000)
              .toString()
              .split(".")[0] +
          " m";
    } else {
      return double.parse(distance.toStringAsFixed(2)).toString() + " km";
    }
  }
}
