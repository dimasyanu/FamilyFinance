import 'package:flutter/material.dart';

void main() {
  runApp(const FamilyFinancialApp());
}

class FamilyFinancialApp extends StatelessWidget {
  const FamilyFinancialApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Family Financial',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const MyHomePage(title: 'Overview'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/profile.png'),
                ),
              ),
            ),
            ListTile(
              title: const Text('Overview'),
              leading: Icon(
                Icons.dashboard,
                color: Colors.green,
              ),
              onTap: () {
              },
            ),
            ListTile(
              title: const Text('Transactions'),
              leading: Icon(
                Icons.receipt,
                color: Colors.green,
              ),
              onTap: () {

              },
            ),
            ListTile(
              title: const Text('Accounts'),
              leading: Icon(
                Icons.wallet,
                color: Colors.green,
              ),
              onTap: () {

              },
            ),
            ListTile(
              title: const Text('Categories'),
              leading: Icon(
                Icons.category,
                color: Colors.green,
              ),
              onTap: () {

              },
            ),
            ListTile(
              title: const Text('Settings'),
              leading: Icon(
                Icons.settings,
                color: Colors.green,
              ),
              onTap: () {

              },
            ),
            Divider(),
            Expanded(child: Align(
              alignment: FractionalOffset.bottomLeft,
              child: ListTile(
                title: const Text('Logout'),
                leading: Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                textColor: Colors.red,
                onTap: () {},
              ),
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
