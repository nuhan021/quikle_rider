import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/services/network_caller.dart';
import 'package:quikle_rider/core/services/storage_service.dart';
import 'package:quikle_rider/core/utils/constants/api_constants.dart';
import 'package:quikle_rider/core/utils/logging/logger.dart';
import 'package:quikle_rider/features/wallet/controllers/wallet_controller.dart';

class WithdrawController extends GetxController {
  WithdrawController({NetworkCaller? networkCaller})
    : _networkCaller = networkCaller ?? NetworkCaller();

  final NetworkCaller _networkCaller;
  final WalletController? _walletController =
      Get.isRegistered<WalletController>() ? Get.find<WalletController>() : null;

  final TextEditingController holderNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController ifscController = TextEditingController();
  final TextEditingController upiController = TextEditingController();
  final TextEditingController withdrawalAmountController =
      TextEditingController();

  final RxBool isSubmitting = false.obs;
  final RxBool isFetchingBeneficiaries = false.obs;
  final RxBool isRequestingWithdrawal = false.obs;
  final RxnString lastError = RxnString();
  final RxnString successMessage = RxnString();
  final RxList<Map<String, dynamic>> beneficiaries =
      <Map<String, dynamic>>[].obs;
  final RxnInt selectedBeneficiaryId = RxnInt();
  final Rxn<Map<String, dynamic>> lastWithdrawalData =
      Rxn<Map<String, dynamic>>();
  final Rxn<Map<String, dynamic>> lastWithdrawalStatus =
      Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    fetchBeneficiaries();
  }

  @override
  void onClose() {
    holderNameController.dispose();

    accountNumberController.dispose();
    ifscController.dispose();
    upiController.dispose();
    withdrawalAmountController.dispose();
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

    final response = await _networkCaller.postRequest(
      '$baseurl/payment/beneficiary/add',
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: {
        'bank_account_number': accountNumber,
        'bank_ifsc': ifsc,
        'bank_holder_name': holderName,
      },
      encodeJson: true,
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
      accountNumberController.clear();
      ifscController.clear();
      holderNameController.clear();

      await fetchBeneficiaries();
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

  Future<void> fetchBeneficiaries() async {
    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) {
      lastError.value = 'Authentication required. Please log in again.';
      return;
    }

    isFetchingBeneficiaries.value = true;
    lastError.value = null;

    final response = await _networkCaller.getRequest(
      '$baseurl/payment/beneficiary',
      headers: {'accept': 'application/json', 'Authorization': 'Bearer $token'},
      defaultErrorMessage: 'Unable to load beneficiaries.',
    );

    isFetchingBeneficiaries.value = false;

    if (response.isSuccess && response.responseData is List) {
      beneficiaries.assignAll(
        List<Map<String, dynamic>>.from(response.responseData as List),
      );
      if (beneficiaries.isNotEmpty) {
        selectedBeneficiaryId.value =
            selectedBeneficiaryId.value ?? beneficiaries.first['id'] as int?;
      }
    } else {
      lastError.value = response.errorMessage;
      beneficiaries.clear();
    }
  }

  Future<void> requestWithdrawal() async {
    final token = StorageService.accessToken;
    final selectedId = selectedBeneficiaryId.value;
    final amountText = withdrawalAmountController.text.trim();

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

    if (selectedId == null) {
      Get.snackbar(
        'No beneficiary',
        'Please select a beneficiary to withdraw to.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (amountText.isEmpty) {
      Get.snackbar(
        'Missing amount',
        'Please enter an amount to withdraw.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      Get.snackbar(
        'Invalid amount',
        'Please enter a valid amount to withdraw.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return;
    }

    isRequestingWithdrawal.value = true;
    lastError.value = null;
    successMessage.value = null;
    lastWithdrawalData.value = null;

    final uri = Uri.parse(
      '$baseurl/payment/request',
    ).replace(queryParameters: {'ben_id': selectedId.toString()});

    final response = await _networkCaller.postRequest(
      uri.toString(),
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: {
        'amount': amount,
        'idempotency_key': 'withdraw_${DateTime.now().millisecondsSinceEpoch}',
      },
      encodeJson: true,
      defaultErrorMessage:
          'Unable to submit withdrawal request. Please try again.',
    );

    isRequestingWithdrawal.value = false;

    if (response.isSuccess) {
      if (response.responseData is Map<String, dynamic>) {
        final data = response.responseData as Map<String, dynamic>;
        lastWithdrawalData.value = (data['data'] is Map<String, dynamic>)
            ? Map<String, dynamic>.from(data['data'])
            : null;
      }
      final newId = lastWithdrawalData.value?['id']?.toString();
      if (newId != null && newId.isNotEmpty) {
        fetchWithdrawalStatus(newId);
      }
      successMessage.value = (response.responseData is Map<String, dynamic>)
          ? response.responseData['message']?.toString()
          : 'Withdrawal request accepted.';
     
      Get.snackbar(
        'Success',
        successMessage.value!,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      // keep wallet data in sync after a successful withdrawal
      await Future.wait([
        _walletController?.fetchCurrentBalance() ?? Future.value(),
        _walletController?.fetchWithdrawalHistory() ?? Future.value(),
      ]);
    } else {
      lastError.value = response.errorMessage;
      Get.snackbar(
        'Error',
        lastError.value ?? 'Unable to submit withdrawal request.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> fetchWithdrawalStatus(String transactionId) async {
    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) {
      lastError.value = 'Authentication required. Please log in again.';
      return;
    }

    final uri = '$baseurl/payment/$transactionId/status';

    final response = await _networkCaller.getRequest(
      uri,
      headers: {'accept': 'application/json', 'Authorization': 'Bearer $token'},
      defaultErrorMessage: 'Unable to fetch withdrawal status.',
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      lastWithdrawalStatus.value = Map<String, dynamic>.from(
        response.responseData as Map,
      );
    } else {
      lastError.value = response.errorMessage;
    }
  }
}
