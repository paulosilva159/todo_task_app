import 'package:clean_flutter_app/generated/l10n.dart';
import 'package:clean_flutter_app/presentation/common/action_stream_listener.dart';
import 'package:clean_flutter_app/presentation/common/async_snapshot_response_view.dart';
import 'package:clean_flutter_app/presentation/common/dialogs/simple_dialogs/task_action_form_dialog.dart';
import 'package:clean_flutter_app/presentation/common/indicator/empty_list_indicator.dart';
import 'package:clean_flutter_app/presentation/common/indicator/error_indicator.dart';
import 'package:clean_flutter_app/presentation/common/indicator/loading_indicator.dart';
import 'package:clean_flutter_app/presentation/common/snackbar/task_action_message_snackbar.dart';
import 'package:clean_flutter_app/presentation/common/task_list_status.dart';
import 'package:clean_flutter_app/presentation/task_screen/vertical_task_list_view/vertical_task_list_view_bloc.dart';
import 'package:clean_flutter_app/presentation/task_screen/vertical_task_list_view/vertical_task_list_view_model.dart';
import 'package:domain/data_observables.dart';
import 'package:domain/data_repository/task_repository.dart';
import 'package:domain/exceptions.dart';
import 'package:domain/model/task.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef TaskListStatusUpdateCallback = void Function(TaskListStatus);

class VerticalTaskListView extends StatelessWidget {
  const VerticalTaskListView({
    @required this.bloc,
    @required this.onNewTaskListStatus,
  })  : assert(bloc != null),
        assert(onNewTaskListStatus != null);

  final VerticalTaskListViewBloc bloc;
  final TaskListStatusUpdateCallback onNewTaskListStatus;

  static Widget create(
          {@required TaskListStatusUpdateCallback onNewTaskListStatus}) =>
      ProxyProvider2<ActiveTaskStorageUpdateStreamWrapper,
          VerticalTaskListViewUseCases, VerticalTaskListViewBloc>(
        update: (
          context,
          activeTaskStorageUpdateStreamWrapper,
          taskListViewUseCases,
          taskListViewBloc,
        ) =>
            taskListViewBloc ??
            VerticalTaskListViewBloc(
              activeTaskStorageUpdateStreamWrapper:
                  activeTaskStorageUpdateStreamWrapper,
              useCases: taskListViewUseCases,
            ),
        dispose: (context, bloc) => bloc.dispose(),
        child: Consumer<VerticalTaskListViewBloc>(
          builder: (context, bloc, child) => VerticalTaskListView(
            bloc: bloc,
            onNewTaskListStatus: onNewTaskListStatus,
          ),
        ),
      );

  String _snackBarMessage(
    BuildContext context, {
    @required VerticalTaskListAction action,
  }) {
    if (action is ShowFailTaskAction) {
      switch (action.type) {
        case VerticalTaskListActionType.updateTask:
          return S.of(context).updateTaskFailSnackBarMessage;
        case VerticalTaskListActionType.removeTask:
          return S.of(context).removeTaskFailSnackBarMessage;
        case VerticalTaskListActionType.reorderTask:
          return S.of(context).reorderTasksFailSnackBarMessage;
      }
    } else {
      switch (action.type) {
        case VerticalTaskListActionType.updateTask:
          return S.of(context).updateTaskSuccessSnackBarMessage;
        case VerticalTaskListActionType.removeTask:
          return S.of(context).removeTaskSuccessSnackBarMessage;
        case VerticalTaskListActionType.reorderTask:
          return S.of(context).reorderTaskSuccessSnackBarMessage;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) =>
      ActionStreamListener<VerticalTaskListAction>(
        actionStream: bloc.onNewAction,
        onReceived: (action) {
          final _message = _snackBarMessage(
            context,
            action: action,
          );

          if (action is ShowFailTaskAction) {
            showFailTask(context, message: _message);
          } else {
            showSuccessTask(context, message: _message);
          }
        },
        child: StreamBuilder<Object>(
          stream: bloc.onNewState,
          builder: (context, snapshot) =>
              AsyncSnapshotResponseView<Loading, Error, Success>(
            loadingWidgetBuilder: (context, loading) => LoadingIndicator(),
            errorWidgetBuilder: (context, error) => ErrorIndicator(
              error: error,
              onTryAgainTap: () => bloc.onTryAgain.add(null),
            ),
            successWidgetBuilder: (context, success) {
              onNewTaskListStatus(
                TaskListLoaded(
                  listSize: success.listSize,
                ),
              );

              if (success is Listing) {
                return _VerticalTaskList(
                  onRemoveTask: bloc.onRemoveTask.add,
                  onUpdateTask: bloc.onUpdateTask.add,
                  onReorderTasks: (oldId, newId) {
                    bloc.onReorderTask.add(
                      ReorderableTaskIds(oldId: oldId, newId: newId),
                    );
                  },
                  tasks: success.tasks,
                );
              } else if (success is Empty) {
                return EmptyListIndicator();
              }

              throw UnkownStateException();
            },
            snapshot: snapshot,
          ),
        ),
      );
}

// TODO(paulosilva159): Refazer ReorderableListView

class _VerticalTaskList extends StatelessWidget {
  const _VerticalTaskList({
    @required this.onRemoveTask,
    @required this.onUpdateTask,
    @required this.onReorderTasks,
    @required this.tasks,
  })  : assert(tasks != null),
        assert(onUpdateTask != null),
        assert(onRemoveTask != null),
        assert(onReorderTasks != null);

  final void Function(Task) onRemoveTask;
  final void Function(Task) onUpdateTask;
  final void Function(int, int) onReorderTasks;
  final List<Task> tasks;

  @override
  Widget build(BuildContext context) => Material(
        child: ReorderableListView(
          key: const ValueKey<TaskListOrientation>(
            TaskListOrientation.vertical,
          ),
          scrollDirection: Axis.vertical,
          onReorder: (oldId, newId) {
            onReorderTasks(
              oldId + 1,
              newId > oldId ? newId : newId + 1,
            );
          },
          children: tasks
              .map((task) => _VerticalTaskListItem(
                    key: ValueKey<int>(task.id),
                    onRemoveTask: onRemoveTask,
                    onUpdateTask: onUpdateTask,
                    task: task,
                  ))
              .toList(),
        ),
      );
}

class _VerticalTaskListItem extends StatelessWidget {
  const _VerticalTaskListItem({
    @required this.task,
    @required this.onRemoveTask,
    @required this.onUpdateTask,
    Key key,
  })  : assert(task != null),
        assert(onRemoveTask != null),
        assert(onUpdateTask != null),
        super(key: key);

  final Task task;
  final void Function(Task) onRemoveTask;
  final void Function(Task) onUpdateTask;

  RoundedRectangleBorder _listTileCardShape() => const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      );

  @override
  Widget build(BuildContext context) => Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        shape: _listTileCardShape(),
        color: Colors.amber,
        child: ListTile(
          onTap: () {
            print('t');
          },
          shape: _listTileCardShape(),
          title: Text(task.title),
          trailing: Container(
            width: 75,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: IconButton(
                    icon: const Icon(Icons.edit_rounded),
                    onPressed: () {
                      showUpsertTaskFormDialog(
                        context,
                        formDialogTitle: S.of(context).updateTaskDialogTitle,
                        onUpsertTask: onUpdateTask,
                        upsertingTask: task,
                      );
                    },
                  ),
                ),
                Expanded(
                  child: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => onRemoveTask(task),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
