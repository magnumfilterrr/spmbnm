import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spmb_app/core/theme/app_theme.dart';
import 'package:spmb_app/core/utils/responsive_helper.dart';
import 'package:spmb_app/logic/dashboard/dashboard_bloc.dart';
import 'package:spmb_app/logic/dashboard/dashboard_event.dart';
import 'package:spmb_app/logic/dashboard/dashboard_state.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppTheme.error),
                  const SizedBox(height: 12),
                  Text(state.message),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<DashboardBloc>().add(LoadDashboard()),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }
          if (state is DashboardLoaded) {
            return _buildDashboard(context, state);
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, DashboardLoaded state) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final crossAxisCount = isDesktop ? 4 : (isTablet ? 2 : 2);

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<DashboardBloc>().add(LoadDashboard()),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 24),

            // Stats Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isDesktop ? 1.6 : 1.4,
              children: [
                _StatCard(
                  title: 'Total Peserta',
                  value: state.total.toString(),
                  icon: Icons.people_alt_rounded,
                  color: AppTheme.primary,
                ),
                _StatCard(
                  title: 'Laki-laki',
                  value: state.laki.toString(),
                  icon: Icons.male_rounded,
                  color: const Color(0xFF1976D2),
                ),
                _StatCard(
                  title: 'Perempuan',
                  value: state.perempuan.toString(),
                  icon: Icons.female_rounded,
                  color: const Color(0xFFE91E8C),
                ),
                _StatCard(
                  title: 'Jurusan',
                  value: state.perJurusan.length.toString(),
                  icon: Icons.category_rounded,
                  color: const Color(0xFF00897B),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Charts Row
            isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildJurusanChart(state)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildJalurChart(state)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildGenderChart(state)),
                    ],
                  )
                : Column(
                    children: [
                      _buildJurusanChart(state),
                      const SizedBox(height: 16),
                      _buildJalurChart(state),
                      const SizedBox(height: 16),
                      _buildGenderChart(state),
                    ],
                  ),

            const SizedBox(height: 24),

            // Jurusan Detail Table
            _buildJurusanTable(state),
          ],
        ),
      ),
    );
  }

  // ─── HEADER ──────────────────────────────────────────
  Widget _buildHeader() {
    final now = DateTime.now();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              'Statistik Penerimaan Murid Baru',
              style: TextStyle(
                  fontSize: 14, color: AppTheme.textSecondary),
            ),
          ],
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${now.day}/${now.month}/${now.year}',
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ─── JURUSAN BAR CHART ───────────────────────────────
  Widget _buildJurusanChart(DashboardLoaded state) {
    final shortNames = {
      'Manajemen Perkantoran dan Layanan Bisnis': 'MPLB',
      'Pemasaran Bisnis Ritel': 'PBR',
      'Desain Komunikasi Visual': 'DKV',
      'Teknik Kendaraan Ringan': 'TKR',
    };

    final colors = [
      AppTheme.primary,
      const Color(0xFF00897B),
      const Color(0xFFE91E8C),
      const Color(0xFFFF8F00),
    ];

    return _ChartCard(
      title: 'Peserta per Jurusan',
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: (state.perJurusan.values.isEmpty
                        ? 10
                        : state.perJurusan.values
                            .reduce((a, b) => a > b ? a : b)) +
                    5.0,
            barTouchData: BarTouchData(enabled: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (v, _) => Text(
                    v.toInt().toString(),
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.textSecondary),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    final keys = state.perJurusan.keys.toList();
                    final idx = value.toInt();
                    if (idx < 0 || idx >= keys.length) {
                      return const SizedBox();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        shortNames[keys[idx]] ?? keys[idx],
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary),
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(
                color: AppTheme.border,
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: state.perJurusan.entries.toList().asMap().entries
                .map((e) => BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value.value.toDouble(),
                          color: colors[e.key % colors.length],
                          width: 28,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                        ),
                      ],
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  // ─── JALUR PIE CHART ─────────────────────────────────
  Widget _buildJalurChart(DashboardLoaded state) {
    final colors = [
      const Color(0xFF1565C0),
      const Color(0xFF00897B),
      const Color(0xFFFF8F00),
    ];

    final sections = state.perJalur.entries.toList().asMap().entries
        .where((e) => e.value.value > 0)
        .map((e) => PieChartSectionData(
              value: e.value.value.toDouble(),
              title: '${e.value.value}',
              color: colors[e.key % colors.length],
              radius: 60,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ))
        .toList();

    return _ChartCard(
      title: 'Jalur Pendaftaran',
      child: SizedBox(
        height: 200,
        child: sections.isEmpty
            ? const Center(
                child: Text('Belum ada data',
                    style: TextStyle(color: AppTheme.textSecondary)))
            : Row(
                children: [
                  Expanded(
                    child: PieChart(PieChartData(
                      sections: sections,
                      centerSpaceRadius: 30,
                      sectionsSpace: 2,
                    )),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: state.perJalur.entries
                        .toList()
                        .asMap()
                        .entries
                        .map((e) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: colors[e.key % colors.length],
                                      borderRadius:
                                          BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    e.value.key,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textPrimary),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
      ),
    );
  }

  // ─── GENDER PIE CHART ────────────────────────────────
  Widget _buildGenderChart(DashboardLoaded state) {
    final total = state.laki + state.perempuan;
    final sections = total == 0
        ? [
            PieChartSectionData(
                value: 1, title: '', color: AppTheme.border, radius: 60)
          ]
        : [
            PieChartSectionData(
              value: state.laki.toDouble(),
              title: '${state.laki}',
              color: const Color(0xFF1976D2),
              radius: 60,
              titleStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
            PieChartSectionData(
              value: state.perempuan.toDouble(),
              title: '${state.perempuan}',
              color: const Color(0xFFE91E8C),
              radius: 60,
              titleStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ];

    return _ChartCard(
      title: 'Jenis Kelamin',
      child: SizedBox(
        height: 200,
        child: Row(
          children: [
            Expanded(
              child: PieChart(PieChartData(
                sections: sections,
                centerSpaceRadius: 30,
                sectionsSpace: 2,
              )),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LegendItem(
                    color: const Color(0xFF1976D2),
                    label: 'Laki-laki',
                    value: state.laki),
                const SizedBox(height: 8),
                _LegendItem(
                    color: const Color(0xFFE91E8C),
                    label: 'Perempuan',
                    value: state.perempuan),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── JURUSAN TABLE ───────────────────────────────────
  Widget _buildJurusanTable(DashboardLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detail per Jurusan',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(2),
              },
              children: [
                // Header
                TableRow(
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text('Jurusan',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text('Jumlah',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text('Persentase',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary)),
                    ),
                  ],
                ),
                // Rows
                ...state.perJurusan.entries.map((e) {
                  final pct = state.total == 0
                      ? 0.0
                      : e.value / state.total * 100;
                  return TableRow(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppTheme.border),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(e.key,
                            style: const TextStyle(
                                color: AppTheme.textPrimary)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text('${e.value}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: pct / 100,
                                  minHeight: 8,
                                  backgroundColor: AppTheme.border,
                                  valueColor:
                                      const AlwaysStoppedAnimation(
                                          AppTheme.primary),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${pct.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── REUSABLE WIDGETS ─────────────────────────────────

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ($value)',
          style: const TextStyle(
              fontSize: 11, color: AppTheme.textPrimary),
        ),
      ],
    );
  }
}