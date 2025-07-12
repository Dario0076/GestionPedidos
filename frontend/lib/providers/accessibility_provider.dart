import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AccessibilityProvider extends ChangeNotifier {
  double _textScaleFactor = 1.0;
  bool _useHighContrast = false;
  bool _enableVibration = true;
  bool _enableSounds = true;
  bool _enableScreenReader = false;
  Duration _animationDuration = const Duration(milliseconds: 300);

  // Getters
  double get textScaleFactor => _textScaleFactor;
  bool get useHighContrast => _useHighContrast;
  bool get enableVibration => _enableVibration;
  bool get enableSounds => _enableSounds;
  bool get enableScreenReader => _enableScreenReader;
  Duration get animationDuration => _animationDuration;

  // Text scaling
  void setTextScaleFactor(double factor) {
    _textScaleFactor = factor.clamp(0.8, 2.0);
    notifyListeners();
  }

  // High contrast mode
  void toggleHighContrast() {
    _useHighContrast = !_useHighContrast;
    notifyListeners();
  }

  // Vibration settings
  void toggleVibration() {
    _enableVibration = !_enableVibration;
    notifyListeners();
  }

  // Sound settings
  void toggleSounds() {
    _enableSounds = !_enableSounds;
    notifyListeners();
  }

  // Screen reader support
  void toggleScreenReader() {
    _enableScreenReader = !_enableScreenReader;
    notifyListeners();
  }

  // Animation speed
  void setAnimationSpeed(double speed) {
    int milliseconds = (300 / speed).round();
    _animationDuration = Duration(milliseconds: milliseconds.clamp(100, 1000));
    notifyListeners();
  }

  // Haptic feedback
  void provideLightFeedback() {
    if (_enableVibration) {
      HapticFeedback.lightImpact();
    }
  }

  void provideMediumFeedback() {
    if (_enableVibration) {
      HapticFeedback.mediumImpact();
    }
  }

  void provideHeavyFeedback() {
    if (_enableVibration) {
      HapticFeedback.heavyImpact();
    }
  }

  void provideSelectionFeedback() {
    if (_enableVibration) {
      HapticFeedback.selectionClick();
    }
  }

  void provideVibrationFeedback() {
    if (_enableVibration) {
      HapticFeedback.vibrate();
    }
  }

  // Play system sounds
  void playClickSound() {
    if (_enableSounds) {
      SystemSound.play(SystemSoundType.click);
    }
  }
}

// Accessibility wrapper widget
class AccessibleWidget extends StatelessWidget {
  final Widget child;
  final String? semanticLabel;
  final String? semanticHint;
  final bool excludeSemantics;
  final VoidCallback? onTap;

  const AccessibleWidget({
    super.key,
    required this.child,
    this.semanticLabel,
    this.semanticHint,
    this.excludeSemantics = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (excludeSemantics) {
      return ExcludeSemantics(child: child);
    }

    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: onTap != null,
      onTap: onTap,
      child: child,
    );
  }
}

// Accessible button with proper semantics
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? tooltip;
  final ButtonStyle? style;

  const AccessibleButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.semanticLabel,
    this.tooltip,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: child,
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      child: button,
    );
  }
}

// Accessible text field
class AccessibleTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? semanticLabel;
  final bool obscureText;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  const AccessibleTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.semanticLabel,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? labelText,
      textField: true,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
        ),
      ),
    );
  }
}

// Screen reader announcements
class ScreenReaderAnnouncer {
  static void announce(String message, {bool assertive = false}) {
    // En Flutter, simplemente usar Semantics para anunciar
    // Esta es una implementación simplificada
    debugPrint('Screen Reader: $message');
  }
}

// Focus management utilities
class FocusUtils {
  static void requestFocus(BuildContext context, FocusNode focusNode) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNode);
    });
  }

  static void clearFocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static void nextFocus(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  static void previousFocus(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }
}

// Responsive breakpoints for accessibility
class ResponsiveBreakpoints {
  static const double mobile = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double largeDesktop = 1440;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }

  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= largeDesktop;
  }

  // Get appropriate padding based on screen size
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.all(24);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(20);
    } else {
      return const EdgeInsets.all(16);
    }
  }

  // Get appropriate text scale for screen size
  static double getTextScale(BuildContext context) {
    if (isDesktop(context)) {
      return 1.1;
    } else if (isTablet(context)) {
      return 1.05;
    } else {
      return 1.0;
    }
  }
}
