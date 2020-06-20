library polymaker;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:polymaker/core/models/location_polygon.dart';
import 'package:polymaker/core/models/trackingmode.dart';
import 'package:polymaker/ui/screens/map_screen.dart';

class PolyMaker {
  ///BuildContext property
  BuildContext context;

  ///Property to customize tool color
  final Color toolColor;

  ///Property to customize polygon color
  final Color polygonColor;

  ///Property to customize location icon
  final IconData iconLocation;

  ///Property to customize edit mode icon
  final IconData iconEditMode;

  ///Property to customize close tool icon
  final IconData iconCloseEdit;

  ///Property to customize done icon
  final IconData iconDoneEdit;

  ///Property to cusstomize undo icon
  final IconData iconUndoEdit;

  ///Property to auto edit mode when maps open
  final bool autoEditMode;

  ///Property to enable and disable point distance
  final bool pointDistance;

  ///Property to respond to user-defined camera pos
  final LatLng targetCameraPosition;

  final TrackingMode trackingMode;

  PolyMaker(
      {@required this.context,
      this.toolColor,
      this.polygonColor,
      this.iconLocation,
      this.iconEditMode,
      this.iconCloseEdit,
      this.iconDoneEdit,
      this.iconUndoEdit,
      this.autoEditMode,
      this.pointDistance,
      this.targetCameraPosition,
      this.trackingMode});

  ///Function to open location maker and get result locations
  Future<List<LatLng>> getLocation() async {
    final result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => MapScreen(
              toolColor: toolColor,
              polygonColor: polygonColor,
              iconLocation: iconLocation,
              iconEditMode: iconEditMode,
              iconCloseEdit: iconCloseEdit,
              iconDoneEdit: iconDoneEdit,
              iconUndoEdit: iconUndoEdit,
              autoEditMode: autoEditMode,
              pointDistance: pointDistance,
              trackingMode: trackingMode,
              targetCameraPosition: targetCameraPosition,
            )));
    return result;
  }
}

///Function to open location maker
Future<List<LatLng>> getLocation(BuildContext context,
    {Color toolColor,
    Color polygonColor,
    IconData iconLocation,
    IconData iconEditMode,
    IconData iconCloseEdit,
    IconData iconDoneEdit,
    IconData iconUndoEdit,
    bool autoEditMode,
    bool pointDistance,
    LatLng targetCameraPosition,
    TrackingMode trackingMode}) async {
  return await PolyMaker(
          context: context,
          toolColor: toolColor != null ? toolColor : Colors.black87,
          polygonColor: polygonColor != null ? polygonColor : Colors.red,
          iconLocation: iconLocation != null ? iconLocation : Icons.location_on,
          iconEditMode:
              iconEditMode != null ? iconEditMode : Icons.edit_location,
          iconCloseEdit: iconCloseEdit != null ? iconCloseEdit : Icons.close,
          iconDoneEdit: iconDoneEdit != null ? iconDoneEdit : Icons.check,
          iconUndoEdit: iconUndoEdit != null ? iconUndoEdit : Icons.undo,
          autoEditMode: autoEditMode != null ? autoEditMode : false,
          pointDistance: pointDistance != null ? pointDistance : true,
          targetCameraPosition:
              targetCameraPosition != null ? targetCameraPosition : null,
          trackingMode:
              trackingMode != null ? trackingMode : TrackingMode.PLANAR)
      .getLocation();
}
