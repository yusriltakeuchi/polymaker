import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:polymaker/core/viewmodels/map_provider.dart';
import 'package:polymaker/ui/Animation/FadeAnimation.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatelessWidget {
  Color toolColor;
  Color polygonColor;
  IconData iconLocation;
  IconData iconEditMode;
  IconData iconCloseEdit;
  IconData iconDoneEdit;
  IconData iconUndoEdit;
  
  MapScreen({
    this.toolColor,
    this.polygonColor,
    this.iconLocation,
    this.iconEditMode,
    this.iconCloseEdit,
    this.iconDoneEdit,
    this.iconUndoEdit
  });

  @override
  Widget build(BuildContext context) {
    //To modify status bar
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark
    ));

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
                  
                  mapProv.cameraPosition != null ? Container(
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
                  ) : Center(
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

                      mapProv.isEditMode == true ? FadeAnimation(
                        delay: 0.8,
                        child: InkWell(
                          onTap: () => mapProv.undoLocation(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: toolColor,
                              borderRadius: BorderRadius.circular(50)
                            ),
                            child: Icon(iconUndoEdit, color: Colors.white,),
                          ),
                        ),
                      ) : SizedBox(),
                      SizedBox(width: mapProv.isEditMode == true ? 10 : 0),

                      mapProv.isEditMode == true ? FadeAnimation(
                        delay: 0.5,
                        child: InkWell(
                          onTap: () => mapProv.savePolygon(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: toolColor,
                              borderRadius: BorderRadius.circular(50)
                            ),
                            child: Icon(iconDoneEdit, color: Colors.white,),
                          ),
                        ),
                      ) : SizedBox(),
                      SizedBox(width: mapProv.isEditMode == true ? 10 : 0),

                      InkWell(
                        onTap: () => mapProv.changeEditMode(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: toolColor,
                            borderRadius: BorderRadius.circular(50)
                          ),
                          child: Icon(mapProv.isEditMode == false ? iconEditMode : iconCloseEdit, color: Colors.white,),
                        ),
                      ),
                      SizedBox(width: 10),

                      InkWell(
                        onTap: () => mapProv.changeCameraPosition(mapProv.sourceLocation),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: toolColor,
                            borderRadius: BorderRadius.circular(50)
                          ),
                          child: Icon(iconLocation, color: Colors.white,),
                        ),
                      ),
                    ],
                  )
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// class MapBody extends StatelessWidget {
//   Color toolColor;
//   MapBody({
//     @required this.toolColor = Colors.black87
//   });

//   @override
//   Widget build(BuildContext context) {

//     //To modify status bar
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.dark
//     ));
    
//     return Consumer<MapProvider>(
//       builder: (contex, mapProv, _) {

//         //Get first location
//         if (mapProv.cameraPosition == null) {
//           mapProv.initCamera();
//           return Center(
//             child: CircularProgressIndicator(),
//           );
//         }

//         return Center(
//           child: Stack(
//             children: <Widget>[
              
//               mapProv.cameraPosition != null ? Container(
//                 width: MediaQuery.of(context).size.width,
//                 height: MediaQuery.of(context).size.height,
//                 child: GoogleMap(
//                   myLocationButtonEnabled: false,
//                   myLocationEnabled: true,
//                   compassEnabled: false,
//                   tiltGesturesEnabled: false,
//                   markers: mapProv.markers,
//                   mapType: MapType.normal,
//                   initialCameraPosition: mapProv.cameraPosition,
//                   onMapCreated: mapProv.onMapCreated,
//                   mapToolbarEnabled: false,
//                   onTap: (loc) => mapProv.onTapMap(loc),
//                   polygons: mapProv.polygons,
//                 ),
//               ) : Center(
//                 child: CircularProgressIndicator(),
//               ),

//               SafeArea(
//                 child: Align(
//                   alignment: Alignment.topRight,
//                   child: Padding(
//                     padding: const EdgeInsets.only(top: 30, right: 20),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: <Widget>[

//                         mapProv.isEditMode == true ? FadeAnimation(
//                           delay: 0.8,
//                           child: InkWell(
//                             onTap: () => mapProv.undoLocation(),
//                             child: Container(
//                               width: 40,
//                               height: 40,
//                               decoration: BoxDecoration(
//                                 color: widget.toolColor,
//                                 borderRadius: BorderRadius.circular(50)
//                               ),
//                               child: Icon(Icons.undo, color: Colors.white,),
//                             ),
//                           ),
//                         ) : SizedBox(),
//                         SizedBox(width: mapProv.isEditMode == true ? 10 : 0),

//                         mapProv.isEditMode == true ? FadeAnimation(
//                           delay: 0.5,
//                           child: InkWell(
//                             onTap: () => mapProv.savePolygon(context),
//                             child: Container(
//                               width: 40,
//                               height: 40,
//                               decoration: BoxDecoration(
//                                 color: widget.toolColor,
//                                 borderRadius: BorderRadius.circular(50)
//                               ),
//                               child: Icon(Icons.check, color: Colors.white,),
//                             ),
//                           ),
//                         ) : SizedBox(),
//                         SizedBox(width: mapProv.isEditMode == true ? 10 : 0),

//                         InkWell(
//                           onTap: () => mapProv.changeEditMode(),
//                           child: Container(
//                             width: 40,
//                             height: 40,
//                             decoration: BoxDecoration(
//                               color: widget.toolColor,
//                               borderRadius: BorderRadius.circular(50)
//                             ),
//                             child: Icon(mapProv.isEditMode == false ? Icons.edit_location : Icons.close, color: Colors.white,),
//                           ),
//                         ),
//                         SizedBox(width: 10),

//                         InkWell(
//                           onTap: () => mapProv.changeCameraPosition(mapProv.sourceLocation),
//                           child: Container(
//                             width: 40,
//                             height: 40,
//                             decoration: BoxDecoration(
//                               color: widget.toolColor,
//                               borderRadius: BorderRadius.circular(50)
//                             ),
//                             child: Icon(Icons.location_on, color: Colors.white,),
//                           ),
//                         ),
//                       ],
//                     )
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }