import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:autodo/screens/home/views/todos.dart';
import 'package:autodo/screens/home/widgets/todo_card.dart';
import 'package:autodo/blocs/blocs.dart';
import 'package:autodo/models/models.dart';
import 'package:autodo/widgets/widgets.dart';

class MockTodosBloc extends MockBloc<TodosEvent, TodosState>
    implements TodosBloc {}

class MockFilteredTodosBloc
    extends MockBloc<FilteredTodosLoaded, FilteredTodosState>
    implements FilteredTodosBloc {}

void main() {
  group('TodosScreen', () {
    TodosBloc todosBloc;
    FilteredTodosBloc filteredTodosBloc;

    setUp(() {
      todosBloc = MockTodosBloc();
      filteredTodosBloc = MockFilteredTodosBloc();
    });

    testWidgets('renders loading', (WidgetTester tester) async {
      when(todosBloc.state).thenAnswer((_) => TodosLoaded([]));
      when(filteredTodosBloc.state).thenAnswer((_) => FilteredTodosLoading());
      Key todosKey = Key('todos');
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<TodosBloc>.value(
              value: todosBloc,
            ),
            BlocProvider<FilteredTodosBloc>.value(
              value: filteredTodosBloc,
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: TodosScreen(key: todosKey),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byKey(todosKey), findsOneWidget);
      expect(find.byType(LoadingIndicator), findsOneWidget);
    });

    testWidgets('renders simple todo list', (WidgetTester tester) async {
      when(todosBloc.state).thenAnswer((_) => TodosLoaded([]));
      when(filteredTodosBloc.state).thenAnswer((_) => FilteredTodosLoaded(
          [Todo(name: '', completed: true)], VisibilityFilter.all));
      Key todosKey = Key('todos');
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<TodosBloc>.value(
              value: todosBloc,
            ),
            BlocProvider<FilteredTodosBloc>.value(
              value: filteredTodosBloc,
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: TodosScreen(key: todosKey),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(todosKey), findsOneWidget);
    });
    testWidgets('renders due date and due mileage',
        (WidgetTester tester) async {
      when(todosBloc.state).thenAnswer((_) => TodosLoaded([]));
      when(filteredTodosBloc.state).thenAnswer((_) => FilteredTodosLoaded([
            Todo(
                name: '',
                dueDate: DateTime.fromMillisecondsSinceEpoch(0),
                dueMileage: 0,
                completed: true)
          ], VisibilityFilter.all));
      Key todosKey = Key('todos');
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<TodosBloc>.value(
              value: todosBloc,
            ),
            BlocProvider<FilteredTodosBloc>.value(
              value: filteredTodosBloc,
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: TodosScreen(key: todosKey),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(todosKey), findsOneWidget);
    });
    testWidgets('check', (WidgetTester tester) async {
      final todo = Todo(
          name: '',
          dueDate: DateTime.fromMillisecondsSinceEpoch(0),
          dueMileage: 0,
          completed: false);
      when(filteredTodosBloc.state)
          .thenAnswer((_) => FilteredTodosLoaded([todo], VisibilityFilter.all));
      when(todosBloc.add(UpdateTodo(todo))).thenAnswer((_) => _);
      Key todosKey = Key('todos');
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<TodosBloc>.value(
              value: todosBloc,
            ),
            BlocProvider<FilteredTodosBloc>.value(
              value: filteredTodosBloc,
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: TodosScreen(key: todosKey),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      verify(todosBloc.add(UpdateTodo(todo.copyWith(completed: true))))
          .called(1);
    });
    testWidgets('dismiss', (WidgetTester tester) async {
      final todo = Todo(
          name: '',
          dueDate: DateTime.fromMillisecondsSinceEpoch(0),
          dueMileage: 0,
          completed: false);
      when(filteredTodosBloc.state)
          .thenAnswer((_) => FilteredTodosLoaded([todo], VisibilityFilter.all));
      when(todosBloc.add(DeleteTodo(todo))).thenAnswer((_) => null);
      Key todosKey = Key('todos');
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<TodosBloc>.value(
              value: todosBloc,
            ),
            BlocProvider<FilteredTodosBloc>.value(
              value: filteredTodosBloc,
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: TodosScreen(key: todosKey),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      verify(todosBloc.add(UpdateTodo(todo.copyWith(completed: true))))
          .called(1);
      await tester.fling(find.byType(TodoCard), Offset(-300, 0), 10000.0);
      await tester.pumpAndSettle();
      verify(todosBloc.add(DeleteTodo(todo))).called(1);
    });
    testWidgets('tap', (WidgetTester tester) async {
      final todo = Todo(
          name: '',
          dueDate: DateTime.fromMillisecondsSinceEpoch(0),
          dueMileage: 0,
          completed: false);
      when(filteredTodosBloc.state)
          .thenAnswer((_) => FilteredTodosLoaded([todo], VisibilityFilter.all));
      Key todosKey = Key('todos');
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<TodosBloc>.value(
              value: todosBloc,
            ),
            BlocProvider<FilteredTodosBloc>.value(
              value: filteredTodosBloc,
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: TodosScreen(key: todosKey),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TodoCard));
      await tester.pump();
      expect(find.byKey(todosKey), findsOneWidget);
    });
  });
}
