import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dots/Screens/TAS/Worklog/my_works_screen.dart';
import 'package:dots/classes/commonFunctions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:dots/classes/commonWidgets.dart';
import 'package:dots/models/worklog_attachment_model.dart';
import 'package:dots/provider/worklog_common_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../../SizeConfigure.dart';
import '../../../classes/language.dart';
import '../../../classes/language_constants.dart';
import '../../../constant.dart';
import '../../../main.dart';
import '../../../provider/worklog_my_works_provider.dart';
import '../../../provider/worklog_sub_works_provider.dart';
import '../../../provider/worklog_provider.dart';
import '../../../services/services.dart';
import 'add_sub_work_screen.dart';
import 'add_work_screen.dart';
import 'my_sub_works_screen.dart';
import 'worklog_screen.dart';

InkWell myWorksTile(
  BuildContext context,
  int index,
  Map workDetails,
  WorklogMyWorksProvider provider,
  AppLocalizations language,
  StateSetter setState, {
  required empImg,
  required empName,
  required empemail,
}) {
  return InkWell(
    onTap: () {
      FocusScope.of(context).requestFocus(FocusNode());
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WorklogScreen(
                    workId: workDetails["WORKID"],
                    workDetailsIndex: index,
                  )));
    },
    child: Slidable(
      endActionPane: ActionPane(
        extentRatio: .55,
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            backgroundColor: Color.fromARGB(255, 238, 237, 242),
            foregroundColor: Colors.black,
            icon: Icons.delete,
            label: translation(context).delete,
            onPressed: (BuildContext _) async {
              bool shouldDelete = false;
              await showDialog(
                  context: context,
                  builder: (ctx) {
                    return AlertDialog(
                      title: customText(
                          "${language.delete} ${workDetails["TASK_NAME"] ?? ""} ?",
                          fontSize: 2.5,
                          textOverflow: TextOverflow.visible),
                      content: customText(language.deleteWorkDialog,
                          textOverflow: TextOverflow.visible),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: customText(language.cancel)),
                        TextButton(
                            onPressed: () {
                              shouldDelete = true;
                              Navigator.pop(ctx);
                            },
                            child: customText(language.ok))
                      ],
                    );
                  });
              if (shouldDelete) {
                provider.isLoading = true;

                provider.rebuild();

                await worklogDeleteWork(workDetails["WORKID"], context);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyWorksScreen(
                            empName: empName,
                            empemail: empemail,
                            empImg: empImg)));
              }
            },
          ),
          SlidableAction(
            key: UniqueKey(),
            backgroundColor: Color.fromARGB(255, 238, 237, 242),
            foregroundColor: Colors.black,
            icon: Icons.edit,
            label: translation(context).edit,
            onPressed: (BuildContext context) {
              provider.isLoading = true;
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddWorkScreen(
                            empImg: empImg,
                            empName: empName,
                            empemail: empemail,
                            workId: workDetails["WORKID"],
                            isToEdit: true,
                            workToEdit: workDetails,
                          )));
            },
          ),
        ],
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[100]!),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/designation.png",
                          height: 30,
                          width: 30,
                        ),
                        customSpacer(width: 10),
                        Expanded(
                          child: customText(
                              "#${workDetails["WORKID"]}-${workDetails["TASK_NAME"] ?? ""}",
                              fontSize: 2,
                              fontWeight: FontWeight.w700,
                              color: kMainColor),
                        ),
                        Icon(Icons.arrow_forward_ios)
                      ],
                    ),
                    customSpacer(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: Row(
                            children: [
                              Icon(
                                Icons.alarm,
                                size: 16,
                              ),
                              customSpacer(width: 5),
                              customText(
                                workDetails["WORK_STATUS"]
                                        .replaceAll("_", " ") ??
                                    "",
                                fontSize: 1,
                                fontWeight: FontWeight.w800,
                              ),
                            ],
                          ),
                        ),
                        customSpacer(width: SizeConfigure.widthMultiplier! * 2),
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: getTextColor(getPriorityInString(
                                  workDetails["PRIORITY_LOW"],
                                  workDetails["PRIORITY_MID"],
                                  workDetails["PRIORITY_HIGH"],
                                  context: context)),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: Row(
                            children: [
                              Icon(
                                Icons.flag,
                                size: 16,
                              ),
                              customSpacer(width: 5),
                              customText(
                                  "${getPriorityInString(workDetails["PRIORITY_LOW"], workDetails["PRIORITY_MID"], workDetails["PRIORITY_HIGH"], context: context)} Priority",
                                  fontSize: 1.2,
                                  fontWeight: FontWeight.bold)
                            ],
                          ),
                        ),
                        customSpacer(width: SizeConfigure.widthMultiplier! * 2),
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: Row(
                            children: [
                              Icon(
                                Icons.alarm,
                                size: 16,
                              ),
                              customSpacer(width: 5),
                              customText(
                                workDetails["WORK_TYPE"]
                                        ?.replaceAll("_", " ") ??
                                    "",
                                fontSize: 1,
                                fontWeight: FontWeight.w800,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    customSpacer(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            color: kMainColor,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            backgroundColor: Colors.grey[200],
                            value: workDetails["PROGRESS"] / 100,
                          ),
                        ),
                        customSpacer(width: 10),
                        Localizations.override(
                          context: context,
                          locale: Locale("en"),
                          child: customText("${workDetails["PROGRESS"]} %",
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: kMainColor,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    customText(
                        "${translation(context).dueDate} : ${toDDMMMYYY(workDetails["END_DATE"])}",
                        fontSize: 1.2,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    Row(
                      children: [
                        customText(
                            translation(context).assignedBY +
                                " : " +
                                workDetails["ASSIGNED_BY"],
                            fontSize: 1.2,
                            fontWeight: FontWeight.bold,
                            maxLength: 40,
                            color: Colors.white),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    ),
  );
}

Row myPriorityWidget(
    String text, String value, WorklogMyWorksProvider provider) {
  return Row(
    children: [
      Checkbox(
          value: provider.selectedPriority == value ? true : false,
          onChanged: (val) {
            provider.selectedPriority = value;
            provider.rebuild();
          }),
      customText(text)
    ],
  );
}

Widget mySortByDateRangeWidget(
    WorklogMyWorksProvider provider, BuildContext context) {
  return StatefulBuilder(builder: (context, setState) {
    return Container(
      height: 50,
      child: provider.dateRangeToSort.isEmpty
          ? InkWell(
              onTap: () async {
                var res = await showCalendarDatePicker2Dialog(
                    context: context,
                    config: CalendarDatePicker2WithActionButtonsConfig(
                      calendarType: CalendarDatePicker2Type.range,
                    ),
                    dialogSize: Size(SizeConfigure.widthMultiplier! * 90,
                        SizeConfigure.widthMultiplier! * 90));
                if (res != null && res.isNotEmpty) {
                  setState(
                    () {
                      provider.dateRangeToSort = res;
                    },
                  );
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(color: Colors.grey[100]),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    customText(translation(context).selectDates),
                    customSpacer(width: 5),
                    const Icon(
                      Icons.calendar_month,
                      size: 20,
                    ),
                  ],
                ),
              ))
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                customText(
                    "${getDate(provider.dateRangeToSort.first!)} ${translation(context).to} ${getDate(provider.dateRangeToSort.last!)}",
                    fontSize: 1.5),
                customSpacer(width: SizeConfigure.widthMultiplier! * 2),
                InkWell(
                    onTap: () {
                      setState(
                        () {
                          provider.dateRangeToSort.clear();
                        },
                      );
                    },
                    child: const Icon(
                      Icons.cancel,
                      size: 20,
                    ))
              ],
            ),
    );
  });
}

SizedBox mySortDropDown(
    List items, Function function, String hint, String? selectedValue) {
  return SizedBox(
    height: 50,
    child: DropdownButtonFormField(
        hint: customText(hint, color: Colors.grey),
        items: items
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: customText(e.replaceAll("_", "  ").toUpperCase(),
                      fontSize: 1.5, color: Colors.black),
                ))
            .toList(),
        onChanged: (value) {
          function(value);
        }),
  );
}

