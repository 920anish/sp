import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'gallery_screen.dart';
import 'membership_screen.dart';
import 'payment_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreenPage(),
    GalleryScreen(),
    MembershipForm(),
    PaymentScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Colors.orange[300]!,
        buttonBackgroundColor: Colors.orange[400],
        height: 55,
        animationDuration: Duration(milliseconds: 200),
        items: <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.photo, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
          Icon(Icons.payment, size: 30, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class HomeScreenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sanatan Pariwar',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,

          ),

        ),
        backgroundColor: Colors.orange[100],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/logo.png',
                  height: 200,
                  width: 200,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Introduction',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Sanatan Pariwar is a community dedicated to the principles and teachings of Sanatan Dharma (Hinduism). We strive to promote spiritual growth, uphold cultural heritage, foster unity, and serve society.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Goals and Objectives',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GoalObjectiveItem(
                      icon: Icons.check_circle,
                      text: 'Promote spiritual growth and enlightenment',
                    ),
                    GoalObjectiveItem(
                      icon: Icons.check_circle,
                      text: 'Preserve and uphold the rich cultural heritage',
                    ),
                    GoalObjectiveItem(
                      icon: Icons.check_circle,
                      text: 'Foster unity and harmony among followers',
                    ),
                    GoalObjectiveItem(
                      icon: Icons.check_circle,
                      text: 'Promote social welfare and service',
                    ),
                    GoalObjectiveItem(
                      icon: Icons.check_circle,
                      text: 'Educate and inspire future generations',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Pramukh Maargadarshak',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/profile_image.png'),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Pashupati Shah',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Spirtual Leader',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Pashupati Shah, the founder of Sanatan Pariwar, is a revered figure and a guiding force within the community. With a deep understanding and commitment to the principles of Sanatan Dharma.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Footer Section
              Text(
                'Follow Us',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SocialLinkIcon(
                    icon: FontAwesomeIcons.facebookF,
                    url: 'https://facebook.com/profile.php?id=100092264037871',
                  ),
                  SocialLinkIcon(
                    icon: FontAwesomeIcons.phone,
                    url: 'tel:+918250082790',
                  ),
                  SocialLinkIcon(
                    icon: FontAwesomeIcons.instagram,
                    url: 'https://instagram.com/920anish920',
                  ),
                  SocialLinkIcon(
                    icon: FontAwesomeIcons.youtube,
                    url: 'https://www.youtube.com/channel/UCisin93pguomFe9BfxkcdYw',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GoalObjectiveItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const GoalObjectiveItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class SocialLinkIcon extends StatelessWidget {
  final IconData icon;
  final String url;

  const SocialLinkIcon({
    required this.icon,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch $url';
        }
      },
      icon: Icon(
        icon,
        size: 30,
        color: Colors.grey[800],
      ),
    );
  }
}
