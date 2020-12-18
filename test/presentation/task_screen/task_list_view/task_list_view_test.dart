import 'package:clean_flutter_app/presentation/common/task_list_status.dart';
import 'package:clean_flutter_app/presentation/task_screen/task_list_view/widgets/task_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:domain/data_observables.dart';
import 'package:domain/exceptions.dart';
import 'package:domain/model/task.dart';

import 'package:clean_flutter_app/generated/l10n.dart';
import 'package:clean_flutter_app/presentation/common/indicator/empty_list_indicator.dart';
import 'package:clean_flutter_app/presentation/common/indicator/loading_indicator.dart';
import 'package:clean_flutter_app/presentation/common/try_again_button.dart';
import 'package:clean_flutter_app/presentation/task_screen/task_list_view/task_list_view.dart';
import 'package:clean_flutter_app/presentation/task_screen/task_list_view/task_list_view_bloc.dart';

class ActiveTaskStorageUpdateStreamWrapperSpy extends Mock
    implements ActiveTaskStorageUpdateStreamWrapper {}

class TaskListViewUseCasesSpy extends Mock implements TaskListViewUseCases {}

void main() {
  const _mockLocale = Locale('en_US');

  ActiveTaskStorageUpdateStreamWrapper activeTaskStorageUpdateStreamWrapper;
  TaskListViewUseCasesSpy useCases;
  TaskListViewBloc bloc;
  Widget screen;

  PostExpectation mockRequestCall() => when(useCases.getTasksList());

  void mockSuccess({List<Task> tasks = const <Task>[]}) =>
      mockRequestCall().thenAnswer((_) async => tasks);

  void mockFailure() => mockRequestCall().thenThrow(UseCaseException());

  void mockStreamWrapper() => when(activeTaskStorageUpdateStreamWrapper.value)
      .thenAnswer((_) => Stream.value(null));

  void mockNewTaskListStatus(TaskListStatus status) {}

  setUp(() {
    activeTaskStorageUpdateStreamWrapper =
        ActiveTaskStorageUpdateStreamWrapperSpy();
    useCases = TaskListViewUseCasesSpy();

    mockStreamWrapper();

    bloc = TaskListViewBloc(
      useCases: useCases,
      activeTaskStorageUpdateStreamWrapper:
          activeTaskStorageUpdateStreamWrapper,
    );

    screen = MaterialApp(
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      locale: _mockLocale,
      home: TaskListView(
        onNewTaskListStatus: mockNewTaskListStatus,
        bloc: bloc,
      ),
    );

    mockSuccess();
  });

  group('Should correctly load all screen states', () {
    testWidgets('Should start with Loading Indicator', (tester) async {
      await tester.pumpWidget(screen);
      await tester.pump();

      expect(find.byType(LoadingIndicator), findsOneWidget);
    });

    testWidgets('Should emit EmptyList Indicator if found list is empty',
        (tester) async {
      await tester.pumpWidget(screen);
      await tester.pump();

      bloc.getTaskItemListSubject(Stream.value(null));
      await tester.pump();

      expect(find.byType(EmptyListIndicator), findsOneWidget);
    });

    testWidgets('Should emit TaskList if found list is not empty',
        (tester) async {
      mockSuccess(tasks: <Task>[const Task(id: 0, title: 'title')]);

      await tester.pumpWidget(screen);
      await tester.pump();

      bloc.getTaskItemListSubject(Stream.value(null));
      await tester.pump();

      expect(find.byType(TaskList), findsOneWidget);
    });

    testWidgets('Should present TryAgainButton in case of Error',
        (tester) async {
      mockFailure();

      await tester.pumpWidget(screen);
      await tester.pump();

      bloc.getTaskItemListSubject(Stream.value(null));
      await tester.pump();

      expect(find.byType(TryAgainButton), findsOneWidget);
    });

    // testWidgets('Should not present FloatActionButton in case of Loading State',
    //     (tester) async {
    //   await tester.pumpWidget(screen);
    //   await tester.pump();
    //
    //   expect(find.byType(FloatingActionButton), findsNothing);
    // });
    //
    // testWidgets('Should not present FloatActionButton in case of Error State',
    //     (tester) async {
    //   mockFailure();
    //
    //   await tester.pumpWidget(screen);
    //   await tester.pump();
    //
    //   bloc.getTaskItemListSubject(Stream.value(null));
    //   await tester.pump();
    //
    //   expect(find.byType(FloatingActionButton), findsNothing);
    // });
  });
}
