import 'package:flutter/material.dart';

// ── Palette (garbage app earthy greens) ────────────────────────────────────

const _primary   = Color(0xFF1B5E35);
const _amber     = Color(0xFF7A5000);
const _green     = Color(0xFF2E6B3E);
const _primaryBg = Color(0xFFE4F5EC);
const _amberBg   = Color(0xFFFBF7E0);
const _greenBg   = Color(0xFFEAF2E4);

// ── Model ──────────────────────────────────────────────────────────────────

enum CustomerStatus { active, inactive, pending }

extension CustomerStatusX on CustomerStatus {
  String get label => ['Active', 'Inactive', 'Pending'][index];
  Color get color => [_green, const Color(0xFF8B4513), _amber][index];
  Color get bg    => [_greenBg, const Color(0xFFF5EDE4), _amberBg][index];
}

class Customer {
  const Customer(this.name, this.initials, this.email, this.location, this.plan, this.joined, this.collections, this.status);
  final String name, initials, email, location, plan, joined;
  final int collections;
  final CustomerStatus status;
}

const _customers = [
  Customer('Jane Muthoni',   'JM', 'jane.m@ecotrack.ke',    'Nairobi, Kenya',   'Premium', 'Jan 2024', 48, CustomerStatus.active),
  Customer('Brian Otieno',   'BO', 'brian.o@cleanzone.co',  'Mombasa, Kenya',   'Basic',   'Mar 2024', 12, CustomerStatus.active),
  Customer('Amara Diallo',   'AD', 'amara.d@greencity.sn',  'Dakar, Senegal',   'Premium', 'Nov 2023', 91, CustomerStatus.active),
  Customer('Leila Hassan',   'LH', 'leila.h@wastetech.tz',  'Dar es Salaam, TZ','Basic',   'Feb 2024',  5, CustomerStatus.pending),
  Customer('Marcus Owusu',   'MO', 'marcus.o@ecobin.gh',    'Accra, Ghana',     'Premium', 'Aug 2023', 73, CustomerStatus.active),
  Customer('Priya Nair',     'PN', 'priya.n@trashsmart.in', 'Nairobi, Kenya',   'Basic',   'Apr 2024',  2, CustomerStatus.inactive),
];

// ── Avatar helpers ─────────────────────────────────────────────────────────

final _bgs = [const Color(0xFFE4F5EC), const Color(0xFFF5F0E4), const Color(0xFFEAF2E4), const Color(0xFFF5EDE4), const Color(0xFFDFF0E8), const Color(0xFFF0F5E4)];
final _fgs = [const Color(0xFF1B5E35), const Color(0xFF7A5000), const Color(0xFF3A6B2A), const Color(0xFF8B4513), const Color(0xFF2E6B3E), const Color(0xFF556B2F)];
Color _abg(String i) => _bgs[i.codeUnitAt(0) % 6];
Color _afg(String i) => _fgs[i.codeUnitAt(0) % 6];

// ── Main widget ────────────────────────────────────────────────────────────

class SupportCustomersContent extends StatefulWidget {
  const SupportCustomersContent({super.key});
  @override State<SupportCustomersContent> createState() => _State();
}

class _State extends State<SupportCustomersContent> {
  CustomerStatus? _filter;
  String _search = '';

  List<Customer> get _filtered => _customers.where((c) {
    if (_filter != null && c.status != _filter) return false;
    if (_search.isNotEmpty && !c.name.toLowerCase().contains(_search.toLowerCase()) &&
        !c.email.toLowerCase().contains(_search.toLowerCase())) return false;
    return true;
  }).toList();

