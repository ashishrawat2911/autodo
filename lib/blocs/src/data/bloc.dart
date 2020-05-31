import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import '../../../generated/localization.dart';
import '../../../models/models.dart';
import '../../../repositories/repositories.dart';
import '../../../units/units.dart';
import '../../../util.dart';
import '../database/barrel.dart';
import '../notifications/barrel.dart';
import 'default_todos.dart';
import 'event.dart';
import 'state.dart';

class DataBloc extends Bloc<DataEvent, DataState> {
  DataBloc({@required this.dbBloc, @required this.notificationsBloc}):
      assert(dbBloc != null),
      assert(notificationsBloc != null) {
    _dbSubscription = dbBloc.listen((state) {
      if (state is DbLoaded) {
        add(LoadData());
      }
    });
  }

  final DatabaseBloc dbBloc;

  final NotificationsBloc notificationsBloc;

  StreamSubscription _dbSubscription;

  @override
  DataState get initialState => DataLoading();

  DataRepository get repo =>
      (dbBloc.state is DbLoaded) ? (dbBloc.state as DbLoaded).dataRepo : null;

  @override
  Stream<DataState> mapEventToState(DataEvent event) async* {
    if (event is LoadData) {
      yield* _mapLoadDataToState(event);
    } else if (event is TranslateDefaults) {
      yield* _mapTranslateDefaultsToState(event);
    }

    // If we're operating on existing data then ensure that everything is loaded
    // first.
    if (!(state is DataLoaded) || repo == null) {
      print('Cannot update uninitialized DataBloc');
      return;
    }

    if (event is AddTodo) {
      yield* _mapAddTodoToState(event);
    } else if (event is UpdateTodo) {
      yield* _mapUpdateTodoToState(event);
    } else if (event is DeleteTodo) {
      yield* _mapDeleteTodoToState(event);
    } else if (event is AddRefueling) {
      yield* _mapAddRefuelingToState(event);
    } else if (event is UpdateRefueling) {
      yield* _mapUpdateRefuelingToState(event);
    } else if (event is DeleteRefueling) {
      yield* _mapDeleteRefuelingToState(event);
    } else if (event is AddCar) {
      yield* _mapAddCarToState(event);
    } else if (event is UpdateCar) {
      yield* _mapUpdateCarToState(event);
    } else if (event is DeleteCar) {
      yield* _mapDeleteCarToState(event);
    }
  }

  /// Calculates the Due Date for a ToDo based on the given car's distanceRate.
  static DateTime calcDueDate(Car car, double dueMileage) {
    if (car.distanceRate == 0 || car.distanceRate == null) {
      return null;
    }

    final distanceToTodo = dueMileage - car.odomSnapshot.mileage;
    var daysToTodo = 0; // TODO: Needs proper fix
    try {
      daysToTodo = (distanceToTodo / car.distanceRate).round();
    } catch (e) {
      print(e);
    }
    final timeToTodo = Duration(days: daysToTodo);
    return roundToDay(car.odomSnapshot.date.toUtc()).add(timeToTodo).toLocal();
  }

  /// Returns a TodoDueState enum value describing the proximity to the ToDo's deadline.
  static TodoDueState calcDueState(Car car, Todo todo) {
    if (todo.completed ?? false) {
      return TodoDueState.COMPLETE;
    } else if (car.odomSnapshot.mileage - todo.dueMileage > 0) {
      return TodoDueState.PAST_DUE;
    } else if (DateTime.now().isAfter(todo.dueDate)) {
      return TodoDueState.PAST_DUE;
    }

    final distanceRate =
        car.distanceRate ?? DEFAULT_DUE_SOON_CUTOFF_DISTANCE_RATE;
    final daysUntilDueMileage =
        ((todo.dueMileage - car.odomSnapshot.mileage) * distanceRate).round();
    // Truncating rather than rounding here, that should hopefully be fine though
    final daysUntilDueDate = todo.dueDate.difference(DateTime.now()).inDays;

    if ((daysUntilDueMileage < DUE_SOON_CUTOFF_TIME) ||
        daysUntilDueDate < DUE_SOON_CUTOFF_TIME) {
      return TodoDueState.DUE_SOON;
    }
    return TodoDueState.UPCOMING;
  }

