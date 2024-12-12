import 'package:dots/SizeConfigure.dart';
import 'package:dots/classes/commonFunctions.dart';
import 'package:dots/classes/commonWidgets.dart';
import 'package:dots/classes/language.dart';
import 'package:dots/classes/language_constants.dart';
import 'package:dots/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../main.dart';
import '../../../models/expanse_cliam_dropdown_model.dart';
import '../../../provider/expanse_claim_provider.dart';
import '../../../widgets/button_global.dart';

TextEditingController claimTypeController = TextEditingController();
SuggestionsController suggestionsController6 = SuggestionsController();
List claims = [];

class ExpenseClaimScreen extends StatefulWidget {
  ExpenseClaimScreen({super.key});

  @override
  State<ExpenseClaimScreen> createState() => _ExpenseClaimScreenState();
}

class _ExpenseClaimScreenState extends State<ExpenseClaimScreen> {
  SuggestionsController suggestionsController1 = SuggestionsController();
  SuggestionsController suggestionsController2 = SuggestionsController();
  SuggestionsController suggestionsController3 = SuggestionsController();
  SuggestionsController suggestionsController4 = SuggestionsController();
  SuggestionsController suggestionsController5 = SuggestionsController();

  TextEditingController requestTypeController = TextEditingController();
  TextEditingController onBehalfController = TextEditingController();
  TextEditingController reimbuismentController = TextEditingController();
  TextEditingController paymentTypeController = TextEditingController();
  TextEditingController currencyTypeController = TextEditingController();

