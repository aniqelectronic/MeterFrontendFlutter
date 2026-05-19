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
class PExplorationBeraPage extends StatefulWidget {
  const PExplorationBeraPage({super.key});

  @override
  State<PExplorationBeraPage> createState() => _PExplorationBeraPageState();
}

class _PExplorationBeraPageState extends State<PExplorationBeraPage> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    /// ================= HISTORICAL =================
    final historicalPlaces = [
      ExplorationItem(
        image:
            "https://lh3.googleusercontent.com/gps-cs-s/AHVAwercWfvb3QG4zGiKBDlqVPCToI6Nfo1hz89aUqm4Y26hWVpEyk5jBhJgV4o385HZ6mmmG_ZfgEiOSqsQKYM9aSidupqGPYpyZZJVeZvY1A3Vp5tO2fQIfeb5JPWSTchGfFkvML-NL9Pa6Y3R=s1360-w1360-h1020-rw",
        title: loc.guaGelanggiTitle,
        date: "01-01-2026",
        description: loc.guaGelanggiDesc,
        fullExplanation: loc.guaGelanggiFull,
        mapUrl: "https://maps.app.goo.gl/3vXgYbPHxyhVSNSYA",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSakSoQ41P5eBdVX10MWY2BeFXeUowmRwFdkw&s",
        title: loc.beraSemelaiTitle,
        date: "01-01-2026",
        description: loc.beraSemelaiDesc,
        fullExplanation: loc.beraSemelaiFull,
        mapUrl: "https://maps.app.goo.gl/1tpturqwrXx8UJrk7",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQemxNTh1QHg3hq0NniWJIroEFTMIUF3sIrxA&s",
        title: loc.beraMasjidTitle,
        date: "01-01-2026",
        description: loc.beraMasjidDesc,
        fullExplanation: loc.beraMasjidFull,
        mapUrl: "https://maps.app.goo.gl/SbxBKCUuf3dvoTNT6",
      ),
    ];

    /// ================= INTERESTING =================
    final interestingPlaces = [
      ExplorationItem(
        image:
            "https://www.sinarharian.com.my/uploads/images/2019/01/26/166437.jpg",
        title: loc.bukitBertanggaTitle,
        date: "01-01-2026",
        description: loc.bukitBertanggaDesc,
        fullExplanation: loc.bukitBertanggaFull,
        mapUrl: "https://maps.app.goo.gl/sAmJu7jzLtouP8vs6",
      ),
      ExplorationItem(
        image:
            "https://www.alltrails.com/mugen/image/location-app-router?url=https%3A%2F%2Fimages.alltrails.com%2FeyJidWNrZXQiOiJhc3NldHMuYWxsdHJhaWxzLmNvbSIsImtleSI6InVwbG9hZHMvcGhvdG8vaW1hZ2UvMzA1NjY1OTcvZjUyNmE0MzdhYjMyZjVhZDJhNWY0ZGEwOGM3MTRhMDAuanBnIiwiZWRpdHMiOnsidG9Gb3JtYXQiOiJ3ZWJwIiwicmVzaXplIjp7IndpZHRoIjoiMTA4MCIsImhlaWdodCI6IjcwMCIsImZpdCI6ImNvdmVyIn0sInJvdGF0ZSI6bnVsbCwianBlZyI6eyJ0cmVsbGlzUXVhbnRpc2F0aW9uIjp0cnVlLCJvdmVyc2hvb3REZXJpbmdpbmciOnRydWUsIm9wdGltaXNlU2NhbnMiOnRydWUsInF1YW50aXNhdGlvblRhYmxlIjozfX19&w=3840&q=90",
        title: loc.bukitSenorangTitle,
        date: "01-01-2026",
        description: loc.bukitSenorangDesc,
        fullExplanation: loc.bukitSenorangFull,
        mapUrl: "https://maps.app.goo.gl/JVU1hEFKdEVksroNA",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRpL-VTse2v04OSTlGCdpjpM9yShZiUERyL6A&s",
        title: loc.lamanLesungTitle,
        date: "01-01-2026",
        description: loc.lamanLesungDesc,
        fullExplanation: loc.lamanLesungFull,
        mapUrl: "https://maps.app.goo.gl/uahabtyDW9DRjVwC9",
      ),
    ];

    /// ================= EATING =================
    final eatingPlaces = [
      ExplorationItem(
        image:
            "https://lh3.googleusercontent.com/gps-cs-s/AHVAwer_TYggaZPSLRpje2gWBwuv1v9WSbUi3W65eIKXzk0K69C_OryekYDPSfTZ_tWbxLC05qPx3xkZb9VkTA-eiC45qkYHaL1994Tpp1wOC-QADOsHbnYvzlCsj78wfS4q_AOKddjS=s1360-w1360-h1020-rw",
        title: loc.warungPatinTitle,
        date: "01-01-2026",
        description: loc.warungPatinDesc,
        fullExplanation: loc.warungPatinFull,
        mapUrl: "https://maps.app.goo.gl/pivxgXJVaTrjbzuZ7",
      ),
      ExplorationItem(
        image:
            "https://lh3.googleusercontent.com/p/AF1QipMgL_cXbq1VMDWCQbPW03RpXsRh2RhtUaEsUkk=w325-h218-n-k-no",
        title: loc.makanBaratTitle,
        date: "01-01-2026",
        description: loc.makanBaratDesc,
        fullExplanation: loc.makanBaratFull,
        mapUrl: "https://maps.app.goo.gl/3qao9yxwkZ7C2nTR8",
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
              Text(
                loc.beraExplorationTitle,
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
            Flexible(
              flex: 2,
              child: Image.network(
                item.image,
                height: 140,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 30),
            Expanded(
              flex: 3,
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 80, vertical: 120),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                    style: const TextStyle(
                        fontSize: 40, fontWeight: FontWeight.bold),
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

class _TabDivider extends StatelessWidget {
  const _TabDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 20);
  }
}
