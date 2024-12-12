import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:dots/provider/expanse_claim_provider.dart';
import 'package:dots/provider/worklog_my_works_provider.dart';
import 'package:dots/services/api_handler.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../classes/commonFunctions.dart';
import '../classes/language_constants.dart';
import '../provider/worklog_common_provider.dart';
import '../provider/worklog_sub_works_provider.dart';

final box = GetStorage();

String getCompanyURL() {
  String initialServiceUrl = box.read('serviceApi');
  return initialServiceUrl;
}

String getAdminToken() {
  String token = box.read('token');
  return token;
}

DateTime dateTime = DateTime.now();
String time = DateFormat('yyyy-MM-dd HHmmss').format(dateTime);

Future<String> addShift(
    String shiftCode,
    String shiftDescription,
    String startTime,
    String endTime,
    String workingHour,
    String? lateStart,
    String? earlyEnd,
    List selectedDays,
    bool openShift,
    bool nightShift,
    bool otShift) async {
  try {
    bool hasConnection = await InternetConnectionChecker().hasConnection;
    if (!hasConnection) {
      showToast();
      throw Exception("No internet connection");
    }

    int adminId = box.read('userSlno');

    final Map<String, dynamic> authData = {
      "user": adminId,
      "CREATED_BY": adminId,
      "shiftCode": shiftCode,
      "shiftDescription": shiftDescription,
      "shiftStartTime": startTime,
      "shiftEndTime": endTime,
      "shiftHRS": workingHour,
      "lateStart": lateStart,
      "earlyEnd": earlyEnd,
      "weeklyOff": selectedDays,
      "openShift": openShift,
      "nightShift": nightShift,
      "otShift": otShift,
      "company_id": box.read('clientId')
    };

    Dio dio = Dio();
    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Authorization'] = getAdminToken();
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(seconds: 5);
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        logPrint: print, // specify log function (optional)
        retries: 5, // retry count (optional)
        retryDelays: const [
          // set delays between retries (optional)
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
          Duration(seconds: 4),
        ],
      ),
    );

    final response = await dio.post(
      "${getCompanyURL()}dndApi/Get_shift_RecordInsert_Mobile",
      data: authData,
    );

    if (response.statusCode == 200) {
      return jsonEncode(response.data)
          .toString(); // Convert the response to a string
    } else {
      throw Exception("Request failed with status: ${response.statusCode}");
    }
  } catch (e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception("Connection Timeout Exception");
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Receive Timeout Exception");
      }
      throw Exception("Dio Error: ${e.message}");
    } else {
      throw Exception("An error occurred: $e");
    }
  }
}

void checkShiftCode(
    String shiftCode, Function resultTrue, Function resultFalse) async {
  try {
    bool hasConnection = await InternetConnectionChecker().hasConnection;
    if (!hasConnection) {
      showToast();
      throw Exception("No internet connection");
    }

    int? userId = box.read('userSlno');
    final Map<String, dynamic> authData = {
      "user": userId,
      "shiftCode": shiftCode,
      "company_id": box.read('clientId')
    };
    Dio dio = Dio();
    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Authorization'] = getAdminToken();
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(seconds: 5);
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        logPrint: print, // specify log function (optional)
        retries: 5, // retry count (optional)
        retryDelays: const [
          // set delays between retries (optional)
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
          Duration(seconds: 4),
        ],
      ),
    );

    final response = await dio.post(
      "${getCompanyURL()}dndApi/Get_shift_RecordInsert_Mobile",
      data: authData,
    );

    if (response.data['result'][0][0]["RESULT"] == true) {
      resultFalse();
    } else {
      resultTrue();
    }
  } catch (e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception("Connection Timeout Exception");
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Receive Timeout Exception");
      }
      throw Exception("Dio Error: ${e.message}");
    } else {
      throw Exception("An error occurred: $e");
    }
  }
}

saveAddHoliday(int? holidayFlag, int? addHolidayFlag, String? holidayCode,
    String? fromDate, String? toDate, String? comCode, String? comDesc) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userSlno = prefs.getInt('logId');

  try {
    bool hasConnection = await InternetConnectionChecker().hasConnection;
    if (!hasConnection) {
      showToast();
      throw Exception("No internet connection");
    }
    final Map<String, dynamic> authData = {
      "userSlno": userSlno,
      "holidayFlag": holidayFlag,
      "addholidayFlag": addHolidayFlag,
      "holidayCode": holidayCode,
      "fromDate": fromDate,
      "toDate": toDate,
      "comcode": comCode,
      "comdesc": comDesc,
      "company_id": box.read('clientId')
    };
    Dio dio = Dio();
    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Authorization'] = getAdminToken();
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(seconds: 5);
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        logPrint: print, // specify log function (optional)
        retries: 5, // retry count (optional)
        retryDelays: const [
          // set delays between retries (optional)
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
          Duration(seconds: 4),
        ],
      ),
    );

    final response = await dio.post(
      "${getCompanyURL()}dndApi/Get_holiday_RecordInsert_Mobile",
      data: authData,
    );

    if (response.statusCode == 200) {
      return jsonEncode(response.data)
          .toString(); // Convert the response to a string
    } else {
      throw Exception("Request failed with status: ${response.statusCode}");
    }
  } catch (e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception("Connection Timeout Exception");
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Receive Timeout Exception");
      }
      throw Exception("Dio Error: ${e.message}");
    } else {
      throw Exception("An error occurred: $e");
    }
  }
}

Future<String?> changePassword(String username, String oldPassword) async {
  bool result = await InternetConnectionChecker().hasConnection;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userSlno = prefs.getInt('logId');

  if (result == true) {
    try {
      final Map<String, dynamic> authData = {
        "USR_Slno": userSlno,
        "userName": username,
        "userPassword": oldPassword,
        "mode": 1,
        "company_id": box.read('clientId')
      };

      Map<String, String> body = {'data': json.encode(authData)};
      FormData formData = FormData.fromMap(body);
      Dio dio = Dio();
      dio.options.headers['content-Type'] = 'multipart/form-data';
      dio.options.headers['Authorization'] = getAdminToken();
      dio.options.connectTimeout = const Duration(seconds: 5);
      dio.options.receiveTimeout = const Duration(seconds: 5);
      dio.interceptors.add(
        RetryInterceptor(
          dio: dio,
          logPrint: print, // specify log function (optional)
          retries: 5, // retry count (optional)
          retryDelays: const [
            // set delays between retries (optional)
            Duration(seconds: 1),
            Duration(seconds: 2),
            Duration(seconds: 3),
            Duration(seconds: 4),
          ],
        ),
      );

      final response = await dio.post(
          "${getCompanyURL()}dndApi/Check_Password_and_username_mobile",
          data: formData);

      if (response.statusCode == 200) {
        return jsonEncode(response.data)
            .toString(); // Convert the response to a string
      } else {
        throw Exception("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          showToast();
          throw Exception("Connection Timeout Exception");
        } else if (e.type == DioExceptionType.receiveTimeout) {
          showToast();
          throw Exception("Receive Timeout Exception");
        }
        throw Exception("Dio Error: ${e.message}");
      } else {
        throw Exception("An error occurred: $e");
      }
    }
  } else {
    showToast();
  }
  return null;
}

