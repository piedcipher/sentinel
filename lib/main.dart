import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const SentinelApp());
}

class Level {
  const Level(this.days, this.name);
  final int days;
  final String name;
}

class Habit {
  const Habit({
    required this.id,
    required this.title,
    required this.hero,
    required this.icon,
    required this.emoji,
    required this.color,
    required this.levels,
    required this.quote,
  });
  final String id;
  final String title;
  final String hero;
  final IconData icon;
  final String emoji;
  final Color color;
  final List<Level> levels;
  final String quote;
}

// Reacher: the drifter who needs nothing. Batman: discipline over impulse.
const habits = [
  Habit(
    id: 'smoking',
    title: 'Cigarettes',
    hero: 'REACHER',
    icon: Icons.smoke_free,
    emoji: '🚬',
    color: Color(0xFFF2C94C),
    quote: 'Hope for the best. Plan for the worst.',
    levels: [
      Level(0, 'Civilian'),
      Level(1, 'Recruit'),
      Level(3, 'Private'),
      Level(7, 'Corporal'),
      Level(14, 'Sergeant'),
      Level(30, 'Lieutenant'),
      Level(60, 'Captain'),
      Level(90, 'Major'),
      Level(180, 'Colonel'),
      Level(365, 'Jack Reacher'),
    ],
  ),
  Habit(
    id: 'fap',
    title: 'Fap',
    hero: 'BATMAN',
    icon: Icons.shield_outlined,
    emoji: '🛡️',
    color: Color(0xFF3A63C8),
    quote: "It's not who I am underneath, but what I do that defines me.",
    levels: [
      Level(0, 'Bruce Wayne'),
      Level(1, 'Street Thug'),
      Level(3, 'Gotham Cop'),
      Level(7, 'Vigilante'),
      Level(14, 'Detective'),
      Level(30, 'Dark Knight'),
      Level(60, 'Worlds Finest'),
      Level(90, 'Justice League'),
      Level(180, 'The Bat'),
      Level(365, 'Batman'),
    ],
  ),
];