  /// Updates the cars and todos based on a change to the odom snapshots.
  Stream<DataState> _reactToOdomSnapshotChange(OdomSnapshot snapshot) async* {
    var car =
        (state as DataLoaded).cars.firstWhere((c) => c.id == snapshot.car);
    if (snapshot.mileage > car.odomSnapshot.mileage) {
      // This refueling is newer than the latest for the car, update the car's mileage
      car = car.copyWith(odomSnapshot: snapshot);
      final updatedCar = await repo.updateCar(car);
      final updatedCarList = List.from((state as DataLoaded).cars)
        ..map((c) => c.id == updatedCar.id ? updatedCar : c);
      yield (state as DataLoaded).copyWith(cars: updatedCarList);

      // update the car's efficiency and distance rate
      // individual efficiency values should probably only be handled in the stats bloc

      // Update the todos' dueState values based on the car's new mileage
      final updatedTodos = (state as DataLoaded).todos.map((t) =>
          (t.carId == car.id)
              ? t.copyWith(dueState: _calcDueState(updatedCar, t))
              : t);
      for (var t in updatedTodos) {
        await repo.updateTodo(t);
      }

      // update the todos' estimated due dates based on the car's new distanceRate
      yield (state as DataLoaded).copyWith(todos: updatedTodos);
    }
  }

  Stream<DataState> _mapLoadDataToState(LoadData event) async* {
    try {
      final cars = await repo
          .getCurrentCars()
          .timeout(Duration(seconds: 1), onTimeout: () => []);
      final refuelings = await repo
          .getCurrentRefuelings()
          .timeout(Duration(seconds: 1), onTimeout: () => []);
      final todos = await repo
          .getCurrentTodos()
          .timeout(Duration(seconds: 1), onTimeout: () => []);

      if (cars != null && refuelings != null && todos != null) {
        yield DataLoaded(cars: cars, refuelings: refuelings, todos: todos);
      } else {
        yield DataLoaded();
      }
    } catch (e) {
      print(e);
      yield DataNotLoaded();
    }
  }

  bool _shouldEstimateDueDate(t) =>
      (t.estimatedDueDate ?? true) &&
      !(t.completed ?? false);

  Stream<DataState> _mapAddTodoToState(AddTodo event) async* {
    final todo = event.todo;
    final car = (state as DataLoaded).cars.firstWhere((c) => c.id == todo.carId);

    if (_shouldEstimateDueDate(todo)) {
      // set an estimated due date for the todo
    }

    if (todo.completed ?? false) {
      // handle the odomSnapshot
    }

    // Schedule a notification
    notificationsBloc.add(ScheduleNotification(
        date: todo.dueDate,
        title: '${IntlKeys.todoDueSoon}: ${todo.name}', // TODO: Translate this
        body: ''));

    final newTodo = await repo.addNewTodo(event.todo);
    final updatedTodos = List.from((state as DataLoaded).todos)..add(newTodo);
    yield (state as DataLoaded).copyWith(todos: updatedTodos);
  }

  Stream<DataState> _mapUpdateTodoToState(UpdateTodo event) async* {
    final todo = event.todo;
    final car = (state as DataLoaded).cars.firstWhere((c) => c.id == todo.carId);

    if (_shouldEstimateDueDate(todo)) {
      // set an estimated due date for the todo
    }

    if (todo.completed ?? false) {
      // handle the odomSnapshot
    }

    notificationsBloc.add(ReScheduleNotification(
        id: out.notificationID,
        date: out.dueDate,
        title: '${IntlKeys.todoDueSoon}: ${out.name}', // TODO: Translate this
        body: ''));

    final updatedTodo = await repo.updateTodo(event.todo);
    final updatedTodos = List.from((state as DataLoaded).todos)
      ..map((t) => (t.id == updatedTodo.id) ? updatedTodo : t);
    yield (state as DataLoaded).copyWith(todos: updatedTodos);
  }

  Stream<DataState> _mapDeleteTodoToState(DeleteTodo event) async* {
    await repo.deleteTodo(event.todo);
    final updatedTodos = List.from((state as DataLoaded).todos)
      ..remove(event.todo);
    yield (state as DataLoaded).copyWith(todos: updatedTodos);
  }

  Stream<DataState> _mapCompleteTodoToState(CompleteTodo event) async* {
    // update the todo, call _reactTo
    // create a new todo if needed
  }

