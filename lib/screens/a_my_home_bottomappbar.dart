import 'package:flutter/material.dart';
import 'package:sharing_taxi/dump/fake_home_screen.dart';
import 'package:sharing_taxi/screens/c_home_screen.dart';

void main() {
  runApp(const MyHomeBottomAppBar());
}

class MyHomeBottomAppBar extends StatefulWidget {
  const MyHomeBottomAppBar({super.key});

  @override
  State createState() => _MyHomeBottomAppBarState();
}

class _MyHomeBottomAppBarState extends State<MyHomeBottomAppBar> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 2,
      shape: const CircularNotchedRectangle(),
      color: Colors.white,
      child: IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.08,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                tooltip: 'Home',
                icon: Icon(
                  Icons.home,
                  size: 35,
                  color: Colors.grey[800],
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const HomeScreen();
                  }));
                },
              ),
              IconButton(
                tooltip: 'Journey List',
                icon: Icon(
                  Icons.search,
                  size: 35,
                  color: Colors.grey[800],
                ),
                onPressed: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) {
                  //   return const JourneyListScreen();
                  // }));
                },
              ),
              IconButton(
                tooltip: 'History',
                icon: Icon(
                  Icons.history,
                  size: 35,
                  color: Colors.grey[800],
                ),
                onPressed: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) {
                  //   return const HistoryScreen();
                  // }));
                },
              ),
              IconButton(
                tooltip: 'Saved Location',
                icon: Icon(
                  Icons.favorite,
                  size: 35,
                  color: Colors.grey[800],
                ),
                onPressed: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) {
                  //   return const SavedLocationScreen();
                  // }));
                },
              ),
              IconButton(
                tooltip: 'Profile',
                icon: Icon(
                  Icons.person,
                  size: 35,
                  color: Colors.grey[800],
                ),
                onPressed: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) {
                  //   return const ProfileScreen();
                  // }));
                },
              ),
              SizedBox(
                width: MediaQuery.of(context).size.height * 0.1,
              )
            ],
          ),
        ),
      ),
    );
  }
}
