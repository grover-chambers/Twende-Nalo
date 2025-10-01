import 'mpesa_service.dart';

class PaymentGatewayService {
  final MpesaService mpesaService;

  PaymentGatewayService({required this.mpesaService});

  Future<MpesaPaymentResult> processPayment({
    required String phoneNumber,
    required double amount,
    required String accountReference,
    required String transactionDesc,
  }) async {
    try {
      return await mpesaService.stkPush(
        phoneNumber: phoneNumber,
        amount: amount,
        accountReference: accountReference,
        transactionDesc: transactionDesc,
      );
    } catch (e) {
      return MpesaPaymentResult.failure(
        errorMessage: 'Payment processing failed: $e',
      );
    }
  }
}
