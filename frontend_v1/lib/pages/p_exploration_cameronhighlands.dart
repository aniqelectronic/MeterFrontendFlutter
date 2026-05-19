import 'package:flutter/material.dart';
import 'package:frontend_v1/pages/ptourist3.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ExplorationItem {
  final String image;
  final String title;
  final String date;
  final String description;
  final String fullExplanation;
  final String? mapUrl;

  ExplorationItem({
    required this.image,
    required this.title,
    required this.date,
    required this.description,
    required this.fullExplanation,
    this.mapUrl,
  });
}

class PExplorationCameronPage extends StatefulWidget {
  const PExplorationCameronPage({super.key});

  @override
  State<PExplorationCameronPage> createState() =>
      _PExplorationCameronPageState();
}

class _PExplorationCameronPageState
    extends State<PExplorationCameronPage> {

  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {

    final loc = AppLocalizations.of(context)!;

    /// ================= BUSINESS =================
    final businessPlaces = [

      ExplorationItem(image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSDJKmbaf1xvVN__n2d4EsX7bNrnFk4UF7DJA&s",title:"Pasar Pagi Kea Farm Market",date:"05/03/2026",description:loc.keaFarmMarketDesc,fullExplanation:loc.keaFarmMarketFull,mapUrl: "https://maps.app.goo.gl/bNLeeRuQYLsMZW6j9"),
      ExplorationItem(image:"https://petitguru.s3.amazonaws.com/482/1.png",title:"Farmers Arcade Cameron Highlands",date:"05/03/2026",description:loc.farmersArcadeDesc,fullExplanation:loc.farmersArcadeFull,mapUrl: "https://maps.app.goo.gl/RiCP6cm3EaXY5xDZA"),
      ExplorationItem(image:"https://lh3.googleusercontent.com/gps-cs-s/AHVAwepKqzlkQsrBFe2gwlEwR8WQuDo6nQk5DpINC52TYCXJbvECcucZA_HWNDpmPtFsu_1y3Eq9_iPgMN0plnZbLJQQFwqOHi9W6fxsUl52RboISahdEzPNZaKD_OohjMSX65PyW7Ljcx-8mdba=w243-h174-n-k-no-nu",title:"Bazar Kea Farm Cameron Highlands",date:"05/03/2026",description:loc.bazarKeaFarmDesc,fullExplanation:loc.bazarKeaFarmFull,mapUrl: "https://maps.app.goo.gl/Ur265GC8hLrVpv2d7"),
      ExplorationItem(image:"https://thesmartlocal.my/wp-content/uploads/2023/05/Agro-Market-in-Cameron-Highlands-4.jpg",title:"Agro Market",date:"05/03/2026",description:loc.agroMarketDesc,fullExplanation:loc.agroMarketFull,mapUrl: "https://maps.app.goo.gl/id7HQoC8rVtDAsUw9"),
      ExplorationItem(image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQZCcMSPaXLZK3Yv0f1TyG9zcqmIrolHCu-zQ&s",title:"S'Corner Central Market",date:"05/03/2026",description:loc.sCornerDesc,fullExplanation:loc.sCornerFull,mapUrl: "https://maps.app.goo.gl/fvtEmcL11MtTeDzq6"),
      ExplorationItem(image:"https://lh3.googleusercontent.com/gps-cs-s/AHVAwerRiO4anCt6FmVP_KmwQnaG72a8CrGdDXzrVE9wwFyyJU1E_jNF3PV6qmGIuTSDLuaI3k6ABRVAIGK5-qup4R7BuFxHIz5I-KQNcS-fOrtrmlBfNdFwY2ZR5wOmT-qD0Q7l5FGr-w=w408-h375-k-no",title:"Pasar Raya Cameron Highland",date:"05/03/2026",description:loc.pasarRayaDesc,fullExplanation:loc.pasarRayaFull,mapUrl: "https://maps.app.goo.gl/uzq2W8vPFWZcqqMC6"),
      ExplorationItem(image:"https://i0.wp.com/foodveler.com/wp-content/uploads/2023/02/Kea-Farm-Market-Foodveler-01.jpg?resize=1024%2C768&ssl=1",title:"Kea Farm Vegetable Farm",date:"05/03/2026",description:loc.keaVegetableDesc,fullExplanation:loc.keaVegetableFull,mapUrl: "https://maps.app.goo.gl/CnvxRDynYvcAuLRH7"),
      ExplorationItem(image:"https://lh3.googleusercontent.com/gps-cs-s/AHVAweqXEin-7HW4h_s4ntfk4ep38Ef-iTbOyIij1z_3qknuAZQAsksgSj7qO8wyTgDAWRqDHkS55343xu0YlokNQm8EtWR_tbYpGn9yHTjOjZF_RnHv6A1EyOx6bL6F5MH4VJexHFmChw=w408-h544-k-no",title:"Kok Lam Farm",date:"05/03/2026",description:loc.kokLamDesc,fullExplanation:loc.kokLamFull,mapUrl: "https://maps.app.goo.gl/epJvMRQxgfCXf98FA"),
      ExplorationItem(image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ5UA3XEQDfLdp1nCVPdE7_Dqep8eSzvrWNlw&s",title:"Cameron Square",date:"05/03/2026",description:loc.cameronSquareDesc,fullExplanation:loc.cameronSquareFull,mapUrl: "https://maps.app.goo.gl/Go8hVtjBqdgUujBP8"),
      ExplorationItem(image:"https://lh3.googleusercontent.com/p/AF1QipN3zzCaN6YBv1GUvwcC9RuCqjZOXO5vyt1Agvvo=w243-h174-n-k-no-nu",title:"Avant Chocolate Cameron Highlands",date:"05/03/2026",description:loc.avantChocolateDesc,fullExplanation:loc.avantChocolateFull,mapUrl: "https://maps.app.goo.gl/B6PHSUtkby2Tkbe77"),

    ];

    /// ================= INTERESTING =================
    final interestingPlaces = [

      ExplorationItem(image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQna-1sbNtSHnNMHuu_wuiK38_wJDucbOqxiA&s",title:"Cameron Centrum",date:"05/03/2026",description:loc.cameronCentrumDesc,fullExplanation:loc.cameronCentrumFull,mapUrl: "https://maps.app.goo.gl/g3mazU4PoGC4Ev9R9"),

      ExplorationItem(image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQHsDjEXhF6AN7MpV-QMsiLBs0VG-Meaa-Twg&s",title:"Green View Garden Cameron Highlands",date:"05/03/2026",description:loc.greenViewDesc,fullExplanation:loc.greenViewFull,mapUrl: "https://maps.app.goo.gl/hpfRtQCeGYhCxcpe9"),

      ExplorationItem(image:"https://static.wixstatic.com/media/3031f2_93c2299c698c437f84f4d1bd7cd1e838~mv2.jpg/v1/fill/w_655,h_369,q_90,enc_avif,quality_auto/3031f2_93c2299c698c437f84f4d1bd7cd1e838~mv2.jpg",title:"Lavender Garden (Cameron Lavender)",date:"05/03/2026",description:loc.lavenderGardenDesc,fullExplanation:loc.lavenderGardenFull,mapUrl: "https://maps.app.goo.gl/5kcQUEaKMgsy3UQv7"),

      ExplorationItem(image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR9ZI7Cg4YK-o-1XIff8FDai8wxKR0XbkAe8A&s",title:"BOH Tea Centre (Sungei Palas Garden)",date:"05/03/2026",description:loc.bohTeaDesc,fullExplanation:loc.bohTeaFull,mapUrl: "https://maps.app.goo.gl/1WmrMoF85bKpQbCi8"),

      ExplorationItem(image:"https://static.wixstatic.com/media/3031f2_0259ff2f5a104059a7cbde8bbc4a7e68~mv2.jpg/v1/fill/w_1360,h_1020,al_c,q_85/gunung-brinchang.jpg",title:"The Sheep Sanctuary",date:"05/03/2026",description:loc.sheepSanctuaryDesc,fullExplanation:loc.sheepSanctuaryFull,mapUrl: "https://maps.app.goo.gl/CrSs18eBJZEBcZ1w5"),

      ExplorationItem(image:"https://static.wixstatic.com/media/3031f2_1f11ed6126ed4e35bf5035d60fcf897e~mv2.jpg/v1/fill/w_1360,h_1020,al_c,q_85/2023-07-19.jpg",title:"Ladang Strawberi PPK Cameron Highlands",date:"05/03/2026",description:loc.ppkStrawberryDesc,fullExplanation:loc.ppkStrawberryFull,mapUrl: "https://maps.app.goo.gl/FXPAqrh6x782a66S9"),

      ExplorationItem(image:"https://www.maisinggah.com/wp-content/uploads/2022/03/Cameron-Highlands-Flora-Park-Taman-Yang-Luas.jpg.webp",title:"Cameron Highlands Flora Park",date:"05/03/2026",description:loc.floraParkDesc,fullExplanation:loc.floraParkFull,mapUrl: "https://maps.app.goo.gl/N8k4rhumuAyuaNTt5"),

      ExplorationItem(image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRFFeHYxtNhiHKj38COG7XIjcDCr-zLOjVarQ&s",title:"Animal Feeding Rainbow Garden",date:"05/03/2026",description:loc.rainbowGardenDesc,fullExplanation:loc.rainbowGardenFull,mapUrl: "https://maps.app.goo.gl/5fEYoZJEnEdvJVjT8"),

      ExplorationItem(image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTafMbLxQDoyVeI-FW_q-ul5u2a7yMGwmFG8w&s",title:"Cactus Point",date:"05/03/2026",description:loc.cactusPointDesc,fullExplanation:loc.cactusPointFull,mapUrl: "https://maps.app.goo.gl/j6DDimN2pKsf6R9q6"),

      ExplorationItem(image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQpioVtEvkpF38LS6ZSSQTo2WShA1ncuRkc-Q&s",title:"Highlands Apiary Farm",date:"05/03/2026",description:loc.apiaryFarmDesc,fullExplanation:loc.apiaryFarmFull,mapUrl: "https://maps.app.goo.gl/EJRyrr3VtJyMkezZA"),

      ExplorationItem(image:"https://i.ytimg.com/vi/qsCMcH9rKIs/maxresdefault.jpg",title:"O&R Garden",date:"05/03/2026",description:loc.orGardenDesc,fullExplanation:loc.orGardenFull,mapUrl: "https://maps.app.goo.gl/6H6fACg1fmcMGz846"),

      ExplorationItem(image:"https://static.wixstatic.com/media/3031f2_7c9d17ba0eb54f0393595aace20102e4~mv2.jpg/v1/fill/w_1360,h_1020,al_c,q_85/a0643-cameron2bvalley2bbharat2btea.jpg",title:"Taman Pertabalan Tanah Rata",date:"05/03/2026",description:loc.pertabalanDesc,fullExplanation:loc.pertabalanFull,mapUrl: "https://maps.app.goo.gl/JNCJgk3JwAbG9PFG8"),

      ExplorationItem(image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRwCBvaGRN4yd3CxOs9RJkyx3-g_6KgF9hskQ&s",title:"ZooMania Butterfly Farm",date:"05/03/2026",description:loc.zoomaniDesc,fullExplanation:loc.zoomaniFull,mapUrl: "https://maps.app.goo.gl/rPazHbWnZjq3YJe4A"),

      ExplorationItem(image:"https://www.visitpahang.my/wp-content/uploads/2022/11/1275469_160721087462255_1719597901_o.jpeg",title:"MARDI Agrotechnology Park",date:"05/03/2026",description:loc.mardiDesc,fullExplanation:loc.mardiFull,mapUrl: "https://maps.app.goo.gl/y4UkYqCXjXt9rKDs9"),

      ExplorationItem(image:"https://lh3.googleusercontent.com/p/AF1QipOBoduukj1qdvse8KbtOOwn_T0L4QQ4j5ztFmBY=w408-h304-k-no",title:"Cameron Highland Mossy Forest",date:"05/03/2026",description:loc.mossyForestDesc,fullExplanation:loc.mossyForestFull,mapUrl: "https://maps.app.goo.gl/mmVdDEw7QUgAMgdj8"),

      ExplorationItem(image:"https://www.mdcameron.gov.my/sites/default/files/styles/panopoly_image_original/public/main_12.jpg?itok=LfqlyNAS",title:"Ladang Lebah Ee Feng Gu",date:"05/03/2026",description:loc.eeFengDesc,fullExplanation:loc.eeFengFull,mapUrl: "https://maps.app.goo.gl/vzAJGi57q5XyizLs8"),

      ExplorationItem(image:"https://static.wixstatic.com/media/3031f2_6abfba7a85cb424c893d3ef5ec2b2554~mv2.jpg/v1/fill/w_960,h_960,al_c,q_85/gunung-brinchang.jpg",title:"Cameron Adventurous",date:"05/03/2026",description:loc.cameronAdventureDesc,fullExplanation:loc.cameronAdventureFull,mapUrl: "https://maps.app.goo.gl/SR13khVPNvopM4mR9"),

      ExplorationItem(image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS-U7oyC4LHWB_K_rzggr1W0CgOhufafz4PFA&s",title:"KC Kwang & Sons Grape Farm",date:"05/03/2026",description:loc.grapeFarmDesc,fullExplanation:loc.grapeFarmFull,mapUrl: "https://maps.app.goo.gl/wSt6iRzWX6bEE7XK8"),

      ExplorationItem(image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQI6nc-Qe4atpIKreX1DMA35OUvoQ8wKhpiRw&s",title:"Tan’s Camellia Garden",date:"05/03/2026",description:loc.camelliaDesc,fullExplanation:loc.camelliaFull,mapUrl: "https://maps.app.goo.gl/fStSjSyCtbQHS8Kv9"),

      ExplorationItem(image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTfDZYfA6ptQ7vFPQo5Lqdql2yDtoZH1o02-A&s",title:"Raju Hill Strawberry Farm",date:"05/03/2026",description:loc.rajuHillDesc,fullExplanation:loc.rajuHillFull,mapUrl: "https://maps.app.goo.gl/5sSSCiaHuw2E4Khw6"),

    ];

    /// ================= EATING =================
    final eatingPlaces = [

      ExplorationItem(image:"https://lh3.googleusercontent.com/gps-cs-s/AHVAwerV2IKT7joYxmhW0ejDvw7_KFf32no1XaJpOBCaGKQKM2D0bMzVUQnO9_gScp2-B-m4YXre_QzTtMCJYMS7Ph3Gs4Lw0BAVTwioF9j1fTL7o1Yy24tNsH2pOA-zqT3nZ9SxIA58=w408-h306-k-no",title:"KHM Strawberries & Jam",date:"05/03/2026",description:loc.khmDesc,fullExplanation:loc.khmFull,mapUrl: "https://maps.app.goo.gl/V6GCoyBcsZ5oqJof8"),

      ExplorationItem(image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSpR4YlhzKawqTnnYkYEv_Est7B8zNavzB6yw&s",title:"YZ Agro Farm (Kebun Strawberry & Kafe)",date:"05/03/2026",description:loc.yzAgroDesc,fullExplanation:loc.yzAgroFull,mapUrl: "https://maps.app.goo.gl/F8E3kcEWkFL8XKUQ8"),

      ExplorationItem(image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQSOL3xSGYR00NDdUjb9NBYFSEg6aqabe97xA&s",title:"Cameron Valley Tea House 1 ",date:"05/03/2026",description:loc.teaHouseDesc,fullExplanation:loc.teaHouseFull,mapUrl: "https://maps.app.goo.gl/jLwnGDwMXyA2CheT7"),

      ExplorationItem(image:"https://media-cdn.tripadvisor.com/media/photo-m/1280/15/8f/bf/6e/photo2jpg.jpg",title:"Cameron Valley Tea House 2 ",date:"05/03/2026",description:loc.teaHouseDesc,fullExplanation:loc.teaHouseFull,mapUrl: "https://maps.app.goo.gl/CyMde8YC3MXPzWF68"),

      ExplorationItem(image:"https://lh3.googleusercontent.com/gps-cs-s/AHVAwepNgNPLeZDVObhEn6F9iEhF-uM0mOvembUjO9nW0CSLXDhzKKrKVDvUiyHbB5XzrrqITBKpJw34TzpNvT-dL3IZoSgqZaOppA_Wnr0Tib2xrKyBRYk7zjeq2ItZaA4jOMmwHjfWfUD-kok=w408-h306-k-no",title:"Cameron Valley Tea House Kuala Terla",date:"05/03/2026",description:loc.teaKualaTerlaDesc,fullExplanation:loc.teaKualaTerlaFull,mapUrl: "https://maps.app.goo.gl/kHFivLTGmrGPsoVY8"),

      ExplorationItem(image:"https://lh3.googleusercontent.com/gps-cs-s/AHVAwerPs6101xDeY4hJUc_Sgurs_MRDfOMyZc4Gh4xnyFiFceVq6FnX6NpkWHeqwweaXLxNSSF3dYFVWd1jz0jlSdw1lHbsa9YqyUBDVLXwU0D-IjcCdLec0YHtVdJghgbto9DHQQq1wYRciyoT=s1360-w1360-h1020-rw",title:"200 Seeds Café By Abang Strawberry",date:"05/03/2026",description:loc.seedsCafeDesc,fullExplanation:loc.seedsCafeFull,mapUrl: "https://maps.app.goo.gl/Mmc7GfpSaf8RmWbRA"),

    ];

    final data = selectedTab == 0
        ? businessPlaces
        : selectedTab == 1
            ? interestingPlaces
            : eatingPlaces;

    return Scaffold(
      body: Stack(
        children: [

          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/images/pnew.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Column(
            children: [

              const SizedBox(height: 120),

              Text(loc.cameronExplorationTitle,
                  style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 3, 89, 210))),

              const SizedBox(height: 50),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(children: [

                  Expanded(child: _CategoryTab(label: loc.tabBusiness,selected: selectedTab == 0,onTap: () => setState(() => selectedTab = 0))),
                  const SizedBox(width: 20),
                  Expanded(child: _CategoryTab(label: loc.tabInteresting,selected: selectedTab == 1,onTap: () => setState(() => selectedTab = 1))),
                  const SizedBox(width: 20),
                  Expanded(child: _CategoryTab(label: loc.tabEating,selected: selectedTab == 2,onTap: () => setState(() => selectedTab = 2))),

                ]),
              ),

              const SizedBox(height: 60),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: ListView.separated(
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 30),
                    itemBuilder: (_, i) => _ExplorationCard(item: data[i]),
                  ),
                ),
              ),

              const SizedBox(height: 300),
            ],
          ),

          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 600,
                height: 120,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PTOURISTPAGE(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: const BorderSide(color: Colors.black, width: 2),
                  ),
                  child: Text(
                    loc.back,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



/// =====================================================
/// EXPLORATION CARD
/// =====================================================
class _ExplorationCard extends StatelessWidget {
  final ExplorationItem item;

  const _ExplorationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: '',
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (_, __, ___) => _ExplorationDetailDialog(item: item),
          transitionBuilder: (context, anim1, anim2, child) {
            return FadeTransition(
              opacity: anim1,
              child: ScaleTransition(scale: anim1, child: child),
            );
          },
        );
      },
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(30), // Softer corners
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Row(
            children: [
              // Image with a gradient overlay
              SizedBox(
                width: 300,
                height: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(item.image, fit: BoxFit.cover),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black26, Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.date,
                        style: TextStyle(fontSize: 18, color: Colors.blueGrey[400], fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Text(
                        item.description,
                        style: TextStyle(fontSize: 25, color: Colors.grey[800], height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.blueAccent),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
    );
  }
}
/// =====================================================
/// DETAIL POPUP (WITH QR CODE)
/// =====================================================
class _ExplorationDetailDialog extends StatelessWidget {
  final ExplorationItem item;
  const _ExplorationDetailDialog({required this.item});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: Colors.transparent, // Allow blurring behind
      insetPadding: const EdgeInsets.symmetric(horizontal: 100, vertical: 80),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Image Header
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                child: Image.network(item.image, height: 350, width: double.infinity, fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Text(item.title, textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Text(item.fullExplanation, style: const TextStyle(fontSize: 24, color: Colors.black87)),
                    const SizedBox(height: 40),
                    if (item.mapUrl != null) ...[
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: QrImageView(data: item.mapUrl!, size: 160),
                      ),
                      const SizedBox(height: 10),
                       Text("GOOGLE MAP", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                    ],
                    const SizedBox(height: 40),
                    // Back Button
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(250, 80),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child:  Text(loc.closetext, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
/// =====================================================
/// CATEGORY TAB
/// =====================================================
class _CategoryTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0359D2) : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected 
            ? [BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))] 
            : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : const Color(0xFF0359D2),
            ),
          ),
        ),
      ),
    );
  }
}