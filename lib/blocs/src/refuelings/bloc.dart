import 'dart:async';

import 'package:autodo/blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';

import 'event.dart';
import 'state.dart';
import 'package:autodo/repositories/repositories.dart';
import 'package:autodo/models/models.dart';

class RefuelingsBloc extends Bloc<RefuelingsEvent, RefuelingsState> {
  static const int MAX_MPG = 0xffff;
  // don't know why anyone would enter this many, but preventing overflow here
  static const int MAX_NUM_REFUELINGS = 0xffff;

  StreamSubscription _dataSubscription, _repoSubscription;
  final DatabaseBloc _dbBloc;

  RefuelingsBloc({@required dbBloc})
      : assert(dbBloc != null),
        _dbBloc = dbBloc {
    _dataSubscription = _dbBloc.listen((state) {
      if (state is DbLoaded) {
        add(LoadRefuelings());
        _repoSubscription = repo?.refuelings()?.listen((event) {
          add(LoadRefuelings());
        });
      }
    });
  }

  @override
  RefuelingsState get initialState => RefuelingsLoading();

  DataRepository get repo => (_dbBloc.state is DbLoaded)
      ? (_dbBloc.state as DbLoaded).repository
      : null;

  @override
  Stream<RefuelingsState> mapEventToState(RefuelingsEvent event) async* {
    if (event is LoadRefuelings) {
      yield* _mapLoadRefuelingsToState();
    } else if (event is AddRefueling) {
      yield* _mapAddRefuelingToState(event);
    } else if (event is UpdateRefueling) {
      yield* _mapUpdateRefuelingToState(event);
    } else if (event is DeleteRefueling) {
      yield* _mapDeleteRefuelingToState(event);
    }
  }

  Future<Refueling> _findLatestRefueling(Refueling refueling) async {
    List<Refueling> refuelings = await repo
        .getCurrentRefuelings()
        .timeout(Duration(seconds: 10), onTimeout: () => []);

    int smallestDiff = MAX_MPG;
    Refueling out;
    for (var r in refuelings) {
      if (r.carName == refueling.carName) {
        var mileageDiff = refueling.mileage - r.mileage;
        if (mileageDiff <= 0) continue; // only looking for past refuelings
        if (mileageDiff < smallestDiff) {
          smallestDiff = mileageDiff;
          out = r;
        }
      }
    }
    return out;
  }

  Stream<RefuelingsState> _mapLoadRefuelingsToState() async* {
    try {
      List<Refueling> refuelings = await repo
          .getCurrentRefuelings()
          .timeout(Duration(seconds: 10), onTimeout: () => []);
      yield RefuelingsLoaded(refuelings);
    } catch (e) {
      print(e);
      yield RefuelingsNotLoaded();
    }
  }

  Stream<RefuelingsState> _mapAddRefuelingToState(AddRefueling event) async* {
    if (repo == null) {
      print('trying to add refueling to empty repo');
      return;
    }

    var item = event.refueling;
    var prev = await _findLatestRefueling(item);
    var dist = (prev == null) ? 0 : item.mileage - prev.mileage;
    Refueling out = event.refueling.copyWith(efficiency: dist / item.amount);

    // event.carsBloc.add(AddRefuelingInfo(item.car, item.mileage, item.date, item.efficiency, prev.date, dist));
    final List<Refueling> updatedRefuelings =
        List.from((state as RefuelingsLoaded).refuelings)..add(out);
    yield RefuelingsLoaded(updatedRefuelings);
    repo.addNewRefueling(out);
  }

  Stream<RefuelingsState> _mapUpdateRefuelingToState(
      UpdateRefueling event) async* {
    if (repo == null) {
      print('trying to update refueling with a null repository');
      return;
    }

    var prev = await _findLatestRefueling(event.refueling);
    var dist = (prev == null) ? 0 : event.refueling.mileage - prev.mileage;
    var efficiency = dist / event.refueling.amount;
    Refueling out = event.refueling.copyWith(efficiency: efficiency);

    final List<Refueling> updatedRefuelings = (state as RefuelingsLoaded)
        .refuelings
        .map((r) => r.id == out.id ? out : r)
        .toList();
    yield RefuelingsLoaded(updatedRefuelings);
    repo.updateRefueling(out);
  }

  Stream<RefuelingsState> _mapDeleteRefuelingToState(
      DeleteRefueling event) async* {
    if (state is RefuelingsLoaded && repo != null) {
      final updatedRefuelings = (state as RefuelingsLoaded)
          .refuelings
          .where((r) => r.id != event.refueling.id)
          .toList();
      yield RefuelingsLoaded(updatedRefuelings);
      repo.deleteRefueling(event.refueling);
    }
  }

  @override
  Future<void> close() {
    _dataSubscription?.cancel();
    _repoSubscription?.cancel();
    return super.close();
  }
}
