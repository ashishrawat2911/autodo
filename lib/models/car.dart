import 'package:autodo/items/distanceratepoint.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

import '../entities/barrel.dart';

@immutable
class Car extends Equatable {
  final String id, name;
  final int mileage, numRefuelings;
  final double averageEfficiency, distanceRate;
  final DateTime lastMileageUpdate;
  final List<DistanceRatePoint> distanceRateHistory;

  Car({ 
    this.id,
    this.name,
    this.mileage,
    this.numRefuelings,
    this.averageEfficiency,
    this.distanceRate,
    this.lastMileageUpdate,
    this.distanceRateHistory
  });

  Car copyWith({
    String id,
    String name,
    int mileage,
    int numRefuelings,
    double averageEfficiency,
    double distanceRate,
    DateTime lastMileageUpdate,
    List<DistanceRatePoint> distanceRateHistory
  }) {
    return Car(
      id: id ?? this.id,
      name: name ?? this.name,
      mileage: mileage ?? this.mileage,
      numRefuelings: numRefuelings ?? this.numRefuelings,
      averageEfficiency: averageEfficiency ?? this.averageEfficiency,
      distanceRate: distanceRate ?? this.distanceRate,
      lastMileageUpdate: lastMileageUpdate ?? this.lastMileageUpdate,
      distanceRateHistory: distanceRateHistory ?? this.distanceRateHistory
    );
  }

  @override 
  List<Object> get props => [id, name, mileage, numRefuelings, averageEfficiency, distanceRate, lastMileageUpdate, distanceRateHistory];

  @override
  String toString() {
    return 'Car { id: $id, name: $name, mileage: $mileage, numRefuelings: $numRefuelings, averageEfficiency: $averageEfficiency, distanceRate: $distanceRate, lastMileageUpdate: $lastMileageUpdate, distanceRateHistory: $distanceRateHistory }';
  }

  CarEntity toEntity() {
    return CarEntity(id, name, mileage, numRefuelings, averageEfficiency, distanceRate, lastMileageUpdate, distanceRateHistory);
  }

  static Car fromEntity(CarEntity entity) {
    return Car(
      id: entity.id,
      name: entity.name,
      mileage: entity.mileage,
      numRefuelings: entity.numRefuelings,
      averageEfficiency: entity.averageEfficiency,
      distanceRate: entity.distanceRate,
      lastMileageUpdate: entity.lastMileageUpdate,
      distanceRateHistory: entity.distanceRateHistory
    );
  }
}