
import 'package:batt/test_cubit.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => TestCubit(),
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: MyHomePage(),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _sw_value = false;
  TextEditingController _controller = TextEditingController(text: "url");

  Future<Null> tmp() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _controller = TextEditingController(text: prefs.getString("url"));
    });
  }

  @override
  void initState(){
    super.initState();
    tmp();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TestCubit, TestState>(builder: (context, state) {
      return Scaffold(
        backgroundColor: state.status,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("You have to enter the url you want to connect"
                  "and replace the battery value by \$battery"),
              const SizedBox(
                height: 50,
              ),
              TextField(
                controller: _controller,
                maxLines: null,
                keyboardType: TextInputType.url,
                onChanged: (url) =>
                    context.read<TestCubit>().urlChanged(url),
              ),

              const SizedBox(
                height: 50,
              ),
              CupertinoSwitch(
                  activeColor: Colors.cyanAccent,
                  value: _sw_value,
                  onChanged: (value){
                    setState(() {
                      _sw_value = value;
                    });
                    if (value == true){
                      BlocProvider.of<TestCubit>(context).validate();
                    }
                    else {
                      BlocProvider.of<TestCubit>(context).cancel();
                    }
                  }
              ),
            ],
          ),
        ),
      );
    });
  }
}
