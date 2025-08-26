// 🏭 PLATFORM FACTORY - CREA LA IMPLEMENTACIÓN CORRECTA SEGÚN PLATAFORMA
import 'platform_service.dart';
import 'platform_implementations/platform_service_base.dart';

class PlatformFactory {
  static PlatformServiceBase createPlatformService() {
    return PlatformServiceImpl();
  }
}