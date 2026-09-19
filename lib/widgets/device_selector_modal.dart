import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/device_data.dart';
import '../providers/app_state_provider.dart';
import 'neo_card.dart';

/// Modal popup for selecting Device Brand → Model
/// Adheres strictly to the ResQ Neo-brutalist / SaaS flat vector design system.
class DeviceSelectorModal extends StatefulWidget {
  const DeviceSelectorModal({super.key});

  /// Opens the modal popup from bottom with native feel
  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const DeviceSelectorModal(),
    );
  }

  @override
  State<DeviceSelectorModal> createState() => _DeviceSelectorModalState();
}

class _DeviceSelectorModalState extends State<DeviceSelectorModal> {
  String? _activeBrand;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getBrandColor(int index) {
    final colors = [
      AppTheme.pastelPurple,
      AppTheme.pastelBlue,
      AppTheme.pastelMint,
      AppTheme.pastelAmber,
      AppTheme.pastelCoral,
      AppTheme.pastelRose,
      AppTheme.lilac,
    ];
    return colors[index % colors.length];
  }

  IconData _getBrandIcon(String brand) {
    switch (brand) {
      case 'Apple':
        return Icons.apple_rounded;
      case 'Google Pixel':
        return Icons.android_rounded;
      default:
        return Icons.smartphone_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final isBrandSelected = _activeBrand != null;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.bgNeutral,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radiusLarge),
          topRight: Radius.circular(AppTheme.radiusLarge),
        ),
        border: Border(
          top: BorderSide(color: AppTheme.strokeBlack, width: AppTheme.strokeWidth),
          left: BorderSide(color: AppTheme.strokeBlack, width: AppTheme.strokeWidth),
          right: BorderSide(color: AppTheme.strokeBlack, width: AppTheme.strokeWidth),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppTheme.strokeBlack,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header Row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 12, 12),
            child: Row(
              children: [
                if (isBrandSelected) ...[
                  // "← Back to Brands" button
                  InkWell(
                    onTap: () {
                      setState(() {
                        _activeBrand = null;
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.arrow_back_rounded, size: 16, color: AppTheme.strokeBlack),
                          SizedBox(width: 6),
                          Text(
                            'Back to Brands',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.strokeBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SELECT MODEL',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: AppTheme.lilacDark,
                          ),
                        ),
                        Text(
                          '$_activeBrand',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'DEVICE SELECTOR',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: AppTheme.lilacDark,
                          ),
                        ),
                        Text(
                          'Select Brand',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 22, color: AppTheme.strokeBlack),
                  onPressed: () => Navigator.of(context).pop(false),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),

          const Divider(color: AppTheme.strokeBlack, thickness: AppTheme.strokeWidth, height: 1),

          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(color: AppTheme.strokeBlack, width: AppTheme.strokeWidth),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, size: 20, color: AppTheme.strokeBlack),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: isBrandSelected
                            ? 'Search $_activeBrand models...'
                            : 'Search brand (Samsung, Apple, OnePlus...)',
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim().toLowerCase();
                        });
                      },
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18, color: AppTheme.textSecondary),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _searchController.clear();
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          ),

          // Main Content List
          Expanded(
            child: isBrandSelected
                ? _buildModelsList(context, appState)
                : _buildBrandsList(context, appState),
          ),
        ],
      ),
    );
  }

  /// Screen 1: Brand Selection List
  Widget _buildBrandsList(BuildContext context, AppStateProvider appState) {
    final allBrands = DeviceData.brands;
    final filteredBrands = _searchQuery.isEmpty
        ? allBrands
        : allBrands.where((b) => b.toLowerCase().contains(_searchQuery)).toList();

    if (filteredBrands.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off_rounded, size: 48, color: AppTheme.textMuted),
              const SizedBox(height: 12),
              Text(
                'No brand found matching "$_searchQuery"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: filteredBrands.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final brand = filteredBrands[index];
        final isCurrentBrand = appState.selectedBrand == brand;
        final modelCount = DeviceData.getModels(brand).length;
        final brandColor = _getBrandColor(index);

        return NeoCard(
          backgroundColor: isCurrentBrand ? AppTheme.pastelPurple : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          onTap: () {
            setState(() {
              _activeBrand = brand;
              _searchQuery = '';
              _searchController.clear();
            });
          },
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: brandColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
                ),
                child: Icon(
                  _getBrandIcon(brand),
                  size: 24,
                  color: AppTheme.strokeBlack,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brand,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$modelCount models available',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCurrentBrand) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.pastelMint,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.strokeBlack, width: 1.0),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.strokeBlack,
                    ),
                  ),
                ),
              ],
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppTheme.strokeBlack,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Screen 2: Model Selection List for Active Brand
  Widget _buildModelsList(BuildContext context, AppStateProvider appState) {
    final brand = _activeBrand!;
    final models = DeviceData.getModels(brand);
    final filteredModels = _searchQuery.isEmpty
        ? models
        : models.where((m) => m.toLowerCase().contains(_searchQuery)).toList();

    if (filteredModels.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off_rounded, size: 48, color: AppTheme.textMuted),
              const SizedBox(height: 12),
              Text(
                'No models found matching "$_searchQuery"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: filteredModels.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final model = filteredModels[index];
        final isSelected = appState.selectedBrand == brand && appState.selectedModel == model;

        return NeoCard(
          backgroundColor: isSelected ? AppTheme.pastelMint : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          onTap: () async {
            final messenger = ScaffoldMessenger.of(context);
            // Save the selected brand and model
            await context.read<AppStateProvider>().setSelectedDevice(brand, model);
            
            if (context.mounted) {
              // Close popup and return to existing Main Page
              Navigator.of(context).pop(true);

              messenger.showSnackBar(
                SnackBar(
                  backgroundColor: AppTheme.strokeBlack,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppTheme.pastelMint, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Selected Device: $brand $model',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.pastelMint : AppTheme.surfaceSecondary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
                ),
                child: Icon(
                  isSelected ? Icons.check_rounded : Icons.phone_android_rounded,
                  size: 20,
                  color: AppTheme.strokeBlack,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      brand,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.strokeBlack, width: 1.0),
                  ),
                  child: const Text(
                    'SELECTED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.strokeBlack,
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: AppTheme.textMuted,
                ),
            ],
          ),
        );
      },
    );
  }
}
