import 'package:get/get.dart';
import 'package:tour_guide/controllers/home_controller.dart';
import 'package:tour_guide/services/Authservice.dart';
import '../controllers/location_controller.dart';
import '../services/user_service.dart';  

class AppBinding extends Bindings {
  @override
  void dependencies() {
    print('🔧 Initializing AppBinding dependencies...');
    Get.put(Authservice(), permanent: true);
    Get.put(LocationController(), permanent: true);
    Get.put(UserService(), permanent: true);
    Get.put(HomeController, permanent: true);
        print('✅ AppBinding dependencies registered');

  }
}