Row myDateWidget(BuildContext context, WorklogMyWorksProvider provider,
    AppLocalizations language) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      InkWell(
        onTap: () async {
          FocusScope.of(context).requestFocus(FocusNode());
          provider.endDate = null;
          var res = await showCalendarDatePicker2Dialog(
              context: context,
              config: CalendarDatePicker2WithActionButtonsConfig(
                  firstDate: DateTime.now()),
              dialogSize: Size(
                  MediaQuery.of(context).size.width -
                      SizeConfigure.widthMultiplier! * 15,
                  MediaQuery.of(context).size.width -
                      SizeConfigure.widthMultiplier! * 15));
          if (res != null) {
            provider.startDate = res[0];
            provider.rebuild();
          }
        },
        child: Stack(
          children: [
            SizedBox(
              height: SizeConfigure.widthMultiplier! * 12,
              width: SizeConfigure.widthMultiplier! * 35,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: SizeConfigure.widthMultiplier! * 10.6,
                  width: SizeConfigure.widthMultiplier! * 42,
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 241, 241, 241),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        customText(
                            provider.startDate != null
                                ? getDate(provider.startDate!)
                                : "DD/MM/YYYY",
                            fontSize: 1.8),
                        customSpacer(
                            width: SizeConfigure.widthMultiplier! * 1.5),
                        provider.startDate != null
                            ? const Icon(
                                Icons.cancel,
                                size: 18,
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            customText("   ${language.startDate}",
                fontSize: 1, fontWeight: FontWeight.w700),
          ],
        ),
      ),
      customText("--", fontSize: 1.8, fontWeight: FontWeight.w500),
      InkWell(
        onTap: () async {
          FocusScope.of(context).requestFocus(FocusNode());
          if (provider.startDate == null) {
            showToastMsg(context, translation(context).pleaseSelectStartDate);
          } else {
            var res = await showCalendarDatePicker2Dialog(
                context: context,
                config: CalendarDatePicker2WithActionButtonsConfig(
                    firstDate: provider.startDate),
                dialogSize: Size(
                    MediaQuery.of(context).size.width -
                        SizeConfigure.widthMultiplier! * 15,
                    MediaQuery.of(context).size.width -
                        SizeConfigure.widthMultiplier! * 15));
            if (res != null) {
              provider.endDate = res[0];
              provider.rebuild();
            }
          }
        },
        child: Stack(
          children: [
            SizedBox(
              height: SizeConfigure.widthMultiplier! * 12,
              width: SizeConfigure.widthMultiplier! * 35,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: SizeConfigure.widthMultiplier! * 10.6,
                  width: SizeConfigure.widthMultiplier! * 42,
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 241, 241, 241),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        customText(
                            provider.endDate != null
                                ? getDate(provider.endDate!)
                                : "DD/MM/YYYY",
                            fontSize: 1.8),
                        customSpacer(
                            width: SizeConfigure.widthMultiplier! * 1.5),
                        provider.endDate != null
                            ? const Icon(
                                Icons.cancel,
                                size: 18,
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            customText("   ${language.dueDate}",
                fontSize: 1, fontWeight: FontWeight.w700),
          ],
        ),
      ),
    ],
  );
}

SizedBox myClientdropDown(BuildContext context, WorklogMyWorksProvider provider,
    AppLocalizations language) {
  return SizedBox(
      width: SizeConfigure.widthMultiplier! * 42,
      height: SizeConfigure.widthMultiplier! * 14,
      child: myTypeHeadDropDown(
          items: Provider.of<WorklogCommonProvider>(context, listen: false)
              .clients,
          hintText: language.client,
          labelText: language.client,
          value: provider.client,
          onSelected: (asiignedBy) {
            provider.client = asiignedBy;
            provider.rebuild();
          },
          onCancel: () {
            provider.client = null;

            provider.rebuild();
          }));
}

Container myAssignedByDropDown(WorklogMyWorksProvider provider,
    AppLocalizations language, BuildContext context) {
  return Container(
    padding: const EdgeInsets.only(left: 5, right: 5),
    decoration: const BoxDecoration(
        color: Color.fromARGB(255, 241, 241, 241),
        borderRadius: BorderRadius.all(Radius.circular(25))),
    width: SizeConfigure.widthMultiplier! * 42,
    height: SizeConfigure.widthMultiplier! * 14,
    child: Row(
      children: [
        Image.asset(
          "assets/icons/user.png",
          height: 20,
          width: 20,
        ),
        const SizedBox(
          width: 5,
        ),
        Expanded(
            child: myTypeHeadDropDown(
                inputBorder: InputBorder.none,
                items:
                    Provider.of<WorklogCommonProvider>(context, listen: false)
                        .employees,
                hintText: language.employee,
                labelText: language.assignedBY,
                value: provider.assignedBy,
                onSelected: (asiignedBy) {
                  provider.assignedBy = asiignedBy;
                  provider.rebuild();
                },
                onCancel: () {
                  provider.assignedBy = null;

                  provider.rebuild();
                }))
      ],
    ),
  );
}

Row updateProgressWidget(BuildContext context, WorklogMyWorksProvider provider,
    AppLocalizations language) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      customText(language.progress,
          fontSize: 2,
          fontWeight: FontWeight.w500,
          color: const Color.fromARGB(255, 103, 100, 100)),
      SizedBox(
        width: MediaQuery.of(context).size.width -
            SizeConfigure.widthMultiplier! * 36,
        child: FlutterSlider(
          handler: FlutterSliderHandler(
              child: customText(
                  (provider.progressToUpdate).toInt().toString() + " %",
                  fontSize: 1,
                  fontWeight: FontWeight.bold)),
          min: 0,
          max: 100,
          trackBar: const FlutterSliderTrackBar(
              activeTrackBar: BoxDecoration(color: kMainColor)),
          values: [provider.progressToUpdate],
          onDragCompleted: (a, value, b) {
            provider.progressToUpdate = value;
            provider.rebuild();
          },
        ),
      ),
    ],
  );
}

