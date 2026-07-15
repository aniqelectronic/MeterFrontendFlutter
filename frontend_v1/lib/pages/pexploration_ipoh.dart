import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/ptourist3.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ExplorationItem {
  final String image;
  final String title;
  final String description;
  final String fullExplanation;
  final String? mapUrl;

  const ExplorationItem({
    required this.image,
    required this.title,
    required this.description,
    required this.fullExplanation,
    this.mapUrl,
  });
}

class PExplorationIpohPage extends StatefulWidget {
  const PExplorationIpohPage({super.key});

  @override
  State<PExplorationIpohPage> createState() => _PExplorationIpohPageState();
}

class _PExplorationIpohPageState extends State<PExplorationIpohPage> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final historicalPlaces = <ExplorationItem>[
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTPn7wAzr6ypuJmgTDftEhMzccwBiCBCqyJ0xhpW32YhA&s=10",
        title: loc.birchMemorialClockTowerTitle,
        description: loc.birchMemorialClockTowerDesc,
        fullExplanation: loc.birchMemorialClockTowerFull,
        mapUrl: "https://maps.app.goo.gl/a5KjzeWrLyTJ1k4v5",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRonQUofqZJlI79NpxlivNckC5i4wBTXl5iNOFQEoJiCQ&s=10",
        title: loc.masjidMuhammadiahIpohTitle,
        description: loc.masjidMuhammadiahIpohDesc,
        fullExplanation: loc.masjidMuhammadiahIpohFull,
        mapUrl: "https://maps.app.goo.gl/UuSbCoEfuJcE1D1K6",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRzwM-qxkDbqcIBGE8e3MAE1uOUBys_RZqEAad-9XzTSw&s=10",
        title: loc.muziumDarulRidzuanTitle,
        description: loc.muziumDarulRidzuanDesc,
        fullExplanation: loc.muziumDarulRidzuanFull,
        mapUrl: "https://maps.app.goo.gl/oCLCafDm7pZknqqH6",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSahwWoRQPZO1_sMcG43dMVP9LDsbBYU5L6qdG0_LK27g&s=10",
        title: loc.muziumGeologiIpohTitle,
        description: loc.muziumGeologiIpohDesc,
        fullExplanation: loc.muziumGeologiIpohFull,
        mapUrl: "https://maps.app.goo.gl/3jFNgYNsVV2bpy6y9",
      ),
    ];

    final interestingPlaces = <ExplorationItem>[
      ExplorationItem(
        image: "https://www.holidaygogogo.com/wp-content/uploads/2016/08/Lost-World-of-Tambun.jpeg",
        title: loc.lostWorldTambunTitle,
        description: loc.lostWorldTambunDesc,
        fullExplanation: loc.lostWorldTambunFull,
        mapUrl: "https://maps.app.goo.gl/mvF7LgvHmjkE2G3V7",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTJwWazZoxeOh7H7MiSQgLjY0QbaD667uRTlbxVf6KmXA&s=10",
        title: loc.bookXcessIpohTitle,
        description: loc.bookXcessIpohDesc,
        fullExplanation: loc.bookXcessIpohFull,
        mapUrl: "https://maps.app.goo.gl/smSrhfzYRsJPUgUL9",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTN_CWAu9sTnQJ0krWlddxq6j-Ng7kDccFyANekHFq-Ag&s=10",
        title: loc.kongHengSquareTitle,
        description: loc.kongHengSquareDesc,
        fullExplanation: loc.kongHengSquareFull,
        mapUrl: "https://maps.app.goo.gl/Y5QfWY34981GRMLJA",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTXGgHOI627sn25C177uVRZHXf2LEnnJPpsiq3449OmwQ&s=10",
        title: loc.banjaranHotspringsTitle,
        description: loc.banjaranHotspringsDesc,
        fullExplanation: loc.banjaranHotspringsFull,
        mapUrl: "https://maps.app.goo.gl/P6Wfy7uZVcd4nwuC6",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrsPWCX7YLeOsPQpd6tQ_nhfJLDg7yA714p4w605yKPg&s=10",
        title: loc.gopengRaftingTitle,
        description: loc.gopengRaftingDesc,
        fullExplanation: loc.gopengRaftingFull,
        mapUrl: "https://maps.app.goo.gl/WbGfN69diu3J6m2p8",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRTucQPg29rwK9w5Rd5xTbxuQuXulay2DVzksgSAwwtvg&s=10",
        title: loc.timeTunnelIpohTitle,
        description: loc.timeTunnelIpohDesc,
        fullExplanation: loc.timeTunnelIpohFull,
        mapUrl: "https://maps.app.goo.gl/yQPr5Kz28BAiZgcZ8",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR5vF8Mpz3psEkiGQFZsISlqDplVqMnq24PGxHujUvMEg&s=10",
        title: loc.upsideDownWorldIpohTitle,
        description: loc.upsideDownWorldIpohDesc,
        fullExplanation: loc.upsideDownWorldIpohFull,
        mapUrl: "https://maps.app.goo.gl/4HtrnjqdL2MJTowu8",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS44PJy22V69hnhS6pv0p9UfLf1NdTK-yiCa7ueKA5Pdw&s=10",
        title: loc.catchAToyRainbowBoxTitle,
        description: loc.catchAToyRainbowBoxDesc,
        fullExplanation: loc.catchAToyRainbowBoxFull,
        mapUrl: "https://maps.app.goo.gl/wyz6mimMq5CfHdYD9",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTCSoqk1Iz6LD8KWPK9S8f6FFrXiAiAT3t9BaHMWzb61A&s=10",
        title: loc.kekLokTongTitle,
        description: loc.kekLokTongDesc,
        fullExplanation: loc.kekLokTongFull,
        mapUrl: "https://maps.app.goo.gl/jDhh7FUfvVEUtTZ16",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTEM-R24jT5CLdURjpasw4HMDq-3AHEpm0BWz_CAw2dxA&s=10",
        title: loc.artOfOldTownTitle,
        description: loc.artOfOldTownDesc,
        fullExplanation: loc.artOfOldTownFull,
        mapUrl: "https://maps.app.goo.gl/AnSaf85gYNdLZm238",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQbi7Tsk0_-zb1d8N7C-yDKdEu-W-_FZOWVT3LEfxLYLA&s=10",
        title: loc.gunungLangTitle,
        description: loc.gunungLangDesc,
        fullExplanation: loc.gunungLangFull,
        mapUrl: "https://maps.app.goo.gl/4SCiURXadiNtvTow9",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcREX4gwlXXDynh-8KM-CZX06SftNJhRC3apXwUMQ6gfCg&s=10",
        title: loc.funtasyHouseTitle,
        description: loc.funtasyHouseDesc,
        fullExplanation: loc.funtasyHouseFull,
        mapUrl: "https://maps.app.goo.gl/GPpTtiy6RYUK8MxD9",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRWj8JUuwvYqI1DM2rjyP3vtzgfVvuZSnubA_DkiWn2EY9sRxafmf1SQEBt&s=10",
        title: loc.dataranMedanStesenTitle,
        description: loc.dataranMedanStesenDesc,
        fullExplanation: loc.dataranMedanStesenFull,
        mapUrl: "https://maps.app.goo.gl/Ki9F31ZbvrA5FLfi8",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR3SnBDPgFsHldEKTKyPG9GyIC98m1cO5UK-ti0Z0foXA&s=10",
        title: loc.bluebluePlaylandTitle,
        description: loc.bluebluePlaylandDesc,
        fullExplanation: loc.bluebluePlaylandFull,
        mapUrl: "https://maps.app.goo.gl/dyzSi1AfJNXFGD3x8",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTSAGxPkS93MgOtdNdQvNDf4nBRqbk-jnQnsYBd9f00yQ&s=10",
        title: loc.lubukTimahTitle,
        description: loc.lubukTimahDesc,
        fullExplanation: loc.lubukTimahFull,
        mapUrl: "https://maps.app.goo.gl/53AHW5GmLgzZzLU89",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ4fzup2GPlNhwJ635uOi4OMbslbcaiw7NM1Mxbs95rBncgg_cveNMtk74E&s=10",
        title: loc.xParkSunwayTitle,
        description: loc.xParkSunwayDesc,
        fullExplanation: loc.xParkSunwayFull,
        mapUrl: "https://maps.app.goo.gl/yDYkKritJAw6GtF19",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTMdl12XOpl_kNmyjOWQMl-nCg78HZlDzN30OgsxWGa6A&s=10",
        title: loc.tasikCerminTitle,
        description: loc.tasikCerminDesc,
        fullExplanation: loc.tasikCerminFull,
        mapUrl: "https://maps.app.goo.gl/ceLdG24VZPBWuA6v6",
      ),
    ];

    final eatingPlaces = <ExplorationItem>[
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQqyp1oHDpzyxXqUCAaqCJeKWIJO6G6n5L8Mqk9PKH-mw&s=10",
        title: loc.dataranMbiFoodCourtTitle,
        description: loc.dataranMbiFoodCourtDesc,
        fullExplanation: loc.dataranMbiFoodCourtFull,
        mapUrl: "https://maps.app.goo.gl/939RNVeiuZHSf6u29",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT_tj_FS5yr-OM8iABPmMt6b17UvBChRwVzGS7M0DzKkA&s=10",
        title: loc.meeRebusRamliTitle,
        description: loc.meeRebusRamliDesc,
        fullExplanation: loc.meeRebusRamliFull,
        mapUrl: "https://maps.app.goo.gl/YJ7r6pVdJb1ci5Wp7",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRb4Da2M8WIC3XZ0m-D2IQpNgYWekcSyyeA2Mx5tQ2DKQ&s=10",
        title: loc.redBrickKitchenTitle,
        description: loc.redBrickKitchenDesc,
        fullExplanation: loc.redBrickKitchenFull,
        mapUrl: "https://maps.app.goo.gl/SJCk5atxcw7tUv3D7",
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
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/images/pnew.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 70),
                Text(
                  loc.ipohExplorationTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 3, 89, 210),
                  ),
                ),
                const SizedBox(height: 45),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    children: [
                      Expanded(
                        child: _CategoryTab(
                          label: loc.ipohTabHistorical,
                          selected: selectedTab == 0,
                          onTap: () => setState(() => selectedTab = 0),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _CategoryTab(
                          label: loc.ipohTabInteresting,
                          selected: selectedTab == 1,
                          onTap: () => setState(() => selectedTab = 1),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _CategoryTab(
                          label: loc.ipohTabEating,
                          selected: selectedTab == 2,
                          onTap: () => setState(() => selectedTab = 2),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 45),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(80, 0, 65, 20),
                    child: Scrollbar(
                      thumbVisibility: true,
                      thickness: 10,
                      radius: const Radius.circular(10),
                      child: ListView.separated(
                        padding: const EdgeInsets.only(right: 15, bottom: 20),
                        itemCount: data.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 30),
                        itemBuilder: (_, index) =>
                            _ExplorationCard(item: data[index]),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 300, right: 300, bottom: 80),
                  child: SizedBox(
                width: 420,
                height: 100,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PTOURISTPAGE(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 244, 245, 246),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.arrow_back, size: 34),
                      const SizedBox(width: 12),
                      Text(
                        loc.backText,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                              ),
                            ],
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
          barrierLabel: 'Ipoh exploration detail',
          barrierColor: Colors.black54,
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (_, __, ___) => _ExplorationDetailDialog(item: item),
          transitionBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutBack,
                ),
                child: child,
              ),
            );
          },
        );
      },
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.88),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withOpacity(0.55),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.12),
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
                child: Image.network(
                  item.image,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    );
                  },
                  errorBuilder: (_, __, ___) {
                    return Container(
                      color: Colors.grey.shade300,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 80,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 22),
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.grey.shade800,
                          height: 1.25,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.blueAccent,
                size: 32,
              ),
              const SizedBox(width: 22),
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
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 880, maxHeight: 1500),
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
                    height: 390,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 390,
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      );
                    },
                    errorBuilder: (_, __, ___) {
                      return Container(
                        height: 390,
                        width: double.infinity,
                        color: Colors.grey.shade300,
                        alignment: Alignment.center,
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
                          color: Color(0xFF1A237E),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        item.fullExplanation,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          fontSize: 25,
                          color: Colors.black87,
                          height: 1.45,
                        ),
                      ),
                      if (item.mapUrl != null) ...[
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: const Color(0xFF0359D2),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: QrImageView(
                            data: item.mapUrl!,
                            size: 190,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          loc.ipohGoogleMap,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0359D2),
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(280, 85),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          loc.ipohClose,
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
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF0359D2)
              : Colors.white.withOpacity(0.75),
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
            maxLines: 2,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : const Color(0xFF0359D2),
            ),
          ),
        ),
      ),
    );
  }
}