  @override
  void initState() {
    ExpanseClaimProvider provider =
        Provider.of<ExpanseClaimProvider>(context, listen: false);
    provider.clearRequestDetails();
    provider.clearDropDownValues();
    provider.isIndividual = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.getExpanseClaimInitialData(context: context, mFlag: 1);
    });
    super.initState();
  }

  double total = 0;
  double pettyBal = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child:
          Consumer<ExpanseClaimProvider>(builder: (context, provider, child) {
        total = 0;
        for (var e in claims) {
          total = total + e["amount"];
        }
        return Scaffold(
            backgroundColor: CommonServices().getThemeColor(),
            appBar: myAppbar(context, provider),
            body: Stack(
              children: [
                InkWell(
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      width: SizeConfigure.widthMultiplier! * 100,
                      height: SizeConfigure.heightMultiplier! * 100 -
                          (myAppbar(context, provider).preferredSize.height +
                              MediaQuery.of(context).padding.top),
                      decoration: const BoxDecoration(
                        color: kBgColor,
                      ),
                      child: Column(
                        children: [
                          customSpacer(
                              height: SizeConfigure.heightMultiplier! * 1),
                          Visibility(
                            visible: !provider.isIndividual,
                            child: Column(
                              children: [
                                typeHead(
                                    context,
                                    onBehalfController,
                                    (context, var suggestion) {
                                      return ListTile(
                                          title: Text(
                                        suggestion.name.toString(),
                                        style: kTextStyle.copyWith(
                                            fontSize: 1.8 *
                                                SizeConfigure.textMultiplier!),
                                      ));
                                    },
                                    (dynamic suggestion) {
                                      onBehalfController.text = suggestion.name;
                                      provider.selectedOnBehalfEmployee =
                                          suggestion;
                                      provider.rebuild();
                                      provider.getExpanseClaimInitialData(
                                          context: context, mFlag: 1);
                                    },
                                    (search) {
                                      return provider.employees
                                          .where((element) => element.name
                                              .toUpperCase()
                                              .contains(search.toUpperCase()))
                                          .toList();
                                    },
                                    translation(context).selectEmpHint,
                                    translation(context).selectEmp,
                                    suggestionsController1,
                                    () {
                                      onBehalfController.clear();
                                      currencyTypeController.clear();
                                      paymentTypeController.clear();
                                      reimbuismentController.clear();
                                      requestTypeController.clear();
                                      provider.selectedOnBehalfEmployee = null;
                                      provider.selectedCurrency = null;
                                      provider.selectedPaymentType = null;
                                      provider.selectedReimbursementType = null;
                                      provider.selectedRequestType = null;
                                      provider.rebuild();
                                    },
                                    null,
                                    null,
                                    null,
                                    null),
                                customSpacer(
                                    height:
                                        SizeConfigure.heightMultiplier! * 2.8),
                              ],
                            ),
                          ),
                          typeHead(
                              context,
                              requestTypeController,
                              (context, var suggestion) {
                                return ListTile(
                                    title: Text(
                                  suggestion.name.toString(),
                                  style: kTextStyle.copyWith(
                                      fontSize:
                                          1.8 * SizeConfigure.textMultiplier!),
                                ));
                              },
                              (dynamic suggestion) {
                                requestTypeController.text = suggestion.name;
                                provider.selectedRequestType = suggestion;
                                provider.getExpanseClaimInitialData(
                                    context: context, mFlag: 1);
                                provider.rebuild();
                              },
                              (search) {
                                return provider.requestTypes
                                    .where((element) => element.name
                                        .toUpperCase()
                                        .contains(search.toUpperCase()))
                                    .toList();
                              },
                              translation(context).selectRequestTypeHint,
                              translation(context).selectRequestType,
                              suggestionsController2,
                              () {
                                requestTypeController.clear();
                                currencyTypeController.clear();
                                paymentTypeController.clear();
                                reimbuismentController.clear();
                                provider.selectedCurrency = null;
                                provider.selectedPaymentType = null;
                                provider.selectedReimbursementType = null;
                                provider.selectedRequestType = null;
                                provider.rebuild();
                              },
                              null,
                              null,
                              null,
                              null),
                          customSpacer(
                              height: SizeConfigure.heightMultiplier! * 2.8),
                          typeHead(
                              context,
                              reimbuismentController,
                              (context, var suggestion) {
                                return ListTile(
                                    title: Text(
                                  suggestion.name.toString(),
                                  style: kTextStyle.copyWith(
                                      fontSize:
                                          1.8 * SizeConfigure.textMultiplier!),
                                ));
                              },
                              (dynamic suggestion) {
                                reimbuismentController.text = suggestion.name;
                                provider.selectedReimbursementType = suggestion;

                                provider.rebuild();
                                provider.getExpanseClaimInitialData(
                                    context: context, mFlag: 1);
                              },
                              (search) {
                                return provider.reimbursementTypes
                                    .where((element) => element.name
                                        .toUpperCase()
                                        .contains(search.toUpperCase()))
                                    .toList();
                              },
                              translation(context).selectReimbursementTypeHint,
                              translation(context).selectReimbursementType,
                              suggestionsController3,
                              () {
                                reimbuismentController.clear();
                                paymentTypeController.clear();
                                currencyTypeController.clear();
                                provider.selectedReimbursementType = null;
                                provider.selectedPaymentType = null;
                                provider.selectedCurrency = null;
                                provider.rebuild();
                              },
                              null,
                              null,
                              null,
                              null),
                          customSpacer(
                              height: SizeConfigure.heightMultiplier! * 2.8),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: typeHead(
                                    context,
                                    paymentTypeController,
                                    (context, var suggestion) {
                                      return ListTile(
                                          title: Text(
                                        suggestion.name.toString(),
                                        style: kTextStyle.copyWith(
                                            fontSize: 1.8 *
                                                SizeConfigure.textMultiplier!),
                                      ));
                                    },
                                    (dynamic suggestion) {
                                      paymentTypeController.text =
                                          suggestion.name;
                                      provider.selectedPaymentType = suggestion;
                                      provider.rebuild();
                                      provider.getExpanseClaimInitialData(
                                          context: context, mFlag: 1);
                                    },
                                    (search) {
                                      return provider.paymentTypes
                                          .where((element) => element.name
                                              .toUpperCase()
                                              .contains(search.toUpperCase()))
                                          .toList();
                                    },
                                    translation(context).selectPaymentTypeHint,
                                    translation(context).selectPaymentType,
                                    suggestionsController4,
                                    () {
                                      paymentTypeController.clear();
                                      currencyTypeController.clear();
                                      provider.selectedCurrency = null;
                                      provider.selectedPaymentType = null;

                                      provider.rebuild();
                                    },
                                    null,
                                    null,
                                    null,
                                    null),
                              ),
                              customSpacer(
                                  width: SizeConfigure.widthMultiplier! * 2.8),
                              Expanded(
                                flex: 2,
                                child: typeHead(
                                    context,
                                    currencyTypeController,
                                    (context, var suggestion) {
                                      return ListTile(
                                          title: Text(
                                        suggestion.name.toString(),
                                        style: kTextStyle.copyWith(
                                            fontSize: 1.8 *
                                                SizeConfigure.textMultiplier!),
                                      ));
                                    },
                                    (dynamic suggestion) {
                                      currencyTypeController.text =
                                          suggestion.name;
                                      provider.selectedCurrency = suggestion;
                                      provider.rebuild();
                                    },
                                    (search) {
                                      return provider.currencyTypes
                                          .where((element) => element.name
                                              .toUpperCase()
                                              .contains(search.toUpperCase()))
                                          .toList();
                                    },
                                    translation(context).currencyHint,
                                    translation(context).currency,
                                    suggestionsController5,
                                    () {
                                      currencyTypeController.clear();
                                      provider.selectedCurrency = null;
                                      provider.rebuild();
                                    },
                                    null,
                                    null,
                                    null,
                                    null),
                              ),
                            ],
                          ),
                          customSpacer(
                              height: SizeConfigure.heightMultiplier! * 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              customText(translation(context).claimDetails,
                                  fontSize: 2, fontWeight: FontWeight.bold),
                              InkWell(
                                  onTap: () {
                                    myAddClaimBottomSheet(
                                      context,
                                      provider,
                                    );
                                  },
                                  child: const Icon(
                                    Icons.add_box,
                                    size: 30,
                                  ))
                            ],
                          ),
                          customSpacer(
                              height: SizeConfigure.heightMultiplier! * 1.5),
                          Expanded(
                              child: claims.length < 1
                                  ? Center(
                                      child: Lottie.asset("images/nodata.json"),
                                    )
                                  : ListView.builder(
                                      itemCount: claims.length,
                                      itemBuilder: (context, index) {
                                        Map claimDetails = claims[index];
                                        return myClaimDetailsWidget(index,
                                            provider, claimDetails, context);
                                      })),
                          customSpacer(
                              height: SizeConfigure.heightMultiplier! * 1.5),
                          Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.all(5),
                                width: SizeConfigure.widthMultiplier! * 30,
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        customText(
                                            "${translation(context).total} : ",
                                            fontWeight: FontWeight.bold),
                                        customText("₹$total",
                                            fontWeight: FontWeight.bold),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        customText(
                                            "${translation(context).pettyBal} : ",
                                            fontSize: 1,
                                            fontWeight: FontWeight.w600),
                                        customText("₹1000",
                                            fontSize: 1,
                                            fontWeight: FontWeight.w600),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: ButtonGlobal(
                                    buttontext: translation(context).submit,
                                    buttonDecoration: const BoxDecoration(
                                        color: kMainColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    onPressed: () {}),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: provider.isLoading,
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                        width: SizeConfigure.widthMultiplier! * 100,
                        height: SizeConfigure.heightMultiplier! * 100,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: buildLoader()),
                  ),
                )
              ],
            ));
      }),
    );
  }
}

