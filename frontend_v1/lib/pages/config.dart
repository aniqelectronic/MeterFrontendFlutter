import 'dart:ffi';

// This class is used to store the configuration of the terminal ( that will not change )
class Config {
  //backend base url
  static const String baseUrl = "http://4.194.122.32:8000";
  //for qr payment
  static String terminalId = "TEST03";
  static String storeId = "Kiosk_Terminal";
  static String shiftId = "DAY_SHIFT";
  static int qrValidity = 300;
  //for compaun
  static String forcifyEndpoint = "https://v2.forcify.xyz/api/v1/external"; //endpoint forcify kompaun kuantan
  static String forcifyToken = "5a5dd0ce-f986-4073-96a9-c3bbfe226fd9"; //forcify kompaun kuantan  token 
  static String compoundPrefix1 = "KN"; 
  //page map
  static double latitude = 3.06444; 
  static double longitude = 101.59361; 
  //page waktu solat
  //to change waktu solat url justchange zone part. ps: to know the zone code is from https://www.e-solat.gov.my/
  static String waktusolatplace = "Subang Jaya, Selangor";
  static String waktusolaturl = "https://www.e-solat.gov.my/index.php?r=esolatApi/takwimsolat&zone=SGR01&period=today";

  //for iot hub
  static const String iotHubSharedAccessKey ='9APQME52StSCTSBh/Jo4NhkLFo+AAo2pBpd8FOQYzoQ=';


}
