import 'package:flutter/material.dart';
import 'package:frontend_v1/pages/tourist/ptourist3.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// =====================================================
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

/// =====================================================
class PExplorationKamparPage extends StatefulWidget {
  const PExplorationKamparPage({super.key});

  @override
  State<PExplorationKamparPage> createState() => _PExplorationKamparPageState();
}

class _PExplorationKamparPageState extends State<PExplorationKamparPage> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

/// ================= HISTORICAL =================
final historicalPlaces = [

ExplorationItem(
image:"https://i.postimg.cc/jdZxnxGH/Perlombongan-Bijih-Timah-di-Perak.jpg",
title:"Muzium Perlombongan Bijih Timah Kinta",
date:"04/02/2026",
description:loc.kintaTinDesc,
fullExplanation:loc.kintaTinFull,
mapUrl:"https://maps.app.goo.gl/22JjjHyvdp54Cnoq9",
),

ExplorationItem(
image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSsVO70aBDuJa3wbquDZtmt9e5mCGmod0Tl3Q&s",
title:"Japanese Carbide Chimney",
date:"04/02/2026",
description:loc.chimneyDesc,
fullExplanation:loc.chimneyFull,
mapUrl:"https://maps.app.goo.gl/h6oiiJRTmyPUjkfF8",
),

ExplorationItem(
image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSWD_JCEHtX-xsz-_3HHs4DrTKxPQhR8O284g&s",
title:"Kellie's Castle",
date:"04/02/2026",
description:loc.kellieDesc,
fullExplanation:loc.kellieFull,
mapUrl:"https://maps.app.goo.gl/N6ve7QUxMMDYdmDw5",
),

ExplorationItem(
image:"https://assets.hmetro.com.my/images/articles/12hma54b.transformed.jpg",
title:"Green Ridge Battle of Kampar",
date:"04/02/2026",
description:loc.greenRidgeDesc,
fullExplanation:loc.greenRidgeFull,
mapUrl:"https://maps.app.goo.gl/MaA9njM4qpC2uHb98",
),

ExplorationItem(
image:"https://www.mdkampar.gov.my/templates/yootheme/cache/4a/4-4ab9abdc.jpeg",
title:"Menara Jam Kampar",
date:"04/02/2026",
description:loc.clockDesc,
fullExplanation:loc.clockFull,
mapUrl:"https://maps.app.goo.gl/XuFSEbJyfhKvAhjW7",
),


];

/// ================= INTERESTING =================
final interestingPlaces = [

ExplorationItem(image:"https://cdn.motherhood.com.my/wp-content/uploads/sites/2/2023/02/04171741/West-Lake-Kampar.jpg",
title:"West Lake Kampar",date:"04/02/2026",
description:loc.westLakeDesc,fullExplanation:loc.westLakeFull,
mapUrl:"https://maps.app.goo.gl/vQr2W3arqS2U8KHK6"),

ExplorationItem(image:"https://www.mdkampar.gov.my/templates/yootheme/cache/f2/sasa1-f2c85659.jpeg",
title:"Ilham Seni Kampar",date:"04/02/2026",
description:loc.ilhamDesc,fullExplanation:loc.ilhamFull,
mapUrl:"https://maps.app.goo.gl/RspTWoKGPqP3o32r9"),

ExplorationItem(image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSEvnQHX5BSux1gP55wsVhqtZYJbUS5E99uiw&s",
title:"Gopeng Pipeline Bridge",date:"04/02/2026",
description:loc.pipelineDesc,fullExplanation:loc.pipelineFull,
mapUrl:"https://maps.app.goo.gl/fh78o3MKtvJEF2Kv6"),

ExplorationItem(image:"https://dynamic-media-cdn.tripadvisor.com/media/photo-o/1b/13/4f/8c/photo2jpg.jpg?w=9600&h=-1&s=1",
title:"Gua Tempurung",date:"04/02/2026",
description:loc.tempurungDesc,fullExplanation:loc.tempurungFull,
mapUrl:"https://maps.app.goo.gl/7va3h4FSUYsSye9i8"),

ExplorationItem(image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSkKjrIFsZRlcRiG5mgOqQDtczwSUZBuX7-vg&s",
title:"Sungai Salu Rainforest",date:"04/02/2026",
description:loc.saluDesc,fullExplanation:loc.saluFull,
mapUrl:"https://maps.app.goo.gl/1juG3HZaSGSTCpqy5"),

ExplorationItem(image:"https://www.startravel.com.my/wp-content/uploads/2024/04/30943092321_9f7260a8d2_b.jpg",
title:"Gua Kandu",date:"04/02/2026",
description:loc.kanduDesc,fullExplanation:loc.kanduFull,
mapUrl:"https://maps.app.goo.gl/L1Axr6oboZWKEh7h9"),

ExplorationItem(image:"https://lh3.googleusercontent.com/proxy/oeLysTyF6MHAFRXIXg4DAupaVU86mgzThk_kt0dyWls0E3pfQNsGmfYac8A_vv3qoiwilQSxKtvp5XYtNXz3xaq0HsjHYzytTRdOQXfZaX8XJbGLcwaYOOv2GQk7MudSQzRCpXD155D9tlQ",
title:"Disney Avenue Agacia Land",date:"04/02/2026",
description:loc.agaciaDesc,fullExplanation:loc.agaciaFull,
mapUrl:"https://maps.app.goo.gl/Q2aBF6wLe3yzviUL9"),

ExplorationItem(image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTrJC3hLr_7Hrh8SBpSUROXsTW2kYMzNkWA_w&s",
title:"Ladang Teh Gaharu",date:"04/02/2026",
description:loc.gaharuDesc,fullExplanation:loc.gaharuFull,
mapUrl:"https://maps.app.goo.gl/UEvTYyt6Dew5mJkNA"),

ExplorationItem(image:"https://dynamic-media-cdn.tripadvisor.com/media/photo-o/29/46/f5/c1/caption.jpg?w=900&h=500&s=1",
title:"Refarm",date:"04/02/2026",
description:loc.refarmDesc,fullExplanation:loc.refarmFull,
mapUrl:"https://maps.app.goo.gl/uMWDvHkx8iiAEQdE8"),

ExplorationItem(image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS3rnKu_WSsB7OinM7TqaACefBdcY2ALYgEcg&s",
title:"Sahom Valley Resort",date:"04/02/2026",
description:loc.sahomDesc,fullExplanation:loc.sahomFull,
mapUrl:"https://maps.app.goo.gl/w6Gb3DqTifmniPoo8"),

ExplorationItem(image:"https://ecentral.my/wp-content/uploads/2025/07/481664127_1217097826445331_6869294950229591304_n.jpg",
title:"Zahara Garden",date:"04/02/2026",
description:loc.zaharaDesc,fullExplanation:loc.zaharaFull,
mapUrl:"https://maps.app.goo.gl/qfH1MVwVU3gZMPsp7"),

];

