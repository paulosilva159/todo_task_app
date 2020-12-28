import 'package:clean_flutter_app/common/subscription_holder.dart';
import 'package:clean_flutter_app/presentation/common/task_list_status.dart';
import 'package:clean_flutter_app/presentation/task_screen/task_screen_model.dart';
import 'package:domain/model/task.dart';
import 'package:domain/use_case/add_task_uc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

class TaskScreenBloc with SubscriptionHolder {
  TaskScreenBloc({
    @required this.useCases,
  }) : assert(useCases != null) {
    addTaskItemSubject(
      _onAddTaskItemSubject.stream,
    ).listen(_onNewStateSubject.add).addTo(subscriptions);

    updateTaskListStatusSubject(
      _onNewTaskListStatusSubject.stream,
    ).listen((taskListStatus) {
      if (taskListStatus is TaskListLoaded) {
        _onNewStateSubject.add(
          Done(listSize: taskListStatus.listSize),
        );
      }
    }).addTo(subscriptions);
  }

  Stream<TaskScreenState> addTaskItemSubject(Stream<Task> inputStream) =>
      inputStream.flatMap<TaskScreenState>(
        (task) => _addData(task: task, actionSink: _onNewActionSubject.sink),
      );

  Stream<TaskListStatus> updateTaskListStatusSubject(
          Stream<TaskListStatus> inputStream) =>
      inputStream;

  final TaskScreenUseCases useCases;

  final _onNewActionSubject = PublishSubject<TaskScreenAction>();
  final _onAddTaskItemSubject = PublishSubject<Task>();
  final _onNewStateSubject = BehaviorSubject<TaskScreenState>.seeded(
    Waiting(),
  );
  final _onNewTaskListStatusSubject = BehaviorSubject<TaskListStatus>.seeded(
    TaskListLoading(),
  );

  Sink<Task> get onAddTaskItem => _onAddTaskItemSubject.sink;
  Sink<TaskListStatus> get onNewTaskListStatus =>
      _onNewTaskListStatusSubject.sink;

  Stream<TaskScreenState> get onNewState => _onNewStateSubject.stream;
  Stream<TaskScreenAction> get onNewAction => _onNewActionSubject.stream;

  Stream<TaskScreenState> _addData({
    @required Task task,
    @required Sink<TaskScreenAction> actionSink,
  }) async* {
    const _actionType = TaskScreenActionType.addTask;

    try {
      await useCases.addTask(
        AddTaskUCParams(task: task),
      );

      actionSink.add(
        ShowSuccessTaskAction(type: _actionType),
      );
    } catch (error) {
      actionSink.add(
        ShowFailTaskAction(type: _actionType),
      );
    }
  }

  void dispose() {
    _onNewStateSubject.close();
    _onNewActionSubject.close();
    _onAddTaskItemSubject.close();
    _onNewTaskListStatusSubject.close();
    disposeSubscriptions();
  }
}

class TaskScreenUseCases {
  TaskScreenUseCases({
    @required this.addTaskUC,
  }) : assert(addTaskUC != null);

  final AddTaskUC addTaskUC;

  Future<void> addTask(AddTaskUCParams params) =>
      addTaskUC.getFuture(params: params);
}
