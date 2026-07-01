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

class PExplorationTemerlohPage extends StatefulWidget {
  const PExplorationTemerlohPage({super.key});

  @override
  State<PExplorationTemerlohPage> createState() =>
      _PExplorationTemerlohPageState();
}

class _PExplorationTemerlohPageState
    extends State<PExplorationTemerlohPage> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    /// ================= BUSINESS =================
    final businessPlaces = [
      ExplorationItem(
          image:
              "https://malaysiagazette.com/wp-content/uploads/2022/11/MGF06112022_PASAR-SEHARI-TEMERLOH21.jpg",
          title: "Pekan Sehari Temerloh",
          date: "23/04/2026",
          description: loc.temBusiness1Desc,
          fullExplanation: loc.temBusiness1Full,
          mapUrl: "https://maps.app.goo.gl/VXECKRQkLCVWEiVr9"),
      ExplorationItem(
          image:
              "https://lh3.googleusercontent.com/gps-cs-s/APNQkAGvPu4GIDD-hQfQcpl0YRumhw0uJ1BSfCvw6O7hFnG3ODhY0UshzQWBBztqxIttDS61fhfZnyna0ES0R-syegYw1ngI6jGFMGWowRAvd9F0l33Rxi3wY3SOOWDmphHSStw8lx99dnpWLZM=s1360-w1360-h1020-rw",
          title: "Medan Selera Dataran Patin",
          date: "23/04/2026",
          description: loc.temBusiness2Desc,
          fullExplanation: loc.temBusiness2Full,
          mapUrl: "https://maps.app.goo.gl/7Q2nXUjqNwRjrfnQ6"),
      ExplorationItem(
          image:
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSHlTJCaPBPJpXOdaVsfu8CI2QN1tp3d9RcJA&s",
          title: "Pasar Besar Temerloh",
          date: "23/04/2026",
          description: loc.temBusiness3Desc,
          fullExplanation: loc.temBusiness3Full,
          mapUrl: "https://maps.app.goo.gl/qDQsvDmjiWBy6rH56"),
      ExplorationItem(
          image:
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRfXh-Hig2C1natPdY-WRI0Lgz_S2KAyj2Lsw&s",
          title: "Pasar Karat Temerloh",
          date: "23/04/2026",
          description: loc.temBusiness4Desc,
          fullExplanation: loc.temBusiness4Full,
          mapUrl: "https://maps.app.goo.gl/Dp7TGBqammr4ttJy6"),
      ExplorationItem(
          image:
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSWrzJ6V5o_6Ye4VRcS2fKviqGihslzLpZoTg&s",
          title: "Pasar Seni Temerloh",
          date: "23/04/2026",
          description: loc.temBusiness5Desc,
          fullExplanation: loc.temBusiness5Full,
          mapUrl: "https://maps.app.goo.gl/xWb16eSiUKYT7k9JA"),
      ExplorationItem(
          image:
              "https://lh3.googleusercontent.com/gps-cs-s/APNQkAEhShW_6jmHjt0Anc4u9BXULv0RVjtiq1TznLbcRKRVz9c_6zJE9-jauGADPhodfdGq1kE5Jsq95nIGjizqgaXeHHULy1hL_8mR2OHVacGylKFtA4-Yz4Fo8DcYLk-SSUrGGnZM=s1360-w1360-h1020-rw",
          title: "Pasar Warisan Temerloh",
          date: "23/04/2026",
          description: loc.temBusiness6Desc,
          fullExplanation: loc.temBusiness6Full,
          mapUrl: "https://maps.app.goo.gl/4CG1mbfBudFJFtwg6"),
      ExplorationItem(
          image:
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS_uCOVyds-kKxMtMo0PEtMBYj_r6Io7iUvxg&s",
          title: "Temerloh Night Market",
          date: "23/04/2026",
          description: loc.temBusiness7Desc,
          fullExplanation: loc.temBusiness7Full,
          mapUrl: "https://maps.app.goo.gl/VNFh5eBzVn6XaLXK8"),
    ];

    /// ================= INTERESTING =================
    final interestingPlaces = [
      ExplorationItem(
          image:
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRB4MOG097wgjLX4hbj7ZsGVDUZZcyywKUQrQ&s",
          title: "Titik Tengah Semenanjung",
          date: "23/04/2026",
          description: loc.temInteresting1Desc,
          fullExplanation: loc.temInteresting1Full,
          mapUrl: "https://maps.app.goo.gl/xjqwwyM7gmu7gq6P6"),
      ExplorationItem(
          image:
              "https://lh3.googleusercontent.com/gps-cs-s/APNQkAEl6xFKYymD5getUbxVlWxilCFPn7sy0W-Se_wQp_GJNfdWnuxSMDsUFdanX7DmKcgyjFWkBbsKdE1f8k4tit7nxeBPRY1ZVrLyfqFwpVXaNewg9io0c36D9vqUjQ1ZWZ9PyRk3=w270-h312-n-k-no",
          title: "Taman Rekreasi Tasik Chatin",
          date: "23/04/2026",
          description: loc.temInteresting2Desc,
          fullExplanation: loc.temInteresting2Full,
          mapUrl: "https://maps.app.goo.gl/eAKWhaE7ALQQmAvq8"),
      ExplorationItem(
          image:
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQWFHQZsDXgPF3OAwRNJw0DTzGYgFqqSrU50g&s",
          title: "Pusat Konservasi Gajah Kebangsaan",
          date: "23/04/2026",
          description: loc.temInteresting3Desc,
          fullExplanation: loc.temInteresting3Full,
          mapUrl: "https://maps.app.goo.gl/9UuaNai3GW3rgjyU9"),
      ExplorationItem(
          image:
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTjCXxcGzUivM8SJ0YtG0zr6mKzblgYIpL3Bw&s",
          title: "Deerland Park",
          date: "23/04/2026",
          description: loc.temInteresting4Desc,
          fullExplanation: loc.temInteresting4Full,
          mapUrl: "https://maps.app.goo.gl/muz17CYr7uyH9MdT7"),
      ExplorationItem(
          image:
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSCMBhn8tHerK-ptVeUTVEc9S8mUFTl7BJ7rg&s",
          title: "Taman Tema Air Kubang Gajah",
          date: "23/04/2026",
          description: loc.temInteresting5Desc,
          fullExplanation: loc.temInteresting5Full,
          mapUrl: "https://maps.app.goo.gl/BBYxMXBVXnxv74fV8"),
      ExplorationItem(
          image:
              "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/10/e1/74/23/gunung-senyum-recreational.jpg?w=9600&h=-1&s=1",
          title: "Gunung Senyum",
          date: "23/04/2026",
          description: loc.temInteresting6Desc,
          fullExplanation: loc.temInteresting6Full,
          mapUrl: "https://maps.app.goo.gl/w1jJ6254z6L4HdKLA"),
      ExplorationItem(
          image:
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRxrlVw30YSnthM4tP1_V8d3BCjonZ4u_OiUw&s",
          title: "Pusat Pemuliharaan Seladang",
          date: "23/04/2026",
          description: loc.temInteresting7Desc,
          fullExplanation: loc.temInteresting7Full,
          mapUrl: "https://maps.app.goo.gl/RUTYanQ4vCXRtKTE6"),
      ExplorationItem(
          image:
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQCucDDuThYxNjutm0Oc3NUhhHggQn5CsJ1zQ&s",
          title: "Kampungstay Desa Murni",
          date: "23/04/2026",
          description: loc.temInteresting8Desc,
          fullExplanation: loc.temInteresting8Full,
          mapUrl: "https://maps.app.goo.gl/23D5M3GWh8xdjFAe7"),
      ExplorationItem(
          image:
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR1NW73lvcaJfIBXE979UiN1F13N0nokInGNw&s",
          title: "Taman Rekreasi Wadi Al-Amin",
          date: "23/04/2026",
          description: loc.temInteresting9Desc,
          fullExplanation: loc.temInteresting9Full,
          mapUrl: "https://maps.app.goo.gl/T9hQuwqTv9RPdSDJ7"),
      ExplorationItem(
          image:
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSCVxW3xGhkqzwJuchzzdDHBFmld141Rg1z3A&s",
          title: "Air Terjun Lata Bujang",
          date: "23/04/2026",
          description: loc.temInteresting10Desc,
          fullExplanation: loc.temInteresting10Full,
          mapUrl: "https://maps.app.goo.gl/EFMfsnEqonzGVLYz5"),
      ExplorationItem(
          image:
              "https://www.mpt.gov.my/sites/default/files/styles/panopoly_image_original/public/3_359.jpg?itok=WtsuPppg",
          title: "Esplanade Temerloh",
          date: "23/04/2026",
          description: loc.temInteresting13Desc,
          fullExplanation: loc.temInteresting13Full,
          mapUrl: "https://maps.app.goo.gl/iwqtrK6v1Dz7ZYp87"),
    ];

    /// ================= FOOD =================
    final eatingPlaces = [
      ExplorationItem(
          image:
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRnBzUpkHxkgAuLjEYvU7PRwPelf86OfMP7yw&s",
          title: "Warung Acu",
          date: "23/04/2026",
          description: loc.temFood1Desc,
          fullExplanation: loc.temFood1Full,
          mapUrl: "https://maps.app.goo.gl/HG8S5niCV1zVFgjt7"),
      ExplorationItem(
          image:
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTRI55Dqy8L70ecRBZ93q3RPHW0zYloH3FbdA&s",
          title: "Go' Bang Maju Tol",
          date: "23/04/2026",
          description: loc.temFood2Desc,
          fullExplanation: loc.temFood2Full,
          mapUrl: "https://maps.app.goo.gl/75s9wy3hHXDqSjw49"),
      ExplorationItem(
          image:
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSDIa5AlgsNlqDBm1MJROf9z1ju2B-WlAPaDQ&s",
          title: "Angah Maju Selera Patin Tebing Sungai",
          date: "23/04/2026",
          description: loc.temFood3Desc,
          fullExplanation: loc.temFood3Full,
          mapUrl: "https://maps.app.goo.gl/2J2RJFvXat8f68Sg9"),
      ExplorationItem(
          image:
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS1Fvxofhcfbw4OqQcshGJrLZeKCJeB0Q-MyA&s",
          title: "Gerai Adik Hanizan",
          date: "23/04/2026",
          description: loc.temFood4Desc,
          fullExplanation: loc.temFood4Full,
          mapUrl: "https://maps.app.goo.gl/qMEYxSx7GXUVPa4a9"),
      ExplorationItem(
          image:
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTOwHZhH5kQvF9K4nJp4EOYushW9sqWZsfp0A&s",
          title: "KOI & AOK CAFE",
          date: "23/04/2026",
          description: loc.temFood5Desc,
          fullExplanation: loc.temFood5Full,
          mapUrl: "https://maps.app.goo.gl/hzFDNGBE8fYH1kJ89"),
      ExplorationItem(
          image:
              "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/25/84/dd/95/di-hadapan-restoran-tok.jpg?w=800&h=800&s=1",
          title: "Restoran Tok Gajah Temerloh",
          date: "23/04/2026",
          description: loc.temFood6Desc,
          fullExplanation: loc.temFood6Full,
          mapUrl: "https://maps.app.goo.gl/XUwu9RHdgHfiHjbMA"),
      ExplorationItem(
          image:
              "https://lh3.googleusercontent.com/gps-cs-s/APNQkAEAuUNGJ6FVPsUqjDneO4SW8zgF2wyZb8-5v6c0kH8T0z80eeemKFh4rkq9U4m08Mi-w8MTzAqfZaZQKH0mBkLfD3VgpZ4J_Pc6dT4aqVqRtM8qRWMPbWaPsaF8OxoFOvyHeDYNcA=w289-h312-n-k-no",
          title: "Mukmin Cafe",
          date: "23/04/2026",
          description: loc.temFood7Desc,
          fullExplanation: loc.temFood7Full,
          mapUrl: "https://maps.app.goo.gl/8UpFsWMEvhQh6b849"),
      ExplorationItem(
          image:
              "https://lh3.googleusercontent.com/gps-cs-s/APNQkAHC1ojAGBMo_ZL4dVQM8uSZZnVxxigLHwzOkyoHCuUFL4bbw3rElGG5xonG2JSu8-dRmZhvi6wZkAXMDMVqwzPvvuydu5srOlobo1FdUR7-rtP10omaTsVrRElESe8I3p2foyaWxM9x_3k=w289-h312-n-k-no",
          title: "Kedai Kesidang @ Kopi Bawah Tangga",
          date: "23/04/2026",
          description: loc.temFood8Desc,
          fullExplanation: loc.temFood8Full,
          mapUrl: "https://maps.app.goo.gl/LZRY4hR3mWPZordNA"),
      ExplorationItem(
          image:
              "https://lh3.googleusercontent.com/gps-cs-s/APNQkAEBl7kKMXUpEOzMFkLDy_3rmkPnVcPsMG8RWD55Jeu6UUS9sWy21fLhqHRRL7dheML91xP5ct52j4ONLSs2BwhB-oiZxaIyh1C3B49fmtFuK4YYNDoo6vRWfTnAo9Ts7s15F_4=w289-h312-n-k-no",
          title: "Selera Patin Bangau Temerloh",
          date: "23/04/2026",
          description: loc.temFood9Desc,
          fullExplanation: loc.temFood9Full,
          mapUrl: "https://maps.app.goo.gl/nWWsdn5T3bPDt9KA6"),
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
              Text(
                loc.temerlohExplorationTitle,
                style: const TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 3, 89, 210)),
              ),
              const SizedBox(height: 50),

              /// tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  children: [
                    Expanded(
                        child: _CategoryTab(
                            label: loc.tabBusiness,
                            selected: selectedTab == 0,
                            onTap: () => setState(() => selectedTab = 0))),
                    const SizedBox(width: 20),
                    Expanded(
                        child: _CategoryTab(
                            label: loc.tabInteresting,
                            selected: selectedTab == 1,
                            onTap: () => setState(() => selectedTab = 1))),
                    const SizedBox(width: 20),
                    Expanded(
                        child: _CategoryTab(
                            label: loc.tabEating,
                            selected: selectedTab == 2,
                            onTap: () => setState(() => selectedTab = 2))),
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