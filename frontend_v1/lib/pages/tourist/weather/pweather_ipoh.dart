import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/model/weather/weather_forecast.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/services/weather/weather_service_ipoh.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';

class PWeatherPageIpoh extends StatefulWidget {
  const PWeatherPageIpoh({super.key});

  @override
  State<PWeatherPageIpoh> createState() =>
      _PWeatherPageIpohState();
}

class _PWeatherPageIpohState
    extends State<PWeatherPageIpoh> {
  final ScrollController _forecastScrollController =
      ScrollController();

  WeatherResult? _result;
  Object? _error;

  bool _loading = true;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  @override
  void dispose() {
    _forecastScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadWeather({
    bool forceRefresh = false,
  }) async {
    if (forceRefresh && _refreshing) return;

    setState(() {
      if (forceRefresh) {
        _refreshing = true;
      } else {
        _loading = true;
      }

      _error = null;
    });

    try {
      final result =
          await WeatherServiceIpoh.instance.getIpohForecast(
        forceRefresh: forceRefresh,
      );

      if (!mounted) return;

      setState(() {
        _result = result;
        _loading = false;
        _refreshing = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error;
        _loading = false;
        _refreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          // ============================================================
          // BACKGROUND IMAGE
          // ============================================================
          Positioned.fill(
            child: Image.asset(
              'lib/images/pnew.png',
              fit: BoxFit.cover,
            ),
          ),

          // ============================================================
          // FRESH SOFT OVERLAY
          // ============================================================
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFF8FCFF).withOpacity(0.93),
                    const Color(0xFFEAF7FF).withOpacity(0.88),
                    const Color(0xFFF4FBF8).withOpacity(0.90),
                  ],
                ),
              ),
            ),
          ),

          // Decorative soft circles.
          Positioned(
            top: -120,
            right: -110,
            child: Container(
              width: 390,
              height: 390,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF38BDF8).withOpacity(0.09),
              ),
            ),
          ),

          Positioned(
            bottom: 120,
            left: -130,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF34D399).withOpacity(0.08),
              ),
            ),
          ),

          // ============================================================
          // HEADER
          // ============================================================
          Positioned(
            top: 72,
            left: 48,
            right: 48,
            child: _ModernWeatherHeader(
              title: loc.weatherPageTitle,
              subtitle: loc.weatherPageSubtitle,
            ),
          ),

          // ============================================================
          // WEATHER CONTENT
          // ============================================================
          Positioned(
            top: 200,
            left: 48,
            right: 48,
            bottom: 350,
            child: _buildBody(loc),
          ),

          // ============================================================
          // DISCLAIMER
          // ============================================================
          Positioned(
            left: 70,
            right: 70,
            bottom: 250,
            child: _DisclaimerCard(
              title: loc.weatherDisclaimerTitle,
              message: loc.weatherDisclaimerText,
            ),
          ),

          // ============================================================
          // BACK BUTTON
          // ============================================================
          Positioned(
            bottom: 90,
            left: 190,
            right: 190,
            child: KioskBackButton(
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // ============================================================
          // FOOTER
          // ============================================================
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                Data.copyrightText,
                style: const TextStyle(
                  color: Color(0xFF334155),
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

  Widget _buildBody(AppLocalizations loc) {
    if (_loading) {
      return _StatusCard(
        icon: Icons.cloud_sync_rounded,
        title: loc.weatherLoadingTitle,
        message: loc.weatherLoadingMessage,
        child: const SizedBox(
          width: 58,
          height: 58,
          child: CircularProgressIndicator(
            strokeWidth: 7,
            color: Color(0xFF0EA5E9),
          ),
        ),
      );
    }

    if (_error != null && _result == null) {
      return _StatusCard(
        icon: Icons.cloud_off_rounded,
        title: loc.weatherUnavailableTitle,
        message: loc.weatherUnavailableMessage,
        child: ElevatedButton.icon(
          onPressed: () => _loadWeather(
            forceRefresh: true,
          ),
          icon: const Icon(
            Icons.refresh_rounded,
            size: 31,
          ),
          label: Text(
            loc.weatherTryAgain,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0EA5E9),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 19,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      );
    }

    final result = _result!;
    final forecasts = result.forecasts.take(7).toList();

    final localeName =
        Localizations.localeOf(context).languageCode;

    return Column(
      children: [
        _CurrentSummaryCard(
          forecast: forecasts.first,
          loc: loc,
          localeName: localeName,
          fetchedAt: result.fetchedAt,
          isFromCache: result.isFromCache,
          refreshing: _refreshing,
          onRefresh: () => _loadWeather(
            forceRefresh: true,
          ),
        ),

        const SizedBox(height: 22),

        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.97),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(
                color: const Color(0xFFD7E5EF),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F4C81)
                      .withOpacity(0.12),
                  blurRadius: 28,
                  spreadRadius: 1,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Column(
                children: [
                  // ====================================================
                  // FORECAST SECTION HEADER
                  // ====================================================
                  Container(
                    padding: const EdgeInsets.fromLTRB(
                      28,
                      22,
                      28,
                      20,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFF1F9FF),
                          Color(0xFFF5FCFA),
                        ],
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFD9E8F1),
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF0EA5E9),
                                Color(0xFF14B8A6),
                              ],
                            ),
                            borderRadius:
                                BorderRadius.circular(17),
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 17),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.weatherSevenDayForecast,
                                style: const TextStyle(
                                  color: Color(0xFF17263A),
                                  fontSize: 31,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                loc.weatherScrollHint,
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.swipe_up_rounded,
                          color: Color(0xFF0EA5E9),
                          size: 36,
                        ),
                      ],
                    ),
                  ),

                  // ====================================================
                  // VISIBLE SCROLLBAR
                  // ====================================================
                  Expanded(
                    child: Scrollbar(
                      controller: _forecastScrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      thickness: 12,
                      radius: const Radius.circular(20),
                      interactive: true,
                      child: ListView.separated(
                        controller:
                            _forecastScrollController,
                        physics:
                            const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          22,
                          20,
                          34,
                          26,
                        ),
                        itemCount: forecasts.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 15),
                        itemBuilder: (context, index) {
                          return _ForecastCard(
                            forecast: forecasts[index],
                            loc: loc,
                            localeName: localeName,
                            index: index,
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
      ],
    );
  }
}

