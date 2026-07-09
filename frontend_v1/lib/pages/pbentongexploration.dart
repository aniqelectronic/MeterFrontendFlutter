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
        mapUrl: "https://maps.app.goo.gl/BR2nvpgHHs5AEEr28",
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
        mapUrl: "https://maps.app.goo.gl/CRxy3uAnJqjcL98i8",
      ),
      ExplorationItem(
        image:
            "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/12/db/1d/e9/bentong-walk.jpg?w=900&h=-1&s=1",
        title: loc.bentongWalkTitle,
        date: "13-01-2025",
        description: loc.bentongWalkDesc,
        fullExplanation: loc.bentongWalkFull,
        mapUrl: "https://maps.app.goo.gl/1FaxWsKexk8Gh4cG8",
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
        mapUrl: "https://maps.app.goo.gl/YboBicTtotyEPMwi6",
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
                loc.bentongExplorationTitle,
                textAlign: TextAlign.center,
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
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 2,
          ),
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

              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.blueAccent,
              ),
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
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: QrImageView(
                          data: item.mapUrl!,
                          size: 160,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Google Map",
                        style: TextStyle(
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
          color: selected
              ? const Color(0xFF0359D2)
              : Colors.white.withOpacity(0.7),
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
            textAlign: TextAlign.center,
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