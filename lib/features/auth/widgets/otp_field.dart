import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class OtpField extends StatefulWidget {
  const OtpField({super.key, required this.onChanged, this.length = AppConstants.otpLength});

  final ValueChanged<String> onChanged;
  final int length;

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// Closing the keyboard with the back gesture leaves the field focused, and
  /// requestFocus() on a focused field does nothing, so ask for the keyboard
  /// explicitly in that case.
  void _openKeyboard() {
    if (_focus.hasFocus) {
      SystemChannels.textInput.invokeMethod<void>('TextInput.show');
    } else {
      _focus.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: 0,
          child: TextField(
            controller: _controller,
            focusNode: _focus,
            autofocus: true,
            keyboardType: TextInputType.number,
            maxLength: widget.length,
            autofillHints: const [AutofillHints.oneTimeCode],
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: widget.onChanged,
          ),
        ),
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _openKeyboard,
            child: ListenableBuilder(
              listenable: Listenable.merge([_controller, _focus]),
              builder: (context, _) {
                final value = _controller.text;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var i = 0; i < widget.length; i++)
                      _Box(
                        digit: i < value.length ? value[i] : null,
                        active: _focus.hasFocus && i == value.length.clamp(0, widget.length - 1),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.digit, required this.active});

  final String? digit;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? Colors.white : const Color(0xFFF1F0F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active ? AppColors.accent : AppColors.border,
          width: active ? 1.6 : 1,
        ),
      ),
      child: digit != null
          ? Text(digit!, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700))
          : active
              ? Container(width: 2, height: 28, color: AppColors.accent)
              : const Icon(Icons.circle, size: 9, color: Color(0xFFCFCDD6)),
    );
  }
}
