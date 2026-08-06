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

  const ExplorationItem({
    required this.image,
    required this.title,
    required this.date,
    required this.description,
    required this.fullExplanation,
    this.mapUrl,
  });
}

class PExplorationIpohPage extends StatefulWidget {
  const PExplorationIpohPage({super.key});

  @override
  State<PExplorationIpohPage> createState() =>
      _PExplorationIpohPageState();
}

class _PExplorationIpohPageState extends State<PExplorationIpohPage> {
  int selectedTab = 0;

  static const String _updatedDate = '06/08/2026';

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final historicalPlaces = <ExplorationItem>[
      ExplorationItem(
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTPn7wAzr6ypuJmgTDftEhMzccwBiCBCqyJ0xhpW32YhA&s=10',
        title: loc.birchMemorialClockTowerTitle,
        date: _updatedDate,
        description: loc.birchMemorialClockTowerDesc,
        fullExplanation: loc.birchMemorialClockTowerFull,
        mapUrl: 'https://maps.app.goo.gl/hXf7sy6QqVxw3M6o7',
      ),
      ExplorationItem(
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRonQUofqZJlI79NpxlivNckC5i4wBTXl5iNOFQEoJiCQ&s=10',
        title: loc.masjidMuhammadiahIpohTitle,
        date: _updatedDate,
        description: loc.masjidMuhammadiahIpohDesc,
        fullExplanation: loc.masjidMuhammadiahIpohFull,
        mapUrl: 'https://maps.app.goo.gl/GizWDwX9A2VnA5Vd7',
      ),
      ExplorationItem(
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRzwM-qxkDbqcIBGE8e3MAE1uOUBys_RZqEAad-9XzTSw&s=10',
        title: loc.muziumDarulRidzuanTitle,
        date: _updatedDate,
        description: loc.muziumDarulRidzuanDesc,
        fullExplanation: loc.muziumDarulRidzuanFull,
        mapUrl: 'https://maps.app.goo.gl/P33rL8BUqxgWhRfe6',
      ),
      ExplorationItem(
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSahwWoRQPZO1_sMcG43dMVP9LDsbBYU5L6qdG0_LK27g&s=10',
        title: loc.muziumGeologiIpohTitle,
        date: _updatedDate,
        description: loc.muziumGeologiIpohDesc,
        fullExplanation: loc.muziumGeologiIpohFull,
        mapUrl: 'https://maps.app.goo.gl/Bp8Dt1Gejho8g4wq5',
      ),
    ];

