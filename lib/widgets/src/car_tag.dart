import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/blocs.dart';
import '../../models/models.dart';
import '../../screens/add_edit/barrel.dart';

class CarTag extends StatelessWidget {
  const CarTag({Key key, this.car, this.text, this.color = Colors.blue})
      : super(key: key);

  final Car car;

  final String text;

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      child: InkWell(
        onTap: () {
          if (car != null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CarAddEditScreen(
                    car: car,
                    isEditing: false,
                    onSave: (name, odom, make, model, year, plate, vin) {
                      BlocProvider.of<CarsBloc>(context).add(UpdateCar(
                          car.copyWith(
                              name: name,
                              mileage: odom,
                              make: make,
                              model: model,
                              year: year,
                              plate: plate,
                              vin: vin)));
                    },
                  ),
                ));
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
          child: Text(text ?? car.name,
              // style: Theme.of(context).accentTextTheme.bodyText1,
              style: TextStyle(fontSize: 12)),
        ),
      ),
    );
  }
}
