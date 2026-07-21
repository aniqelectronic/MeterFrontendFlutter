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

class PExplorationRompinPage extends StatefulWidget {
  const PExplorationRompinPage({super.key});

  @override
  State<PExplorationRompinPage> createState() =>
      _PExplorationRompinPageState();
}

class _PExplorationRompinPageState
    extends State<PExplorationRompinPage> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    /// ================= HISTORICAL =================
    final historicalPlaces = [
      ExplorationItem(
        image: "https://lh3.googleusercontent.com/gps-cs-s/AHVAwepA9IjqVSOqvGTL7XRKrHZuWSvAufJI3UF5ZouscIxizld43_2VzBaeG3LdsjIvde9Z4OjK6vDXSU7jerSVqt9b9sLtUH9Ji4GNmrz1gv-cTCXTdoOQPblfaHizLN4jovtzAWnC=s1360-w1360-h1020-rw",
        title: "0 KM Kuala Rompin",
        date: "04/02/2026",
        description: loc.rompin0kmDesc,
        fullExplanation: loc.rompin0kmFull,
        mapUrl: "https://maps.app.goo.gl/ewdqyG6JqUPhhYMKA",
      ),
    ];

    /// ================= INTERESTING =================
    final interestingPlaces = [
      ExplorationItem(
          image: "https://www.visitpahang.my/wp-content/uploads/2022/11/2022-11-08-18.00.41.jpg",
          title: "Seri Mahkota Waterfall",
          date: "04/02/2026",
          description: loc.seriMahkotaDesc,
          fullExplanation: loc.seriMahkotaFull,
          mapUrl: "https://maps.app.goo.gl/RCsJke88m95kfefy5",
           ),

      ExplorationItem(
          image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQJ0-gnnnXU5Xxf40G9T_5vYwwHjyP3gE49bA&s",
          title: "Rompin Trail",
          date: "04/02/2026",
          description: loc.rompinTrailDesc,
          fullExplanation: loc.rompinTrailFull,
          mapUrl: "https://maps.app.goo.gl/Auo4CZ8rHf6e6srJA",
          ),

      ExplorationItem(
          image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRfM9bppQcqAzDylCR1DzdB-ijL7oDzm4xanQ&s",
          title: "Pantai Hiburan",
          date: "04/02/2026",
          description: loc.pantaiHiburanDesc,
          fullExplanation: loc.pantaiHiburanFull,
          mapUrl: "https://maps.app.goo.gl/mT52dmXW5rLwRWyN7",),


      ExplorationItem(
          image: "https://cf.bstatic.com/xdata/images/hotel/max1024x768/153877575.jpg?k=d4ebdcab2b1514e90d3f96361db309ec592889d38aaf29a85538cecf224a7fce&o=",
          title: "Rompin Beach Resort",
          date: "04/02/2026",
          description: loc.beachResortDesc,
          fullExplanation: loc.beachResortFull,
          mapUrl: "https://maps.app.goo.gl/fJMo4ckuZ4NRR6yi7",
          ),

      ExplorationItem(
          image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTfL73R6LUM4hfyb7KXmAaaYUPfvMbkyRgkhg&s",
          title: "Taman Negeri Rompin Pahang",
          date: "04/02/2026",
          description: loc.tamanNegeriDesc,
          fullExplanation: loc.tamanNegeriFull,
          mapUrl: "https://maps.app.goo.gl/fXk5ovY7sA2FkVhu7",
          ),

      ExplorationItem(
          image: "https://cf.bstatic.com/xdata/images/hotel/max1024x768/362023877.jpg?k=b23d85a7ac932040c678d07f0c4cd61ae004fa5501fca5922e59e15ce42c2a51&o=",
          title: "Rompin Rainforest Lodge",
          date: "04/02/2026",
          description: loc.rainforestLodgeDesc,
          fullExplanation: loc.rainforestLodgeFull,
          mapUrl: "https://maps.app.goo.gl/m1hgKMQNx44Tf89a8",
          ),

      ExplorationItem(
          image: "https://lh3.googleusercontent.com/p/AF1QipMbk1NFHpJcnRBPXndbtTHnGh6fQklFM05ygsfR=s1360-w1360-h1020-rw",
          title: "Cemara Riverview Chalet",
          date: "04/02/2026",
          description: loc.cemaraDesc,
          fullExplanation: loc.cemaraFull,
          mapUrl: "https://maps.app.goo.gl/3yBYbWg7eXB6qu376",
          ),

      ExplorationItem(
          image: "https://lh3.googleusercontent.com/gps-cs-s/AHVAweqNEfSiMTCfGwmmlD9XWGhW8vSZYduIOPHvamtYfN1IgfMlc6VZXiBB1S8hfZDHywVYumNfd1z-py8GEdqfF-C_IPhVMT-7dix-tFTOwovlD98e4oaAqo-k8_VUOcG6BavNhuUs=s1360-w1360-h1020-rw",
          title: "Jeti Awam Pantai Bernas",
          date: "04/02/2026",
          description: loc.jetiBernasDesc,
          fullExplanation: loc.jetiBernasFull,
          mapUrl: "https://maps.app.goo.gl/x9quYANM22zbjBmX8",
          ),
    ];

    /// ================= FOOD =================
    final eatingPlaces = [

      ExplorationItem(image:"https://lh3.googleusercontent.com/gps-cs-s/AHVAweoKWjsMqMs0dL2N_0eKyZ6JYsUvHHXvIwiGPNdwgyNws5zDB7qZJI7_yDJUf3ruIcdZgwpSZeAPKtYPZORHE7lic9_KWsxAwOR2_22cpBNw89AiWV4WXv3RUHraMBpjLVJDWOs9Slws8BoI=w243-h174-n-k-no-nu",
          title:"Restoran Rompin Baru",date:"04/02/2026",
          description:loc.food1Desc,fullExplanation:loc.food1Full,
          mapUrl: "https://maps.app.goo.gl/R1pDM5vWJGhMUATj7",
          ),

      ExplorationItem(image:"https://media-cdn.tripadvisor.com/media/photo-s/1c/00/e6/dc/img-20200901-wa0025-largejpg.jpg",
          title:"Gerai Makan Mak Ngah Udang Galah Sepit Biru",date:"04/02/2026",
          description:loc.food2Desc,fullExplanation:loc.food2Full,
          mapUrl: "https://maps.app.goo.gl/qd2euNEz3usefym47",
          ),

      ExplorationItem(image:"https://lh3.googleusercontent.com/p/AF1QipNsxFGrttqgkcQ2roJ2heiOWoDUd_eiN_YeS9Iw=s1360-w1360-h1020-rw",
          title:"Sarap D' Tasek Kuala Rompin",date:"04/02/2026",
          description:loc.food3Desc,fullExplanation:loc.food3Full,
          mapUrl: "https://maps.app.goo.gl/11KTWJTUmaCs2S4R8",
          ),

      ExplorationItem(image:"https://lh3.googleusercontent.com/gps-cs-s/AHVAweql55e-nobdIegfRgrpf_g7man13LLEgPwRLBCCBmB2Ljr6yb7YHgrkLqRO2TZPGLzYJLgSb2piXjHXHRDOlfVJ-K4iBD31KAz-s_ONvv9aR3NTvPhxqKLmvVaLj7UtcgeTLwE-=s1360-w1360-h1020-rw",
          title:"Kedai Makan Selera Serdang",date:"04/02/2026",
          description:loc.food4Desc,fullExplanation:loc.food4Full,
          mapUrl: "https://maps.app.goo.gl/ktpbWkTfkm5pD2Zn9",
          ),

      ExplorationItem(image:"https://lh3.googleusercontent.com/gps-cs-s/AHVAwepkEae11fcGPYPw4i1FVch9ieR0VY6ZJxN2FPUOdc4CqwHv4egv5A11mHF6RBa8Xq8zzKSCl_mLEiiwFzb0n3qtR0vHgv0mKB15aWqnEJwdeq2MZnJFZWqtlcodcdvp9NR52MdXRw=w408-h306-k-no",
          title:"Gerai Makan Azizah Cawangan-2",date:"04/02/2026",
          description:loc.food5Desc,fullExplanation:loc.food5Full,
          mapUrl: "https://maps.app.goo.gl/TLPrXDUhHcpfRVYS8",
          ),

      ExplorationItem(image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRcKH7Ku90wEk3zg8ec0_zEovVBHVKsNSKKUA&s",
          title:"Restoran Paip Biru",date:"04/02/2026",
          description:loc.food6Desc,fullExplanation:loc.food6Full,
          mapUrl: "https://maps.app.goo.gl/1jKKdXyvTU3HazQEA",
          ),

      ExplorationItem(image:"https://media-cdn.tripadvisor.com/media/photo-s/05/cb/f6/47/rompin-river-seafood.jpg",
          title:"Restaurant Rompin River Seafood",date:"04/02/2026",
          description:loc.food7Desc,fullExplanation:loc.food7Full,
          mapUrl: "https://maps.app.goo.gl/TGvn6JueTE3y9God7",
          ),

      ExplorationItem(image:"https://lh3.googleusercontent.com/gps-cs-s/AHVAweo2Vgke8G8StbAYXsVBaPllr9KJ1iDHnSubIUrNae2rw9wk6W_RtuZoG9is2SNlCNrg81mp8rro0tSQ-33WbzQjTCO3lyisdXCAufp-NjGRi2FY_NpXTfj3NTEgAJuvbEXCQmE=w243-h304-n-k-no-nu",
          title:"Warong Kopi Johan",date:"04/02/2026",
          description:loc.food8Desc,fullExplanation:loc.food8Full,
          mapUrl: "https://maps.app.goo.gl/NNuAUd5rh79j1LvN8",
          ),

      ExplorationItem(image:"https://lh3.googleusercontent.com/gps-cs-s/AHVAwepQT28fMDJZZycx1Evk4RVs5ij6yYkUW27I5cHj7k3hLNX5flbqc16c9qNb7IfHh1dLAV4ZIMQL3P850YMrPb_2lWS_f0BMat6K-eilmChplG7N_71Qjg9cqNb-YZsrhFdD8nsY=s1360-w1360-h1020-rw",
          title:"Ikan Celup Tepung Qaseh Armani",date:"04/02/2026",
          description:loc.food9Desc,fullExplanation:loc.food9Full,
          mapUrl: "https://maps.app.goo.gl/NVLHZvWmfhTN3tWS8",
          ),

      ExplorationItem(image:"https://lh3.googleusercontent.com/gps-cs-s/AHVAweoTjOopZZxHwTUy0_-lXJRpUnAPp9RkHi75r0R0dSOfvLLhsXhNcSB4Y-1LMduiiqVHYh3li7yVZbeJo1VXUM-YJ9gOgA0VKPqGrH4mxqN3VohftAE-IELKCcbZxelNBE96Rd5BervnG1-5=s1360-w1360-h1020-rw",
          title:"Warung Celup Tepung Embun Corner",date:"04/02/2026",
          description:loc.food10Desc,fullExplanation:loc.food10Full,
          mapUrl: "https://maps.app.goo.gl/J6Xr5rP6CRvDtvMw7",
          ),

      ExplorationItem(image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQbhK2Fb9_2BBZGVa5ItYcKtHKi5OgLA6Yo3w&s",
          title:"Gerai Makan Hajjah Rosminah",date:"04/02/2026",
          description:loc.food11Desc,fullExplanation:loc.food11Full,
          mapUrl: "https://maps.app.goo.gl/9wRxywJ8jfsZAVL99",
          ),

      ExplorationItem(image:"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTqiuqWD92Uz2ieGpuqaIpcVpHuZhontslpGg&s",
          title:"Kedai Makan Pokok Manggis",date:"04/02/2026",
          description:loc.food12Desc,fullExplanation:loc.food12Full,
          mapUrl: "https://maps.app.goo.gl/ZEXCKJo3cMLpnDsi7",
          ),

      ExplorationItem(image:"https://lh3.googleusercontent.com/gps-cs-s/AHVAwepi6bty8Dafvyrefeqk_Bc15OGa915ddYHrYDLDQJnNNJickIVBgZuX9bb4RsCyBTwPldZdFR4FI_kIiJeBJNBwHSJZhyHULEyN5DGEC-li_Xj1aMOpw2MrNjlLm1aG8dW3LkY=s1360-w1360-h1020-rw",
          title:"Mak Ngah Udang Galah Cawangan 2",date:"04/02/2026",
          description:loc.food13Desc,fullExplanation:loc.food13Full,
          mapUrl: "https://maps.app.goo.gl/RfCj9EGdbUhWb9KVA",
          ),

      ExplorationItem(image:"https://lh3.googleusercontent.com/p/AF1QipOde-GdkHGl2idxf3un4rXXaHLxweMw1NnTwiaL=w289-h312-n-k-no",
          title:"DYA ZARA CAFE Rompin",date:"04/02/2026",
          description:loc.food14Desc,fullExplanation:loc.food14Full,
          mapUrl: "https://maps.app.goo.gl/g3MM2bh9nb6T9LoB7",
          ),

      ExplorationItem(image:"https://lh3.googleusercontent.com/gps-cs-s/AHVAweoRZdsSA7UdkeLrFlXsSRTqFxeP-BdjI1Mf7WdKnMA2O1yWCqMzw84nqKvBb7dA3nvUo7rF1-xPFZipGrG89db42Qq9xcnbvj5ZZnKAcWP8Z59GlBGSONCtJeGQiV90e2z-18I=w325-h218-n-k-no",
          title:"Meisha Corner (Kedai Makan)",date:"04/02/2026",
          description:loc.food15Desc,fullExplanation:loc.food15Full,
          mapUrl: "https://maps.app.goo.gl/oRCkE71177QfL8mz8",
          ),

      ExplorationItem(image:"https://lh3.googleusercontent.com/gps-cs-s/AHVAwerWTY_jL31Jo-f7BHxbqqOaFnoJSFXx1TPrWp7N5v5lI2w35vbPYlIp04WPVgCKx-LwdemXdVx9j5hsfPR4LPpfnPIL3bA0Pwr7YMXIzADB9KjNohaDnBO4DVUT8NvFuWeMqJcZfQ=s1360-w1360-h1020-rw",
          title:"MS STREET KITCHEN",date:"04/02/2026",
          description:loc.food16Desc,fullExplanation:loc.food16Full,
          mapUrl: "https://maps.app.goo.gl/XZgVnkxs2cQdrv2NA",
          ),

      ExplorationItem(image:"https://lh3.googleusercontent.com/gps-cs-s/AHVAweq1_jQs0TLzmqKLkUyroMN_vdrR3zjAaWauAkztlCVA8R6V9APXvzzp81Gnm1HoTcihTxDbA5HEtv2fPD1SkFWEQ1iymNbvjPJU7xbleZd1qhxb4ANun9Jhb8gj_gznUmROxibV=s1360-w1360-h1020-rw",
          title:"Warung Mokla",date:"04/02/2026",
          description:loc.food17Desc,fullExplanation:loc.food17Full,
          mapUrl: "https://maps.app.goo.gl/oKBrXG7og5rM9cZr9",
          ),

      ExplorationItem(image:"https://lh3.googleusercontent.com/gps-cs-s/AHVAweorjn3Vgijv-1bLZdQeewsXio4TY-pjN4qZE52ZFDj7umnT7DQ9hofqD6pnaXbXG4AH3l_8kpdsYC_mVhFuV9fFzz6l4w1tyKTcG4ksZnVL9VYr40IfOIU0y3hHy07oO3IcX_LV5g=s1360-w1360-h1020-rw",
          title:"One's Seafood",date:"04/02/2026",
          description:loc.food18Desc,fullExplanation:loc.food18Full,
          mapUrl: "https://maps.app.goo.gl/z7PtYdsXkFq2j9hx6",
          ),

      ExplorationItem(image:"https://lh3.googleusercontent.com/gps-cs-s/AHVAwepribvVuc85gM9AO0iU7mAUvAEt2F8Fbhi5n0gKjmn2NeliH7UErgHnjtBHzmXLRTKLeCfresRb4ePuNzEXVbYMSwPro9YodnZWadPIH3JnIGZaWK02Y9CLFfZKRjeSYAI_GgsV=s1360-w1360-h1020-rw",
          title:"Medan Selera Rompin",date:"04/02/2026",
          description:loc.food19Desc,fullExplanation:loc.food19Full,
          mapUrl: "https://maps.app.goo.gl/qbV95BQPzq6CbZXw5",
          ),

      ExplorationItem(image:"https://lh3.googleusercontent.com/gps-cs-s/AHVAweotBEos7jJW4Gd4pje8wFnqkGYOFmIj0oQWYVXyYVTjPSzaONvcdMivBXp7HJPWCwlaCM1dr5IIB__vcPvnZWhSwKUHuUVmLufxPmpC1zEij4r7V_5gDAx7fbovWh_SZTwSIXpKlQ=s1360-w1360-h1020-rw",
          title:"MR CHURROS",date:"04/02/2026",
          description:loc.food20Desc,fullExplanation:loc.food20Full,
          mapUrl: "https://maps.app.goo.gl/cTfGHue8nJCB7gpD9",
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
              Text(loc.rompinExplorationTitle,
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
