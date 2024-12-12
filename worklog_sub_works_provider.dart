import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dots/models/worklog_attachment_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../classes/commonFunctions.dart';
import '../classes/language_constants.dart';
import '../services/services.dart';
import 'worklog_my_works_provider.dart';
import 'worklog_provider.dart';

class WorklogSubWorkProvider extends ChangeNotifier {
  bool isLoading = false;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  double? newProgress;
  String? totalTime;
  int expandedTileIndex = -1;
  String? workTitle;
  List<WorklogAttachments> subWorkSttachments = [];
  String status = "In Progress";
  void rebuild() {
    notifyListeners();
  }

  Future<bool> submitWorklog(
    String? workTitle,
    String workDescription,
    String notes,
    String blockersAndChallengers,
    String workId,
    BuildContext context,
  ) async {
    try {
      if (workTitle == null ||
          workDescription.isEmpty ||
          startTime == null ||
          endTime == null ||
          newProgress == null) {
        showToastMsg(context, translation(context).pleaseFillAllFields);
        return false;
      } else {
        isLoading = true;
        rebuild();
        List base64Attacments = [];
        for (var e in subWorkSttachments) {
          base64Attacments.add({"name": e.name, "desc": e.base64});
        }
        Map<String, dynamic> subWork = {
          "EMP_code": box.read("empCode"),
          "WORKID": workId,
          "M_FLAG": 10,
          "DATE": DateFormat('yyyy-MM-dd').format(DateTime.now()),
          "WORK_NOTS": notes,
          "WORK_TITLE": workTitle,
          "WORK_DESCRIPTION": workDescription,
          "START_TIME": "${startTime!.hour}:${startTime!.minute}:00",
          "END_TIME": "${endTime!.hour}:${endTime!.minute}:00",
          "TOTAL_TIME": totalTime,
          "WORK_PROGRESS": newProgress,
          "WORK_COMPLETED_FLAG": status == "Completed" ? true : null,
          "WORK_IN_PROGRESS_FLAG": status == "In Progress" ? true : null,
          "WORK_CHALLENGES": blockersAndChallengers,
          "ATTACHMENT_FILE": base64Attacments
        };
        FormData formData = FormData.fromMap({"data": jsonEncode(subWork)});
        var res = await worklogAddSubWork(formData);
        if (res.data["result"].runtimeType == bool) {
          if (res.data["result"]) {
            showToastMsg(context, translation(context).createdSuccessfully,
                backgroundColor: Colors.green);
          } else {
            showToastMsg(context, translation(context).failedToCreate);
            isLoading = false;
            rebuild();
            return false;
          }
        }
        Provider.of<WorklogProvider>(context, listen: false).rebuild();
        Provider.of<WorklogMyWorksProvider>(context, listen: false).rebuild();
        isLoading = false;
        rebuild();
        return true;
      }
    } catch (e) {
      isLoading = false;
      rebuild();
      showToastMsg(context, translation(context).wentWrong);
      return false;
    }
  }

  Future<bool> updateWorklog(
    String workId,
    int subWorkId,
    String? workTitle,
    String workDescription,
    String notes,
    String blockersAndChallengers,
    BuildContext context,
  ) async {
    try {
      if (workDescription.isEmpty ||
          startTime == null ||
          endTime == null ||
          workTitle == null) {
        showToastMsg(context, translation(context).pleaseFillAllFields);
        return false;
      } else {
        isLoading = true;
        rebuild();
        List base64Attacments = [];

        for (var e in subWorkSttachments) {
          base64Attacments.add({"name": e.name, "desc": e.base64});
        }
        print(totalTime.toString().replaceAll(".", ":"));
        Map<String, dynamic> subWork = {
          "EMP_code": box.read("empCode"),
          "WORKID": workId,
          "WORK_SUB_ID": subWorkId,
          "M_FLAG": 13,
          "DATE": DateFormat('yyyy-MM-dd').format(DateTime.now()),
          "WORK_NOTS": notes,
          "WORK_TITLE": workTitle,
          "WORK_DESCRIPTION": workDescription,
          "START_TIME": "${startTime!.hour}:${startTime!.minute}:00",
          "END_TIME": "${endTime!.hour}:${endTime!.minute}:00",
          "TOTAL_TIME": totalTime,
          "WORK_PROGRESS": newProgress,
          "WORK_COMPLETED_FLAG": status == "Completed" ? true : null,
          "WORK_IN_PROGRESS_FLAG": status == "In Progress" ? true : null,
          "WORK_CHALLENGES": blockersAndChallengers,
          "ATTACHMENT_FILE": base64Attacments
        };
        FormData formData = FormData.fromMap({"data": jsonEncode(subWork)});
        var res = await worklogEditSubWork(formData);
        if (res.data["result"].runtimeType == bool) {
          if (res.data["result"]) {
            showToastMsg(context, translation(context).updatedSuccessfully,
                backgroundColor: Colors.green);
          } else {
            showToastMsg(context, translation(context).failedToUpdate);
            isLoading = false;
            rebuild();
            return false;
          }
        }
        isLoading = false;
        rebuild();
        if (context.mounted) {
          Provider.of<WorklogProvider>(context, listen: false).rebuild();
          Provider.of<WorklogMyWorksProvider>(context, listen: false).rebuild();
        }
        return true;
      }
    } catch (e) {
      isLoading = false;
      rebuild();
      showToastMsg(context, translation(context).wentWrong);
      return false;
    }
  }

  void clear() {
    startTime = null;
    endTime = null;
    newProgress = null;
    totalTime = null;
    status = "In Progress";
    subWorkSttachments.clear();
    workTitle = null;
    expandedTileIndex = -1;
  }
}
