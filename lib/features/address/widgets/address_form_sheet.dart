import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../models/address.dart';
import '../providers/address_providers.dart';

Future<void> showAddressFormSheet(BuildContext context, {Address? existing}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => AddressFormSheet(existing: existing),
  );
}

class AddressFormSheet extends ConsumerStatefulWidget {
  const AddressFormSheet({super.key, this.existing});

  final Address? existing;

  @override
  ConsumerState<AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends ConsumerState<AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late var _label = widget.existing?.label ?? AddressLabel.home;
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _phone = TextEditingController(text: widget.existing?.phone);
  late final _line = TextEditingController(text: widget.existing?.line);

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _line.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(addressesProvider.notifier).save(
          Address(
            id: widget.existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
            label: _label,
            name: _name.text.trim(),
            phone: _phone.text.trim(),
            line: _line.text.trim(),
          ),
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                editing ? 'Edit address' : 'Add new delivery location',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  for (final l in AddressLabel.values)
                    ChoiceChip(
                      label: Text(l.title),
                      selected: l == _label,
                      showCheckmark: false,
                      selectedColor: AppColors.accentSoft,
                      side: BorderSide(color: l == _label ? AppColors.primary : AppColors.border),
                      labelStyle: TextStyle(
                        color: l == _label ? AppColors.primary : AppColors.ink,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) => setState(() => _label = l),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _name,
                hint: 'Full name',
                validator: Validators.name,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _phone,
                hint: 'Mobile number',
                validator: (v) =>
                    Validators.isPhone(v?.trim() ?? '') ? null : 'Enter a valid 10 digit number',
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _line,
                hint: 'House no, street, area, city, pincode',
                validator: (v) => (v == null || v.trim().length < 8) ? 'Enter full address' : null,
                textCapitalization: TextCapitalization.words,
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 16),
              AppButton(label: editing ? 'Save changes' : 'Save address', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
