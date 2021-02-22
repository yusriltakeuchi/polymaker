import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:polymaker/core/models/trackingmode.dart';
import 'package:polymaker/core/viewmodels/map_provider.dart';
import 'package:polymaker/ui/Animation/FadeAnimation.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
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

  final IconData iconGPSPoint;

  ///Property to auto edit mode when maps open
  final bool autoEditMode;

  ///Property to enable and disable point distance
  final bool pointDistance;

  ///Property to choose tracking mode, you can choose PLANAR or LINEAR
  final TrackingMode trackingMode;

  ///Property to enable draggable marker
  final bool enableDragMarker;

  ///If this is null it means user is opting to use GPS tracking
  final LatLng targetCameraPosition;

  MapScreen(
      {this.toolColor,
      this.polygonColor,
      this.iconLocation,
      this.iconEditMode,
      this.iconCloseEdit,
      this.iconDoneEdit,
      this.iconUndoEdit,
      this.iconGPSPoint,
      this.autoEditMode,
      this.pointDistance,
      this.trackingMode,
      this.targetCameraPosition,
      this.enableDragMarker});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String distance = "awal";
  bool isSatellite = false;
  @override
  Widget build(BuildContext context) {
    //To modify status bar
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark));

    return Scaffold(
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => MapProvider(),
          )
        ],
        child: Consumer<MapProvider>(
          builder: (contex, mapProv, _) {
            //Get first location
            if (mapProv.cameraPosition == null) {
              if (widget.targetCameraPosition != null) {
                mapProv.initCamera(widget.autoEditMode, widget.pointDistance,
                    targetCameraPosition: widget.targetCameraPosition, dragMarker: widget.enableDragMarker);
              } else {
                mapProv.initCamera(widget.autoEditMode, widget.pointDistance, dragMarker: widget.enableDragMarker);
              }
              mapProv.setPolygonColor(widget.polygonColor);
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return Center(
              child: Stack(
                children: <Widget>[
                  Positioned(top: -300, child: mapDistance()),
                  Positioned(top: -300, child: mapIcon()),
                  mapProv.cameraPosition != null
                      ? Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: GoogleMap(
                            myLocationButtonEnabled: false,
                            myLocationEnabled: true,
                            compassEnabled: false,
                            tiltGesturesEnabled: false,
                            markers: mapProv.markers,
                            mapType: isSatellite
                                ? MapType.satellite
                                : MapType.normal,
                            initialCameraPosition: mapProv.cameraPosition,
                            onMapCreated: mapProv.onMapCreated,
                            mapToolbarEnabled: false,
                            onTap: (loc) => mapProv.onTapMap(loc,
                                mode: widget.trackingMode),
                            polygons: widget.trackingMode == TrackingMode.PLANAR
                                ? mapProv.polygons
                                : null,
                            polylines:
                                widget.trackingMode == TrackingMode.LINEAR
                                    ? mapProv.polylines
                                    : null,
                          ),
                        )
                      : Center(
                          child: CircularProgressIndicator(),
                        ),
                  _toolsList(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  ///Widget for custom marker
  Widget mapIcon() {
    return Consumer<MapProvider>(
      builder: (context, mapProv, _) {
        return RepaintBoundary(
          key: mapProv.markerKey,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                color: widget.polygonColor, shape: BoxShape.circle),
            child: Center(
              child: Text(
                (mapProv.tempLocation.length + 1).toString(),
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget mapDistance() {
    return Consumer<MapProvider>(
      builder: (context, mapProv, _) {
        return RepaintBoundary(
          key: mapProv.distanceKey,
          child: Container(
            width: mapProv.distance.length > 6
                ? (mapProv.distance.length >= 9 ? 100 : 80)
                : 64,
            height: 32,
            decoration: BoxDecoration(
                color: widget.toolColor,
                borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: Text(mapProv.distance,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ),
        );
      },
    );
  }

  ///Widget tools list
  Widget _toolsList() {
    return Builder(
      builder: (context) {
        return Consumer<MapProvider>(
          builder: (context, mapProv, _) {
            return SafeArea(
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                        padding: const EdgeInsets.only(top: 30, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            mapProv.isEditMode == true
                                ? FadeAnimation(
                                    delay: 0.8,
                                    child: InkWell(
                                      onTap: () => mapProv.undoLocation(),
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                            color: isSatellite
                                                ? Colors.white
                                                : widget.toolColor,
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                        child: Icon(
                                          widget.iconUndoEdit,
                                          color: isSatellite
                                              ? Colors.black87
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                : SizedBox(),
                            SizedBox(
                                width: mapProv.isEditMode == true ? 10 : 0),
                            mapProv.isEditMode == true
                                ? FadeAnimation(
                                    delay: 0.5,
                                    child: InkWell(
                                      onTap: () =>
                                          mapProv.saveTracking(context),
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                            color: isSatellite
                                                ? Colors.white
                                                : widget.toolColor,
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                        child: Icon(
                                          widget.iconDoneEdit,
                                          color: isSatellite
                                              ? Colors.black87
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                : SizedBox(),
                            SizedBox(
                                width: mapProv.isEditMode == true ? 10 : 0),
                            InkWell(
                              onTap: () => mapProv.changeEditMode(),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: isSatellite
                                        ? Colors.white
                                        : widget.toolColor,
                                    borderRadius: BorderRadius.circular(50)),
                                child: Icon(
                                  mapProv.isEditMode == false
                                      ? widget.iconEditMode
                                      : widget.iconCloseEdit,
                                  color: isSatellite
                                      ? Colors.black87
                                      : Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            InkWell(
                              onTap: () => mapProv
                                  .changeCameraPosition(mapProv.sourceLocation),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: isSatellite
                                        ? Colors.white
                                        : widget.toolColor,
                                    borderRadius: BorderRadius.circular(50)),
                                child: Icon(
                                  widget.iconLocation,
                                  color: isSatellite
                                      ? Colors.black87
                                      : Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            //TODO: add button to change map style to sattelite and normal.
                            InkWell(
                              onTap: () {
                                if (isSatellite) {
                                  isSatellite = false;
                                } else
                                  isSatellite = true;
                                setState(() {});
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: isSatellite
                                        ? Colors.white
                                        : widget.toolColor,
                                    borderRadius: BorderRadius.circular(50)),
                                child: Icon(
                                  isSatellite ? Icons.map : Icons.satellite,
                                  color: isSatellite
                                      ? Colors.black87
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        )),
                  ),
                  widget.targetCameraPosition == null && mapProv.isEditMode
                      ? Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(bottom: 30, left: 20),
                            child: FadeAnimation(
                              delay: 0.5,
                              child: InkWell(
                                onTap: () {
                                  mapProv.addGpsLocation(
                                      mode: widget.trackingMode);
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: isSatellite
                                          ? Colors.white
                                          : widget.toolColor,
                                      borderRadius: BorderRadius.circular(50)),
                                  child: Icon(
                                    widget.iconGPSPoint,
                                    color: isSatellite
                                        ? Colors.black87
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : SizedBox(height: 0, width: 0),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
