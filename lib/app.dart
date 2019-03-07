import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import './pages/home.dart';
import './pages/link.dart';
import './pages/search.dart';

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AppState();
  }
}

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    print('state:$state');
    if (state == AppLifecycleState.resumed) {
      print('try check clipboard?');
      Clipboard.getData(Clipboard.kTextPlain).then((data) {
        if(data != null) {
          print('clipboard:${data.text}');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO:add splash screen
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      title: '极速下载',
      showSemanticsDebugger: false,
      home: HomePage(),
      routes: {
        HomePage.Tag: (_) => HomePage(),
        LinkPage.Tag: (_) => LinkPage(),
        SearchPage.Tag: (_) => SearchPage(),
      },
    );
  }
}

// App入口,监听状态变化以及splash
// class App extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() {
//     return _AppState();
//   }
// }

// class _AppState extends State<App> with WidgetsBindingObserver {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     print('created just call here?');

//     var url = 'thunder://QUFmdHA6Ly95Z2R5ODp5Z2R5OEB5ZzQ1LmR5ZHl0dC5uZXQ6NzM4OC8lRTklOTglQjMlRTUlODUlODklRTclOTQlQjUlRTUlQkQlQjF3d3cueWdkeTguY29tLiVFOSU5QyVCOCVFNCVCOCVCQi5IRC43MjBwLiVFNCVCOCVBRCVFOCU4QiVCMSVFNSU4RiU4QyVFNSVBRCU5NyVFNSVCOSU5NS5ta3ZaWg==';
//     var real = Util.parseThunder(url);
//     var dst =Uri.decodeFull(real);
//     var uri = Uri.parse(dst);
//     print('url:$real');
//     print('dst:$dst');
//     print('name:${uri.pathSegments.last}');
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);

//     print('state:$state');
//     if(state ==AppLifecycleState.resumed) {
//       print('try check clipboard?');
//       Clipboard.getData(Clipboard.kTextPlain).then((data){
//         print('clipboard:${data.text}');
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Navigator.pushNamed(context, HomePage.Tag);
//     return HomePage();
//   }
// }
