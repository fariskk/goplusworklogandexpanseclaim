import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dots/models/worklog_attachment_model.dart';
import 'package:dots/services/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../classes/commonFunctions.dart';
import '../classes/language_constants.dart';
import 'worklog_common_provider.dart';

class WorklogMyWorksProvider extends ChangeNotifier {
  String? selectedWorkGroup;
  String? selectedWorType;
  List<DateTime?> dateRangeToSort = [];
  String selectedTypeForSort = "All";
  String selectedPriorityForSort = "All";
  String selectedStatusForSort = "All";
  bool isFilterOn = false;
  DateTime? startDate;
  DateTime? endDate;
  String selectedPriority = "Mid";
  String? assignedBy;
  bool isSearchEnabled = false;
  String searchKeyword = "";
  bool isLoading = false;
  String? client;
  double progressToUpdate = 0;
  List<WorklogAttachments> attachments = [];

  void rebuild() {
    notifyListeners();
  }

  getDropdownValues(BuildContext context) async {
    try {
      final provider =
          Provider.of<WorklogCommonProvider>(context, listen: false);
      provider.clear();
      var res = await worklogGetDropdownValuesResponse(context);

      if (res.statusCode == 200 && res.data["result"] != false) {
        List data = res.data["result"];

        List<String> workGroup = [];

        data[0].forEach((e) {
          workGroup.add("${e["id"]}-${e["work_group"]}");
        });
        List<String> employees = [];
        data[1].forEach((e) {
          employees.add("${e["slno"]}-${e["employee_name"]}");
        });
        List<String> clients = [];
        data[2].forEach((e) {
          clients.add("${e["id"]}-${e["client_name"]}");
        });
        List<String> workTypes = [];
        data[3].forEach((e) {
          workTypes.add("${e["ID"]}-${e["WORK_TYPE"]}");
        });

        provider.companyes = workGroup;
        provider.employees = employees;
        provider.clients = clients;
        provider.workTypes = workTypes;
      } else {
        showToastMsg(context, translation(context).wentWrong);
      }
    } catch (e) {
      showToastMsg(context, translation(context).wentWrong);
    }
  }

  Future<bool> submit(String taskName, String comments, String dependencies,
      BuildContext context) async {
    try {
      if (taskName.isEmpty ||
          startDate == null ||
          endDate == null ||
          assignedBy == null ||
          client == null ||
          selectedWorkGroup == null ||
          selectedWorType == null) {
        showToastMsg(context, translation(context).pleaseFillAllFields);
        return false;
      } else {
        isLoading = true;
        rebuild();
        List base64Attacments = [];
        for (var e in attachments) {
          base64Attacments.add({"name": e.name, "desc": e.base64});
        }
        print(selectedWorType);
        Map<String, dynamic> newWork = {
          "M_FLAG": 3,
          "EMPCODE": box.read("empCode"),
          "CLIENT": client!.split("-").first,
          "WORK_TYPE": int.parse(selectedWorType!.split("-").first),
          "WORKGROUP": selectedWorkGroup!.split("-").first,
          "TASK_NAME": taskName,
          "ASSIGNED_BY": assignedBy!.split("-").first,
          "START_DATE": DateFormat('yyyy-MM-dd').format(startDate!),
          "END_DATE": DateFormat('yyyy-MM-dd').format(endDate!),
          "PRIORITY_LOW": selectedPriority == "Low" ? true : null,
          "PRIORITY_MID": selectedPriority == "Mid" ? true : null,
          "PRIORITY_HIGH": selectedPriority == "High" ? true : null,
          "ATTACHMENT_FILE": base64Attacments,
          "WORK_DESCRIPTION": comments,
          "DEPENDENCIES": dependencies,
        };

        FormData formData = FormData.fromMap({"data": jsonEncode(newWork)});

        var res = await worklogCreateNewWork(formData);
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

  Future<bool> update(String taskName, String comments, String dependencies,
      BuildContext context, String reason, String workId) async {
    try {
      if (taskName.isEmpty ||
          startDate == null ||
          endDate == null ||
          assignedBy == null ||
          client == null ||
          selectedWorkGroup == null ||
          selectedWorType == null ||
          reason.isEmpty) {
        showToastMsg(context, translation(context).pleaseFillAllFields);
        return false;
      } else {
        isLoading = true;
        rebuild();
        List base64Attacments = [];
        for (var e in attachments) {
          base64Attacments.add({"name": e.name, "desc": e.base64});
        }
        int workTypeId =
            int.parse(Provider.of<WorklogCommonProvider>(context, listen: false)
                .workTypes
                .where((item) {
                  return item.contains(selectedWorType!);
                })
                .first
                .split("-")
                .first);
        Map<String, dynamic> newWork = {
          "M_FLAG": 6,
          "EMP_code": box.read("empCode"),
          "WORKID": workId,
          "WORK_TYPE": workTypeId,
          "WORKGROUP": selectedWorkGroup!.split("-").first,
          "ASSIGNED_BY": assignedBy!.split("-").first,
          "CLIENT": client!.split("-").first,
          "TASK_NAME": taskName,
          "START_DATE": DateFormat('yyyy-MM-dd').format(startDate!),
          "END_DATE": DateFormat('yyyy-MM-dd').format(endDate!),
          "DEPENDENCIES": dependencies,
          "PRIORITY_LOW": selectedPriority == "Low" ? true : null,
          "PRIORITY_MID": selectedPriority == "Mid" ? true : null,
          "PRIORITY_HIGH": selectedPriority == "High" ? true : null,
          "WORK_DESCRIPTION": comments,
          "ATTACHMENT_FILE": base64Attacments,
          "WORK_PROGRESS": progressToUpdate,
          "EDITED_REASON": reason
        };

        FormData formData = FormData.fromMap({"data": jsonEncode(newWork)});

        var res = await worklogUpdateWork(formData);
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
    selectedTypeForSort = "All";
    selectedPriorityForSort = "All";
    selectedStatusForSort = "All";
    startDate = null;
    endDate = null;
    selectedPriority = "Mid";
    assignedBy = null;
    client = null;
    selectedWorkGroup = null;
    selectedWorType = null;
    isSearchEnabled = false;
    searchKeyword = "";
    attachments.clear();
    progressToUpdate = 0;
  }
}
