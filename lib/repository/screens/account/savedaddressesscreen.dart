import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quick_kart/domain/constants/appcolors.dart';
import 'package:quick_kart/domain/data/address_store.dart';
import 'package:quick_kart/domain/models/address.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key, this.selectionMode = false});

  final bool selectionMode;

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  Future<void> _selectAddress(SavedAddress address) async {
    AddressStore.select(address.id);
    if (widget.selectionMode) {
      Navigator.of(context).pop(address);
      return;
    }
    setState(() {});
    _showMessage('${address.label} set as your default address');
  }

  Future<void> _openAddressForm({SavedAddress? address}) async {
    final result = await showDialog<SavedAddress>(
      context: context,
      builder: (dialogContext) => _AddressFormDialog(address: address),
    );

    if (result == null || !mounted) return;

    setState(() {
      if (address == null) {
        AddressStore.add(result);
      } else {
        AddressStore.update(result);
      }
    });
    _showMessage(address == null ? 'Address added' : 'Address updated');
  }

  Future<void> _deleteAddress(SavedAddress address) async {
    if (AddressStore.addresses.length <= 1) {
      _showMessage('Keep at least one saved address');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Delete address?',
          style: TextStyle(
            fontFamily: 'bold',
            fontSize: 17,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          '${address.label} will be removed from your saved addresses.',
          style: const TextStyle(
            fontFamily: 'Regular',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'bold',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'bold',
                fontSize: 13,
                color: AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => AddressStore.remove(address.id));
    _showMessage('Address deleted');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontFamily: 'Regular', fontSize: 13),
          ),
          backgroundColor: AppColors.textPrimary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final addresses = AddressStore.addresses;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          title: Text(
            widget.selectionMode ? 'Select address' : 'Saved Addresses',
            style: const TextStyle(
              fontFamily: 'bold',
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            Text(
              widget.selectionMode
                  ? 'Choose where you would like your order delivered.'
                  : 'Manage the addresses you use for quick checkout.',
              style: const TextStyle(
                fontFamily: 'Regular',
                fontSize: 12.5,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            for (var index = 0; index < addresses.length; index++) ...[
              if (index > 0) const SizedBox(height: 12),
              _AddressCard(
                address: addresses[index],
                isSelected: addresses[index].id == AddressStore.selectedId,
                selectionMode: widget.selectionMode,
                onTap: () => _selectAddress(addresses[index]),
                onEdit: () => _openAddressForm(address: addresses[index]),
                onSetDefault: () => _selectAddress(addresses[index]),
                onDelete: () => _deleteAddress(addresses[index]),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => _openAddressForm(),
                icon: const Icon(
                  Icons.add_location_alt_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
                label: const Text(
                  'Add new address',
                  style: TextStyle(
                    fontFamily: 'bold',
                    fontSize: 13.5,
                    color: AppColors.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.isSelected,
    required this.selectionMode,
    required this.onTap,
    required this.onEdit,
    required this.onSetDefault,
    required this.onDelete,
  });

  final SavedAddress address;
  final bool isSelected;
  final bool selectionMode;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isHome = address.label.toLowerCase() == 'home';
    final isWork = address.label.toLowerCase() == 'work';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A101828),
                blurRadius: 14,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primarySoft
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  isHome
                      ? Icons.home_rounded
                      : isWork
                      ? Icons.work_outline_rounded
                      : Icons.location_on_outlined,
                  size: 20,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            address.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'bold',
                              fontSize: 13.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'DEFAULT',
                              style: TextStyle(
                                fontFamily: 'bold',
                                fontSize: 7.5,
                                letterSpacing: 0.6,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.fullAddress,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Regular',
                        fontSize: 11.5,
                        height: 1.45,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (selectionMode)
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                )
              else
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    size: 19,
                    color: AppColors.textSecondary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'default':
                        onSetDefault();
                      case 'edit':
                        onEdit();
                      case 'delete':
                        onDelete();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'default',
                      child: Text(
                        'Set as default',
                        style: TextStyle(fontFamily: 'Regular', fontSize: 12.5),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(
                        'Edit address',
                        style: TextStyle(fontFamily: 'Regular', fontSize: 12.5),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete address',
                        style: TextStyle(
                          fontFamily: 'Regular',
                          fontSize: 12.5,
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The add/edit address dialog.
///
/// The text editing controllers are owned by this dialog's [State], so they
/// are disposed only once the dialog route fully unmounts — after the exit
/// animation has completed. Disposing them immediately after the future
/// resolves (while the dialog is still animating out) triggers the
/// framework assertion `_dependents.isEmpty` and shows a red error screen.
class _AddressFormDialog extends StatefulWidget {
  const _AddressFormDialog({this.address});

  final SavedAddress? address;

  @override
  State<_AddressFormDialog> createState() => _AddressFormDialogState();
}

class _AddressFormDialogState extends State<_AddressFormDialog> {
  late final TextEditingController _labelController = TextEditingController(
    text: widget.address?.label ?? 'Home',
  );
  late final TextEditingController _detailsController = TextEditingController(
    text: widget.address?.details ?? '',
  );
  late final TextEditingController _areaController = TextEditingController(
    text: widget.address?.area ?? '',
  );
  late final TextEditingController _cityController = TextEditingController(
    text: widget.address?.city ?? 'Islamabad',
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _labelController.dispose();
    _detailsController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    Navigator.of(context).pop(
      SavedAddress(
        id: widget.address?.id ?? AddressStore.nextId(),
        label: _labelController.text.trim(),
        details: _detailsController.text.trim(),
        area: _areaController.text.trim(),
        city: _cityController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.address != null;

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        editing ? 'Edit address' : 'Add new address',
        style: const TextStyle(
          fontFamily: 'bold',
          fontSize: 18,
          color: AppColors.textPrimary,
        ),
      ),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildField(
                  controller: _labelController,
                  label: 'Address label',
                  hint: 'Home, Work, etc.',
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: _detailsController,
                  label: 'House / street',
                  hint: 'House 12, Street 4',
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: _areaController,
                  label: 'Area / sector',
                  hint: 'Sector F-11',
                  isRequired: false,
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: _cityController,
                  label: 'City',
                  hint: 'Islamabad',
                  isRequired: false,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontFamily: 'bold',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        TextButton(
          onPressed: _save,
          child: const Text(
            'Save address',
            style: TextStyle(
              fontFamily: 'bold',
              fontSize: 13,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: const TextStyle(
        fontFamily: 'Regular',
        fontSize: 13.5,
        color: AppColors.textPrimary,
      ),
      validator: (value) {
        // Only the truly required fields are validated, so a quick edit and
        // save never blocks the flow. Errors also clear the moment the user
        // types because of the onUserInteraction auto-validate mode.
        if (isRequired && (value ?? '').trim().isEmpty) {
          return '$label is required';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          fontFamily: 'Regular',
          fontSize: 12.5,
          color: AppColors.textSecondary,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Regular',
          fontSize: 12.5,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.fieldBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorStyle: const TextStyle(
          fontFamily: 'Regular',
          fontSize: 11,
          color: AppColors.danger,
        ),
      ),
    );
  }
}
