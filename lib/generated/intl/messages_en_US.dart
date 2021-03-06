// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en_US locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en_US';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "addTaskDialogTitle" : MessageLookupByLibrary.simpleMessage("Add task"),
    "addTaskFailSnackBarMessage" : MessageLookupByLibrary.simpleMessage("Fail to add task"),
    "addTaskSuccessSnackBarMessage" : MessageLookupByLibrary.simpleMessage("Successfully added task"),
    "cancelDialogActionTitle" : MessageLookupByLibrary.simpleMessage("Cancel"),
    "confirmDialogActionTitle" : MessageLookupByLibrary.simpleMessage("Yes"),
    "deleteTaskDialogMessage" : MessageLookupByLibrary.simpleMessage("Do you really want to delete this task?"),
    "deleteTaskDialogTitle" : MessageLookupByLibrary.simpleMessage("Delete task"),
    "emptyListIndicatorMessage" : MessageLookupByLibrary.simpleMessage("Empty list. Add new task"),
    "errorIndicatorMessage" : MessageLookupByLibrary.simpleMessage("Error"),
    "genericFailTaskSnackBarMessage" : MessageLookupByLibrary.simpleMessage("Something went wrong"),
    "genericSuccessTaskSnackBarMessage" : MessageLookupByLibrary.simpleMessage("Action was successful"),
    "genericUpsertTaskButtonLabel" : MessageLookupByLibrary.simpleMessage("Save"),
    "removeTaskFailSnackBarMessage" : MessageLookupByLibrary.simpleMessage("Failed to remove task"),
    "removeTaskSuccessSnackBarMessage" : MessageLookupByLibrary.simpleMessage("Successfully removed task"),
    "reorderTaskSuccessSnackBarMessage" : MessageLookupByLibrary.simpleMessage("Successfully reordered tasks"),
    "reorderTasksFailSnackBarMessage" : MessageLookupByLibrary.simpleMessage("Failed to reorder task"),
    "tryAgainButtonLabel" : MessageLookupByLibrary.simpleMessage("Try Again"),
    "updateTaskDialogTitle" : MessageLookupByLibrary.simpleMessage("Update task"),
    "updateTaskFailSnackBarMessage" : MessageLookupByLibrary.simpleMessage("Failed to update task"),
    "updateTaskSuccessSnackBarMessage" : MessageLookupByLibrary.simpleMessage("Successfully updated task")
  };
}
