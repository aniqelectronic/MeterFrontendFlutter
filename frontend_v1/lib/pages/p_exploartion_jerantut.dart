import 'package:flutter/material.dart';
import 'package:frontend_v1/pages/pothers3.dart';
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

class _PExplorationJerantutPageState
    extends State<PExplorationJerantutPage> {

  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    /// ================= HISTORICAL =================
    final historicalPlaces = [
      ExplorationItem(
        image: "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjGosMS5UK-yuFgjt6QuxgNZwQSqyiMkaGif51R7Fj3j2sxrfEYHVobHRqeRfh-M78CZ65DsVdQLXtgdRfafb1kaKpmDF36LVmXFB3_Ze_-75mhErCPnbhEAHT06YAQvFqzqfZH4e6gow/s1600/12313752_1072953262716432_5106261533996871985_n.jpg",
        title: "Kompleks Galeri Mat Kilau Pulau Tawar",
        date: "04/02/2026",
        description: loc.matKilauDesc,
        fullExplanation: loc.matKilauFull,
        mapUrl:"https://maps.app.goo.gl/4v8im1hYBYcYh2pD6",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT2-8TUZWkKrXcHVrjDXKX1KqJl0YHk_MDbFA&s",
        title: "LAMAN MAT KILAU",
        date: "04/02/2026",
        description: loc.lamanMatKilauDesc,
        fullExplanation: loc.lamanMatKilauFull,
        mapUrl:"https://maps.app.goo.gl/j2thdZaLpEuW42Ue9",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRbRPmjDDp4nBEGBvyOJuolNuhcnC7x8md4pQ&s",
        title: "Bekas Hentian Kereta Api Lama (Kuala Tembeling)",
        date: "04/02/2026",
        description: loc.kualaTembelingDesc,
        fullExplanation: loc.kualaTembelingFull,
        mapUrl:"https://maps.app.goo.gl/FRxoV4qTNr8uEFgv5",
      ),
    ];

    /// ================= INTERESTING =================
    final interestingPlaces = [
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQpyeeIw_a71ahL2kh1kjJVb4qvgxkxHNHgQg&s",
        title: "Lata Meraung",
        date: "04/02/2026",
        description: loc.lataMeraungDesc,
        fullExplanation: loc.lataMeraungFull,
        mapUrl:"https://maps.app.goo.gl/TLqLiYsJAvL57sfH6",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS8cnEVVQuRJG528ARm1IG-NOetxQ0q4tGqnw&s",
        title: "Taman I-City Jerantut",
        date: "04/02/2026",
        description: loc.icityDesc,
        fullExplanation: loc.icityFull,
        mapUrl:"https://maps.app.goo.gl/JZZQazcREdssXSew7",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQo0N5DWaEjqTLHDD0S7neDU7QuwiypX5NOhg&s",
        title: "Gua Kota Gelanggi",
        date: "04/02/2026",
        description: loc.gelanggiDesc,
        fullExplanation: loc.gelanggiFull,
        mapUrl:"https://maps.app.goo.gl/XD2u5MeHCW5U2tu98",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSCAOmkLBTNgwRQJ58QAJBVBN1kfAv2l3ZNJw&s",
        title: "D’PUMA HOUSE",
        date: "04/02/2026",
        description: loc.dpumaDesc,
        fullExplanation: loc.dpumaFull,
        mapUrl:"https://maps.app.goo.gl/55BDEFYRoWFBspwY8",
      ),
      ExplorationItem(
        image: "https://damak.nadi.my/wp-content/uploads/2024/09/2.jpg",
        title: "Rumah Rakit D'jongkei Kelola",
        date: "04/02/2026",
        description: loc.rakitDesc,
        fullExplanation: loc.rakitFull,
        mapUrl:"https://maps.app.goo.gl/DEZ9cRaxCgMf9zBK6",
      ),
      ExplorationItem(
        image: "https://pokokkelapa.wordpress.com/wp-content/uploads/2024/07/pokok-kelapa-bukit-merak-bukit-buloh-11.jpg",
        title: "Bukit Merah (The Red Forest)",
        date: "04/02/2026",
        description: loc.bukitMerahDesc,
        fullExplanation: loc.bukitMerahFull,
        mapUrl:"https://maps.app.goo.gl/kjCfnhLyeLahgYXk9",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSRcQ1d1ZhZpDe2JFufSDt9qfnnzMU7HoDlTw&s",
        title: "Via Ferrata Paya Gunung",
        date: "04/02/2026",
        description: loc.viaFerrataDesc,
        fullExplanation: loc.viaFerrataFull,
        mapUrl:"https://maps.app.goo.gl/iikP1meaZeTkLqfFA",
      ),
    ];

    /// ================= FOOD =================
    final eatingPlaces = [
      ExplorationItem(
          image: "https://lh3.googleusercontent.com/p/AF1QipOZKhuM7LX4YpLsGP_bvhtrXF9mXN2C2iJwmtfH=s1360-w1360-h1020-rw",
          title: "Sate Temeen Jerantut",
          date: "04/02/2026",
          description: loc.food1Desc,
          fullExplanation: loc.food1Full,
          mapUrl:"https://maps.app.goo.gl/GjVKGLr6NbdCKTUEA",
          ),
      ExplorationItem(
          image: "https://www.visitpahang.my/wp-content/uploads/2022/12/img-20200220-154411-largejpg.jpeg",
          title: "Gypsy Garden Jerantut Cafe",
          date: "04/02/2026",
          description: loc.food2Desc,
          fullExplanation: loc.food2Full,
          mapUrl:"https://maps.app.goo.gl/iiueTG8dmwSzjDbK6",
          ),
      ExplorationItem(
          image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRMV3SFi0TbNfdoZTS6xssr0fKiUPg6RPTPpg&s",
          title: "Warong Gantong",
          date: "04/02/2026",
          description: loc.food3Desc,
          fullExplanation: loc.food3Full,
          mapUrl:"https://maps.app.goo.gl/aa9Szxy9HVYNjeUaA",
          ),
      ExplorationItem(
          image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTtvFiVCbmH3njOxuU71ojmZ25YvlpjXKDNbg&s",
          title: "Murtabak Jerantut Ferry Restaurant",
          date: "04/02/2026",
          description: loc.food4Desc,
          fullExplanation: loc.food4Full,
          mapUrl:"https://maps.app.goo.gl/URTWDiojuxR8AZDKA",
          ),
      ExplorationItem(
          image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ-F1hDIipyxh_sGrDzlncWsqHIqp7nYtnHxA&s",
          title: "Kedai Makan Makan Di Jerantut",
          date: "04/02/2026",
          description: loc.food5Desc,
          fullExplanation: loc.food5Full,
          mapUrl:"https://maps.app.goo.gl/NRp8K3vAZh6u9TMw5",
          ),
      ExplorationItem(
          image: "https://www.visitpahang.my/wp-content/uploads/2022/11/WhatsApp-Image-2022-11-24-at-2.34.51-PM.jpeg",
          title: "Kopi Chantek",
          date: "04/02/2026",
          description: loc.food6Desc,
          fullExplanation: loc.food6Full,
          mapUrl:"https://maps.app.goo.gl/wMw4G5GZjN39rfbV7",
          ),
      ExplorationItem(
          image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT4mgtDl6k_Kvn-fP-VdGZtiSy0FDunkdu-ng&s",
          title: "Bojiocafe Jerantut Pahang",
          date: "04/02/2026",
          description: loc.food7Desc,
          fullExplanation: loc.food7Full,
          mapUrl:"https://maps.app.goo.gl/e5gPFkjfxXMPGihr7",
          ),
      ExplorationItem(
          image: "https://lh3.googleusercontent.com/gps-cs-s/AHVAweoP2TV9vFbL31U8uuCxDbdaPioOep-GImkWCwf-c77UUnINPuwWTbDI88trNM7EDrVYF9q7VIb_90NoTGq6Pq2QZhximwdJYGNCcnjaq1FIjVeUBj8bXUfUKYWU5e59Bk7-A8zrzw=w408-h306-k-no",
          title: "Kedai Kopi Puteh",
          date: "04/02/2026",
          description: loc.food8Desc,
          fullExplanation: loc.food8Full,
          mapUrl:"https://maps.app.goo.gl/knhoGiZvuXNvo3tk8",
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
              Text(loc.jerantutExplorationTitle,
                  style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 3, 89, 210))),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(children: [
                  Expanded(child: _CategoryTab(
                      label: loc.tabHistorical,
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
                        builder: (_) => const POTHERS3PAGE(),
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
