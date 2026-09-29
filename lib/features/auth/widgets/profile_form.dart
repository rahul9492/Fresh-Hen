import 'package:flutter/material.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class ProfileForm extends StatefulWidget {
  const ProfileForm({
    super.key,
    required this.submitLabel,
    required this.loading,
    required this.onSubmit,
    this.initialName,
    this.initialEmail,
  });

  final String submitLabel;
  final bool loading;
  final String? initialName;
  final String? initialEmail;
  final void Function(String name, String? email) onSubmit;

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initialName);
  late final _email = TextEditingController(text: widget.initialEmail);

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    widget.onSubmit(_name.text.trim(), _email.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextField(
            controller: _name,
            hint: 'Full Name',
            validator: Validators.name,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _email,
            hint: 'Email (Optional)',
            validator: Validators.optionalEmail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          AppButton(label: widget.submitLabel, loading: widget.loading, onPressed: _submit),
        ],
      ),
    );
  }
}