SizedBox addWorkAttachFilesection(BuildContext context,
    WorklogMyWorksProvider provider, AppLocalizations language) {
  return SizedBox(
    height: 45,
    width: MediaQuery.of(context).size.width,
    child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: provider.attachments.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return InkWell(
              onTap: () async {
                var files = await FilePicker.platform.pickFiles(
                  allowMultiple: true,
                  type: FileType.custom,
                  allowedExtensions: ['jpg', 'pdf', '.csv', '.xlsx', '.xls'],
                );
                if (files != null) {
                  for (var file in files.files) {
                    if (file.size / 1024 > 400) {
                      showToastMsg(context,
                          "${file.name} ${translation(context).sizeIsGraterThan400KB}");
                      continue;
                    }
                    List<int> bytes = await File(file.path!).readAsBytes();
                    String img64 = base64Encode(bytes);
                    provider.attachments.add(
                        WorklogAttachments(name: file.name, base64: img64));
                  }
                  provider.rebuild();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                margin: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 237, 237, 237),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.add,
                      size: 15,
                      color: kMainColor,
                    ),
                    customSpacer(width: 5),
                    Text(
                      provider.attachments.isEmpty
                          ? language.attachFile
                          : language.add,
                    )
                  ],
                ),
              ),
            );
          }
          return InkWell(
            onTap: () {
              fileViewer(
                  context: context,
                  base64Image: provider.attachments[index - 1].base64);
            },
            child: Container(
              padding: const EdgeInsets.all(3),
              margin: const EdgeInsets.all(5),
              width: 200,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 237, 237, 237),
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(
                    Icons.attach_file_rounded,
                    size: 15,
                    color: kMainColor,
                  ),
                  customSpacer(width: SizeConfigure.widthMultiplier! * 1.5),
                  Localizations.override(
                    context: context,
                    locale: Locale("en"),
                    child: customText(provider.attachments[index - 1].name,
                        maxLength: 18, fontSize: 1.4),
                  ),
                  IconButton(
                      onPressed: () {
                        provider.attachments.removeAt(index - 1);
                        provider.rebuild();
                      },
                      icon: const Icon(
                        Icons.cancel,
                        size: 12,
                      ))
                ],
              ),
            ),
          );
        }),
  );
}

Row chartIndIcatorWidget(
    String text, Color color, double value, List chartValues) {
  String percentage = ((value / chartValues[4]).isNaN
          ? 0 * 100
          : (value / chartValues[4]) * 100)
      .toStringAsFixed(1);

  return Row(
    children: [
      Container(
        margin: EdgeInsets.all(5),
        height: SizeConfigure.widthMultiplier! * 3,
        width: SizeConfigure.widthMultiplier! * 3,
        decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(2))),
      ),
      customSpacer(width: 5),
      Text(
        text,
        style: GoogleFonts.archivo(
          fontSize: SizeConfigure.textMultiplier! * 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
      customSpacer(width: 10),
      customText("$percentage%",
          fontSize: 1.2, fontWeight: FontWeight.bold, color: kMainColor),
    ],
  );
}

PieChartSectionData chartData(Color color, double value, int index) {
  return PieChartSectionData(
      radius: 15,
      color: color,
      value: value,
      title: "",
      titleStyle: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white));
}

Visibility mySearchField(
    WorklogMyWorksProvider provider,
    BuildContext context,
    AppLocalizations language,
    TextEditingController controller,
    StateSetter setState) {
  return Visibility(
      visible: provider.isSearchEnabled,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        margin: EdgeInsets.only(bottom: 10),
        child: TextField(
            controller: controller,
            onChanged: (value) {
              setState(
                () {
                  provider.searchKeyword = value;
                },
              );
            },
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
                hintText: language.search,
                hintStyle: const TextStyle(color: Colors.grey),
                border: outlineInputBorder(),
                focusedBorder: outlineInputBorder(),
                enabledBorder: outlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(
                      () {
                        provider.isSearchEnabled = false;
                        provider.searchKeyword = "";

                        controller.clear();
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.cancel,
                    color: Colors.black,
                  ),
                ))),
      ));
}

Row myFilterAndSearchSection(
    WorklogMyWorksProvider provider,
    AppLocalizations language,
    BuildContext context,
    StateSetter setState,
    int activeWorkCount) {
  return Row(
    children: [
      customText(language.activeWorks,
          fontSize: 2, fontWeight: FontWeight.w700),
      customSpacer(width: 5),
      customText("($activeWorkCount)",
          fontWeight: FontWeight.bold,
          color: kMainColor,
          fontSize: 1.4,
          maxLength: 20),
      const Expanded(child: SizedBox()),
      IconButton(
          onPressed: () async {
            if (!provider.isFilterOn) {
              provider.isFilterOn = true;
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: customText(translation(context).filters,
                          fontSize: 1.8, fontWeight: FontWeight.bold),
                      content: Consumer<WorklogMyWorksProvider>(
                          builder: (context, provider, _) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                customText(translation(context).sort,
                                    fontSize: 1.7, color: Colors.grey),
                                mySortByDateRangeWidget(provider, context),
                              ],
                            ),
                            // Divider(),

                            mySortDropDown(
                                ["All", "INDIVIDUAL", "SUPPORT", "R&D"],
                                (String? value) {
                              provider.selectedTypeForSort = value!;
                            }, translation(context).type,
                                provider.selectedTypeForSort),
                            // Divider(),

                            mySortDropDown(["All", "Low", "Mid", "High"],
                                (String? value) {
                              provider.selectedPriorityForSort = value!;
                            }, translation(context).priority,
                                provider.selectedPriorityForSort),
                            // Divider(),

                            mySortDropDown(
                                ["All", "PENDING", "COMPLETED", "ON_HOLD"],
                                (String? value) {
                              provider.selectedStatusForSort = value!;
                            }, translation(context).status,
                                provider.selectedStatusForSort),
                          ],
                        );
                      }),
                      actions: [
                        TextButton(
                            onPressed: () {
                              setState(
                                () {
                                  provider.isFilterOn = false;
                                  provider.dateRangeToSort.clear();
                                  provider.selectedPriorityForSort = "All";
                                  provider.selectedStatusForSort = "All";
                                  provider.selectedTypeForSort = "All";
                                },
                              );
                              Navigator.pop(context);
                            },
                            child: Text(translation(context).cancel)),
                        TextButton(
                            onPressed: () {
                              setState(
                                () {},
                              );
                              Navigator.pop(context);
                            },
                            child: Text(translation(context).ok))
                      ],
                    );
                  });
            } else {
              setState(
                () {
                  provider.isFilterOn = false;
                  provider.dateRangeToSort.clear();
                  provider.selectedPriorityForSort = "All";
                  provider.selectedStatusForSort = "All";
                  provider.selectedTypeForSort = "All";
                },
              );
            }
          },
          icon: provider.isFilterOn
              ? const Icon(
                  Icons.cancel,
                  color: Colors.grey,
                )
              : const Icon(
                  Icons.filter_alt,
                  color: Colors.grey,
                )),
      InkWell(
        onTap: () {
          setState(
            () {
              provider.isSearchEnabled = true;
            },
          );
        },
        child: Container(
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
          decoration: const BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          height: SizeConfigure.widthMultiplier! * 7,
          child: const Icon(
            Icons.search,
            color: Colors.white,
          ),
        ),
      ),
      customSpacer(width: SizeConfigure.widthMultiplier! * 1.5)
    ],
  );
}