class SentinelApp extends StatelessWidget {
  const SentinelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sentinel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF08080B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
        ),
      ),
      home: const Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  SharedPreferences? _prefs;
  Timer? _ticker;
  final _pages = PageController();
  int _page = 0;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) async {
      for (final h in habits) {
        if (p.getInt('${h.id}_start') == null) {
          await p.setInt(
            '${h.id}_start',
            DateTime.now().millisecondsSinceEpoch,
          );
        }
      }
      if (mounted) setState(() => _prefs = p);
    });
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => mounted ? setState(() {}) : null,
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pages.dispose();
    super.dispose();
  }

  Duration _streak(Habit h) {
    final ms = _prefs?.getInt('${h.id}_start');
    if (ms == null) return Duration.zero;
    final d = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(ms),
    );
    return d.isNegative ? Duration.zero : d;
  }

  int _best(Habit h) => _prefs?.getInt('${h.id}_best') ?? 0;
  int _relapses(Habit h) => _prefs?.getInt('${h.id}_relapses') ?? 0;

  Future<void> _relapse(Habit h) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Reset ${h.title}?'),
        content: const Text(
          'Counter goes back to zero. Own it, then start again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('I relapsed'),
          ),
        ],
      ),
    );
    if (ok != true || _prefs == null) return;
    final days = _streak(h).inDays;
    if (days > _best(h)) await _prefs!.setInt('${h.id}_best', days);
    await _prefs!.setInt('${h.id}_relapses', _relapses(h) + 1);
    await _prefs!.setInt(
      '${h.id}_start',
      DateTime.now().millisecondsSinceEpoch,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_prefs == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final accent = habits[_page].color;
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.5),
            radius: 1.1,
            colors: [accent.withValues(alpha: 0.18), const Color(0xFF08080B)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pages,
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [
                    for (final h in habits)
                      HabitPage(
                        habit: h,
                        streak: _streak(h),
                        best: _best(h),
                        relapses: _relapses(h),
                        onRelapse: () => _relapse(h),
                      ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < habits.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _page ? 22 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == _page ? accent : Colors.white24,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class HabitPage extends StatelessWidget {
  const HabitPage({
    super.key,
    required this.habit,
    required this.streak,
    required this.best,
    required this.relapses,
    required this.onRelapse,
  });

  final Habit habit;
  final Duration streak;
  final int best;
  final int relapses;
  final VoidCallback onRelapse;

  String _two(int n) => n.toString().padLeft(2, '0');

  void _showLevels(BuildContext context, int current) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              '${habit.title.toUpperCase()} LEVELS',
              style: TextStyle(
                color: habit.color,
                fontSize: 16,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < habit.levels.length; i++)
              ListTile(
                dense: true,
                selected: i == current,
                selectedColor: habit.color,
                leading: Icon(
                  i <= current ? Icons.check_circle : Icons.lock_outline,
                ),
                title: Text('Level ${i + 1} · ${habit.levels[i].name}'),
                trailing: Text(
                  habit.levels[i].days == 0
                      ? 'Start'
                      : '${habit.levels[i].days} days',
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = streak.inDays;
    var idx = 0;
    for (var i = 0; i < habit.levels.length; i++) {
      if (days >= habit.levels[i].days) idx = i;
    }
    final level = habit.levels[idx];
    final next = idx == habit.levels.length - 1 ? null : habit.levels[idx + 1];
    final progress = next == null
        ? 1.0
        : ((streak.inSeconds - level.days * 86400) /
                  ((next.days - level.days) * 86400))
              .clamp(0.0, 1.0);
    final c = habit.color;
    const dim = TextStyle(
      color: Colors.white38,
      fontSize: 12,
      letterSpacing: 2,
    );

    return LayoutBuilder(
      builder: (context, box) {
        final ring = math.max(
          140.0,
          math.min(math.min(box.maxWidth * 0.7, box.maxHeight * 0.36), 340.0),
        );
        final s = ring / 260;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: box.maxWidth < 400 ? 20 : 32,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: box.maxHeight),
                child: IntrinsicHeight(
                  child: _content(
                    context,
                    days,
                    idx,
                    level,
                    next,
                    progress,
                    c,
                    dim,
                    ring,
                    s,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _content(
    BuildContext context,
    int days,
    int idx,
    Level level,
    Level? next,
    double progress,
    Color c,
    TextStyle dim,
    double ring,
    double s,
  ) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                '${habit.emoji}  ${habit.title.toUpperCase()}  ·  ${habit.hero}',
                style: dim,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              tooltip: 'Levels',
              icon: const Icon(
                Icons.info_outline,
                size: 20,
                color: Colors.white38,
              ),
              onPressed: () => _showLevels(context, idx),
            ),
          ],
        ),
        const Spacer(),
        SizedBox(
          width: ring,
          height: ring,
          child: CustomPaint(
            painter: _RingPainter(progress: progress, color: c),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(habit.emoji, style: TextStyle(fontSize: 28 * s)),
                    const SizedBox(height: 4),
                    Text(
                      '$days',
                      style: TextStyle(
                        fontSize: 84 * s,
                        fontWeight: FontWeight.w200,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(days == 1 ? 'DAY' : 'DAYS', style: dim),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 28 * s),
        Text(
          '${_two(streak.inHours % 24)}:${_two(streak.inMinutes % 60)}:${_two(streak.inSeconds % 60)}',
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white54,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        SizedBox(height: 28 * s),
        Text(
          level.name.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: c,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          next == null ? 'Max level' : '${next.days - days}d to ${next.name}',
          style: const TextStyle(color: Colors.white38),
        ),
        const Spacer(),
        const SizedBox(height: 16),
        Text(
          '“${habit.quote}”',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white30,
            fontStyle: FontStyle.italic,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Stat(label: 'BEST', value: '${best > days ? best : days}d'),
            _Stat(label: 'LEVEL', value: '${idx + 1}/${habit.levels.length}'),
            _Stat(label: 'RELAPSES', value: '$relapses'),
          ],
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: onRelapse,
          style: TextButton.styleFrom(foregroundColor: Colors.white30),
          child: const Text('I relapsed'),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 6.0;
    final rect = Offset.zero & size;
    final arc = rect.deflate(stroke);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = Colors.white10;
    canvas.drawArc(arc, 0, math.pi * 2, false, track);
    if (progress <= 0) return;
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final bar = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(arc, -math.pi / 2, math.pi * 2 * progress, false, glow);
    canvas.drawArc(arc, -math.pi / 2, math.pi * 2 * progress, false, bar);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white38,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
