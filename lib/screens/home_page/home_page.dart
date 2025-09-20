import 'package:flutter/material.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:gate_pass_project/authentication/student_auth/student_login_view.dart';
import 'package:gate_pass_project/screens/face_detection/face_detection_view.dart';
import 'package:gate_pass_project/screens/list_of_jobs/list_of_jobs_view.dart';
import 'package:gate_pass_project/screens/student_profile_management/stud_profile_manag_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.studId, this.studentId = ''});
  final int studId;
  final String studentId;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<SliderDrawerState> _sliderDrawerKey =
      GlobalKey<SliderDrawerState>();
  String title = "Gate Pass";

  int _tabIndex = 2;
  int get tabIndex => _tabIndex;
  set tabIndex(int v) {
    _tabIndex = v;
    setState(() {});
  }

  String? studentId;
  int? studId;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: _tabIndex);
    studId = widget.studId;
    studentId = widget.studentId;
    print("User ID in Home Screen: $studId");
    print("studentId in Home Screen: $studentId");
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to close the dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text('Do you really want to log out?')],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                // If "No" is pressed, just close the dialog
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                // If "Yes" is pressed, close the dialog and navigate back to the login page.
                // Using pushReplacement ensures the user can't go back to the home page.
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const StudentLoginPage(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SliderDrawer(
          key: _sliderDrawerKey,
          sliderOpenSize: 300.0,
          slideDirection: SlideDirection.leftToRight,
          sliderBoxShadow: SliderBoxShadow(
            blurRadius: 25,
            spreadRadius: 5,
            color: const Color.fromARGB(255, 94, 135, 168),
          ),
          slider: _buildDrawer(),
          appBar: SliderAppBar(
            config: SliderAppBarConfig(
              title: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          child: SafeArea(
            child: Scaffold(
              extendBody: true,
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  if (studId != null) {
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) {
                    //     //  return ChatScreen(userId: userId!);
                    //     },
                    //   ),
                    // );
                  } else {
                    // Optional: handle error or show a toast/snackbar
                  }
                },
                child: Icon(Icons.chat),
              ),
              bottomNavigationBar: CircleNavBar(
                activeIcons: const [
                  Icon(Icons.outbond_outlined, color: Colors.deepPurple),
                  Icon(Icons.access_time, color: Colors.deepPurple),
                  Icon(Icons.home, color: Colors.deepPurple),
                  Icon(Icons.work, color: Colors.deepPurple),
                  // Icon(
                  //   Icons.production_quantity_limits,
                  //   color: Colors.deepPurple,
                  // ),
                  Icon(Icons.logout, color: Colors.deepPurple),
                ],
                inactiveIcons: const [
                  Text("Out"),
                  Text("Attendence"),
                  Text("Home"),
                  Text("View Jobs"),
                  // Text("buy Products"),
                  Text("Logout"),
                ],
                color: Colors.white,
                height: 60,
                circleWidth: 60,
                activeIndex: tabIndex,
                onTap: (index) {
                  tabIndex = index;
                  pageController.jumpToPage(tabIndex);
                  if (index == 0) {
                  } else if (index == 1) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => FaceDetectionScreen(
                          studId: studId!,
                          studentId: studentId!,
                        ),
                      ),
                    );
                  } else if (index == 2) {
                  } else if (index == 3) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CompanyListView(userId: studId!),
                      ),
                    );
                  } else if (index == 4) {
                    _showLogoutDialog(context);
                  }
                },
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
                cornerRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
                shadowColor: const Color.fromARGB(255, 248, 219, 175),
                elevation: 10,
              ),
              body: PageView(
                controller: pageController,
                onPageChanged: (v) {
                  tabIndex = v;
                },
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: const Color.fromARGB(255, 158, 233, 225),
                  ),
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: const Color.fromARGB(255, 180, 210, 235),
                  ),
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: const Color.fromARGB(255, 162, 238, 209),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Container(
      width: 200.0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(top: 70),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 50, color: Colors.white),
              // backgroundImage: AssetImage('assets/images/user.png'),
            ),
            SizedBox(height: 10),
            Text('name'),
            SizedBox(height: 30),
            ListTile(
              leading: Icon(
                Icons.home,
                color: Color.fromARGB(255, 163, 79, 182),
              ),
              title: Text(
                "Home",
                style: TextStyle(color: Color.fromARGB(255, 14, 13, 13)),
              ),
              selectedColor: Colors.purple,
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) {
                      return HomeScreen(studId: studId!, studentId: studentId!);
                    },
                  ),
                );
              },
            ),
            // ListTile(
            //   leading: Icon(
            //     Icons.feedback_outlined,
            //     color: Color.fromARGB(255, 163, 79, 182),
            //   ),
            //   title: Text(
            //     "Feedback",
            //     style: TextStyle(color: Color.fromARGB(255, 10, 10, 10)),
            //   ),
            // ),
            ListTile(
              leading: Icon(
                Icons.book_rounded,
                color: Color.fromARGB(255, 103, 30, 119),
              ),
              title: Text(
                "Profile Management",
                style: TextStyle(color: Color.fromARGB(255, 10, 10, 10)),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return StudentProfileScreen(studId: studId!);
                    },
                  ),
                );
                //StudentProfileScreen(studId: studId!,);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.paypal_sharp,
                color: Color.fromARGB(255, 163, 79, 182),
              ),
              title: Text(
                "Videos",
                style: TextStyle(color: Color.fromARGB(255, 10, 10, 10)),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.info_outlined,
                color: Color.fromARGB(255, 163, 79, 182),
              ),
              title: Text(
                "Articles",
                style: TextStyle(color: Color.fromARGB(255, 10, 10, 10)),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: Color.fromARGB(255, 163, 79, 182),
              ),
              title: Text(
                "Links",
                style: TextStyle(color: Color.fromARGB(255, 10, 10, 10)),
              ),
              onTap: () {
                // Navigator.of(context).pushReplacement(
                //   MaterialPageRoute(
                //     builder: (context) {
                //       return const LoginScreen();
                //     },
                //   ),
                // );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.info_outlined,
                color: Color.fromARGB(255, 163, 79, 182),
              ),
              title: Text(
                "Do or Don'ts",
                style: TextStyle(color: Color.fromARGB(255, 10, 10, 10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
