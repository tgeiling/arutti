import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'provider.dart';

class QuestionnaireScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const QuestionnaireScreen({Key? key, required this.onComplete})
      : super(key: key);

  @override
  _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_updatePage);
  }

  void _updatePage() {
    if (_pageController.page!.toInt() != _currentPage) {
      setState(() {
        _currentPage = _pageController.page!.toInt();
      });
    }
  }

  void _finishQuestionnaire() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('questionnaireDone', true);
    widget.onComplete();
  }

  @override
  void dispose() {
    _pageController.removeListener(_updatePage);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white, // Background set to white
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            IntroductionPage(pageController: _pageController),
            UserDataPage(pageController: _pageController),
            MeasurementsPage(pageController: _pageController),
            CompletionPage(onFinish: _finishQuestionnaire),
          ],
        ),
      ),
    );
  }
}

class IntroductionPage extends StatelessWidget {
  final PageController pageController;

  const IntroductionPage({Key? key, required this.pageController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            'Willkommen bei Arutti!',
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 16),
          Text(
            'Damit wir die App optimal auf deine Bedürfnisse zuschneiden können, '
            'benötigen wir ein paar Informationen von dir.',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Colors.black54,
                ),
            textAlign: TextAlign.left,
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              backgroundColor: Colors.black, // Button color set to black
            ),
            child: const Text(
              "Los geht's",
              style: TextStyle(fontSize: 18, color: Colors.white), // White text
            ),
          ),
        ],
      ),
    );
  }
}

class UserDataPage extends StatefulWidget {
  final PageController pageController;

  const UserDataPage({Key? key, required this.pageController})
      : super(key: key);

  @override
  _UserDataPageState createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userDataProvider =
        Provider.of<UserDataProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.all(32.0),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            'Deine Daten',
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
          ),
          const SizedBox(height: 16),
          _buildTextField(_firstNameController, 'Vorname'),
          const SizedBox(height: 16),
          _buildTextField(_surnameController, 'Nachname'),
          const SizedBox(height: 16),
          _buildTextField(_emailController, 'E-Mail'),
          const SizedBox(height: 16),
          _buildTextField(_telephoneController, 'Telefonnummer'),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              userDataProvider.setFirstName(_firstNameController.text);
              userDataProvider.setSurname(_surnameController.text);
              userDataProvider.setEmail(_emailController.text);
              userDataProvider.setTelephone(_telephoneController.text);

              widget.pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              backgroundColor: Colors.black, // Button color set to black
            ),
            child: const Text(
              'Weiter',
              style: TextStyle(fontSize: 18, color: Colors.white), // White text
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: Colors.grey[200], // Light gray background
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class MeasurementsPage extends StatefulWidget {
  final PageController pageController;

  const MeasurementsPage({Key? key, required this.pageController})
      : super(key: key);

  @override
  _MeasurementsPageState createState() => _MeasurementsPageState();
}

class _MeasurementsPageState extends State<MeasurementsPage> {
  final TextEditingController _chestController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();
  final TextEditingController _hipsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userDataProvider =
        Provider.of<UserDataProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.all(32.0),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            'Deine Maße',
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
          ),
          const SizedBox(height: 16),
          _buildTextField(_chestController, 'Brust (cm)'),
          const SizedBox(height: 16),
          _buildTextField(_waistController, 'Taille (cm)'),
          const SizedBox(height: 16),
          _buildTextField(_hipsController, 'Hüfte (cm)'),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              userDataProvider
                  .setChest(int.tryParse(_chestController.text) ?? 0);
              userDataProvider
                  .setWaist(int.tryParse(_waistController.text) ?? 0);
              userDataProvider.setHips(int.tryParse(_hipsController.text) ?? 0);

              widget.pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              backgroundColor: Colors.black, // Button color set to black
            ),
            child: const Text(
              'Weiter',
              style: TextStyle(fontSize: 18, color: Colors.white), // White text
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: Colors.grey[200], // Light gray background
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class CompletionPage extends StatelessWidget {
  final VoidCallback onFinish;

  const CompletionPage({Key? key, required this.onFinish}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            'Vielen Dank!',
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Deine Daten wurden gespeichert. Du kannst jetzt die App vollständig nutzen.',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Colors.black54,
                ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: onFinish,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              backgroundColor: Colors.black, // Button color set to black
            ),
            child: const Text(
              'Fertigstellen',
              style: TextStyle(fontSize: 18, color: Colors.white), // White text
            ),
          ),
        ],
      ),
    );
  }
}
