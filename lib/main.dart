import 'package:flutter/material.dart';
import 'package:flutter_app_chat/pages/home_page/home_page.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/fim_info/bloc/film_info_Bloc.dart';
import 'package:flutter_app_chat/pages/login_page/loginBloc/login_bloc.dart';
import 'package:flutter_app_chat/pages/login_page/login_page.dart';
import 'package:flutter_app_chat/pages/manager_page/bloc/hometab_bloc.dart';
import 'package:flutter_app_chat/pages/manager_page/home_manager_page.dart';
import 'package:flutter_app_chat/pages/manager_page/shift_manager_page/location_manager_page/location_edit_page.dart';
import 'package:flutter_app_chat/pages/manager_page/shift_manager_page/shift_manager_page.dart';
import 'package:flutter_app_chat/pages/manager_page/shift_manager_page/shift_page/shift_edit_page.dart';
import 'package:flutter_app_chat/pages/manager_page/showtime_manager_page/showtime_edit_manager_page.dart';
import 'package:flutter_app_chat/pages/register_page/createAccount_bloc/createAccount_bloc.dart';
import 'package:flutter_app_chat/pages/register_page/sendCodeBloc/sendcode_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'pages/register_page/createAccount_bloc/createAccount_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<LoginBloc>(
            create: (context) => LoginBloc(),
          ),
          BlocProvider<SendCodeBloc>(
            create: (context) => SendCodeBloc(),
          ),
          BlocProvider<CreateAccountBloc>(
            create: (context) => CreateAccountBloc(),
          ),
          BlocProvider<HomeTabBloc>(
            create: (context) => HomeTabBloc(),
          ),
          BlocProvider<FilmInfoBloc>(
            create: (context) => FilmInfoBloc(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: EasyLoading.init(),
          home: HomePage(),
          // home: ShiftEditPage(),
        ));
  }
}
