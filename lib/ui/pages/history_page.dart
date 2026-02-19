import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/entree_historique.dart';
import '../../providers/historique_provider.dart';
import '../../utils/constants.dart';
import '../components/section_panel.dart';

/// Page historique des analyses.
class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final histAsync = ref.watch(historiqueProvider);
    return histAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
      data: (entries) => _buildContent(entries),
    );
  }

  Widget _buildContent(List<EntreeHistorique> entries) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Historique',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
          Text('${entries.length} analyse${entries.length > 1 ? 's' : ''}',
              style: const TextStyle(color: AppColors.texteSecondaire)),
        ]),
        const SizedBox(height: 16),

        if (entries.isEmpty)
          Container(
            width: double.infinity, padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(color: AppColors.panneau, borderRadius: BorderRadius.circular(15)),
            child: const Text(
              'Aucune analyse dans l\'historique\n\nLancez une analyse depuis la page Analyse',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.texteSecondaire, fontSize: 14)),
          )
        else
          ...entries.map((e) => _HistoryCard(entry: e)),
      ]),
    );
  }
}

class _HistoryCard extends StatefulWidget {
  final EntreeHistorique entry;
  const _HistoryCard({required this.entry});

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    final isDetaille = e.mode == 'detaille';
    final badgeColor = isDetaille ? AppColors.violet : AppColors.accent;

    // Format date
    String dateStr = e.date;
    try {
      final dt = DateTime.parse(e.date);
      dateStr = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {}

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: SectionPanel(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Row(children: [
            Expanded(child: Text(dateStr,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10)),
              child: Text(isDetaille ? 'Detaillee' : 'Rapide',
                  style: TextStyle(fontSize: 10, color: badgeColor, fontWeight: FontWeight.w600)),
            ),
          ]),

          // Resume
          if (e.resumeIa.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              _expanded ? e.resumeIa : _truncate(e.resumeIa, 100),
              style: const TextStyle(fontSize: 12, color: AppColors.texteSecondaire, fontStyle: FontStyle.italic),
            ),
          ],

          // Contenu expanse
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _expandedContent(e),
            crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ]),
      ),
    );
  }

  Widget _expandedContent(EntreeHistorique e) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (e.routineMatin.isNotEmpty) ...[
          const Text('Routine Matin', style: TextStyle(color: Color(0xFFF9ED69), fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ...e.routineMatin.asMap().entries.map((entry) {
            final r = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text('${entry.key + 1}. ${r['produit'] ?? ''} — ${r['raison'] ?? ''}',
                  style: const TextStyle(fontSize: 12)),
            );
          }),
          const SizedBox(height: 8),
        ],
        if (e.routineSoir.isNotEmpty) ...[
          const Text('Routine Soir', style: TextStyle(color: AppColors.violet, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ...e.routineSoir.asMap().entries.map((entry) {
            final r = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text('${entry.key + 1}. ${r['produit'] ?? ''} — ${r['raison'] ?? ''}',
                  style: const TextStyle(fontSize: 12)),
            );
          }),
          const SizedBox(height: 8),
        ],
        if (e.alertes.isNotEmpty) ...[
          ...e.alertes.map((a) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text('\u26a0 $a', style: const TextStyle(fontSize: 12, color: AppColors.danger)),
          )),
          const SizedBox(height: 8),
        ],
        if (e.activitesJour.isNotEmpty) ...[
          ...e.activitesJour.map((a) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text('\u2022 $a', style: const TextStyle(fontSize: 12, color: Color(0xFF00B4D8))),
          )),
          const SizedBox(height: 8),
        ],
        if (e.conseilsJour.isNotEmpty)
          Container(
            width: double.infinity, padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8)),
            child: Text('\u{1f4a1} ${e.conseilsJour}',
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.accent)),
          ),
      ]),
    );
  }

  String _truncate(String text, int max) =>
      text.length > max ? '${text.substring(0, max)}...' : text;
}