Widget myChartWidget(BuildContext context, WorklogMyWorksProvider provider,
    List chartValues, AppLocalizations language) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      color: Colors.white,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                padding: EdgeInsets.all(10),
                height: SizeConfigure.widthMultiplier! * 30,
                width: SizeConfigure.widthMultiplier! * 30,
                child: CircleAvatar(
                  backgroundColor: kMainColor.withOpacity(.1),
                  child: Stack(
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 10,
                          sections: [
                            chartData(const Color.fromARGB(255, 253, 201, 81),
                                chartValues[1], 1),
                            chartData(const Color.fromARGB(255, 88, 151, 231),
                                chartValues[2], 2),
                            chartData(const Color.fromARGB(255, 230, 79, 96),
                                chartValues[3], 3),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            customText(translation(context).total,
                                fontSize: 1.2, fontWeight: FontWeight.bold),
                            customText(chartValues[5].toInt().toString()),
                          ],
                        ),
                      )
                    ],
                  ),
                )),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            chartIndIcatorWidget(
                language.pending,
                const Color.fromARGB(255, 253, 201, 81),
                chartValues[1],
                chartValues),
            customSpacer(width: 5),
            chartIndIcatorWidget(
                language.onHold,
                const Color.fromARGB(255, 88, 151, 231),
                chartValues[2],
                chartValues),
            chartIndIcatorWidget(
                language.overdue,
                const Color.fromARGB(255, 230, 79, 96),
                chartValues[3],
                chartValues),
            customSpacer(height: 10),
            SizedBox(
              width: SizeConfigure.widthMultiplier! * 40,
              child: customText(
                  translation(context)
                      .workYetToComplete
                      .replaceAll("<value>", chartValues[1].toInt().toString()),
                  fontWeight: FontWeight.w700,
                  fontSize: 1.3,
                  textOverflow: TextOverflow.visible),
            )
          ],
        ),
        SizedBox()
      ],
    ),
  );
}

Localizations myPieChartDetailsWidget(String text, double value, Color color,
    IconData icon, BuildContext context) {
  return Localizations.override(
    context: context,
    locale: const Locale("en"),
    child: Container(
      padding: EdgeInsets.all(10),
      width: SizeConfigure.widthMultiplier! * 40,
      height: SizeConfigure.widthMultiplier! * 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(radiusCircular(10)),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              customText(text, fontSize: 1.6, fontWeight: FontWeight.bold),
              Icon(
                icon,
                size: 16,
                color: color,
              ),
            ],
          ),
          SizedBox(
            width: SizeConfigure.widthMultiplier! * 25,
            child: Text(
              value.toInt().toString(),
              overflow: TextOverflow.ellipsis,
              style: kTextStyle.copyWith(
                  fontWeight: FontWeight.bold, fontSize: 18),
            ),
          )
        ],
      ),
    ),
  );
}

Container myChartDetailsWidget(
    String text, IconData icon, double value, Color color) {
  return Container(
    padding: const EdgeInsets.all(5),
    margin: const EdgeInsets.all(2),
    width: SizeConfigure.widthMultiplier! * 16,
    height: 10,
    decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.all(Radius.circular(10))),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.black,
            ),
            customText(value.toInt().toString(),
                fontSize: 1.5, fontWeight: FontWeight.bold),
          ],
        ),
        customText(text,
            fontSize: 1, fontWeight: FontWeight.bold, color: Colors.grey[600])
      ],
    ),
  );
}

//worklog

SizedBox myAttachFilesection(BuildContext context, WorklogProvider provider,
    int workDetailsIndex, AppLocalizations language) {
  return SizedBox(
    height: 45,
    width: MediaQuery.of(context).size.width,
    child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: provider.attachments.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return InkWell(
              onTap: () async {
                var files = await FilePicker.platform.pickFiles(
                  allowMultiple: true,
                  type: FileType.custom,
                  allowedExtensions: ['jpg', 'pdf', '.csv', '.xlsx', '.xls'],
                );
                if (files != null) {
                  for (var file in files.files) {
                    if (file.size / 1024 > 400) {
                      showToastMsg(context,
                          "${file.name} ${translation(context).sizeIsGraterThan400KB}");
                      continue;
                    }
                    List<int> bytes = await File(file.path!).readAsBytes();
                    String img64 = base64Encode(bytes);
                    provider.attachments.add(WorklogAttachments.fromJson(
                        {"name": file.name, "path": img64}));
                  }

                  provider.rebuild();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 237, 237, 237),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.add,
                      size: 15,
                      color: kMainColor,
                    ),
                    customSpacer(width: SizeConfigure.widthMultiplier! * 1.5),
                    provider.attachments.isEmpty
                        ? Text(
                            language.attachFile,
                          )
                        : Text(language.add)
                  ],
                ),
              ),
            );
          }
          return InkWell(
            onTap: () {
              fileViewer(
                  context: context,
                  base64Image: provider.attachments[index - 1].base64);
            },
            child: Container(
              padding: const EdgeInsets.all(3),
              margin: const EdgeInsets.all(5),
              width: 200,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 237, 237, 237),
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Icon(
                    Icons.attach_file_rounded,
                    size: 15,
                    color: kMainColor,
                  ),
                  customSpacer(width: SizeConfigure.widthMultiplier! * 1.5),
                  Localizations.override(
                    context: context,
                    locale: Locale("en"),
                    child: customText(provider.attachments[index - 1].name,
                        maxLength: 18, fontSize: 1.4),
                  ),
                  IconButton(
                      onPressed: () {
                        provider.attachments.removeAt(index - 1);
                        provider.rebuild();
                      },
                      icon: const Icon(
                        Icons.cancel,
                        size: 12,
                      ))
                ],
              ),
            ),
          );
        }),
  );
}

Row myCircularProgressWidget(
    BuildContext context, Map workDetails, AppLocalizations language) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      SizedBox(
          height: SizeConfigure.widthMultiplier! * 40,
          width: SizeConfigure.widthMultiplier! * 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: SizeConfigure.widthMultiplier! * 30,
                width: SizeConfigure.widthMultiplier! * 30,
                child: CircularProgressIndicator(
                  backgroundColor: const Color.fromARGB(255, 232, 228, 228),
                  strokeWidth: 22,
                  strokeCap: StrokeCap.round,
                  color: kMainColor,
                  value: workDetails["PROGRESS"] / 100,
                ),
              ),
              customText("${workDetails["PROGRESS"]}%",
                  fontSize: 1.1, fontWeight: FontWeight.bold)
            ],
          )),
      customSpacer(width: SizeConfigure.widthMultiplier! * 4),
      SizedBox(
        width: SizeConfigure.widthMultiplier! * 35,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customText(language.assignedBY,
                fontSize: 1, color: Colors.grey, fontWeight: FontWeight.w700),
            customText(
              workDetails["ASSIGNED_BY"].replaceAll("_", " ").split("-").last,
              fontSize: 1.4,
            ),
            customText(language.workGroups,
                fontSize: 1, color: Colors.grey, fontWeight: FontWeight.w700),
            customText(
              workDetails["WORK_GROUP"].replaceAll("_", " ").split("-").last,
              fontSize: 1.4,
            ),
            Visibility(
              visible: workDetails["DEPENDENCIES"].isNotEmpty,
              child: Column(
                children: [
                  customText(language.dependencies,
                      fontSize: 1,
                      color: Colors.grey,
                      fontWeight: FontWeight.w700),
                ],
              ),
            ),
            Text(
              workDetails["DEPENDENCIES"],
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      )
    ],
  );
}

