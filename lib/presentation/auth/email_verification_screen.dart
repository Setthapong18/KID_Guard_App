// ==================== Email Verification Screen ====================
// หน้าจอยืนยันอีเมล — แสดงหลังสมัครหรือล็อกอินก่อน verify
//
// ฟีเจอร์:
// - Responsive design ใช้ LayoutBuilder + % ของจอ
// - กดปุ่มเพื่อเช็ค verification
// - พอ verify แล้ว → auto-login เข้าแอพทันที
// - ปุ่มส่งอีเมลยืนยันอีกครั้ง
// - FittedBox ป้องกันข้อความล้นจอทุกอุปกรณ์
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import '../../logic/providers/auth_provider.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String password;

  const EmailVerificationScreen({
    required this.email, required this.password, super.key,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with SingleTickerProviderStateMixin {
  bool _isChecking = false;
  bool _isResending = false;
  bool _emailSent = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;

  // Colors ตาม login_screen.dart
  static const _primaryColor = Color(0xFF6B9080);
  static const _textPrimary = Color(0xFF1A1A2E);
  static const _textSecondary = Color(0xFF6B7280);
  static const _textMuted = Color(0xFF9CA3AF);
  static const _bgColor = Color(0xFFFAFAFC);
  static const _inputBg = Color(0xFFF5F5F7);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  /// เช็คว่า email verified แล้วหรือยัง
  Future<void> _checkVerification() async {
    if (_isChecking) return;

    setState(() => _isChecking = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );

      final user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      final updatedUser = FirebaseAuth.instance.currentUser;

      if (updatedUser != null && updatedUser.emailVerified) {
        if (mounted) {
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          final success = await authProvider.signIn(
            widget.email,
            widget.password,
          );
          if (success && mounted) {
            Navigator.pushReplacementNamed(context, '/parent/dashboard');
          }
        }
      } else {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                '⏳ ยังไม่ได้ยืนยัน — กรุณากดลิงก์ในอีเมลก่อน',
              ),
              backgroundColor: const Color(0xFFf59e0b),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  /// ส่ง verification email อีกครั้ง
  Future<void> _resendEmail() async {
    if (_isResending || _resendCooldown > 0) return;

    setState(() => _isResending = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        await FirebaseAuth.instance.signOut();
        setState(() {
          _emailSent = true;
          _resendCooldown = 60;
        });
        _cooldownTimer?.cancel();
        _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted) {
            setState(() {
              _resendCooldown--;
              if (_resendCooldown <= 0) {
                timer.cancel();
                _emailSent = false;
              }
            });
          } else {
            timer.cancel();
          }
        });
      } else {
        await FirebaseAuth.instance.signOut();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('❌ ไม่สามารถส่งอีเมลได้ กรุณาลองใหม่'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            // ==================== % ของจอ — ยืดหยุ่นทุกอุปกรณ์ ====================
            final pad = (w * 0.07).clamp(16.0, 40.0);

            // Font — สมดุลพอดี
            final titleFs = (w * 0.055).clamp(18.0, 28.0);
            final bodyFs = (w * 0.035).clamp(13.0, 16.0);
            final smallFs = (w * 0.02).clamp(11.0, 14.0);
            const btnFs = 12.0;

            // Icon — % ของความกว้าง
            final iconBox = (w * 0.22).clamp(56.0, 120.0);
            final iconInner = iconBox * 0.48;

            // Spacing — % ของความสูง
            final gap = (h * 0.028).clamp(10.0, 32.0);
            final miniGap = (h * 0.008).clamp(3.0, 10.0);
            final btnH = (h * 0.06).clamp(46.0, 56.0);

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: pad, vertical: gap),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ==================== Mail Icon ====================
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          width: iconBox,
                          height: iconBox,
                          decoration: BoxDecoration(
                            color: _primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.mark_email_unread_rounded,
                            size: iconInner,
                            color: _primaryColor,
                          ),
                        ),
                      ),
                      SizedBox(height: gap),

                      // ==================== Title ====================
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'ยืนยันอีเมลของคุณ',
                          style: TextStyle(
                            fontSize: titleFs,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(height: miniGap),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'เราส่งลิงก์ยืนยันไปที่อีเมลของคุณแล้ว',
                          style: TextStyle(
                            fontSize: bodyFs,
                            color: _textSecondary,
                          ),
                        ),
                      ),
                      SizedBox(height: gap),

                      // ==================== Email Box ====================
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: w * 0.03,
                          vertical: h * 0.012,
                        ),
                        decoration: BoxDecoration(
                          color: _inputBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _primaryColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: bodyFs + 2,
                              color: _primaryColor,
                            ),
                            SizedBox(width: w * 0.025),
                            Expanded(
                              child: Text(
                                widget.email,
                                style: TextStyle(
                                  fontSize: bodyFs,
                                  fontWeight: FontWeight.w600,
                                  color: _textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: gap),

                      // ==================== Info Card ====================
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(w * 0.035),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: smallFs + 2,
                                  color: _primaryColor,
                                ),
                                SizedBox(width: w * 0.02),
                                Expanded(
                                  child: Text(
                                    _isChecking
                                        ? 'กำลังตรวจสอบ...'
                                        : 'กดปุ่มด้านล่างหลังยืนยันอีเมลแล้ว',
                                    style: TextStyle(
                                      fontSize: smallFs,
                                      color: _textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: miniGap),
                            _buildTip(smallFs, '💡', 'เช็คทั้ง Inbox และ Spam'),
                            SizedBox(height: miniGap * 0.5),
                            _buildTip(
                              smallFs,
                              '🔗',
                              'กดลิงก์ในเมล → กลับมากดยืนยัน',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: gap),

                      SizedBox(
                        width: double.infinity,
                        height: btnH,
                        child: ElevatedButton.icon(
                          onPressed: _isChecking ? null : _checkVerification,
                          icon: _isChecking
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.verified_user_rounded,
                                  size: 20,
                                ),
                          label: Text(
                            _isChecking
                                ? 'กำลังตรวจสอบ...'
                                : 'ยืนยันแล้ว ตรวจสอบเลย',
                            style: const TextStyle(
                              fontSize: btnFs,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            textStyle: const TextStyle(
                              fontSize: btnFs,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: miniGap),

                      SizedBox(
                        width: double.infinity,
                        height: btnH,
                        child: OutlinedButton.icon(
                          onPressed: (_isResending || _resendCooldown > 0)
                              ? null
                              : _resendEmail,
                          icon: _isResending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  _emailSent
                                      ? Icons.check_circle_outline
                                      : Icons.email_outlined,
                                  size: 20,
                                ),
                          label: Text(
                            _resendCooldown > 0
                                ? 'ส่งอีกครั้งใน ${_resendCooldown}s'
                                : _emailSent
                                ? 'ส่งแล้ว!'
                                : 'ส่งอีเมลยืนยันอีกครั้ง',
                            style: const TextStyle(
                              fontSize: btnFs,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            textStyle: const TextStyle(
                              fontSize: btnFs,
                              fontWeight: FontWeight.w500,
                            ),
                            side: BorderSide(
                              color: _primaryColor.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: gap * 0.6),

                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          '← กลับหน้าล็อกอิน',
                          style: TextStyle(
                            fontSize: smallFs,
                            color: _textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTip(double fontSize, String emoji, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: TextStyle(fontSize: fontSize)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: fontSize, color: _textMuted),
          ),
        ),
      ],
    );
  }
}
