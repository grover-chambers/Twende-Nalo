import 'dart:convert';
import 'package:http/http.dart' as http;

enum MpesaEnvironment { sandbox, production }

class MpesaPaymentResult {
  final bool success;
  final String? transactionId;
  final String? checkoutRequestId;
  final String? responseCode;
  final String? responseDescription;
  final String? customerMessage;
  final String? errorMessage;

  MpesaPaymentResult({
    required this.success,
    this.transactionId,
    this.checkoutRequestId,
    this.responseCode,
    this.responseDescription,
    this.customerMessage,
    this.errorMessage,
  });

  factory MpesaPaymentResult.success({
    required String transactionId,
    required String checkoutRequestId,
    String? customerMessage,
  }) {
    return MpesaPaymentResult(
      success: true,
      transactionId: transactionId,
      checkoutRequestId: checkoutRequestId,
      customerMessage: customerMessage,
    );
  }

  factory MpesaPaymentResult.failure({
    required String errorMessage,
    String? responseCode,
    String? responseDescription,
  }) {
    return MpesaPaymentResult(
      success: false,
      errorMessage: errorMessage,
      responseCode: responseCode,
      responseDescription: responseDescription,
    );
  }
}

class MpesaService {
  final MpesaEnvironment environment;
  final String consumerKey;
  final String consumerSecret;
  final String shortCode;
  final String passkey;
  final String callbackUrl;

  late final String _baseUrl;
  String? _accessToken;
  DateTime? _tokenExpiry;

  MpesaService({
    required this.environment,
    required this.consumerKey,
    required this.consumerSecret,
    required this.shortCode,
    required this.passkey,
    required this.callbackUrl,
  }) {
    _baseUrl = environment == MpesaEnvironment.sandbox
        ? 'https://sandbox.safaricom.co.ke'
        : 'https://api.safaricom.co.ke';
  }

  // Get OAuth access token
  Future<String?> _getAccessToken() async {
    if (_accessToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken;
    }

    try {
      final credentials = base64Encode(utf8.encode('$consumerKey:$consumerSecret'));
      
      final response = await http.get(
        Uri.parse('$_baseUrl/oauth/v1/generate?grant_type=client_credentials'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
        
        // Token typically expires in 3600 seconds (1 hour)
        final expiresIn = data['expires_in'] ?? 3600;
        _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn - 300)); // 5 min buffer
        
        return _accessToken;
      } else {
        throw Exception('Failed to get access token: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting M-Pesa access token: $e');
    }
  }

  // Generate password for STK Push
  String _generatePassword() {
    final timestamp = _getTimestamp();
    final data = '$shortCode$passkey$timestamp';
    return base64Encode(utf8.encode(data));
  }

  // Get current timestamp in the required format
  String _getTimestamp() {
    final now = DateTime.now();
    return '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';
  }

  // Validate phone number format
  String _formatPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Handle different phone number formats
    if (cleaned.startsWith('0')) {
      cleaned = '254${cleaned.substring(1)}';
    } else if (cleaned.startsWith('+254')) {
      cleaned = cleaned.substring(1);
    } else if (!cleaned.startsWith('254')) {
      cleaned = '254$cleaned';
    }
    
    // Validate Kenya mobile number format
    if (!RegExp(r'^254[17]\d{8}$').hasMatch(cleaned)) {
      throw Exception('Invalid Kenyan phone number format');
    }
    
