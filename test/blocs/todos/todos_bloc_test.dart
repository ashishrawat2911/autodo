import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:equatable/equatable.dart';

import 'package:autodo/blocs/blocs.dart';
import 'package:autodo/repositories/repositories.dart';
import 'package:autodo/models/models.dart';

class MockDataRepository extends Mock
    with EquatableMixin
    implements DataRepository {}

class MockCarsBloc extends Mock implements CarsBloc {}

class MockRepeatsBloc extends Mock implements RepeatsBloc {}

class MockNotificationsBloc extends Mock implements NotificationsBloc {}

class MockWriteBatch extends Mock implements WriteBatchWrapper {}

class MockDbBloc extends Mock implements DatabaseBloc {}

void main() {
  group('TodosBloc', () {
    group('Null Assertions', () {
      test('Null Database Bloc', () {
        final carsBloc = MockCarsBloc();
        final notificationsBloc = MockNotificationsBloc();
        final repeatsBloc = MockRepeatsBloc();
        expect(
            () => TodosBloc(
                carsBloc: carsBloc,
                notificationsBloc: notificationsBloc,
                repeatsBloc: repeatsBloc,
                dbBloc: null),
            throwsAssertionError);
      });
      test('Null Cars Bloc', () {
        final dbBloc = MockDbBloc();
        final notificationsBloc = MockNotificationsBloc();
        final repeatsBloc = MockRepeatsBloc();
        expect(
            () => TodosBloc(
                carsBloc: null,
                notificationsBloc: notificationsBloc,
                repeatsBloc: repeatsBloc,
                dbBloc: dbBloc),
            throwsAssertionError);
      });
      test('Null NotificationsBloc', () {
        final carsBloc = MockCarsBloc();
        final dbBloc = MockDbBloc();
        final repeatsBloc = MockRepeatsBloc();
        expect(
            () => TodosBloc(
                carsBloc: carsBloc,
                notificationsBloc: null,
                repeatsBloc: repeatsBloc,
                dbBloc: dbBloc),
            throwsAssertionError);
      });
      test('Null RepeatsBloc', () {
        final carsBloc = MockCarsBloc();
        final notificationsBloc = MockNotificationsBloc();
        final dbBloc = MockDbBloc();
        expect(
            () => TodosBloc(
                carsBloc: carsBloc,
                notificationsBloc: notificationsBloc,
                repeatsBloc: null,
                dbBloc: dbBloc),
            throwsAssertionError);
      });
    });
    group('LoadTodos', () {
      blocTest(
        'Loaded',
        build: () {
          final carsBloc = MockCarsBloc();
          whenListen(
              carsBloc,
              Stream.fromIterable([
                CarsLoaded([Car()])
              ]));
          final dataRepository = MockDataRepository();
          when(dataRepository.todos()).thenAnswer((_) => Stream.fromIterable([
                [Todo()]
              ]));
          final notificationsBloc = MockNotificationsBloc();
          final repeatsBloc = MockRepeatsBloc();
          whenListen(
              repeatsBloc,
              Stream.fromIterable([
                RepeatsLoaded([Repeat()])
              ]));
          final dbBloc = MockDbBloc();
          when(dbBloc.state).thenAnswer((_) => DbLoaded(dataRepository));
          return TodosBloc(
              dbBloc: dbBloc,
              carsBloc: carsBloc,
              notificationsBloc: notificationsBloc,
              repeatsBloc: repeatsBloc);
        },
        act: (bloc) async => bloc.add(LoadTodos()),
        expect: [
          TodosLoading(),
          TodosLoaded([Todo()]),
        ],
      );
      blocTest(
        'NotLoaded',
        build: () {
          final carsBloc = MockCarsBloc();
          whenListen(
              carsBloc,
              Stream.fromIterable([
                CarsLoaded([Car()])
              ]));
          final dataRepository = MockDataRepository();
          when(dataRepository.todos())
              .thenAnswer((_) => Stream.fromIterable([null]));
          final notificationsBloc = MockNotificationsBloc();
          final repeatsBloc = MockRepeatsBloc();
          whenListen(
              repeatsBloc,
              Stream.fromIterable([
                RepeatsLoaded([Repeat()])
              ]));
          final dbBloc = MockDbBloc();
          when(dbBloc.state).thenAnswer((_) => DbLoaded(dataRepository));
          return TodosBloc(
              dbBloc: dbBloc,
              carsBloc: carsBloc,
              notificationsBloc: notificationsBloc,
              repeatsBloc: repeatsBloc);
        },
        act: (bloc) async => bloc.add(LoadTodos()),
        expect: [
          TodosLoading(),
          TodosLoaded([]),
        ],
      );
      blocTest(
        'Caught Exception',
        build: () {
          final carsBloc = MockCarsBloc();
          whenListen(
              carsBloc,
              Stream.fromIterable([
                CarsLoaded([Car()])
              ]));
          final dataRepository = MockDataRepository();
          when(dataRepository.todos()).thenThrow((_) => Exception());
          final notificationsBloc = MockNotificationsBloc();
          final repeatsBloc = MockRepeatsBloc();
          whenListen(
              repeatsBloc,
              Stream.fromIterable([
                RepeatsLoaded([Repeat()])
              ]));
          final dbBloc = MockDbBloc();
          when(dbBloc.state).thenAnswer((_) => DbLoaded(dataRepository));
          return TodosBloc(
              dbBloc: dbBloc,
              carsBloc: carsBloc,
              notificationsBloc: notificationsBloc,
              repeatsBloc: repeatsBloc);
        },
        act: (bloc) async => bloc.add(LoadTodos()),
        expect: [
          TodosLoading(),
          TodosNotLoaded(),
        ],
      );
    });
    final todo1 = Todo(id: '0', dueMileage: 0);
    final todo2 = Todo(id: '0', dueMileage: 1000);
    blocTest(
      'AddTodo',
      build: () {
        final carsBloc = MockCarsBloc();
        whenListen(
            carsBloc,
            Stream.fromIterable([
              CarsLoaded([Car()])
            ]));
        final dataRepository = MockDataRepository();
        when(dataRepository.todos()).thenAnswer((_) => Stream.fromIterable([
              [todo1]
            ]));
        final notificationsBloc = MockNotificationsBloc();
        final repeatsBloc = MockRepeatsBloc();
        whenListen(
            repeatsBloc,
            Stream.fromIterable([
              RepeatsLoaded([Repeat()])
            ]));
        final dbBloc = MockDbBloc();
        when(dbBloc.state).thenAnswer((_) => DbLoaded(dataRepository));
        return TodosBloc(
            dbBloc: dbBloc,
            carsBloc: carsBloc,
            notificationsBloc: notificationsBloc,
            repeatsBloc: repeatsBloc);
      },
      act: (bloc) async {
        bloc.add(LoadTodos());
        bloc.add(AddTodo(todo2));
      },
      expect: [
        TodosLoading(),
        TodosLoaded([todo1]),
        TodosLoaded([todo1, todo2]),
      ],
    );
    blocTest(
      'UpdateTodo',
      build: () {
        final carsBloc = MockCarsBloc();
        whenListen(
            carsBloc,
            Stream.fromIterable([
              CarsLoaded([Car()])
            ]));
        final dataRepository = MockDataRepository();
        when(dataRepository.todos()).thenAnswer((_) => Stream.fromIterable([
              [todo1]
            ]));
        final notificationsBloc = MockNotificationsBloc();
        final repeatsBloc = MockRepeatsBloc();
        whenListen(
            repeatsBloc,
            Stream.fromIterable([
              RepeatsLoaded([Repeat()])
            ]));
        final dbBloc = MockDbBloc();
        when(dbBloc.state).thenAnswer((_) => DbLoaded(dataRepository));
        return TodosBloc(
            dbBloc: dbBloc,
            carsBloc: carsBloc,
            notificationsBloc: notificationsBloc,
            repeatsBloc: repeatsBloc);
      },
      act: (bloc) async {
        bloc.add(LoadTodos());
        bloc.add(UpdateTodo(todo1.copyWith(dueMileage: 1000)));
      },
      expect: [
        TodosLoading(),
        TodosLoaded([todo1]),
        TodosLoaded([todo1.copyWith(dueMileage: 1000)]),
      ],
    );
    blocTest(
      'DeleteTodo',
      build: () {
        final carsBloc = MockCarsBloc();
        whenListen(
            carsBloc,
            Stream.fromIterable([
              CarsLoaded([Car()])
            ]));
        final dataRepository = MockDataRepository();
        when(dataRepository.todos()).thenAnswer((_) => Stream.fromIterable([
              [todo1]
            ]));
        final notificationsBloc = MockNotificationsBloc();
        final repeatsBloc = MockRepeatsBloc();
        whenListen(
            repeatsBloc,
            Stream.fromIterable([
              RepeatsLoaded([Repeat()])
            ]));
        final dbBloc = MockDbBloc();
        when(dbBloc.state).thenAnswer((_) => DbLoaded(dataRepository));
        return TodosBloc(
            dbBloc: dbBloc,
            carsBloc: carsBloc,
            notificationsBloc: notificationsBloc,
            repeatsBloc: repeatsBloc);
      },
      act: (bloc) async {
        bloc.add(LoadTodos());
        bloc.add(DeleteTodo(todo1));
      },
      expect: [
        TodosLoading(),
        TodosLoaded([todo1]),
        TodosLoaded([]),
      ],
    );
    blocTest(
      'ToggleAll',
      build: () {
        final carsBloc = MockCarsBloc();
        whenListen(
            carsBloc,
            Stream.fromIterable([
              CarsLoaded([Car()])
            ]));
        final dataRepository = MockDataRepository();
        when(dataRepository.todos()).thenAnswer((_) => Stream.fromIterable([
              [todo1.copyWith(completed: false)]
            ]));
        final notificationsBloc = MockNotificationsBloc();
        final repeatsBloc = MockRepeatsBloc();
        whenListen(
            repeatsBloc,
            Stream.fromIterable([
              RepeatsLoaded([Repeat()])
            ]));
        final dbBloc = MockDbBloc();
        when(dbBloc.state).thenAnswer((_) => DbLoaded(dataRepository));
        return TodosBloc(
            dbBloc: dbBloc,
            carsBloc: carsBloc,
            notificationsBloc: notificationsBloc,
            repeatsBloc: repeatsBloc);
      },
      act: (bloc) async {
        bloc.add(LoadTodos());
        bloc.add(ToggleAll());
      },
      expect: [
        TodosLoading(),
        TodosLoaded([todo1.copyWith(completed: false)]),
        TodosLoaded([todo1.copyWith(completed: true)]),
      ],
    );
    final car = Car(
        id: '0',
        name: 'test',
        mileage: 1000,
        distanceRate: 1.0,
        lastMileageUpdate: DateTime.fromMillisecondsSinceEpoch(0).toUtc());
    final todo3 = Todo(
        id: '0', carName: 'test', dueMileage: 2000, estimatedDueDate: true);
    blocTest(
      'UpdateDueDates',
      build: () {
        final carsBloc = MockCarsBloc();
        whenListen(
            carsBloc,
            Stream.fromIterable([
              CarsLoaded([car])
            ]));
        final dataRepository = MockDataRepository();
        when(dataRepository.todos()).thenAnswer((_) => Stream.fromIterable([
              [todo3]
            ]));
        final writeBatch = MockWriteBatch();
        when(writeBatch.updateData(todo3.id, dynamic))
            .thenAnswer((_) => ((_) => _));
        when(writeBatch.commit()).thenAnswer((_) async {});
        when(dataRepository.startTodoWriteBatch())
            .thenAnswer((_) => writeBatch);
        final notificationsBloc = MockNotificationsBloc();
        final repeatsBloc = MockRepeatsBloc();
        whenListen(
            repeatsBloc,
            Stream.fromIterable([
              RepeatsLoaded([Repeat()])
            ]));
        final dbBloc = MockDbBloc();
        when(dbBloc.state).thenAnswer((_) => DbLoaded(dataRepository));
        return TodosBloc(
            dbBloc: dbBloc,
            carsBloc: carsBloc,
            notificationsBloc: notificationsBloc,
            repeatsBloc: repeatsBloc);
      },
      act: (bloc) async {
        bloc.add(LoadTodos());
        // bloc.add(UpdateDueDates([car.copyWith(distanceRate: 2.0)]));
      },
      expect: [
        TodosLoading(),
        TodosLoaded([todo3]),
        TodosLoaded([
          todo3.copyWith(
              dueDate: DateTime.parse('1972-09-27 00:00:00.000Z'),
              estimatedDueDate: true)
        ]),
      ],
    );
    blocTest(
      'CompletedTodo',
      build: () {
        final carsBloc = MockCarsBloc();
        whenListen(
            carsBloc,
            Stream.fromIterable([
              CarsLoaded([car])
            ]));
        when(carsBloc.state).thenAnswer((_) => CarsLoaded([car]));

        final dataRepository = MockDataRepository();
        when(dataRepository.todos()).thenAnswer((_) => Stream.fromIterable([
              [todo3]
            ]));
        when(dataRepository.addNewTodo(todo3)).thenAnswer((_) async {});
        when(dataRepository.updateTodo(todo3)).thenAnswer((_) async {});
        final writeBatch = MockWriteBatch();
        when(writeBatch.updateData(todo3.id, dynamic))
            .thenAnswer((_) => ((_) => _));
        when(writeBatch.commit()).thenAnswer((_) async {});
        when(dataRepository.startTodoWriteBatch())
            .thenAnswer((_) => writeBatch);

        final notificationsBloc = MockNotificationsBloc();
        final repeatsBloc = MockRepeatsBloc();
        whenListen(
            repeatsBloc,
            Stream.fromIterable([
              RepeatsLoaded([Repeat()])
            ]));
        when(repeatsBloc.state).thenAnswer((_) => RepeatsLoaded([Repeat()]));
        final dbBloc = MockDbBloc();
        when(dbBloc.state).thenAnswer((_) => DbLoaded(dataRepository));
        return TodosBloc(
            dbBloc: dbBloc,
            carsBloc: carsBloc,
            notificationsBloc: notificationsBloc,
            repeatsBloc: repeatsBloc);
      },
      act: (bloc) async {
        bloc.add(LoadTodos());
        bloc.add(CompleteTodo(todo3, DateTime.fromMillisecondsSinceEpoch(0)));
      },
      expect: [
        TodosLoading(),
        TodosLoaded([todo3]),
        TodosLoaded([
          todo3.copyWith(
              completed: true,
              completedDate: DateTime.fromMillisecondsSinceEpoch(0))
        ]),
      ],
    );
    blocTest(
      'RepeatsRefresh',
      build: () {
        final carsBloc = MockCarsBloc();
        whenListen(
            carsBloc,
            Stream.fromIterable([
              CarsLoaded([Car()])
            ]));
        final dataRepository = MockDataRepository();
        when(dataRepository.todos()).thenAnswer((_) => Stream.fromIterable([
              [todo1]
            ]));
        final notificationsBloc = MockNotificationsBloc();
        final repeatsBloc = MockRepeatsBloc();
        whenListen(
            repeatsBloc,
            Stream.fromIterable([
              RepeatsLoaded([Repeat()])
            ]));
        final dbBloc = MockDbBloc();
        when(dbBloc.state).thenAnswer((_) => DbLoaded(dataRepository));
        return TodosBloc(
            dbBloc: dbBloc,
            carsBloc: carsBloc,
            notificationsBloc: notificationsBloc,
            repeatsBloc: repeatsBloc);
      },
      act: (bloc) async {
        bloc.add(LoadTodos());
        bloc.add(RepeatsRefresh([Repeat()]));
      },
      expect: [
        TodosLoading(),
        TodosLoaded([todo1]),
      ],
    );
  });
}
