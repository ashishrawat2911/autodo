import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:json_intl/json_intl.dart';

import '../../../../blocs/blocs.dart';
import '../../../../generated/localization.dart';
import '../../../../integ_test_keys.dart';
import '../../../../theme.dart';
import 'form.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({Key key = IntegrationTestKeys.signupScreen})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
      decoration: scaffoldBackgroundGradient(),
      child: Scaffold(
        appBar: AppBar(
            title: Text(
          JsonIntl.of(context).get(IntlKeys.signUp),
          style: TextStyle(color: Colors.grey[300]),
        )),
        body: BlocBuilder<SignupBloc, SignupState>(
          builder: (context, state) => SignupForm(),
        ),
        backgroundColor: Colors.transparent,
      ));
}
