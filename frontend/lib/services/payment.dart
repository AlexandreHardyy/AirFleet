import 'dio.dart';

class PaymentService {
  static createPaymentIntent(int flightId, int amount) async {
    try {
      final response = await dioApi.post(
        "/payment/create-intent",
        data: {'amount': amount, 'flightId': flightId},
      );


      if (response.statusCode != 200) {
        return null;
      }

      return response.data;
    } catch (e) {
      throw Exception('Something went wrong: ${e.toString()}');
    }
  }

  static verifyPaymentIntent(int flightId, String paymentId) async {
    try {
      final response = await dioApi.post(
        "/payment/verify",
        data: {'payment_id': paymentId, 'flight_id': flightId},
      );

      if (response.statusCode != 200) {
        return false;
      }

      return true;
    } catch (e) {
      throw Exception('Something went wrong: ${e.toString()}');
    }
  }
}