Visibility myWorkAttacmentsDisplayWidget(
    List attachments, BuildContext context) {
  return Visibility(
    visible: attachments.isNotEmpty,
    child: SizedBox(
      height: SizeConfigure.widthMultiplier! * 9,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: attachments.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                fileViewer(
                    context: context,
                    base64Image: attachments[index]["ATTACHMENT_FILE"]);
              },
              child: Container(
                padding: const EdgeInsets.all(3),
                margin: const EdgeInsets.all(5),
                height: 35,
                width: SizeConfigure.widthMultiplier! * 30,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 237, 237, 237),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.attach_file_rounded,
                      size: 15,
                      color: kMainColor,
                    ),
                    customSpacer(width: SizeConfigure.widthMultiplier! * 1.5),
                    Localizations.override(
                      context: context,
                      locale: Locale("en"),
                      child: customText(attachments[index]["IMAGE_NAME"] ?? "",
                          maxLength: 18, fontSize: 1),
                    ),
                  ],
                ),
              ),
            );
          }),
    ),
  );
}

Row myStatusSection(WorklogProvider provider, BuildContext context,
    AppLocalizations language, List employees, List statusTypes) {
  return Row(
    children: [
      Expanded(
        child: SizedBox(
          height: 60,
          child: DropdownButtonFormField(
              icon: Icon(
                Icons.arrow_drop_down,
                size: 20,
              ),
              style: TextStyle(fontWeight: FontWeight.w600),
              value: provider.selectedStatus,
              dropdownColor: Colors.white,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  hintText: translation(context).status,
                  labelText: translation(context).status),
              items: statusTypes
                  .map((e) => DropdownMenuItem(
                        onTap: () {
                          provider.selectedStatus = e["id"];
                          if (e["WORK_STATUS"] == "ASSIGN TO") {
                            provider.isStatusAssignTo = true;
                          } else {
                            provider.isStatusAssignTo = false;
                            provider.assignTo = null;
                          }
                          provider.rebuild();
                        },
                        value: e["id"],
                        child: customText(
                            e["WORK_STATUS"].toString().replaceAll("_", " "),
                            fontWeight: FontWeight.normal),
                      ))
                  .toList(),
              onChanged: (value) {}),
        ),
      ),
      customSpacer(
          width: provider.isStatusAssignTo
              ? SizeConfigure.widthMultiplier! * 2
              : 0),
      Visibility(
        visible: provider.isStatusAssignTo,
        child: Expanded(
          child: Container(
              child: myTypeHeadDropDown(
                  items: employees.map((e) {
                    return "${e["slno"]}-${e["employee_name"]}";
                  }).toList(),
                  hintText: language.employee,
                  labelText: language.assignedBY,
                  value: provider.assignTo,
                  onSelected: (assignedBy) {
                    provider.assignTo = assignedBy;
                    provider.rebuild();
                  },
                  onCancel: () {
                    provider.assignTo = null;

                    provider.rebuild();
                  })),
        ),
      ),
    ],
  );
}

