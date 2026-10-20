import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '../services/speech.dart';
import '../theme.dart';
import '../widgets.dart';

const String buildNumber = String.fromEnvironment('BUILD_NUMBER', defaultValue: 'dev');

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Future<bool?> _voice = Speech.japaneseVoiceInstalled();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final state = AppState.instance;
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: state,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              const Row(
                children: [
                  BackSquare(),
                  SizedBox(width: 10),
                  Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 22),
              const SectionLabel('Appearance'),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(value: ThemeMode.system, label: Text('System')),
                    ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                    ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                  ],
                  selected: {state.themeMode},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) => state.setThemeMode(s.first),
                ),
              ),
              const SizedBox(height: 6),
              Text("System follows your phone's light or dark setting",
                  style: TextStyle(fontSize: 12, color: c.muted)),
              const SizedBox(height: 22),
              const SectionLabel('Sound'),
              Panel(
                padding: EdgeInsets.zero,
                child: SwitchListTile(
                  title: const Text('Play sound when a card flips',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  subtitle: Text('Turn off for quiet places', style: TextStyle(fontSize: 12, color: c.muted)),
                  value: state.autoPlay,
                  onChanged: state.setAutoPlay,
                ),
              ),
              const SizedBox(height: 22),
              const SectionLabel('Offline voice'),
              Panel(
                child: FutureBuilder<bool?>(
                  future: _voice,
                  builder: (context, snap) {
                    final installed = snap.data;
                    final status = snap.connectionState != ConnectionState.done
                        ? 'Checking…'
                        : installed == true
                            ? 'Installed'
                            : installed == false
                                ? 'Not installed'
                                : 'Could not check';
                    final color = installed == true ? c.green : c.amber;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text('Japanese voice', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                            ),
                            Text(status, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          Speech.voiceCredit != null
                              ? 'Kana and example words use built-in recordings and always work offline. '
                                  'The phone voice is only a backup for words without a recording.'
                              : installed == true
                                  ? 'Sounds will work without internet. Test it in airplane mode to be sure.'
                                  : 'Sounds use your phone\'s text-to-speech. Open Android Settings, search for '
                                      '"text-to-speech", and install the Japanese voice for the speech engine.',
                          style: TextStyle(fontSize: 13, color: c.muted),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => Speech.speak('おちゃ'),
                              icon: const Icon(Icons.volume_up_rounded),
                              label: const Text('Test: おちゃ'),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () => setState(() => _voice = Speech.japaneseVoiceInstalled()),
                              child: const Text('Check again'),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 22),
              const SectionLabel('Credits'),
              Panel(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    const _CreditRow(
                      name: 'Klee One',
                      what: 'Font for the kana cards · Fontworks',
                      license: 'SIL Open Font License 1.1',
                      first: true,
                    ),
                    const _CreditRow(
                      name: 'M PLUS Rounded 1c',
                      what: 'App font · M+ Fonts Project',
                      license: 'SIL Open Font License 1.1',
                    ),
                    if (Speech.voiceCredit != null)
                      _CreditRow(
                        name: Speech.voiceCredit!,
                        what: 'Voice for the kana and example words · VOICEVOX',
                        license: 'Used under the VOICEVOX and No.7 terms of use',
                      )
                    else
                      const _CreditRow(
                        name: 'Sounds',
                        what: "Your phone's Japanese text-to-speech voice",
                        license: 'Provided by your phone',
                      ),
                    ListTile(
                      shape: Border(top: BorderSide(color: c.line)),
                      title: const Text('Open-source licenses', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      trailing: Icon(Icons.chevron_right_rounded, color: c.muted),
                      onTap: () => showLicensePage(
                        context: context,
                        applicationName: 'Kana Cards',
                        applicationVersion: 'Build $buildNumber',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Center(child: Text('Kana Cards · build $buildNumber', style: TextStyle(fontSize: 12, color: c.muted))),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreditRow extends StatelessWidget {
  const _CreditRow({required this.name, required this.what, required this.license, this.first = false});

  final String name;
  final String what;
  final String license;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: first ? null : Border(top: BorderSide(color: c.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          Text(what, style: TextStyle(fontSize: 12, color: c.muted)),
          Text(license, style: TextStyle(fontSize: 12, color: c.blue)),
        ],
      ),
    );
  }
}