AppBar myAppbar(BuildContext context, ExpanseClaimProvider provider) {
  return AppBar(
    elevation: 0.0,
    backgroundColor: CommonServices().getThemeColor(),
    leading: IconButton(
      icon: const Icon(
        Icons.arrow_back_ios,
        color: Colors.white,
      ),
      onPressed: () async {
        Navigator.pop(context);
      },
    ),
    title: customText(translation(context).expanseClaimRequest,
        fontSize: 2, color: Colors.white),
    bottom: TabBar(
        indicatorWeight: .2,
        dividerHeight: 8,
        labelPadding: EdgeInsets.zero,
        dividerColor: kBgColor,
        indicatorColor: Colors.transparent,
        tabs: myTabs(context, provider)),
    titleSpacing: 0,
    actions: [
      DropdownButton<Language>(
        underline: const SizedBox(),
        icon: const Icon(
          Icons.language,
          color: Colors.white,
        ),
        onChanged: (Language? language) async {
          if (language != null) {
            Locale _locale = await setLocale(language.languageCode);
            MyApp.setLocale(context, _locale);
          }
        },
        items: Language.languageList()
            .map<DropdownMenuItem<Language>>(
              (e) => DropdownMenuItem<Language>(
                value: e,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      e.flag,
                      style: TextStyle(
                          fontSize: 2.5 * SizeConfigure.textMultiplier!),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      e.name,
                      style: kTextStyle.copyWith(color: Colors.black54),
                    )
                  ],
                ),
              ),
            )
            .toList(),
      ),
      customSpacer(width: SizeConfigure.widthMultiplier! * 2)
    ],
  );
}

