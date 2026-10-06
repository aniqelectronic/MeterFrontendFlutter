import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/tourist/ptourist3.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';
import 'package:qr_flutter/qr_flutter.dart';

// ============================================================================
// EXPLORATION ITEM
// ============================================================================
class ExplorationItem {
  final String image;
  final String title;
  final String date;
  final String description;
  final String fullExplanation;
  final String? mapUrl;

  const ExplorationItem({
    required this.image,
    required this.title,
    required this.date,
    required this.description,
    required this.fullExplanation,
    this.mapUrl,
  });
}

// ============================================================================
// MELAKA EXPLORATION PAGE - SAME DESIGN AS PUTRAJAYA
// ============================================================================
class PExplorationMelakaPage extends StatefulWidget {
  const PExplorationMelakaPage({super.key});

  @override
  State<PExplorationMelakaPage> createState() =>
      _PExplorationMelakaPageState();
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
    
    
    
    

    // ========================================================================
    // SELECT DATA
    // ========================================================================
    final List<ExplorationItem> data;

    switch (selectedTab) {
      case 0:
        data = historicalPlaces;
        break;

      case 1:
        data = interestingPlaces;
        break;

      case 2:
      default:
        data = eatingPlaces;
        break;
    }

    return Scaffold(
      body: Stack(
        children: [
          // ==================================================================
          // BACKGROUND
          // ==================================================================
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'lib/images/pnew.png',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // ==================================================================
          // DECORATIVE CIRCLES
          // ==================================================================
          Positioned(
            top: -100,
            right: -110,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(
                  0xFF64B5F6,
                ).withOpacity(0.10),
              ),
            ),
          ),

          Positioned(
            bottom: 240,
            left: -130,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(
                  0xFF42A5F5,
                ).withOpacity(0.08),
              ),
            ),
          ),

          // ==================================================================
          // MAIN CONTENT
          // ==================================================================
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  65,
                  45,
                  65,
                  330,
                ),
                child: Column(
                  children: [
                    // ========================================================
                    // HEADER
                    // ========================================================
                    Container(
                      width: double.infinity,
                      height: 135,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF0D47A1),
                            Color(0xFF1976D2),
                            Color(0xFF42A5F5),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF1976D2,
                            ).withOpacity(0.25),
                            blurRadius: 25,
                            offset:
                                const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            left: 0,
                            child: Container(
                              width: 82,
                              height: 82,
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withOpacity(0.16),
                                borderRadius:
                                    BorderRadius.circular(
                                  23,
                                ),
                              ),
                              child: const Icon(
                                Icons
                                    .travel_explore_rounded,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          ),

                          Positioned.fill(
                            left: 115,
                            right: 115,
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  loc.melakaExplorationTitle,
                                  textAlign:
                                      TextAlign.center,
                                  maxLines: 1,
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.white,
                                    fontSize: 52,
                                    fontWeight:
                                        FontWeight
                                            .w900,
                                    letterSpacing:
                                        0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    // ========================================================
                    // CATEGORY TABS
                    // ========================================================
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withOpacity(0.96),
                        borderRadius:
                            BorderRadius.circular(28),
                        border: Border.all(
                          color: const Color(
                            0xFFB8C8DA,
                          ),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(0.08),
                            blurRadius: 18,
                            offset:
                                const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _CategoryTab(
                              icon: Icons
                                  .account_balance_rounded,
                              label: loc.tabHistorical,
                              selected:
                                  selectedTab == 0,
                              onTap: () {
                                setState(() {
                                  selectedTab = 0;
                                });
                              },
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child: _CategoryTab(
                              icon: Icons
                                  .landscape_rounded,
                              label: loc.tabInteresting,
                              selected:
                                  selectedTab == 1,
                              onTap: () {
                                setState(() {
                                  selectedTab = 1;
                                });
                              },
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child: _CategoryTab(
                              icon:
                                  Icons.restaurant_rounded,
                              label:
                                  loc.tabEating,
                              selected:
                                  selectedTab == 2,
                              onTap: () {
                                setState(() {
                                  selectedTab = 2;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    // ========================================================
                    // CATEGORY TITLE + COUNT
                    // ========================================================
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF1976D2,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              10,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 15,
                        ),

                        Expanded(
                          child: Text(
                            _selectedCategoryTitle(
                              loc,
                            ),
                            style:
                                const TextStyle(
                              color: Color(
                                0xFF102A43,
                              ),
                              fontSize: 30,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                        ),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 17,
                            vertical: 9,
                          ),
                          decoration:
                              BoxDecoration(
                            color: const Color(
                              0xFFE3F2FD,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                          ),
                          child: Text(
                            '${data.length}',
                            style:
                                const TextStyle(
                              color: Color(
                                0xFF1976D2,
                              ),
                              fontSize: 21,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // ========================================================
                    // PLACES LIST
                    // ========================================================
                    Expanded(
                      child: data.isEmpty
                          ? _EmptyPlaceCard(
                              text: 'No places available',
                            )
                          : Scrollbar(
                              thumbVisibility:
                                  true,
                              thickness: 10,
                              radius:
                                  const Radius.circular(
                                10,
                              ),
                              child:
                                  ListView.separated(
                                padding:
                                    const EdgeInsets
                                        .only(
                                  right: 20,
                                  bottom: 20,
                                ),
                                itemCount:
                                    data.length,
                                separatorBuilder:
                                    (_, __) =>
                                        const SizedBox(
                                  height: 24,
                                ),
                                itemBuilder:
                                    (_, index) =>
                                        _ExplorationCard(
                                  item:
                                      data[index],
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ==================================================================
          // BACK BUTTON
          // ==================================================================
          Positioned(
            bottom: 150,
            left: 300,
            right: 300,
            child: KioskBackButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const PTOURISTPAGE(),
                  ),
                );
              },
            ),
          ),

          // ==================================================================
          // FOOTER
          // ==================================================================
          Positioned(
            bottom: 50,
            left: 30,
            right: 30,
            child: Center(
              child: Text(
                Data.copyrightText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SELECTED CATEGORY TITLE
  // ==========================================================================
  String _selectedCategoryTitle(AppLocalizations loc) {
    switch (selectedTab) {
      case 0:
        return loc.tabHistorical;
      case 1:
        return loc.tabInteresting;
      case 2:
        return loc.tabEating;
      default:
        return '';
    }
  }
}

// ============================================================================
// EXPLORATION CARD
// ============================================================================
class _ExplorationCard extends StatelessWidget {
  final ExplorationItem item;

  const _ExplorationCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final loc =
        AppLocalizations.of(context)!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(30),
        onTap: () {
          showGeneralDialog(
            context: context,
            barrierDismissible: true,
            barrierLabel:
                'Melaka exploration details',
            barrierColor:
                Colors.black.withOpacity(
              0.55,
            ),
            transitionDuration:
                const Duration(
              milliseconds: 280,
            ),
            pageBuilder:
                (_, __, ___) =>
                    _ExplorationDetailDialog(
              item: item,
            ),
            transitionBuilder:
                (
              _,
              animation,
              __,
              child,
            ) {
              final curvedAnimation =
                  CurvedAnimation(
                parent: animation,
                curve:
                    Curves.easeOutBack,
              );

              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale:
                      Tween<double>(
                    begin: 0.92,
                    end: 1,
                  ).animate(
                    curvedAnimation,
                  ),
                  child: child,
                ),
              );
            },
          );
        },
        child: Container(
          height: 270,
          decoration: BoxDecoration(
            color: Colors.white
                .withOpacity(0.97),
            borderRadius:
                BorderRadius.circular(30),
            border: Border.all(
              color: const Color(
                0xFFD4E1EF,
              ),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(0.09),
                blurRadius: 18,
                offset:
                    const Offset(0, 9),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(28),
            child: Row(
              children: [
                // ============================================================
                // IMAGE
                // ============================================================
                SizedBox(
                  width: 330,
                  height: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        item.image,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) {
                          return Container(
                            color:
                                const Color(
                              0xFFECEFF1,
                            ),
                            child:
                                const Center(
                              child: Icon(
                                Icons
                                    .image_not_supported_rounded,
                                size: 82,
                                color:
                                    Color(
                                  0xFF90A4AE,
                                ),
                              ),
                            ),
                          );
                        },
                        loadingBuilder:
                            (
                          context,
                          child,
                          loadingProgress,
                        ) {
                          if (loadingProgress ==
                              null) {
                            return child;
                          }

                          return Container(
                            color:
                                const Color(
                              0xFFE3F2FD,
                            ),
                            child:
                                const Center(
                              child:
                                  CircularProgressIndicator(
                                color:
                                    Color(
                                  0xFF1976D2,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const DecoratedBox(
                        decoration:
                            BoxDecoration(
                          gradient:
                              LinearGradient(
                            begin: Alignment
                                .bottomCenter,
                            end: Alignment
                                .topCenter,
                            colors: [
                              Color(
                                0x88000000,
                              ),
                              Colors
                                  .transparent,
                            ],
                          ),
                        ),
                      ),

                      Positioned(
                        left: 18,
                        bottom: 18,
                        child: Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                Colors.black
                                    .withOpacity(
                              0.58,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              15,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons
                                    .calendar_month_rounded,
                                color:
                                    Colors.white,
                                size: 20,
                              ),
                              const SizedBox(
                                width: 7,
                              ),
                              Text(
                                item.date,
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize:
                                      16,
                                  fontWeight:
                                      FontWeight
                                          .w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ============================================================
                // DETAILS
                // ============================================================
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets
                            .fromLTRB(
                      30,
                      24,
                      24,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                maxLines: 2,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  color:
                                      Color(
                                    0xFF102A43,
                                  ),
                                  fontSize:
                                      30,
                                  fontWeight:
                                      FontWeight
                                          .w900,
                                  height: 1.1,
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 16,
                            ),

                            Container(
                              width: 52,
                              height: 52,
                              decoration:
                                  BoxDecoration(
                                color:
                                    const Color(
                                  0xFFE3F2FD,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  16,
                                ),
                              ),
                              child:
                                  const Icon(
                                Icons
                                    .arrow_forward_rounded,
                                color:
                                    Color(
                                  0xFF1976D2,
                                ),
                                size: 31,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        Container(
                          width: 65,
                          height: 5,
                          decoration:
                              BoxDecoration(
                            gradient:
                                const LinearGradient(
                              colors: [
                                Color(
                                  0xFF1976D2,
                                ),
                                Color(
                                  0xFF64B5F6,
                                ),
                              ],
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              10,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        Expanded(
                          child: Text(
                            item.description,
                            maxLines: 4,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xFF52667A,
                              ),
                              fontSize:
                                  23,
                              fontWeight:
                                  FontWeight
                                      .w600,
                              height: 1.35,
                            ),
                          ),
                        ),

                        Row(
                          children: [
                            const Icon(
                              Icons
                                  .touch_app_rounded,
                              color:
                                  Color(
                                0xFF1976D2,
                              ),
                              size: 25,
                            ),

                            const SizedBox(
                              width: 9,
                            ),

                            Text(
                              loc
                                  .putrajayaViewDetails,
                              style:
                                  const TextStyle(
                                color:
                                    Color(
                                  0xFF1976D2,
                                ),
                                fontSize:
                                    19,
                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// DETAIL DIALOG
// ============================================================================
class _ExplorationDetailDialog
    extends StatelessWidget {
  final ExplorationItem item;

  const _ExplorationDetailDialog({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final loc =
        AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor:
          Colors.transparent,
      insetPadding:
          const EdgeInsets.symmetric(
        horizontal: 90,
        vertical: 75,
      ),
      child: Container(
        constraints:
            const BoxConstraints(
          maxWidth: 900,
          maxHeight: 1500,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(38),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(0.30),
              blurRadius: 35,
              offset:
                  const Offset(0, 18),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(38),
          child: Column(
            children: [
              // ==============================================================
              // IMAGE HEADER
              // ==============================================================
              SizedBox(
                height: 390,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      item.image,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) {
                        return Container(
                          color:
                              const Color(
                            0xFFECEFF1,
                          ),
                          child:
                              const Icon(
                            Icons
                                .image_not_supported_rounded,
                            size: 100,
                            color:
                                Color(
                              0xFF90A4AE,
                            ),
                          ),
                        );
                      },
                    ),

                    const DecoratedBox(
                      decoration:
                          BoxDecoration(
                        gradient:
                            LinearGradient(
                          begin: Alignment
                              .bottomCenter,
                          end: Alignment
                              .topCenter,
                          colors: [
                            Color(
                              0xCC000000,
                            ),
                            Colors
                                .transparent,
                          ],
                        ),
                      ),
                    ),

                    // CLOSE X
                    Positioned(
                      top: 22,
                      right: 22,
                      child: Material(
                        color: Colors.white
                            .withOpacity(
                          0.92,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          18,
                        ),
                        child: InkWell(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            18,
                          ),
                          onTap: () =>
                              Navigator.pop(
                            context,
                          ),
                          child:
                              const SizedBox(
                            width: 58,
                            height: 58,
                            child: Icon(
                              Icons
                                  .close_rounded,
                              color:
                                  Color(
                                0xFF102A43,
                              ),
                              size: 34,
                            ),
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      left: 35,
                      right: 35,
                      bottom: 28,
                      child: Text(
                        item.title,
                        textAlign:
                            TextAlign.left,
                        maxLines: 2,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontSize: 42,
                          fontWeight:
                              FontWeight
                                  .w900,
                          height: 1.1,
                          shadows: [
                            Shadow(
                              color: Colors
                                  .black45,
                              blurRadius:
                                  10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ==============================================================
              // DETAIL CONTENT
              // ==============================================================
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child:
                          SingleChildScrollView(
                        padding:
                            const EdgeInsets
                                .fromLTRB(
                          40,
                          34,
                          40,
                          25,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal:
                                        16,
                                    vertical:
                                        10,
                                  ),
                                  decoration:
                                      BoxDecoration(
                                    color:
                                        const Color(
                                      0xFFE3F2FD,
                                    ),
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      18,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons
                                            .calendar_month_rounded,
                                        color:
                                            Color(
                                          0xFF1976D2,
                                        ),
                                        size:
                                            23,
                                      ),
                                      const SizedBox(
                                        width:
                                            8,
                                      ),
                                      Text(
                                        item.date,
                                        style:
                                            const TextStyle(
                                          color:
                                              Color(
                                            0xFF1976D2,
                                          ),
                                          fontSize:
                                              19,
                                          fontWeight:
                                              FontWeight
                                                  .w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 28,
                            ),

                            Container(
                              width:
                                  double.infinity,
                              padding:
                                  const EdgeInsets
                                      .all(
                                28,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    const Color(
                                  0xFFF7FAFD,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  24,
                                ),
                                border:
                                    Border.all(
                                  color:
                                      const Color(
                                    0xFFD8E4F0,
                                  ),
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                item
                                    .fullExplanation,
                                textAlign:
                                    TextAlign.left,
                                style:
                                    const TextStyle(
                                  color:
                                      Color(
                                    0xFF34495E,
                                  ),
                                  fontSize:
                                      24,
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ========================================================
                    // MAP + CLOSE
                    // ========================================================
                    Container(
                      width:
                          double.infinity,
                      padding:
                          const EdgeInsets
                              .fromLTRB(
                        35,
                        24,
                        35,
                        30,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            Colors.white,
                        border:
                            const Border(
                          top:
                              BorderSide(
                            color:
                                Color(
                              0xFFD8E4F0,
                            ),
                            width: 2,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black
                                    .withOpacity(
                              0.08,
                            ),
                            blurRadius:
                                16,
                            offset:
                                const Offset(
                              0,
                              -5,
                            ),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize:
                            MainAxisSize
                                .min,
                        children: [
                          if (item.mapUrl !=
                              null)
                            Container(
                              width:
                                  double.infinity,
                              padding:
                                  const EdgeInsets
                                      .all(
                                22,
                              ),
                              decoration:
                                  BoxDecoration(
                                gradient:
                                    const LinearGradient(
                                  begin:
                                      Alignment
                                          .topLeft,
                                  end:
                                      Alignment
                                          .bottomRight,
                                  colors: [
                                    Color(
                                      0xFFF1F8FF,
                                    ),
                                    Color(
                                      0xFFE3F2FD,
                                    ),
                                  ],
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  24,
                                ),
                                border:
                                    Border.all(
                                  color:
                                      const Color(
                                    0xFF90CAF9,
                                  ),
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding:
                                        const EdgeInsets
                                            .all(
                                      10,
                                    ),
                                    decoration:
                                        BoxDecoration(
                                      color:
                                          Colors
                                              .white,
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        18,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Colors
                                                  .black
                                                  .withOpacity(
                                            0.08,
                                          ),
                                          blurRadius:
                                              12,
                                        ),
                                      ],
                                    ),
                                    child:
                                        QrImageView(
                                      data: item
                                          .mapUrl!,
                                      size: 145,
                                      backgroundColor:
                                          Colors
                                              .white,
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 24,
                                  ),

                                  Expanded(
                                    child:
                                        Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        const Icon(
                                          Icons
                                              .location_on_rounded,
                                          color:
                                              Color(
                                            0xFF1976D2,
                                          ),
                                          size:
                                              42,
                                        ),

                                        const SizedBox(
                                          height:
                                              8,
                                        ),

                                        Text(
                                          loc
                                              .putrajayaGoogleMap,
                                          style:
                                              const TextStyle(
                                            color:
                                                Color(
                                              0xFF102A43,
                                            ),
                                            fontSize:
                                                27,
                                            fontWeight:
                                                FontWeight
                                                    .w900,
                                          ),
                                        ),

                                        const SizedBox(
                                          height:
                                              5,
                                        ),

                                        Text(
                                          loc
                                              .putrajayaScanMap,
                                          style:
                                              const TextStyle(
                                            color:
                                                Color(
                                              0xFF52667A,
                                            ),
                                            fontSize:
                                                18,
                                            fontWeight:
                                                FontWeight
                                                    .w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (item.mapUrl !=
                              null)
                            const SizedBox(
                              height: 22,
                            ),

                          SizedBox(
                            width: 340,
                            height: 78,
                            child:
                                ElevatedButton
                                    .icon(
                              onPressed: () =>
                                  Navigator.pop(
                                context,
                              ),
                              icon:
                                  const Icon(
                                Icons
                                    .close_rounded,
                                size: 31,
                              ),
                              label: Text(
                                loc
                                    .putrajayaClose,
                                style:
                                    const TextStyle(
                                  fontSize:
                                      27,
                                  fontWeight:
                                      FontWeight
                                          .w900,
                                ),
                              ),
                              style:
                                  ElevatedButton
                                      .styleFrom(
                                backgroundColor:
                                    const Color(
                                  0xFFD32F2F,
                                ),
                                foregroundColor:
                                    Colors.white,
                                elevation: 0,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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

// ============================================================================
// CATEGORY TAB
// ============================================================================
class _CategoryTab
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 260,
          ),
          curve: Curves.easeOut,
          height: 92,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    begin:
                        Alignment.topLeft,
                    end: Alignment
                        .bottomRight,
                    colors: [
                      Color(
                        0xFF0D47A1,
                      ),
                      Color(
                        0xFF1976D2,
                      ),
                      Color(
                        0xFF42A5F5,
                      ),
                    ],
                  )
                : null,
            color: selected
                ? null
                : const Color(
                    0xFFF4F8FC,
                  ),
            borderRadius:
                BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? const Color(
                      0xFF0D47A1,
                    )
                  : const Color(
                      0xFFD6E3EF,
                    ),
              width: 2,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(
                        0xFF1976D2,
                      ).withOpacity(0.25),
                      blurRadius: 14,
                      offset:
                          const Offset(
                        0,
                        7,
                      ),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration:
                    BoxDecoration(
                  color: selected
                      ? Colors.white
                          .withOpacity(
                          0.18,
                        )
                      : const Color(
                          0xFFE3F2FD,
                        ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    14,
                  ),
                ),
                child: Icon(
                  icon,
                  color: selected
                      ? Colors.white
                      : const Color(
                          0xFF1976D2,
                        ),
                  size: 28,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Flexible(
                child: FittedBox(
                  fit:
                      BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : const Color(
                              0xFF1976D2,
                            ),
                      fontSize: 23,
                      fontWeight:
                          FontWeight.w900,
                    ),
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

// ============================================================================
// EMPTY CARD
// ============================================================================
class _EmptyPlaceCard
    extends StatelessWidget {
  final String text;

  const _EmptyPlaceCard({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 650,
        padding:
            const EdgeInsets.all(
          45,
        ),
        decoration:
            BoxDecoration(
          color: Colors.white
              .withOpacity(0.96),
          borderRadius:
              BorderRadius.circular(
            30,
          ),
          border: Border.all(
            color: const Color(
              0xFFD6E3EF,
            ),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(0.08),
              blurRadius: 18,
              offset:
                  const Offset(
                0,
                8,
              ),
            ),
          ],
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons
                  .travel_explore_rounded,
              size: 85,
              color: Color(
                0xFF90A4AE,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              text,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color: Color(
                  0xFF52667A,
                ),
                fontSize: 28,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}