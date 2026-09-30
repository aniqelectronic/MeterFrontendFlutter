import 'package:flutter/material.dart';



import 'package:frontend_v1/l10n/app_localizations.dart';

import 'package:frontend_v1/pages/data.dart';

import 'package:frontend_v1/pages/option/pbil3.dart';



import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_network_status_service.dart';



import 'package:frontend_v1/widgets/kiosk_back_button.dart';

import 'package:frontend_v1/pages/bil/gamecredits/pgamecredits4.dart';



enum GameCreditStatus {

  loading,

  healthy,

  interruption,

  unavailable,

}



class _GameCreditProduct {

  final String code;

  final String name;

  final String imageUrl;

  final String processingTime;

  final String note;



  const _GameCreditProduct({

    required this.code,

    required this.name,

    required this.imageUrl,

    required this.processingTime,

    required this.note,

  });

}



class PGAMECREDITS3PAGE extends StatefulWidget {

  const PGAMECREDITS3PAGE({

    super.key,

  });



  @override

  State<PGAMECREDITS3PAGE> createState() =>

      _PGAMECREDITS3PAGEState();

}



class _PGAMECREDITS3PAGEState

    extends State<PGAMECREDITS3PAGE> {

  final List<_GameCreditProduct> _products = [];



  bool _catalogLoading = true;

  String? _catalogError;



  final Map<String, GameCreditStatus> _statuses = {};

  final Map<String, String?> _lastUpdated = {};



  final ScrollController _scrollController =

      ScrollController();



  bool showScrollUp = false;

  bool showScrollDown = false;

  String _searchQuery = '';



  static const List<Color> _accentColors = [

    Color(0xFF009688),

    Color(0xFF7356D8),

    Color(0xFFE56B21),

    Color(0xFFD64D8B),

    Color(0xFF1469E8),

    Color(0xFF15946B),

  ];



  static const List<Color> _lightAccentColors = [

    Color(0xFFE0F5F2),

    Color(0xFFEDE9FF),

    Color(0xFFFFECDD),

    Color(0xFFFFE6F2),

    Color(0xFFE3F0FF),

    Color(0xFFE2F7EF),

  ];



  @override

  void initState() {

    super.initState();



    _scrollController.addListener(_handleScroll);



    WidgetsBinding.instance.addPostFrameCallback((_) {

      _loadCatalog();

    });

  }



  Future<void> _loadCatalog() async {

    if (mounted) {

      setState(() {

        _catalogLoading = true;

        _catalogError = null;



        showScrollUp = false;

        showScrollDown = false;

      });

    }



    try {

      final Map<String, dynamic> catalog =

          await IimmpactCatalogService.getCatalog();



      // ================================================================

      // TREE

      // ================================================================



      final dynamic treeRaw = catalog['tree'];



      if (treeRaw is! Map) {

        throw Exception(

          'Catalog tree not found.',

        );

      }



      final Map<String, dynamic> tree =

          Map<String, dynamic>.from(

        treeRaw,

      );



      // ================================================================

      // GROUPS

      // ================================================================



      final dynamic groupsRaw = tree['groups'];



      if (groupsRaw is! List) {

        throw Exception(

          'Catalog groups not found.',

        );

      }



      // ================================================================

      // FIND GAME_CREDITS

      // ================================================================



      final List<String> gameCreditCodes = [];



      for (final dynamic groupRaw in groupsRaw) {

        if (groupRaw is! Map) {

          continue;

        }



        final Map<String, dynamic> group =

            Map<String, dynamic>.from(

          groupRaw,

        );



        final String groupId =

            group['id']

                    ?.toString()

                    .trim()

                    .toUpperCase() ??

                '';



        // Only look inside GAMES group

        if (groupId != 'GAMES') {

          continue;

        }



        final dynamic categoriesRaw =

            group['categories'];



        if (categoriesRaw is! List) {

          continue;

        }



        for (final dynamic categoryRaw

            in categoriesRaw) {

          if (categoryRaw is! Map) {

            continue;

          }



          final Map<String, dynamic> category =

              Map<String, dynamic>.from(

            categoryRaw,

          );



          final String categoryId =

              category['id']

                      ?.toString()

                      .trim()

                      .toUpperCase() ??

                  '';



          if (categoryId != 'GAME_CREDITS') {

            continue;

          }



          final dynamic productCodesRaw =

              category['product_codes'];



          if (productCodesRaw is! List) {

            continue;

          }



          for (final dynamic rawCode

              in productCodesRaw) {

            final String code =

                rawCode

                        ?.toString()

                        .trim()

                        .toUpperCase() ??

                    '';



            if (code.isEmpty) {

              continue;

            }



            if (!gameCreditCodes.contains(code)) {

              gameCreditCodes.add(code);

            }

          }

        }

      }



      // ================================================================

      // PRODUCTS

      // ================================================================



      final dynamic productsRaw =

          catalog['products'];



      if (productsRaw is! Map) {

        throw Exception(

          'Catalog products not found.',

        );

      }



      final Map<String, dynamic> products =

          Map<String, dynamic>.from(

        productsRaw,

      );



      // ================================================================

      // BUILD ACTIVE PRODUCTS

      // ================================================================



      final List<_GameCreditProduct> loadedProducts = [];



      for (final String code in gameCreditCodes) {

        final dynamic rawProduct =

            products[code];



        if (rawProduct is! Map) {

          debugPrint(

            'Game Credit catalog product not found: $code',

          );



          continue;

        }



        final Map<String, dynamic> product =

            Map<String, dynamic>.from(

          rawProduct,

        );



        // ==============================================================

        // ACTIVE FILTER

        // ==============================================================



        if (product['is_active'] != true) {

          debugPrint(

            'Game Credit product inactive: $code',

          );



          continue;

        }



        final String productCode =

            product['code']

                    ?.toString()

                    .trim()

                    .toUpperCase() ??

                code;



        final String productName =

            product['name']

                    ?.toString()

                    .trim() ??

                productCode;



        final String imageUrl =

            product['image_url']

                    ?.toString()

                    .trim() ??

                '';



        final String processingTime =

            product['processing_time']

                    ?.toString()

                    .trim() ??

                '';



        final String note =

            product['note']

                    ?.toString()

                    .trim() ??

                '';



        loadedProducts.add(

          _GameCreditProduct(

            code: productCode,

            name: productName,

            imageUrl: imageUrl,

            processingTime: processingTime,

            note: note,

          ),

        );

      }



      if (!mounted) {

        return;

      }



      setState(() {

        _products

          ..clear()

          ..addAll(loadedProducts);



        _statuses.clear();

        _lastUpdated.clear();



        for (final _GameCreditProduct product

            in loadedProducts) {

          _statuses[product.code] =

              GameCreditStatus.loading;

        }



        _catalogLoading = false;

        _catalogError = null;

      });



      debugPrint('');

      debugPrint(

        '========================================',

      );

      debugPrint(

        'GAME CREDITS CATALOG LOADED',

      );

      debugPrint(

        '========================================',

      );

      debugPrint(

        'Products: '

        '${_products.map((e) => e.code).toList()}',

      );

      debugPrint(

        '========================================',

      );

      debugPrint('');



      await _loadNetworkStatuses();



      if (!mounted) {

        return;

      }



      WidgetsBinding.instance.addPostFrameCallback((_) {

        _handleScroll();

      });

    } on IimmpactCatalogException catch (error) {

      debugPrint(

        'Game Credits catalog error: ${error.message}',

      );



      if (!mounted) {

        return;

      }



      setState(() {

        _products.clear();

        _statuses.clear();

        _lastUpdated.clear();



        _catalogLoading = false;

        _catalogError = error.message;



        showScrollUp = false;

        showScrollDown = false;

      });

    } catch (error, stackTrace) {

      debugPrint(

        'Unexpected Game Credits catalog error: $error',

      );



      debugPrintStack(

        stackTrace: stackTrace,

      );



      if (!mounted) {

        return;

      }



      setState(() {

        _products.clear();

        _statuses.clear();

        _lastUpdated.clear();



        _catalogLoading = false;

        _catalogError = error.toString();



        showScrollUp = false;

        showScrollDown = false;

      });

    }

  }



  Future<void> _loadNetworkStatuses() async {

    if (_products.isEmpty) {

      return;

    }



    await Future.wait(

      _products.map(

        (_GameCreditProduct product) {

          return _refreshNetworkStatus(

            product.code,

          );

        },

      ),

    );

  }



  Future<GameCreditStatus> _refreshNetworkStatus(

    String productCode,

  ) async {

    if (mounted) {

      setState(() {

        _statuses[productCode] =

            GameCreditStatus.loading;

      });

    }



    try {

      final result =

          await IimmpactNetworkStatusService.getStatus(

        productCode: productCode,

      );



      final GameCreditStatus status =

          result.isHealthy

              ? GameCreditStatus.healthy

              : GameCreditStatus.interruption;



      if (mounted) {

        setState(() {

          _statuses[productCode] = status;

          _lastUpdated[productCode] =

              result.lastUpdated;

        });

      }



      return status;

    } catch (error) {

      debugPrint(

        'Game Credit network status error '

        'for $productCode: $error',

      );



      if (mounted) {

        setState(() {

          _statuses[productCode] =

              GameCreditStatus.unavailable;

        });

      }



      return GameCreditStatus.unavailable;

    }

  }



  Future<bool> _showInterruptionWarning({

    required String productName,

    required String productCode,

  }) async {

    final loc =

        AppLocalizations.of(context)!;



    final bool? result =

        await showDialog<bool>(

      context: context,

      barrierDismissible: false,

      builder: (

        BuildContext dialogContext,

      ) {

        return Dialog(

          backgroundColor: Colors.transparent,

          insetPadding:

              const EdgeInsets.symmetric(

            horizontal: 80,

          ),

          child: Container(

            width: 800,

            padding:

                const EdgeInsets.fromLTRB(

              45,

              42,

              45,

              38,

            ),

            decoration: BoxDecoration(

              color: Colors.white,

              borderRadius:

                  BorderRadius.circular(38),

              border: Border.all(

                color:

                    const Color(0xFFF2A520),

                width: 3,

              ),

              boxShadow: [

                BoxShadow(

                  color:

                      Colors.black.withOpacity(

                    0.25,

                  ),

                  blurRadius: 35,

                  offset:

                      const Offset(0, 18),

                ),

              ],

            ),

            child: Column(

              mainAxisSize:

                  MainAxisSize.min,

              children: [

                Container(

                  width: 125,

                  height: 125,

                  decoration: BoxDecoration(

                    color:

                        const Color(0xFFFFF2D9),

                    shape:

                        BoxShape.circle,

                  ),

                  child: const Icon(

                    Icons.warning_amber_rounded,

                    color:

                        Color(0xFFD87900),

                    size: 78,

                  ),

                ),



                const SizedBox(height: 28),



                Text(

                  loc.networkInterruptionTitle,

                  textAlign:

                      TextAlign.center,

                  style:

                      const TextStyle(

                    color:

                        Color(0xFF17283E),

                    fontSize: 40,

                    fontWeight:

                        FontWeight.w900,

                  ),

                ),



                const SizedBox(height: 24),



                Container(

                  width: double.infinity,

                  padding:

                      const EdgeInsets.all(25),

                  decoration: BoxDecoration(

                    color:

                        const Color(0xFFFFF9ED),

                    borderRadius:

                        BorderRadius.circular(24),

                  ),

                  child: Text(

                    loc.networkInterruptionMessage(

                      productName,

                    ),

                    textAlign:

                        TextAlign.center,

                    style:

                        const TextStyle(

                      color:

                          Color(0xFF4B4234),

                      fontSize: 29,

                      height: 1.4,

                      fontWeight:

                          FontWeight.w600,

                    ),

                  ),

                ),



                if (_lastUpdated[

                        productCode] !=

                    null) ...[

                  const SizedBox(height: 20),

                  Text(

                    '${loc.networkLastUpdated}: '

                    '${_lastUpdated[productCode]}',

                    style:

                        const TextStyle(

                      fontSize: 21,

                      color:

                          Color(0xFF758399),

                      fontWeight:

                          FontWeight.w600,

                    ),

                  ),

                ],



                const SizedBox(height: 36),



                Row(

                  children: [

                    Expanded(

                      child: SizedBox(

                        height: 78,

                        child:

                            OutlinedButton(

                          onPressed: () {

                            Navigator.pop(

                              dialogContext,

                              false,

                            );

                          },

                          child: Text(

                            loc.backButton,

                            style:

                                const TextStyle(

                              fontSize: 24,

                              fontWeight:

                                  FontWeight.w900,

                            ),

                          ),

                        ),

                      ),

                    ),



                    const SizedBox(width: 22),



                    Expanded(

                      child: SizedBox(

                        height: 78,

                        child:

                            ElevatedButton(

                          onPressed: () {

                            Navigator.pop(

                              dialogContext,

                              true,

                            );

                          },

                          style:

                              ElevatedButton.styleFrom(

                            backgroundColor:

                                const Color(

                              0xFF168A50,

                            ),

                            foregroundColor:

                                Colors.white,

                          ),

                          child: Text(

                            loc.continueButton,

                            style:

                                const TextStyle(

                              fontSize: 24,

                              fontWeight:

                                  FontWeight.w900,

                            ),

                          ),

                        ),

                      ),

                    ),

                  ],

                ),

              ],

            ),

          ),

        );

      },

    );



    return result ?? false;

  }



  Future<void> _handleProductTap(

    _GameCreditProduct product,

  ) async {

    final GameCreditStatus status =

        await _refreshNetworkStatus(

      product.code,

    );



    if (!mounted) {

      return;

    }



    if (status ==

        GameCreditStatus.interruption) {

      final bool continuePurchase =

          await _showInterruptionWarning(

        productName: product.name,

        productCode: product.code,

      );



      if (!continuePurchase) {

        return;

      }

    }



    if (!mounted) {

      return;

    }



    if (status ==

        GameCreditStatus.unavailable) {

      final loc =

          AppLocalizations.of(context)!;



      await showDialog<void>(

        context: context,

        builder: (

          BuildContext dialogContext,

        ) {

          return AlertDialog(

            title: Text(

              loc.alertTitle,

            ),

            content: Text(

              loc.networkUnavailableMessage(

                product.name,

              ),

            ),

            actions: [

              TextButton(

                onPressed: () {

                  Navigator.pop(

                    dialogContext,

                  );

                },

                child: Text(

                  loc.electricOk,

                ),

              ),

            ],

          );

        },

      );



      return;

    }



    await Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>

            PGAMECREDITS4PAGE(

          productCode:

              product.code,

          productName:

              product.name,

          imageUrl:

              product.imageUrl,

        ),

      ),

    );

  }



  List<_GameCreditProduct> get _filteredProducts {
    final String query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return _products;
    }

    return _products.where(
      (_GameCreditProduct product) {
        return product.name.toLowerCase().contains(query) ||
            product.code.toLowerCase().contains(query);
      },
    ).toList();
  }

  void _applySearchQuery(
    String value,
  ) {
    setState(() {
      _searchQuery = value.trim();
      showScrollUp = false;
      showScrollDown = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }

      _handleScroll();
    });
  }

  Future<void> _openSearchKeyboard(
    AppLocalizations loc,
  ) async {
    String draft = _searchQuery;

    const List<List<String>> keyboardRows = [
      [
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9',
        '0',
      ],
      [
        'Q',
        'W',
        'E',
        'R',
        'T',
        'Y',
        'U',
        'I',
        'O',
        'P',
      ],
      [
        'A',
        'S',
        'D',
        'F',
        'G',
        'H',
        'J',
        'K',
        'L',
      ],
      [
        'Z',
        'X',
        'C',
        'V',
        'B',
        'N',
        'M',
      ],
    ];

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (
        BuildContext dialogContext,
      ) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            StateSetter setDialogState,
          ) {
            void addCharacter(
              String value,
            ) {
              setDialogState(() {
                draft += value;
              });
            }

            void backspace() {
              if (draft.isEmpty) {
                return;
              }

              setDialogState(() {
                draft = draft.substring(
                  0,
                  draft.length - 1,
                );
              });
            }

            void clearAll() {
              setDialogState(() {
                draft = '';
              });
            }

            return Dialog(
              backgroundColor:
                  Colors.transparent,
              insetPadding:
                  const EdgeInsets.symmetric(
                horizontal: 80,
                vertical: 24,
              ),
              child: Container(
                width: 1000,
                height: 920,
                padding:
                    const EdgeInsets.fromLTRB(
                  16,
                  24,
                  16,
                  24,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    34,
                  ),
                  border:
                      Border.all(
                    color:
                        const Color(
                      0xFFBFE4DF,
                    ),
                    width:
                        2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(
                        0.24,
                      ),
                      blurRadius:
                          38,
                      offset:
                          const Offset(
                        0,
                        18,
                      ),
                    ),
                  ],
                ),
                child:
                    SingleChildScrollView(
                  child:
                      Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width:
                                70,
                            height:
                                70,
                            decoration:
                                const BoxDecoration(
                              gradient:
                                  LinearGradient(
                                begin:
                                    Alignment.topLeft,
                                end:
                                    Alignment.bottomRight,
                                colors: [
                                  Color(
                                    0xFF00695C,
                                  ),
                                  Color(
                                    0xFF26A69A,
                                  ),
                                ],
                              ),
                              shape:
                                  BoxShape.circle,
                            ),
                            child:
                                const Icon(
                              Icons.search_rounded,
                              color:
                                  Colors.white,
                              size:
                                  38,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.providerSearchTitle.toUpperCase(),
                                  style:
                                      const TextStyle(
                                    color:
                                        Color(
                                      0xFF122C4C,
                                    ),
                                    fontSize:
                                        39,
                                    fontWeight:
                                        FontWeight.w900,
                                    height:
                                        1.1,
                                  ),
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                // Text(
                                //   loc.providerSearchHint,
                                //   style:
                                //       const TextStyle(
                                //     color:
                                //         Color(
                                //       0xFF67788D,
                                //     ),
                                //     fontSize:
                                //         28,
                                //     fontWeight:
                                //         FontWeight.w600,
                                //     height:
                                //         1.25,
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Container(
                        width:
                            double.infinity,
                        constraints:
                            const BoxConstraints(
                          minHeight:
                              104,
                        ),
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal:
                              24,
                          vertical:
                              18,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFFF5FAFA,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            24,
                          ),
                          border:
                              Border.all(
                            color:
                                const Color(
                              0xFF8FCFC7,
                            ),
                            width:
                                2,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              color:
                                  Color(
                                0xFF00796B,
                              ),
                              size:
                                  32,
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  draft.isEmpty
                                      ? loc.providerSearchHint
                                      : draft,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: draft.isEmpty
                                        ? const Color(0xFF8292A5)
                                        : const Color(0xFF15253A),
                                    fontSize: 35,
                                    fontWeight: FontWeight.w800,
                                    height: 1.2,
                                  ),
                                ),
                              ),

                              // Show cursor ONLY when user has typed something
                              if (draft.isNotEmpty) ...[
                                const SizedBox(width: 1),
                                Container(
                                  width: 3,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF009688),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 22,
                      ),
                      ...keyboardRows.map(
                        (
                          List<String> row,
                        ) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(
                              bottom:
                                  12,
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                for (
                                  int index = 0;
                                  index <
                                      row.length;
                                  index++
                                ) ...[
                                  _SearchKeyboardKey(
                                    label:
                                        row[index],
                                    onTap:
                                        () {
                                      addCharacter(
                                        row[index],
                                      );
                                    },
                                  ),
                                  if (
                                    index <
                                        row.length -
                                            1
                                  )
                                    const SizedBox(
                                      width: 8,
                                    ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child:
                                _SearchUtilityButton(
                              icon:
                                  Icons
                                      .space_bar_rounded,
                              label:
                                  '',
                              onTap:
                                  () {
                                addCharacter(
                                  ' ',
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            flex: 3,
                            child:
                                _SearchUtilityButton(
                              icon:
                                  Icons
                                      .backspace_outlined,
                              label:
                                  loc.keyboardBackspace,
                              onTap:
                                  backspace,
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            flex: 3,
                            child:
                                _SearchUtilityButton(
                              icon:
                                  Icons
                                      .delete_sweep_outlined,
                              label:
                                  loc.keyboardClearAll,
                              onTap:
                                  clearAll,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child:
                                SizedBox(
                              height:
                                  92,
                              child:
                                  OutlinedButton.icon(
                                onPressed:
                                    () {
                                  Navigator.pop(
                                    dialogContext,
                                  );
                                },
                                icon:
                                    const Icon(
                                  Icons.close_rounded,
                                  size:
                                      34,
                                ),
                                label:
                                    Text(
                                  loc.close
                                      .toUpperCase(),
                                  style:
                                      const TextStyle(
                                    fontSize:
                                        29,
                                    fontWeight:
                                        FontWeight.w900,
                                  ),
                                ),
                                style:
                                    OutlinedButton.styleFrom(
                                  foregroundColor:
                                      const Color(
                                    0xFF31445A,
                                  ),
                                  side:
                                      const BorderSide(
                                    color:
                                        Color(
                                      0xFFBBC8D6,
                                    ),
                                    width:
                                        2,
                                  ),
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                      20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 18,
                          ),
                          Expanded(
                            child:
                                SizedBox(
                              height:
                                  92,
                              child:
                                  ElevatedButton.icon(
                                onPressed:
                                    () {
                                  Navigator.pop(
                                    dialogContext,
                                  );

                                  _applySearchQuery(
                                    draft,
                                  );
                                },
                                icon:
                                    const Icon(
                                  Icons.search_rounded,
                                  size:
                                      34,
                                ),
                                label:
                                    Text(
                                  loc.providerSearchButton
                                      .toUpperCase(),
                                  style:
                                      const TextStyle(
                                    fontSize:
                                        29,
                                    fontWeight:
                                        FontWeight.w900,
                                  ),
                                ),
                                style:
                                    ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(
                                    0xFF00897B,
                                  ),
                                  foregroundColor:
                                      Colors.white,
                                  elevation:
                                      0,
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                      20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchBar(
    AppLocalizations loc,
  ) {
    final bool hasSearch =
        _searchQuery.trim().isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _openSearchKeyboard(
            loc,
          );
        },
        borderRadius:
            BorderRadius.circular(
          28,
        ),
        child: Container(
          width:
              double.infinity,
          constraints:
              const BoxConstraints(
            minHeight: 116,
          ),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          decoration:
              BoxDecoration(
            color:
                Colors.white.withOpacity(
              0.97,
            ),
            borderRadius:
                BorderRadius.circular(
              28,
            ),
            border:
                Border.all(
              color:
                  hasSearch
                      ? const Color(
                          0xFF009688,
                        )
                      : const Color(
                          0xFFC7D8E5,
                        ),
              width:
                  hasSearch
                      ? 2.5
                      : 2,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    const Color(
                  0xFF173B66,
                ).withOpacity(
                  0.11,
                ),
                blurRadius:
                    20,
                offset:
                    const Offset(
                  0,
                  8,
                ),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width:
                    70,
                height:
                    70,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFE0F5F2,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),
                child:
                    const Icon(
                  Icons.search_rounded,
                  color:
                      Color(
                    0xFF00796B,
                  ),
                  size:
                      34,
                ),
              ),
              const SizedBox(
                width: 18,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text(
                      hasSearch
                          ? _searchQuery
                          : loc.providerSearchTitle.toUpperCase(),
                      maxLines:
                          1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          TextStyle(
                        color:
                            hasSearch
                                ? const Color(
                                    0xFF15253A,
                                  )
                                : const Color(
                                    0xFF697B90,
                                  ),
                        fontSize:
                            30,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasSearch) ...[
                const SizedBox(
                  width: 12,
                ),
                Material(
                  color:
                      const Color(
                    0xFFF0F3F7,
                  ),
                  shape:
                      const CircleBorder(),
                  child: InkWell(
                    onTap: () {
                      _applySearchQuery(
                        '',
                      );
                    },
                    customBorder:
                        const CircleBorder(),
                    child:
                        const SizedBox(
                      width:
                          52,
                      height:
                          52,
                      child:
                          Icon(
                        Icons.close_rounded,
                        color:
                            Color(
                          0xFF596A7F,
                        ),
                        size:
                            28,
                      ),
                    ),
                  ),
                ),
              ] else
                const Icon(
                  Icons
                      .keyboard_arrow_right_rounded,
                  color:
                      Color(
                    0xFF6E8094,
                  ),
                  size:
                      36,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleScroll() {

    if (!_scrollController.hasClients ||

        !mounted ||

        _catalogLoading) {

      return;

    }



    final double maxScroll =

        _scrollController

            .position

            .maxScrollExtent;



    final double currentScroll =

        _scrollController.offset;



    final bool shouldShowScrollUp =

        currentScroll > 10;



    final bool shouldShowScrollDown =

        maxScroll > 10 &&

        currentScroll <

            maxScroll - 10;



    if (showScrollUp !=

            shouldShowScrollUp ||

        showScrollDown !=

            shouldShowScrollDown) {

      setState(() {

        showScrollUp =

            shouldShowScrollUp;



        showScrollDown =

            shouldShowScrollDown;

      });

    }

  }



  void _scrollUp() {

    if (!_scrollController.hasClients) {

      return;

    }



    final double destination =

        (_scrollController.offset - 600)

            .clamp(

      0.0,

      _scrollController

          .position

          .maxScrollExtent,

    );



    _scrollController.animateTo(

      destination,

      duration:

          const Duration(milliseconds: 400),

      curve: Curves.easeOut,

    );

  }



  void _scrollDown() {

    if (!_scrollController.hasClients) {

      return;

    }



    final double destination =

        (_scrollController.offset + 600)

            .clamp(

      0.0,

      _scrollController

          .position

          .maxScrollExtent,

    );



    _scrollController.animateTo(

      destination,

      duration:

          const Duration(milliseconds: 400),

      curve: Curves.easeOut,

    );

  }
  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 550), curve: Curves.easeOutCubic);
  }

  Widget _buildScrollAction(AppLocalizations loc) {
    if (!showScrollUp && showScrollDown) return _ScrollDiscoveryControl(key: const ValueKey('top-more'), mode: _ScrollControlMode.more, label: loc.scrollViewMore, onPressed: _scrollDown);
    if (showScrollUp && showScrollDown) return Row(key: const ValueKey('middle-controls'), mainAxisSize: MainAxisSize.min, children: [_ScrollDiscoveryControl(mode: _ScrollControlMode.up, label: loc.scrollUpShort, onPressed: _scrollUp), const SizedBox(width: 22), _ScrollDiscoveryControl(mode: _ScrollControlMode.more, label: loc.scrollViewMore, onPressed: _scrollDown)]);
    if (showScrollUp && !showScrollDown) return _ScrollDiscoveryControl(key: const ValueKey('bottom-top'), mode: _ScrollControlMode.top, label: loc.scrollBackTop, onPressed: _scrollToTop);
    return const SizedBox.shrink();
  }




  @override

  void dispose() {

    _scrollController.removeListener(

      _handleScroll,

    );



    _scrollController.dispose();



    super.dispose();

  }



  @override

  Widget build(

    BuildContext context,

  ) {

    final loc =

        AppLocalizations.of(context)!;



    return Scaffold(

      body: Stack(

        children: [

          Positioned.fill(

            child: Image.asset(

              'lib/images/pnew.png',

              fit: BoxFit.cover,

            ),

          ),



          Positioned.fill(

            child: Container(

              decoration: BoxDecoration(

                gradient: LinearGradient(

                  begin:

                      Alignment.topCenter,

                  end:

                      Alignment.bottomCenter,

                  colors: [

                    Colors.white.withOpacity(

                      0.02,

                    ),

                    Colors.white.withOpacity(

                      0.12,

                    ),

                    Colors.white.withOpacity(

                      0.04,

                    ),

                  ],

                ),

              ),

            ),

          ),



          Positioned(

            top: 82,

            left: 65,

            right: 65,

            child:

                _GameCreditHeader(

              title:

                  loc.gameCreditsPageTitle,

              subtitle:

                  loc.gameCreditsPageSubtitle,

            ),

          ),



          Positioned(

            top: 325,

            left: 45,

            right: 45,

            bottom: 305,

            child:

                _buildProviderArea(

              loc,

            ),

          ),



          if (!_catalogLoading && _catalogError == null && _filteredProducts.isNotEmpty && showScrollDown)
            Positioned(left: 35, right: 35, bottom: 270, height: 175, child: IgnorePointer(child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: const [0.0, 0.30, 0.68, 1.0], colors: [Colors.white.withOpacity(0.00), Colors.white.withOpacity(0.14), Colors.white.withOpacity(0.62), Colors.white.withOpacity(0.95)]))))),

          if (!_catalogLoading && _catalogError == null && _filteredProducts.isNotEmpty)
            Positioned(left: 0, right: 0, bottom: 270, child: Center(child: AnimatedSwitcher(duration: const Duration(milliseconds: 250), switchInCurve: Curves.easeOutCubic, switchOutCurve: Curves.easeInCubic, child: _buildScrollAction(loc)))),

          Positioned(

            bottom: 105,

            left: 300,

            right: 300,

            child:

                KioskBackButton(

              onPressed: () {

                Navigator.pushReplacement(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>

                        const PBIL3PAGE(),

                  ),

                );

              },

            ),

          ),



          Positioned(

            bottom: 25,

            left: 0,

            right: 0,

            child: Center(

              child: Text(

                Data.copyrightText,

                textAlign:

                    TextAlign.center,

                style:

                    const TextStyle(

                  color:

                      Color(0xFF26364A),

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



  Widget _buildProviderArea(

    AppLocalizations loc,

  ) {

    if (_catalogLoading) {

      return _buildLoading(

        loc,

      );

    }



    if (_catalogError != null) {

      return Center(

        child: Container(

          width: 680,

          padding:

              const EdgeInsets.all(42),

          decoration: BoxDecoration(

            color:

                Colors.white.withOpacity(

              0.97,

            ),

            borderRadius:

                BorderRadius.circular(35),

            border: Border.all(

              color:

                  const Color(0xFFE57373),

              width: 2,

            ),

          ),

          child: Column(

            mainAxisSize:

                MainAxisSize.min,

            children: [

              const Icon(

                Icons.cloud_off_rounded,

                color:

                    Color(0xFFD32F2F),

                size: 85,

              ),



              const SizedBox(height: 25),



              Text(

                loc.providerLoadError,

                textAlign:

                    TextAlign.center,

                style:

                    const TextStyle(

                  color:

                      Color(0xFF17283E),

                  fontSize: 35,

                  fontWeight:

                      FontWeight.w900,

                ),

              ),



              const SizedBox(height: 14),



              Text(

                loc.providerLoadErrorSubtitle,

                textAlign:

                    TextAlign.center,

                style:

                    const TextStyle(

                  color:

                      Color(0xFF657386),

                  fontSize: 24,

                  fontWeight:

                      FontWeight.w600,

                ),

              ),



              const SizedBox(height: 30),



              SizedBox(

                width: double.infinity,

                height: 80,

                child:

                    ElevatedButton.icon(

                  onPressed:

                      _loadCatalog,

                  icon:

                      const Icon(

                    Icons.refresh_rounded,

                    size: 30,

                  ),

                  label: Text(

                    loc.retryButton,

                    style:

                        const TextStyle(

                      fontSize: 27,

                      fontWeight:

                          FontWeight.w900,

                    ),

                  ),

                ),

              ),

            ],

          ),

        ),

      );

    }



    if (_products.isEmpty) {

      return Center(

        child: Container(

          width: 680,

          padding:

              const EdgeInsets.all(42),

          decoration: BoxDecoration(

            color:

                Colors.white.withOpacity(

              0.97,

            ),

            borderRadius:

                BorderRadius.circular(35),

          ),

          child: Text(

            loc.gameCreditsNoServices,

            textAlign:

                TextAlign.center,

            style:

                const TextStyle(

              color:

                  Color(0xFF17283E),

              fontSize: 30,

              fontWeight:

                  FontWeight.w900,

            ),

          ),

        ),

      );

    }



    final List<_GameCreditProduct> visibleProducts =
        _filteredProducts;

    return Column(
      children: [
        _buildSearchBar(
          loc,
        ),

        const SizedBox(
          height: 40,
        ),

        Expanded(
          child: visibleProducts.isEmpty
              ? Center(
                  child: Container(
                    width: 650,
                    padding:
                        const EdgeInsets.fromLTRB(
                      34,
                      34,
                      34,
                      32,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.white.withOpacity(
                        0.97,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        30,
                      ),
                      border:
                          Border.all(
                        color:
                            const Color(
                          0xFFBFE4DF,
                        ),
                        width:
                            2,
                      ),
                    ),
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Container(
                          width:
                              90,
                          height:
                              90,
                          decoration:
                              const BoxDecoration(
                            color:
                                Color(
                              0xFFE0F5F2,
                            ),
                            shape:
                                BoxShape.circle,
                          ),
                          child:
                              const Icon(
                            Icons
                                .search_off_rounded,
                            color:
                                Color(
                              0xFF00796B,
                            ),
                            size:
                                50,
                          ),
                        ),
                        const SizedBox(
                          height: 22,
                        ),
                        Text(
                          loc.providerSearchNoResults,
                          textAlign:
                              TextAlign.center,
                          style:
                              const TextStyle(
                            color:
                                Color(
                              0xFF17283E,
                            ),
                            fontSize:
                                28,
                            fontWeight:
                                FontWeight.w900,
                            height:
                                1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Scrollbar(
                  controller:
                      _scrollController,
                  thumbVisibility:
                      true,
                  trackVisibility:
                      true,
                  interactive:
                      true,
                  thickness:
                      11,
                  radius:
                      const Radius.circular(
                    20,
                  ),
                  child:
                      SingleChildScrollView(
                    controller:
                        _scrollController,
                    physics:
                        const BouncingScrollPhysics(),
                    padding:
                        const EdgeInsets.only(
                      right:
                          24,
                      bottom:
                          145,
                    ),
                    child:
                        Column(
                      children: [
                        for (
                          int index = 0;
                          index <
                              visibleProducts.length;
                          index += 2
                        )
                          Padding(
                            padding:
                                EdgeInsets.only(
                              bottom:
                                  index + 2 <
                                          visibleProducts.length
                                      ? 36
                                      : 0,
                            ),
                            child:
                                Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child:
                                      _GameCreditCard(
                                    product:
                                        visibleProducts[index],
                                    status:
                                        _statuses[
                                                visibleProducts[index]
                                                    .code] ??
                                            GameCreditStatus.loading,
                                    accentColor:
                                        _accentColors[
                                          index %
                                              _accentColors.length
                                        ],
                                    lightAccentColor:
                                        _lightAccentColors[
                                          index %
                                              _lightAccentColors.length
                                        ],
                                    onPressed:
                                        () {
                                      _handleProductTap(
                                        visibleProducts[index],
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(
                                  width: 34,
                                ),

                                Expanded(
                                  child:
                                      index + 1 <
                                              visibleProducts.length
                                          ? _GameCreditCard(
                                              product:
                                                  visibleProducts[
                                                    index + 1
                                                  ],
                                              status:
                                                  _statuses[
                                                          visibleProducts[
                                                                  index + 1]
                                                              .code] ??
                                                      GameCreditStatus.loading,
                                              accentColor:
                                                  _accentColors[
                                                    (index + 1) %
                                                        _accentColors.length
                                                  ],
                                              lightAccentColor:
                                                  _lightAccentColors[
                                                    (index + 1) %
                                                        _lightAccentColors.length
                                                  ],
                                              onPressed:
                                                  () {
                                                _handleProductTap(
                                                  visibleProducts[
                                                    index + 1
                                                  ],
                                                );
                                              },
                                            )
                                          : const SizedBox(),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }


  // ============================================================================

// MODERN LOADING

// SAME DESIGN AS IDD

// ============================================================================



Widget _buildLoading(

  AppLocalizations loc,

) {

  const Color color =

      Color(0xFF009688);



  return Column(

    children: [

      // ======================================================================

      // MAIN LOADING CARD

      // ======================================================================



      Container(

        width: double.infinity,

        padding:

            const EdgeInsets.symmetric(

          horizontal: 35,

          vertical: 30,

        ),

        decoration:

            BoxDecoration(

          color:

              Colors.white.withOpacity(

            0.97,

          ),

          borderRadius:

              BorderRadius.circular(

            30,

          ),

          border: Border.all(

            color:

                color.withOpacity(

              0.20,

            ),

            width: 2,

          ),

          boxShadow: [

            BoxShadow(

              color:

                  color.withOpacity(

                0.12,

              ),

              blurRadius: 24,

              offset:

                  const Offset(

                0,

                10,

              ),

            ),

          ],

        ),

        child: Row(

          children: [

            // ================================================================

            // ICON + SPINNER

            // ================================================================



            Container(

              width: 100,

              height: 100,

              decoration:

                  BoxDecoration(

                color:

                    color.withOpacity(

                  0.10,

                ),

                shape:

                    BoxShape.circle,

                border: Border.all(

                  color:

                      color.withOpacity(

                    0.18,

                  ),

                  width: 2,

                ),

              ),

              child: Stack(

                alignment:

                    Alignment.center,

                children: [

                  SizedBox(

                    width: 70,

                    height: 70,

                    child:

                        CircularProgressIndicator(

                      strokeWidth: 5,

                      color: color,

                      backgroundColor:

                          color.withOpacity(

                        0.12,

                      ),

                    ),

                  ),



                  const Icon(

                    Icons

                        .videogame_asset_rounded,

                    color: color,

                    size: 40,

                  ),

                ],

              ),

            ),



            const SizedBox(

              width: 25,

            ),



            // ================================================================

            // TEXT

            // ================================================================



            Expanded(

              child: Column(

                crossAxisAlignment:

                    CrossAxisAlignment.start,

                children: [

                  Text(

                    loc.providerLoading,

                    style:

                        const TextStyle(

                      color:

                          Color(

                        0xFF16324F,

                      ),

                      fontSize: 30,

                      fontWeight:

                          FontWeight.w900,

                      height: 1.15,

                    ),

                  ),



                  const SizedBox(

                    height: 9,

                  ),



                  Text(

                    loc.providerLoadingSubtitle,

                    style:

                        const TextStyle(

                      color:

                          Color(

                        0xFF6A7B90,

                      ),

                      fontSize: 20,

                      fontWeight:

                          FontWeight.w600,

                      height: 1.35,

                    ),

                  ),

                ],

              ),

            ),

          ],

        ),

      ),



      const SizedBox(

        height: 28,

      ),



      // ======================================================================

      // SKELETON PROVIDER CARDS

      // ======================================================================



      Row(

        children: [

          Expanded(

            child:

                _buildLoadingProviderCard(),

          ),



          const SizedBox(

            width: 34,

          ),



          Expanded(

            child:

                _buildLoadingProviderCard(),

          ),

        ],

      ),

    ],

  );

}





  Widget _buildLoadingProviderCard() {

    return Container(

      height: 330,

      padding:

          const EdgeInsets.all(

        27,

      ),

      decoration:

          BoxDecoration(

        color:

            Colors.white.withOpacity(

          0.94,

        ),

        borderRadius:

            BorderRadius.circular(

          34,

        ),

        border: Border.all(

          color:

              const Color(

            0xFFDCE5EF,

          ),

          width: 2,

        ),

        boxShadow: [

          BoxShadow(

            color:

                const Color(

              0xFF009688,

            ).withOpacity(

              0.07,

            ),

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

        crossAxisAlignment:

            CrossAxisAlignment.start,

        children: [

          // LOGO PLACEHOLDER

          Container(

            width: 150,

            height: 115,

            decoration:

                BoxDecoration(

              color:

                  const Color(

                0xFFE9EFF6,

              ),

              borderRadius:

                  BorderRadius.circular(

                24,

              ),

            ),

          ),



          const Spacer(),



          // NAME PLACEHOLDER

          Container(

            width: double.infinity,

            height: 25,

            decoration:

                BoxDecoration(

              color:

                  const Color(

                0xFFE1E8F0,

              ),

              borderRadius:

                  BorderRadius.circular(

                20,

              ),

            ),

          ),



          const SizedBox(

            height: 13,

          ),



          // SMALL TEXT PLACEHOLDER

          Container(

            width: 170,

            height: 20,

            decoration:

                BoxDecoration(

              color:

                  const Color(

                0xFFEDF2F7,

              ),

              borderRadius:

                  BorderRadius.circular(

                20,

              ),

            ),

          ),



          const SizedBox(

            height: 22,

          ),



          // STATUS PLACEHOLDER

          Container(

            width: 185,

            height: 48,

            decoration:

                BoxDecoration(

              color:

                  const Color(

                0xFFE8EEF5,

              ),

              borderRadius:

                  BorderRadius.circular(

                30,

              ),

            ),

          ),

        ],

      ),

    );

  }

}



// ============================================================================

// MODERN + GOVERNMENT GAME CREDITS HEADER

// KEEPS EXISTING BADGE + TITLE + SUBTITLE

// ============================================================================



class _GameCreditHeader extends StatelessWidget {

  final String title;

  final String subtitle;



  const _GameCreditHeader({

    required this.title,

    required this.subtitle,

  });



  @override

  Widget build(BuildContext context) {

    const Color accentColor = Color(0xFF009688);

    const Color darkAccent = Color(0xFF00695C);

    const Color lightAccent = Color(0xFF26A69A);



    return Container(

      padding: const EdgeInsets.fromLTRB(

        30,

        24,

        30,

        24,

      ),

      decoration: BoxDecoration(

        color: Colors.white.withOpacity(0.96),

        borderRadius: BorderRadius.circular(32),

        border: Border.all(

          color: const Color(0xFFD5E4F7),

          width: 2,

        ),

        boxShadow: [

          BoxShadow(

            color: const Color(0xFF173A66).withOpacity(0.14),

            blurRadius: 30,

            offset: const Offset(0, 12),

          ),

        ],

      ),

      child: Row(

        children: [

          // ==========================================================

          // LEFT GAME CREDITS ICON

          // ==========================================================



          Container(

            width: 105,

            height: 105,

            decoration: BoxDecoration(

              gradient: const LinearGradient(

                begin: Alignment.topLeft,

                end: Alignment.bottomRight,

                colors: [

                  darkAccent,

                  lightAccent,

                ],

              ),

              borderRadius: BorderRadius.circular(30),

              boxShadow: [

                BoxShadow(

                  color: accentColor.withOpacity(0.28),

                  blurRadius: 20,

                  offset: const Offset(0, 8),

                ),

              ],

            ),

            child: const Icon(

              Icons.videogame_asset_rounded,

              color: Colors.white,

              size: 56,

            ),

          ),



          const SizedBox(width: 28),



          // ==========================================================

          // EXISTING HEADER INFORMATION

          // ==========================================================



          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                // ------------------------------------------------------

                // EXISTING GAME CREDITS BADGE

                // ------------------------------------------------------



                Container(

                  padding: const EdgeInsets.symmetric(

                    horizontal: 18,

                    vertical: 7,

                  ),

                  decoration: BoxDecoration(

                    color: const Color(0xFFE4F6F3),

                    borderRadius: BorderRadius.circular(100),

                  ),

                  child: const Row(

                    mainAxisSize: MainAxisSize.min,

                    children: [

                      Icon(

                        Icons.videogame_asset_rounded,

                        size: 20,

                        color: accentColor,

                      ),



                      SizedBox(width: 8),



                      Text(

                        'GAME CREDITS',

                        style: TextStyle(

                          color: accentColor,

                          fontSize: 17,

                          fontWeight: FontWeight.w900,

                          letterSpacing: 1.1,

                        ),

                      ),

                    ],

                  ),

                ),



                const SizedBox(height: 12),



                // ------------------------------------------------------

                // EXISTING TITLE

                // ------------------------------------------------------



                Text(

                  title.toUpperCase(),

                  maxLines: 2,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(

                    color: Color(0xFF122C4C),

                    fontSize: 52,

                    fontWeight: FontWeight.w900,

                    height: 1.02,

                    letterSpacing: -0.8,

                  ),

                ),



                const SizedBox(height: 9),



                // ------------------------------------------------------

                // EXISTING SUBTITLE

                // ------------------------------------------------------



                Text(

                  subtitle,

                  maxLines: 2,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(

                    color: Color(0xFF607188),

                    fontSize: 30,

                    fontWeight: FontWeight.w600,

                    height: 1.25,

                  ),

                ),

              ],

            ),

          ),



          const SizedBox(width: 24),



          // ==========================================================

          // RIGHT TEAL ACCENT BAR

          // ==========================================================



          Container(

            width: 8,

            height: 105,

            decoration: BoxDecoration(

              borderRadius: BorderRadius.circular(20),

              gradient: const LinearGradient(

                begin: Alignment.topCenter,

                end: Alignment.bottomCenter,

                colors: [

                  darkAccent,

                  lightAccent,

                ],

              ),

            ),

          ),

        ],

      ),

    );

  }

}



class _GameCreditCard

    extends StatefulWidget {

  final _GameCreditProduct product;

  final GameCreditStatus status;



  final Color accentColor;

  final Color lightAccentColor;



  final VoidCallback onPressed;



  const _GameCreditCard({

    required this.product,

    required this.status,

    required this.accentColor,

    required this.lightAccentColor,

    required this.onPressed,

  });



  @override

  State<_GameCreditCard> createState() =>

      _GameCreditCardState();

}



class _GameCreditCardState

    extends State<_GameCreditCard> {

  bool _pressed = false;



  bool get _enabled =>

      widget.status !=

      GameCreditStatus.unavailable;



  @override

  Widget build(BuildContext context) {

    final loc =

        AppLocalizations.of(context)!;



    return GestureDetector(

      behavior:

          HitTestBehavior.opaque,



      onTapDown:

          _enabled

              ? (_) {

                  setState(() {

                    _pressed = true;

                  });

                }

              : null,



      onTapUp:

          _enabled

              ? (_) {

                  setState(() {

                    _pressed = false;

                  });

                }

              : null,



      onTapCancel:

          _enabled

              ? () {

                  setState(() {

                    _pressed = false;

                  });

                }

              : null,



      onTap:

          _enabled

              ? widget.onPressed

              : null,



      child: AnimatedScale(

        scale:

            _pressed ? 0.965 : 1,

        duration:

            const Duration(

          milliseconds: 130,

        ),

        child: Container(

          height: 500,

          padding:

              const EdgeInsets.all(30),

          decoration: BoxDecoration(

            color:

                Colors.white.withOpacity(

              _enabled ? 0.96 : 0.70,

            ),

            borderRadius:

                BorderRadius.circular(40),

            border: Border.all(

              color:

                  _pressed

                      ? widget.accentColor

                      : Colors.black,

              width:

                  _pressed ? 4 : 3,

            ),

            boxShadow: [

              BoxShadow(

                color:

                    const Color(0xFF19375C)

                        .withOpacity(0.16),

                blurRadius: 30,

                offset:

                    const Offset(0, 15),

              ),

            ],

          ),

          child: Column(

            crossAxisAlignment:

                CrossAxisAlignment.start,

            children: [

              Row(

                mainAxisAlignment:

                    MainAxisAlignment

                        .spaceBetween,

                crossAxisAlignment:

                    CrossAxisAlignment.start,

                children: [

                  Container(

                    width: 220,

                    height: 175,

                    padding:

                        const EdgeInsets.all(24),

                    decoration: BoxDecoration(

                      color: Colors.white,

                      borderRadius:

                          BorderRadius.circular(32),

                      border: Border.all(

                        color:

                            widget.accentColor

                                .withOpacity(

                          0.20,

                        ),

                      ),

                    ),

                    child:

                        _buildLogo(),

                  ),



                  Container(

                    width: 58,

                    height: 58,

                    decoration: BoxDecoration(

                      color:

                          widget.accentColor,

                      shape:

                          BoxShape.circle,

                    ),

                    child:

                        const Icon(

                      Icons

                          .arrow_forward_rounded,

                      color:

                          Colors.white,

                      size: 32,

                    ),

                  ),

                ],

              ),



              const Spacer(),



              Text(

                widget.product.name

                    .toUpperCase(),

                maxLines: 2,

                overflow:

                    TextOverflow.ellipsis,

                style:

                    const TextStyle(

                  color:

                      Color(0xFF15253A),

                  fontSize: 32,

                  fontWeight:

                      FontWeight.w900,

                  height: 1.08,

                ),

              ),



              const SizedBox(height: 18),



              _buildNetworkStatus(loc),



              if (widget

                  .product

                  .processingTime

                  .isNotEmpty) ...[

                const SizedBox(height: 14),



                Row(

                  children: [

                    const Icon(

                      Icons.schedule_rounded,

                      size: 22,

                      color:

                          Color(0xFF647187),

                    ),



                    const SizedBox(width: 8),



                    Expanded(

                      child: Text(

                        '${loc.processingTimeLabel}: '

                        '${_processingTime(

                          context,

                        )}',

                        maxLines: 1,

                        overflow:

                            TextOverflow.ellipsis,

                        style:

                            const TextStyle(

                          color:

                              Color(

                            0xFF647187,

                          ),

                          fontSize: 18,

                          fontWeight:

                              FontWeight.w700,

                        ),

                      ),

                    ),

                  ],

                ),

              ],



              const SizedBox(height: 18),



              Container(

                width: 60,

                height: 7,

                decoration: BoxDecoration(

                  color:

                      widget.accentColor,

                  borderRadius:

                      BorderRadius.circular(50),

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }



  Widget _buildLogo() {

    if (widget

        .product

        .imageUrl

        .isEmpty) {

      return Icon(

        Icons.videogame_asset_rounded,

        size: 90,

        color:

            widget.accentColor,

      );

    }



    return Image.network(

      widget.product.imageUrl,

      fit:

          BoxFit.contain,

      loadingBuilder: (

        context,

        child,

        progress,

      ) {

        if (progress == null) {

          return child;

        }



        return Center(

          child:

              CircularProgressIndicator(

            color:

                widget.accentColor,

          ),

        );

      },

      errorBuilder: (

        context,

        error,

        stackTrace,

      ) {

        return Icon(

          Icons.videogame_asset_rounded,

          size: 90,

          color:

              widget.accentColor,

        );

      },

    );

  }



  Widget _buildNetworkStatus(

    AppLocalizations loc,

  ) {

    String text;

    Color background;

    Color foreground;

    IconData icon;



    switch (widget.status) {

      case GameCreditStatus.loading:

        text =

            loc.networkStatusChecking;

        background =

            const Color(0xFFF0F4F8);

        foreground =

            const Color(0xFF536272);

        icon =

            Icons.sync_rounded;

        break;



      case GameCreditStatus.healthy:

        text =

            loc.networkStatusGood;

        background =

            const Color(0xFFE2F8EC);

        foreground =

            const Color(0xFF08783E);

        icon =

            Icons.check_circle_rounded;

        break;



      case GameCreditStatus.interruption:

        text =

            loc.networkStatusSlow;

        background =

            const Color(0xFFFFF0D7);

        foreground =

            const Color(0xFFB75B00);

        icon =

            Icons.warning_amber_rounded;

        break;



      case GameCreditStatus.unavailable:

        text =

            loc.networkStatusUnknown;

        background =

            const Color(0xFFF1F1F1);

        foreground =

            const Color(0xFF555555);

        icon =

            Icons.help_outline_rounded;

        break;

    }



    return Container(

      padding:

          const EdgeInsets.symmetric(

        horizontal: 15,

        vertical: 11,

      ),

      decoration: BoxDecoration(

        color: background,

        borderRadius:

            BorderRadius.circular(30),

      ),

      child: Row(

        mainAxisSize:

            MainAxisSize.min,

        children: [

          if (widget.status ==

              GameCreditStatus.loading)

            SizedBox(

              width: 22,

              height: 22,

              child:

                  CircularProgressIndicator(

                strokeWidth: 3,

                color: foreground,

              ),

            )

          else

            Icon(

              icon,

              size: 24,

              color: foreground,

            ),



          const SizedBox(width: 8),



          Flexible(

            child: Text(

              '${loc.networkLabel}: $text',

              maxLines: 1,

              overflow:

                  TextOverflow.ellipsis,

              style: TextStyle(

                color: foreground,

                fontSize: 17,

                fontWeight:

                    FontWeight.w900,

              ),

            ),

          ),

        ],

      ),

    );

  }



  String _processingTime(

    BuildContext context,

  ) {

    final loc =

        AppLocalizations.of(context)!;



    switch (widget

        .product

        .processingTime

        .toLowerCase()) {

      case 'instant':

        return loc.processingInstant;



      case '24_hours':

        return loc.processing24Hours;



      case '3_days':

        return loc.processing3Days;



      case 'pin':

        return 'PIN';



      case 'link':

        return 'LINK';



      default:

        return widget

            .product

            .processingTime

            .replaceAll('_', ' ')

            .toUpperCase();

    }

  }

}


class _SearchKeyboardKey extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _SearchKeyboardKey({
    required this.label,
    required this.onTap,
  });

  @override
  State<_SearchKeyboardKey> createState() =>
      _SearchKeyboardKeyState();
}

class _SearchKeyboardKeyState
    extends State<_SearchKeyboardKey> {
  bool _pressed = false;

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onTapDown:
          (_) {
        setState(() {
          _pressed = true;
        });
      },
      onTapUp:
          (_) {
        setState(() {
          _pressed = false;
        });

        widget.onTap();
      },
      onTapCancel:
          () {
        setState(() {
          _pressed = false;
        });
      },
      child:
          AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 100,
        ),
        width: 80,
        height: 90,
        alignment:
            Alignment.center,
        decoration:
            BoxDecoration(
          color:
              _pressed
                  ? const Color(
                      0xFF00796B,
                    )
                  : Colors.white,
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          border:
              Border.all(
            color:
                _pressed
                    ? const Color(
                        0xFF00796B,
                      )
                    : const Color(
                        0xFFB8C8D6,
                      ),
            width:
                2,
          ),
          boxShadow:
              _pressed
                  ? []
                  : [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(
                          0.08,
                        ),
                        blurRadius:
                            8,
                        offset:
                            const Offset(
                          0,
                          4,
                        ),
                      ),
                    ],
        ),
        child: Text(
          widget.label,
          style:
              TextStyle(
            color:
                _pressed
                    ? Colors.white
                    : const Color(
                        0xFF17283E,
                      ),
            fontSize:
                40,
            fontWeight:
                FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _SearchUtilityButton
    extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SearchUtilityButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_SearchUtilityButton> createState() =>
      _SearchUtilityButtonState();
}

class _SearchUtilityButtonState
    extends State<_SearchUtilityButton> {
  bool _pressed = false;

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onTapDown:
          (_) {
        setState(() {
          _pressed = true;
        });
      },
      onTapUp:
          (_) {
        setState(() {
          _pressed = false;
        });

        widget.onTap();
      },
      onTapCancel:
          () {
        setState(() {
          _pressed = false;
        });
      },
      child:
          AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 100,
        ),
        height: 86,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
        ),
        decoration:
            BoxDecoration(
          color:
              _pressed
                  ? const Color(
                      0xFF00695C,
                    )
                  : const Color(
                      0xFFF3F7F8,
                    ),
          borderRadius:
              BorderRadius.circular(
            16,
          ),
          border:
              Border.all(
            color:
                _pressed
                    ? const Color(
                        0xFF00695C,
                      )
                    : const Color(
                        0xFFBCCCD8,
                      ),
            width:
                2,
          ),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              color:
                  _pressed
                      ? Colors.white
                      : const Color(
                          0xFF315067,
                        ),
              size:
                  36,
            ),
            if (widget.label.isNotEmpty) ...[
              const SizedBox(
                width: 8,
              ),
              Flexible(
                child: FittedBox(
                  fit:
                      BoxFit.scaleDown,
                  child: Text(
                    widget.label,
                    maxLines:
                        1,
                    style:
                        TextStyle(
                      color:
                          _pressed
                              ? Colors.white
                              : const Color(
                                  0xFF315067,
                                ),
                      fontSize:
                          25,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _ScrollControlMode { up, more, top }

class _ScrollDiscoveryControl extends StatefulWidget {
  final _ScrollControlMode mode; final String label; final VoidCallback onPressed;
  const _ScrollDiscoveryControl({super.key, required this.mode, required this.label, required this.onPressed});
  @override State<_ScrollDiscoveryControl> createState() => _ScrollDiscoveryControlState();
}

class _ScrollDiscoveryControlState extends State<_ScrollDiscoveryControl> {
  bool _pressed = false;
  @override Widget build(BuildContext context) {
    final isUp = widget.mode == _ScrollControlMode.up || widget.mode == _ScrollControlMode.top;
    final arrow = isUp ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded;
    return AnimatedScale(scale: _pressed ? 0.96 : 1, duration: const Duration(milliseconds: 120), child: Material(color: Colors.transparent, child: InkWell(onTap: widget.onPressed, onHighlightChanged: (v) { if (mounted) setState(() => _pressed = v); }, borderRadius: BorderRadius.circular(100), child: AnimatedContainer(duration: const Duration(milliseconds: 140), constraints: const BoxConstraints(minHeight: 88), padding: const EdgeInsets.fromLTRB(30,13,22,13), decoration: BoxDecoration(color: Colors.white.withOpacity(.98), borderRadius: BorderRadius.circular(100), border: Border.all(color: _pressed ? const Color(0xFF009688) : const Color(0xFFBFDCD8), width: _pressed ? 2.5 : 1.7), boxShadow: [BoxShadow(color: const Color(0xFF173B66).withOpacity(_pressed ? .09 : .17), blurRadius: _pressed ? 8 : 20, offset: Offset(0,_pressed ? 2 : 7))]), child: Row(mainAxisSize: MainAxisSize.min, children: [if (isUp) ...[_ScrollArrowCircle(icon: arrow, pressed: _pressed), const SizedBox(width:14)], ConstrainedBox(constraints: const BoxConstraints(minWidth:88,maxWidth:190), child: FittedBox(fit: BoxFit.scaleDown, child: Text(widget.label.toUpperCase(), maxLines:1, style: const TextStyle(color: Color(0xFF163B67), fontSize:24, fontWeight:FontWeight.w900, letterSpacing:.5)))), if (!isUp) ...[const SizedBox(width:14), _ScrollArrowCircle(icon: arrow, pressed:_pressed)]])))));
  }
}

class _ScrollArrowCircle extends StatelessWidget {
  final IconData icon; final bool pressed; const _ScrollArrowCircle({required this.icon, required this.pressed});
  @override Widget build(BuildContext context) => AnimatedContainer(duration: const Duration(milliseconds:140), width:66, height:66, decoration: BoxDecoration(gradient: LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors: pressed ? const [Color(0xFF00695C),Color(0xFF00897B)] : const [Color(0xFF009688),Color(0xFF26A69A)]), shape:BoxShape.circle, boxShadow:[BoxShadow(color:const Color(0xFF009688).withOpacity(.30),blurRadius:12,offset:const Offset(0,4))]), child:Icon(icon,color:Colors.white,size:48));
}
