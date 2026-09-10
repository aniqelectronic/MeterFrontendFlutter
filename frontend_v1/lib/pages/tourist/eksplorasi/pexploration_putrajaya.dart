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
// PUTRAJAYA EXPLORATION PAGE
// ============================================================================
class PExplorationPutrajayaPage extends StatefulWidget {
  const PExplorationPutrajayaPage({
    super.key,
  });

  @override
  State<PExplorationPutrajayaPage> createState() =>
      _PExplorationPutrajayaPageState();
}

class _PExplorationPutrajayaPageState
    extends State<PExplorationPutrajayaPage> {
  // 0 = Historical
  // 1 = Interesting
  // 2 = Food
  int selectedTab = 1;

  static const String _updatedDate = '10/09/2026';

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    // ========================================================================
    // HISTORICAL PLACES
    // ========================================================================
    final historicalPlaces = <ExplorationItem>[
      _historical(
        loc,
        title: 'Masjid Putra',
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQvBrhYaIxOEF9W3Pg4qNs7_wnHe7Nap8dbTUhlJlrXOQ&s=10',
        mapUrl:
            'https://maps.app.goo.gl/qgfnhbMUJaW5ssL97',
      ),
      _historical(
        loc,
        title: 'Perdana Putra',
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSSlJdSvx4PhttWsVjAApZChU4aZBiiDHwwUAqBVdifZA&s=10',
        mapUrl:
            'https://maps.app.goo.gl/G5reFJ6RmgXKp2Ln8',
      ),
      _historical(
        loc,
        title:
            'Masjid Tuanku Mizan Zainal Abidin',
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRBQeSvKzSPKg7PdiBCrQYLsZgBH-Inc0wIP6OaRLUtaw&s=10',
        mapUrl:
            'https://maps.app.goo.gl/rKzfKAcd4FmbBt9N8',
      ),
    ];

    // ========================================================================
    // INTERESTING PLACES
    // ========================================================================
    final interestingPlaces = <ExplorationItem>[
      _interesting(
        loc,
        title: 'Putrajaya Secret Garden',
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQprSS4mQTffN8Tccy-LK5fnBmYlEYjFm4gGrgoKyWJX9kBE45oO_Epil0&s=10',
        mapUrl:
            'https://maps.app.goo.gl/jydM9y75haoy3CDt5',
      ),
      _interesting(
        loc,
        title: 'Dataran Putra',
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT2NMDQDI4rGjIya3zTAqao22fF8Txh7V7wYU5Rv3Gl4g&s=10',
        mapUrl:
            'https://maps.app.goo.gl/ue8VvBHC59ArQib76',
      ),
      _interesting(
        loc,
        title: 'Astaka Morocco',
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTbEx0dGcuKJXfv7O3ap5DHrkgHIvFl6g9LRkpSI7BIKnh3Q_nLBYMGP7yM&s=10',
        mapUrl:
            'https://maps.app.goo.gl/sSF5fW18F1eRbc4D8',
      ),
      _interesting(
        loc,
        title: 'Putrajaya Steps',
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRD9gF08hwZHYsLVvgWxJvvHpQVPNAPauCmA73_SvcqruvIuKNxHKMBUzML&s=10',
        mapUrl:
            'https://maps.app.goo.gl/iDxMNz3nFBd7DESGA',
      ),
      _interesting(
        loc,
        title: 'Pantai Floria',
        image:
            'https://www.maisinggah.com/wp-content/uploads/2022/03/Pantai-Floria-Anjung-Floria-Presint-4-Putrajaya-2.jpg',
        mapUrl:
            'https://maps.app.goo.gl/ZF22NWtyTweX9Dd69',
      ),
      _interesting(
        loc,
        title: 'Anjung Floria',
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRYTnKqe9r-twr8mUUmrxQXNcWm6-iZHIlZTWejoo2Hh3PsCaFmdVoLjOE&s=10',
        mapUrl:
            'https://maps.app.goo.gl/SQvmdT7bJ9wi5eRE7',
      ),
      _interesting(
        loc,
        title: 'IOI City Mall Putrajaya',
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSZYQSvB_dF_kdhUdSWnw5wMxwZWEX6JUZiq-MEHA2O8PAVsDDT2VwzzXhB&s=10',
        mapUrl:
            'https://maps.app.goo.gl/dMtj9u7uQynBR2Tv8',
      ),
      _interesting(
        loc,
        title: 'G2G Animal Garden',
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT31fTQcfR9nUk4JtajA1CxqsjSI_flrcVZnzqgbFbwtBRIUhISXF7Nru0&s=10',
        mapUrl:
            'https://maps.app.goo.gl/N2MKifB5J213EpNN6',
      ),
      _interesting(
        loc,
        title: 'Taman Ekuestrian Putrajaya',
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTGxoe1-X5a1Mgcae_G_q4nvICR_9wnc1aFV4kcC1LGhGBmxb_rVWsWYTGh&s=10',
        mapUrl:
            'https://maps.app.goo.gl/2V6fXMkEiSx1VbVM6',
      ),
      _interesting(
        loc,
        title: 'Monumen Millennium',
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcScMNl_ZD61G3XHHDmUDGubr-EYXs0uQ3mB_cn3KSDxuA&s',
        mapUrl:
            'https://maps.app.goo.gl/hDyvcrFjrLC6wdPx7',
      ),
      _interesting(
        loc,
        title: 'Taman Botani Putrajaya',
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS5ehWn-zBHIkFZOlpyZ2aHbDL3f3tQLTw1uMXkRVfc1LxCeUK3ItIBiuS_&s=10',
        mapUrl:
            'https://maps.app.goo.gl/iBCUyqYj5UW5GuFV9',
      ),
      _interesting(
        loc,
        title: 'Taman Wetland Putrajaya',
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSUFJ3y4e-BHSeGCNViZQI5olMzIeWkCBAjTBOO67AbBh5Q9ijBVObTFAU&s=10',
        mapUrl:
            'https://maps.app.goo.gl/7JXGyf9m27rVSQQi8',
      ),
      _interesting(
        loc,
        title:
            'Pusat Konvensyen Antarabangsa Putrajaya',
        image:
            'https://upload.wikimedia.org/wikipedia/commons/f/ff/Putrajaya_1386543868_86fa637bd3.jpg',
        mapUrl:
            'https://maps.app.goo.gl/kmTEGhn7F6Wrf5dZA',
      ),
      _interesting(
        loc,
        title: 'Jambatan Seri Wawasan',
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQhqcHqz9DhKtL-UernMAP3RhqK_vuwCBrA3HyhN-SRDnyMp5QAUcLQJQA0&s=10',
        mapUrl:
            'https://maps.app.goo.gl/uf7HGmA7BMYAabG27',
      ),
      _interesting(
        loc,
        title: 'Cruise Tasik Putrajaya',
        image:
            'https://www.cruisetasikputrajaya.com/images/actp/article/02ed.jpg',
        mapUrl:
            'https://maps.app.goo.gl/tFiL2VrC4NAaCpgN8',
      ),
      _interesting(
        loc,
        title: 'Flyboard Malaysia',
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTt6mekp0dymzxfSfQDF-GJQKy8FIvA7IbQqCTkKMQiovg0xLXzZAV6vsQm&s=10',
        mapUrl:
            'https://maps.app.goo.gl/tfWj19nkgovDjsc66',
      ),
      _interesting(
        loc,
        title: 'Alamanda Putrajaya',
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcROqNku3v8ApGp2BV8q4vUzh_8xgpezXslEeNsbZ5XKDOCQkzs3oNTGCwkF&s=10',
        mapUrl:
            'https://maps.app.goo.gl/nvCUZ5P1ZQFRHU758',
      ),
      _interesting(
        loc,
        title: 'Taman Saujana Hijau Putrajaya',
        image:
            'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/13/90/b1/3b/photo2jpg.jpg?w=900&h=500&s=1',
        mapUrl:
            'https://maps.app.goo.gl/utGrWbQ48Y13qHsy6',
      ),
      _interesting(
        loc,
        title: 'Taman Cabaran Putrajaya',
        image:
            'https://www.ppj.gov.my/storage/11806/putrajaya-tamancabaran03-(2).jpg',
        mapUrl:
            'https://maps.app.goo.gl/cyi4JEQEmEMJ1rGk7',
      ),
    ];

    // ========================================================================
    // FOOD PLACES
    // ========================================================================
    final eatingPlaces = <ExplorationItem>[
      _food(
        loc,
        title: 'Umai Cafe',
        image:
            'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/0b/7e/49/ae/on-approaching-umai-cafe.jpg?w=500&h=-1&s=1',
        mapUrl:
            'https://maps.app.goo.gl/dtzkY4TufMxWCkgy5',
      ),
      _food(
        loc,
        title: 'Restoran Dapur Jiran',
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcToZgsGkUwX29htkFTR3BvGc4HLUirXfs6YSJ6IXs_cdWkWmhbUyBagVP1a&s=10',
        mapUrl:
            'https://maps.app.goo.gl/819HBpZKGfdhzXQQ8',
      ),
      _food(
        loc,
        title: 'Medan Selera Presint 9',
        image:
            'https://tourism.ppj.gov.my/storage/destination_images/jpeg/Food_court_precinct9.jpeg',
        mapUrl:
            'https://maps.app.goo.gl/59WYvFkaB797Ms228',
      ),
      _food(
        loc,
        title: 'Wok & Roll Thai Cuisine',
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQmwWMqBkhGkcOxEmMXwUj5L-RrvzaNxE8zPxDEUYVFyAnkd8sN56vWot4&s=10',
        mapUrl:
            'https://maps.app.goo.gl/TMYYjkzcinZ73U3a6',
      ),
      _food(
        loc,
        title: 'Kasbin Putrajaya',
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS0GhFcU9cg_GrtdRPFsRdQ1mtJBd1jxDu3PqGVmfrLEPR1to63DXn6kSaS&s=10',
        mapUrl:
            'https://maps.app.goo.gl/EKcTBuMdQjnp2Rsa6',
      ),
      _food(
        loc,
        title: 'Makan Kitchen',
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSgTKgmP1RXU7Cc03V2LcHzjJooyKTGjL2nxPHuNz5qOrr5jtDsqzqEw7OR&s=10',
        mapUrl:
            'https://maps.app.goo.gl/KaoQFYQvi6gt9cdp9',
      ),
      _food(
        loc,
        title: 'Padi House Galeria PJH',
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSvd0FWy7xtNVbkczjU3t2cdLsOAoxkDWKfYZwN-XeAhMPwQpFrzSTHE4g&s=10',
        mapUrl:
            'https://maps.app.goo.gl/Q6RncZFe1wFBFV2V9',
      ),
      _food(
        loc,
        title: 'Nelayan Kitchen',
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR--OrziNFruGhvzo_B-9D0i_UK6S6jzo9Ya6kJwoG-GaTECizHe8Olz-M&s=10',
        mapUrl:
            'https://maps.app.goo.gl/iq45j913fKTiA2Vm9',
      ),
      _food(
        loc,
        title: 'Ekues Cabin Cafe',
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQKjYBHnqsO_2nj3_p1aZYIxo3pyRcj2399TNPMwCHimMGW1amppUJ2ODIj&s=10',
        mapUrl:
            'https://maps.app.goo.gl/Hq8crequFf9ByJH29',
      ),
      _food(
        loc,
        title: '10GRAM AYER8 PUTRAJAYA',
        image:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQqDhVBI1A4H2dejGpOzzbdtIoUsfEsnP0LZQ4IcijsGW1hqnIAR90XBAsX&s=10',
        mapUrl:
            'https://maps.app.goo.gl/4SN9sBxQ7AcUCdFt8',
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
                                  loc
                                      .putrajayaExplorationTitle,
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
                              label: loc
                                  .putrajayaTabHistorical,
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
                              label: loc
                                  .putrajayaTabInteresting,
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
                                  loc.putrajayaTabEating,
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
                              text: loc
                                  .putrajayaNoPlaces,
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
  // CREATE INTERESTING PLACE
  // ==========================================================================
  ExplorationItem _interesting(
    AppLocalizations loc, {
    required String title,
    required String image,
    required String mapUrl,
  }) {
    return ExplorationItem(
      image: image,
      title: title,
      date: _updatedDate,
      description:
          loc.putrajayaInterestingDesc(
        title,
      ),
      fullExplanation:
          loc.putrajayaInterestingFull(
        title,
      ),
      mapUrl: mapUrl,
    );
  }

  // ==========================================================================
  // CREATE HISTORICAL PLACE
  // ==========================================================================
  ExplorationItem _historical(
    AppLocalizations loc, {
    required String title,
    required String image,
    required String mapUrl,
  }) {
    return ExplorationItem(
      image: image,
      title: title,
      date: _updatedDate,
      description:
          loc.putrajayaHistoricalDesc(
        title,
      ),
      fullExplanation:
          loc.putrajayaHistoricalFull(
        title,
      ),
      mapUrl: mapUrl,
    );
  }

  // ==========================================================================
  // CREATE FOOD PLACE
  // ==========================================================================
  ExplorationItem _food(
    AppLocalizations loc, {
    required String title,
    required String image,
    required String mapUrl,
  }) {
    return ExplorationItem(
      image: image,
      title: title,
      date: _updatedDate,
      description:
          loc.putrajayaFoodDesc(
        title,
      ),
      fullExplanation:
          loc.putrajayaFoodFull(
        title,
      ),
      mapUrl: mapUrl,
    );
  }

  // ==========================================================================
  // SELECTED CATEGORY TITLE
  // ==========================================================================
  String _selectedCategoryTitle(
    AppLocalizations loc,
  ) {
    switch (selectedTab) {
      case 0:
        return loc.putrajayaTabHistorical;

      case 1:
        return loc.putrajayaTabInteresting;

      case 2:
        return loc.putrajayaTabEating;

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
                'Putrajaya exploration details',
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