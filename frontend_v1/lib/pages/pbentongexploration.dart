import 'package:flutter/material.dart';
import 'package:frontend_v1/pages/ptourist3.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart'; // 🔹 ADDED

/// =====================================================
/// DATA MODEL
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
/// MAIN PAGE
/// =====================================================
class PExplorationBentongPage extends StatefulWidget {
  const PExplorationBentongPage({super.key});

  @override
  State<PExplorationBentongPage> createState() =>
      _PExplorationBentongPageState();
}

class _PExplorationBentongPageState extends State<PExplorationBentongPage> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final historicalPlaces = [
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQEdvh0RbFnBeFk9h6sc6HpuyXZohLtPywXfA&s",
        title: loc.jomKeBentongGallery,
        date: "12-01-2025",
        description: loc.jomKeBentongDesc,
        fullExplanation: loc.jomKeBentongFull,
        mapUrl: "https://maps.app.goo.gl/BR2nvpgHHs5AEEr28", // ✅ Galeri Bentong
      ),
    ];

    final interestingPlaces = [
      ExplorationItem(
        image:
            "https://dusuntua.com/images/listing_photos/312_saujanajandabaik.jpg",
        title: loc.jandaBaikTitle,
        date: "31-01-2025",
        description: loc.jandaBaikDesc,
        fullExplanation: loc.jandaBaikFull,
        mapUrl: "https://maps.app.goo.gl/CRxy3uAnJqjcL98i8", // ✅ Janda Baik
      ),
      ExplorationItem(
        image:
            "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/12/db/1d/e9/bentong-walk.jpg?w=900&h=-1&s=1",
        title: loc.bentongWalkTitle,
        date: "13-01-2025",
        description: loc.bentongWalkDesc,
        fullExplanation: loc.bentongWalkFull,
        mapUrl: "https://maps.app.goo.gl/1FaxWsKexk8Gh4cG8", // ✅ Bentong Walk
      ),
    ];

   
   final eatingPlaces = [
     ExplorationItem(
       image:
           "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEikZIUVUqNiy64ftMiTZLC2gzpuXa4XRJTnseA4qFC-mjT_k1sqiRHAke4rZjNeLabhyphenhyphen1V_jwSQpiaLswWnIRZwn_DAeBNa_DOvVtL3g88FDP_mo2_4mDF5qc29BxaQKr-I79dAkKwW9m0/s1600/20200223_102207.jpg",
       title: loc.lemangTokKiTitle,
       date: "20-01-2025",
       description: loc.lemangTokKiDesc,
       fullExplanation: loc.lemangTokKiFull,
       mapUrl: "https://maps.app.goo.gl/YboBicTtotyEPMwi6", // ✅ Lemang Tok Ki
     ),
   ];


    List<ExplorationItem> data =
        selectedTab == 0
            ? historicalPlaces
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

          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                loc.bentongExplorationTitle,
                style: const TextStyle(
                  color: Color.fromARGB(255, 3, 89, 210),
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Positioned(
            top: 310,
            left: 40,
            right: 40,
            child: Row(
              children: [
                Expanded(
                  child: _CategoryTab(
                    label: loc.tabHistorical,
                    selected: selectedTab == 0,
                    onTap: () => setState(() => selectedTab = 0),
                  ),
                ),
                const _TabDivider(),
                Expanded(
                  child: _CategoryTab(
                    label: loc.tabInteresting,
                    selected: selectedTab == 1,
                    onTap: () => setState(() => selectedTab = 1),
                  ),
                ),
                const _TabDivider(),
                Expanded(
                  child: _CategoryTab(
                    label: loc.tabEating,
                    selected: selectedTab == 2,
                    onTap: () => setState(() => selectedTab = 2),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 500,
            left: 80,
            right: 80,
            bottom: 320,
            child: ListView.separated(
              itemCount: data.length,
              separatorBuilder: (_, __) => const SizedBox(height: 30),
              itemBuilder: (_, index) =>
                  _ExplorationCard(item: data[index]),
            ),
          ),

          Positioned(
            bottom: 200,
            left: 300,
            right: 300,
            child: SizedBox(
              width: 300,
              height: 120,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PTOURISTPAGE()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: const BorderSide(color: Colors.black, width: 2),
                ),
                child: Text(
                  loc.back,
                  style:
                      const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
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
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => _ExplorationDetailDialog(item: item),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
      
          // 🔹 BUTTON EFFECT
          border: Border.all(
            color: Colors.black,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(3, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.network(item.image, width: 200, height: 140, fit: BoxFit.cover),
            const SizedBox(width: 30),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold)),
                  Text(item.date, style: const TextStyle(fontSize: 22)),
                  Text(item.description,
                      style: const TextStyle(fontSize: 24)),
                ],
              ),
            ),
          ],
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
   
   final bool showQr = item.mapUrl != null;



    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 80, vertical: 120),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.title,
                  style: const TextStyle(
                      fontSize: 36, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Image.network(item.image, height: 220),
              const SizedBox(height: 20),
              Text(item.fullExplanation,
                  style: const TextStyle(fontSize: 26)),

             if (showQr) ...[
               const SizedBox(height: 30),
               QrImageView(
                 data: item.mapUrl!,
                 size: 180,
                 backgroundColor: Colors.white,
               ),
               const SizedBox(height: 10),
               const Text(
                 "Google Map",
                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
               ),
             ],


              const SizedBox(height: 40),
              SizedBox(
                width: 300,
                height: 100,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: const BorderSide(color: Colors.black, width: 2),
                ),
                child: Text(
                  AppLocalizations.of(context)!.back,
                  style:
                      const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                ),
              ),
            const SizedBox(height: 30),
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: selected ? Colors.blue.withOpacity(0.1) : Colors.white,
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Column(
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.blue : Colors.black,
              ),
            ),
            if (selected)
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 120,
                height: 5,
                color: Colors.red,
              ),
          ],
        ),
      ),
    );
  }
}

/// =====================================================
/// TAB DIVIDER
/// =====================================================
class _TabDivider extends StatelessWidget {
  const _TabDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 4, height: 90, color: Colors.black);
  }
}

