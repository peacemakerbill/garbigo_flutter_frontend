import 'package:flutter/material.dart';

const _primary     = Color(0xFF15803D);   // Bright green (accents)
const _darkGreen   = Color(0xFF15803D);   // Dark green (headers, buttons)
const _amber       = Color(0xFF7A5000);
const _green       = Color(0xFF15803D);
const _olive       = Color(0xFF556B2F);
const _brown       = Color(0xFF8B4513);
const _primaryBg   = Color(0xFFE4F5EC);
const _amberBg     = Color(0xFFFBF7E0);
const _greenBg     = Color(0xFFEAF2E4);

// ── Model ──────────────────────────────────────────────────────────────────

class _Metric {
  const _Metric(this.title, this.value, this.trend, this.trendUp, this.icon, this.color, this.bg);
  final String title, value, trend;
  final bool trendUp;
  final IconData icon;
  final Color color, bg;
}

class _AgentData {
  const _AgentData(this.name, this.initials, this.resolved, this.rating, this.online);
  final String name, initials;
  final int resolved;
  final double rating;
  final bool online;
}

const _metrics = [
  _Metric('Tickets Resolved',       '187',    '↑ 12% vs last month', true,  Icons.check_circle_outline_rounded, _green,   _greenBg),
  _Metric('Avg Resolution Time',    '4.8 hrs','↓ 1.2 hrs faster',    true,  Icons.timer_outlined,               _primary, _primaryBg),
  _Metric('Customer Satisfaction',  '4.7/5',  '↑ 0.3 points',        true,  Icons.star_outline_rounded,         _amber,   _amberBg),
  _Metric('Active Agents',          '12',     '3 on break',           false, Icons.support_agent_rounded,        _olive,   const Color(0xFFF0F5E4)),
];

const _agents = [
  _AgentData('Jane Muthoni', 'JM', 42, 4.9, true),
  _AgentData('Brian Otieno', 'BO', 38, 4.7, true),
  _AgentData('Amara Diallo', 'AD', 35, 4.8, false),
  _AgentData('Leila Hassan', 'LH', 29, 4.6, true),
];

final _abgs = [_primaryBg, _amberBg, _greenBg, const Color(0xFFF0F5E4)];
final _afgs = [_primary, _amber, _green, _olive];

Color _abg(String i) => _abgs[i.codeUnitAt(0) % 4];
Color _afg(String i) => _afgs[i.codeUnitAt(0) % 4];

// ── Main widget ────────────────────────────────────────────────────────────

class SupportReportsContent extends StatelessWidget {
  const SupportReportsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Header
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Support Reports',
                style: tt.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: _darkGreen,
                )),
            const SizedBox(height: 4),
            Text('Performance metrics and customer satisfaction',
                style: tt.bodyMedium?.copyWith(color: cs.onSurface.withOpacity(0.5))),
          ])),
          OutlinedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.download_rounded, size: 16, color: _darkGreen),
            label: Text('Export', style: TextStyle(color: _darkGreen, fontSize: 13)),
            style: OutlinedButton.styleFrom(
                side: BorderSide(color: _darkGreen.withOpacity(0.4)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            ),
          ),
        ]),

        const SizedBox(height: 20),

        // Metric cards - Improved responsiveness
        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 1100 ? 4 :
            constraints.maxWidth > 700 ? 2 : 1;
            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.65,
              children: [for (final m in _metrics) _MetricCard(m)],
            );
          },
        ),

        const SizedBox(height: 24),

        // Agent leaderboard
        Text('Top Agents This Month',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _agents.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final a = _agents[i];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cs.outline.withOpacity(0.12))
              ),
              child: Row(children: [
                // Rank
                SizedBox(
                    width: 24,
                    child: Text(
                        '${i + 1}',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: i == 0 ? _amber : cs.onSurface.withOpacity(0.35)
                        )
                    )
                ),
                // Avatar
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: _abg(a.initials), shape: BoxShape.circle),
                  child: Center(
                      child: Text(
                          a.initials,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _afg(a.initials)
                          )
                      )
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text(a.name, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 6),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                            color: a.online ? _green : Colors.grey.shade400,
                            shape: BoxShape.circle
                        ),
                      ),
                    ]),
                    Text('${a.resolved} resolved',
                        style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.45))),
                  ]),
                ),
                Row(children: [
                  Icon(Icons.star_rounded, size: 14, color: _amber),
                  const SizedBox(width: 3),
                  Text('${a.rating}',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _amber)),
                ]),
              ]),
            );
          },
        ),

        const SizedBox(height: 32),
      ]),
    );
  }
}

// ── Metric card ────────────────────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  const _MetricCard(this.m);
  final _Metric m;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
        color: m.bg,
        borderRadius: BorderRadius.circular(16)
    ),
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: m.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10)
          ),
          child: Icon(m.icon, color: m.color, size: 20),
        ),
        const Spacer(),
        Icon(
            m.trendUp ? Icons.trending_up_rounded : Icons.trending_flat_rounded,
            size: 18,
            color: m.trendUp ? _green : _amber
        ),
      ]),
      const Spacer(),
      Text(
          m.value,
          style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              height: 1.1
          )
      ),
      const SizedBox(height: 4),
      Text(
          m.title,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: m.color.withOpacity(0.85)
          )
      ),
      const SizedBox(height: 6),
      Text(
          m.trend,
          style: TextStyle(
              fontSize: 12,
              color: m.trendUp ? _green : _amber,
              fontWeight: FontWeight.w500
          )
      ),
    ]),
  );
}