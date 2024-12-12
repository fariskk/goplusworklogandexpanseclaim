import 'package:dots/classes/language_constants.dart';
import 'package:dots/models/expanse_cliam_dropdown_model.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

import '../services/services.dart';

class ExpanseClaimProvider extends ChangeNotifier {
  List<ExpanseClaimDropdownItemModel> requestTypes = [];
  List<ExpanseClaimDropdownItemModel> currencyTypes = [];
  List<ExpanseClaimDropdownItemModel> reimbursementTypes = [];
  List<ExpanseClaimDropdownItemModel> paymentTypes = [];
  List<ExpanseClaimDropdownItemModel> claimTypes = [];
  List<ExpanseClaimDropdownItemModel> employees = [];

  bool isIndividual = true;
  bool isLoading = false;
  ExpanseClaimDropdownItemModel? selectedCurrency;
  ExpanseClaimDropdownItemModel? selectedRequestType;
  ExpanseClaimDropdownItemModel? selectedOnBehalfEmployee;
  ExpanseClaimDropdownItemModel? selectedReimbursementType;
  ExpanseClaimDropdownItemModel? selectedPaymentType;
  ExpanseClaimDropdownItemModel? selectedClaimType;
  List<XFile> attachments = [];

  int expandedCostAllocationItem = -1;
  void clearRequestDetails() {
    selectedCurrency = null;
    selectedRequestType = null;
    selectedOnBehalfEmployee = null;
    selectedReimbursementType = null;
    selectedPaymentType = null;
    selectedClaimType = null;
  }

  void clearDropDownValues() {
    requestTypes.clear();
    currencyTypes.clear();
    reimbursementTypes.clear();
    paymentTypes.clear();
    claimTypes.clear();
    employees.clear();
  }

  getExpanseClaimInitialData(
      {required BuildContext context, required int mFlag}) async {
    try {
      isLoading = true;
      rebuild();

      var result =
          await getExpanseClaimRequestResponse(provider: this, mFlag: mFlag);
      if (result["result"].runtimeType == bool && result["result"] == false) {
        Fluttertoast.showToast(
            msg: translation(context).wentWrong,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 14.0);
      } else {
        paymentTypes.clear();
        reimbursementTypes.clear();
        requestTypes.clear();
        currencyTypes.clear();
        employees.clear();
        claimTypes.clear();
        result["result"][0].forEach((item) {
          requestTypes.add(ExpanseClaimDropdownItemModel(
              id: item["id"], name: item["name"], special: ""));
        });
        result["result"][5].forEach((item) {
          reimbursementTypes.add(ExpanseClaimDropdownItemModel(
              id: item["id"], name: item["ReimbursementsType"], special: ""));
        });
        result["result"][6].forEach((item) {
          paymentTypes.add(ExpanseClaimDropdownItemModel(
              id: item["id"], name: item["PaymentType"], special: ""));
        });
        result["result"][7].forEach((item) {
          currencyTypes.add(ExpanseClaimDropdownItemModel(
              id: item["id"],
              name: item["name"],
              special: item["CUR_EXCHNGE_RATE"]));
        });
        result["result"][3].forEach((item) {
          claimTypes.add(ExpanseClaimDropdownItemModel(
              id: item["id"], name: item["ClaimType"], special: ""));
        });

        result["result"][1].forEach((item) {
          employees.add(ExpanseClaimDropdownItemModel(
              id: int.parse(item["empid"]),
              name: item["emp_name"],
              special: ""));
        });
      }
      isLoading = false;
      rebuild();
    } catch (e) {
      isLoading = false;
      rebuild();

      Fluttertoast.showToast(
          msg: translation(context).wentWrong,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0);
    }
  }

  void rebuild() {
    notifyListeners();
  }
}
