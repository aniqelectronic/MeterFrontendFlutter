import 'dart:ffi';

//this class is used to store the data that will may change during runtime 
class Data {
  //rate per hour parking
  static double ratePerHour = 0.65;

    //call information number
  static String telefonNo = "03-4162 8672";

    //text copyright
  static String copyrightText = "Copyright © 2026 City Car Park. All rights reserved.";

    //talian aduan majlis
  static String aduanMajlisBentong = "1300-88-1148";

    //to change waktu solat for demo url justchange zone part. ps: to know the zone code is from https://www.e-solat.gov.my/
  static String waktusolatplacedemo = "Ipoh, Perak";
  static String waktusolaturldemo = "https://www.e-solat.gov.my/index.php?r=esolatApi/takwimsolat&zone=PRK02&period=today";

    //page map demo
  static double latitudedemo = 4.5975; 
  static double longitudedemo = 101.0901; 
}