Container myClientAndDueDateSection(BuildContext context,
    WorklogProvider provider, Map workDetails, AppLocalizations language) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
        color: const Color.fromARGB(255, 247, 244, 244),
        borderRadius: BorderRadius.all(Radius.circular(10))),
    child: Row(
      children: [
        SizedBox(
          width: SizeConfigure.widthMultiplier! * 38,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: SizeConfigure.widthMultiplier! * 10.4,
                width: SizeConfigure.widthMultiplier! * 10.4,
                decoration: const BoxDecoration(
                    color: kMainColor,
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                child: Center(
                  child: Image.asset(
                    "assets/icons/user.png",
                    color: Colors.white,
                    width: SizeConfigure.widthMultiplier! * 6,
                    height: SizeConfigure.widthMultiplier! * 4,
                  ),
                ),
              ),
              customSpacer(width: SizeConfigure.widthMultiplier! * 1.5),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customSpacer(height: SizeConfigure.widthMultiplier! * 1),
                  customText(language.client,
                      color: Colors.grey, fontSize: 1.0),
                  SizedBox(
                    width: SizeConfigure.widthMultiplier! * 25,
                    child: customText(
                        workDetails["CLIENT_NAME"]
                            .replaceAll("_", " ")
                            .split("-")
                            .last,
                        fontSize: 1.2),
                  ),
                  customSpacer(height: SizeConfigure.widthMultiplier! * 1),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: SizeConfigure.widthMultiplier! * .3,
          height: SizeConfigure.widthMultiplier! * 12,
          color: Colors.grey,
        ),
        Container(
          padding: const EdgeInsets.only(left: 10, right: 10),
          width: SizeConfigure.widthMultiplier! * 35,
          child: Row(
            children: [
              Container(
                height: SizeConfigure.widthMultiplier! * 10.4,
                width: SizeConfigure.widthMultiplier! * 10.4,
                decoration: const BoxDecoration(
                    color: kMainColor,
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                child: Center(
                  child: Image.asset(
                    "assets/icons/calendar.png",
                    color: Colors.white,
                    width: SizeConfigure.widthMultiplier! * 5,
                    height: SizeConfigure.widthMultiplier! * 5,
                  ),
                ),
              ),
              customSpacer(width: SizeConfigure.widthMultiplier! * 1.5),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customSpacer(height: SizeConfigure.widthMultiplier! * 1),
                  customText(language.dueDate, color: Colors.grey, fontSize: 1),
                  customSpacer(height: SizeConfigure.widthMultiplier! * .2),
                  customText(toDDMMMYYY(workDetails["DUE_DATE"]),
                      fontSize: 1.2),
                  customSpacer(height: SizeConfigure.widthMultiplier! * .7),
                  customText(
                      getDateDiffrence(workDetails["DUE_DATE"]) > 0
                          ? "${getDateDiffrence(workDetails["DUE_DATE"])} ${language.daysLeft}"
                          : language.overdue,
                      fontSize: .9,
                      color: Colors.red)
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

AppBar myAppBar(WorklogProvider provider, BuildContext context, Map workDetails,
    String workId, AppLocalizations language) {
  return AppBar(
    elevation: 0,
    backgroundColor: kMainColor,
    leading: IconButton(
      icon: const Icon(
        Icons.arrow_back_ios,
        color: Colors.white,
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
    title: customText("#$workId", fontSize: 2.1, color: Colors.white),
    actions: [
      TextButton.icon(
        icon: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MySubWorksScreen(
                        workId: workId,
                        work: workDetails,
                      )));
        },
        label: customText(language.dailyLog, color: Colors.white),
      ),
      customSpacer(width: SizeConfigure.widthMultiplier! * 2),
      myLanguageButton(context),
      customSpacer(width: SizeConfigure.widthMultiplier! * 3),
    ],
  );
}

Color getTextColor(String text) {
  switch (text) {
    case "Low":
      return Colors.yellow;
    case "Mid":
      return Colors.orange;
    case "High":
      return Colors.red;
    case "COMPLETED":
      return const Color.fromARGB(255, 153, 250, 157);
    case "PENDING":
      return const Color.fromARGB(255, 254, 243, 165);
    case "ON_HOLD":
      return const Color.fromARGB(255, 164, 213, 253);
    default:
      return Colors.black;
  }
}

//sub work
FlutterSlider progressSliderWidget(
    Map workDetails, WorklogSubWorkProvider provider) {
  return FlutterSlider(
    handler: FlutterSliderHandler(
        child: customText(
            (provider.newProgress ?? workDetails["PROGRESS"].toDouble() ?? 0)
                    .toInt()
                    .toString() +
                " %",
            textDirection: TextDirection.ltr,
            fontSize: 1,
            fontWeight: FontWeight.bold)),
    trackBar: const FlutterSliderTrackBar(
        activeTrackBar: BoxDecoration(color: kMainColor)),
    values: [provider.newProgress ?? workDetails["PROGRESS"].toDouble()],
    max: 100.1,
    min: workDetails["PROGRESS"].toDouble(),
    onDragCompleted: (a, value, b) {
      provider.newProgress = value;
      provider.rebuild();
    },
  );
}

SizedBox subWorksAttachFilesection(BuildContext context,
    WorklogSubWorkProvider provider, AppLocalizations language) {
  return SizedBox(
    height: 45,
    width: MediaQuery.of(context).size.width,
    child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: provider.subWorkSttachments.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return InkWell(
              onTap: () async {
                var files = await FilePicker.platform.pickFiles(
                  allowMultiple: true,
                  type: FileType.custom,
                  allowedExtensions: ['jpg', 'pdf', '.csv', '.xlsx', '.xls'],
                );
                if (files != null) {
                  for (var file in files.files) {
                    if (file.size / 1024 > 400) {
                      showToastMsg(context,
                          "${file.name} ${translation(context).sizeIsGraterThan400KB}");
                      continue;
                    }
                    List<int> bytes = await File(file.path!).readAsBytes();
                    String img64 = base64Encode(bytes);
                    provider.subWorkSttachments.add(
                        WorklogAttachments(base64: img64, name: file.name));
                  }

                  provider.rebuild();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.all(5),
                height: SizeConfigure.widthMultiplier! * 8,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 237, 237, 237),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.add,
                      size: 15,
                      color: kMainColor,
                    ),
                    customSpacer(width: SizeConfigure.widthMultiplier! * 1.5),
                    Text(provider.subWorkSttachments.isEmpty
                        ? language.attachFile
                        : language.add)
                  ],
                ),
              ),
            );
          }
          return InkWell(
            onTap: () {
              fileViewer(
                  context: context,
                  base64Image: provider.subWorkSttachments[index - 1].base64);
            },
            child: Container(
              padding: const EdgeInsets.all(3),
              margin: const EdgeInsets.all(5),
              width: 200,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 237, 237, 237),
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Icon(
                    Icons.attach_file_rounded,
                    size: 15,
                    color: kMainColor,
                  ),
                  customSpacer(width: SizeConfigure.widthMultiplier! * 1.5),
                  Localizations.override(
                    context: context,
                    locale: Locale("en"),
                    child: customText(
                        provider.subWorkSttachments[index - 1].name,
                        maxLength: 18,
                        fontSize: 1.4),
                  ),
                  IconButton(
                      onPressed: () {
                        provider.subWorkSttachments.removeAt(index - 1);
                        provider.rebuild();
                      },
                      icon: const Icon(
                        Icons.cancel,
                        size: 12,
                      ))
                ],
              ),
            ),
          );
        }),
  );
}

Row statusWidget(WorklogSubWorkProvider provider, String text, String value) {
  return Row(
    children: [
      Checkbox(
          value: provider.status == value ? true : false,
          onChanged: (val) {
            provider.status = value;
            provider.rebuild();
          }),
      customText(text)
    ],
  );
}

Stack timeDisplayWidget(
    TimeOfDay? time, String titleText, BuildContext context) {
  return Stack(
    children: [
      SizedBox(
        height: SizeConfigure.widthMultiplier! * 12,
        width: SizeConfigure.widthMultiplier! * 24,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: SizeConfigure.widthMultiplier! * 10.6,
            width: SizeConfigure.widthMultiplier! * 42,
            decoration: const BoxDecoration(
                color: Color.fromARGB(255, 241, 241, 241),
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  time != null
                      ? customText(time.format(context), fontSize: 1.6)
                      : customText("00:00", fontSize: 1.8),
                  customSpacer(width: 5),
                  time != null
                      ? const Icon(
                          Icons.cancel,
                          size: 18,
                        )
                      : const SizedBox()
                ],
              ),
            ),
          ),
        ),
      ),
      customText("   $titleText", fontSize: 1, fontWeight: FontWeight.w700),
    ],
  );
}

List<Widget> expandedContentWidget(
    Map subWorkDetails,
    List<WorklogAttachments> subWorkAttachments,
    BuildContext context,
    AppLocalizations language) {
  return [
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        customText(
          language.workDescription,
          fontSize: 1.6,
          fontWeight: FontWeight.w700,
        ),
      ],
    ),
    customText(subWorkDetails["WORK_DESCRIPTION"],
        color: const Color.fromARGB(255, 162, 155, 155),
        textOverflow: TextOverflow.visible),
    Visibility(
      visible: subWorkDetails["WORK_NOTS"].isNotEmpty,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customSpacer(height: 10),
          customText(
            language.notes,
            fontSize: 1.6,
            fontWeight: FontWeight.w700,
          ),
          customText(subWorkDetails["WORK_NOTS"],
              color: const Color.fromARGB(255, 162, 155, 155),
              textOverflow: TextOverflow.visible),
          customSpacer(height: 10),
        ],
      ),
    ),
    Visibility(
      visible: subWorkDetails["WORK_CHALLENGES"].isNotEmpty,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customText(
            language.blockersAndChallenges,
            fontSize: 1.6,
            fontWeight: FontWeight.w700,
          ),
          customText(subWorkDetails["WORK_CHALLENGES"],
              color: const Color.fromARGB(255, 162, 155, 155),
              textOverflow: TextOverflow.visible),
          customSpacer(height: 10),
        ],
      ),
    ),
    Visibility(
      visible: subWorkAttachments.isNotEmpty,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customText(
            language.attachments,
            fontSize: 1.6,
            fontWeight: FontWeight.w700,
          ),
          SizedBox(
            height: SizeConfigure.widthMultiplier! * 10,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: subWorkAttachments.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    splashColor: Colors.white,
                    onTap: () async {
                      fileViewer(
                          context: context,
                          base64Image: subWorkAttachments[index].base64);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.all(5),
                      height: SizeConfigure.widthMultiplier! * 3,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 237, 237, 237),
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.attach_file_rounded,
                            size: SizeConfigure.widthMultiplier! * 3,
                            color: kMainColor,
                          ),
                          customSpacer(
                              width: SizeConfigure.widthMultiplier! * 1.5),
                          customText(subWorkAttachments[index].name,
                              maxLength: 18,
                              fontSize: 1,
                              fontWeight: FontWeight.bold),
                        ],
                      ),
                    ),
                  );
                }),
          ),
          customSpacer(height: 10),
        ],
      ),
    )
  ];
}