  int _count(CustomerStatus s) => _customers.where((c) => c.status == s).length;

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
            Text('Customers', style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5)),
            const SizedBox(height: 4),
            Text('View and manage customer information', style: tt.bodyMedium?.copyWith(color: cs.onSurface.withOpacity(0.5))),
          ])),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.person_add_rounded, size: 18),
            label: const Text('Add customer'),
            style: FilledButton.styleFrom(
              backgroundColor: _primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ]),

        const SizedBox(height: 20),

        // Summary cards
        LayoutBuilder(builder: (_, box) {
          final cols = box.maxWidth < 400 ? 2 : 3;
          return GridView.count(
            crossAxisCount: cols, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.8,
            children: [
              _SummaryCard('Total',    _customers.length, Icons.group_rounded,          _primary, _primaryBg),
              _SummaryCard('Active',   _count(CustomerStatus.active),  Icons.check_circle_outline_rounded, _green, _greenBg),
              _SummaryCard('Pending',  _count(CustomerStatus.pending), Icons.hourglass_top_rounded,        _amber, _amberBg),
            ],
          );
        }),

        const SizedBox(height: 20),

        // Search bar
        Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outline.withOpacity(0.15)),
          ),
          child: TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Search by name or email…',
              hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.35), fontSize: 14),
              prefixIcon: Icon(Icons.search_rounded, color: cs.onSurface.withOpacity(0.35), size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _Chip('All', _filter == null, null, () => setState(() => _filter = null)),
            const SizedBox(width: 8),
            for (final s in CustomerStatus.values) ...[
              _Chip(s.label, _filter == s, s.color, () => setState(() => _filter = _filter == s ? null : s)),
              if (s != CustomerStatus.values.last) const SizedBox(width: 8),
            ],
          ]),
        ),

        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 2),
          child: Text('${filtered.length} customer${filtered.length == 1 ? '' : 's'}',
              style: tt.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.4), fontWeight: FontWeight.w600, letterSpacing: 0.4)),
        ),

        // List
        if (filtered.isEmpty)
          Center(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Column(children: [
              Icon(Icons.person_search_rounded, size: 48, color: cs.onSurface.withOpacity(0.2)),
              const SizedBox(height: 12),
              Text('No customers found', style: tt.bodyMedium?.copyWith(color: cs.onSurface.withOpacity(0.4))),
            ]),
          ))
        else
          ListView.separated(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _CustomerCard(filtered[i]),
          ),

        const SizedBox(height: 32),
      ]),
    );
  }
}

// ── Summary card ───────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard(this.label, this.count, this.icon, this.color, this.bg);
  final String label; final int count; final IconData icon; final Color color, bg;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    child: Row(children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 18),
      ),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('$count', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color, height: 1.1)),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color.withOpacity(0.75)), overflow: TextOverflow.ellipsis),
      ])),
    ]),
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

// ── Customer card ──────────────────────────────────────────────────────────

class _CustomerCard extends StatelessWidget {
  const _CustomerCard(this.c);
  final Customer c;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16), onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outline.withOpacity(0.12)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              // Left accent bar
              Container(width: 4, color: _primary),

              Expanded(child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  // Top row: avatar + name + status
                  Row(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: _abg(c.initials), shape: BoxShape.circle),
                      child: Center(child: Text(c.initials, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _afg(c.initials)))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(c.name, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      Text(c.email, style: tt.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.45), fontSize: 12)),
                    ])),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: c.status.bg, borderRadius: BorderRadius.circular(20)),
                      child: Text(c.status.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c.status.color)),
                    ),
                  ]),

                  const SizedBox(height: 12),
                  Divider(height: 1, color: cs.outline.withOpacity(0.08)),
                  const SizedBox(height: 12),

                  // Bottom row: meta chips + view button
                  Row(children: [
                    _MetaChip(Icons.location_on_outlined, c.location.split(',').first, cs),
                    const SizedBox(width: 8),
                    _MetaChip(Icons.recycling_rounded, '${c.collections} pickups', cs),
                    const SizedBox(width: 8),
                    _MetaChip(Icons.workspace_premium_outlined, c.plan, cs),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: _primary,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('View', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ]),
                ]),
              )),
            ])),
          ),
        ),
      ),
    );
  }
}

// ── Meta chip ──────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  const _MetaChip(this.icon, this.label, this.cs);
  final IconData icon; final String label; final ColorScheme cs;

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 12, color: cs.onSurface.withOpacity(0.4)),
    const SizedBox(width: 3),
    Text(label, style: TextStyle(fontSize: 11, color: cs.onSurface.withOpacity(0.5), fontWeight: FontWeight.w500)),
  ]);
}