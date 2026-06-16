import 'package:flutter/material.dart';
import 'package:frontend_v1/pages/ptourist3.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';
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

class PExplorationSubangJayaPage extends StatefulWidget {
  const PExplorationSubangJayaPage({super.key});

  @override
  State<PExplorationSubangJayaPage> createState() =>
      _PExplorationSubangJayaPageState();
}

class _PExplorationSubangJayaPageState
    extends State<PExplorationSubangJayaPage> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final historicalPlaces = [
      ExplorationItem(
        image:
            "https://lh3.googleusercontent.com/gps-cs-s/APNQkAHbGH8DhCMh3jc08aefDnIGp9RYX7u2C3F24FA3ciKXY3iZIa18ybsNq85Hjs0mlTlR1qxcruL2N8MqXnLm8W1tbugrjD7QmwTXSH0fmBOVf1fzR3F8zbr1ziOC48VeFoHA6eA=s1360-w1360-h1020-rw",
        title: loc.subangBlueMosqueTitle,
        date: "04/06/2026",
        description: loc.subangBlueMosqueDesc,
        fullExplanation: loc.subangBlueMosqueFull,
        mapUrl: "https://maps.app.goo.gl/HTfBB1uLwnLPTvnZ8",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRaFVH56Gt--JSz5K5d5E0t3Qzm1VLwiZihWw&s",
        title: loc.subangIstanaAlamTitle,
        date: "04/06/2026",
        description: loc.subangIstanaAlamDesc,
        fullExplanation: loc.subangIstanaAlamFull,
        mapUrl: "https://maps.app.goo.gl/VjostQqS5QrwKRqi9",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQVONujfyZDRSiDUqEmd16sDaoW_F7A27qnqg&s",
        title: loc.subangLakeGardenTitle,
        date: "04/06/2026",
        description: loc.subangLakeGardenDesc,
        fullExplanation: loc.subangLakeGardenFull,
        mapUrl: "https://maps.app.goo.gl/zNFpnn5UqtugQKHJ8",
      ),
    ];

    final interestingPlaces = [
      ExplorationItem(
        image: "https://sunwaylagoon.com/wp-content/uploads/2026/01/wav-1.jpg",
        title: loc.subangSunwayLagoonTitle,
        date: "04/06/2026",
        description: loc.subangSunwayLagoonDesc,
        fullExplanation: loc.subangSunwayLagoonFull,
        mapUrl: "https://maps.app.goo.gl/8WbNventbRmcBF9v9",
      ),
      ExplorationItem(
        image:
            "https://www.sunwaypyramid.com/static/jt-22-2-1710740648736/w768.jpg",
        title: loc.subangSunwayPyramidTitle,
        date: "04/06/2026",
        description: loc.subangSunwayPyramidDesc,
        fullExplanation: loc.subangSunwayPyramidFull,
        mapUrl: "https://maps.app.goo.gl/U5xroabfueguFFgV8",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQh8chgtHfKERBg1kOQTtoz8TczUEWxPhlVww&s",
        title: loc.subangRiaParkTitle,
        date: "04/06/2026",
        description: loc.subangRiaParkDesc,
        fullExplanation: loc.subangRiaParkFull,
        mapUrl: "https://maps.app.goo.gl/EvNF3hLPPiHo2MNE9",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTEGDFZmr84Iz-hLSkbfT0xTUMBJs80S-bwsg&s",
        title: loc.subangEmpireTitle,
        date: "04/06/2026",
        description: loc.subangEmpireDesc,
        fullExplanation: loc.subangEmpireFull,
        mapUrl: "https://maps.app.goo.gl/MjhL2wdGXVCXrMkr5",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTU8hsicaeZ3nXupILB5gTO0ju5o-hptX8L8Q&s",
        title: loc.subangSS15Title,
        date: "04/06/2026",
        description: loc.subangSS15Desc,
        fullExplanation: loc.subangSS15Full,
        mapUrl: "https://maps.app.goo.gl/yY7tZF4fbEanmWS29",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQL-NniGvRkJ-AR59oYRlWOMgblCP5Z6Vt_tw&s",
        title: loc.subangDaMenTitle,
        date: "04/06/2026",
        description: loc.subangDaMenDesc,
        fullExplanation: loc.subangDaMenFull,
        mapUrl: "https://maps.app.goo.gl/ZdR166V5DfPZr2dz8",
      ),
      ExplorationItem(
        image:
            "https://www.summit-usj.com/wp-content/uploads/2026/04/Summit-Building-for-Website.jpg-2.jpeg",
        title: loc.subangSummitTitle,
        date: "04/06/2026",
        description: loc.subangSummitDesc,
        fullExplanation: loc.subangSummitFull,
        mapUrl: "https://maps.app.goo.gl/GCGhf7D3n4tKzFve6",
      ),
    ];

    final eatingPlaces = [
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcStbVyDaQCCGHKIGuSSbChGH8yvam7OFZGafw&s",
        title: loc.subangJibbyTitle,
        date: "04/06/2026",
        description: loc.subangJibbyDesc,
        fullExplanation: loc.subangJibbyFull,
        mapUrl: "https://maps.app.goo.gl/WbNPKUokv8P7JQ7E6",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSgHsVA73iWcsJ-adk9xz_JqLl1PNMH4UpJCQ&s",
        title: loc.subangVillageParkTitle,
        date: "04/06/2026",
        description: loc.subangVillageParkDesc,
        fullExplanation: loc.subangVillageParkFull,
        mapUrl: "https://maps.app.goo.gl/C5VEb7pBwA8q8ET77",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQImB0PosFcBnoT-eCVVlg8Q6svP4jo9vsQDQ&s",
        title: loc.subangRakuzenTitle,
        date: "04/06/2026",
        description: loc.subangRakuzenDesc,
        fullExplanation: loc.subangRakuzenFull,
        mapUrl: "https://maps.app.goo.gl/kA8ovmkWyDFeYYBd9",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQmj6cEimcBmth5RflSqEyJLnoUdDA_8X0MpQ&s",
        title: loc.subangFoodStreetTitle,
        date: "04/06/2026",
        description: loc.subangFoodStreetDesc,
        fullExplanation: loc.subangFoodStreetFull,
        mapUrl: "https://maps.app.goo.gl/2Hy5RBJQ3CG3S9T28",
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
                loc.subangExplorationTitle,
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 3, 89, 210),
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
                    const SizedBox(width: 20),
                    Expanded(
                      child: _CategoryTab(
                        label: loc.tabInteresting,
                        selected: selectedTab == 1,
                        onTap: () => setState(() => selectedTab = 1),
                      ),
                    ),
                    const SizedBox(width: 20),
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
                      itemBuilder: (_, i) => _ExplorationCard(item: data[i]),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 160),
            ],
          ),
          Positioned(
            bottom: 150,
            left: 300,
            right: 300,
            child: KioskBackButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PTOURISTPAGE(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

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
          borderRadius: BorderRadius.circular(30),
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
              SizedBox(
                width: 300,
                height: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      item.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 80,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.date,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blueGrey[400],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.grey[800],
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.blueAccent),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExplorationDetailDialog extends StatelessWidget {
  final ExplorationItem item;

  const _ExplorationDetailDialog({required this.item});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 100, vertical: 80),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(40)),
                child: Image.network(
                  item.image,
                  height: 350,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      height: 350,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 100,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      item.fullExplanation,
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 40),
                    if (item.mapUrl != null) ...[
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: QrImageView(
                          data: item.mapUrl!,
                          size: 160,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Google Map",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(250, 80),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        loc.closetext,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
          color:
              selected ? const Color(0xFF0359D2) : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
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