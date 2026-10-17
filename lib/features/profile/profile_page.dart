import 'package:flutter/material.dart';

import '../../core/utils/nav.dart';
import '../../data/repositories/app_state.dart';
import '../../shared/widgets/glass_card.dart';
import '../progress/progress_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.state});
  final AppState state;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final TextEditingController _name =
      TextEditingController(text: widget.state.nickname);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _confirmReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('پاک کردن پیشرفت؟'),
        content: const Text(
            'امتیاز، دستاوردها، تاریخچه و وضعیت واژگان برای همیشه پاک می‌شود.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('پاک کن'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await widget.state.resetProgress();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('پیشرفت پاک شد.')));
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    return ListenableBuilder(
      listenable: s,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('پروفایل و تنظیمات',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: 'نام مستعار',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: s.setNickname,
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => s.setNickname(_name.text),
                  child: const Text('ذخیره'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('تم'),
                const SizedBox(height: 8),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                        value: ThemeMode.system, label: Text('سیستم')),
                    ButtonSegment(value: ThemeMode.light, label: Text('روشن')),
                    ButtonSegment(value: ThemeMode.dark, label: Text('تیره')),
                  ],
                  selected: {s.themeMode},
                  onSelectionChanged: (v) => s.setThemeMode(v.first),
                ),
                SwitchListTile(
                  value: s.haptics,
                  onChanged: s.setHaptics,
                  title: const Text('لرزش هنگام پاسخ'),
                ),
                const SwitchListTile(
                  value: false,
                  onChanged: null,
                  title: Text('صدا'),
                  subtitle: Text('به‌زودی'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.insights),
            title: const Text('داشبورد پیشرفت'),
            onTap: () => openPage(context, 'پیشرفت', ProgressPage(state: s)),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('پاک کردن پیشرفت'),
            onTap: _confirmReset,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('دربارهٔ روبو عربی'),
            subtitle: Text(
              'نسخهٔ محتوا: ${s.content.version}\n'
              'حالت آفلاین: همهٔ امکانات بدون اینترنت کار می‌کنند.',
            ),
          ),
        ],
      ),
    );
  }
}