    final interestingPlaces = <ExplorationItem>[
      ExplorationItem(
        image:
            'https://www.holidaygogogo.com/wp-content/uploads/2016/08/Lost-World-of-Tambun.jpeg',
        title: loc.lostWorldTambunTitle,
        date: _updatedDate,
        description: loc.lostWorldTambunDesc,
        fullExplanation: loc.lostWorldTambunFull,
        mapUrl: 'https://maps.app.goo.gl/JvMthz6WcnNJMGx47',
      ),
      ExplorationItem(
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTJwWazZoxeOh7H7MiSQgLjY0QbaD667uRTlbxVf6KmXA&s=10',
        title: loc.bookXcessIpohTitle,
        date: _updatedDate,
        description: loc.bookXcessIpohDesc,
        fullExplanation: loc.bookXcessIpohFull,
        mapUrl: 'https://maps.app.goo.gl/WvGjpMMhS4pWAeN38',
      ),
      ExplorationItem(
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTN_CWAu9sTnQJ0krWlddxq6j-Ng7kDccFyANekHFq-Ag&s=10',
        title: loc.kongHengSquareTitle,
        date: _updatedDate,
        description: loc.kongHengSquareDesc,
        fullExplanation: loc.kongHengSquareFull,
        mapUrl: 'https://maps.app.goo.gl/UusRNriDzJChCZs39',
      ),
      ExplorationItem(
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTXGgHOI627sn25C177uVRZHXf2LEnnJPpsiq3449OmwQ&s=10',
        title: loc.banjaranHotspringsTitle,
        date: _updatedDate,
        description: loc.banjaranHotspringsDesc,
        fullExplanation: loc.banjaranHotspringsFull,
        mapUrl: 'https://maps.app.goo.gl/JXjgbw6mB8ancUGW8',
      ),
      ExplorationItem(
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrsPWCX7YLeOsPQpd6tQ_nhfJLDg7yA714p4w605yKPg&s=10',
        title: loc.gopengRaftingTitle,
        date: _updatedDate,
        description: loc.gopengRaftingDesc,
        fullExplanation: loc.gopengRaftingFull,
        mapUrl: 'https://maps.app.goo.gl/tHN6LPmhovEweMua6',
      ),
      ExplorationItem(
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRTucQPg29rwK9w5Rd5xTbxuQuXulay2DVzksgSAwwtvg&s=10',
        title: loc.timeTunnelIpohTitle,
        date: _updatedDate,
        description: loc.timeTunnelIpohDesc,
        fullExplanation: loc.timeTunnelIpohFull,
        mapUrl: 'https://maps.app.goo.gl/B563bRXJbtWdRrev9',
      ),
      ExplorationItem(
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR5vF8Mpz3psEkiGQFZsISlqDplVqMnq24PGxHujUvMEg&s=10',
        title: loc.upsideDownWorldIpohTitle,
        date: _updatedDate,
        description: loc.upsideDownWorldIpohDesc,
        fullExplanation: loc.upsideDownWorldIpohFull,
        mapUrl: 'https://maps.app.goo.gl/sL9wDARWhAVgz1uM7',
      ),
      ExplorationItem(
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTCSoqk1Iz6LD8KWPK9S8f6FFrXiAiAT3t9BaHMWzb61A&s=10',
        title: loc.kekLokTongTitle,
        date: _updatedDate,
        description: loc.kekLokTongDesc,
        fullExplanation: loc.kekLokTongFull,
        mapUrl: 'https://maps.app.goo.gl/ddC4iDkQKsqknh8i7',
      ),
      ExplorationItem(
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQbi7Tsk0_-zb1d8N7C-yDKdEu-W-_FZOWVT3LEfxLYLA&s=10',
        title: loc.gunungLangTitle,
        date: _updatedDate,
        description: loc.gunungLangDesc,
        fullExplanation: loc.gunungLangFull,
        mapUrl: 'https://maps.app.goo.gl/iFRmwuMdYsEPGUhk7',
      ),
      ExplorationItem(
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcREX4gwlXXDynh-8KM-CZX06SftNJhRC3apXwUMQ6gfCg&s=10',
        title: loc.funtasyHouseTitle,
        date: _updatedDate,
        description: loc.funtasyHouseDesc,
        fullExplanation: loc.funtasyHouseFull,
        mapUrl: 'https://maps.app.goo.gl/kEJRkjuBVCeWqoS9A',
      ),
      ExplorationItem(
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTSAGxPkS93MgOtdNdQvNDf4nBRqbk-jnQnsYBd9f00yQ&s=10',
        title: loc.lubukTimahTitle,
        date: _updatedDate,
        description: loc.lubukTimahDesc,
        fullExplanation: loc.lubukTimahFull,
        mapUrl: 'https://maps.app.goo.gl/cm7HA68uC6E1dgj56',
      ),
      ExplorationItem(
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ4fzup2GPlNhwJ635uOi4OMbslbcaiw7NM1Mxbs95rBncgg_cveNMtk74E&s=10',
        title: loc.xParkSunwayTitle,
        date: _updatedDate,
        description: loc.xParkSunwayDesc,
        fullExplanation: loc.xParkSunwayFull,
        mapUrl: 'https://maps.app.goo.gl/KLYyjkPEe9Zk15Xr5',
      ),
      ExplorationItem(
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTMdl12XOpl_kNmyjOWQMl-nCg78HZlDzN30OgsxWGa6A&s=10',
        title: loc.tasikCerminTitle,
        date: _updatedDate,
        description: loc.tasikCerminDesc,
        fullExplanation: loc.tasikCerminFull,
        mapUrl: 'https://maps.app.goo.gl/dgXkScczycAKGx32A',
      ),
    ];