Future<String?> resetPassword(
    String username, String oldPassword, String newPassword) async {
  bool result = await InternetConnectionChecker().hasConnection;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userSlno = prefs.getInt('logId');

  if (result == true) {
    try {
      final Map<String, dynamic> authData = {
        "USR_Slno": userSlno,
        "userName": username,
        "userPassword": oldPassword,
        "newPassword": newPassword,
        "company_id": box.read('clientId')
      };

      Map<String, String> body = {'data': json.encode(authData)};
      FormData formData = FormData.fromMap(body);
      Dio dio = Dio();
      dio.options.headers['content-Type'] = 'multipart/form-data';
      dio.options.headers['Authorization'] = getAdminToken();
      dio.options.connectTimeout = const Duration(seconds: 5);
      dio.options.receiveTimeout = const Duration(seconds: 5);
      dio.interceptors.add(
        RetryInterceptor(
          dio: dio,
          logPrint: print, // specify log function (optional)
          retries: 5, // retry count (optional)
          retryDelays: const [
            // set delays between retries (optional)
            Duration(seconds: 1),
            Duration(seconds: 2),
            Duration(seconds: 3),
            Duration(seconds: 4),
          ],
        ),
      );

      final response = await dio.post(
          "${getCompanyURL()}dndApi/employee_PasswordChange_mobile",
          data: formData);

      if (response.statusCode == 200) {
        return jsonEncode(response.data)
            .toString(); // Convert the response to a string
      } else {
        throw Exception("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          showToast();
          throw Exception("Connection Timeout Exception");
        } else if (e.type == DioExceptionType.receiveTimeout) {
          showToast();
          throw Exception("Receive Timeout Exception");
        }
        throw Exception("Dio Error: ${e.message}");
      } else {
        throw Exception("An error occurred: $e");
      }
    }
  } else {
    showToast();
  }
  return null;
}

viewCommonCodes() async {
  bool result = await InternetConnectionChecker().hasConnection;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userSlno = prefs.getInt('logId');
  if (result == true) {
    try {
      final Map<String, dynamic> authData = {
        "user": userSlno,
        "company_id": box.read('clientId')
      };
      Dio dio = Dio();
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Authorization'] = getAdminToken();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);
      dio.interceptors.add(
        RetryInterceptor(
          dio: dio,
          logPrint: print, // specify log function (optional)
          retries: 5, // retry count (optional)
          retryDelays: const [
            // set delays between retries (optional)
            Duration(seconds: 1),
            Duration(seconds: 2),
            Duration(seconds: 3),
            Duration(seconds: 4),
          ],
        ),
      );
      final response = await dio.post(
          "${getCompanyURL()}dndApi/commoncodes_details_View_Mobile",
          data: authData);
      if (response.statusCode == 200) {
        return jsonEncode(response.data)
            .toString(); // Convert the response to a string
      } else {
        throw Exception("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          showToast();
          throw Exception("Connection Timeout Exception");
        } else if (e.type == DioExceptionType.receiveTimeout) {
          showToast();
          throw Exception("Receive Timeout Exception");
        }
        throw Exception("Dio Error: ${e.message}");
      } else {
        throw Exception("An error occurred: $e");
      }
    }
  } else {
    showToast();
  }
  return null;
}

editCommonCodes(
  int? mode,
  String? descSlNo,
  String? designation,
  String? depSlNo,
  String? department,
  String? employerSlNo,
  String? employer,
  String? locationSlNo,
  String? location,
  String? nationality,
  String? nationalitySlNo,
  String? holidayCode,
  String? fromDate,
  String? toDate,
) async {
  bool result = await InternetConnectionChecker().hasConnection;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userSlno = prefs.getInt('logId');
  if (result == true) {
    try {
      final Map<String, dynamic> authData = {
        "mode": mode,
        "descSlno": descSlNo,
        "DESIGNATIONS": designation,
        "depSlno": depSlNo,
        "DEPARTMENTS": department,
        "Employer": employer,
        "employerSlno": employerSlNo,
        "locationSlno": locationSlNo,
        "location": location,
        "nationality": nationality,
        "nationalitySlno": nationalitySlNo,
        "holidycode": holidayCode,
        "fromdate": fromDate,
        "todate": toDate,
        "user": userSlno,
        "company_id": box.read('clientId')
      };

      Dio dio = Dio();
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Authorization'] = getAdminToken();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);
      dio.interceptors.add(
        RetryInterceptor(
          dio: dio,
          logPrint: print, // specify log function (optional)
          retries: 5, // retry count (optional)
          retryDelays: const [
            // set delays between retries (optional)
            Duration(seconds: 1),
            Duration(seconds: 2),
            Duration(seconds: 3),
            Duration(seconds: 4),
          ],
        ),
      );
      final response = await dio.post(
          "${getCompanyURL()}dndApi/Commoncode_edit_and_delete_Mobile",
          data: authData);
      if (response.statusCode == 200) {
        return jsonEncode(response.data)
            .toString(); // Convert the response to a string
      } else {
        throw Exception("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          showToast();
          throw Exception("Connection Timeout Exception");
        } else if (e.type == DioExceptionType.receiveTimeout) {
          showToast();
          throw Exception("Receive Timeout Exception");
        }
        throw Exception("Dio Error: ${e.message}");
      } else {
        throw Exception("An error occurred: $e");
      }
    }
  } else {
    showToast();
  }
  return null;
}

