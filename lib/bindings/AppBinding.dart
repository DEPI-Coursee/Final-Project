import 'package:get/get.dart';
import 'package:tour_guide/controllers/connection_controller.dart';
import 'package:tour_guide/services/Authservice.dart';
import '../controllers/location_controller.dart';
import '../controllers/theme_controller.dart';
import '../services/user_service.dart';  

class AppBinding extends Bindings {
  @override
  void dependencies() {
    print('🔧 Initializing AppBinding dependencies...');
    
    // ✅ Put ConnectionController FIRST and as permanent
    // This ensures it's ready before other services
    Get.put<ConnectionController>(
      ConnectionController(), 
      permanent: true,
    );
    
    // ✅ Put ThemeController as permanent so theme persists across routes
    Get.put<ThemeController>(
      ThemeController(),
      permanent: true,
    );
    
    Get.lazyPut<Authservice>(() => Authservice(), fenix: true);
    Get.lazyPut<LocationController>(() => LocationController(), fenix: true);
    Get.lazyPut<UserService>(() => UserService(), fenix: true);

    print('✅ AppBinding dependencies registered');
  }
}