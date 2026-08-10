import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/chat_data.dart';
import '../theme.dart';
import 'analyzing_screen.dart';

/// 确认页：选择「哪个是我」+ 关系类型（决定 LLM 解读口径）。
class SetupScreen extends StatefulWidget {
  final ChatData data;
  const SetupScreen({super.key, required this.data});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  Relationship? _relationship;
  late String _you = widget.data.participants.first;

  String get _partner => widget.data.participants
      .firstWhere((p) => p != _you, orElse: () => 'Them');

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final data = widget.data;
    final fmt =
        '${_monthName(data.firstDate)} ${data.firstDate.year} – ${_monthName(data.lastDate)} ${data.lastDate.year}';

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              Text(l.setupTitle,
                  style: const TextStyle(
                      fontSize: 21, fontWeight: FontWeight.w700)),
              Text(l.setupSubtitle,
                  style: const TextStyle(fontSize: 13, color: UColors.muted)),
              const SizedBox(height: 16),
              UCard(
                child: Row(
                  children: [
                    UAvatar(_partner, isYou: false),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.setupChatWith(_partner),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.5)),
                          Text(
                              l.setupMessageCount(data.messages.length, fmt),
                              style: const TextStyle(
                                  fontSize: 11.5, color: UColors.muted)),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle,
                        color: UColors.blue, size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ULabel(l.setupWhichIsYou),
              Wrap(
                spacing: 8,
                children: [
                  for (final p in data.participants)
                    ChoiceChip(
                      label: Text(p),
                      selected: _you == p,
                      selectedColor: UColors.rose,
                      labelStyle: TextStyle(
                        fontSize: 12.5,
                        color: _you == p ? Colors.white : UColors.ink2,
                        fontWeight:
                            _you == p ? FontWeight.w600 : FontWeight.w400,
                      ),
                      onSelected: (_) => setState(() => _you = p),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              ULabel(l.setupRelationship),
              Wrap(
                spacing: 8,
                runSpacing: 2,
                children: [
                  for (final r in Relationship.values)
                    ChoiceChip(
                      label: Text(r.label(l)),
                      selected: _relationship == r,
                      selectedColor: UColors.rose,
                      labelStyle: TextStyle(
                        fontSize: 12.5,
                        color: _relationship == r
                            ? Colors.white
                            : UColors.ink2,
                        fontWeight: _relationship == r
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      onSelected: (_) => setState(() => _relationship = r),
                    ),
                ],
              ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: UColors.rose,
                  disabledBackgroundColor:
                      UColors.rose.withValues(alpha: .35),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: const StadiumBorder(),
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _relationship == null
                    ? null
                    : () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => AnalyzingScreen(
                            data: widget.data,
                            you: _you,
                            relationship: _relationship!,
                          ),
                        )),
                child: Text(l.setupAnalyze,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),
              Center(child: PrivacyNote(l.setupPrivacy)),
            ],
          ),
        ),
      ),
    );
  }

  static String _monthName(DateTime d) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][d.month - 1];
}