addCommonCodesListView(String codeDesc, String comType) async {
  bool result = await InternetConnectionChecker().hasConnection;
  if (result == true) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? logId = prefs.getInt('logId');
    int? userId = box.read('userSlno');
    final Map<String, dynamic> authData = {
      "user": userId,
      "codeDesc": codeDesc,
      "comType": comType,
      "logID": logId,
      "company_id": box.read('clientId')
    };
    try {
      Dio dio = Dio();
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers['Authorization'] = getAdminToken();
      dio.options.connectTimeout = const Duration(seconds: 5);
      dio.options.receiveTimeout = const Duration(seconds: 5);
      dio.interceptors.add(
        RetryInterceptor(
          dio: dio,
          retries: 5, // retry count (optional)
          retryDelays: const [
            // set delays between retries (optional)
            Duration(seconds: 1), // wait 1 sec before the first retry
            Duration(seconds: 2), // wait 2 sec before the second retry
            Duration(seconds: 3), // wait 3 sec before the third retry
            Duration(seconds: 4), // wait 4 sec before the fourth retry
          ],
        ),
      );
      final response = await dio.post(
          "${getCompanyURL()}dndApi/Save_COMMONCODES_EMP_DETAILS_MOBILE",
          data: authData);
      if (response.statusCode == 200) {
        return jsonEncode(response.data)
            .toString(); // Convert the response to a string
      } else {
        throw Exception("Request failed with status: ${response.statusCode}");
      }
      //
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          showToast();
          throw Exception("Connection Timeout Exception");
        } else if (e.type == DioExceptionType.receiveTimeout) {
          showToast();
          throw Exception("Receive Timeout Exception");
        }
        throw Exception("Dio Error: ${e.message}");
      } else {
        throw Exception("An error occurred: $e");
      }
    }
  } else {
    showToast();
  }
}

shiftEditDeleteCommonCodes(
    int? mode,
    String? shiftCodeOld,
    String? shiftCode,
    String? shiftDescription,
    String? shiftStartTime,
    String? shiftEndTime,
    String? shiftHRS,
    String? lateStart,
    String? earlyEnd,
    List? weeklyOff,
    bool? openShift,
    bool? nightShift,
    bool? otShift,
    bool? clearWeekFlag) async {
  bool result = await InternetConnectionChecker().hasConnection;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userSlno = prefs.getInt('logId');
  if (result == true) {
    try {
      final Map<String, dynamic> authData = {
        "shiftCodeOld": shiftCodeOld,
        "shiftCode": shiftCode,
        "shiftDescription": shiftDescription,
        "shiftStartTime": shiftStartTime,
        "shiftEndTime": shiftEndTime,
        "shiftHRS": shiftHRS,
        "lateStart": lateStart,
        "earlyEnd": earlyEnd,
        "weeklyOff": weeklyOff,
        "CREATED_BY": userSlno,
        "openShift": openShift,
        "nightShift": nightShift,
        "otShift": otShift,
        "mode": mode,
        "user": userSlno,
        "clearWeekFlag": clearWeekFlag,
        "company_id": box.read('clientId')
      };

      Dio dio = Dio();
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Authorization'] = getAdminToken();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);
      dio.interceptors.add(
        RetryInterceptor(
          dio: dio,
          logPrint: print, // specify log function (optional)
          retries: 5, // retry count (optional)
          retryDelays: const [
            // set delays between retries (optional)
            Duration(seconds: 1),
            Duration(seconds: 2),
            Duration(seconds: 3),
            Duration(seconds: 4),
          ],
        ),
      );
      final response = await dio.post(
          "${getCompanyURL()}dndApi/Shift_edit_and_delete_Mobile",
          data: authData);
      if (response.statusCode == 200) {
        return jsonEncode(response.data)
            .toString(); // Convert the response to a string
      } else {
        throw Exception("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          showToast();
          throw Exception("Connection Timeout Exception");
        } else if (e.type == DioExceptionType.receiveTimeout) {
          showToast();
          throw Exception("Receive Timeout Exception");
        }
        throw Exception("Dio Error: ${e.message}");
      } else {
        throw Exception("An error occurred: $e");
      }
    }
  } else {
    showToast();
  }
  return null;
}

monthlyWiseReport(String startDate, String endDate, String? empSlno) async {
  bool result = await InternetConnectionChecker().hasConnection;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userSlno = prefs.getInt('logId');
  String fromDateString = DateFormat('yyyy-MM-dd')
      .format(DateFormat(getCompanyDateFormat()).parse(startDate))
      .toString();

  String toDateString = DateFormat('yyyy-MM-dd')
      .format(DateFormat(getCompanyDateFormat()).parse(endDate))
      .toString();

  if (result == true) {
    try {
      final Map<String, dynamic> authData = {
        "fromDate": fromDateString,
        "toDate": toDateString,
        "user": userSlno,
        "empSlno": empSlno,
        "mode": empSlno == null ? 2 : 1,
        "company_id": box.read('clientId')
      };

      Dio dio = Dio();
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Authorization'] = getAdminToken();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);
      dio.interceptors.add(
        RetryInterceptor(
          dio: dio,
          logPrint: print, // specify log function (optional)
          retries: 5, // retry count (optional)
          retryDelays: const [
            // set delays between retries (optional)
            Duration(seconds: 1),
            Duration(seconds: 2),
            Duration(seconds: 3),
            Duration(seconds: 4),
          ],
        ),
      );
      final response = await dio.post(
          "${getCompanyURL()}dndApi/Get_Attendance_card_Mobile",
          data: authData);
      if (response.statusCode == 200) {
        return jsonEncode(response.data)
            .toString(); // Convert the response to a string
      } else {
        throw Exception("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          showToast();
          throw Exception("Connection Timeout Exception");
        } else if (e.type == DioExceptionType.receiveTimeout) {
          showToast();
          throw Exception("Receive Timeout Exception");
        }
        throw Exception("Dio Error: ${e.message}");
      } else {
        throw Exception("An error occurred: $e");
      }
    }
  } else {
    showToast();
  }
  return null;
}

monthlyWiseReportList(String? empSlno, String? getDate) async {
  bool result = await InternetConnectionChecker().hasConnection;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userSlno = prefs.getInt('logId');

  if (result == true) {
    try {
      final Map<String, dynamic> authData = {
        "empSlno": empSlno,
        "getDate": getDate,
        "user": userSlno,
        "mode": 1,
        "company_id": box.read('clientId')
      };
      Dio dio = Dio();
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Authorization'] = getAdminToken();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);
      dio.interceptors.add(
        RetryInterceptor(
          dio: dio,
          logPrint: print, // specify log function (optional)
          retries: 5, // retry count (optional)
          retryDelays: const [
            // set delays between retries (optional)
            Duration(seconds: 1),
            Duration(seconds: 2),
            Duration(seconds: 3),
            Duration(seconds: 4),
          ],
        ),
      );
      final response = await dio.post(
          "${getCompanyURL()}dndApi/Get_Attendance_card_Employee_wise_Mobile",
          data: authData);
      if (response.statusCode == 200) {
        return jsonEncode(response.data)
            .toString(); // Convert the response to a string
      } else {
        throw Exception("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          showToast();
          throw Exception("Connection Timeout Exception");
        } else if (e.type == DioExceptionType.receiveTimeout) {
          showToast();
          throw Exception("Receive Timeout Exception");
        }
        throw Exception("Dio Error: ${e.message}");
      } else {
        throw Exception("An error occurred: $e");
      }
    }
  } else {
    showToast();
  }
  return null;
}

