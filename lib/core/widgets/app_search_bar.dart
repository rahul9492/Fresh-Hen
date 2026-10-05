import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../constants/spacing.dart';

/// Search field used across the app.
///
/// * Editable: optional [debounce] before [onChanged] fires, clear button built in.
/// * Read-only ([AppSearchBar.readOnly]): looks the same but acts as a tap target.
class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    super.key,
    this.controller,
    this.hint = 'Search...',
    this.onChanged,
    this.debounce = Duration.zero,
    this.autofocus = false,
    this.bordered = true,
  })  : readOnlyMode = false,
        onTap = null;

  const AppSearchBar.readOnly({super.key, required this.onTap, this.hint = 'Search...'})
      : controller = null,
        onChanged = null,
        debounce = Duration.zero,
        autofocus = false,
        bordered = true,
        readOnlyMode = true;

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final Duration debounce;
  final bool autofocus;
  final bool bordered;
  final bool readOnlyMode;
  final VoidCallback? onTap;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final _controller = widget.controller ?? TextEditingController();
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _changed(String value) {
    _timer?.cancel();
    if (widget.debounce == Duration.zero) {
      widget.onChanged?.call(value);
    } else {
      _timer = Timer(widget.debounce, () => widget.onChanged?.call(value));
    }
  }

  void _clear() {
    _controller.clear();
    _timer?.cancel();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      border: widget.bordered ? Border.all(color: AppColors.border) : null,
    );

    if (widget.readOnlyMode) {
      return InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: decoration,
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: AppColors.body),
              const SizedBox(width: 12),
              Text(widget.hint, style: const TextStyle(color: AppColors.muted, fontSize: 15)),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 48,
      decoration: decoration,
      child: TextField(
        controller: _controller,
        autofocus: widget.autofocus,
        textInputAction: TextInputAction.search,
        cursorColor: AppColors.primary,
        onChanged: _changed,
        decoration: InputDecoration(
          hintText: widget.hint,
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.body),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (_, value, _) => value.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    onPressed: _clear,
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
          ),
        ),
      ),
    );
  }
}
