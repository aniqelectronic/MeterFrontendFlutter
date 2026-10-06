import 'dart:ffi';

//this class is used to store the data that will may change during runtime 
class Data {
  //rate per hour parking
  static double ratePerHour = 0.65;

    //call information number
  static String telefonNo = "03-4162 8672";

    //text copyright
  static String copyrightText = "Copyright © 2026 Juara Inovasi Pasifik. All rights reserved.";

    //talian aduan majlis
  static String aduanMajlisBentong = "1300-88-1148";

    //to change waktu solat for demo url justchange zone part. ps: to know the zone code is from https://www.e-solat.gov.my/
  static String waktusolatplacedemo = "Kuala Lumpur, Melaka";
  static String waktusolaturldemo = "https://www.e-solat.gov.my/index.php?r=esolatApi/takwimsolat&zone=MLK01&period=today";

    //page map demo
  static double latitudedemo = 2.250 ; 
  static double longitudedemo = 102.250; 

  //iimmpact api key and secret
  static const String iimmpactApiKey =
    'iimm_dev_GsdV7nL4xb95Vl3MB7dLOBYKDZ9Y3Uyo';

  static const String iimmpactHmacSecret =
      'GxsoPPUj20q+irjuQkIUdWLSvQi63yVDCeoVETp43HA=';
    
  static const String iimmpactBaseUrl =
      'https://staging.iimmpact.com';

  static const double electricityServiceFee = 1.00;

  static const double waterServiceFee = 1.00;

  //update the date the code was last updated
  static String lastUpdatedDate = "2026-10-06 16:40:00";

  //pbt which area
  static String pbtArea = "Melaka";

  // ============================================================
  // WEATHER
  // ============================================================

  static String weatherPlaceName = "Melaka";

  static String weatherLocationId = "St012";

  
}