activeEmployeeDetails(String? empCode) async {
  bool result = await InternetConnectionChecker().hasConnection;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userSlno = prefs.getInt('logId');
  if (result == true) {
    try {
      final Map<String, dynamic> authData = {
        "empcode": empCode,
        "mode": 1,
        "company_id": box.read('clientId'),
        "user": userSlno
      };
      Dio dio = Dio();
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Authorization'] = getAdminToken();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);
      dio.interceptors.add(
        RetryInterceptor(
          dio: dio,
          logPrint: print, // specify log function (optional)
          retries: 5, // retry count (optional)
          retryDelays: const [
            // set delays between retries (optional)
            Duration(seconds: 1),
            Duration(seconds: 2),
            Duration(seconds: 3),
            Duration(seconds: 4),
          ],
        ),
      );
      final response = await dio.post(
          "${getCompanyURL()}dndApi/Get_employeedetails_mobile",
          data: authData);
      if (response.statusCode == 200) {
        return jsonEncode(response.data)
            .toString(); // Convert the response to a string
      } else {
        throw Exception("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          showToast();
          throw Exception("Connection Timeout Exception");
        } else if (e.type == DioExceptionType.receiveTimeout) {
          showToast();
          throw Exception("Receive Timeout Exception");
        }
        throw Exception("Dio Error: ${e.message}");
      } else {
        throw Exception("An error occurred: $e");
      }
    }
  } else {
    showToast();
  }
  return null;
}

//gopluspuch work

//leave return api

leaveReturnList(int EmpId, String? type) async {
  bool result = await InternetConnectionChecker().hasConnection;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userSlno = prefs.getInt('logId');
  if (result == true) {
    try {
      final Map<String, dynamic> authData = {
        "user": userSlno,
        "EMP": EmpId,
        "flg": '0',
        "type": type,
      };
      Dio dio = Dio();
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Authorization'] = getAdminToken();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);
      dio.interceptors.add(
        RetryInterceptor(
          dio: dio,
          logPrint: print, // specify log function (optional)
          retries: 5, // retry count (optional)
          retryDelays: const [
            // set delays between retries (optional)
            Duration(seconds: 1),
            Duration(seconds: 2),
            Duration(seconds: 3),
            Duration(seconds: 4),
          ],
        ),
      );
      final response = await dio.post(
          "${getCompanyURL()}dndApi/mobEss_leave_return_data_mobile",
          data: authData);
      if (response.statusCode == 200) {
        return jsonEncode(response.data)
            .toString(); // Convert the response to a string
      } else {
        throw Exception("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          showToast();
          throw Exception("Connection Timeout Exception");
        } else if (e.type == DioExceptionType.receiveTimeout) {
          showToast();
          throw Exception("Receive Timeout Exception");
        }
        throw Exception("Dio Error: ${e.message}");
      } else {
        throw Exception("An error occurred: $e");
      }
    }
  } else {
    showToast();
  }
  return null;
}

Future<String?> saveLeaveReturn(
    int process,
    String? date,
    String? remark,
    int emp,
    int edit_usr,
    int annualLeaveSlNo,
    int req_by_emp,
    int editId,
    String empName,
    int fileCount,
    List attachment,
    bool flag,
    String type) async {
  bool result = await InternetConnectionChecker().hasConnection;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userSlno = prefs.getInt('logId');

  if (result == true) {
    try {
      final Map<String, dynamic> authData = {
        "user": userSlno,
        "process": process,
        "date": date,
        "remark": remark,
        "emp": emp,
        "edit_usr": edit_usr,
        "annualLeaveSlno": annualLeaveSlNo,
        "genObj": {
          "req_by_emp": req_by_emp,
          "emp": editId,
          "empName": empName,
          "fileCount": fileCount,
          "loc": null
        },
        "attachment": attachment,
        "flg": flag,
        "type": type,
        "mobflag": 1,
        "time": time
      };
      Map<String, String> body = {'data': json.encode(authData)};
      FormData formData = FormData.fromMap(body);
      Dio dio = Dio();
      dio.options.headers['content-Type'] = 'multipart/form-data';
      dio.options.headers['Authorization'] = getAdminToken();
      dio.options.connectTimeout = const Duration(seconds: 5);
      dio.options.receiveTimeout = const Duration(seconds: 5);
      dio.interceptors.add(
        RetryInterceptor(
          dio: dio,
          logPrint: print, // specify log function (optional)
          retries: 5, // retry count (optional)
          retryDelays: const [
            // set delays between retries (optional)
            Duration(seconds: 1),
            Duration(seconds: 2),
            Duration(seconds: 3),
            Duration(seconds: 4),
          ],
        ),
      );

      final response = await dio.post(
          "${getCompanyURL()}dndApi/mobESS_leave_return_save_mobile",
          data: formData);

      if (response.statusCode == 200) {
        return jsonEncode(response.data)
            .toString(); // Convert the response to a string
      } else {
        throw Exception("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          showToast();
          throw Exception("Connection Timeout Exception");
        } else if (e.type == DioExceptionType.receiveTimeout) {
          showToast();
          throw Exception("Receive Timeout Exception");
        }
        throw Exception("Dio Error: ${e.message}");
      } else {
        throw Exception("An error occurred: $e");
      }
    }
  } else {
    showToast();
  }
  return null;
}

//hrletter request

