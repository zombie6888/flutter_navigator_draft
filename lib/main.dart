import 'package:flutter/material.dart';
import 'package:router_app/navigation/custom_route_config.dart';
import 'package:url_strategy/url_strategy.dart';

class Page6 extends StatelessWidget {
  const Page6({super.key});

  @override
  Widget build(BuildContext context) {
    print('build page6');
    return Scaffold(
        appBar: AppBar(title: const Text("page6")),
        body:  Center(
          child: Column(
            children: [
              const Text(
                "page6",
                style: TextStyle(fontSize: 22),
              ),
              TextButton(
                  onPressed: () {
                    //Navigator.of(context).pushNamed('/page1');
                    router.pushNamed('/tab1/page6?test=2&tre=3');
                  },
                  child: const Text("/tab1/page6?test=2", style: TextStyle(fontSize: 22)))
            ],
          ),
        ));
  }
}

class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    print('build /tab2/page1');
    return Scaffold(
        appBar: AppBar(title: const Text("page1")),
        body: Center(
          child: Column(
            children: [
              const Text(
                "/tab2/page1",
                style: TextStyle(fontSize: 22),
              ),
              TextButton(
                  onPressed: () {
                    router.pushNamed('/tab3/page2');
                  },
                  child:
                      const Text("to page2", style: TextStyle(fontSize: 22))),
              TextButton(
                  onPressed: () {
                    //Navigator.of(context).pushNamed('/page1');
                    router.pushNamed('/tab1/page4?test=1');
                  },
                  child: const Text("to page4", style: TextStyle(fontSize: 22)))
            ],
          ),
        ));
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    print('home init state');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('build home');
    return Scaffold(        
        appBar: AppBar(title: const Text("home")),
        body: Center(
          child: Builder(builder: (context) {
            return Column(
              children: [
                const Text("home", style: TextStyle(fontSize: 22)),
                TextButton(
                    onPressed: () {
                      //Navigator.of(context).pushNamed('/page1');
                      router.pushNamed('/tab2/page1');
                    },
                    child:
                        const Text("to page1", style: TextStyle(fontSize: 22))),
                TextButton(
                    onPressed: () {
                      //Navigator.of(context).pushNamed('/page1');
                      router.pushNamed('/tab1/page4?test=1');
                    },
                    child:
                        const Text("to page4", style: TextStyle(fontSize: 22))),
                TextButton(
                    onPressed: () {
                      //Navigator.of(context).pushNamed('/page1');
                      router.pushNamed('/tab1/page6?test=1');
                    },
                    child:
                        const Text("to page6", style: TextStyle(fontSize: 22)))
              ],
            );
          }),
        ));
  }
}

class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    print('build page2');
    return Scaffold(
        appBar: AppBar(title: const Text("page2")),
        body: const Center(
          child: Column(
            children: [
              Text(
                "page2",
                style: TextStyle(fontSize: 22),
              ),
            ],
          ),
        ));
  }
}

class Page4 extends StatelessWidget {
  const Page4({super.key});

  @override
  Widget build(BuildContext context) {
    print('build tab1/page4');
    return Scaffold(
        appBar: AppBar(title: const Text("tab1/page4")),
        body:Center(
          child: Column(
            children: [
              const Text(
                "page4",
                style: TextStyle(fontSize: 22),
              ),
              TextButton(
                  onPressed: () {                   
                    router.pushNamed('/tab1/page5');
                  },
                  child:
                      const Text("to page5", style: TextStyle(fontSize: 22))),
              TextButton(
                  onPressed: () {                   
                    router.pushNamed('/tab1/page4?test=2');
                  },
                  child:
                      const Text("to page4?test=2", style: TextStyle(fontSize: 22))),        
            ],
          ),
        ));
  }
}

class Page5 extends StatelessWidget {
  const Page5({super.key});

  @override
  Widget build(BuildContext context) {
    print('build tab1/page5');
    return Scaffold(
        appBar: AppBar(title: const Text("tab1/page5")),
        body: const Center(
          child: Column(
            children: [
              Text(
                "page5",
                style: TextStyle(fontSize: 22),
              ),              
            ],
          ),
        ));
  }
}

void main() {
  setPathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      //  routeInformationParser: informationParser,
      //routerDelegate: router,
      routerConfig: routeConfig,

      // routes: {
      //   "/": (context) => HomePage(),
      //   "/page1": (context) => Page1(),
      //   "/page2": (context) => Page2(),
      // },
    );
  }
}
