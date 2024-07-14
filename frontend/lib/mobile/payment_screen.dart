import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:frontend/mobile/blocs/socket_io/socket_io_bloc.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/services/payment.dart';
import 'package:frontend/widgets/title.dart';

class PaymentScreen extends StatelessWidget {
  final Flight flight;

  const PaymentScreen({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MainTitle(content: "Your flight"),
              const SizedBox(height: 24),
              const SecondaryTitle(content: "Departure"),
              const SizedBox(height: 10),
              Text(
                flight.departure.name,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                flight.departure.address,
              ),
              const SizedBox(height: 24),
              const SecondaryTitle(content: "Arrival"),
              const SizedBox(height: 10),
              Text(
                flight.arrival.name,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                flight.arrival.address,
              ),
              const SizedBox(height: 24),
              const SecondaryTitle(content: "Pilot"),
              const SizedBox(height: 10),
              Text(
                "${flight.pilot?.firstName} ${flight.pilot?.lastName}",
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  _handlePayment(context);
                },
                child: Text("Pay ${flight.price} €"),
              ),
            ],
          ),
        ));
  }

  void _handlePayment(BuildContext context) async {
    final response = await PaymentService.createPaymentIntent(
        flight.id, (flight.price! * 100).round());

    if (response == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create payment intent')),
      );
      return;
    }

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: response['client_secret'],
        merchantDisplayName: 'AirFleet',
      ),
    );

    try {
      await Stripe.instance.presentPaymentSheet();
      await PaymentService.verifyPaymentIntent(flight.id, response['id']);
      Navigator.of(context).pop();
      context
          .read<SocketIoBloc>()
          .add(SocketIoAcceptProposal(flightId: flight.id));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Failed: $e')),
      );
    }
  }
}
