import 'package:flutter/material.dart';
import 'package:frontend_v1/pages/pothers3.dart';
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
class PExplorationNegeriSembilanPage extends StatefulWidget {
  const PExplorationNegeriSembilanPage({super.key});

  @override
  State<PExplorationNegeriSembilanPage> createState() =>
      _PExplorationNegeriSembilanPageState();
}

class _PExplorationNegeriSembilanPageState
    extends State<PExplorationNegeriSembilanPage> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    /// ================= HISTORICAL =================
    final historicalPlaces = [
      ExplorationItem(
        image:
            "https://live.staticflickr.com/65535/10425574095_3415ff82de_z.jpg",
        title: loc.nsIstanaTitle,
        date: "01-01-2026",
        description: loc.nsIstanaDesc,
        fullExplanation: loc.nsIstanaFull,
        mapUrl: "https://maps.app.goo.gl/uhfkzES3KJmkkWQ68",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQGg9HEDmw0dXf1B_V_5oCGR0X8sRBOqElN2Q&s",
        title: loc.nsMuseumTitle,
        date: "01-01-2026",
        description: loc.nsMuseumDesc,
        fullExplanation: loc.nsMuseumFull,
        mapUrl: "https://maps.app.goo.gl/W1x8bEAuHgo1Xnaz5",
      ),
      ExplorationItem(
        image:
            "https://d19snafwln6jq8.cloudfront.net/xom-rest/assets/f74855dc-23d7-4518-96dd-78d2e2dad5e8/preview?width=1600&height=800&mimeType=image%2Fjpeg",
        title: loc.nsMasjidTitle,
        date: "01-01-2025",
        description: loc.nsMasjidDesc,
        fullExplanation: loc.nsMasjidFull,
        mapUrl: "https://maps.app.goo.gl/sUEfrmMowbt8D4ab8",
      ),

            ExplorationItem(
        image:
            "https://i0.wp.com/gdtjns.com/wp-content/uploads/2016/03/IMG_7930-scaled.jpg?ssl=1",
        title: loc.royalGalleryTitle,
        date: "01-01-2026",
        description: loc.royalGalleryDesc,
        fullExplanation: loc.royalGalleryFull,
        mapUrl: "https://maps.app.goo.gl/RmMznBB2WfnWuNts8",
      ),
      ExplorationItem(
        image:
            "https://gowhere.my/wp-content/uploads/2015/07/Centipede-Temple-Then-Sze-Koon--e1436863512321.png",
        title: loc.centipedeTempleTitle,
        date: "01-01-2026",
        description: loc.centipedeTempleDesc,
        fullExplanation: loc.centipedeTempleFull,
        mapUrl: "https://maps.app.goo.gl/7Sd8Zt1U4dtcMdWm9",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTrS0U9TROuPJE1fFMXkfJyIs7OHFFWlCOEcw&s",
        title: loc.armyMuseumPDTitle,
        date: "01-01-2026",
        description: loc.armyMuseumPDDesc,
        fullExplanation: loc.armyMuseumPDFull,
        mapUrl: "https://maps.app.goo.gl/zkDpTq4kjNGwPuMX9",
      ),

    ];

    /// ================= INTERESTING =================
    final interestingPlaces = [
      ExplorationItem(
        image:
            "https://www.holidify.com/images/cmsuploads/compressed/Blue_Lagoon_Port_Dickson_Malaysia_20200109171323.jpeg",
        title: loc.nsPortDicksonTitle,
        date: "01-01-2025",
        description: loc.nsPortDicksonDesc,
        fullExplanation: loc.nsPortDicksonFull,
        mapUrl: "https://maps.app.goo.gl/YDhdsrrczazv3Bi27",
      ),
      ExplorationItem(
        image:
            "https://pokokkelapa.wordpress.com/wp-content/uploads/2019/09/pokok-kelapa-angsi-b-putus-3.jpg?w=584",
        title: loc.nsGunungAngsiTitle,
        date: "01-01-2025",
        description: loc.nsGunungAngsiDesc,
        fullExplanation: loc.nsGunungAngsiFull,
        mapUrl: "https://maps.app.goo.gl/AHd49mQyDk4i8YAcA",
      ),
      ExplorationItem(
        image:
            "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/09/bb/35/09/air-terjun-jeram-toi.jpg?w=900&h=500&s=1",
        title: loc.nsJeramTitle,
        date: "01-01-2025",
        description: loc.nsJeramDesc,
        fullExplanation: loc.nsJeramFull,
        mapUrl: "https://maps.app.goo.gl/jYCw5YML4eSDL7zs8",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSoEMFuj0jRNbcq3F82MIxbixhU9wvVDM1q6A&s",
        title: loc.hutanRecTanjungTuanTitle,
        date: "01-01-2026",
        description: loc.hutanRecTanjungTuanDesc,
        fullExplanation: loc.hutanRecTanjungTuanFull,
        mapUrl: "https://maps.app.goo.gl/T8YLMETdamHxe6Xb8",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTpyzGSEKfJ2rx9igZXrDtcUeVXn441z6T-7w&s",
        title: loc.eduEcoSungaiMenyalaTitle,
        date: "01-01-2026",
        description: loc.eduEcoSungaiMenyalaDesc,
        fullExplanation: loc.eduEcoSungaiMenyalaFull,
        mapUrl: "https://maps.app.goo.gl/UBgJvtNdFSbt9UmS7",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSEME3fZi8hUq7O87dnC2H-aUfxcbNFu6_oEA&s",
        title: loc.serembanHillParkTitle,
        date: "01-01-2026",
        description: loc.serembanHillParkDesc,
        fullExplanation: loc.serembanHillParkFull,
        mapUrl: "https://maps.app.goo.gl/bvi9JGKtweMqsBXX9",
      ),

      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTjXsNbOKon8B1jDzg6VvZDaKlQ6mwDrEf5cA&s",
        title: loc.wildWestTitle,
        date: "01-01-2026",
        description: loc.wildWestDesc,
        fullExplanation: loc.wildWestFull,
        mapUrl:
            "https://maps.app.goo.gl/Gr9iju1GUDbBmjvG7",
      ),
      ExplorationItem(
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTwfcB78rCqQtSDVJRWscxKkkWamQsN3IYf6Q&s",
        title: loc.wetWorldTitle,
        date: "01-01-2026",
        description: loc.wetWorldDesc,
        fullExplanation: loc.wetWorldFull,
        mapUrl: "https://maps.app.goo.gl/cuoAXSVYTrk7QM4s8",
      ),
      ExplorationItem(
        image:
            "https://assets.hmetro.com.my/images/articles/SANTAI_-_%E2%80%98KARPET_HIJAU%E2%80%99_SUNGAI_KENABOI_HMfield_image_socialmedia.var_1685572228.jpg",
        title: loc.tnKenaboiTitle,
        date: "01-01-2026",
        description: loc.tnKenaboiDesc,
        fullExplanation: loc.tnKenaboiFull,
        mapUrl: "https://maps.app.goo.gl/nMeHrmSvBo1azqGa9",
      ),
        ExplorationItem(
        image:
            "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/2a/92/dc/c4/caption.jpg?w=900&h=500&s=1",
        title: loc.airTerjunLataKijangTitle,
        date: "01-01-2026",
        description: loc.airTerjunLataKijangDesc,
        fullExplanation: loc.airTerjunLataKijangFull,
        mapUrl: "https://maps.app.goo.gl/wXGD89Uh3cC22qFc9",
      ),
        ExplorationItem(
        image:
            "https://petitguru.s3.amazonaws.com/129/18.jpg",
        title: loc.pIkanHiasanPDTitle,
        date: "01-01-2026",
        description: loc.pIkanHiasanPDDesc,
        fullExplanation: loc.pIkanHiasanPDFull,
        mapUrl: "https://maps.app.goo.gl/AVJB4TsuohLBpnwa6",
      ),
    ];

    /// ================= EATING =================
    final eatingPlaces = [
      ExplorationItem(
        image:
            "https://lh3.googleusercontent.com/gps-cs-s/AG0ilSw4wtUO3jv70OBM5qg0-rTTfSC5MnVh2XCM1A-v_8gXA82QZx_DLoTj4-B0uIQmimooutW5KsE4btZkKapWQJ0cHROsK3wjxH0ySahFicS9ljWKWIrIwqnOxKX2U1s6nbQi=w408-h306-k-no",
        title: loc.nsKuwaahTitle,
        date: "01-01-2025",
        description: loc.nsKuwaahDesc,
        fullExplanation: loc.nsKuwaahFull,
        mapUrl: "https://maps.app.goo.gl/C8XbudHFxsgigdE17",
      ),
      ExplorationItem(
        image:
            "https://lh3.googleusercontent.com/gps-cs-s/AG0ilSy3Srj34AF3u4RpjkmvslrHZ5Is26So1fFfozqaOrw-HYCfGWwa50gFcdRstwKU_ezdVtBuzTmk1OipIznLEex0DvOxsdHHPPHSWcAMwW_tWsaby6QIcmWZy_7dHkBO6xN4m2U=s1360-w1360-h1020-rw",
        title: loc.nsRimbaTitle,
        date: "01-01-2025",
        description: loc.nsRimbaDesc,
        fullExplanation: loc.nsRimbaFull,
        mapUrl: "https://maps.app.goo.gl/LfwTDzaGoyX5br4C9",
      ),

            ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQro2Zqt_6zn-pgtNh8IskMYcGzfE-VM6u14w&s",
        title: loc.hayyanHudaTitle,
        date: "01-01-2026",
        description: loc.hayyanHudaDesc,
        fullExplanation: loc.hayyanHudaFull,
        mapUrl: "https://maps.app.goo.gl/SXbu2magkNm3ExMe6",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRFUGk1CLSMXaAmm4XxymFYBvtqeS9k_NST-w&s",
        title: loc.meeHirisTitle,
        date: "01-01-2026",
        description: loc.meeHirisDesc,
        fullExplanation: loc.meeHirisFull,
        mapUrl: "https://maps.app.goo.gl/qo4jhAFRCA7Gwzvs6",
      ),
      ExplorationItem(
        image: "https://lh3.googleusercontent.com/gps-cs-s/AHVAweplaoZuWHb-60fecGHU05tTU-fxjG-iFl6tB-BZSgPW_9Vgc9bT0BJpftNtn6mLOiVicQHX1VAVgoBRT4enzy9bIT8s7fhD6u148_-Zh7Roa0cHtEuq04NEFfpuv6Xv1dWdl1RH=s1360-w1360-h1020-rw",
        title: loc.belqisTitle,
        date: "01-01-2026",
        description: loc.belqisDesc,
        fullExplanation: loc.belqisFull,
        mapUrl: "https://maps.app.goo.gl/ba8Yx76mD1uFKVXcA",
      ),
      ExplorationItem(
        image: "https://lh3.googleusercontent.com/p/AF1QipPalXB7WUUNDKx_pcuWvpFxnwBgObK_96wtxS5x=s1360-w1360-h1020-rw",
        title: loc.seleraNogoriTitle,
        date: "01-01-2026",
        description: loc.seleraNogoriDesc,
        fullExplanation: loc.seleraNogoriFull,
        mapUrl: "https://maps.app.goo.gl/kLNtb3ioV4zbT2as7",
      ),
      ExplorationItem(
        image: "https://media-cdn.tripadvisor.com/media/photo-s/0a/0f/0a/81/restoren-kemangi.jpg",
        title: loc.kemangiTitle,
        date: "01-01-2026",
        description: loc.kemangiDesc,
        fullExplanation: loc.kemangiFull,
        mapUrl: "https://maps.app.goo.gl/5dxjQLbyVq4gwJT7A",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS4NrCg6JIW3gc_7KIV5VJ9ZuWNZW_tDk10qQ&s",
        title: loc.hajiShariffCendolTitle,
        date: "01-01-2026",
        description: loc.hajiShariffCendolDesc,
        fullExplanation: loc.hajiShariffCendolFull,
        mapUrl: "https://maps.app.goo.gl/kP8mw6wvfWpBhJMr6",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQqG7Di5bAQVsktFFT3mOFfeeM9OGSgsC7-6A&s",
        title: loc.nasiArabDamsyikTitle,
        date: "01-01-2026",
        description: loc.nasiArabDamsyikDesc,
        fullExplanation: loc.nasiArabDamsyikFull,
        mapUrl: "https://maps.app.goo.gl/tBbHN8MFrY3Wbza87",
      ),
      ExplorationItem(
        image: "https://lh3.googleusercontent.com/gps-cs-s/AHVAweqgt7neRQGfmOK-LJ3qrPtfiKdMt3moa68jzVWHkv9sJDYP62wJ2w2_VTRyK7Gw8_MgNN3S4iKpHnj3K5IUFTo37V9YqPZWe1aCPVPDpgjDRDGX8wrS1egiZJh_9ez7AzWjbqA=s1360-w1360-h1020-rw",
        title: loc.restoranDPantaiTitle,
        date: "01-01-2026",
        description: loc.restoranDPantaiDesc,
        fullExplanation: loc.restoranDPantaiFull,
        mapUrl: "https://maps.app.goo.gl/krb3BEfeUU8nygSX6",
      ),
      ExplorationItem(
        image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRyUjLWvGu2Tz1GT1rZKG52jfohIfwKQ0M3Yg&s",
        title: loc.nasiLemakSenawangTitle,
        date: "01-01-2026",
        description: loc.nasiLemakSenawangDesc,
        fullExplanation: loc.nasiLemakSenawangFull,
        mapUrl: "https://maps.app.goo.gl/Q9BDuQM2V6KB5USK7",
      ),
      ExplorationItem(
        image: "https://media-cdn.tripadvisor.com/media/photo-s/17/a5/18/97/good-evening-n9stickfactory.jpg",
        title: loc.n9StickFactoryTitle,
        date: "01-01-2026",
        description: loc.n9StickFactoryDesc,
        fullExplanation: loc.n9StickFactoryFull,
        mapUrl: "https://maps.app.goo.gl/UaJxagkFHF837QG47",
      ),
      ExplorationItem(
        image: "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/13/e6/e9/82/20180729-115603-largejpg.jpg?w=1200&h=1200&s=1",
        title: loc.pdFamousCendolTitle,
        date: "01-01-2026",
        description: loc.pdFamousCendolDesc,
        fullExplanation: loc.pdFamousCendolFull,
        mapUrl: "https://maps.app.goo.gl/fGjiz7cdBXkYekGj9",
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
                loc.nsExplorationTitle,
                style: const TextStyle(
                  color: Color.fromARGB(255, 3, 89, 210),
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),
              /// Tabs
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
              SizedBox(
                height: MediaQuery.of(context).size.height - 720,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: Scrollbar(
                    thumbVisibility: true,
                    thickness: 10,
                    child: ListView.separated(
                      itemCount: data.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 30),
                      itemBuilder: (_, index) => _ExplorationCard(item: data[index]),
                    ),
                  ),
                ),
              ),
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
