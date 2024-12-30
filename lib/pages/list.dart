import 'package:flutter/material.dart';


import '../components/yellow_button.dart';
import '../const.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("list"),
        backgroundColor: AppColors.green,
      ),
      body: const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Stack(
            children: [
              Center(
                child: Text("list page content"),
              ),
            ],
          )),
      bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child:
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                children: [
                  YellowButton(
                    onPressed: () {},
                    iconUrl: 'lib/images/plan_lists.svg',
                    label: "Plan Lists",
                  ),
                  YellowButton(
                    onPressed: () {},
                    iconUrl: 'lib/images/plan_favorites.svg',
                    label: "Plan Favorites",
                  ),
          ])),
    );
  }
}
