import 'environment_config.dart';

class GlobalConfig {
  String mainURL() {
     if (EnvironmentConfig.ENV == "PROD") {
       return "http://mgbix.id:82/trucking-aba/API/";
     } else if (EnvironmentConfig.ENV == "RC") {
       return "http://mgbix.id:82/anugerah-truck-dev2/API/";
     } else {
       return "http://mgbix.id:82/anugerah-truck-dev/API/";
     }
  }
  // static const String MainURL = "http://mgbix.id:82/anugerah-truck-dev/API/";

  // static const String MainURL = "http://mgbix.id:82/trucking-aba/API/";

  String LoginURL() => mainURL() + "driverLogin";
  String DriverDataURL() => mainURL() + "DriverData";
  String ListSJ() => mainURL() + "listSJ";
  String Berangkat() => mainURL() + "berangkat";
  String UpdateStatus() => mainURL() + "uploadFile";

  static const String SPUserKey = "UserModel";
  static const String SPDriverKey = "DriverModel";

  static const String DatabsePath = "MG_Truck.db";

  static const String formatDate = "dd/MM/yyyy";
}