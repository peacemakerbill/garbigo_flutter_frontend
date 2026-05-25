import 'package:flutter/material.dart';

// ── Enums ──────────────────────────────────────────────────────────────────

enum Priority { high, medium, low }
enum Status { open, inProgress, resolved }

// Garbage app palette: deep forest green primary, amber warning, earthy tones
extension PriorityX on Priority {
  String get label => ['High', 'Medium', 'Low'][index];
  Color get color => [const Color(0xFFB84C00), const Color(0xFF8A7200), const Color(0xFF2E6B3E)][index];
  Color get bg   => [const Color(0xFFFFF0E6), const Color(0xFFFBF7E0), const Color(0xFFEAF5EE)][index];
  IconData get icon => [Icons.keyboard_double_arrow_up_rounded, Icons.drag_handle_rounded, Icons.keyboard_double_arrow_down_rounded][index];
}

extension StatusX on Status {
  String get label => ['Open', 'In Progress', 'Resolved'][index];
  Color get color => [const Color(0xFF1B5E35), const Color(0xFF4A6741), const Color(0xFF2E6B3E)][index];
  Color get bg   => [const Color(0xFFE4F5EC), const Color(0xFFEEF4EA), const Color(0xFFD6EFE0)][index];
}

// ── Model ──────────────────────────────────────────────────────────────────

class Ticket {
  const Ticket(this.id, this.subject, this.client, this.initials, this.ago, this.priority, this.status, this.category);
  final String id, subject, client, initials, ago, category;
  final Priority priority;
  final Status status;
}

const _tickets = [
  Ticket('SUP-100', 'Payment declined on checkout',       'Jane Muthoni', 'JM', '2h ago',  Priority.high,   Status.open,       'Billing'),
  Ticket('SUP-101', 'Cannot reset account password',      'Brian Otieno', 'BO', '4h ago',  Priority.medium, Status.inProgress, 'Account'),
  Ticket('SUP-102', 'API rate limit exceeded',            'Amara Diallo', 'AD', '6h ago',  Priority.high,   Status.open,       'Technical'),
  Ticket('SUP-103', 'Subscription upgrade not applied',   'Leila Hassan', 'LH', '8h ago',  Priority.medium, Status.inProgress, 'Billing'),
  Ticket('SUP-104', 'Dashboard charts not loading',       'Marcus Owusu', 'MO', '1d ago',  Priority.low,    Status.resolved,   'Technical'),
  Ticket('SUP-105', 'Invoice PDF missing line items',     'Priya Nair',   'PN', '1d ago',  Priority.high,   Status.open,       'Billing'),
];

// ── Avatar helpers ─────────────────────────────────────────────────────────

final _avatarBgs = [const Color(0xFFE4F5EC), const Color(0xFFF5F0E4), const Color(0xFFEAF2E4), const Color(0xFFF5EDE4), const Color(0xFFDFF0E8), const Color(0xFFF0F5E4)];
final _avatarFgs = [const Color(0xFF1B5E35), const Color(0xFF7A5000), const Color(0xFF3A6B2A), const Color(0xFF8B4513), const Color(0xFF2E6B3E), const Color(0xFF556B2F)];
Color _bg(String i) => _avatarBgs[i.codeUnitAt(0) % 6];
Color _fg(String i) => _avatarFgs[i.codeUnitAt(0) % 6];

// ── Main widget ────────────────────────────────────────────────────────────

class SupportTicketsContent extends StatefulWidget {
  const SupportTicketsContent({super.key});
  @override State<SupportTicketsContent> createState() => _State();
}

class _State extends State<SupportTicketsContent> {
  Status? _status;
  Priority? _priority;

  List<Ticket> get _filtered => _tickets.where((t) {
    if (_status != null && t.status != _status) return false;
    if (_priority != null && t.priority != _priority) return false;
    return true;
  }).toList();

