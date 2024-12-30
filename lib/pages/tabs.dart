import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import './home.dart';
import './plan.dart';
import './list.dart';
import './me.dart';

class Tabs extends StatefulWidget {
  final int index;
  const Tabs({super.key,this.index = 0});

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  late int _currentIndex;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentIndex = widget.index;
  }

  final List<Widget> _pages = const [
    HomePage(),
    PlanPage(),
    ListPage(),
    MePage(),
  ];


  @override
  Widget build(BuildContext context) {
     return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          iconSize: 15,
          selectedItemColor: Colors.yellow,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) => {
                setState(() {
                  _currentIndex = index;
                })
              },
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'lib/images/Home.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                    _currentIndex == 0 ? Colors.yellow : Colors.grey,
                    BlendMode.srcIn),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'lib/images/Plan.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                    _currentIndex == 1 ? Colors.yellow : Colors.grey,
                    BlendMode.srcIn),
              ),
              label: 'Plan',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'lib/images/List.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                    _currentIndex == 2 ? Colors.yellow : Colors.grey,
                    BlendMode.srcIn),
              ),
              label: 'List',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'lib/images/Me.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                    _currentIndex == 3 ? Colors.yellow : Colors.grey,
                    BlendMode.srcIn),
              ),
              label: 'Me',
            ),
          ]),
    );
  }
}