import 'package:flutter/material.dart';
import 'package:sharing_taxi/screens/g_history_screen.dart';
import 'package:sharing_taxi/screens/c_home_screen.dart';
import 'package:sharing_taxi/screens/a_profile_screen.dart';
import 'package:sharing_taxi/screens/e_journey_list_screen.dart';
import 'package:sharing_taxi/screens/f_saved_location_screen.dart';

class MyBottomAppbar extends StatefulWidget {
  final String? page;
  const MyBottomAppbar({
    Key? key,
    @required this.page,
  }) : super(key: key);

  @override
  State<MyBottomAppbar> createState() => _MyBottomAppbarState();
}

class _MyBottomAppbarState extends State<MyBottomAppbar> {
  // ignore: missing_required_param
  final page = const MyBottomAppbar().page;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 2,
      //shape: shape,
      color: Colors.white,
      child: IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.08,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              (widget.page == 'home')
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height * 0.08,
                      width: 135,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const HomeScreen();
                          }));
                        },
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(1),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          )),
                          backgroundColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 255, 205, 139)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.home,
                              size: 30,
                            ),
                            Text(
                              ' Home',
                              style: TextStyle(fontSize: 17),
                            )
                          ],
                        ),
                      ),
                    )
                  : IconButton(
                      tooltip: 'Home',
                      icon: Icon(
                        Icons.home,
                        size: 35,
                        color: Colors.grey[500],
                      ),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const HomeScreen();
                        }));
                      },
                    ),
              (widget.page == 'journey')
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height * 0.08,
                      width: 135,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const JourneyListScreen();
                          }));
                        },
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(1),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          )),
                          backgroundColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 255, 205, 139)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.explore,
                              size: 30,
                            ),
                            Text(
                              ' Journey\n List',
                              style: TextStyle(fontSize: 17),
                            )
                          ],
                        ),
                      ),
                    )
                  : IconButton(
                      tooltip: 'Journey List',
                      icon: Icon(
                        Icons.explore,
                        size: 35,
                        color: Colors.grey[500],
                      ),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const JourneyListScreen();
                        }));
                      },
                    ),
              (widget.page == 'history')
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height * 0.08,
                      width: 135,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const HistoryScreen();
                          }));
                        },
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(1),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          )),
                          backgroundColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 255, 205, 139)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.history,
                              size: 30,
                            ),
                            Text(
                              ' History',
                              style: TextStyle(fontSize: 17),
                            )
                          ],
                        ),
                      ),
                    )
                  : IconButton(
                      tooltip: 'History',
                      icon: Icon(
                        Icons.history,
                        size: 35,
                        color: Colors.grey[500],
                      ),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const HistoryScreen();
                        }));
                      },
                    ),
              (widget.page == 'savedlocation')
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height * 0.08,
                      width: 135,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const SavedLocationScreen();
                          }));
                        },
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(1),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          )),
                          backgroundColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 255, 205, 139)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.favorite,
                              size: 30,
                            ),
                            Text(
                              ' Saved\n Location',
                              style: TextStyle(fontSize: 17),
                            )
                          ],
                        ),
                      ),
                    )
                  : IconButton(
                      tooltip: 'Saved Location',
                      icon: Icon(
                        Icons.favorite,
                        size: 35,
                        color: Colors.grey[500],
                      ),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const SavedLocationScreen();
                        }));
                      },
                    ),
              (widget.page == 'profile')
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height * 0.08,
                      width: 135,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const ProfileScreen();
                          }));
                        },
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(1),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          )),
                          backgroundColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 255, 205, 139)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.person,
                              size: 30,
                            ),
                            Text(
                              ' Profile',
                              style: TextStyle(fontSize: 17),
                            )
                          ],
                        ),
                      ),
                    )
                  : IconButton(
                      tooltip: 'Profile',
                      icon: Icon(
                        Icons.person,
                        size: 35,
                        color: Colors.grey[500],
                      ),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const ProfileScreen();
                        }));
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