Widget myExpanstionTile(
    List subWorkAttachments,
    Map subWorkDetails,
    WorklogSubWorkProvider provider,
    BuildContext context,
    AppLocalizations language,
    Map work,
    int index,
    String workId,
    StateSetter setState) {
  var language = AppLocalizations.of(context)!;
  List<WorklogAttachments> attachmentsOfThisSubWork = [];
  for (var attachment in subWorkAttachments) {
    if (attachment["WORK_SUB_ID"] == subWorkDetails["WORK_SUB_ID"]) {
      attachmentsOfThisSubWork.add(WorklogAttachments(
          name: attachment["IMAGE_NAME"],
          base64: attachment["ATTACHMENT_FILE"]));
    }
  }

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      child: Slidable(
        endActionPane: ActionPane(
          extentRatio: .55,
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              backgroundColor: Color.fromARGB(255, 238, 237, 242),
              onPressed: (BuildContext _) async {
                bool shouldDelete = false;
                await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: customText(
                            "${language.delete} ${subWorkDetails["WORK_TITLE"] ?? ""} ?",
                            fontSize: 2.5,
                            textOverflow: TextOverflow.visible),
                        content: customText(language.deleteWorklogDialog,
                            textOverflow: TextOverflow.visible),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: customText(language.cancel)),
                          TextButton(
                              onPressed: () async {
                                shouldDelete = true;
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              },
                              child: customText(language.ok))
                        ],
                      );
                    });
                if (shouldDelete) {
                  provider.isLoading = true;
                  provider.rebuild();
                  await worklogDeleteSubWork(
                      workId, subWorkDetails["WORK_SUB_ID"], context, provider);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              MySubWorksScreen(work: work, workId: workId)));
                }
              },
              foregroundColor: Colors.black,
              icon: Icons.delete,
              label: translation(context).delete,
            ),
            SlidableAction(
              backgroundColor: Color.fromARGB(255, 238, 237, 242),
              onPressed: (BuildContext context) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => AddSubWorkScreen(
                          isToEdit: true,
                          workId: workId,
                          work: work,
                          subWorkToEdit: subWorkDetails,
                          subWorkAttachments: attachmentsOfThisSubWork,
                          subWorkId: subWorkDetails["WORK_SUB_ID"],
                        )));
              },
              foregroundColor: Colors.black,
              icon: Icons.edit,
              label: translation(context).edit,
            ),
          ],
        ),
        child: Column(
          children: [
            ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              key: UniqueKey(),
              maintainState: true,
              onExpansionChanged: (value) {
                if (value) {
                  setState(() {
                    provider.expandedTileIndex = index;
                  });
                } else {
                  setState(() {
                    provider.expandedTileIndex = -1;
                  });
                }
              },
              initiallyExpanded: index == provider.expandedTileIndex,
              shape: const Border(),
              childrenPadding: const EdgeInsets.all(10),
              collapsedBackgroundColor:
                  const Color.fromARGB(255, 255, 255, 255),
              backgroundColor: Colors.white,
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              leading: Container(
                  height: SizeConfigure.widthMultiplier! * 14,
                  width: SizeConfigure.widthMultiplier! * 14,
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 126, 147, 168),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: myExpanstiontileDateWidget(subWorkDetails)),
              subtitle: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: subWorkDetails["WORK_COMPLETED_FLAG"] == true
                            ? Colors.green
                            : Colors.orange,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.flag,
                          size: 16,
                          color: Colors.black,
                        ),
                        customSpacer(width: 5),
                        customText(
                          subWorkDetails["WORK_COMPLETED_FLAG"] == true
                              ? "completed"
                              : "pending",
                          fontSize: 1,
                          fontWeight: FontWeight.w800,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      width: SizeConfigure.widthMultiplier! * 45,
                      child: customText(
                        "#${subWorkDetails["WORK_SUB_ID"]}-${subWorkDetails["WORK_TITLE"] ?? ""}",
                        fontSize: 1.9,
                        textDirection: TextDirection.ltr,
                      )),
                  customSpacer(height: 10),
                ],
              ),
              children: expandedContentWidget(
                  subWorkDetails, attachmentsOfThisSubWork, context, language),
            ),
            Container(
              width: double.infinity,
              color: kMainColor,
              padding: EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  customText(
                      "${to12Hours(subWorkDetails["START_TIME"])} ${translation(context).to} ${to12Hours(subWorkDetails["END_TIME"])} (${subWorkDetails["TOTAL_TIME"]} ${translation(context).hours})",
                      fontSize: 1.2,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                  customText(
                      translation(context).employee +
                          " : " +
                          subWorkDetails["EMPLOYEE_NAME"],
                      fontSize: 1.4,
                      fontWeight: FontWeight.w600,
                      maxLength: 30,
                      color: Colors.white),
                ],
              ),
            )
          ],
        ),
      ),
    ),
  );
}

Column myExpanstiontileDateWidget(Map subWorkDetails) {
  return Column(
    children: [
      customText(toDDMMMYYY(subWorkDetails["CURRENT_DATE"]).split("-").first,
          fontSize: 2.5, color: Colors.white, fontWeight: FontWeight.bold),
      customText(toDDMMMYYY(subWorkDetails["CURRENT_DATE"]).split("-")[1],
          fontSize: 1.4, color: const Color.fromARGB(255, 240, 240, 240))
    ],
  );
}
//common

Future<bool> myExitDialog(
  BuildContext context,
  language,
) async {
  bool yesOrNo = false;
  await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: customText(language.exitDialog, fontSize: 1.8),
          actions: [
            TextButton(
                onPressed: () {
                  yesOrNo = false;
                  Navigator.pop(context);
                },
                child: Text(language.no)),
            TextButton(
                onPressed: () {
                  yesOrNo = true;
                  Navigator.pop(context);
                },
                child: Text(language.yes))
          ],
        );
      });
  return yesOrNo;
}