hrLetterRequestList(int EmpId, int? process, int mode) async {
  bool result = await InternetConnectionChecker().hasConnection;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userSlno = prefs.getInt('logId');
  if (result == true) {
    try {
      final Map<String, dynamic> authData = {
        "user": userSlno,
        "Emp_Slno": EmpId,
        "PROCESS": process,
        "Mode": mode
      };
      Dio dio = Dio();
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Authorization'] = getAdminToken();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);
      dio.interceptors.add(
        RetryInterceptor(
          dio: dio,
          logPrint: print, // specify log function (optional)
          retries: 5, // retry count (optional)
          retryDelays: const [
            // set delays between retries (optional)
            Duration(seconds: 1),
            Duration(seconds: 2),
            Duration(seconds: 3),
            Duration(seconds: 4),
          ],
        ),
      );
      final response = await dio.post(
          "${getCompanyURL()}dndApi/ESS_HR_Letter_Process_mobile",
          data: authData);

      if (response.statusCode == 200) {
        return jsonEncode(response.data)
            .toString(); // Convert the response to a string
      } else {
        throw Exception("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          showToast();
          throw Exception("Connection Timeout Exception");
        } else if (e.type == DioExceptionType.receiveTimeout) {
          showToast();
          throw Exception("Receive Timeout Exception");
        }
        throw Exception("Dio Error: ${e.message}");
      } else {
        throw Exception("An error occurred: $e");
      }
    }
  } else {
    showToast();
  }
  return null;
}

Future<String?> saveHrLetterRequest(
    int process,
    int employee,
    String requiredDate,
    String purpose,
    String remark,
    int fileCount,
    int req_by_emp,
    String employeeName,
    int scheme_dr,
    int leave,
    List attachment,
    List tags) async {
  bool result = await InternetConnectionChecker().hasConnection;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userSlno = prefs.getInt('logId');
  if (result == true) {
    try {
      var hrRequestData = {
        "user": userSlno,
        "process": process,
        "employee": employee,
        "start_date": requiredDate,
        "Purpose": purpose,
        "remarks": remark,
        "description": '',
        "fileCount": fileCount,
        "req_by_emp": req_by_emp,
        "employeeName": employeeName,
        "loc": null,
        "scheme_dr": scheme_dr,
        "leave": leave,
        "PFT_MOB_FLAG": 1,
        "time": time
      };
      var authData = {
        "hrLetter": hrRequestData,
        "attachment": attachment,
        "tags": tags
      };
      Map<String, String> body = {'data': json.encode(authData)};
      FormData formData = FormData.fromMap(body);
      Dio dio = Dio();
      dio.options.headers['content-Type'] = 'multipart/form-data';
      dio.options.headers['Authorization'] = getAdminToken();
      dio.options.connectTimeout = const Duration(seconds: 5);
      dio.options.receiveTimeout = const Duration(seconds: 5);
      dio.interceptors.add(
        RetryInterceptor(
          dio: dio,
          logPrint: print, // specify log function (optional)
          retries: 5, // retry count (optional)
          retryDelays: const [
            // set delays between retries (optional)
            Duration(seconds: 1),
            Duration(seconds: 2),
            Duration(seconds: 3),
            Duration(seconds: 4),
          ],
        ),
      );

      final response = await dio.post(
          "${getCompanyURL()}dndApi/mobESS_saveLetterRequest_mobile",
          data: formData);

      if (response.statusCode == 200) {
        return jsonEncode(response.data)
            .toString(); // Convert the response to a string
      } else {
        throw Exception("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          showToast();
          throw Exception("Connection Timeout Exception");
        } else if (e.type == DioExceptionType.receiveTimeout) {
          showToast();
          throw Exception("Receive Timeout Exception");
        }
        throw Exception("Dio Error: ${e.message}");
      } else {
        throw Exception("An error occurred: $e");
      }
    }
  } else {
    showToast();
  }
  return null;
}

//hrletter approval

getApprovalHrLetterRequests() async {
  bool result = await InternetConnectionChecker().hasConnection;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userSlno = prefs.getInt('logId');
  if (result == true) {
    try {
      final Map<String, dynamic> authData = {
        "userSlno": userSlno,
        "onBehalf": 0
      };
      Dio dio = Dio();
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Authorization'] = getAdminToken();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);
      dio.interceptors.add(
        RetryInterceptor(
          dio: dio,
          logPrint: print, // specify log function (optional)
          retries: 5, // retry count (optional)
          retryDelays: const [
            // set delays between retries (optional)
            Duration(seconds: 1),
            Duration(seconds: 2),
            Duration(seconds: 3),
            Duration(seconds: 4),
          ],
        ),
      );
      final response = await dio.post(
          "${getCompanyURL()}dndApi/HRLetter_pending_approvals_data_mobile",
          data: authData);
      if (response.statusCode == 200) {
        return jsonEncode(response.data)
            .toString(); // Convert the response to a string
      } else {
        throw Exception("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          showToast();
          throw Exception("Connection Timeout Exception");
        } else if (e.type == DioExceptionType.receiveTimeout) {
          showToast();
          throw Exception("Receive Timeout Exception");
        }
        throw Exception("Dio Error: ${e.message}");
      } else {
        throw Exception("An error occurred: $e");
      }
    }
  } else {
    showToast();
  }
  return null;
}

Future<String?> moreDetailsHrLetterRequest(String Pft_Slno) async {
  bool result = await InternetConnectionChecker().hasConnection;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userSlno = prefs.getInt('logId');

  if (result == true) {
    try {
      final Map<String, dynamic> authData = {
        "Pft_Slno": Pft_Slno,
        "userSlno": userSlno
      };
      Map<String, String> body = {'data': json.encode(authData)};
      FormData formData = FormData.fromMap(body);
      Dio dio = Dio();
      dio.options.headers['content-Type'] = 'multipart/form-data';
      dio.options.headers['Authorization'] = getAdminToken();
      dio.options.connectTimeout = const Duration(seconds: 5);
      dio.options.receiveTimeout = const Duration(seconds: 5);
      dio.interceptors.add(
        RetryInterceptor(
          dio: dio,
          logPrint: print, // specify log function (optional)
          retries: 5, // retry count (optional)
          retryDelays: const [
            // set delays between retries (optional)
            Duration(seconds: 1),
            Duration(seconds: 2),
            Duration(seconds: 3),
            Duration(seconds: 4),
          ],
        ),
      );
      final response = await dio.post(
          "${getCompanyURL()}dndApi/HRletter_getLoadRequestDetails_mobile",
          data: formData);

      if (response.statusCode == 200) {
        return jsonEncode(response.data)
            .toString(); // Convert the response to a string
      } else {
        throw Exception("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          showToast();
          throw Exception("Connection Timeout Exception");
        } else if (e.type == DioExceptionType.receiveTimeout) {
          showToast();
          throw Exception("Receive Timeout Exception");
        }
        throw Exception("Dio Error: ${e.message}");
      } else {
        throw Exception("An error occurred: $e");
      }
    }
  } else {
    showToast();
  }
  return null;
}

