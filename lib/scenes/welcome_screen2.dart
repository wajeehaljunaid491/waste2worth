import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'login_screen.dart';

class WelcomeScreen2 extends StatelessWidget {
  const WelcomeScreen2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Section (50% with image and custom background color)
            Expanded(
              flex: 1,
              child: Container(
                color: const Color(0xFF90B290), // Custom green background
                child: Center(
                  child: Image.asset(
                    'assets/images/re7.png',
                    height: 250, // Adjust image size as needed
                  ),
                ),
              ),
            ),
            // Bottom Section (50% with text and buttons)
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Main Heading
                    const Text(
                      'Signing in helps us tailor your experience to your preferences.',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Subheading
                    const Text(
                      'By recycling, you conserve resources, reduce pollution.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    // Register Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>  RegisterScreen()),
                        );
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white, // Button text color
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50), backgroundColor:  const Color(0xFF90B290), // Darker green for the button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Rounded corners for button
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 32.0), // Button padding
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Sign In Button
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF90B290), // Green text color for the button
                        ),
                      ),
                      style: TextButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        padding: const EdgeInsets.symmetric(horizontal: 32.0), // Button padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Rounded corners for button
                        ),
                        side: const BorderSide(
                          color: const Color(0xFF90B290), // Green border for the button
                          width: 2, // Border width
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
