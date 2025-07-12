import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/translation_provider.dart';

class TranslatedTextFormField extends ConsumerWidget {
  final TextEditingController? controller;
  final String labelText;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Function(String?)? onSaved;
  final int? maxLines;
  final bool readOnly;
  final Function()? onTap;

  const TranslatedTextFormField({
    super.key,
    this.controller,
    required this.labelText,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationState = ref.watch(translationProvider);
    final translationNotifier = ref.read(translationProvider.notifier);

    return FutureBuilder<Map<String, String>>(
      future: _getTranslatedStrings(translationNotifier, translationState),
      builder: (context, snapshot) {
        final translations =
            snapshot.data ?? {'label': labelText, 'hint': hintText ?? ''};

        return TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: translations['label'],
            hintText: translations['hint']?.isNotEmpty == true
                ? translations['hint']
                : null,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            border: const OutlineInputBorder(),
          ),
          validator: validator != null
              ? (value) =>
                    _translateValidator(validator!(value), translationNotifier)
              : null,
          onChanged: onChanged,
          onSaved: onSaved,
        );
      },
    );
  }

  Future<Map<String, String>> _getTranslatedStrings(
    TranslationNotifier translationNotifier,
    TranslationState translationState,
  ) async {
    if (translationState.currentLanguage == 'es') {
      return {'label': labelText, 'hint': hintText ?? ''};
    }

    final results = <String, String>{};
    results['label'] = await translationNotifier.translate(labelText);
    if (hintText != null && hintText!.isNotEmpty) {
      results['hint'] = await translationNotifier.translate(hintText!);
    }
    return results;
  }

  String? _translateValidator(
    String? validationResult,
    TranslationNotifier translationNotifier,
  ) {
    if (validationResult == null) return null;

    // Para los validators, hacemos la traducción de forma síncrona usando cache
    // En una implementación más completa, podrías usar un FutureBuilder aquí también
    return validationResult; // Por ahora devolvemos el mensaje original
  }
}

// Widget para campos de texto simples traducidos
class TranslatedTextField extends ConsumerWidget {
  final TextEditingController? controller;
  final String labelText;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Function(String)? onChanged;
  final int? maxLines;
  final bool readOnly;
  final Function()? onTap;

  const TranslatedTextField({
    super.key,
    this.controller,
    required this.labelText,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationState = ref.watch(translationProvider);
    final translationNotifier = ref.read(translationProvider.notifier);

    return FutureBuilder<Map<String, String>>(
      future: _getTranslatedStrings(translationNotifier, translationState),
      builder: (context, snapshot) {
        final translations =
            snapshot.data ?? {'label': labelText, 'hint': hintText ?? ''};

        return TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: translations['label'],
            hintText: translations['hint']?.isNotEmpty == true
                ? translations['hint']
                : null,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            border: const OutlineInputBorder(),
          ),
          onChanged: onChanged,
        );
      },
    );
  }

  Future<Map<String, String>> _getTranslatedStrings(
    TranslationNotifier translationNotifier,
    TranslationState translationState,
  ) async {
    if (translationState.currentLanguage == 'es') {
      return {'label': labelText, 'hint': hintText ?? ''};
    }

    final results = <String, String>{};
    results['label'] = await translationNotifier.translate(labelText);
    if (hintText != null && hintText!.isNotEmpty) {
      results['hint'] = await translationNotifier.translate(hintText!);
    }
    return results;
  }
}

// Widget para campos de búsqueda traducidos
class TranslatedSearchField extends ConsumerWidget {
  final String? hintText;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final InputDecoration? decoration;

  const TranslatedSearchField({
    super.key,
    this.hintText,
    this.controller,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.decoration,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationState = ref.watch(translationProvider);
    final translationNotifier = ref.read(translationProvider.notifier);

    return FutureBuilder<String?>(
      future: hintText != null && translationState.currentLanguage != 'es'
          ? translationNotifier.translate(hintText!)
          : Future.value(hintText),
      builder: (context, snapshot) {
        final translatedHint = snapshot.data ?? hintText;

        return TextField(
          controller: controller,
          onChanged: onChanged,
          decoration:
              decoration ??
              InputDecoration(
                hintText: translatedHint,
                prefixIcon: prefixIcon,
                suffixIcon: suffixIcon,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
        );
      },
    );
  }
}
