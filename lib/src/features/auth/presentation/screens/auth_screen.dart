import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quizlett/core/constant/app_colors.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final AnimationController _formController;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _formController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _formController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleForm() {
    setState(() {
      _isLogin = !_isLogin;
      _formController.reset();
      _formController.forward();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(authControllerProvider.notifier);
    if (_isLogin) {
      await notifier.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      await notifier.signUp(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Listen to Auth Errors
    ref.listen(authControllerProvider, (previous, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // 1. Moving Mesh Gradient Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _MeshBgPainter(_bgController.value, isDark),
                );
              },
            ),
          ),

          // 2. Glassmorphism Blur Backdrop
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(color: Colors.transparent),
            ),
          ),

          // 3. Scrollable Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    // App Logo & Subtitle
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: AppColors.primaryGradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.question_mark_rounded,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Quizzlett',
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Test your mind, level up your knowledge',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 4. Glassmorphic Form Card
                    AnimatedBuilder(
                      animation: _formController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _formController.value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - _formController.value)),
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.white.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                _isLogin ? 'Welcome Back' : 'Create Account',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 24),

                              if (!_isLogin) ...[
                                TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Full Name',
                                    prefixIcon: Icon(
                                      Icons.person_outline_rounded,
                                    ),
                                    hintText: 'Enter your name',
                                  ),
                                  validator: (value) =>
                                      value == null || value.trim().isEmpty
                                      ? 'Please enter your name'
                                      : null,
                                ),
                                const SizedBox(height: 16),
                              ],

                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Email Address',
                                  prefixIcon: Icon(Icons.email_outlined),
                                  hintText: 'hello@example.com',
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                  ),
                                  hintText: '••••••••',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                ),
                                validator: (value) =>
                                    value == null || value.length < 6
                                    ? 'Password must be at least 6 characters'
                                    : null,
                              ),
                              const SizedBox(height: 24),

                              // Submit Button
                              ElevatedButton(
                                onPressed: authState is AuthLoading
                                    ? null
                                    : _submit,
                                style:
                                    ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                    ).copyWith(
                                      backgroundColor: WidgetStateProperty.all(
                                        AppColors.primary,
                                      ),
                                    ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: AppColors.primaryGradient,
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: authState is AuthLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : Text(
                                            _isLogin ? 'Sign In' : 'Sign Up',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Divider "or"
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.1),
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Or continue with',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.1),
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 5. Google Login Button
                    OutlinedButton(
                      onPressed: authState is AuthLoading
                          ? null
                          : () => ref
                                .read(authControllerProvider.notifier)
                                .signInWithGoogle(),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.03)
                            : Colors.white.withValues(alpha: 0.8),
                        side: BorderSide(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : AppColors.borderLight,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(20, 20),
                            painter: _GoogleIconPainter(),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Sign in with Google',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Toggle text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLogin
                              ? "Don't have an account? "
                              : "Already have an account? ",
                          style: theme.textTheme.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: authState is AuthLoading ? null : _toggleForm,
                          child: Text(
                            _isLogin ? 'Sign Up' : 'Sign In',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 6. Google Icon Vector Painter
class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double r = w / 2;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Draw Blue Section
    paint.color = const Color(0xFF4285F4);
    final pathBlue = Path()
      ..moveTo(r, r)
      ..lineTo(w, r)
      ..arcTo(
        Rect.fromCircle(center: Offset(r, r), radius: r),
        0,
        math.pi / 4,
        false,
      )
      ..lineTo(r, r)
      ..close();
    canvas.drawPath(pathBlue, paint);

    final pathBlueHorizontal = Path()
      ..moveTo(r, r)
      ..lineTo(w, r)
      ..lineTo(w, r * 1.2)
      ..lineTo(r * 1.1, r * 1.2)
      ..lineTo(r * 1.1, r)
      ..close();
    canvas.drawPath(pathBlueHorizontal, paint);

    // Draw Green Section
    paint.color = const Color(0xFF34A853);
    final pathGreen = Path()
      ..moveTo(r, r)
      ..lineTo(r + r * math.cos(math.pi / 4), r + r * math.sin(math.pi / 4))
      ..arcTo(
        Rect.fromCircle(center: Offset(r, r), radius: r),
        math.pi / 4,
        math.pi * 3 / 4,
        false,
      )
      ..lineTo(r, r)
      ..close();
    canvas.drawPath(pathGreen, paint);

    // Draw Yellow Section
    paint.color = const Color(0xFFFBBC05);
    final pathYellow = Path()
      ..moveTo(r, r)
      ..lineTo(r - r, r)
      ..arcTo(
        Rect.fromCircle(center: Offset(r, r), radius: r),
        math.pi,
        math.pi * 1 / 4,
        false,
      )
      ..lineTo(r, r)
      ..close();
    canvas.drawPath(pathYellow, paint);

    // Draw Red Section
    paint.color = const Color(0xEA43358B); // Custom Red
    paint.color = const Color(0xFFEA4335);
    final pathRed = Path()
      ..moveTo(r, r)
      ..lineTo(r - r * math.cos(math.pi / 4), r - r * math.sin(math.pi / 4))
      ..arcTo(
        Rect.fromCircle(center: Offset(r, r), radius: r),
        math.pi * 5 / 4,
        math.pi * 3 / 4,
        false,
      )
      ..lineTo(r, r)
      ..close();
    canvas.drawPath(pathRed, paint);

    // Punch a hole in the middle to make it a ring
    final holePaint = Paint()
      ..color = Colors.transparent
      ..blendMode = BlendMode.clear;
    canvas.drawCircle(Offset(r, r), r * 0.6, holePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 7. Moving Mesh Background Painter
class _MeshBgPainter extends CustomPainter {
  final double animationValue;
  final bool isDark;

  _MeshBgPainter(this.animationValue, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Draw base dark/light background
    final bgPaint = Paint()
      ..color = isDark ? AppColors.bgDark : AppColors.bgLight;
    canvas.drawRect(rect, bgPaint);

    final double phase = animationValue * 2 * math.pi;

    // First bubble (Indigo/Violet)
    final offset1 = Offset(
      size.width * (0.3 + 0.15 * math.sin(phase)),
      size.height * (0.2 + 0.1 * math.cos(phase * 1.2)),
    );
    final paint1 = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.2),
              AppColors.primary.withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCircle(center: offset1, radius: size.width * 0.75),
          );
    canvas.drawCircle(offset1, size.width * 0.75, paint1);

    // Second bubble (Rose/Pink)
    final offset2 = Offset(
      size.width * (0.7 + 0.1 * math.cos(phase * 0.8)),
      size.height * (0.75 + 0.15 * math.sin(phase * 1.5)),
    );
    final paint2 = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppColors.secondary.withValues(alpha: isDark ? 0.2 : 0.15),
              AppColors.secondary.withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCircle(center: offset2, radius: size.width * 0.7),
          );
    canvas.drawCircle(offset2, size.width * 0.7, paint2);

    // Third bubble (Teal/Violet)
    final offset3 = Offset(
      size.width * (0.1 + 0.1 * math.cos(phase * 1.1)),
      size.height * (0.8 + 0.1 * math.sin(phase * 0.9)),
    );
    final paint3 = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppColors.tertiary.withValues(alpha: isDark ? 0.15 : 0.12),
              AppColors.tertiary.withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCircle(center: offset3, radius: size.width * 0.5),
          );
    canvas.drawCircle(offset3, size.width * 0.5, paint3);
  }

  @override
  bool shouldRepaint(covariant _MeshBgPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isDark != isDark;
  }
}
