import 'package:flutter/material.dart';
import 'package:pay/pay.dart';
import 'payment_config.dart';

class PaymentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[100],
      appBar: AppBar(
        title: Text(
          'Sanatan Daan',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.orange[100],
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/donation_image.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Make a Donation',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Your donation will go towards a good cause and make a positive impact.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 30),
                GestureDetector(
                  onTap: () async {
                    final paymentItems = [
                      PaymentItem(
                        label: 'Total',
                        amount: '99.99',
                        status: PaymentItemStatus.final_price,
                      ),
                    ];

                    Pay payClient = Pay({
                      PayProvider.google_pay: PaymentConfiguration.fromJsonString(defaultGooglePay),
                      // Replace with your Google Pay configuration JSON
                    });

                    final result = await payClient.showPaymentSelector(
                      PayProvider.google_pay,
                      paymentItems,
                    );

                    print(result);
                  },
                  child: Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.orange[400],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.payment,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Donate Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
