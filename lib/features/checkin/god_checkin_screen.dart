import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/streak_provider.dart';
import '../../core/theme/app_theme.dart';

/// "How's your relationship with God today?" — green theme, smiley.
/// Slider 1-10, emoji shifts from sad to radiant.
class GodCheckinScreen extends ConsumerStatefulWidget {
  const GodCheckinScreen({super.key});
  @override
  ConsumerState<GodCheckinScreen> createState() => _GodCheckinScreenState();
}

class _GodCheckinScreenState extends ConsumerState<GodCheckinScreen> {
  double _value = 7;

  @override
  void initState() {
    super.initState();
    final current = ref.read(godMoodProvider);
    if (current != null) _value = current.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.moodGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(flex: 1),
              const Text(
                "how's your relationship\nwith God today?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 48),
              Text(_emojiFor(_value), style: const TextStyle(fontSize: 80)),
              const SizedBox(height: 32),
              Slider(
                value: _value,
                min: 1,
                max: 10,
                divisions: 9,
                onChanged: (v) => setState(() => _value = v),
              ),
              const SizedBox(height: 12),
              Text(
                _labelFor(_value),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(flex: 2),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.moodGreen,
                  ),
                  child: const Text('continue'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    await ref.read(godMoodProvider.notifier).set(_value.round());
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  String _emojiFor(double v) {
    if (v <= 2) return '😔';
    if (v <= 4) return '😕';
    if (v <= 6) return '🙂';
    if (v <= 8) return '😊';
    return '😄';
  }

  String _labelFor(double v) {
    if (v <= 2) return 'far';
    if (v <= 4) return 'strained';
    if (v <= 6) return 'present';
    if (v <= 8) return 'good';
    return 'radiant';
  }
}