saveTagsEdit(int masterDr, String letterTag, String pftSlno, String oldDesc,
    String newDesc, String reason) async {
  bool result = await InternetConnectionChecker().hasConnection;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userSlno = prefs.getInt('logId');
  if (result == true) {
    try {
      final Map<String, dynamic> authData = {
        "details": {
          "masterDr": masterDr,
          "letterTag": letterTag,
          "pftSlno": pftSlno,
          "oldDesc": oldDesc,
          "newDesc": newDesc,
          "reason": reason
        },
        "userSlno": userSlno,
        "mobflag": 1
      };
      Dio dio = Dio();
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Authorization'] = getAdminToken();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);
      dio.interceptors.add(
        RetryInterceptor(
          dio: dio,
          logPrint: print, // specify log function (optional)
          retries: 5, // retry count (optional)
          retryDelays: const [
            // set delays between retries (optional)
            Duration(seconds: 1),
            Duration(seconds: 2),
            Duration(seconds: 3),
            Duration(seconds: 4),
          ],
        ),
      );
      final response = await dio.post(
          "${getCompanyURL()}dndApi/UpdateHrLetterNonEmployeeTags_mobile",
          data: authData);
      if (response.statusCode == 200) {
        return jsonEncode(response.data)
            .toString(); // Convert the response to a string
      } else {
        throw Exception("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          showToast();
          throw Exception("Connection Timeout Exception");
        } else if (e.type == DioExceptionType.receiveTimeout) {
          showToast();
          throw Exception("Receive Timeout Exception");
        }
        throw Exception("Dio Error: ${e.message}");
      } else {
        throw Exception("An error occurred: $e");
      }
    }
  } else {
    showToast();
  }
  return null;
}

Future<String?> submitHrLetterRequestDetails(List requestDetailsList) async {
  bool result = await InternetConnectionChecker().hasConnection;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userSlno = prefs.getInt('logId');

  if (result == true) {
    try {
      var requests = {
        "user": userSlno,
        "list": requestDetailsList,
        "mobFlag": 1,
        "onBehalf": false
      };
      Map<String, String> body = {'data': json.encode(requests)};
      FormData formData = FormData.fromMap(body);
      Dio dio = Dio();
      dio.options.headers['content-Type'] = 'multipart/form-data';
      dio.options.headers['Authorization'] = getAdminToken();
      dio.options.connectTimeout = const Duration(seconds: 5);
      dio.options.receiveTimeout = const Duration(seconds: 5);
      dio.interceptors.add(
        RetryInterceptor(
          dio: dio,
          logPrint: print, // specify log function (optional)
          retries: 5, // retry count (optional)
          retryDelays: const [
            // set delays between retries (optional)
            Duration(seconds: 1),
            Duration(seconds: 2),
            Duration(seconds: 3),
            Duration(seconds: 4),
          ],
        ),
      );
      final response = await dio.post(
          "${getCompanyURL()}dndApi/ESS_Save_approvel_mobile",
          data: formData);

      if (response.statusCode == 200) {
        return jsonEncode(response.data)
            .toString(); // Convert the response to a string
      } else {
        throw Exception("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          showToast();
          throw Exception("Connection Timeout Exception");
        } else if (e.type == DioExceptionType.receiveTimeout) {
          showToast();
          throw Exception("Receive Timeout Exception");
        }
        throw Exception("Dio Error: ${e.message}");
      } else {
        throw Exception("An error occurred: $e");
      }
    }
  } else {
    showToast();
  }
  return null;
}

Future<String?> previewHrLetter(String Pft_Slno) async {
  bool result = await InternetConnectionChecker().hasConnection;
  int? userSlno = box.read('userSlno');

  if (result == true) {
    try {
      final Map<String, dynamic> authData = {
        "PFT_SLNO": Pft_Slno,
        "user": userSlno
      };

      Map<String, String> body = {'data': json.encode(authData)};
      FormData formData = FormData.fromMap(body);
      Dio dio = Dio();
      dio.options.headers['content-Type'] = 'multipart/form-data';
      dio.options.headers['Authorization'] = getAdminToken();
      dio.options.connectTimeout = const Duration(seconds: 5);
      dio.options.receiveTimeout = const Duration(seconds: 5);
      dio.interceptors.add(
        RetryInterceptor(
          dio: dio,
          logPrint: print, // specify log function (optional)
          retries: 5, // retry count (optional)
          retryDelays: const [
            // set delays between retries (optional)
            Duration(seconds: 1),
            Duration(seconds: 2),
            Duration(seconds: 3),
            Duration(seconds: 4),
          ],
        ),
      );
      final response = await dio.post(
          "${getCompanyURL()}dndApi/ESS_loadGenerateTemplateHR_lettermobile",
          data: formData);

      if (response.statusCode == 200) {
        return jsonEncode(response.data)
            .toString(); // Convert the response to a string
      } else {
        throw Exception("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          showToast();
          throw Exception("Connection Timeout Exception");
        } else if (e.type == DioExceptionType.receiveTimeout) {
          showToast();
          throw Exception("Receive Timeout Exception");
        }
        throw Exception("Dio Error: ${e.message}");
      } else {
        throw Exception("An error occurred: $e");
      }
    }
  } else {
    showToast();
  }
  return null;
}

Future<String?> getHRTemplate(String tempalte, int empSlno) async {
  bool result = await InternetConnectionChecker().hasConnection;
  if (result == true) {
    try {
      final Map<String, dynamic> authData = {
        "tempname": tempalte,
        "Emp_Slno": empSlno,
        "mode": 3
      };

      Map<String, String> body = {'data': json.encode(authData)};
      FormData formData = FormData.fromMap(body);
      Dio dio = Dio();
      dio.options.headers['content-Type'] = 'multipart/form-data';
      dio.options.headers['Authorization'] = getAdminToken();
      dio.options.connectTimeout = const Duration(seconds: 5);
      dio.options.receiveTimeout = const Duration(seconds: 5);
      dio.interceptors.add(
        RetryInterceptor(
          dio: dio,
          logPrint: print, // specify log function (optional)
          retries: 5, // retry count (optional)
          retryDelays: const [
            // set delays between retries (optional)
            Duration(seconds: 1),
            Duration(seconds: 2),
            Duration(seconds: 3),
            Duration(seconds: 4),
          ],
        ),
      );
      final response = await dio.post(
          "${getCompanyURL()}dndApi/ESS_GenerateTemplateHR_letterPreview_mobile",
          data: formData);

      if (response.statusCode == 200) {
        return jsonEncode(response.data)
            .toString(); // Convert the response to a string
      } else {
        throw Exception("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          showToast();
          throw Exception("Connection Timeout Exception");
        } else if (e.type == DioExceptionType.receiveTimeout) {
          showToast();
          throw Exception("Receive Timeout Exception");
        }
        throw Exception("Dio Error: ${e.message}");
      } else {
        throw Exception("An error occurred: $e");
      }
    }
  } else {
    showToast();
  }
  return null;
}