/// ================= FOOD =================
final eatingPlaces = [

ExplorationItem(image:"https://lh3.googleusercontent.com/p/AF1QipMo7cxWjU43PvTAxN8YUzvT2DA_fTtnJTSA4FhU=s1360-w1360-h1020-rw",
title:"Buncit Cafe",date:"04/02/2026",
description:loc.buncitDesc,fullExplanation:loc.buncitFull,
mapUrl:"https://maps.app.goo.gl/9N3sLXPeVLMZLXiy8",
),

ExplorationItem(image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR4Q2jhh2NFgWHkIilQm6Vm-yIPcK5ILCqyPA&s",
title:"La’cottage Cafe and Chalet",date:"04/02/2026",
description:loc.lacottageDesc,fullExplanation:loc.lacottageFull,
mapUrl:"https://maps.app.goo.gl/AthmqxgFqZRPMX3Z9",
),


ExplorationItem(image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQPyny-AHsZg5c01mPc91XDygpWr6qIZsDVBw&s",
title:"Nasi Kandar Beratur 786",date:"04/02/2026",
description:loc.nasi786Desc,fullExplanation:loc.nasi786Full,
mapUrl:"https://maps.app.goo.gl/4TTVxpM6sDUeYyst8",
),

ExplorationItem(image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRjmKku4ll0PJB3nsO2Sf55x-MndVkrAPNETw&s",
title:"Restoran Adily",date:"04/02/2026",
description:loc.adilyDesc,fullExplanation:loc.adilyFull,
mapUrl:"https://maps.app.goo.gl/T2tX3BQ64ZX1LWP18",
),

ExplorationItem(image:"https://lh3.googleusercontent.com/p/AF1QipMrDfAEIbRoSggfDu1QBGnW-A0ZghW-V7v6L4Mn=w289-h312-n-k-no",
title:"Cousin'ss Cafe",date:"04/02/2026",
description:loc.cousinDesc,fullExplanation:loc.cousinFull,
mapUrl:"https://maps.app.goo.gl/3AZEfpVTESJ4Sngp7",
),


ExplorationItem(image:"https://lh3.googleusercontent.com/p/AF1QipN4KIB6wErhmCd5GJz78XO1CzPrHUP2wfH_SXnS=w325-h218-n-k-no",
title:"Jayne Kitchen Golden Fried Chicken Nasi Lemak",date:"04/02/2026",
description:loc.jayneDesc,fullExplanation:loc.jayneFull,
mapUrl:"https://maps.app.goo.gl/Vr4sBveM81zTESid9",
),

ExplorationItem(image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTHvaqShbq36mDSqAmoTCbAFNRkRIZME_G-zg&s",
title:"Nasi Ayam Peladang",date:"04/02/2026",
description:loc.peladangDesc,fullExplanation:loc.peladangFull,
mapUrl:"https://maps.app.goo.gl/TwXTnuDF1pmgKkSG7",
),

];

final data = selectedTab==0?historicalPlaces:selectedTab==1?interestingPlaces:eatingPlaces;

return Scaffold(
body: Stack(children:[

Container(decoration:const BoxDecoration(
image:DecorationImage(image:AssetImage("lib/images/pnew.png"),fit:BoxFit.cover))),

Column(children:[
const SizedBox(height:120),
Text(loc.kamparExplorationTitle,
style:const TextStyle(fontSize:52,fontWeight:FontWeight.bold,color:Color.fromARGB(255,3,89,210))),
const SizedBox(height:50),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(children: [

                  Expanded(child: _CategoryTab(label: loc.tabHistorical,selected: selectedTab == 0,onTap: () => setState(() => selectedTab = 0))),
                  const SizedBox(width: 20),
                  Expanded(child: _CategoryTab(label: loc.tabInteresting,selected: selectedTab == 1,onTap: () => setState(() => selectedTab = 1))),
                  const SizedBox(width: 20),
                  Expanded(child: _CategoryTab(label: loc.tabEating,selected: selectedTab == 2,onTap: () => setState(() => selectedTab = 2))),

                ]),
              ),

const SizedBox(height:60),

SizedBox(
height:MediaQuery.of(context).size.height-720,
child:Padding(
padding:const EdgeInsets.symmetric(horizontal:80),
child:Scrollbar(
thumbVisibility:true,
thickness:10,
radius:const Radius.circular(10),
child:ListView.separated(
itemCount:data.length,
separatorBuilder:(_,__)=>const SizedBox(height:30),
itemBuilder:(_,i)=>_ExplorationCard(item:data[i]),
)))),

const SizedBox(height:160),
]),

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

]));
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