List<Widget> myTabs(
  BuildContext context,
  ExpanseClaimProvider provider,
) {
  return [
    GestureDetector(
      onTap: () async {
        provider.isIndividual = true;
        provider.clearRequestDetails();
        provider.rebuild();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.only(bottom: 5),
        height: 50,
        width: MediaQuery.of(context).size.width / 2,
        decoration: BoxDecoration(
            color: provider.isIndividual
                ? kBgColor
                : CommonServices().getThemeColor(),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Align(
            alignment: Alignment.bottomCenter,
            child: customText(
              translation(context).individual,
              fontWeight: FontWeight.w700,
              fontSize: 2,
              color: provider.isIndividual
                  ? CommonServices().getThemeColor()
                  : kBgColor,
            )),
      ),
    ),
    GestureDetector(
      onTap: () {
        provider.isIndividual = false;
        provider.clearRequestDetails();
        provider.rebuild();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.only(bottom: 5),
        height: 50,
        width: MediaQuery.of(context).size.width / 2,
        decoration: BoxDecoration(
            color: provider.isIndividual
                ? CommonServices().getThemeColor()
                : kBgColor,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Align(
            alignment: Alignment.bottomCenter,
            child: customText(
              translation(context).onBehalf,
              fontWeight: FontWeight.w700,
              fontSize: 2,
              color: provider.isIndividual
                  ? kBgColor
                  : CommonServices().getThemeColor(),
            )),
      ),
    ),
  ];
}

void myAddClaimBottomSheet(
  BuildContext context,
  ExpanseClaimProvider provider, {
  bool isToEdit = false,
  Map? claimDetails,
  int? claimIndex,
}) {
  TextEditingController remarksController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  provider.attachments = [];
  provider.selectedClaimType = null;
  TextEditingController conversionRateController =
      TextEditingController(text: "0");
  if (isToEdit) {
    provider.selectedClaimType = claimDetails!["claimType"];
    remarksController.text = claimDetails["remarks"];
    amountController.text = claimDetails["amount"].toString();
    conversionRateController.text = provider.selectedCurrency != null
        ? "${claimDetails["amount"] * provider.selectedCurrency?.special}"
        : "0";
    claimDetails["attachments"].forEach((e) {
      provider.attachments.add(e);
    });
  }

  showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer<ExpanseClaimProvider>(
            builder: (context, provider, child) {
          return InkWell(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Container(
              padding: EdgeInsets.all(20),
              width: SizeConfigure.widthMultiplier! * 100,
              height: MediaQuery.of(context).viewInsets.bottom != 0
                  ? SizeConfigure.heightMultiplier! * 70
                  : 450,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText(translation(context).claimDetails,
                        fontSize: 2, fontWeight: FontWeight.bold),
                    customSpacer(height: SizeConfigure.heightMultiplier! * 2),
                    typeHead(
                        context,
                        claimTypeController,
                        (context, var suggestion) {
                          return ListTile(
                              title: Text(
                            suggestion.name.toString(),
                            style: kTextStyle.copyWith(
                                fontSize: 1.8 * SizeConfigure.textMultiplier!),
                          ));
                        },
                        (dynamic suggestion) {
                          claimTypeController.text = suggestion.name;
                          provider.selectedClaimType = suggestion;
                          provider.rebuild();
                        },
                        (search) {
                          return provider.claimTypes
                              .where((element) => element.name
                                  .toUpperCase()
                                  .contains(search.toUpperCase()))
                              .toList();
                        },
                        translation(context).selectClaimTypeHint,
                        translation(context).selectClaimType,
                        suggestionsController6,
                        () {
                          claimTypeController.clear();
                          provider.selectedCurrency = null;
                          provider.rebuild();
                        },
                        null,
                        null,
                        null,
                        null),
                    customSpacer(height: SizeConfigure.heightMultiplier! * 2),
                    Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: myTextfield(translation(context).amount,
                                controller: amountController,
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                              if (provider.selectedCurrency != null) {
                                if (double.tryParse(amountController.text) ==
                                    null) {
                                  showToastMsg(context, "Invalid Amount");
                                } else {
                                  double amount =
                                      double.parse(amountController.text);
                                  conversionRateController.text =
                                      "${amount * provider.selectedCurrency!.special}";
                                }
                              } else {
                                showToastMsg(
                                  context,
                                  "Select a Currency",
                                );
                              }
                            })),
                        customSpacer(width: SizeConfigure.widthMultiplier! * 2),
                        Expanded(
                            flex: 1,
                            child: myTextfield(
                                translation(context).conversationRate,
                                controller: conversionRateController,
                                readOnly: true))
                      ],
                    ),
                    customSpacer(height: SizeConfigure.heightMultiplier! * 2),
                    myTextfield(translation(context).remarks,
                        controller: remarksController),
                    customSpacer(height: SizeConfigure.heightMultiplier! * 1.5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        customText(translation(context).attachments,
                            fontSize: 2, fontWeight: FontWeight.w600),
                        Row(
                          children: [
                            IconButton(
                                onPressed: () async {
                                  final ImagePicker picker = ImagePicker();
                                  final XFile? image = await picker.pickImage(
                                      source: ImageSource.camera);
                                  if (image != null) {
                                    provider.attachments.add(image);
                                    provider.rebuild();
                                  }
                                },
                                icon: const Icon(Icons.camera)),
                            IconButton(
                                onPressed: () async {
                                  final ImagePicker picker = ImagePicker();
                                  final List<XFile> images =
                                      await picker.pickMultiImage();

                                  provider.attachments = images;
                                  provider.rebuild();
                                },
                                icon: const Icon(Icons.image)),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      width: SizeConfigure.widthMultiplier! * 100,
                      height: provider.attachments.length * 50,
                      child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: provider.attachments.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.all(5),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10))),
                              height: 40,
                              width: SizeConfigure.widthMultiplier! * 100,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  customText(provider.attachments[index].name,
                                      maxLength: 25),
                                  InkWell(
                                      onTap: () {
                                        provider.attachments.removeAt(index);
                                        provider.rebuild();
                                      },
                                      child: const Icon(
                                        Icons.cancel,
                                        size: 15,
                                      ))
                                ],
                              ),
                            );
                          }),
                    ),
                    customSpacer(height: SizeConfigure.heightMultiplier! * 1.5),
                    ButtonGlobal(
                      buttontext: isToEdit
                          ? translation(context).update
                          : translation(context).submit,
                      onPressed: () {
                        if (provider.selectedClaimType == null) {
                          showToastMsg(
                            context,
                            "please select claim type",
                          );
                        } else if (amountController.text.isEmpty) {
                          showToastMsg(
                            context,
                            "please enter amount",
                          );
                        } else if (double.tryParse(amountController.text) ==
                            null) {
                          showToastMsg(
                            context,
                            "please enter a valid amount",
                          );
                        } else if (provider.attachments.isEmpty) {
                          showToastMsg(
                            context,
                            "please select attachment",
                          );
                        } else {
                          Map newClaim = {
                            "claimType": provider.selectedClaimType,
                            "amount": double.parse(amountController.text),
                            "remarks": remarksController.text,
                            "attachments": provider.attachments,
                          };
                          if (isToEdit) {
                            claims[claimIndex!] = newClaim;
                          } else {
                            claims.add(newClaim);
                          }
                          Navigator.pop(context);
                          provider.rebuild();
                        }
                      },
                      buttonDecoration: const BoxDecoration(
                          color: kMainColor,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      });
}

