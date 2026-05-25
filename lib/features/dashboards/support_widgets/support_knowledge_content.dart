import 'package:flutter/material.dart';

const _primary   = Color(0xFF1B5E35);
const _amber     = Color(0xFF7A5000);
const _green     = Color(0xFF2E6B3E);
const _primaryBg = Color(0xFFE4F5EC);
const _amberBg   = Color(0xFFFBF7E0);

// ── Model ──────────────────────────────────────────────────────────────────

enum ArticleCategory { scheduling, billing, account, technical, recycling }

extension ArticleCategoryX on ArticleCategory {
  String get label => ['Scheduling', 'Billing', 'Account', 'Technical', 'Recycling'][index];
  Color get color  => [_green, _amber, const Color(0xFF556B2F), const Color(0xFF8B4513), _primary][index];
  Color get bg     => [const Color(0xFFEAF2E4), _amberBg, const Color(0xFFF0F5E4), const Color(0xFFF5EDE4), _primaryBg][index];
  IconData get icon => [Icons.calendar_month_rounded, Icons.receipt_long_rounded, Icons.manage_accounts_rounded, Icons.settings_rounded, Icons.recycling_rounded][index];
}

class Article {
  const Article(this.title, this.views, this.updated, this.category, this.helpful);
  final String title, updated; final int views, helpful; final ArticleCategory category;
}

const _articles = [
  Article('How to schedule a bulk waste pickup',         1240, '2 days ago',  ArticleCategory.scheduling, 94),
  Article('Understanding your monthly invoice',          870,  '5 days ago',  ArticleCategory.billing,    88),
  Article('Reset your account password',                 654,  '1 week ago',  ArticleCategory.account,    91),
  Article('What items are accepted for recycling?',      1103, '3 days ago',  ArticleCategory.recycling,  97),
  Article('API integration guide for businesses',        420,  '2 weeks ago', ArticleCategory.technical,  82),
  Article('How to track your waste collection route',    780,  '4 days ago',  ArticleCategory.scheduling, 90),
  Article('Upgrade or downgrade your subscription plan', 510,  '1 week ago',  ArticleCategory.billing,    85),
];

// ── Main widget ────────────────────────────────────────────────────────────

class SupportKnowledgeContent extends StatefulWidget {
  const SupportKnowledgeContent({super.key});
  @override State<SupportKnowledgeContent> createState() => _State();
}

class _State extends State<SupportKnowledgeContent> {
  ArticleCategory? _filter;
  String _search = '';

  List<Article> get _filtered => _articles.where((a) {
    if (_filter != null && a.category != _filter) return false;
    if (_search.isNotEmpty && !a.title.toLowerCase().contains(_search.toLowerCase())) return false;
    return true;
  }).toList();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final filtered = _filtered;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Header
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Knowledge Base', style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5)),
            const SizedBox(height: 4),
            Text('Help articles and FAQs for customers & staff', style: tt.bodyMedium?.copyWith(color: cs.onSurface.withOpacity(0.5))),
          ])),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('New article'),
            style: FilledButton.styleFrom(backgroundColor: _primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ]),

        const SizedBox(height: 20),

        // Stats row
        Row(children: [
          _StatPill(Icons.article_rounded,      '${_articles.length} articles', _primary, _primaryBg),
          const SizedBox(width: 10),
          _StatPill(Icons.visibility_rounded,   '${_articles.fold(0, (s, a) => s + a.views)} views', _green, const Color(0xFFEAF2E4)),
          const SizedBox(width: 10),
          _StatPill(Icons.thumb_up_alt_rounded, '${(_articles.map((a) => a.helpful).reduce((a, b) => a + b) / _articles.length).round()}% helpful', _amber, _amberBg),
        ]),

        const SizedBox(height: 20),

        // Search
        Container(
          decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: cs.outline.withOpacity(0.15))),
          child: TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Search articles…',
              hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.35), fontSize: 14),
              prefixIcon: Icon(Icons.search_rounded, color: cs.onSurface.withOpacity(0.35), size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Category filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _Chip('All', _filter == null, null, () => setState(() => _filter = null)),
            const SizedBox(width: 8),
            for (final cat in ArticleCategory.values) ...[
              _Chip(cat.label, _filter == cat, cat.color, () => setState(() => _filter = _filter == cat ? null : cat)),
              if (cat != ArticleCategory.values.last) const SizedBox(width: 8),
            ],
          ]),
        ),

        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 2),
          child: Text('${filtered.length} article${filtered.length == 1 ? '' : 's'}',
              style: tt.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.4), fontWeight: FontWeight.w600, letterSpacing: 0.4)),
        ),

        // Articles list
        if (filtered.isEmpty)
          Center(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Column(children: [
              Icon(Icons.search_off_rounded, size: 48, color: cs.onSurface.withOpacity(0.2)),
              const SizedBox(height: 12),
              Text('No articles found', style: tt.bodyMedium?.copyWith(color: cs.onSurface.withOpacity(0.4))),
            ]),
          ))
        else
          ListView.separated(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _ArticleCard(filtered[i]),
          ),

        const SizedBox(height: 32),
      ]),
    );
  }
}

// ── Stat pill ──────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  const _StatPill(this.icon, this.label, this.color, this.bg);
  final IconData icon; final String label; final Color color, bg;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Flexible(child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color), overflow: TextOverflow.ellipsis)),
      ]),
    ),
  );
}

// ── Filter chip ────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  const _Chip(this.label, this.selected, this.color, this.onTap);
  final String label; final bool selected; final Color? color; final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = color ?? _primary;
    return GestureDetector(onTap: onTap, child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? c.withOpacity(0.12) : Colors.transparent,
        border: Border.all(color: selected ? c : Colors.grey.shade300, width: selected ? 1.5 : 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(fontSize: 13, fontWeight: selected ? FontWeight.w600 : FontWeight.w400, color: selected ? c : Colors.grey.shade600)),
    ));
  }
}

// ── Article card ───────────────────────────────────────────────────────────

class _ArticleCard extends StatelessWidget {
  const _ArticleCard(this.a);
  final Article a;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: cs.surface, borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16), onTap: () {},
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: cs.outline.withOpacity(0.12))),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Container(width: 4, color: a.category.color),
              Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: a.category.bg, borderRadius: BorderRadius.circular(10)),
                    child: Icon(a.category.icon, color: a.category.color, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(a.title, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600, height: 1.3)),
                    const SizedBox(height: 6),
                    Row(children: [
                      Icon(Icons.visibility_outlined, size: 12, color: cs.onSurface.withOpacity(0.4)),
                      const SizedBox(width: 3),
                      Text('${a.views}', style: TextStyle(fontSize: 11, color: cs.onSurface.withOpacity(0.45))),
                      const SizedBox(width: 10),
                      Icon(Icons.schedule_rounded, size: 12, color: cs.onSurface.withOpacity(0.4)),
                      const SizedBox(width: 3),
                      Text(a.updated, style: TextStyle(fontSize: 11, color: cs.onSurface.withOpacity(0.45))),
                      const SizedBox(width: 10),
                      const Icon(Icons.thumb_up_alt_outlined, size: 12, color: _green),
                      const SizedBox(width: 3),
                      Text('${a.helpful}%', style: const TextStyle(fontSize: 11, color: _green, fontWeight: FontWeight.w600)),
                    ]),
                  ])),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: cs.onSurface.withOpacity(0.3)),
                ]),
              )),
            ])),
          ),
        ),
      ),
    );
  }
}