import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:polymaker/core/viewmodels/map_provider.dart';
import 'package:polymaker/ui/Animation/FadeAnimation.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatelessWidget {

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

  MapScreen(
      {this.toolColor,
      this.polygonColor,
      this.iconLocation,
      this.iconEditMode,
      this.iconCloseEdit,
      this.iconDoneEdit,
      this.iconUndoEdit});

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
              mapProv.initCamera();
              mapProv.setPolygonColor(polygonColor);
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return Center(
              child: Stack(
                children: <Widget>[
                  mapIcon(),
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
                            mapType: MapType.normal,
                            initialCameraPosition: mapProv.cameraPosition,
                            onMapCreated: mapProv.onMapCreated,
                            mapToolbarEnabled: false,
                            onTap: (loc) => mapProv.onTapMap(loc),
                            polygons: mapProv.polygons,
                          ),
                        )
                      : Center(
                          child: CircularProgressIndicator(),
                        ),
                  _toolsList()
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
            decoration:
                BoxDecoration(color: polygonColor, shape: BoxShape.circle),
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

  ///Widget tools list
  Widget _toolsList() {
    return Builder(
      builder: (context) {
        return Consumer<MapProvider>(
          builder: (context, mapProv, _) {
            return SafeArea(
              child: Align(
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
                                        color: toolColor,
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    child: Icon(
                                      iconUndoEdit,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(),
                        SizedBox(width: mapProv.isEditMode == true ? 10 : 0),
                        mapProv.isEditMode == true
                            ? FadeAnimation(
                                delay: 0.5,
                                child: InkWell(
                                  onTap: () => mapProv.savePolygon(context),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: toolColor,
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    child: Icon(
                                      iconDoneEdit,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(),
                        SizedBox(width: mapProv.isEditMode == true ? 10 : 0),
                        InkWell(
                          onTap: () => mapProv.changeEditMode(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                color: toolColor,
                                borderRadius: BorderRadius.circular(50)),
                            child: Icon(
                              mapProv.isEditMode == false
                                  ? iconEditMode
                                  : iconCloseEdit,
                              color: Colors.white,
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
                                color: toolColor,
                                borderRadius: BorderRadius.circular(50)),
                            child: Icon(
                              iconLocation,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
            );
          },
        );
      },
    );
  }
}