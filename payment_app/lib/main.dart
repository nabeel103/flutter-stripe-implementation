import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

// pk_test_TYooMQauvdEDq54NiTphI7jx
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = 'pk_test_TYooMQauvdEDq54NiTphI7jx';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, dynamic>? paymentIntentData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await makePayment();
          },
          child: const Text('Click Me'),
        ),
      ),
    );
  }

  Future<void> makePayment() async {
    try {
      paymentIntentData = await createPaymementIntent('0.50', 'USD');
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntentData!['client_secret'],
        // applePay: const PaymentSheetApplePay(
        //   merchantCountryCode: 'US',
        // ),
        googlePay: const PaymentSheetGooglePay(
          merchantCountryCode: 'DE',
          testEnv: true,
        ),

        style: ThemeMode.dark,

        merchantDisplayName: 'Example Inc.',
        // testEnv: true,
      ));

      displyPaymentSheet();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  displyPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      setState(() {
        paymentIntentData = null;
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment succesfully completed'),
        ),
      );
    } on StripeException catch (e) {
      debugPrint(e.toString());
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.error.localizedMessage}'),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  createPaymementIntent(String amount, String currency) async {
    try {
      // Convert amount to cents as an integer
      int amountInCents = (double.parse(amount) * 100).toInt();

      Map<String, dynamic> body = {
        'amount': amountInCents.toString(),
        'currency': currency,
        'payment_method_types[]': 'card'
      };
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization': 'Bearer sk_test_4eC39HqLyjWDarjtT1zdp7dc',
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      debugPrint(response.body.toString());
      return jsonDecode(response.body.toString());
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
