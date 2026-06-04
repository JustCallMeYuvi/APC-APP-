import 'dart:convert';
import 'dart:math';
import 'package:animated_movies_app/turn_over_module/widgets/common/badge_widget.dart';
import 'package:animated_movies_app/turn_over_module/widgets/navigation/header.dart';
import 'package:animated_movies_app/turn_over_module/widgets/states/empty_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'constants/turnover_colors.dart';
import 'helpers/turnover_helper.dart';
import 'models/filter_state.dart';
import 'models/turnover_record.dart';
import 'services/turnover_api_service.dart';
import 'tabs/charts_tab.dart';
import 'tabs/insights_tab.dart';
import 'tabs/overview_tab.dart';
import 'tabs/summary_tab.dart';
import 'tabs/table_tab.dart';
import 'widgets/filters/filter_bar.dart';
import 'widgets/navigation/side_nav.dart';
import 'widgets/navigation/tab_strip.dart';
import 'widgets/states/error_view.dart';
import 'widgets/states/loader.dart';

// ════════════════════════════════════════════════════════════
//  HELPERS
// ════════════════════════════════════════════════════════════

// ════════════════════════════════════════════════════════════
//  ROOT SCREEN
// ════════════════════════════════════════════════════════════

class TurnOverScreen extends StatefulWidget {
  const TurnOverScreen({super.key});
  @override
  State<TurnOverScreen> createState() => _TurnOverScreenState();
}

class _TurnOverScreenState extends State<TurnOverScreen>
    with SingleTickerProviderStateMixin {
  FilterState _filter = const FilterState();
  int _tab = 0;
  List<TurnoverRecord> _data = [];
  bool _loading = false;
  String? _error;
  late AnimationController _ac;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _fade = CurvedAnimation(parent: _ac, curve: Curves.easeOut);
    _loadData();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _data = await TurnoverApiService.fetch(_filter);
      _ac
        ..reset()
        ..forward();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onFilterChanged(FilterState fs) {
    setState(() => _filter = fs);
    _loadData();
  }

  bool get _isMonth => _filter.subView == SubView.monthwise;

  @override
  Widget build(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width >= 900 ? _wide() : _narrow();

  Widget _wide() => Scaffold(
        backgroundColor: kCBg,
        body: Row(children: [
          SideNavWidget(tab: _tab, onTab: (t) => setState(() => _tab = t)),
          Expanded(
              child: Column(children: [
            FilterBar(
                filter: _filter, onChanged: _onFilterChanged, isWide: true),
            Expanded(child: _body()),
          ])),
        ]),
      );

  Widget _narrow() => Scaffold(
        backgroundColor: kCBg,
        body: Column(children: [
          const TurnOutHeaderWidget(),
          FilterBar(
              filter: _filter, onChanged: _onFilterChanged, isWide: false),
          TabStripWidget(tab: _tab, onTab: (t) => setState(() => _tab = t)),
          Expanded(child: _body()),
        ]),
      );

  Widget _body() {
    if (_loading) return const LoaderWidget();
    if (_error != null) return ErrorViewWidget(error: _error!, onRetry: _loadData);
    if (_data.isEmpty) return const EmptyWidget();
    return FadeTransition(opacity: _fade, child: _tabContent());
  }

  Widget _tabContent() {
    // agg = first record for KPI cards (overview uses all records for charts)
    final agg = _data.first;
    switch (_tab) {
      case 0:
        return OverviewTab(data: _data, filter: _filter, agg: agg);
      case 1:
        return ChartsTab(data: _data, isMonth: _isMonth);
      case 2:
        return TableTab(data: _data, isMonth: _isMonth);
      case 3:
        return InsightsTab(data: _data, agg: agg, isMonth: _isMonth);
      case 4:
        return SummaryTab(data: _data, agg: agg, isMonth: _isMonth);
      default:
        return const SizedBox();
    }
  }
}

// ════════════════════════════════════════════════════════════
//  SMALL REUSABLE WIDGETS
// ════════════════════════════════════════════════════════════