Slidable myClaimDetailsWidget(
  int index,
  ExpanseClaimProvider provider,
  Map<dynamic, dynamic> claimDetails,
  BuildContext context,
) {
  return Slidable(
    endActionPane: ActionPane(
      extentRatio: .55,
      motion: const DrawerMotion(),
      children: [
        SlidableAction(
          backgroundColor: kBgColor,
          foregroundColor: Colors.black,
          icon: Icons.delete,
          label: translation(context).delete,
          onPressed: (BuildContext context) {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: customText(translation(context).deleteItem),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(translation(context).cancel)),
                      TextButton(
                          onPressed: () {
                            claims.removeAt(index);
                            Navigator.pop(context);
                            provider.rebuild();
                          },
                          child: Text(translation(context).ok))
                    ],
                  );
                });
          },
        ),
        SlidableAction(
          backgroundColor: kBgColor,
          key: UniqueKey(),
          foregroundColor: Colors.black,
          icon: Icons.edit,
          label: translation(context).edit,
          onPressed: (BuildContext context) {
            myAddClaimBottomSheet(
              context,
              provider,
              claimDetails: claimDetails,
              isToEdit: true,
              claimIndex: index,
            );
          },
        ),
      ],
    ),
    child: Container(
      width: SizeConfigure.widthMultiplier! * 100,
      margin: const EdgeInsets.all(1),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.all(5),
            height: SizeConfigure.widthMultiplier! * 13,
            width: SizeConfigure.widthMultiplier! * 13,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            child: Center(
              child: Icon(Icons.token),
            ),
          ),
          customSpacer(width: SizeConfigure.widthMultiplier! * 3),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: SizeConfigure.widthMultiplier! * 40,
                      child: customText(
                        claimDetails["claimType"].name,
                        fontWeight: FontWeight.bold,
                        fontSize: 1.5,
                      ),
                    ),
                    customText("₹${claimDetails["amount"]}",
                        fontWeight: FontWeight.bold,
                        maxLength: 10,
                        color: kMainColor)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: customText(claimDetails["remarks"],
                          fontSize: 1.5,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w700),
                    ),
                    myViewAllocationWidget(context, provider)
                  ],
                )
              ],
            ),
          )
        ],
      ),
    ),
  );
}

