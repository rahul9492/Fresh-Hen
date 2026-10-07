import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/context_x.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../checkout/providers/checkout_providers.dart';
import '../models/address.dart';
import '../providers/address_providers.dart';
import '../../../core/constants/spacing.dart';

/// Adds a new address (or edits [existing]), saves it and selects it for
/// delivery. Returns the saved address, or null if dismissed.
Future<Address?> showAddressFormSheet(BuildContext context, {Address? existing}) {
  return showAppSheet<Address>(context, builder: (_) => AddressFormSheet(existing: existing));
}

class AddressFormSheet extends ConsumerStatefulWidget {
  const AddressFormSheet({super.key, this.existing});

  final Address? existing;

  @override
  ConsumerState<AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends ConsumerState<AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final Address? _old = widget.existing;
  late var _label = _old?.label ?? AddressLabel.home;
  late final _house = TextEditingController(text: _old?.house);
  late final _area = TextEditingController(text: _old?.area);
  late final _landmark = TextEditingController(text: _old?.landmark);
  late final _city = TextEditingController(text: _old?.city);
  late final _pincode = TextEditingController(text: _old?.pincode);
  late final _customLabel = TextEditingController(text: _old?.customLabel);
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late bool _isDefault;
  late bool _editReceiver;
  var _saving = false;

  /// The very first address is always the default.
  late final bool _isFirst = ref.read(addressesProvider).every((a) => a.id == _old?.id);

  @override
  void initState() {
    super.initState();
    // Load the delivery area now, so the pincode can be checked on save.
    ref.read(storeSettingsProvider);
    final user = ref.read(authSessionProvider);
    _name = TextEditingController(text: _old?.name ?? user?.name ?? '');
    _phone = TextEditingController(text: _old?.phone ?? user?.phone ?? '');
    _isDefault = _old?.isDefault ?? _isFirst;
    // Only show the receiver fields up front when something is missing.
    _editReceiver = _name.text.trim().isEmpty || !Validators.isPhone(_phone.text.trim());
  }