  int _count(Status s) => _tickets.where((t) => t.status == s).length;
  int get _highCount => _tickets.where((t) => t.priority == Priority.high).length;

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
            Text('Support Tickets', style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5)),
            const SizedBox(height: 4),
            Text('Manage and resolve customer requests', style: tt.bodyMedium?.copyWith(color: cs.onSurface.withOpacity(0.5))),
          ])),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('New ticket'),
            style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ]),

        const SizedBox(height: 20),

        // Summary cards
        LayoutBuilder(builder: (ctx, box) {
          final cols = box.maxWidth < 400 ? 2 : 3;
          return GridView.count(
            crossAxisCount: cols, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.8,
            children: [
              _SummaryCard('Open',         _count(Status.open),       Icons.inbox_rounded,        const Color(0xFF1B5E35), const Color(0xFFE4F5EC)),
              _SummaryCard('In Progress',  _count(Status.inProgress), Icons.autorenew_rounded,    const Color(0xFF7A5000), const Color(0xFFFBF7E0)),
              _SummaryCard('High Priority',_highCount,                Icons.priority_high_rounded, const Color(0xFFB84C00), const Color(0xFFFFF0E6)),
            ],
          );
        }),

        const SizedBox(height: 20),

        // Filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _Chip('All', _status == null && _priority == null, null, () => setState(() { _status = null; _priority = null; })),
            const SizedBox(width: 8),
            for (final s in Status.values) ...[
              _Chip(s.label, _status == s, s.color, () => setState(() { _status = _status == s ? null : s; _priority = null; })),
              const SizedBox(width: 8),
            ],
            for (final p in Priority.values) ...[
              _Chip(p.label, _priority == p, p.color, () => setState(() { _priority = _priority == p ? null : p; _status = null; })),
              if (p != Priority.low) const SizedBox(width: 8),
            ],
          ]),
        ),

        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 2),
          child: Text('${filtered.length} ticket${filtered.length == 1 ? '' : 's'}',
              style: tt.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.4), fontWeight: FontWeight.w600, letterSpacing: 0.4)),
        ),

        // List
        if (filtered.isEmpty)
          Center(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Column(children: [
              Icon(Icons.inbox_outlined, size: 48, color: cs.onSurface.withOpacity(0.2)),
              const SizedBox(height: 12),
              Text('No tickets match this filter', style: tt.bodyMedium?.copyWith(color: cs.onSurface.withOpacity(0.4))),
            ]),
          ))
        else
          ListView.separated(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _TicketCard(filtered[i]),
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
    final c = color ?? Theme.of(context).colorScheme.primary;
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

// ── Ticket card ────────────────────────────────────────────────────────────

class _TicketCard extends StatelessWidget {
  const _TicketCard(this.t);
  final Ticket t;

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
            boxShadow: t.priority == Priority.high
                ? [BoxShadow(color: t.priority.color.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 2))]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              // Priority bar
              Container(width: 4, color: t.priority.color),

              Expanded(child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  // Top row
                  Row(children: [
                    Text(t.id, style: tt.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.4), fontWeight: FontWeight.w600, letterSpacing: 0.4)),
                    const Spacer(),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: t.status.bg, borderRadius: BorderRadius.circular(20)),
                      child: Text(t.status.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.status.color)),
                    ),
                  ]),

                  const SizedBox(height: 8),
                  Text(t.subject, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600, height: 1.3)),
                  const SizedBox(height: 12),

                  // Bottom row
                  Row(children: [
                    // Avatar
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(color: _bg(t.initials), shape: BoxShape.circle),
                      child: Center(child: Text(t.initials, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _fg(t.initials)))),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(t.client, style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
                      Text(t.ago, style: tt.bodySmall?.copyWith(fontSize: 11, color: cs.onSurface.withOpacity(0.4))),
                    ])),
                    // Category
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: cs.onSurface.withOpacity(0.06), borderRadius: BorderRadius.circular(20)),
                      child: Text(t.category, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: cs.onSurface.withOpacity(0.55))),
                    ),
                    const SizedBox(width: 8),
                    // Priority badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: t.priority.bg, borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(t.priority.icon, size: 12, color: t.priority.color),
                        const SizedBox(width: 3),
                        Text(t.priority.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.priority.color)),
                      ]),
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