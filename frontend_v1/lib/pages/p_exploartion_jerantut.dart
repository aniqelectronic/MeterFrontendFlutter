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

class PExplorationJerantutPage extends StatefulWidget {
  const PExplorationJerantutPage({super.key});

  @override
  State<PExplorationJerantutPage> createState() =>
      _PExplorationJerantutPageState();
}

class _PExplorationJerantutPageState extends State<PExplorationJerantutPage> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final historicalPlaces = [
      ExplorationItem(
        image:
            "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjGosMS5UK-yuFgjt6QuxgNZwQSqyiMkaGif51R7Fj3j2sxrfEYHVobHRqeRfh-M78CZ65DsVdQLXtgdRfafb1kaKpmDF36LVmXFB3_Ze_-75mhErCPnbhEAHT06YAQvFqzqfZH4e6gow/s1600/12313752_1072953262716432_5106261533996871985_n.jpg",
        title: "Kompleks Galeri Mat Kilau Pulau Tawar",
        date: "04/02/2026",
        description: loc.matKilauDesc,
        fullExplanation: loc.matKilauFull,
        mapUrl: "https://maps.app.goo.gl/4v8im1hYBYcYh2pD6",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT2-8TUZWkKrXcHVrjDXKX1KqJl0YHk_MDbFA&s",
        title: "LAMAN MAT KILAU",
        date: "04/02/2026",
        description: loc.lamanMatKilauDesc,
        fullExplanation: loc.lamanMatKilauFull,
        mapUrl: "https://maps.app.goo.gl/j2thdZaLpEuW42Ue9",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRbRPmjDDp4nBEGBvyOJuolNuhcnC7x8md4pQ&s",
        title: "Bekas Hentian Kereta Api Lama (Kuala Tembeling)",
        date: "04/02/2026",
        description: loc.kualaTembelingDesc,
        fullExplanation: loc.kualaTembelingFull,
        mapUrl: "https://maps.app.goo.gl/FRxoV4qTNr8uEFgv5",
      ),
    ];

    final interestingPlaces = [
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQpyeeIw_a71ahL2kh1kjJVb4qvgxkxHNHgQg&s",
        title: "Lata Meraung",
        date: "04/02/2026",
        description: loc.lataMeraungDesc,
        fullExplanation: loc.lataMeraungFull,
        mapUrl: "https://maps.app.goo.gl/TLqLiYsJAvL57sfH6",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS8cnEVVQuRJG528ARm1IG-NOetxQ0q4tGqnw&s",
        title: "Taman I-City Jerantut",
        date: "04/02/2026",
        description: loc.icityDesc,
        fullExplanation: loc.icityFull,
        mapUrl: "https://maps.app.goo.gl/JZZQazcREdssXSew7",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQo0N5DWaEjqTLHDD0S7neDU7QuwiypX5NOhg&s",
        title: "Gua Kota Gelanggi",
        date: "04/02/2026",
        description: loc.gelanggiDesc,
        fullExplanation: loc.gelanggiFull,
        mapUrl: "https://maps.app.goo.gl/XD2u5MeHCW5U2tu98",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSCAOmkLBTNgwRQJ58QAJBVBN1kfAv2l3ZNJw&s",
        title: "D’PUMA HOUSE",
        date: "04/02/2026",
        description: loc.dpumaDesc,
        fullExplanation: loc.dpumaFull,
        mapUrl: "https://maps.app.goo.gl/55BDEFYRoWFBspwY8",
      ),
      ExplorationItem(
        image: "https://damak.nadi.my/wp-content/uploads/2024/09/2.jpg",
        title: "Rumah Rakit D'jongkei Kelola",
        date: "04/02/2026",
        description: loc.rakitDesc,
        fullExplanation: loc.rakitFull,
        mapUrl: "https://maps.app.goo.gl/DEZ9cRaxCgMf9zBK6",
      ),
      ExplorationItem(
        image:
            "https://pokokkelapa.wordpress.com/wp-content/uploads/2024/07/pokok-kelapa-bukit-merak-bukit-buloh-11.jpg",
        title: "Bukit Merah (The Red Forest)",
        date: "04/02/2026",
        description: loc.bukitMerahDesc,
        fullExplanation: loc.bukitMerahFull,
        mapUrl: "https://maps.app.goo.gl/kjCfnhLyeLahgYXk9",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSRcQ1d1ZhZpDe2JFufSDt9qfnnzMU7HoDlTw&s",
        title: "Via Ferrata Paya Gunung",
        date: "04/02/2026",
        description: loc.viaFerrataDesc,
        fullExplanation: loc.viaFerrataFull,
        mapUrl: "https://maps.app.goo.gl/iikP1meaZeTkLqfFA",
      ),
    ];

    final eatingPlaces = [
      ExplorationItem(
        image:
            "https://lh3.googleusercontent.com/p/AF1QipOZKhuM7LX4YpLsGP_bvhtrXF9mXN2C2iJwmtfH=s1360-w1360-h1020-rw",
        title: "Sate Temeen Jerantut",
        date: "04/02/2026",
        description: loc.food1Desc,
        fullExplanation: loc.food1Full,
        mapUrl: "https://maps.app.goo.gl/GjVKGLr6NbdCKTUEA",
      ),
      ExplorationItem(
        image:
            "https://www.visitpahang.my/wp-content/uploads/2022/12/img-20200220-154411-largejpg.jpeg",
        title: "Gypsy Garden Jerantut Cafe",
        date: "04/02/2026",
        description: loc.food2Desc,
        fullExplanation: loc.food2Full,
        mapUrl: "https://maps.app.goo.gl/iiueTG8dmwSzjDbK6",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRMV3SFi0TbNfdoZTS6xssr0fKiUPg6RPTPpg&s",
        title: "Warong Gantong",
        date: "04/02/2026",
        description: loc.food3Desc,
        fullExplanation: loc.food3Full,
        mapUrl: "https://maps.app.goo.gl/aa9Szxy9HVYNjeUaA",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTtvFiVCbmH3njOxuU71ojmZ25YvlpjXKDNbg&s",
        title: "Murtabak Jerantut Ferry Restaurant",
        date: "04/02/2026",
        description: loc.food4Desc,
        fullExplanation: loc.food4Full,
        mapUrl: "https://maps.app.goo.gl/URTWDiojuxR8AZDKA",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ-F1hDIipyxh_sGrDzlncWsqHIqp7nYtnHxA&s",
        title: "Kedai Makan Makan Di Jerantut",
        date: "04/02/2026",
        description: loc.food5Desc,
        fullExplanation: loc.food5Full,
        mapUrl: "https://maps.app.goo.gl/NRp8K3vAZh6u9TMw5",
      ),
      ExplorationItem(
        image:
            "https://www.visitpahang.my/wp-content/uploads/2022/11/WhatsApp-Image-2022-11-24-at-2.34.51-PM.jpeg",
        title: "Kopi Chantek",
        date: "04/02/2026",
        description: loc.food6Desc,
        fullExplanation: loc.food6Full,
        mapUrl: "https://maps.app.goo.gl/wMw4G5GZjN39rfbV7",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT4mgtDl6k_Kvn-fP-VdGZtiSy0FDunkdu-ng&s",
        title: "Bojiocafe Jerantut Pahang",
        date: "04/02/2026",
        description: loc.food7Desc,
        fullExplanation: loc.food7Full,
        mapUrl: "https://maps.app.goo.gl/e5gPFkjfxXMPGihr7",
      ),
      // ExplorationItem(
      //   image:
      //       "https://lh3.googleusercontent.com/gps-cs-s/AHVAweoP2TV9vFbL31U8uuCxDbdaPioOep-GImkWCwf-c77UUnINPuwWTbDI88trNM7EDrVYF9q7VIb_90NoTGq6Pq2QZhximwdJYGNCcnjaq1FIjVeUBj8bXUfUKYWU5e59Bk7-A8zrzw=w408-h306-k-no",
      //   title: "Kedai Kopi Puteh",
      //   date: "04/02/2026",
      //   description: loc.food8Desc,
      //   fullExplanation: loc.food8Full,
      //   mapUrl: "https://maps.app.goo.gl/knhoGiZvuXNvo3tk8",
      // ),
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
                loc.jerantutExplorationTitle,
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
              child: ScaleTransition(
                scale: anim1,
                child: child,
              ),
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
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black26,
                            Colors.transparent,
                          ],
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 20,
                  ),
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

/// =====================================================
/// DETAIL POPUP WITH QR CODE
/// =====================================================
class _ExplorationDetailDialog extends StatelessWidget {
  final ExplorationItem item;

  const _ExplorationDetailDialog({required this.item});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 100,
        vertical: 80,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(40),
                ),
                child: Image.network(
                  item.image,
                  height: 350,
                  width: double.infinity,
                  fit: BoxFit.cover,
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
                          border: Border.all(
                            color: Colors.grey[300]!,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: QrImageView(
                          data: item.mapUrl!,
                          size: 160,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "GOOGLE MAP",
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