//employee summary report
employeeSummaryReport(String empCode, String fromDate, String toDate) async {
  bool result = await InternetConnectionChecker().hasConnection;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userSlno = prefs.getInt('logId');

  if (result == true) {
    try {
      final Map<String, dynamic> authData = {
        "user": userSlno,
        "empcode": empCode,
        "startDate": fromDate,
        "endDate": toDate,
        "company_id": box.read('clientId'),
      };

      Map<String, String> body = {'data': json.encode(authData)};
      FormData formData = FormData.fromMap(body);
      Dio dio = Dio();
      dio.options.headers['content-Type'] = 'multipart/form-data';
      dio.options.headers['Authorization'] = getAdminToken();
      dio.options.connectTimeout = const Duration(seconds: 5);
      dio.options.receiveTimeout = const Duration(seconds: 5);
      dio.interceptors.add(
        RetryInterceptor(
          dio: dio,
          logPrint: print, // specify log function (optional)
          retries: 5, // retry count (optional)
          retryDelays: const [
            // set delays between retries (optional)
            Duration(seconds: 1),
            Duration(seconds: 2),
            Duration(seconds: 3),
            Duration(seconds: 4),
          ],
        ),
      );

      final response = await dio.post(
          "${getCompanyURL()}dndApi/employee_Performance_reportPage_mobile",
          data: formData);
      if (response.statusCode == 200) {
        return jsonEncode(response.data)
            .toString(); // Convert the response to a string
      } else {
        throw Exception("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          showToast();
          throw Exception("Connection Timeout Exception");
        } else if (e.type == DioExceptionType.receiveTimeout) {
          showToast();
          throw Exception("Receive Timeout Exception");
        }
        throw Exception("Dio Error: ${e.message}");
      } else {
        throw Exception("An error occurred: $e");
      }
    }
  } else {
    showToast();
  }
  return null;
}

//hrletter request stataus
Future<String?> getHrLetterRequestStatus(String year) async {
  bool result = await InternetConnectionChecker().hasConnection;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userSlno = prefs.getInt('logId');

  if (result == true) {
    try {
      var requests = {"userSlno": userSlno, "Mflag": 1, "currentyear": year};

      Map<String, String> body = {'data': json.encode(requests)};
      FormData formData = FormData.fromMap(body);
      Dio dio = Dio();
      dio.options.headers['content-Type'] = 'multipart/form-data';
      dio.options.headers['Authorization'] = getAdminToken();
      dio.options.connectTimeout = const Duration(seconds: 5);
      dio.options.receiveTimeout = const Duration(seconds: 5);
      dio.interceptors.add(
        RetryInterceptor(
          dio: dio,
          logPrint: print, // specify log function (optional)
          retries: 5, // retry count (optional)
          retryDelays: const [
            // set delays between retries (optional)
            Duration(seconds: 1),
            Duration(seconds: 2),
            Duration(seconds: 3),
            Duration(seconds: 4),
          ],
        ),
      );
      final response = await dio.post(
          "${getCompanyURL()}dndApi/getLoad_ESS_Hr_letter_Request_Status_mobile",
          data: formData);

      if (response.statusCode == 200) {
        return jsonEncode(response.data)
            .toString(); // Convert the response to a string
      } else {
        throw Exception("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          showToast();
          throw Exception("Connection Timeout Exception");
        } else if (e.type == DioExceptionType.receiveTimeout) {
          showToast();
          throw Exception("Receive Timeout Exception");
        }
        throw Exception("Dio Error: ${e.message}");
      } else {
        throw Exception("An error occurred: $e");
      }
    }
  } else {
    showToast();
  }
  return null;
}

dataEmployees() async {
  try {
    bool hasConnection = await InternetConnectionChecker().hasConnection;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userSlno = prefs.getInt('logId');
    if (!hasConnection) {
      showToast();
      throw Exception("No internet connection");
    }

    final Map<String, dynamic> authData = {
      "user": userSlno,
      "mobflag": 1,
      "company_id": box.read('clientId'),
    };
    Dio dio = Dio();
    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Authorization'] = getAdminToken();
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(seconds: 5);
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        logPrint: print, // specify log function (optional)
        retries: 5, // retry count (optional)
        retryDelays: const [
          // set delays between retries (optional)
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
          Duration(seconds: 4),
        ],
      ),
    );

    final response = await dio.post(
      "${getCompanyURL()}dndApi/employeeLIst_ATTENDANCE_Mobile",
      data: authData,
    );

    if (response.statusCode == 200) {
      return jsonEncode(response.data)
          .toString(); // Convert the response to a string
    } else {
      throw Exception("Request failed with status: ${response.statusCode}");
    }
  } catch (e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception("Connection Timeout Exception");
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Receive Timeout Exception");
      }
      throw Exception("Dio Error: ${e.message}");
    } else {
      throw Exception("An error occurred: $e");
    }
  }
}

//faris:-exp

getExpanseClaimRequestResponse(
    {required ExpanseClaimProvider provider,
    required,
    required int mFlag}) async {
  try {
    bool hasConnection = await InternetConnectionChecker().hasConnection;

    if (!hasConnection) {
      showToast();
      throw Exception("No internet connection");
    }

    Map<String, dynamic> data = {
      "data": jsonEncode({
        "userID": provider.selectedOnBehalfEmployee != null
            ? provider.selectedOnBehalfEmployee!.id
            : box.read("userSlno"),
        "Emp_Slno": box.read("empId"),
        "Mflag": mFlag,
        "req_typeId": provider.selectedRequestType?.id,
        "reim_id": provider.selectedReimbursementType?.id,
        "payment_type_id": provider.selectedPaymentType?.id
      })
    };

    FormData formData = FormData.fromMap(data);
    Dio dio = Dio();
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        logPrint: print,
        retries: 5,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
          Duration(seconds: 4),
        ],
      ),
    );
    var response = await dio.post(
      '${getCompanyURL()}dndApi/LoadExpenseClaim_Details_mobile',
      options: Options(
        headers: {'Authorization': box.read("token")},
      ),
      data: formData,
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception("Request failed with status: ${response.statusCode}");
    }
  } catch (e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception("Connection Timeout Exception");
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Receive Timeout Exception");
      }
      throw Exception("Dio Error: ${e.message}");
    } else {
      throw Exception("An error occurred: $e");
    }
  }
}