    final eatingPlaces = <ExplorationItem>[
      ExplorationItem(
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT_tj_FS5yr-OM8iABPmMt6b17UvBChRwVzGS7M0DzKkA&s=10',
        title: loc.meeRebusRamliTitle,
        date: _updatedDate,
        description: loc.meeRebusRamliDesc,
        fullExplanation: loc.meeRebusRamliFull,
        mapUrl: 'https://maps.app.goo.gl/zD9b5SdmPWBFAvEz8',
      ),
      ExplorationItem(
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRb4Da2M8WIC3XZ0m-D2IQpNgYWekcSyyeA2Mx5tQ2DKQ&s=10',
        title: loc.redBrickKitchenTitle,
        date: _updatedDate,
        description: loc.redBrickKitchenDesc,
        fullExplanation: loc.redBrickKitchenFull,
        mapUrl: 'https://maps.app.goo.gl/eckJZUbg8XTSJaJ86',
      ),
    ];

    final List<ExplorationItem> data;
    switch (selectedTab) {
      case 0:
        data = historicalPlaces;
        break;
      case 1:
        data = interestingPlaces;
        break;
      default:
        data = eatingPlaces;
    }

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/images/pnew.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -110,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF64B5F6).withOpacity(0.10),
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
                color: const Color(0xFF42A5F5).withOpacity(0.08),
              ),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(65, 45, 65, 330),
                child: Column(
                  children: [
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
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1976D2).withOpacity(0.25),
                            blurRadius: 25,
                            offset: const Offset(0, 12),
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
                                color: Colors.white.withOpacity(0.16),
                                borderRadius: BorderRadius.circular(23),
                              ),
                              child: const Icon(
                                Icons.travel_explore_rounded,
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
                                  loc.ipohExplorationTitle,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 52,
                                    fontWeight: FontWeight.w900,
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.96),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: const Color(0xFFB8C8DA),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _CategoryTab(
                              icon: Icons.account_balance_rounded,
                              label: loc.ipohTabHistorical,
                              selected: selectedTab == 0,
                              onTap: () => setState(() => selectedTab = 0),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _CategoryTab(
                              icon: Icons.landscape_rounded,
                              label: loc.ipohTabInteresting,
                              selected: selectedTab == 1,
                              onTap: () => setState(() => selectedTab = 1),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _CategoryTab(
                              icon: Icons.restaurant_rounded,
                              label: loc.ipohTabEating,
                              selected: selectedTab == 2,
                              onTap: () => setState(() => selectedTab = 2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1976D2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            _selectedCategoryTitle(loc),
                            style: const TextStyle(
                              color: Color(0xFF102A43),
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 17,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${data.length}',
                            style: const TextStyle(
                              color: Color(0xFF1976D2),
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: data.isEmpty
                          ? const _EmptyPlaceCard()
                          : Scrollbar(
                              thumbVisibility: true,
                              thickness: 10,
                              radius: const Radius.circular(10),
                              child: ListView.separated(
                                padding: const EdgeInsets.only(
                                  right: 20,
                                  bottom: 20,
                                ),
                                itemCount: data.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 24),
                                itemBuilder: (_, index) =>
                                    _ExplorationCard(item: data[index]),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            left: 300,
            right: 300,
            child: KioskBackButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PTOURISTPAGE(),
                  ),
                );
              },
            ),
          ),
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

  String _selectedCategoryTitle(AppLocalizations loc) {
    switch (selectedTab) {
      case 0:
        return loc.ipohTabHistorical;
      case 1:
        return loc.ipohTabInteresting;
      case 2:
        return loc.ipohTabEating;
      default:
        return '';
    }
  }
}

class _ExplorationCard extends StatelessWidget {
  final ExplorationItem item;

  const _ExplorationCard({required this.item});

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
            barrierLabel: 'Ipoh exploration details',
            barrierColor: Colors.black.withOpacity(0.55),
            transitionDuration: const Duration(milliseconds: 280),
            pageBuilder: (_, __, ___) =>
                _ExplorationDetailDialog(item: item),
            transitionBuilder: (_, animation, __, child) {
              final curvedAnimation = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              );

              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.92, end: 1).animate(
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
            color: Colors.white.withOpacity(0.97),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0xFFD4E1EF),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.09),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Row(
              children: [
                SizedBox(
                  width: 330,
                  height: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        item.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            color: const Color(0xFFECEFF1),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported_rounded,
                                size: 82,
                                color: Color(0xFF90A4AE),
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: const Color(0xFFE3F2FD),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF1976D2),
                              ),
                            ),
                          );
                        },
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Color(0x88000000),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 18,
                        bottom: 18,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.58),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_month_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                item.date,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30, 24, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF102A43),
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                color: Color(0xFF1976D2),
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
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF1976D2),
                                Color(0xFF64B5F6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Expanded(
                          child: Text(
                            item.description,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF52667A),
                              fontSize: 23,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.touch_app_rounded,
                              color: Color(0xFF1976D2),
                              size: 25,
                            ),
                            const SizedBox(width: 9),
                            Text(
                              AppLocalizations.of(context)!.viewDetails,
                              style: const TextStyle(
                                color: Color(0xFF1976D2),
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
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

class _ExplorationDetailDialog extends StatelessWidget {
  final ExplorationItem item;

  const _ExplorationDetailDialog({required this.item});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 90, vertical: 75),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 900,
          maxHeight: 1500,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(38),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.30),
              blurRadius: 35,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(38),
          child: Column(
            children: [
              SizedBox(
                height: 390,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      item.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          color: const Color(0xFFECEFF1),
                          child: const Icon(
                            Icons.image_not_supported_rounded,
                            size: 100,
                            color: Color(0xFF90A4AE),
                          ),
                        );
                      },
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Color(0xCC000000),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 22,
                      right: 22,
                      child: Material(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => Navigator.pop(context),
                          child: const SizedBox(
                            width: 58,
                            height: 58,
                            child: Icon(
                              Icons.close_rounded,
                              color: Color(0xFF102A43),
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
                        textAlign: TextAlign.left,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(40, 34, 40, 25),
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(35, 24, 35, 30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: const Border(
                          top: BorderSide(
                            color: Color(0xFFD8E4F0),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.location_on_rounded,
                                          color: Color(0xFF1976D2),
                                          size: 42,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          loc.ipohGoogleMap,
                                          style: const TextStyle(
                                            color: Color(0xFF102A43),
                                            fontSize: 27,
                                            fontWeight: FontWeight.w900,
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
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 31,
                              ),
                              label: Text(
                                loc.ipohClose,
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
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          height: 92,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0D47A1),
                      Color(0xFF1976D2),
                      Color(0xFF42A5F5),
                    ],
                  )
                : null,
            color: selected ? null : const Color(0xFFF4F8FC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? const Color(0xFF0D47A1)
                  : const Color(0xFFD6E3EF),
              width: 2,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF1976D2).withOpacity(0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 7),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withOpacity(0.18)
                      : const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: selected ? Colors.white : const Color(0xFF1976D2),
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
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          selected ? Colors.white : const Color(0xFF1976D2),
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
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

class _EmptyPlaceCard extends StatelessWidget {
  const _EmptyPlaceCard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 650,
        padding: const EdgeInsets.all(45),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: const Color(0xFFD6E3EF),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.travel_explore_rounded,
              size: 85,
              color: Color(0xFF90A4AE),
            ),
            SizedBox(height: 20),
            Text(
              'No places available',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF52667A),
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
