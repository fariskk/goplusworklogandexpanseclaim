import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dots/classes/commonFunctions.dart';
import 'package:dots/models/worklog_attachment_model.dart';
import 'package:dots/services/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../classes/language_constants.dart';
import 'worklog_my_works_provider.dart';

class WorklogProvider extends ChangeNotifier {
  int? selectedStatus;
  String? assignTo;
  bool isStatusAssignTo = false;
  List<WorklogAttachments> attachments = [];
  bool isLodaing = false;
  submitWork(BuildContext context, String workId, String comments) async {
    try {
      isLodaing = true;
      rebuild();
      if (selectedStatus == null) {
        showToastMsg(context, translation(context).pleaseSelectStatus);
      } else if (isStatusAssignTo && assignTo == null) {
        showToastMsg(
          context,
          translation(context).pleaseSelectEmployee,
        );
      } else {
        List base64Attacments = [];
        for (var e in attachments) {
          base64Attacments.add({"name": e.name, "desc": e.base64});
        }
        Map data = {
          "EMP_code": box.read("empCode"),
          "M_FLAG": 7,
          "WORKID": workId,
          "STATUS": selectedStatus,
          "WORK_NOTS": comments,
          "ATTACHMENT_FILE": base64Attacments,
          "ASSIGNED_TO": assignTo?.split("-").first
        };
        FormData formData = FormData.fromMap({"data": jsonEncode(data)});
        var res = await worklogSubmitWork(formData);
        if (res.data["result"].runtimeType == bool) {
          if (res.data["result"]) {
            showToastMsg(context, translation(context).submittedSuccessfully,
                backgroundColor: Colors.green);
          } else {
            showToastMsg(context, translation(context).failedToSubmit);
          }
        }
      }
      Provider.of<WorklogMyWorksProvider>(context, listen: false).rebuild();
      isLodaing = false;
      rebuild();
    } catch (e) {
      isLodaing = false;
      rebuild();
    }
  }

  void rebuild() {
    notifyListeners();
  }

  void clear() {
    isStatusAssignTo = false;
    selectedStatus = null;
    assignTo = null;
    attachments = [];
  }
}