InkWell myViewAllocationWidget(
    BuildContext context, ExpanseClaimProvider provider) {
  return InkWell(
    onTap: () {
      provider.expandedCostAllocationItem = -1;
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: const ContinuousRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              insetPadding: EdgeInsets.zero,
              contentPadding: const EdgeInsets.all(20),
              actionsPadding: const EdgeInsets.all(5),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText(translation(context).costCenterAllocation,
                      fontWeight: FontWeight.bold, fontSize: 2),
                  customSpacer(height: SizeConfigure.heightMultiplier! * 1),
                  customText(
                      "${translation(context).claimType} : ${provider.selectedRequestType ?? "none"}",
                      fontSize: 1.2),
                ],
              ),
              content: Consumer<ExpanseClaimProvider>(
                  builder: (context, provider, child) {
                return SizedBox(
                  height: SizeConfigure.widthMultiplier! * 100 - 80,
                  width: SizeConfigure.widthMultiplier! * 100 - 80,
                  child: ListView.builder(
                      itemCount: 13,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.all(3),
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            child: ExpansionTile(
                              key: UniqueKey(),
                              onExpansionChanged: (value) {
                                if (value) {
                                  provider.expandedCostAllocationItem = index;
                                  provider.rebuild();
                                }
                              },
                              initiallyExpanded:
                                  provider.expandedCostAllocationItem == index,
                              backgroundColor: Colors.grey[200],
                              collapsedBackgroundColor: Colors.grey[200],
                              shape: const Border(),
                              leading: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10))),
                                padding: const EdgeInsets.all(5),
                                height: SizeConfigure.widthMultiplier! * 12,
                                width: SizeConfigure.widthMultiplier! * 12,
                                child: Center(
                                  child: customText("100%",
                                      fontSize: 1.2,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: customText("Muhammed faris kk",
                                  fontWeight: FontWeight.bold),
                              subtitle: customText(
                                "Cost Center Amount : 1000",
                                fontSize: 1.2,
                              ),
                              childrenPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              expandedAlignment: Alignment.centerLeft,
                              expandedCrossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                myCostAllocationWidget("T1", "FIN/HRD/ADMIN"),
                                myCostAllocationWidget("T2", "Not Applicable"),
                                myCostAllocationWidget(
                                    "T3", "Functional expanse"),
                                myCostAllocationWidget("T4", "Finance"),
                                myCostAllocationWidget(
                                    "Cost Center (%)", "100%"),
                              ],
                            ),
                          ),
                        );
                      }),
                );
              }),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(translation(context).ok)),
              ],
            );
          });
    },
    child: customText(translation(context).viewAllocation,
        fontSize: 1.3, color: const Color.fromARGB(255, 122, 203, 240)),
  );
}

myCostAllocationWidget(String title, String value) {
  return Container(
    padding: const EdgeInsets.all(2),
    child: customText("$title : $value",
        fontWeight: FontWeight.w700,
        color: Colors.grey[600],
        fontSize: 1.3,
        textOverflow: TextOverflow.visible),
  );
}
