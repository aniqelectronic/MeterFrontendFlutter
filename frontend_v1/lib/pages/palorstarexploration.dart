import 'package:flutter/material.dart';
import 'package:frontend_v1/pages/ptourist3.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
class PExplorationAlorStarPage extends StatefulWidget {
  const PExplorationAlorStarPage({super.key});

  @override
  State<PExplorationAlorStarPage> createState() =>
      _PExplorationBentongPageState();
}

class _PExplorationBentongPageState extends State<PExplorationAlorStarPage> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final historicalPlaces = [
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ4sggDUKBS6cEIBHVhBFoq8Xqu4D9idbDhyQ&s",
        title: loc.muziumDirajaTitle,
        date: "01-01-2025",
        description: loc.muziumDirajaDesc,
        fullExplanation: loc.muziumDirajaFull,
        mapUrl: "https://maps.app.goo.gl/BASVsnR8XLVX1X5P6",
      ),
      ExplorationItem(
        image:
            "https://leveragehotel.com/cdn/shop/articles/Alor_Setar_Tower.webp?v=1704706820",
        title: loc.menaraAlorSetarTitle,
        date: "01-01-2025",
        description: loc.menaraAlorSetarDesc,
        fullExplanation: loc.menaraAlorSetarFull,
        mapUrl: "https://maps.app.goo.gl/9Me1Sc1Nz3vHFAcq7",
      ),
      ExplorationItem(
        image:
            "https://assets.nst.com.my/images/articles/Masjid-Zahir_1709982004.jpg",
        title: loc.masjidZahirTitle,
        date: "01-01-2025",
        description: loc.masjidZahirDesc,
        fullExplanation: loc.masjidZahirFull,
        mapUrl: "https://maps.app.goo.gl/G7vgr3xBeZztuP9R8",
      ),
      ExplorationItem(
        image:
            "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/0e/94/20/89/balai-besar-is-located.jpg?w=9600&h=-1&s=1",
        title: loc.balaiBesarTitle,
        date: "01-01-2025",
        description: loc.balaiBesarDesc,
        fullExplanation: loc.balaiBesarFull,
        mapUrl: "https://maps.app.goo.gl/uoMqiLdBnDguFqpm7",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQeFY7dJ_-vSWEAaUWN7U3j3aHtA6XXIXXI-Q&s",
        title: loc.mahathirHouseTitle,
        date: "01-01-2025",
        description: loc.mahathirHouseDesc,
        fullExplanation: loc.mahathirHouseFull,
        mapUrl: "https://maps.app.goo.gl/yZGxhH3W5PSyDfJP7",
      ),
    ];

    final interestingPlaces = [
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSiR0h13hP9e9eoBJDvKbwFAU-zAsF4fTkdRw&s",
        title: loc.muziumPadiTitle,
        date: "01-01-2025",
        description: loc.muziumPadiDesc,
        fullExplanation: loc.muziumPadiFull,
        mapUrl: "https://maps.app.goo.gl/tUZ9rN97h6fyBeSP7",
      ),
      ExplorationItem(
        image:
            "https://www.dagangnews.com/sites/default/files/inline-images/kedah%202.jpg",
        title: loc.skydeckTitle,
        date: "01-01-2025",
        description: loc.skydeckDesc,
        fullExplanation: loc.skydeckFull,
        mapUrl: "https://maps.app.goo.gl/9Me1Sc1Nz3vHFAcq7",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR-Igt4XaeM4ZigrMNgjNmCaaBPBsbi_zBjxw&s",
        title: loc.tamanJubliTitle,
        date: "01-01-2025",
        description: loc.tamanJubliDesc,
        fullExplanation: loc.tamanJubliFull,
        mapUrl: "https://maps.app.goo.gl/vVKqqJrLuQr35gpeA",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRYIdiHLmgfu5d2_mu-xsYFNCPiKkJepOgh-Q&s",
        title: loc.pekanRabuTitle,
        date: "01-01-2025",
        description: loc.pekanRabuDesc,
        fullExplanation: loc.pekanRabuFull,
        mapUrl: "https://maps.app.goo.gl/T52TKJGE5oA9ysav8",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/licensed-image?q=tbn:ANd9GcTl0I133u96Yfo2A-noW896OD0mwL7x8KwICD8Qqq9BkzHGvUClMn1ho8rNbK9btiPurbQqapH4kTiBDiBYHQCGdIKX&s=19",
        title: loc.kualaKedahTitle,
        date: "01-01-2025",
        description: loc.kualaKedahDesc,
        fullExplanation: loc.kualaKedahFull,
        mapUrl: "https://maps.app.goo.gl/uKnaUWvhQQ3jLwtu5",
      ),
    ];

    final eatingPlaces = [
      ExplorationItem(
        image:
            "https://lh3.googleusercontent.com/p/AF1QipM3lvVww107V9aJlJ3wHXKsMysyuPlgWjATn64l=s1360-w1360-h1020-rw",
        title: loc.royaleTitle,
        date: "01-01-2025",
        description: loc.royaleDesc,
        fullExplanation: loc.royaleFull,
        mapUrl: "https://maps.app.goo.gl/fXEuR2HghtTzEd7g9",
      ),
      ExplorationItem(
        image:
            "https://lh3.googleusercontent.com/gps-cs-s/AG0ilSx2INbK91UJV6RSqgj2CQOsXrfpan_-2HG0svwLZB4bLR-h82vbQdnqgeKnW9SNkDQEdXgfZbwGAj4IeTafWPIxf_j3ah3h34PQIo4GA1rGcgVnuAPsVoAtcv44W4QHFpQReyiqX30SYPA=w289-h312-n-k-no",
        title: loc.meeShamTitle,
        date: "01-01-2025",
        description: loc.meeShamDesc,
        fullExplanation: loc.meeShamFull,
        mapUrl: "https://maps.app.goo.gl/zEmCmNHWwuv7sHQA6",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRFolHJu0T1zVbf2EowoRjwV3WagiKS0tAJqQ&s",
        title: loc.laksaTelukKechaiTitle,
        date: "01-01-2025",
        description: loc.laksaTelukKechaiDesc,
        fullExplanation: loc.laksaTelukKechaiFull,
        mapUrl: "https://maps.app.goo.gl/DgTqWmuRHB9Y1LLW8",
      ),
      ExplorationItem(
        image:
            "https://lh3.googleusercontent.com/gps-cs-s/AG0ilSz9TRndx654Mq47QLVgKRdgF_oRShq1QtUJl7DTWVMOYzJMgXDCJ3PLJiChNFcsIJls5kWEmi_6swMVM6vuZOyye7SWf-TPbuPKedoBGujUOwvr3ZYodjalT-wF8Nc64r3oH4-FbuBU2YLU=w289-h312-n-k-no",
        title: loc.yasmeenTitle,
        date: "01-01-2025",
        description: loc.yasmeenDesc,
        fullExplanation: loc.yasmeenFull,
        mapUrl: "https://maps.app.goo.gl/GTioD5aFvtJUy9HL8",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRZWWV2AgAGW-ng2Ygfekw_KFdFke-7dhzQmA&s",
        title: loc.gulaiPanasTitle,
        date: "01-01-2025",
        description: loc.gulaiPanasDesc,
        fullExplanation: loc.gulaiPanasFull,
        mapUrl: "https://maps.app.goo.gl/8rwV4Cnb5sdWDNdz5",
      ),
    ];

    final data = selectedTab == 0
        ? historicalPlaces
        : selectedTab == 1
            ? interestingPlaces
            : eatingPlaces;

    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Background (FIXED)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/images/pnew.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
    
          // 🔹 FIXED CONTENT + SCROLLABLE LIST ONLY
          Column(
            children: [
              const SizedBox(height: 120),
    
              Text(
                loc.alorsetarExplorationTitle,
                style: const TextStyle(
                  color: Color.fromARGB(255, 3, 89, 210),
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                ),
              ),
    
              const SizedBox(height: 50),
    
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
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
    
              const SizedBox(height: 60),
    
              // ✅ ONLY THIS PART SCROLLS
            SizedBox(
              height: MediaQuery.of(context).size.height - 720,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 80),
                child: Scrollbar(
                  thumbVisibility: true,
                  thickness: 10,
                  radius: const Radius.circular(10),
                  child: ListView.separated(
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 30),
                    itemBuilder: (_, index) =>
                        _ExplorationCard(item: data[index]),
                  ),
                ),
              ),
            ),
 
              const SizedBox(height: 160), // space for back button
            ],
          ),
    
          // 🔹 FIXED BACK BUTTON (NO OVERFLOW)
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 600, // ✅ FIXED WIDTH (NO OVERFLOW)
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
          border: Border.all(color: Colors.black, width: 2),
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
                Flexible( // ✅ IMPORTANT
                  flex: 2,
                  child: Image.network(
                    item.image,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 30),
                Expanded(
                  flex: 3, // ✅ IMPORTANT
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        item.date,
                        style: const TextStyle(fontSize: 22),
                      ),
                      Text(
                        item.description,
                        style: const TextStyle(fontSize: 24),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
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
    final bool showQr = item.mapUrl != null;

    return Dialog(
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 80, vertical: 120),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
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
                const Text("Google Map",
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
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
