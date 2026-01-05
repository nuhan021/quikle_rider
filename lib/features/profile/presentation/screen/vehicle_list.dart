import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/common/widgets/common_appbar.dart';
import 'package:quikle_rider/core/utils/constants/colors.dart';
import 'package:quikle_rider/features/profile/data/models/vehicle_model.dart';
import 'package:quikle_rider/features/profile/presentation/controller/profile_controller.dart';
import 'package:quikle_rider/features/profile/presentation/screen/vehicle_information.dart';
import 'package:quikle_rider/features/profile/presentation/widgets/profile_components/profile_list_shimmer_card.dart';

class VehicleListPage extends StatelessWidget {
  VehicleListPage({super.key});

  final ProfileController _profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    _profileController.ensureVehicleListLoaded();
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: UnifiedProfileAppBar(
        title: 'My Vehicles',
        showActionButton: false,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.greenbutton,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Get.to(VehicleInformationPage()),
      ),
      body: Obx(() {
        final isLoading = _profileController.isVehicleListLoading.value;
        final vehicles = _profileController.vehicleList;
        final error = _profileController.vehicleListError.value;

        if (isLoading) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, __) => const ProfileListShimmerCard(
              showAvatar: true,
              margin: EdgeInsets.zero,
              lineWidths: <double>[160, 120, 200],
            ),
          );
        }

        if (error != null && error.isNotEmpty) {
          return _VehicleStateMessage(
            icon: Icons.directions_car,
            title: 'Unable to load vehicles',
            message: error,
            actionLabel: 'Retry',
            onAction: () => _profileController.fetchVehiclesList(),
          );
        }

        if (vehicles.isEmpty) {
          return _VehicleStateMessage(
            icon: Icons.directions_car_filled_outlined,
            title: 'No vehicles found',
            message:
                'Add your first vehicle to start receiving orders for that vehicle type.',
            actionLabel: 'Refresh',
            onAction: () => _profileController.fetchVehiclesList(),
          );
        }

        return RefreshIndicator(
          onRefresh: _profileController.fetchVehiclesList,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: vehicles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return _VehicleCard(vehicle: vehicle);
            },
          ),
        );
      }),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.vehicle});

  final VehicleModel vehicle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _capitalize(vehicle.vehicleType),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarygreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  vehicle.licensePlateNumber,
                  style: const TextStyle(
                    color: AppColors.primarygreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _VehicleInfoRow(
            label: 'Model',
            value: vehicle.model?.isNotEmpty == true
                ? vehicle.model!
                : 'Not specified',
          ),
          const SizedBox(height: 8),
          _VehicleInfoRow(
            label: 'Added on',
            value: _formatTimestamp(vehicle.createdAt),
          ),
          const SizedBox(height: 8),
          _VehicleInfoRow(
            label: 'Last updated',
            value: _formatTimestamp(vehicle.updatedAt),
          ),
        ],
      ),
    );
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return 'Vehicle';
    return value[0].toUpperCase() + value.substring(1);
  }

  static String _formatTimestamp(String? value) {
    if (value == null || value.isEmpty) return 'Not available';
    try {
      final dateTime = DateTime.tryParse(value);
      if (dateTime == null) return value;
      final day = dateTime.day.toString().padLeft(2, '0');
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final month = _monthName(dateTime.month);
      return '$day $month ${dateTime.year} • $hour:$minute';
    } catch (_) {
      return value;
    }
  }

  static String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[(month - 1).clamp(0, months.length - 1)];
  }
}

class _VehicleInfoRow extends StatelessWidget {
  const _VehicleInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _VehicleStateMessage extends StatelessWidget {
  const _VehicleStateMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primarygreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