// ============================================================================
// MODERN HEADER
// ============================================================================
class _ModernWeatherHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ModernWeatherHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Container(
        //   padding: const EdgeInsets.symmetric(
        //     horizontal: 22,
        //     vertical: 10,
        //   ),
        //   decoration: BoxDecoration(
        //     color: const Color(0xFF0EA5E9).withOpacity(0.10),
        //     borderRadius: BorderRadius.circular(100),
        //     border: Border.all(
        //       color:
        //           const Color(0xFF0EA5E9).withOpacity(0.25),
        //       width: 1.5,
        //     ),
        //   ),
        //   child: const Row(
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       Icon(
        //         Icons.cloud_queue_rounded,
        //         color: Color(0xFF0284C7),
        //         size: 24,
        //       ),
        //       SizedBox(width: 9),
        //       Text(
        //         'MET MALAYSIA',
        //         style: TextStyle(
        //           color: Color(0xFF0284C7),
        //           fontSize: 18,
        //           fontWeight: FontWeight.w900,
        //           letterSpacing: 1.3,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),

        // const SizedBox(height: 14),

        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [
                Color(0xFF0369A1),
                Color(0xFF0EA5E9),
                Color(0xFF0F9F8F),
              ],
            ).createShader(bounds);
          },
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 59,
              fontWeight: FontWeight.w900,
              height: 1.04,
              letterSpacing: -1,
            ),
          ),
        ),

        // const SizedBox(height: 14),

        // Container(
        //   constraints: const BoxConstraints(
        //     maxWidth: 760,
        //   ),
        //   padding: const EdgeInsets.symmetric(
        //     horizontal: 28,
        //     vertical: 14,
        //   ),
        //   decoration: BoxDecoration(
        //     color: Colors.white.withOpacity(0.90),
        //     borderRadius: BorderRadius.circular(21),
        //     border: Border.all(
        //       color: const Color(0xFFD6E7F1),
        //       width: 1.5,
        //     ),
        //     boxShadow: [
        //       BoxShadow(
        //         color:
        //             const Color(0xFF0F4C81).withOpacity(0.08),
        //         blurRadius: 18,
        //         offset: const Offset(0, 8),
        //       ),
        //     ],
        //   ),
        //   child: Text(
        //     subtitle,
        //     textAlign: TextAlign.center,
        //     style: const TextStyle(
        //       color: Color(0xFF475569),
        //       fontSize: 27,
        //       fontWeight: FontWeight.w700,
        //       height: 1.25,
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

