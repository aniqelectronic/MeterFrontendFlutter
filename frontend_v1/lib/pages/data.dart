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
  static String waktusolatplacedemo = "Ipoh, Perak";
  static String waktusolaturldemo = "https://www.e-solat.gov.my/index.php?r=esolatApi/takwimsolat&zone=PRK02&period=today";

    //page map demo
  static double latitudedemo = 4.59865; 
  static double longitudedemo = 101.089914; 

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
  static String lastUpdatedDate = "2026-08-07 12:20:00";
}
