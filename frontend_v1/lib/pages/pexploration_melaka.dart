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
class PExplorationMelakaPage extends StatefulWidget {
  const PExplorationMelakaPage({super.key});

  @override
  State<PExplorationMelakaPage> createState() => _PExplorationMelakaPageState();
}

class _PExplorationMelakaPageState extends State<PExplorationMelakaPage> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    /// ================= HISTORICAL PLACES =================
    final historicalPlaces = [
      ExplorationItem(
        image: "https://www.maisinggah.com/wp-content/uploads/2024/07/Kota-A-Famosa.webp",
        title: "A Famosa",
        date: "04/02/2026",
        description: loc.aFamosaDesc,
        fullExplanation: loc.aFamosaFull,
        mapUrl: "https://maps.app.goo.gl/C1YHmSUuMfPsih4v7",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTO5R8ly2hXQoYUyKpCD1Y9pR3azuwEMErQ5Q&s",
        title: "Perigi Hang Tuah",
        date: "04/02/2026",
        description: loc.perigiHangTuahDesc,
        fullExplanation: loc.perigiHangTuahFull,
        mapUrl: "https://maps.app.goo.gl/psEmbmdWwrSwAsV49",
      ),
      ExplorationItem(
        image: "https://www.mbmb.gov.my/images/2023/08/11/istana_kesultanan_melaka.jpg",
        title: "Muzium Istana Kesultanan Melaka",
        date: "04/02/2026",
        description: loc.istanaKesultananDesc,
        fullExplanation: loc.istanaKesultananFull,
        mapUrl: "https://maps.app.goo.gl/zpHiHKfd8xu6Cd3bA",
      ),
      ExplorationItem(
        image: "https://www.babanyonyamuseum.com/wp-content/uploads/2024/07/home-facade-cropped.webp",
        title: "Baba & Nyonya Heritage Museum",
        date: "04/02/2026",
        description: loc.babaNyonyaDesc,
        fullExplanation: loc.babaNyonyaFull,
        mapUrl: "https://maps.app.goo.gl/8XyggmfjRtDEAspe9",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTtvcgctDV1EOjbknYZFsMHWs4_vmQpv8XT-w&s",
        title: "Galeri Warisan Kota Melaka",
        date: "04/02/2026",
        description: loc.galeriWarisanDesc,
        fullExplanation: loc.galeriWarisanFull,
        mapUrl: "https://maps.app.goo.gl/PAM3mJShJzJgqiWB7",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRUCwRqyssNHqDryxGDRFOZ86nw1be4k_wBaQ&s",
        title: "Cheng Ho Cultural Museum",
        date: "04/02/2026",
        description: loc.chengHoDesc,
        fullExplanation: loc.chengHoFull,
        mapUrl: "https://maps.app.goo.gl/9qnd6FSVSRVKGW3S9",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRCH0B35JbYrLd5XRhmh-07T3zVtMO43_5TYA&s",
        title: "Samudera Museum",
        date: "04/02/2026",
        description: loc.samuderaDesc,
        fullExplanation: loc.samuderaFull,
        mapUrl: "https://maps.app.goo.gl/PeSNLbqg7ihXvQGx9",
      ),
      ExplorationItem(
        image: "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/1a/f7/f2/1c/middleburg-bastion.jpg?w=900&h=-1&s=1",
        title: "Middelburg Bastion",
        date: "04/02/2026",
        description: loc.middelburgDesc,
        fullExplanation: loc.middelburgFull,
        mapUrl: "https://maps.app.goo.gl/XY8WrPgzPYg8DgCv8",
      ),
      ExplorationItem(
        image: "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/0a/30/d1/e7/melaka-history-and-ethnography.jpg?w=700&h=400&s=1",
        title: "The History and Ethnography Museum",
        date: "04/02/2026",
        description: loc.ethnoDesc,
        fullExplanation: loc.ethnoFull,
        mapUrl: "https://maps.app.goo.gl/EpAPBTLWWiyxgLvi6",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQt6O_rC_sPMeRUCc8dYMkEGupzreh1MsMuXg&s",
        title: "0km Melaka",
        date: "04/02/2026",
        description: loc.zeroKmDesc,
        fullExplanation: loc.zeroKmFull,
        mapUrl: "https://maps.app.goo.gl/bLwTeyXy9ebAKxYHA",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSISG4rhvq13_a1tEQ8j5erKZS9WpLO38B9UQ&s",
        title: "Church of Saint Paul, Malacca",
        date: "04/02/2026",
        description: loc.stPaulDesc,
        fullExplanation: loc.stPaulFull,
        mapUrl: "https://maps.app.goo.gl/qRKcoAsq4pbLi6sDA",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTBrlNUt8eyin_KFtq3aZt4KwS0GlNTnVBMuQ&s",
        title: "Hang Jebat Mausoleum",
        date: "04/02/2026",
        description: loc.hangJebatDesc,
        fullExplanation: loc.hangJebatFull,
        mapUrl: "https://maps.app.goo.gl/FyTkLbK3rDBLa4or9",
      ),
    ];

    /// ================= INTERESTING PLACES =================
    final interestingPlaces = [
      ExplorationItem(
        image: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/25/Malacca_Zoo_and_Bird_Farm.jpg/1280px-Malacca_Zoo_and_Bird_Farm.jpg",
        title: "Zoo Melaka",
        date: "04/02/2026",
        description: loc.zooDesc,
        fullExplanation: loc.zooFull,
        mapUrl: "https://maps.app.goo.gl/7m2BWu4PTTsvXWzY7",
      ),
      ExplorationItem(
        image: "https://www.maisinggah.com/wp-content/uploads/2024/07/Melaka-River-Cruise-Gambar-Waktu-Siang.webp",
        title: "Melaka River Cruise Jeti Taman Rempah",
        date: "04/02/2026",
        description: loc.riverDesc,
        fullExplanation: loc.riverFull,
        mapUrl:"https://maps.app.goo.gl/zxhH28cTfYj9nTxo7",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSJCbd73kkwXO_rLEF3Fi4BmpTLUgq-PrKdcw&s",
        title: "Taman Buaya & Rekreasi Melaka",
        date: "04/02/2026",
        description: loc.crocDesc,
        fullExplanation: loc.crocFull,
        mapUrl:"https://maps.app.goo.gl/M48p3hErzCh4P3Dj6",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTBCOy_8q0d4ToR9STJFk0izczvv6C82DSsTg&s",
        title: "Magic Art 3D Museum",
        date: "04/02/2026",
        description: loc.magicDesc,
        fullExplanation: loc.magicFull,
        mapUrl:"https://maps.app.goo.gl/QsTVe4s6JAAQteBA9",
      ),
      ExplorationItem(
        image: "https://breakoutescapegame.com/wp-content/uploads/2024/10/Breakout-Melaka-Poster-Collage-1024x362-1.jpg",
        title: "Breakout Melaka - Escape Room & Spy Game Junior",
        date: "04/02/2026",
        description: loc.breakoutDesc,
        fullExplanation: loc.breakoutFull,
        mapUrl:"https://maps.app.goo.gl/87H4QETJX4tZu2vk6",
      ),
      ExplorationItem(
        image: "https://res.klook.com/images/fl_lossy.progressive,q_65/c_fill,w_9600,h_630/w_80,x_15,y_15,g_south_west,l_Klook_water_br_trans_yhcmh3/activities/fvrybqt1y8envnreruyj/AFamosaTicketinMelaka-KlookMalaysia.jpg",
        title: "A'Famosa Water Theme Park",
        date: "04/02/2026",
        description: loc.waterDesc,
        fullExplanation: loc.waterFull,
        mapUrl:"https://maps.app.goo.gl/nGxNhMj7et4WAi2m6",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSOqHLT4s-UFRVcZU7csZCxiwhwUp6_ShU5lQ&s",
        title: "MoCity Fun Park",
        date: "04/02/2026",
        description: loc.mocityDesc,
        fullExplanation: loc.mocityFull,
        mapUrl:"https://maps.app.goo.gl/RqQ7JtdhcwFXBQUu8",
      ),
      ExplorationItem(
        image: "https://visitmelaka.com.my/images/culture/melakawonderland.jpg",
        title: "Melaka Wonderland Theme Park & Resort",
        date: "04/02/2026",
        description: loc.wonderlandDesc,
        fullExplanation: loc.wonderlandFull,
        mapUrl:"https://maps.app.goo.gl/6jjMf4Y7LR33qvvQ6",
      ),
      ExplorationItem(
        image: "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/28/cf/fb/d4/playground-for-your-kids.jpg?w=900&h=500&s=1",
        title: "Wonderpark Melaka",
        date: "04/02/2026",
        description: loc.wonderparkDesc,
        fullExplanation: loc.wonderparkFull,
        mapUrl:"https://maps.app.goo.gl/93pmjgmuYqZukyfSA",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSkMw5Fa0EdMx4FNsAjqUf10eR0-IbGpYI1FA&s",
        title: "UK Fun Park",
        date: "04/02/2026",
        description: loc.ukfunDesc,
        fullExplanation: loc.ukfunFull,
        mapUrl:"https://maps.app.goo.gl/tmh1sWs8q3Anqk157",
      ),
      ExplorationItem(
        image: "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/17/f0/d7/70/enjoy-elephant-feeding.jpg?w=900&h=500&s=1",
        title: "A'Famosa Safari Wonderland",
        date: "04/02/2026",
        description: loc.safariDesc,
        fullExplanation: loc.safariFull,
        mapUrl:"https://maps.app.goo.gl/QY5Z27rnbpcD2o689",
      ),
      ExplorationItem(
        image: "https://www.maisinggah.com/wp-content/uploads/2024/07/Asahan-Water-Theme-Park-Gambar-Baru.webp",
        title: "Asahan Water Theme Park",
        date: "04/02/2026",
        description: loc.asahanDesc,
        fullExplanation: loc.asahanFull,
        mapUrl:"https://maps.app.goo.gl/GUTCaXg8pudzSHzw7",
      ),
      ExplorationItem(
        image: "https://pix10.agoda.net/hotelImages/400249/-1/5523ce19f6bfd456732643f9610b76f7.jpg?ce=0&s=414x232",
        title: "Bayou Lagoon Water Park",
        date: "04/02/2026",
        description: loc.bayouDesc,
        fullExplanation: loc.bayouFull,
        mapUrl:"https://maps.app.goo.gl/TTBYKCsjg2uZpAq67",
      ),
    ];

    /// ================= EATING PLACES =================
    final eatingPlaces = [
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQXJH59dD3UhrP3rtulK7iohUkJm8m-6adCvQ&s",
        title: "Restoran Baba Kaya",
        date: "04/02/2026",
        description: loc.babaKayaDesc,
        fullExplanation: loc.babaKayaFull,
        mapUrl:"https://maps.app.goo.gl/3MsddLAZBvpKGSY17",
      ),
      ExplorationItem(
        image: "https://lh3.googleusercontent.com/gps-cs-s/AHVAweoi067NWZtbld5adjaFcufD88-LjBftNAp88JmIKOi1M7NXfhCf4SG2tAfoclA5guiYTBjuqkMN3D2jl74ldJDS-7jK4H2DMtdJH2AXnGv-zQ9i_zuNhW4ZR8IL16cccxSUTlKqKStuo45m=w289-h312-n-k-no",
        title: "Asam Pedas Selera Kampung Sdn Bhd",
        date: "04/02/2026",
        description: loc.asamSeleraDesc,
        fullExplanation: loc.asamSeleraFull,
        mapUrl:"https://maps.app.goo.gl/QXQ9eQeBTNrsMNV5A",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQZYJ3l2U5-efHfSd9h9Ick1V0zwfzUtx7B4Q&s",
        title: "ATLANTIC NYONYA @ MELAKA RAYA",
        date: "04/02/2026",
        description: loc.atlanticDesc,
        fullExplanation: loc.atlanticFull,
        mapUrl:"https://maps.app.goo.gl/iy4gNNJevBBLkCFx8",
      ),
      ExplorationItem(
        image: "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/2a/d3/49/89/caption.jpg?w=9600&h=9600&s=1",
        title: "Cendol Kampung Hulu",
        date: "04/02/2026",
        description: loc.cendolDesc,
        fullExplanation: loc.cendolFull,
        mapUrl:"https://maps.app.goo.gl/vMZtWnuvppTAJw7S9",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTgdodx76TBSb1MkGTdquOaaafxhRwt7gMS9Q&s",
        title: "Asam Pedas Orang Kampung",
        date: "04/02/2026",
        description: loc.asamOrangDesc,
        fullExplanation: loc.asamOrangFull,
        mapUrl:"https://maps.app.goo.gl/Fykgn4eNkDg5XzGz8",
      ),
      ExplorationItem(
        image: "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/2b/31/70/b3/caption.jpg?w=9600&h=9600&s=1",
        title: "Atas Restaurant – Heritage Riverside Dining",
        date: "04/02/2026",
        description: loc.atasDesc,
        fullExplanation: loc.atasFull,
        mapUrl:"https://maps.app.goo.gl/Qpb4T8NuZfDqVuCb9",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTlic12WdVSRsMBRmcL0vY4ITjtSkEGlak1mw&s",
        title: "Rooftop Cafe & Resto Melaka",
        date: "04/02/2026",
        description: loc.rooftopDesc,
        fullExplanation: loc.rooftopFull,
        mapUrl:"https://maps.app.goo.gl/vi18R6vBT58EuUnB9",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQBBq0LcUsUuYwgZWML9mzERyjmPk-rIgDlgw&s",
        title: "Cafe Chef Wan @ The Shore Melaka",
        date: "04/02/2026",
        description: loc.chefWanDesc,
        fullExplanation: loc.chefWanFull,
        mapUrl:"https://maps.app.goo.gl/Ucpt2DdMxADmMw86A",
      ),
      ExplorationItem(
        image: "https://www.freemalaysiatoday.com/cdn-cgi/image/width=3840,quality=80,format=auto,fit=scale-down,metadata=none,dpr=1,onerror=redirect/https://media.freemalaysiatoday.com/wp-content/uploads/2022/12/outside.jpg",
        title: "Calanthe Art Cafe",
        date: "04/02/2026",
        description: loc.calantheDesc,
        fullExplanation: loc.calantheFull,
        mapUrl:"https://maps.app.goo.gl/jJPsnC3ToQBENKFK6",
      ),
      ExplorationItem(
        image: "https://lh3.googleusercontent.com/p/AF1QipOyC6LQw4E_fti2BOYC81F0tXR5rF-xkabdphAe=w480-h300-k-n-rw",
        title: "Papayun Kitchen, Tepi Sungai, Kg Hulu, Bandar Melaka",
        date: "04/02/2026",
        description: loc.papayunDesc,
        fullExplanation: loc.papayunFull,
        mapUrl:"https://maps.app.goo.gl/HSmyuRQPpCFy27NfA",
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
                loc.melakaExplorationTitle,
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