// ============================================================================
// CURRENT WEATHER SUMMARY
// ============================================================================
class _CurrentSummaryCard extends StatelessWidget {
  final WeatherForecast forecast;
  final AppLocalizations loc;
  final String localeName;
  final DateTime fetchedAt;
  final bool isFromCache;
  final bool refreshing;
  final VoidCallback onRefresh;

  const _CurrentSummaryCard({
    required this.forecast,
    required this.loc,
    required this.localeName,
    required this.fetchedAt,
    required this.isFromCache,
    required this.refreshing,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final condition = _translateForecast(
      forecast.summaryForecast,
      localeName,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(
        27,
        25,
        22,
        25,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0369A1),
            Color(0xFF0EA5E9),
            Color(0xFF14B8A6),
          ],
        ),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(
          color: Colors.white.withOpacity(0.80),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0369A1).withOpacity(0.25),
            blurRadius: 28,
            spreadRadius: 1,
            offset: const Offset(0, 13),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -55,
            right: -45,
            child: Container(
              width: 185,
              height: 185,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.09),
              ),
            ),
          ),

          Row(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.17),
                  borderRadius: BorderRadius.circular(29),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.26),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  _weatherIcon(
                    forecast.summaryForecast,
                  ),
                  color: Colors.white,
                  size: 72,
                ),
              ),

              const SizedBox(width: 24),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.weatherIpohLocation,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 39,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      condition,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                        height: 1.18,
                      ),
                    ),
                    const SizedBox(height: 13),
                    Row(
                      children: [
                        Icon(
                          isFromCache
                              ? Icons.save_rounded
                              : Icons.update_rounded,
                          color:
                              Colors.white.withOpacity(0.86),
                          size: 20,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            '${loc.weatherUpdated}: '
                            '${DateFormat('dd/MM/yyyy, hh:mm a').format(fetchedAt)}'
                            '${isFromCache ? ' • ${loc.weatherCachedData}' : ''}',
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: TextStyle(
                              color:
                                  Colors.white.withOpacity(0.88),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              Column(
                children: [
                  Text(
                    '${forecast.maxTemp}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 61,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '${forecast.minTemp}° '
                      '${loc.weatherMinimumShort}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Material(
                    color: Colors.white.withOpacity(0.17),
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      onTap:
                          refreshing ? null : onRefresh,
                      borderRadius:
                          BorderRadius.circular(18),
                      child: SizedBox(
                        width: 58,
                        height: 58,
                        child: Center(
                          child: refreshing
                              ? const SizedBox(
                                  width: 30,
                                  height: 30,
                                  child:
                                      CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 4,
                                  ),
                                )
                              : const Icon(
                                  Icons.refresh_rounded,
                                  color: Colors.white,
                                  size: 34,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// FORECAST CARD
// ============================================================================
class _ForecastCard extends StatelessWidget {
  final WeatherForecast forecast;
  final AppLocalizations loc;
  final String localeName;
  final int index;

  const _ForecastCard({
    required this.forecast,
    required this.loc,
    required this.localeName,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat(
      'EEEE, dd MMMM',
      _intlLocale(localeName),
    ).format(forecast.date);

    final bool isFirst = index == 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFirst
              ? const [
                  Color(0xFFEAF8FF),
                  Color(0xFFEDFCF8),
                ]
              : const [
                  Color(0xFFF8FBFE),
                  Color(0xFFF4F9FC),
                ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isFirst
              ? const Color(0xFF8DD7E8)
              : const Color(0xFFD7E4ED),
          width: isFirst ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF315B78)
                .withOpacity(0.07),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isFirst
                        ? const [
                            Color(0xFF0EA5E9),
                            Color(0xFF14B8A6),
                          ]
                        : const [
                            Color(0xFFDDF2FF),
                            Color(0xFFE3F7F2),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _weatherIcon(
                    forecast.summaryForecast,
                  ),
                  color: isFirst
                      ? Colors.white
                      : const Color(0xFF087DA5),
                  size: 41,
                ),
              ),

              const SizedBox(width: 17),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            dateText,
                            style: const TextStyle(
                              color: Color(0xFF17263A),
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (isFirst)
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0EA5E9),
                              borderRadius:
                                  BorderRadius.circular(100),
                            ),
                            child: Text(
                              loc.weatherToday,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _translateForecast(
                        forecast.summaryForecast,
                        localeName,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF607085),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.18,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 15),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.86),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: const Color(0xFFD7E4ED),
                  ),
                ),
                child: Text(
                  '${forecast.minTemp}° / '
                  '${forecast.maxTemp}°',
                  style: const TextStyle(
                    color: Color(0xFF087DA5),
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _PeriodChip(
                  icon: Icons.wb_sunny_rounded,
                  label: loc.weatherMorning,
                  value: _translateForecast(
                    forecast.morningForecast,
                    localeName,
                  ),
                  accentColor: const Color(0xFFF59E0B),
                  backgroundColor:
                      const Color(0xFFFFF8E7),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PeriodChip(
                  icon: Icons.light_mode_rounded,
                  label: loc.weatherAfternoon,
                  value: _translateForecast(
                    forecast.afternoonForecast,
                    localeName,
                  ),
                  accentColor: const Color(0xFF0EA5E9),
                  backgroundColor:
                      const Color(0xFFEAF7FF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PeriodChip(
                  icon: Icons.nights_stay_rounded,
                  label: loc.weatherNight,
                  value: _translateForecast(
                    forecast.nightForecast,
                    localeName,
                  ),
                  accentColor: const Color(0xFF6366F1),
                  backgroundColor:
                      const Color(0xFFF0F0FF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PERIOD CHIP
// ============================================================================
class _PeriodChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;
  final Color backgroundColor;

  const _PeriodChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 118,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withOpacity(0.18),
          width: 1.4,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.18,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DISCLAIMER
// ============================================================================
class _DisclaimerCard extends StatelessWidget {
  final String title;
  final String message;

  const _DisclaimerCard({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB).withOpacity(0.97),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF2C94C),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8A6D1D).withOpacity(0.10),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B)
                  .withOpacity(0.14),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFFD97706),
              size: 29,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Color(0xFF73520C),
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextSpan(
                    text: message,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// STATUS CARD
// ============================================================================
class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget child;

  const _StatusCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 640,
        padding: const EdgeInsets.all(42),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.97),
          borderRadius: BorderRadius.circular(34),
          border: Border.all(
            color: const Color(0xFFD7E5EF),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F4C81)
                  .withOpacity(0.12),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFEAF8FF),
                    Color(0xFFE9FBF6),
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(
                icon,
                size: 76,
                color: const Color(0xFF0EA5E9),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: Color(0xFF17263A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 28),
            child,
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// WEATHER ICON
// ============================================================================
IconData _weatherIcon(String forecast) {
  final value = forecast.toLowerCase();

  if (value.contains('ribut petir')) {
    return Icons.thunderstorm_rounded;
  }

  if (value.contains('hujan')) {
    return Icons.grain_rounded;
  }

  if (value.contains('jerebu')) {
    return Icons.blur_on_rounded;
  }

  if (value.contains('mendung')) {
    return Icons.cloud_rounded;
  }

  if (value.contains('tiada hujan')) {
    return Icons.wb_sunny_rounded;
  }

  return Icons.cloud_queue_rounded;
}

// ============================================================================
// FORECAST TRANSLATION
// ============================================================================
String _intlLocale(String languageCode) {
  switch (languageCode) {
    case 'ms':
      return 'ms_MY';
    case 'zh':
      return 'zh_CN';
    case 'ta':
      return 'ta_IN';
    default:
      return 'en_US';
  }
}

// ============================================================================
// FORECAST TRANSLATION
// The data.gov.my forecast text is returned in Malay.
// ============================================================================
String _translateForecast(
  String value,
  String languageCode,
) {
  if (languageCode == 'ms') return value;

  const translations = <String, Map<String, String>>{
    'Berjerebu': {
      'en': 'Hazy',
      'zh': '烟霾',
      'ta': 'புகைமூட்டம்',
    },
    'Mendung': {
      'en': 'Cloudy',
      'zh': '多云',
      'ta': 'மேகமூட்டம்',
    },
    'Tiada hujan': {
      'en': 'No rain',
      'zh': '无雨',
      'ta': 'மழையில்லை',
    },
    'Hujan': {
      'en': 'Rain',
      'zh': '有雨',
      'ta': 'மழை',
    },
    'Hujan di beberapa tempat': {
      'en': 'Scattered rain',
      'zh': '局部地区有雨',
      'ta': 'சில இடங்களில் மழை',
    },
    'Hujan di kebanyakan tempat': {
      'en': 'Rain in most places',
      'zh': '多数地区有雨',
      'ta': 'பெரும்பாலான இடங்களில் மழை',
    },
    'Hujan di satu dua tempat': {
      'en': 'Isolated rain',
      'zh': '一两个地区有雨',
      'ta': 'ஓரிரு இடங்களில் மழை',
    },
    'Hujan di satu dua tempat di kawasan pantai': {
      'en': 'Isolated rain over coastal areas',
      'zh': '沿海一两个地区有雨',
      'ta': 'கடலோரத்தின் ஓரிரு இடங்களில் மழை',
    },
    'Hujan di satu dua tempat di kawasan pedalaman': {
      'en': 'Isolated rain over inland areas',
      'zh': '内陆一两个地区有雨',
      'ta': 'உள்நாட்டின் ஓரிரு இடங்களில் மழை',
    },
    'Ribut petir': {
      'en': 'Thunderstorms',
      'zh': '雷暴',
      'ta': 'இடியுடன் கூடிய மழை',
    },
    'Ribut petir menyeluruh': {
      'en': 'Widespread thunderstorms',
      'zh': '大范围雷暴',
      'ta': 'பரவலாக இடியுடன் கூடிய மழை',
    },
    'Ribut petir di beberapa tempat': {
      'en': 'Scattered thunderstorms',
      'zh': '局部地区有雷暴',
      'ta': 'சில இடங்களில் இடியுடன் கூடிய மழை',
    },
    'Ribut petir di kebanyakan tempat': {
      'en': 'Thunderstorms in most places',
      'zh': '多数地区有雷暴',
      'ta': 'பெரும்பாலான இடங்களில் இடியுடன் கூடிய மழை',
    },
    'Ribut petir di beberapa tempat di kawasan pedalaman': {
      'en': 'Scattered thunderstorms over inland areas',
      'zh': '内陆局部地区有雷暴',
      'ta': 'உள்நாட்டின் சில இடங்களில் இடியுடன் கூடிய மழை',
    },
    'Ribut petir di satu dua tempat': {
      'en': 'Isolated thunderstorms',
      'zh': '一两个地区有雷暴',
      'ta': 'ஓரிரு இடங்களில் இடியுடன் கூடிய மழை',
    },
    'Ribut petir di satu dua tempat di kawasan pantai': {
      'en': 'Isolated thunderstorms over coastal areas',
      'zh': '沿海一两个地区有雷暴',
      'ta': 'கடலோரத்தின் ஓரிரு இடங்களில் இடியுடன் கூடிய மழை',
    },
    'Ribut petir di satu dua tempat di kawasan pedalaman': {
      'en': 'Isolated thunderstorms over inland areas',
      'zh': '内陆一两个地区有雷暴',
      'ta': 'உள்நாட்டின் ஓரிரு இடங்களில் இடியுடன் கூடிய மழை',
    },
  };

  return translations[value]?[languageCode] ??
      translations[value]?['en'] ??
      value;
}
