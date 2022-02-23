import 'package:batt/test_cubit.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toggle_switch/toggle_switch.dart';

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

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key}) : super(key: key);

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
              TextFormField(
                      decoration: const InputDecoration(hintText: "url"),
                      maxLines: null,
                      keyboardType: TextInputType.url,
                      onChanged: (url) =>
                          context.read<TestCubit>().urlChanged(url),
              ),

              const SizedBox(
                height: 50,
              ),
              ToggleSwitch(
                initialLabelIndex: 0,
                totalSwitches: 2,
                labels: const ['Off', 'Start'],
                onToggle: (index) {
                  if (index == 1) {
                    BlocProvider.of<TestCubit>(context).validate();
                  } else {
                    BlocProvider.of<TestCubit>(context).cancel();
                  }
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}
