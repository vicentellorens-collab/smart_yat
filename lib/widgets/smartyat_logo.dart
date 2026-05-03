import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';

/// SmartYat primary logo mark.
///
/// Single-line wordmark: SMART (Barlow Condensed Light 300) + YAT (ExtraBold 800).
/// The weight shift between modifier and anchor is the design.
/// A cold-cyan rule underscores the YAT portion only.
///
/// Parameters:
///   [width]       — controls overall size; all proportions scale from it.
///   [showTagline] — adds "Intelligent yacht management." below the rule.
///
/// Usage:
///   SmartYatLogo(width: 220)
///   SmartYatLogo(width: 200, showTagline: true)
///
/// Placement:
///   Login screen  → width: 200, showTagline: true
///   PIN screen    → width: 160, showTagline: false
///   Anywhere else → do not use; logo appears on pre-auth screens only.

class SmartYatLogo extends StatelessWidget {
  final double width;
  final bool showTagline;

  final Color smartColor;
  final Color yatColor;
  final Color ruleColor;
  final Color taglineColor;

  const SmartYatLogo({
    super.key,
    this.width = 220,
    this.showTagline = false,
    this.smartColor   = const Color(0xFF8AAEC8),
    this.yatColor     = AppTheme.textPrimary,
    this.ruleColor    = AppTheme.accent,
    this.taglineColor = AppTheme.textTertiary,
  });

  @override
  Widget build(BuildContext context) {
    // Scale factor: fontSize 64 on a 400-wide SVG source = 0.16
    final double fontSize = width * 0.16;

    // Rule sits under YAT only — ~43% of total wordmark width
    final double ruleWidth = width * 0.43;

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'SMART',
                  style: GoogleFonts.barlowCondensed(
                    fontWeight: FontWeight.w300,
                    fontSize: fontSize,
                    color: smartColor,
                    letterSpacing: fontSize * 0.04,
                    height: 1.0,
                  ),
                ),
                TextSpan(
                  text: 'YAT',
                  style: GoogleFonts.barlowCondensed(
                    fontWeight: FontWeight.w800,
                    fontSize: fontSize,
                    color: yatColor,
                    letterSpacing: fontSize * 0.02,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Rule aligned to the right, sitting under YAT
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: ruleWidth,
              height: 1.5,
              decoration: BoxDecoration(
                color: ruleColor,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          if (showTagline) ...[
            const SizedBox(height: 14),
            Text(
              'Intelligent yacht management.',
              style: GoogleFonts.barlow(
                fontWeight: FontWeight.w300,
                fontSize: 13,
                color: taglineColor,
                letterSpacing: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
