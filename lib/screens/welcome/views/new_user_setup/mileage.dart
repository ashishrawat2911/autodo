import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:autodo/util.dart';
import 'package:autodo/theme.dart';
import 'package:autodo/integ_test_keys.dart';
import 'package:autodo/blocs/blocs.dart';
import 'package:autodo/models/models.dart';
import 'base.dart';

class CarEntryField extends StatefulWidget {
  final Function next;
  final Function onNameSaved, onMileageSaved;
  final GlobalKey<FormState> formKey;

  CarEntryField(this.next, this.onNameSaved, this.onMileageSaved, this.formKey);

  @override
  State<CarEntryField> createState() =>
      CarEntryFieldState(next, onNameSaved, onMileageSaved, formKey);
}

class CarEntryFieldState extends State<CarEntryField> {
  bool firstWritten = false;
  FocusNode _nameNode, _mileageNode;
  Function nextNode;
  final Function onNameSaved, onMileageSaved;
  final GlobalKey<FormState> formKey;

  CarEntryFieldState(
      this.nextNode, this.onNameSaved, this.onMileageSaved, this.formKey);

  @override
  initState() {
    _nameNode = FocusNode();
    _mileageNode = FocusNode();
    super.initState();
  }

  @override
  dispose() {
    _nameNode.dispose();
    _mileageNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    nameField() => TextFormField(
          key: IntegrationTestKeys.mileageNameField,
          maxLines: 1,
          autofocus: true,
          decoration: defaultInputDecoration('', 'Car Name'),
          validator: (val) => requiredValidator(val),
          initialValue: '',
          onSaved: onNameSaved,
          focusNode: _nameNode,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => changeFocus(_nameNode, _mileageNode),
        );

    mileageField() => TextFormField(
          key: IntegrationTestKeys.mileageMileageField,
          maxLines: 1,
          autofocus: false,
          decoration: defaultInputDecoration('', 'Mileage'),
          validator: (val) => intValidator(val),
          initialValue: '',
          onSaved: onMileageSaved,
          focusNode: _mileageNode,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) async => await nextNode(),
        );

    return Container(
      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Form(
        key: formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: nameField(),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: mileageField(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MileageScreen extends StatefulWidget {
  final String mileageEntry;
  final mileageKey;
  final Function() onNext;

  MileageScreen(this.mileageEntry, this.mileageKey, this.onNext);

  @override
  MileageScreenState createState() => MileageScreenState(this.mileageEntry);
}

class MileageScreenState extends State<MileageScreen> {
  var mileageEntry;
  List<GlobalKey<FormState>> formKeys = [GlobalKey<FormState>()];
  List<Car> cars = [Car()];

  MileageScreenState(this.mileageEntry);

  _next() async {
    bool allValidated = true;
    formKeys.forEach((k) {
      if (k.currentState.validate()) {
        k.currentState.save();
      } else {
        allValidated = false;
      }
    });
    if (allValidated) {
      cars.forEach((c) {
        BlocProvider.of<CarsBloc>(context).add(AddCar(c));
      });
      // hide the keyboard
      FocusScope.of(context).requestFocus(FocusNode());
      await Future.delayed(Duration(milliseconds: 400));
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget headerText = Container(
      height: 110,
      child: Center(
          child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Text(
              'Before you get started,\n let\'s get some info about your car(s).',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w600,
                color: Colors.white.withAlpha(230),
              ),
            ),
          ),
          Text(
            'Tap "Add" to configure multiple cars.',
            style: Theme.of(context).primaryTextTheme.body1,
          ),
        ],
      )),
    );

    Widget card() {
      List<Widget> carFields = [];
      for (var i in Iterable.generate(cars.length)) {
        carFields.add(CarEntryField((i == cars.length - 1) ? _next : null,
            (val) {
          cars[i] = cars[i].copyWith(name: val);
        }, (val) => cars[i] = cars[i].copyWith(mileage: int.parse(val)),
            formKeys[i]));
      }

      return Container(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ...carFields,
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      FlatButton.icon(
                        padding: EdgeInsets.all(0),
                        icon: Icon(Icons.add),
                        label: Text('Add'),
                        onPressed: () => setState(() {
                          cars.add(Car());
                          formKeys.add(GlobalKey<FormState>());
                        }),
                      ),
                      FlatButton.icon(
                        padding: EdgeInsets.all(0),
                        icon: Icon(Icons.delete),
                        label: Text('Remove'),
                        onPressed: () {
                          if (cars.length < 2) return;
                          setState(() => cars.removeAt(cars.length - 1));
                        },
                      ),
                    ],
                  ),
                  FlatButton(
                    key: IntegrationTestKeys.mileageNextButton,
                    padding: EdgeInsets.all(0),
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    child: Text(
                      'Next',
                      style: Theme.of(context).primaryTextTheme.button,
                    ),
                    onPressed: () async => await _next(),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Form(
        key: widget.mileageKey,
        child: AccountSetupScreen(header: headerText, panel: card()));
  }
}
