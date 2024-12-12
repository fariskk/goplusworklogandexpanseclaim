import 'package:dots/classes/commonWidgets.dart';
import 'package:dots/classes/language_constants.dart';
import 'package:dots/models/worklog_attachment_model.dart';
import 'package:dots/provider/worklog_common_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../SizeConfigure.dart';
import '../../../constant.dart';
import '../../../provider/worklog_sub_works_provider.dart';
import 'my_sub_works_screen.dart';
import 'worklog_widget_and_functions.dart';

class AddSubWorkScreen extends StatefulWidget {
  AddSubWorkScreen(
      {super.key,
      this.isToEdit = false,
      required this.workId,
      required this.work,
      this.subWorkId,
      this.subWorkToEdit,
      this.subWorkAttachments});

  bool isToEdit;
  Map? subWorkToEdit;
  List<WorklogAttachments>? subWorkAttachments;

  String workId;
  Map work;
  int? subWorkId;
  @override
  State<AddSubWorkScreen> createState() => _AddSubWorkScreenState();
}

class _AddSubWorkScreenState extends State<AddSubWorkScreen> {
  TextEditingController workTitleController = TextEditingController();
  TextEditingController workDescriptionController = TextEditingController();

  TextEditingController notesController = TextEditingController();

  TextEditingController blockersController = TextEditingController();