TypeAheadField myTypeHeadDropDown(
    {required List<String> items,
    required String hintText,
    required String labelText,
    required String? value,
    required Function onSelected,
    required Function onCancel,
    InputBorder? inputBorder = const OutlineInputBorder()}) {
  return TypeAheadField(
    constraints: const BoxConstraints(maxHeight: 200),
    suggestionsCallback: (search) {
      return items
          .where(
              (element) => element.toUpperCase().contains(search.toUpperCase()))
          .toList();
    },
    builder: (context, controller, focusNode) {
      controller.text = value ?? "";

      controller.addListener(
        () {
          if (items.contains(controller.text)) {
            FocusScope.of(context).requestFocus(FocusNode());
          }
        },
      );
      return FocusScope(
        child: Focus(
          onFocusChange: (value) {
            if (!value) {
              if (!items.contains(controller.text)) {
                onCancel();
              }
            }
          },
          child: TextField(
              onChanged: (value) {
                controller.text = value;
              },
              readOnly: items.contains(controller.text),
              style: TextStyle(fontSize: SizeConfigure.textMultiplier! * 1.8),
              controller: TextEditingController(
                  text: controller.text.split("-").last.replaceAll("_", " ")),
              focusNode: focusNode,
              decoration: InputDecoration(
                suffixIcon: Visibility(
                    visible: controller.text.isNotEmpty,
                    child: IconButton(
                        onPressed: () {
                          onCancel();
                        },
                        icon: const Icon(Icons.cancel))),
                border: inputBorder,
                hintStyle: const TextStyle(fontWeight: FontWeight.normal),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelText: labelText,
                labelStyle:
                    TextStyle(fontSize: SizeConfigure.textMultiplier! * 1.6),
                hintText: hintText,
              )),
        ),
      );
    },
    itemBuilder: (context, sugession) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: customText(
            sugession.toString().split("-").last.replaceAll("_", "  "),
            textOverflow: TextOverflow.visible),
      );
    },
    onSelected: (selectedValue) {
      onSelected(selectedValue);
    },
  );
}

String getDate(DateTime date) {
  return "${date.day}-${date.month}-${date.year}";
}

int getDateDiffrence(String date) {
  List dateParts = date.split("-");
  int days = DateTime(int.parse(dateParts[2]), int.parse(dateParts[1]),
          int.parse(dateParts[0]))
      .difference(DateTime.now())
      .inDays;

  return days + 1;
}

String getMountString(String mount) {
  switch (mount) {
    case "1":
      return "Jan";
    case "2":
      return "Feb";
    case "3":
      return "Mar";
    case "4":
      return "Apr";
    case "5":
      return "May";
    case "6":
      return "Jun";
    case "7":
      return "Jul";
    case "8":
      return "Aug";
    case "9":
      return "Sep";
    case "10":
      return "Oct";
    case "11":
      return "Nov";
    case "12":
      return "Des";
    default:
      return "error";
  }
}

String to12Hours(String time) {
  String hour = time.split(":").first;
  int intHour = int.parse(hour);
  if (intHour > 12) {
    return "${(intHour - 12)}:${time.split(":").last}";
  }
  return time;
}

String toDDMMMYYY(String date) {
  List dateParts = date.split("-");
  return "${dateParts[0]}-${getMountString(dateParts[1])}-${dateParts[2]}"
      .toUpperCase();
}

String dateTimetoDDMMYYY(DateTime date) {
  return "${date.day}-${date.month}-${date.year}";
}

class AutoNumberingTextField extends StatefulWidget {
  AutoNumberingTextField(
      {super.key,
      required this.hintText,
      required this.controller,
      this.minLines = 1,
      this.maxLines = 1});
  String hintText;
  int minLines;
  int maxLines;
  TextEditingController controller;
  @override
  State<AutoNumberingTextField> createState() => _TestState();
}

class _TestState extends State<AutoNumberingTextField> {
  String previusText = "";

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateNumbering);
  }

  void _updateNumbering() {
    String text = widget.controller.text;
    int j = text.split("\n").length;
    if (text == "1.") {
      text = "1. ";
    }
    if ((text.length < previusText.length) && text.length > 2) {
      if (text[text.length - 1] == "." && text[text.length - 3] == "\n") {
        text = text.substring(0, text.length - 3);
      }
    } else {
      if (text.isNotEmpty && text[text.length - 1] == "\n" && text.length > 2) {
        if (text[text.length - 3] == ".") {
          text = text.substring(0, text.length - 1);
        } else {
          text = "$text$j. ";
        }
      }
    }

    String updatedText = text;
    previusText = updatedText;
    widget.controller.value = TextEditingValue(
      text: updatedText,
      selection: TextSelection.collapsed(offset: updatedText.length),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateNumbering);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      child: Focus(
        onFocusChange: (focus) {
          if (!focus) {
            if (widget.controller.text == "1. ") {
              widget.controller.removeListener(_updateNumbering);
              widget.controller.text = "";
            }
            List lines = widget.controller.text.split("\n");
            if (lines.last.length == 3) {
              lines.removeAt(lines.length - 1);
              widget.controller.text = lines.join("\n");
            }
          }
          if (focus) {
            widget.controller.addListener(_updateNumbering);
            if (widget.controller.text == "") {
              widget.controller.value = const TextEditingValue(
                text: "1. ",
                selection: TextSelection.collapsed(offset: 3),
              );
            }
          }
        },
        child: TextField(
          style: TextStyle(fontSize: SizeConfigure.textMultiplier! * 1.8),
          controller: widget.controller,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: widget.hintText,
              hintStyle: const TextStyle(fontWeight: FontWeight.normal),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              label: customText(widget.hintText)),
        ),
      ),
    );
  }
}

PopupMenuButton<dynamic> myLanguageButton(BuildContext context) {
  return PopupMenuButton<Language>(
      onSelected: (Language? language) async {
        if (language != null) {
          Locale _locale = await setLocale(language.languageCode);
          MyApp.setLocale(context, _locale);
        }
      },
      child: const Icon(
        Icons.language,
        color: Colors.white,
      ),
      itemBuilder: (context) {
        return Language.languageList().map((e) {
          return PopupMenuItem(
            value: e,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  e.flag,
                  style:
                      TextStyle(fontSize: 2.5 * SizeConfigure.textMultiplier!),
                ),
                SizedBox(width: 10),
                Text(
                  e.name,
                  style: kTextStyle.copyWith(color: Colors.black54),
                )
              ],
            ),
          );
        }).toList();
      });
}

getPriorityInString(bool low, bool mid, bool high,
    {bool shouldArabize = false, BuildContext? context}) {
  if (low) {
    if (shouldArabize && context != null) {
      return translation(context).low;
    }
    return "Low";
  } else if (mid) {
    if (shouldArabize && context != null) {
      return translation(context).mid;
    }
    return "Mid";
  } else {
    if (shouldArabize && context != null) {
      return translation(context).high;
    }
    return "High";
  }
}

DateTime toDateTime(String dateInString) {
  List dateParts = dateInString.split("-");
  return DateTime(int.parse(dateParts[2]), int.parse(dateParts[1]),
      int.parse(dateParts[0]));
}

void fileViewer(
    {required BuildContext context, required String base64Image}) async {
  Uint8List bytes = const Base64Decoder().convert(base64Image);
  Directory dir = await getApplicationCacheDirectory();
  File file = await File("${dir.path}/tempFile").writeAsBytes(bytes);
  OpenFile.open(file.path);
}