  @override
  void dispose() {
    for (final c in [_house, _area, _landmark, _city, _pincode, _customLabel, _name, _phone]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    // Make sure the delivery area is loaded before checking the pincode. If
    // it can't be loaded, the server still checks when the order is placed.
    try {
      await ref.read(storeSettingsProvider.future);
    } catch (_) {}
    if (!mounted) return;
    if (!_formKey.currentState!.validate()) {
      if (_name.text.trim().isEmpty || !Validators.isPhone(_phone.text.trim())) {
        setState(() => _editReceiver = true);
      }
      return;
    }
    final address = Address(
      id: _old?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      label: _label,
      customLabel: _label == AddressLabel.other ? _customLabel.text.trim() : null,
      house: _house.text.trim(),
      area: _area.text.trim(),
      landmark: _landmark.text.trim(),
      city: _city.text.trim(),
      pincode: _pincode.text.trim(),
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      isDefault: _isFirst || _isDefault,
    );
    setState(() => _saving = true);
    try {
      final saved = await ref.read(addressesProvider.notifier).save(address);
      ref.read(selectedAddressIdProvider.notifier).select(saved.id);
      if (mounted) Navigator.pop(context, saved);
    } catch (e) {
      if (mounted) context.showError(e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  static String? _required(String? v, String message) =>
      (v == null || v.trim().length < 2) ? message : null;

  @override
  Widget build(BuildContext context) {
    final editing = _old != null;
    return AppSheet(
      title: editing ? 'Edit address' : 'Add delivery address',
      footer: AppButton(
        label: editing ? 'Save changes' : 'Confirm',
        loading: _saving,
        onPressed: _save,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            _Field(
              controller: _house,
              label: 'House',
              required: true,
              hint: 'House / Flat / Floor / Building',
              validator: (v) => _required(v, 'Enter your house or flat number'),
            ),
            _Field(
              controller: _area,
              label: 'Area',
              required: true,
              hint: 'Area, sector, street, village',
              validator: (v) => _required(v, 'Enter your area or street'),
            ),
            _Field(controller: _landmark, label: 'Landmark', hint: 'Nearby landmark (optional)'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Field(
                    controller: _city,
                    label: 'City',
                    required: true,
                    hint: 'City',
                    validator: (v) => _required(v, 'Enter your city'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Field(
                    controller: _pincode,
                    label: 'Pincode',
                    required: true,
                    hint: '6 digits',
                    keyboardType: TextInputType.number,
                    formatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    validator: (v) {
                      final pin = v?.trim() ?? '';
                      if (!RegExp(r'^[1-9]\d{5}$').hasMatch(pin)) return 'Enter a valid pincode';
                      final settings = ref.read(storeSettingsProvider).value;
                      return settings == null || settings.deliversTo(pin)
                          ? null
                          : "We don't deliver here yet";
                    },
                  ),
                ),
              ],
            ),
            _ReceiverSection(
              editing: _editReceiver,
              name: _name,
              phone: _phone,
              onEdit: () => setState(() => _editReceiver = true),
            ),
            const SizedBox(height: 4),
            const Text(
              'Add Address Label',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (final l in AddressLabel.values) ...[
                  if (l != AddressLabel.values.first) const SizedBox(width: 12),
                  Expanded(
                    child: _LabelButton(
                      label: l,
                      selected: l == _label,
                      onTap: () => setState(() => _label = l),
                    ),
                  ),
                ],
              ],
            ),
            if (_label == AddressLabel.other) ...[
              const SizedBox(height: 16),
              _Field(
                controller: _customLabel,
                label: 'Save as',
                hint: "e.g. Mom's place, Gym",
                maxLength: 20,
              ),
            ] else
              const SizedBox(height: 8),
            _DefaultCheckbox(
              value: _isFirst || _isDefault,
              locked: _isFirst,
              onChanged: (v) => setState(() => _isDefault = v),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.required = false,
    this.validator,
    this.keyboardType,
    this.formatters,
    this.maxLength,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool required;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: color, width: width),
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        // Keeps the message on one line: it shrinks to fit the field's width
        // on narrow phones instead of being cut off or wrapping.
        errorBuilder: (context, error) => Padding(
          padding: const EdgeInsets.only(top: 4),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(error, style: const TextStyle(color: AppColors.accent, fontSize: 12)),
          ),
        ),
        // Re-check as the user edits, so an error clears once the value is fixed.
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: keyboardType,
        inputFormatters: [
          ...?formatters,
          if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
        ],
        textInputAction: TextInputAction.next,
        textCapitalization: keyboardType == null ? TextCapitalization.words : TextCapitalization.none,
        cursorColor: AppColors.primary,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          label: Text.rich(
            TextSpan(
              text: label,
              children: [
                if (required)
                  const TextSpan(text: ' *', style: TextStyle(color: AppColors.accent)),
              ],
            ),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: const TextStyle(color: AppColors.ink, fontSize: 15, fontWeight: FontWeight.w500),
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
          contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          border: border(AppColors.border),
          enabledBorder: border(AppColors.border),
          focusedBorder: border(AppColors.primary, 1.4),
          errorBorder: border(AppColors.accent),
          focusedErrorBorder: border(AppColors.accent, 1.4),
        ),
      ),
    );
  }
}

/// Who receives the order. Pre-filled from the profile and collapsed to one
/// line, since most people order for themselves.
class _ReceiverSection extends StatelessWidget {
  const _ReceiverSection({
    required this.editing,
    required this.name,
    required this.phone,
    required this.onEdit,
  });

  final bool editing;
  final TextEditingController name;
  final TextEditingController phone;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    if (editing) {
      return Column(
        children: [
          _Field(
            controller: name,
            label: "Receiver's name",
            required: true,
            hint: 'Full name',
            validator: Validators.name,
          ),
          _Field(
            controller: phone,
            label: "Receiver's phone",
            required: true,
            hint: '10 digit mobile number',
            keyboardType: TextInputType.phone,
            formatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 10,
            validator: (v) =>
                Validators.isPhone(v?.trim() ?? '') ? null : 'Enter a valid 10 digit number',
          ),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.hairline),
        ),
        child: Row(
          children: [
            const Icon(Icons.person_outline_rounded, size: 20, color: AppColors.body),
            const SizedBox(width: 12),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: 'Receiver: ',
                  style: const TextStyle(color: AppColors.body),
                  children: [
                    TextSpan(
                      text: '${name.text.trim()}, +91 ${phone.text.trim()}',
                      style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                // Wraps onto a second line instead of cutting off the phone number.
                style: const TextStyle(fontSize: 13),
              ),
            ),
            TextButton(onPressed: onEdit, child: const Text('Edit')),
          ],
        ),
      ),
    );
  }
}

class _LabelButton extends StatelessWidget {
  const _LabelButton({required this.label, required this.selected, required this.onTap});

  final AddressLabel label;
  final bool selected;
  final VoidCallback onTap;

  IconData get _icon => switch (label) {
        AddressLabel.home => Icons.home_rounded,
        AddressLabel.work => Icons.work_rounded,
        AddressLabel.other => Icons.place_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
          ),
          // Shrinks a little on very narrow screens instead of overflowing.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_icon, size: 17, color: selected ? Colors.white : AppColors.body),
                  const SizedBox(width: 6),
                  Text(
                    label.title,
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.ink,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DefaultCheckbox extends StatelessWidget {
  const _DefaultCheckbox({required this.value, required this.locked, required this.onChanged});

  final bool value;

  /// The first address is always the default, so the box can't be cleared.
  final bool locked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: locked ? null : () => onChanged(!value),
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 24,
              child: Checkbox(
                value: value,
                onChanged: locked ? null : (v) => onChanged(v ?? false),
                activeColor: AppColors.primary,
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                locked ? 'Default address (your first address)' : 'Make this my default address',
                style: const TextStyle(fontSize: 14, color: AppColors.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