  bool canPop = false;
  @override
  void initState() {
    fillEditDetails(
        Provider.of<WorklogSubWorkProvider>(context, listen: false));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var language = AppLocalizations.of(context)!;
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) async {
        canPop = await myExitDialog(context, language);
        if (canPop && context.mounted) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => MySubWorksScreen(
                        work: widget.work,
                        workId: widget.workId,
                      )));
        }
      },
      child: Consumer<WorklogSubWorkProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: kMainColor,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: kMainColor,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
                onPressed: () async {
                  canPop = await myExitDialog(context, language);
                  if (canPop && context.mounted) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MySubWorksScreen(
                                  work: widget.work,
                                  workId: widget.workId,
                                )));
                  }
                },
              ),
              title: customText(
                  widget.isToEdit ? language.update : language.dailyLog,
                  fontSize: 2,
                  color: Colors.white),
              actions: [
                myLanguageButton(context),
                customSpacer(width: SizeConfigure.widthMultiplier! * 4.5)
              ],
            ),
            body: Stack(
              children: [
                InkWell(
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          customSpacer(
                              height: SizeConfigure.widthMultiplier! * 4),
                          customText(
                            language.workDetails,
                            fontSize: 1.9,
                            fontWeight: FontWeight.bold,
                          ),
                          const Divider(),

                          customSpacer(
                              height: SizeConfigure.widthMultiplier! * 3),
                          //  work title dropdown

                          TypeAheadField(
                              constraints: const BoxConstraints(maxHeight: 200),
                              suggestionsCallback: (search) {
                                return Provider.of<WorklogCommonProvider>(
                                        context,
                                        listen: false)
                                    .workTitle
                                    .where((element) => element
                                        .toUpperCase()
                                        .contains(search.toUpperCase()))
                                    .toList();
                              },
                              builder: (context, controller, focusNode) {
                                controller.text = provider.workTitle ?? "";

                                controller.addListener(
                                  () {
                                    if (Provider.of<WorklogCommonProvider>(
                                            context,
                                            listen: false)
                                        .workTitle
                                        .contains(controller.text)) {
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                    }
                                  },
                                );
                                return FocusScope(
                                  child: Focus(
                                    onFocusChange: (value) {
                                      if (!value) {
                                        if (!Provider.of<WorklogCommonProvider>(
                                                context,
                                                listen: false)
                                            .workTitle
                                            .contains(controller.text)) {
                                          provider.workTitle = null;

                                          provider.rebuild();
                                        }
                                      }
                                    },
                                    child: TextField(
                                        onChanged: (value) {
                                          if (Provider.of<
                                                      WorklogCommonProvider>(
                                                  context,
                                                  listen: false)
                                              .workTitle
                                              .contains(value)) {
                                            provider.workTitle = value;
                                            provider.rebuild();
                                          }
                                        },
                                        readOnly:
                                            Provider.of<WorklogCommonProvider>(
                                                    context,
                                                    listen: false)
                                                .workTitle
                                                .contains(controller.text),
                                        style: TextStyle(
                                            fontSize:
                                                SizeConfigure.textMultiplier! *
                                                    1.8),
                                        controller: controller,
                                        focusNode: focusNode,
                                        decoration: InputDecoration(
                                          suffixIcon: Visibility(
                                              visible:
                                                  controller.text.isNotEmpty,
                                              child: IconButton(
                                                  onPressed: () {
                                                    provider.workTitle = null;

                                                    provider.rebuild();
                                                  },
                                                  icon: const Icon(
                                                      Icons.cancel))),
                                          border: outlineInputBorder(),
                                          hintStyle: const TextStyle(
                                              fontWeight: FontWeight.normal),
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.always,
                                          labelText: language.workTitle,
                                          labelStyle: TextStyle(
                                              fontSize: SizeConfigure
                                                      .textMultiplier! *
                                                  1.6),
                                          hintText: language.workTitle,
                                        )),
                                  ),
                                );
                              },
                              itemBuilder: (context, sugession) {
                                if (sugession == "CUSTOM") {
                                  TextEditingController
                                      customWorkTitleController =
                                      TextEditingController();
                                  return Container(
                                    padding: EdgeInsets.all(5),
                                    child: TextField(
                                      controller: customWorkTitleController,
                                      decoration: InputDecoration(
                                          hintText: translation(context).custom,
                                          border: outlineInputBorder(),
                                          suffix: InkWell(
                                              onTap: () {
                                                FocusScope.of(context)
                                                    .unfocus();
                                                provider.workTitle =
                                                    customWorkTitleController
                                                        .text
                                                        .toString();
                                                provider.rebuild();
                                              },
                                              child: Icon(Icons.done_sharp))),
                                    ),
                                  );
                                }
                                return Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: customText(
                                      sugession
                                          .toString()
                                          .split("-")
                                          .last
                                          .replaceAll("_", "  "),
                                      textOverflow: TextOverflow.visible),
                                );
                              },
                              onSelected: (value) {
                                if (value.toString() == "CUSTOM") {
                                  return;
                                }
                                provider.workTitle = value.toString();
                                provider.rebuild();
                              }),

                          customSpacer(
                              height: SizeConfigure.widthMultiplier! * 3),
                          //work description field
                          myTextfield(language.workDescription,
                              controller: workDescriptionController),
                          customSpacer(
                              height: SizeConfigure.widthMultiplier! * 3.2),
                          //time section
                          SizedBox(
                            height: SizeConfigure.widthMultiplier! * 12,
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                    onTap: () async {
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                      TimeOfDay? time = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now());

                                      if (time != null) {
                                        provider.startTime = time;
                                      }
                                      provider.rebuild();
                                    },
                                    child: timeDisplayWidget(provider.startTime,
                                        language.startTime, context)),
                                customText("TO",
                                    fontSize: 1.8, fontWeight: FontWeight.w500),
                                InkWell(
                                  onTap: () async {
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    TimeOfDay? time = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now());
                                    if (time != null) {
                                      provider.endTime = time;
                                    }
                                    provider.rebuild();
                                  },
                                  child: timeDisplayWidget(provider.endTime,
                                      language.endTime, context),
                                ),
                                Stack(
                                  children: [
                                    SizedBox(
                                      height:
                                          SizeConfigure.widthMultiplier! * 12,
                                      width:
                                          SizeConfigure.widthMultiplier! * 25,
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          height:
                                              SizeConfigure.widthMultiplier! *
                                                  10.6,
                                          width:
                                              SizeConfigure.widthMultiplier! *
                                                  42,
                                          decoration: BoxDecoration(
                                              color: kMainColor.withOpacity(.2),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10))),
                                          child: Center(
                                            child: customText(
                                                provider.startTime != null &&
                                                        provider.endTime != null
                                                    ? getTotalTime(
                                                        provider.startTime!,
                                                        provider.endTime!,
                                                        provider,
                                                        context)
                                                    : "0:0",
                                                fontSize: 2),
                                          ),
                                        ),
                                      ),
                                    ),
                                    customText("   ${language.totalTime}",
                                        fontSize: 1,
                                        fontWeight: FontWeight.w700),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          customSpacer(
                              height: SizeConfigure.widthMultiplier! * 3),
                          //status section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              customText(language.status,
                                  fontSize: 2, fontWeight: FontWeight.w600),
                              statusWidget(provider,
                                  translation(context).pending, "In Progress"),
                              statusWidget(provider,
                                  translation(context).completed, "Completed"),
                            ],
                          ),
                          customSpacer(
                              height: SizeConfigure.widthMultiplier! * 3),
                          //notes field
                          AutoNumberingTextField(
                            hintText: language.notes,
                            controller: notesController,
                            maxLines: 3,
                          ),
                          //progress section
                          widget.isToEdit
                              ? SizedBox(
                                  height: SizeConfigure.widthMultiplier! * 2,
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    customText(language.progress,
                                        fontSize: 1.7,
                                        fontWeight: FontWeight.w500,
                                        color: const Color.fromARGB(
                                            255, 103, 100, 100)),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width -
                                          SizeConfigure.widthMultiplier! * 36,
                                      child: progressSliderWidget(
                                          widget.work, provider),
                                    ),
                                  ],
                                ),
                          customSpacer(
                              height: SizeConfigure.widthMultiplier! * 1),
                          //blocers and challeges field
                          AutoNumberingTextField(
                            hintText: language.blockersAndChallenges,
                            controller: blockersController,
                            minLines: 2,
                            maxLines: 3,
                          ),
                          customSpacer(
                              height: SizeConfigure.widthMultiplier! * 2),
                          // attach file section
                          subWorksAttachFilesection(
                              context, provider, language),
                          customSpacer(
                              height: SizeConfigure.widthMultiplier! * 2),
                          //submit section
                          MaterialButton(
                            onPressed: () async {
                              FocusScope.of(context).unfocus();
                              if (widget.isToEdit) {
                                if (await provider.updateWorklog(
                                      widget.workId,
                                      widget.subWorkId!,
                                      provider.workTitle,
                                      workDescriptionController.text,
                                      notesController.text,
                                      blockersController.text,
                                      context,
                                    ) &&
                                    context.mounted) {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MySubWorksScreen(
                                                work: widget.work,
                                                workId: widget.workId,
                                              )));
                                }
                              } else {
                                if (await provider.submitWorklog(
                                      provider.workTitle,
                                      workDescriptionController.text,
                                      notesController.text,
                                      blockersController.text,
                                      widget.workId,
                                      context,
                                    ) &&
                                    context.mounted) {
                                  widget.work["PROGRESS"] =
                                      provider.newProgress;

                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MySubWorksScreen(
                                                workId: widget.workId,
                                                work: widget.work,
                                              )));
                                }
                              }
                            },
                            minWidth: MediaQuery.of(context).size.width,
                            color: kMainColor,
                            shape: const StadiumBorder(),
                            height: SizeConfigure.widthMultiplier! * 10,
                            child: customText(
                                widget.isToEdit
                                    ? language.update
                                    : language.submit,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          customSpacer(
                              height: SizeConfigure.widthMultiplier! * 3)
                        ],
                      ),
                    ),
                  ),
                ),
                Visibility(
                    visible: provider.isLoading,
                    child: SizedBox(
                        height: SizeConfigure.heightMultiplier! * 100,
                        width: SizeConfigure.widthMultiplier! * 100,
                        child: Lottie.asset("assets/json/dotsloading.json")))
              ],
            ),
          );
        },
      ),
    );
  }

  void fillEditDetails(WorklogSubWorkProvider provider) {
    provider.clear();
    if (widget.isToEdit) {
      provider.workTitle = widget.subWorkToEdit!["WORK_TITLE"];
      workTitleController.text = widget.subWorkToEdit!["WORK_TITLE"];
      workDescriptionController.text =
          widget.subWorkToEdit!["WORK_DESCRIPTION"];
      provider.status = widget.subWorkToEdit!["WORK_COMPLETED_FLAG"] == true
          ? "Completed"
          : "In Progress";
      notesController.text = widget.subWorkToEdit!["WORK_NOTS"];
      provider.startTime = toTimeOfDay(widget.subWorkToEdit!["START_TIME"]);
      provider.endTime = toTimeOfDay(widget.subWorkToEdit!["END_TIME"]);
      blockersController.text = widget.subWorkToEdit!["WORK_CHALLENGES"];
      provider.subWorkSttachments = widget.subWorkAttachments!;
    }
  }
}

TimeOfDay toTimeOfDay(String timeInString) {
  List timeParts = timeInString.split(":");
  return TimeOfDay(
      hour: int.parse(timeParts.first), minute: int.parse(timeParts.last));
}

String getTotalTime(TimeOfDay start, TimeOfDay end,
    WorklogSubWorkProvider provider, BuildContext context) {
  final startMinutes = start.hour * 60 + start.minute;
  final endMinutes = end.hour * 60 + end.minute;
  int differenceMinutes = endMinutes - startMinutes;
  if (differenceMinutes < 0) {
    differenceMinutes += 24 * 60;
  }

  final differenceHours = differenceMinutes ~/ 60;
  final differenceRemainingMinutes = differenceMinutes % 60;
  final localizations = MaterialLocalizations.of(context);
  String formatedDiff = localizations
      .formatTimeOfDay(
          TimeOfDay(
            hour: differenceHours,
            minute: differenceRemainingMinutes,
          ),
          alwaysUse24HourFormat: true)
      .split(" ")
      .first;
  provider.totalTime = formatedDiff;
  return formatedDiff;
}
