import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/services/network_caller.dart';
import 'package:quikle_rider/core/services/storage_service.dart';
import 'package:quikle_rider/core/utils/constants/api_constants.dart';
import 'package:quikle_rider/core/utils/logging/logger.dart';

class WithdrawController extends GetxController {
  WithdrawController({NetworkCaller? networkCaller})
      : _networkCaller = networkCaller ?? NetworkCaller();

  final NetworkCaller _networkCaller;

  final TextEditingController holderNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController ifscController = TextEditingController();
  final TextEditingController upiController = TextEditingController();

  final RxBool isSubmitting = false.obs;
  final RxnString lastError = RxnString();
  final RxnString successMessage = RxnString();

  @override
  void onClose() {
    holderNameController.dispose();
    accountNumberController.dispose();
    ifscController.dispose();
    upiController.dispose();
    super.onClose();
  }

  Future<void> submitBankDetails() async {
    final holderName = holderNameController.text.trim();
    final accountNumber = accountNumberController.text.trim();
    final ifsc = ifscController.text.trim();

    if (holderName.isEmpty || accountNumber.isEmpty || ifsc.isEmpty) {
      Get.snackbar(
        'Missing information',
        'Please enter account holder name, account number, and IFSC code.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return;
    }

    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) {
      lastError.value = 'Authentication required. Please log in again.';
      Get.snackbar(
        'Session expired',
        lastError.value!,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isSubmitting.value = true;
    lastError.value = null;
    successMessage.value = null;

    final uri = Uri.parse('$baseurl/payment/beneficiary/add').replace(
      queryParameters: {
        'bank_account_number': accountNumber,
        
        'bank_ifsc': ifsc,
        'bank_holder_name': holderName,
      },
      
    );

    final response = await _networkCaller.postRequest(
      uri.toString(),
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      encodeJson: false,
      defaultErrorMessage: 'Unable to add bank details. Please try again.',
    );

    isSubmitting.value = false;

    if (response.isSuccess) {
      final serverMessage = response.responseData is Map<String, dynamic>
          ? response.responseData['message']?.toString()
          : null;
          AppLoggerHelper.debug("status code ${response.statusCode}");
      successMessage.value = serverMessage ?? 'Bank added successfully';
      AppLoggerHelper.debug("Added Payment method${response.responseData}");
      Get.snackbar(
        'Success',
        successMessage.value!,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      lastError.value = response.errorMessage;
      Get.snackbar(
        'Error',
        lastError.value ?? 'Unable to add bank details.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}
