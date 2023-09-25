import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void launchGithub() =>
      launchUrl(Uri.parse('https://github.com/taleroangel/ratonight'),
          mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text("About")),
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 180,
                  width: 180,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage("assets/icon.png"),
                    ),
                  ),
                ),
                Text(
                  "Ratonight",
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: const [
                      TextSpan(text: "Made with ❤️ for Ratona 🐭\n"),
                      TextSpan(text: "Built with Flutter 🐦️\n"),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: launchGithub,
                  icon: const Icon(Icons.people_alt_rounded),
                  label: const Text("GitHub Respository"),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LicensePage(),
                    ),
                  ),
                  icon: const Icon(Icons.balance_rounded),
                  label: const Text("Software Licences"),
                ),
              ].separatedBy(const SizedBox(height: 24.0))),
        ),
      );
}