//faris:-exp

//faris - worl

// get all works
Future worklogGetAllWorks(
    BuildContext context, WorklogMyWorksProvider provider) async {
  try {
    FormData formData = FormData.fromMap({
      "data": jsonEncode({"EMP_code": box.read("empCode"), "M_FLAG": 4})
    });

    var res = await apiHandler(
        url: "dndApi/get_Work_log_dashbord_mobile", data: formData);
    provider.isLoading = false;
    return res;
  } catch (e) {
    print(e);
    Provider.of<WorklogCommonProvider>(context, listen: false).onError();
    showToastMsg(context, translation(context).wentWrong);
  }
}

//create work
Future worklogCreateNewWork(FormData formData) async {
  return await apiHandler(
      url: "dndApi/get_save_WorkLog_data_mobile", data: formData);
}

//get work details
Future worklogGetWorkDetails(String workId, BuildContext context) async {
  try {
    FormData formData = FormData.fromMap({
      "data": jsonEncode(
          {"EMP_code": box.read("empCode"), "M_FLAG": 14, "WORKID": workId})
    });
    return await apiHandler(
        url: "dndApi/get_Work_log_update_data_load_mobile", data: formData);
  } catch (e) {
    Provider.of<WorklogCommonProvider>(context, listen: false).onError();
    showToastMsg(context, translation(context).wentWrong);
  }
}

// get intial values for edit work
Future worklogGetInitialValuesForEditWork(String workId) async {
  FormData formData = FormData.fromMap({
    "data": jsonEncode(
        {"EMP_code": box.read("empCode"), "M_FLAG": 14, "WORKID": workId})
  });
  return await apiHandler(
      url: "dndApi/get_Work_log_update_data_load_mobile", data: formData);
}

//delete work
Future worklogDeleteWork(String workId, context) async {
  try {
    FormData formData = FormData.fromMap({
      "data": jsonEncode(
          {"EMP_code": box.read("empCode"), "M_FLAG": 5, "WORKID": workId})
    });
    var res = await apiHandler(
        url: "dndApi/get_Work_log_data_delete_mobile", data: formData);
    if (res.data["result"].runtimeType == bool) {
      if (res.data["result"]) {
        showToastMsg(context, translation(context).deletedSuccessfully,
            backgroundColor: Colors.green);
      } else {
        showToastMsg(context, translation(context).failedToDelete);
      }
    }
  } catch (e) {
    showToastMsg(context, translation(context).wentWrong);
  }
}

// update work
Future worklogUpdateWork(FormData formData) async {
  return await apiHandler(
      url: "dndApi/get_Work_log_data_edit_mobile", data: formData);
}

// submit work
Future worklogSubmitWork(FormData formData) async {
  return await apiHandler(
      url: "dndApi/get_daily_Work_log_update_mobile", data: formData);
}

//get dropdown values
Future worklogGetDropdownValuesResponse(BuildContext context) async {
  try {
    FormData formData = FormData.fromMap({
      "data": jsonEncode({"EMP_code": box.read("empCode"), "M_FLAG": 1})
    });
    return await apiHandler(
        url: "dndApi/get_workLog_details_mobile", data: formData);
  } catch (e) {
    throw "Dio Error";
  }
}

// get all sub works
Future worklogGetAllSubWorks(String workId, BuildContext context,
    WorklogSubWorkProvider provider) async {
  try {
    FormData formData = FormData.fromMap({
      "data": jsonEncode(
          {"EMP_code": box.read("empCode"), "M_FLAG": 8, "WORKID": workId})
    });
    var res = await apiHandler(
        url: "dndApi/get_daily_Work_log_report_mobile", data: formData);
    provider.isLoading = false;
    return res;
  } catch (e) {
    Provider.of<WorklogCommonProvider>(context, listen: false).onError();
    showToastMsg(context, translation(context).wentWrong);
  }
}

//add sub work
Future worklogAddSubWork(FormData formData) async {
  return await apiHandler(
      url: "dndApi/get_daily_Work_log__Save_report_mobile", data: formData);
}

//edit sub work
Future worklogEditSubWork(FormData formData) async {
  return await apiHandler(
      url: "dndApi/get_daily_Work_log_edit_mobile", data: formData);
}

//delete sub work
Future worklogDeleteSubWork(String workId, int subWorkId, BuildContext context,
    WorklogSubWorkProvider provider) async {
  try {
    FormData formData = FormData.fromMap({
      "data": jsonEncode({
        "EMP_code": box.read("empCode"),
        "WORKID": workId,
        "M_FLAG": 11,
        "WORK_SUB_ID": subWorkId,
        "DATE": DateFormat('yyyy-MM-dd').format(DateTime.now())
      })
    });
    var res = await apiHandler(
        url: "dndApi/get_daily_Work_log_Delete_mobile", data: formData);
    if (res.data["result"].runtimeType == bool) {
      if (res.data["result"]) {
        showToastMsg(context, translation(context).deletedSuccessfully,
            backgroundColor: Colors.green);
      } else {
        showToastMsg(
          context,
          translation(context).failedToDelete,
        );
      }
    }
  } catch (e) {
    showToastMsg(context, translation(context).wentWrong);
  }
}

// worklogPostMethode(String url, Object data) async {
//   try {
//     bool haveConnection = await InternetConnectionChecker().hasConnection;
//     if (!haveConnection) {
//       throw "no internet";
//     }
//     Dio dio = Dio();
//     dio.interceptors.add(
//       RetryInterceptor(
//         dio: dio,
//         logPrint: print,
//         retries: 5,
//         retryDelays: const [
//           Duration(seconds: 1),
//           Duration(seconds: 2),
//           Duration(seconds: 3),
//           Duration(seconds: 4),
//         ],
//       ),
//     );
//     var res = await dio.post(getCompanyURL() + url, data: data);

//     return res;
//   } catch (e) {
//     throw "post methode error";
//   }
// }
//faris - worl

showToast() {
  Fluttertoast.showToast(
      msg: 'Bad Internet Connection!',
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.red,
      textColor: Colors.white);
}
