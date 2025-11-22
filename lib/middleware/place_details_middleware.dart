import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class PlaceDetailsMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Allow all navigation to proceed
    // The PlaceDetails widget will handle null arguments gracefully
    return null;
  }
}

