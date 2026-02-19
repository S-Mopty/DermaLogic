import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/profil_utilisateur.dart';
import '../../providers/profil_provider.dart';
import '../../utils/constants.dart';
import '../components/section_panel.dart';

/// Page profil utilisateur.
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  TypePeau _typePeau = TypePeau.normale;
  TrancheAge _trancheAge = TrancheAge.age2635;
  double _stress = 5;
  final Set<String> _maladies = {};
  final _customMaladieCtrl = TextEditingController();
  final Set<String> _customMaladies = {};
  String _allergies = '';
  final Set<ObjectifPeau> _objectifs = {};
  String _instructions = '';
  String _status = '';
  bool _loaded = false;

  static const _maladiesPredefinies = [
    'Eczema', 'Psoriasis', 'Rosacee', 'Dermatite',
    'Acne', 'Vitiligo', 'Keratose', 'Couperose',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadProfile);
  }

  Future<void> _loadProfile() async {
    final profil = await ref.read(profilProvider.future);
    if (!mounted) return;
    setState(() {
      _typePeau = profil.typePeau;
      _trancheAge = profil.trancheAge;
      _stress = profil.niveauStress.toDouble();
      _maladies.clear();
      _customMaladies.clear();
      for (final m in profil.maladiesPeau) {
        if (_maladiesPredefinies.contains(m)) {
          _maladies.add(m);
        } else {
          _customMaladies.add(m);
        }
      }
      _allergies = profil.allergies.join(', ');
      _objectifs
        ..clear()
        ..addAll(profil.objectifs);
      _instructions = profil.instructionsQuotidiennes;
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _customMaladieCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SectionPanel(
            title: 'Informations generales',
            child: Column(
              children: [
                Row(children: [
                  Expanded(
                    child: DropdownButtonFormField<TypePeau>(
                      initialValue: _typePeau,
                      decoration: const InputDecoration(labelText: 'Type de peau'),
                      dropdownColor: AppColors.panneau,
                      items: TypePeau.values.map((t) =>
                        DropdownMenuItem(value: t, child: Text(_typePeauLabel(t)))).toList(),
                      onChanged: (v) => setState(() => _typePeau = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<TrancheAge>(
                      initialValue: _trancheAge,
                      decoration: const InputDecoration(labelText: 'Tranche d\'age'),
                      dropdownColor: AppColors.panneau,
                      items: TrancheAge.values.map((t) =>
                        DropdownMenuItem(value: t, child: Text(t.value))).toList(),
                      onChanged: (v) => setState(() => _trancheAge = v!),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Text('Stress : ${_stress.round()}/10', style: const TextStyle(fontSize: 14)),
                ]),
                Slider(value: _stress, min: 1, max: 10, divisions: 9,
                    onChanged: (v) => setState(() => _stress = v)),
              ],
            ),
          ),

          SectionPanel(
            title: 'Conditions cutanees',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8, runSpacing: 6,
                  children: [
                    ..._maladiesPredefinies.map((m) => FilterChip(
                      label: Text(m), selected: _maladies.contains(m),
                      selectedColor: AppColors.accent, checkmarkColor: AppColors.fond,
                      onSelected: (s) => setState(() => s ? _maladies.add(m) : _maladies.remove(m)),
                    )),
                    ..._customMaladies.map((m) => FilterChip(
                      label: Text(m), selected: true,
                      selectedColor: AppColors.violet, checkmarkColor: Colors.white,
                      onSelected: (_) => setState(() => _customMaladies.remove(m)),
                    )),
                  ],
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: TextField(
                    controller: _customMaladieCtrl,
                    decoration: const InputDecoration(hintText: 'Ajouter une condition...', isDense: true),
                    onSubmitted: (_) => _addCustomMaladie(),
                  )),
                  const SizedBox(width: 8),
                  IconButton(onPressed: _addCustomMaladie,
                      icon: const Icon(Icons.add, color: AppColors.accent)),
                ]),
              ],
            ),
          ),

          SectionPanel(
            title: 'Allergies / intolerances',
            child: TextFormField(
              initialValue: _allergies, maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Ex: parfum, alcool, retinol (separes par des virgules)'),
              onChanged: (v) => _allergies = v,
            ),
          ),

          SectionPanel(
            title: 'Objectifs de soin',
            child: Wrap(
              spacing: 8, runSpacing: 6,
              children: ObjectifPeau.values.map((o) => FilterChip(
                label: Text(_objectifLabel(o)), selected: _objectifs.contains(o),
                selectedColor: AppColors.accent, checkmarkColor: AppColors.fond,
                onSelected: (s) => setState(() => s ? _objectifs.add(o) : _objectifs.remove(o)),
              )).toList(),
            ),
          ),

          SectionPanel(
            title: 'Instructions quotidiennes',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextFormField(
                initialValue: _instructions, maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Ex: J\'ai la peau irritee, eviter les actifs forts...'),
                onChanged: (v) => _instructions = v,
              ),
              const SizedBox(height: 4),
              const Text('Ces instructions seront prises en compte a chaque analyse.',
                  style: TextStyle(fontSize: 10, color: AppColors.texteSecondaire)),
            ]),
          ),

          SizedBox(
            width: double.infinity, height: 45,
            child: ElevatedButton(onPressed: _save,
              child: const Text('Sauvegarder le profil',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
          ),
          if (_status.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(_status, style: const TextStyle(color: AppColors.accent, fontSize: 13)),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _addCustomMaladie() {
    final t = _customMaladieCtrl.text.trim();
    if (t.isNotEmpty) setState(() { _customMaladies.add(t); _customMaladieCtrl.clear(); });
  }

  Future<void> _save() async {
    final profil = ProfilUtilisateur(
      typePeau: _typePeau, trancheAge: _trancheAge, niveauStress: _stress.round(),
      maladiesPeau: [..._maladies, ..._customMaladies],
      allergies: _allergies.split(',').map((a) => a.trim()).where((a) => a.isNotEmpty).toList(),
      objectifs: _objectifs.toList(), instructionsQuotidiennes: _instructions,
    );
    await ref.read(profilProvider.notifier).save(profil);
    if (mounted) setState(() => _status = 'Profil sauvegarde !');
  }

  String _typePeauLabel(TypePeau t) => switch (t) {
    TypePeau.normale => 'Normale', TypePeau.grasse => 'Grasse',
    TypePeau.seche => 'Seche', TypePeau.mixte => 'Mixte', TypePeau.sensible => 'Sensible',
  };

  String _objectifLabel(ObjectifPeau o) => switch (o) {
    ObjectifPeau.hydratation => 'Hydratation', ObjectifPeau.antiAcne => 'Anti-acne',
    ObjectifPeau.eclat => 'Eclat', ObjectifPeau.antiTaches => 'Anti-taches',
    ObjectifPeau.antiAge => 'Anti-age', ObjectifPeau.apaisement => 'Apaisement',
    ObjectifPeau.protection => 'Protection',
  };
}
