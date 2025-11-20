import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/common/widgets/common_appbar.dart';
import 'package:quikle_rider/features/profile/data/models/profile_model.dart';
import 'package:quikle_rider/features/profile/presentation/controller/profile_controller.dart';

class VehicleInformationPage extends StatefulWidget {
  const VehicleInformationPage({Key? key}) : super(key: key);

  @override
  State<VehicleInformationPage> createState() => _VehicleInformationPageState();
}

class _VehicleInformationPageState extends State<VehicleInformationPage> {
  ProfileController _profileController = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String selectedVehicleType = 'Bike';
  final TextEditingController _licensePlateController = TextEditingController();
  final TextEditingController _vehicleModelController = TextEditingController();

  final List<String> vehicleTypes = ['Bike', 'Car', 'Truck', 'Van'];

  @override
  void initState() {
    super.initState();
    _profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: UnifiedProfileAppBar(title: "Vehicle Information"),
      body: Obx(() {
        final ProfileModel? profile = _profileController.profile.value;
        final isLoadingProfile =
            _profileController.isLoading.value && profile == null;

        if (isLoadingProfile) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      _buildProfileCard(profile),
                      const SizedBox(height: 30),
                      _buildVehicleForm(),
                      const SizedBox(height: 20),
                      _buildVehicleSummary(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
            _buildErrorMessage(),
            _buildSaveButton(),
          ],
        );
      }),
    );
  }

  Widget _buildProfileCard(ProfileModel? profile) {
    final rawName = profile?.name ?? '';
    final rawEmail = profile?.email ?? '';
    final trimmedName = rawName.trim();
    final trimmedEmail = rawEmail.trim();
    final name = trimmedName.isNotEmpty ? trimmedName : 'Rider';
    final email = trimmedEmail.isNotEmpty
        ? trimmedEmail
        : 'Email not available';
    final imageUrl = profile?.profileImage;
    final imageProvider = imageUrl != null && imageUrl.trim().isNotEmpty
        ? NetworkImage(imageUrl)
        : const AssetImage('assets/images/loginriderimage.png')
              as ImageProvider;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[200],
            backgroundImage: imageProvider,
          ),
          const SizedBox(height: 15),
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          Text(email, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildVehicleForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Vehicle Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          _buildVehicleTypeDropdown(),
          _buildTextField(
            label: 'License Plate Number',
            controller: _licensePlateController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your license plate number';
              }
              return null;
            },
            textCapitalization: TextCapitalization.characters,
          ),
          _buildTextField(
            label: 'Vehicle Model (Optional)',
            controller: _vehicleModelController,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildVehicleSummary() {
    return Obx(() {
      final vehicle = _profileController.vehicleDetails.value;
      if (vehicle == null) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Saved Vehicle',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow('Type', _formatVehicleType(vehicle.vehicleType)),
            const SizedBox(height: 6),
            _buildSummaryRow('Model', vehicle.model ?? 'Not provided'),
            const SizedBox(height: 6),
            _buildSummaryRow('License Plate', vehicle.licensePlateNumber),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Obx(() {
      final error = _profileController.vehicleCreationError.value;
      if (error == null || error.isEmpty) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          error,
          style: const TextStyle(color: Colors.red, fontSize: 13),
        ),
      );
    });
  }

  Widget _buildSaveButton() {
    return Obx(() {
      final isSaving = _profileController.isCreatingVehicle.value;
      return Container(
        margin: const EdgeInsets.all(20),
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: isSaving ? null : _saveVehicleInformation,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Save Changes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      );
    });
  }

  Widget _buildVehicleTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vehicle Type',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedVehicleType,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                onChanged: (String? newValue) {
                  if (newValue == null) return;
                  setState(() {
                    selectedVehicleType = newValue;
                  });
                },
                items: vehicleTypes.map<DropdownMenuItem<String>>((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    FormFieldValidator<String>? validator,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textCapitalization: textCapitalization,
            validator: validator,
            decoration: InputDecoration(
              hintText: label,
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.orange),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveVehicleInformation() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final licensePlate = _licensePlateController.text.trim();
    final modelText = _vehicleModelController.text.trim();

    final success = await _profileController.createVehicle(
      vehicleType: selectedVehicleType.toLowerCase(),
      licensePlateNumber: licensePlate,
      model: modelText.isEmpty ? null : modelText,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vehicle information saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_profileController.vehicleCreationErrorText),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _licensePlateController.dispose();
    _vehicleModelController.dispose();
    super.dispose();
  }

  String _formatVehicleType(String type) {
    if (type.isEmpty) return 'N/A';
    return type[0].toUpperCase() + type.substring(1);
  }
}