  Stream<DataState> _mapAddRefuelingToState(AddRefueling event) async* {
    final refueling = event.refueling;

    // Write Odom Snapshot to Database
    final newOdomSnapshot =
        await repo.addNewOdomSnapshot(refueling.odomSnapshot);
    final refuelingWithOdomSnapshotId =
        refueling.copyWith(odomSnapshot: newOdomSnapshot);
    yield* _reactToOdomSnapshotChange(newOdomSnapshot);

    // Write the Refueling to Database
    final newRefueling =
        await repo.addNewRefueling(refuelingWithOdomSnapshotId);
    final updatedRefuelings = List.from((state as DataLoaded).refuelings)
      ..add(newRefueling);
    yield (state as DataLoaded).copyWith(refuelings: updatedRefuelings);
  }

  Stream<DataState> _mapUpdateRefuelingToState(UpdateRefueling event) async* {
    var updatedRefueling = event.refueling;
    final curRefueling = (state as DataLoaded).refuelings.firstWhere((r) => r.id == updatedRefueling.id);

    if (updatedRefueling.odomSnapshot != curRefueling.odomSnapshot) {
      // OdomSnapshot changed, write it to db and update related models
      final updatedOdomSnapshot = await repo.updateOdomSnapshot(updatedRefueling.odomSnapshot);
      updatedRefueling = updatedRefueling.copyWith(odomSnapshot: updatedOdomSnapshot);
      yield* _reactToOdomSnapshotChange(updatedOdomSnapshot);
    }

    // Write Refueling to Database
    updatedRefueling = await repo.updateRefueling(updatedRefueling);
    final updatedRefuelings = List.from((state as DataLoaded).refuelings)
      ..map((r) => (r.id == updatedRefueling.id) ? updatedRefueling : r);
    yield (state as DataLoaded).copyWith(refuelings: updatedRefuelings);
  }

  Stream<DataState> _mapDeleteRefuelingToState(DeleteRefueling event) async* {
    // Check if this refueling is the latest for the car and update the car/todos if so
    // TODO: see what the delete cascading will look like on the server
    await repo.deleteRefueling(event.refueling);
    final updatedRefuelings = List.from((state as DataLoaded).refuelings)
      ..remove(event.refueling);
    yield (state as DataLoaded).copyWith(refuelings: updatedRefuelings);
  }

  Stream<DataState> _mapAddCarToState(AddCar event) async* {
    // add default todos
    // handle new odom snapshot

    final newCar = await repo.addNewCar(event.car);
    final updatedCars = List.from((state as DataLoaded).cars)..add(newCar);
    yield (state as DataLoaded).copyWith(cars: updatedCars);
  }

  Stream<DataState> _mapUpdateCarToState(UpdateCar event) async* {
    // handle the odom snapshot if that gets updated
    // assuming that won't happen since it doesn't make much sense from a UI
    // perspective but it would be easy to forget about here if not taken care
    // of by default
    final updatedCar = await repo.updateCar(event.car);
    final updatedCars = List.from((state as DataLoaded).cars)
      ..map((c) => (c.id == updatedCar.id) ? updatedCar : c);
    yield (state as DataLoaded).copyWith(cars: updatedCars);
  }

  Stream<DataState> _mapDeleteCarToState(DeleteCar event) async* {
    // TODO: see if the todos/refuelings/odomsnapshots for the car will be deleted by server here
    await repo.deleteCar(event.car);
    final updatedCars = List.from((state as DataLoaded).cars)
      ..remove(event.car);
    yield (state as DataLoaded).copyWith(cars: updatedCars);
  }

  Stream<DataState> _mapTranslateDefaultsToState(
      TranslateDefaults event) async* {
    List<Todo> translated;

    // Get the correct set of defaults so the intervals are nice, round numbers
    if (event.distanceUnit == DistanceUnit.imperial) {
      translated = List<Todo>.from(defaultsImperial);
    } else if (event.distanceUnit == DistanceUnit.metric) {
      translated = List<Todo>.from(defaultsMetric);
    }

    // Translate the names
    translated = translated
        .map((t) => t.copyWith(name: event.jsonIntl.get(t.name)))
        .toList();
    if (state is DataLoading) {
      yield DataLoading(defaultTodos: translated);
    } else if (state is DataLoaded) {
      yield (state as DataLoaded).copyWith(defaultTodos: translated);
    }
  }

  @override
  void onTransition(dynamic transition) {
    print('*****************************************');
    print('**   onTransition $transition');
    print('*****************************************');
  }

  @override
  Future<void> close() async {
    await _dbSubscription?.cancel();
    return super.close();
  }
}