    return cleaned;
  }

  // STK Push payment
  Future<MpesaPaymentResult> stkPush({
    required String phoneNumber,
    required double amount,
    required String accountReference,
    required String transactionDesc,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        return MpesaPaymentResult.failure(
          errorMessage: 'Failed to get access token',
        );
      }

      final formattedPhone = _formatPhoneNumber(phoneNumber);
      final timestamp = _getTimestamp();
      final password = _generatePassword();

      final requestBody = {
        'BusinessShortCode': shortCode,
        'Password': password,
        'Timestamp': timestamp,
        'TransactionType': 'CustomerPayBillOnline',
        'Amount': amount.round(),
        'PartyA': formattedPhone,
        'PartyB': shortCode,
        'PhoneNumber': formattedPhone,
        'CallBackURL': callbackUrl,
        'AccountReference': accountReference,
        'TransactionDesc': transactionDesc,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/mpesa/stkpush/v1/processrequest'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['ResponseCode'] == '0') {
        return MpesaPaymentResult.success(
          transactionId: responseData['MerchantRequestID'],
          checkoutRequestId: responseData['CheckoutRequestID'],
          customerMessage: responseData['CustomerMessage'],
        );
      } else {
        return MpesaPaymentResult.failure(
          errorMessage: responseData['errorMessage'] ?? 'STK Push failed',
          responseCode: responseData['ResponseCode'],
          responseDescription: responseData['ResponseDescription'],
        );
      }
    } catch (e) {
      return MpesaPaymentResult.failure(
        errorMessage: 'Error initiating STK Push: $e',
      );
    }
  }

  // Query STK Push transaction status
  Future<MpesaPaymentResult> queryStkPushStatus({
    required String checkoutRequestId,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        return MpesaPaymentResult.failure(
          errorMessage: 'Failed to get access token',
        );
      }

      final timestamp = _getTimestamp();
      final password = _generatePassword();

      final requestBody = {
        'BusinessShortCode': shortCode,
        'Password': password,
        'Timestamp': timestamp,
        'CheckoutRequestID': checkoutRequestId,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/mpesa/stkpushquery/v1/query'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final resultCode = responseData['ResultCode'];
        
        if (resultCode == '0') {
          // Transaction successful
          return MpesaPaymentResult.success(
            transactionId: responseData['MpesaReceiptNumber'],
            checkoutRequestId: checkoutRequestId,
            customerMessage: 'Payment completed successfully',
          );
        } else if (resultCode == '1032') {
          // Transaction cancelled by user
          return MpesaPaymentResult.failure(
            errorMessage: 'Transaction cancelled by user',
            responseCode: resultCode,
            responseDescription: responseData['ResultDesc'],
          );
        } else if (resultCode == '1037') {
          // Transaction timed out
          return MpesaPaymentResult.failure(
            errorMessage: 'Transaction timed out',
            responseCode: resultCode,
            responseDescription: responseData['ResultDesc'],
          );
        } else {
          // Other failure
          return MpesaPaymentResult.failure(
            errorMessage: responseData['ResultDesc'] ?? 'Transaction failed',
            responseCode: resultCode,
            responseDescription: responseData['ResultDesc'],
          );
        }
      } else {
        return MpesaPaymentResult.failure(
          errorMessage: 'Failed to query transaction status',
        );
      }
    } catch (e) {
      return MpesaPaymentResult.failure(
        errorMessage: 'Error querying STK Push status: $e',
      );
    }
  }

  // C2B Register URLs (for production setup)
  Future<bool> registerC2BUrls({
    required String validationUrl,
    required String confirmationUrl,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) return false;

      final requestBody = {
        'ShortCode': shortCode,
        'ResponseType': 'Completed',
        'ConfirmationURL': confirmationUrl,
        'ValidationURL': validationUrl,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/mpesa/c2b/v1/registerurl'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error registering C2B URLs: $e');
      return false;
    }
  }

  // B2C Payment (for refunds or rider payments)
  Future<MpesaPaymentResult> b2cPayment({
    required String phoneNumber,
    required double amount,
    required String remarks,
    String? occassion,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        return MpesaPaymentResult.failure(
          errorMessage: 'Failed to get access token',
        );
      }

      final formattedPhone = _formatPhoneNumber(phoneNumber);

      final requestBody = {
        'InitiatorName': 'TwendeNalo', // This should be configured in M-Pesa portal
        'SecurityCredential': _getSecurityCredential(),
        'CommandID': 'BusinessPayment',
        'Amount': amount.round(),
        'PartyA': shortCode,
        'PartyB': formattedPhone,
        'Remarks': remarks,
        'QueueTimeOutURL': '$callbackUrl/timeout',
        'ResultURL': '$callbackUrl/result',
        'Occassion': occassion ?? remarks,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/mpesa/b2c/v1/paymentrequest'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['ResponseCode'] == '0') {
        return MpesaPaymentResult.success(
          transactionId: responseData['ConversationID'],
          checkoutRequestId: responseData['OriginatorConversationID'],
          customerMessage: responseData['ResponseDescription'],
        );
      } else {
        return MpesaPaymentResult.failure(
          errorMessage: responseData['errorMessage'] ?? 'B2C Payment failed',
          responseCode: responseData['ResponseCode'],
          responseDescription: responseData['ResponseDescription'],
        );
      }
    } catch (e) {
      return MpesaPaymentResult.failure(
        errorMessage: 'Error initiating B2C payment: $e',
      );
    }
  }

  // Generate security credential for B2C (simplified - in production use proper certificate)
  String _getSecurityCredential() {
    // This is a placeholder. In production, you need to:
    // 1. Get the M-Pesa certificate from Safaricom
    // 2. Encrypt your initiator password using the certificate
    // 3. Return the encrypted credential
    return 'PLACEHOLDER_SECURITY_CREDENTIAL';
  }

  // Account Balance
  Future<Map<String, dynamic>?> getAccountBalance() async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) return null;

      final requestBody = {
        'Initiator': 'TwendeNalo',
        'SecurityCredential': _getSecurityCredential(),
        'CommandID': 'AccountBalance',
        'PartyA': shortCode,
        'IdentifierType': '4',
        'Remarks': 'Account balance inquiry',
        'QueueTimeOutURL': '$callbackUrl/timeout',
        'ResultURL': '$callbackUrl/balance',
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/mpesa/accountbalance/v1/query'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting account balance: $e');
      return null;
    }
  }

  // Process callback response
  static Map<String, dynamic>? processCallback(String callbackBody) {
    try {
      final data = jsonDecode(callbackBody);
      
      if (data['Body'] != null && data['Body']['stkCallback'] != null) {
        final callback = data['Body']['stkCallback'];
        final resultCode = callback['ResultCode'];
        
        Map<String, dynamic> result = {
          'success': resultCode == 0,
          'resultCode': resultCode,
          'resultDesc': callback['ResultDesc'],
          'merchantRequestId': callback['MerchantRequestID'],
          'checkoutRequestId': callback['CheckoutRequestID'],
        };

        if (resultCode == 0 && callback['CallbackMetadata'] != null) {
          final metadata = callback['CallbackMetadata']['Item'];
          for (var item in metadata) {
            switch (item['Name']) {
              case 'Amount':
                result['amount'] = item['Value'];
                break;
              case 'MpesaReceiptNumber':
                result['mpesaReceiptNumber'] = item['Value'];
                break;
              case 'TransactionDate':
                result['transactionDate'] = item['Value'];
                break;
              case 'PhoneNumber':
                result['phoneNumber'] = item['Value'];
                break;
            }
          }
        }

        return result;
      }
      return null;
    } catch (e) {
      print('Error processing M-Pesa callback: $e');
      return null;
    }
  }

  // Utility method to validate amount
  static bool isValidAmount(double amount) {
    return amount >= 1 && amount <= 70000; // M-Pesa limits
  }

  // Get user-friendly error message
  static String getUserFriendlyError(String? responseCode) {
    switch (responseCode) {
      case '1':
        return 'Insufficient balance. Please top up and try again.';
      case '1032':
        return 'Transaction was cancelled by user.';
      case '1037':
        return 'Transaction timed out. Please try again.';
      case '2001':
        return 'Invalid PIN entered. Please try again.';
      case '1001':
        return 'Invalid phone number. Please check and try again.';
      case '9999':
        return 'Request cancelled by user.';
      default:
        return 'Transaction failed. Please try again or contact support.';
    }
  }
}

// Callback data models
class MpesaCallback {
  final String merchantRequestId;
  final String checkoutRequestId;
  final int resultCode;
  final String resultDesc;
  final double? amount;
  final String? mpesaReceiptNumber;
  final DateTime? transactionDate;
  final String? phoneNumber;

  MpesaCallback({
    required this.merchantRequestId,
    required this.checkoutRequestId,
    required this.resultCode,
    required this.resultDesc,
    this.amount,
    this.mpesaReceiptNumber,
    this.transactionDate,
    this.phoneNumber,
  });

  bool get isSuccessful => resultCode == 0;

  factory MpesaCallback.fromMap(Map<String, dynamic> map) {
    return MpesaCallback(
      merchantRequestId: map['merchantRequestId'] ?? '',
      checkoutRequestId: map['checkoutRequestId'] ?? '',
      resultCode: map['resultCode'] ?? -1,
      resultDesc: map['resultDesc'] ?? '',
      amount: map['amount']?.toDouble(),
      mpesaReceiptNumber: map['mpesaReceiptNumber'],
      transactionDate: map['transactionDate'] != null
          ? DateTime.tryParse(map['transactionDate'].toString())
          : null,
      phoneNumber: map['phoneNumber'],
    );
  }
}
