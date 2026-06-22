import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_with_hive/Services/ResponseModel/resonse_model.dart';
import 'package:flutter_with_hive/Services/post_requests.dart';
import 'package:flutter_with_hive/core/utils/api_urls.dart';
import 'package:flutter_with_hive/core/utils/print_log.dart';
import 'package:get/get.dart';

class StripeTestingController extends GetxController {
  final RxInt amountInCents = 0.obs;
  final RxBool isLoadingStripe = false.obs;

  Future<void> postStripeData(BuildContext context, int amount) async {
    final data = {'amount': amount};
    isLoadingStripe.value = true;

    final ResponseModel response = await APIsCallPost.payStripWithBody(
      ApiUrls.payStripPayment,
      data,
    );
    isLoadingStripe.value = false;

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dynamic stripeResponse = jsonDecode(response.data);
      final clientSecretKey = stripeResponse['clientSecret'] ?? '';
      printLog('Stripe client secret received: $clientSecretKey');
      try {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecretKey,
            merchantDisplayName: 'Stripe testing',
          ),
        );
        await Stripe.instance.presentPaymentSheet();
      } on StripeException catch (e) {
        printLog('StripeException: ${e.error.localizedMessage}');
        return;
      } catch (e) {
        printLog('Unexpected error presenting payment sheet: $e');
        return;
      }
    }
  }
}
