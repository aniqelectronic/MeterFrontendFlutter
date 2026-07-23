import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/tourist/ptourist3.dart';
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
  const PExplorationBentongPage({
    super.key,
  });

  @override
  State<PExplorationBentongPage> createState() =>
      _PExplorationBentongPageState();
}

class _PExplorationBentongPageState
    extends State<PExplorationBentongPage> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

  final historicalPlaces = [
    ExplorationItem(
      image:
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQEdvh0RbFnBeFk9h6sc6HpuyXZohLtPywXfA&s",
      title: loc.jomKeBentongGallery,
      date: "23/7/2026",
      description: loc.jomKeBentongDesc,
      fullExplanation: loc.jomKeBentongFull,
      mapUrl: "https://maps.app.goo.gl/iu7CaoVpVvTarXtP8",
    ),

    // =========================================================
    // JAPANESE GARDEN
    // =========================================================

    ExplorationItem(
      image:
          "https://lh3.googleusercontent.com/grass-cs/ACvplmO-p6Zi4U9bNu7x7jM5Oa3lgKqWMoAES2RQGGxumpgn1pnrgCPOGcO39wcEui-eDgzpnPRJPNHopsf9d0k5ralb7_0ywpJsNZhA9F1OurH2XgESI_KuNtcH1d9YrrfPMZIYaNEn=w270-h312-n-k-no",
      title: loc.japaneseGardenTitle,
      date: "23/7/2026",
      description: loc.japaneseGardenDesc,
      fullExplanation: loc.japaneseGardenFull,
      mapUrl: "https://maps.app.goo.gl/Rq4qrQT9XYboNRgQ8",
    ),
  ];

    final interestingPlaces = [
      ExplorationItem(
        image:
            "https://dusuntua.com/images/listing_photos/312_saujanajandabaik.jpg",
        title: loc.jandaBaikTitle,
        date: "23/7/2026",
        description: loc.jandaBaikDesc,
        fullExplanation: loc.jandaBaikFull,
        mapUrl: "https://maps.app.goo.gl/bRsWPSdezwhgn94C7",
      ),

      // =========================================================
      // ADVENTURE PARK BY COLMAR TROPICALE
      // =========================================================

      ExplorationItem(
        image:
            "https://res.klook.com/image/upload/w_750,h_469,c_fill,q_85/w_80,x_15,y_15,g_south_west,l_Klook_water_br_trans_yhcmh3/activities/mxxf8jojqi8v514wktux.jpg",
        title: loc.adventureParkColmarTitle,
        date: "23/7/2026",
        description: loc.adventureParkColmarDesc,
        fullExplanation: loc.adventureParkColmarFull,
        mapUrl: "https://maps.app.goo.gl/hh7d59GdUKdB9mpd7",
      ),

      // =========================================================
      // BUKIT TINGGI HORSE TRAIL RIDES
      // =========================================================

      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ5GUzjQaD_m__rToatYKhRMM_gDKqsy9uwfMe68iKtxD2l7jHHHbvKdEE&s=10",
        title: loc.bukitTinggiHorseTrailTitle,
        date: "23/7/2026",
        description: loc.bukitTinggiHorseTrailDesc,
        fullExplanation: loc.bukitTinggiHorseTrailFull,
        mapUrl: "https://maps.app.goo.gl/YfwUCm9a3KdZY9so7",
      ),

      // =========================================================
      // RABBIT FARM BUKIT TINGGI
      // =========================================================

      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQH8OYiZZfMXBqa9eKnTmtTppDM1cE0oDDDUkGmF-3MxcvvH9AD5xtzIVI&s=10",
        title: loc.rabbitFarmBukitTinggiTitle,
        date: "23/7/2026",
        description: loc.rabbitFarmBukitTinggiDesc,
        fullExplanation: loc.rabbitFarmBukitTinggiFull,
        mapUrl: "https://maps.app.goo.gl/bg5DhaPYawX9HoqdA",
      ),

      // =========================================================
      // BILUT EXTREME PARK
      // =========================================================

      ExplorationItem(
        image:
            "https://lh3.googleusercontent.com/grass-cs/ACvplmNmkU_R-HFaQ0_IK8ptSd49juoOy8jtooar55fKdgJbdYaFw157ZVXk_81R8mtXpr5G400E5FQPd-2KUHjHzBnuE5Gy9UqTThUJfIhcEJrzi0NCsmGPge-Vk8GW0U6ahhS7DZFF=w270-h312-n-k-no",
        title: loc.bilutExtremeParkTitle,
        date: "23/7/2026",
        description: loc.bilutExtremeParkDesc,
        fullExplanation: loc.bilutExtremeParkFull,
        mapUrl: "https://maps.app.goo.gl/kXF8bnJKeFemdRhh9",
      ),

      // =========================================================
      // BILUT VALLEY BEE FARM
      // =========================================================

      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTFi3FzFCM5Z1mQl9ayBkGgn1wKPxBJKhkR5rhDyMDyVc60PyyZ6i0yHYY&s=10",
        title: loc.bilutValleyBeeFarmTitle,
        date: "23/7/2026",
        description: loc.bilutValleyBeeFarmDesc,
        fullExplanation: loc.bilutValleyBeeFarmFull,
        mapUrl: "https://maps.app.goo.gl/X9ZBp98e8ykjicn37",
      ),

      // =========================================================
      // SWAT PAINTBALL KG JANDA BAIK
      // =========================================================

      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS8hO_mdht40cr4nFdhxHGJUK4H6p1ACK--QjO9EvVvRgeLwPEsDt5VjNOQ&s=10",
        title: loc.swatPaintballJandaBaikTitle,
        date: "23/7/2026",
        description: loc.swatPaintballJandaBaikDesc,
        fullExplanation: loc.swatPaintballJandaBaikFull,
        mapUrl: "https://maps.app.goo.gl/rdS9uiaYPNXJNZvR9",
      ),
    ];

    final eatingPlaces = [
      ExplorationItem(
        image:
            "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEikZIUVUqNiy64ftMiTZLC2gzpuXa4XRJTnseA4qFC-mjT_k1sqiRHAke4rZjNeLabhyphenhyphen1V_jwSQpiaLswWnIRZwn_DAeBNa_DOvVtL3g88FDP_mo2_4mDF5qc29BxaQKr-I79dAkKwW9m0/s1600/20200223_102207.jpg",
        title: loc.lemangTokKiTitle,
        date: "23/7/2026",
        description: loc.lemangTokKiDesc,
        fullExplanation: loc.lemangTokKiFull,
        mapUrl: "https://maps.app.goo.gl/YboBicTtotyEPMwi6",
      ),

      // =========================================================
      // LEMANG TO'KI 2
      // =========================================================

      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTwyJjOvzX76-nwuz279zO66O4QrKW4cjmGNiE8WjtFyeEoOUury8RnVaIK&s=10",
        title: loc.lemangToki2Title,
        date: "23/7/2026",
        description: loc.lemangToki2Desc,
        fullExplanation: loc.lemangToki2Full,
        mapUrl: "https://maps.app.goo.gl/TgX3TGRfjBcE38d19",
      ),

      // =========================================================
      // RESTORAN UDANG GALAH LUBUK HANTU
      // =========================================================

      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcScALHO3pwAzkPYS7msN3o5lbyY-ScUu5LKgGOlA66PqeW4mDv7feb-0_g&s=10",
        title: loc.udangGalahLubukHantuTitle,
        date: "23/7/2026",
        description: loc.udangGalahLubukHantuDesc,
        fullExplanation: loc.udangGalahLubukHantuFull,
        mapUrl: "https://maps.app.goo.gl/buAhGSgYNwJbtBAo6",
      ),

      // =========================================================
      // RESTORAN CINTA RASA AIRENA (AAA) BENTONG
      // =========================================================

      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSNGY04LXpGh4gYxZju8I1sI0JYF2INn6IbJFFNShK6hoYR2OMSxjLl4Jc8&s=10",
        title: loc.cintaRasaAirenaTitle,
        date: "23/7/2026",
        description: loc.cintaRasaAirenaDesc,
        fullExplanation: loc.cintaRasaAirenaFull,
        mapUrl: "https://maps.app.goo.gl/3NZSEaxcqcMuQGYGA",
      ),

      // =========================================================
      // PINEYARD
      // =========================================================

      ExplorationItem(
        image:
            "https://lh3.googleusercontent.com/gps-cs-s/AHRPTWn1gb-XtTq1P-vBTAlYk4cbuLkp-vysoWjR5bvPZB83mlWzugaY53WfuBV-3y01AKP4-l2IbuKARLm_LsFhbTtXc63LwziE2sch-Mc_nwOajDuHK1pw__ib-9-z3LIKL0YThm8OOvp9v8C8=s1360-w1360-h1020-rw",
        title: loc.pineyardTitle,
        date: "23/7/2026",
        description: loc.pineyardDesc,
        fullExplanation: loc.pineyardFull,
        mapUrl: "https://maps.app.goo.gl/ohk4XYniJVvEwAw9A",
      ),
    ];

    final List<ExplorationItem> data =
        selectedTab == 0
            ? historicalPlaces
            : selectedTab == 1
                ? interestingPlaces
                : eatingPlaces;

    return Scaffold(
      body: Stack(
        children: [
          // ===================================================
          // BACKGROUND
          // ===================================================

          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    "lib/images/pnew.png",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Soft decorative background circles.
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

          // ===================================================
          // MAIN CONTENT
          // ===================================================

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
                    // ===========================================
                    // MODERN HEADER
                    // ===========================================

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
                                  loc.bentongExplorationTitle,
                                  textAlign:
                                      TextAlign.center,
                                  maxLines: 1,
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.white,
                                    fontSize: 52,
                                    fontWeight:
                                        FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ===========================================
                    // CATEGORY CARD
                    // ===========================================

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color:
                            Colors.white.withOpacity(
                          0.96,
                        ),
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
                            color:
                                Colors.black.withOpacity(
                              0.08,
                            ),
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
                              label:
                                  loc.tabHistorical,
                              selected:
                                  selectedTab == 0,
                              onTap: () {
                                setState(() {
                                  selectedTab = 0;
                                });
                              },
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: _CategoryTab(
                              icon: Icons
                                  .landscape_rounded,
                              label:
                                  loc.tabInteresting,
                              selected:
                                  selectedTab == 1,
                              onTap: () {
                                setState(() {
                                  selectedTab = 1;
                                });
                              },
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: _CategoryTab(
                              icon: Icons
                                  .restaurant_rounded,
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

                    const SizedBox(height: 30),

                    // ===========================================
                    // SECTION LABEL
                    // ===========================================

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
                                BorderRadius.circular(10),
                          ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: Text(
                            _selectedCategoryTitle(
                              loc,
                            ),
                            style: const TextStyle(
                              color:
                                  Color(0xFF102A43),
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
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFE3F2FD,
                            ),
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${data.length}",
                            style: const TextStyle(
                              color:
                                  Color(0xFF1976D2),
                              fontSize: 21,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ===========================================
                    // EXPLORATION LIST
                    // ===========================================

                    Expanded(
                      child: data.isEmpty
                          ? const _EmptyPlaceCard()
                          : Scrollbar(
                              thumbVisibility: true,
                              thickness: 10,
                              radius:
                                  const Radius.circular(
                                10,
                              ),
                              child:
                                  ListView.separated(
                                padding:
                                    const EdgeInsets.only(
                                  right: 20,
                                  bottom: 20,
                                ),
                                itemCount: data.length,
                                separatorBuilder:
                                    (_, __) =>
                                        const SizedBox(
                                  height: 24,
                                ),
                                itemBuilder:
                                    (context, index) {
                                  return _ExplorationCard(
                                    item: data[index],
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ===================================================
          // BACK BUTTON
          // MAINTAINED
          // ===================================================

          Positioned(
            bottom: 150,
            left: 300,
            right: 300,
            child: KioskBackButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const PTOURISTPAGE(),
                  ),
                );
              },
            ),
          ),

          // ===================================================
          // FOOTER
          // ===================================================

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
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _selectedCategoryTitle(
    AppLocalizations loc,
  ) {
    switch (selectedTab) {
      case 0:
        return loc.tabHistorical;

      case 1:
        return loc.tabInteresting;

      case 2:
        return loc.tabEating;

      default:
        return "";
    }
  }
}

// ===========================================================
// EXPLORATION CARD
// ===========================================================

class _ExplorationCard extends StatelessWidget {
  final ExplorationItem item;

  const _ExplorationCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () {
          showGeneralDialog(
            context: context,
            barrierDismissible: true,
            barrierLabel: "",
            barrierColor:
                Colors.black.withOpacity(0.55),
            transitionDuration:
                const Duration(milliseconds: 280),
            pageBuilder: (_, __, ___) {
              return _ExplorationDetailDialog(
                item: item,
              );
            },
            transitionBuilder:
                (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              final curvedAnimation =
                  CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              );

              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(
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
            color:
                Colors.white.withOpacity(0.97),
            borderRadius:
                BorderRadius.circular(30),
            border: Border.all(
              color:
                  const Color(0xFFD4E1EF),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(
                  0.09,
                ),
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
                // ===============================================
                // IMAGE
                // ===============================================

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
                        decoration: BoxDecoration(
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
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),

                      Positioned(
                        left: 18,
                        bottom: 18,
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                Colors.black.withOpacity(
                              0.58,
                            ),
                            borderRadius:
                                BorderRadius.circular(
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
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ===============================================
                // CONTENT
                // ===============================================

                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      30,
                      24,
                      24,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                maxLines: 2,
                                overflow:
                                    TextOverflow.ellipsis,
                                style:
                                    const TextStyle(
                                  color:
                                      Color(
                                    0xFF102A43,
                                  ),
                                  fontSize: 30,
                                  fontWeight:
                                      FontWeight.w900,
                                  height: 1.1,
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

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
                                    BorderRadius.circular(
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

                        const SizedBox(height: 18),

                        Container(
                          width: 65,
                          height: 5,
                          decoration: BoxDecoration(
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
                                BorderRadius.circular(
                              10,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Expanded(
                          child: Text(
                            item.description,
                            maxLines: 4,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              color:
                                  Color(0xFF52667A),
                              fontSize: 23,
                              fontWeight:
                                  FontWeight.w600,
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

                            const SizedBox(width: 9),

                            Text(
                              AppLocalizations.of(
                                context,
                              )!
                                  .viewDetails,
                              style:
                                  const TextStyle(
                                color:
                                    Color(
                                  0xFF1976D2,
                                ),
                                fontSize: 19,
                                fontWeight:
                                    FontWeight.w800,
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

// ===========================================================
// DETAIL DIALOG
// ===========================================================

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
      backgroundColor: Colors.transparent,
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
              color:
                  Colors.black.withOpacity(
                0.30,
              ),
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
              // ===============================================
              // DIALOG IMAGE
              // ===============================================

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
                      decoration: BoxDecoration(
                        gradient:
                            LinearGradient(
                          begin:
                              Alignment.bottomCenter,
                          end:
                              Alignment.topCenter,
                          colors: [
                            Color(
                              0xCC000000,
                            ),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    Positioned(
                      top: 22,
                      right: 22,
                      child: Material(
                        color: Colors.white
                            .withOpacity(0.92),
                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(
                            18,
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const SizedBox(
                            width: 58,
                            height: 58,
                            child: Icon(
                              Icons.close_rounded,
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
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight:
                              FontWeight.w900,
                          height: 1.1,
                          shadows: [
                            Shadow(
                              color:
                                  Colors.black45,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ===============================================
              // DIALOG CONTENT
              // ===============================================

Expanded(
  child: Column(
    children: [
      // ===============================================
      // SCROLLABLE DESCRIPTION
      // ===============================================

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              color: Color(0xFF1976D2),
                              size: 23,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item.date,
                              style: const TextStyle(
                                color: Color(0xFF1976D2),
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FAFD),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFD8E4F0),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      item.fullExplanation,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: Color(0xFF34495E),
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===============================================
          // FIXED BOTTOM QR + CLOSE AREA
          // ===============================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              35,
              24,
              35,
              30,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: const Color(0xFFD8E4F0),
                  width: 2,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.mapUrl != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFF1F8FF),
                          Color(0xFFE3F2FD),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF90CAF9),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: QrImageView(
                            data: item.mapUrl!,
                            size: 145,
                            backgroundColor: Colors.white,
                          ),
                        ),

                        const SizedBox(width: 24),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: Color(0xFF1976D2),
                                size: 42,
                              ),

                              const SizedBox(height: 8),

                              Text(
                                loc.scanGoogleMaps,
                                style: const TextStyle(
                                  color: Color(0xFF102A43),
                                  fontSize: 27,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                loc.scanGoogleMapsInstruction,
                                style: const TextStyle(
                                  color: Color(0xFF52667A),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                if (item.mapUrl != null)
                  const SizedBox(height: 22),

                SizedBox(
                  width: 340,
                  height: 78,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 31,
                    ),
                    label: Text(
                      loc.closetext,
                      style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
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

// ===========================================================
// CATEGORY TAB
// ===========================================================

class _CategoryTab extends StatelessWidget {
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
              const Duration(milliseconds: 260),
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
                    end:
                        Alignment.bottomRight,
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
                      color:
                          const Color(
                        0xFF1976D2,
                      ).withOpacity(0.25),
                      blurRadius: 14,
                      offset:
                          const Offset(0, 7),
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
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white
                          .withOpacity(0.18)
                      : const Color(
                          0xFFE3F2FD,
                        ),
                  borderRadius:
                      BorderRadius.circular(
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

              const SizedBox(width: 12),

              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
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

// ===========================================================
// EMPTY STATE
// ===========================================================

class _EmptyPlaceCard
    extends StatelessWidget {
  const _EmptyPlaceCard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 650,
        padding:
            const EdgeInsets.all(45),
        decoration: BoxDecoration(
          color:
              Colors.white.withOpacity(0.96),
          borderRadius:
              BorderRadius.circular(30),
          border: Border.all(
            color:
                const Color(0xFFD6E3EF),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(
                0.08,
              ),
              blurRadius: 18,
              offset:
                  const Offset(0, 8),
            ),
          ],
        ),
        child: const Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              Icons
                  .travel_explore_rounded,
              size: 85,
              color:
                  Color(0xFF90A4AE),
            ),
            SizedBox(height: 20),
            Text(
              "No places available",
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    Color(0xFF52667A),
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