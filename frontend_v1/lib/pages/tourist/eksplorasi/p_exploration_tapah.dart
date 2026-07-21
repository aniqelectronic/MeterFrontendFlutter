import 'package:flutter/material.dart';
import 'package:frontend_v1/pages/tourist/ptourist3.dart';
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

class PExplorationTapahPage extends StatefulWidget {
  const PExplorationTapahPage({super.key});

  @override
  State<PExplorationTapahPage> createState() =>
      _PExplorationTapahPageState();
}

class _PExplorationTapahPageState
    extends State<PExplorationTapahPage> {

  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    /// ================= PERNIAGAAN =================
    final businessPlaces = [
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ_2RyZpe1vH1kZiMCCkyrW3ylXEU3SVXQpLA&s",
        title: "Memory Lane",
        date: "05/03/2026",
        description: loc.memoryLaneDesc,
        fullExplanation: loc.memoryLaneFull,
        mapUrl: "https://maps.app.goo.gl/ir39UqsnKz5eNUiCA",
      ),
      ExplorationItem(
        image: "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/1a/91/0a/ab/photo0jpg.jpg?w=900&h=500&s=1",
        title: "Concubine Lane",
        date: "05/03/2026",
        description: loc.concubineLaneDesc,
        fullExplanation: loc.concubineLaneFull,
        mapUrl: "https://maps.app.goo.gl/rf3qbPWme24tXrYMA",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ1cAQ6sCMvaJ4ALz1n1eTbPNjqctlz1ICu-A&s",
        title: "Lorong Seni",
        date: "05/03/2026",
        description: loc.lorongSeniDesc,
        fullExplanation: loc.lorongSeniFull,
        mapUrl: "https://maps.app.goo.gl/fXLDReoVqGcfQBFp8",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ205AjJIxXOvbx_JSxc1-mx-x2kNkfq_mwDQ&s",
        title: "Gerbang Malam",
        date: "05/03/2026",
        description: loc.gerbangMalamDesc,
        fullExplanation: loc.gerbangMalamFull,
        mapUrl: "https://maps.app.goo.gl/YEZ1R5CKfxPVeDFx8",
      ),
    ];

    /// ================= MENARIK =================
    final interestingPlaces = [
      ExplorationItem(
        image: "https://mdtapah.gov.my/templates/yootheme/cache/4f/pettingzoo-4f1c1008.jpeg",
        title: "Petting Zoo @ Gunung Lang",
        date: "05/03/2026",
        description: loc.pettingZooDesc,
        fullExplanation: loc.pettingZooFull,
        mapUrl:"https://maps.app.goo.gl/h6qh3ZPiGRzPUYVWA",
      ),
      ExplorationItem(
        image: "https://mdtapah.gov.my/templates/yootheme/cache/e6/light-e67a9d18.jpeg",
        title: "Light & Sound @ Ipoh Padang",
        date: "05/03/2026",
        description: loc.lightSoundDesc,
        fullExplanation: loc.lightSoundFull,
        mapUrl:"https://maps.app.goo.gl/fVeTBpdCGx7KDC6j6",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTtSzU3sqz1S5j5-w4mwmdTr6OYl2EGx5oGJg&s",
        title: "Ipoh Padang",
        date: "05/03/2026",
        description: loc.ipohPadangDesc,
        fullExplanation: loc.ipohPadangFull,
        mapUrl:"https://maps.app.goo.gl/fVeTBpdCGx7KDC6j6",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTjiWIuJLtvz3mEvdKafWe-t6UZ0OFqFp9GvQ&s",
        title: "Taman Rekreasi Sultan Abdul Aziz",
        date: "05/03/2026",
        description: loc.sultanAzizDesc,
        fullExplanation: loc.sultanAzizFull,
        mapUrl:"https://maps.app.goo.gl/2L2nf8hQpWuDUJya8",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRdZap-j0H5TluT3rxuDp1zIPi7ZSEsLLvqRQ&s",
        title: "Taman Rekreasi Gunung Lang",
        date: "05/03/2026",
        description: loc.gunungLangDesc,
        fullExplanation: loc.gunungLangFull,
        mapUrl:"https://maps.app.goo.gl/rdGgq9XAKsshemhUA",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTZIOSTL5VhOfgzk5IUGem-DkfyWj8jGF3pgg&s",
        title: "Taman Jepun",
        date: "05/03/2026",
        description: loc.tamanJepunDesc,
        fullExplanation: loc.tamanJepunFull,
        mapUrl:"https://maps.app.goo.gl/mC4NqHAq8Vhg3oBx5",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSB8kv67znAVY3IG_rlySaWoluHujlU121mkQ&s",
        title: "Taman D.R. Seenivasagam",
        date: "05/03/2026",
        description: loc.drSeenivasagamDesc,
        fullExplanation: loc.drSeenivasagamFull,
        mapUrl:"https://maps.app.goo.gl/GXyuZV4bZAkevYmbA",
      ),
      ExplorationItem(
        image: "https://mdtapah.gov.my/templates/yootheme/cache/08/gua-tambun-08e1a663.jpeg",
        title: "Gua Tambun",
        date: "05/03/2026",
        description: loc.guaTambunDesc,
        fullExplanation: loc.guaTambunFull,
        mapUrl:"https://maps.app.goo.gl/2iuWM2DLGmPBqyUe8",
      ),
      ExplorationItem(
        image: "https://lh3.googleusercontent.com/gps-cs-s/AHVAweqZc3_7cH9kabQ4YCjfRRdjs2KHfhbw0dO1lPWS7rS3PUqsSv9rUTGHhOyEL2QbZqFHOQL_AexerIYbHz1nGDjJa9NUlyHW2buZotXUbuYH2OgYt8SE_gVunbSLiVOwq_mIb87Q=w289-h312-n-k-no",
        title: "Qin Xing Ling",
        date: "05/03/2026",
        description: loc.qinXingLingDesc,
        fullExplanation: loc.qinXingLingFull,
        mapUrl:"https://maps.app.goo.gl/pmUgnxtRBeqA6TMw6",
      ),
      ExplorationItem(
        image: "https://lh3.googleusercontent.com/gps-cs-s/AHVAweogn6fysGkXBv6d-th1f0PlvU7nRQfOvYIJO8LCXBLLXmOEYYFaSaQncr5Hmp_cCQvuIw8QBglPmqyhy7ty9N8hwHRZqOQjtvBHNcD74iswqJC5kO9zBGZNecrUbkT879wVP8G-1Q=s1360-w1360-h1020-rw",
        title: "Gua Masoorat",
        date: "05/03/2026",
        description: loc.guaMasooratDesc,
        fullExplanation: loc.guaMasooratFull,
        mapUrl:"https://maps.app.goo.gl/62Xq858XFgWkdpWMA",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR-VkGDVrXNvQpyuVz64Whlbrc-KBjP6caNgQ&s",
        title: "Tasek Cermin",
        date: "05/03/2026",
        description: loc.tasekCerminDesc,
        fullExplanation: loc.tasekCerminFull,
        mapUrl:"https://maps.app.goo.gl/KURPpbfJSVq8nJ3e8",
      ),
    ];

    /// ================= MAKAN =================
    final eatingPlaces = [
      ExplorationItem(
          image: "https://lh3.googleusercontent.com/gps-cs-s/AHVAweqO7m-EIfqQMOJf1syU7n9j0eJm82RkFgoeV71mAjAT5HPTYF0P2Ws1TSRrQzYnJdwnkXbc9Ya5NL6GiDCarsChgrTP1B7bhCov9xpeXWV6x8sbavmW6iv3nQNnVbFAnrAzkyH45ziwlT9H=w289-h312-n-k-no",
          title: "Medan Selera Dato Sagor",
          date: "05/03/2026",
          description: loc.medanSagorDesc,
          fullExplanation: loc.medanSagorFull,
          mapUrl:"https://maps.app.goo.gl/VLcNtAJS25djwiPw8",
          ),
      ExplorationItem(
          image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRiCqKcPIZ1Hc3uWhFVCblexlbN_1_1I_4hWQ&s",
          title: "Rojak N Cendol Padang Ipoh",
          date: "05/03/2026",
          description: loc.rojakDesc,
          fullExplanation: loc.rojakFull,
          mapUrl:"https://maps.app.goo.gl/RTA8neywarYrfMeS6",
          ),
      ExplorationItem(
          image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQzpGVbx5U6b4KDM-6kPfxG5tHDn2eQP6Mm8g&s",
          title: "Plan B",
          date: "05/03/2026",
          description: loc.planBDesc,
          fullExplanation: loc.planBFull,
          mapUrl:"https://maps.app.goo.gl/nbFnZEnk96eXJ4ns6",
          ),
      ExplorationItem(
          image: "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/07/40/bc/99/stg-boutique-cafe.jpg?w=900&h=500&s=1",
          title: "STG Ipoh Old Town",
          date: "05/03/2026",
          description: loc.stgDesc,
          fullExplanation: loc.stgFull,
          mapUrl:"https://maps.app.goo.gl/vwuCtdWy6JVHkjsS9",
          ),
      ExplorationItem(
          image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSeZuuNLPOitTbXWs9g6K63hu4iB-83t6bF6w&s",
          title: "Durbar at FMS",
          date: "05/03/2026",
          description: loc.durbarDesc,
          fullExplanation: loc.durbarFull,
          mapUrl:"https://maps.app.goo.gl/SVkDcMKp1hApqjQ48",
          ),
      ExplorationItem(
          image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRijnWYPNa9gFrSisNDDBv1lR_m7xLxa5BcIQ&s",
          title: "Miker Pizza",
          date: "05/03/2026",
          description: loc.mikerDesc,
          fullExplanation: loc.mikerFull,
          mapUrl:"https://maps.app.goo.gl/Vm7NiwFbLp3o7jJo6",
          ),
      ExplorationItem(
          image: "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/0b/0e/aa/8f/tandoor-grill.jpg?w=900&h=500&s=1",
          title: "Tandoor Grill",
          date: "05/03/2026",
          description: loc.tandoorDesc,
          fullExplanation: loc.tandoorFull,
          mapUrl:"https://maps.app.goo.gl/qAeDzkrvzPxCpbWWA",
          ),
      ExplorationItem(
          image: "https://mdtapah.gov.my/templates/yootheme/cache/65/ipoh-central-kitchen-659bbbce.jpeg",
          title: "Ipoh Central Kitchen",
          date: "05/03/2026",
          description: loc.centralKitchenDesc,
          fullExplanation: loc.centralKitchenFull,
          mapUrl:"https://maps.app.goo.gl/RrwqQRAZpgwnarXt7",
          ),
      ExplorationItem(
          image: "https://lh3.googleusercontent.com/p/AF1QipPErPQVyn266AqnYZdPeyDpV3ACD98SI_CFbWM=w289-h312-n-k-no",
          title: "Greentown Dimsum Cafe",
          date: "05/03/2026",
          description: loc.greentownDesc,
          fullExplanation: loc.greentownFull,
          mapUrl:"https://maps.app.goo.gl/WxQLoLYdYufwtwHn8",
          ),
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
              Text(loc.tapahExplorationTitle,
                  style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 3, 89, 210))),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(children: [
                  Expanded(child: _CategoryTab(
                      label: loc.tabBusiness,
                      selected: selectedTab == 0,
                      onTap: () => setState(() => selectedTab = 0))),
                  const SizedBox(width: 20),
                  Expanded(child: _CategoryTab(
                      label: loc.tabInteresting,
                      selected: selectedTab == 1,
                      onTap: () => setState(() => selectedTab = 1))),
                  const SizedBox(width: 20),
                  Expanded(child: _CategoryTab(
                      label: loc.tabEating,
                      selected: selectedTab == 2,
                      onTap: () => setState(() => selectedTab = 2))),
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