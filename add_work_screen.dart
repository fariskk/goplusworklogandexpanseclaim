import 'package:dots/classes/commonFunctions.dart';
import 'package:dots/classes/language_constants.dart';
import 'package:dots/models/worklog_attachment_model.dart';
import 'package:dots/provider/worklog_common_provider.dart';
import 'package:dots/services/services.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../SizeConfigure.dart';
import '../../../classes/commonWidgets.dart';
import '../../../constant.dart';
import '../../../provider/worklog_my_works_provider.dart';
import 'my_works_screen.dart';
import 'worklog_widget_and_functions.dart';

class AddWorkScreen extends StatefulWidget {
  AddWorkScreen(
      {super.key,
      this.workToEdit,
      this.isToEdit = false,
      this.workId,
      required this.empImg,
      required this.empName,
      required this.empemail});

  String empName;
  String empemail;
  String? empImg;

  bool isToEdit;
  Map? workToEdit;

  String? workId;
  @override
  State<AddWorkScreen> createState() => _AddWorkScreenState();
}

class _AddWorkScreenState extends State<AddWorkScreen> {
  TextEditingController taskNameController = TextEditingController();
  TextEditingController reasonController = TextEditingController();

  TextEditingController commentsController = TextEditingController();
  TextEditingController dependenciesController = TextEditingController();
  bool canPop = false;
  @override
  void initState() {
    var provider = Provider.of<WorklogMyWorksProvider>(context, listen: false);
    provider.clear();
    if (widget.isToEdit) {
      fillEditinitialValues(provider);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorklogMyWorksProvider>(
      builder: (context, provider, child) {
        var language = AppLocalizations.of(context)!;
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
                        builder: (context) => MyWorksScreen(
                            empName: widget.empName,
                            empemail: widget.empemail,
                            empImg: widget.empImg)),
                  );
                }
              },
            ),

            //title
            title: customText(
                widget.isToEdit ? language.update : language.createWork,
                fontSize: 2.5,
                color: Colors.white),
            actions: [
              myLanguageButton(context),
              customSpacer(width: SizeConfigure.widthMultiplier! * 4.5)
            ],
          ),
          body: PopScope(
            canPop: canPop,
            onPopInvokedWithResult: (value, dynamic) async {
              canPop = await myExitDialog(context, language);
              if (canPop && context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyWorksScreen(
                          empName: widget.empName,
                          empemail: widget.empemail,
                          empImg: widget.empImg)),
                );
              }
            },
            child: InkWell(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Stack(
                children: [
                  Container(
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
                          customSpacer(height: 20),

                          customText(language.workDetails,
                              fontSize: 2, fontWeight: FontWeight.bold),
                          const Divider(),
                          customSpacer(height: 10),
                          //work group typhead
                          myTypeHeadDropDown(
                              value: provider.selectedWorkGroup ?? "",
                              hintText: language.workGroups,
                              items: Provider.of<WorklogCommonProvider>(context,
                                      listen: false)
                                  .companyes,
                              labelText: language.workGroups,
                              onCancel: () {
                                provider.selectedWorkGroup = null;

                                provider.rebuild();
                              },
                              onSelected: (workGroup) {
                                provider.selectedWorkGroup = workGroup;

                                provider.rebuild();
                              }),
                          customSpacer(height: 15),
                          // work type typehead
                          myTypeHeadDropDown(
                              value: provider.selectedWorType ?? "",
                              hintText: language.workType,
                              items: Provider.of<WorklogCommonProvider>(context,
                                      listen: false)
                                  .workTypes,
                              labelText: language.workType,
                              onCancel: () {
                                provider.selectedWorType = null;

                                provider.rebuild();
                              },
                              onSelected: (workType) {
                                provider.selectedWorType = workType;

                                provider.rebuild();
                              }),

                          customSpacer(
                              height: SizeConfigure.widthMultiplier! * 3.2),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //assigned by section
                              myAssignedByDropDown(provider, language, context),
                              //client section
                              myClientdropDown(context, provider, language),
                            ],
                          ),
                          customSpacer(height: 15),
                          //taskname field
                          myTextfield(language.taskName,
                              controller: taskNameController),
                          customSpacer(height: 10),
                          //date section
                          SizedBox(
                            height: 60,
                            width: MediaQuery.of(context).size.width,
                            child: myDateWidget(context, provider, language),
                          ),
                          //update progress slider
                          widget.isToEdit
                              ? updateProgressWidget(
                                  context, provider, language)
                              : customSpacer(height: 15),

                          //dependencies section

                          AutoNumberingTextField(
                            hintText: language.dependencies,
                            controller: dependenciesController,
                            maxLines: 3,
                          ),
                          customSpacer(height: 10),
                          //priority section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              customText(language.priority,
                                  fontSize: 2, fontWeight: FontWeight.w600),
                              myPriorityWidget(
                                  translation(context).low, "Low", provider),
                              myPriorityWidget(
                                  translation(context).mid, "Mid", provider),
                              myPriorityWidget(
                                  translation(context).high, "High", provider),
                            ],
                          ),
                          customSpacer(height: 10),
                          //Reason Field
                          Visibility(
                            visible: widget.isToEdit,
                            child: AutoNumberingTextField(
                              hintText: language.reasonForChange,
                              controller: reasonController,
                              maxLines: 3,
                            ),
                          ),
                          customSpacer(height: 15),
                          //comments field
                          AutoNumberingTextField(
                            hintText: language.comments,
                            controller: commentsController,
                            minLines: 2,
                            maxLines: 3,
                          ),
                          customSpacer(height: 10),
                          addWorkAttachFilesection(context, provider, language),
                          customSpacer(height: 10),
                          MaterialButton(
                            onPressed: () async {
                              FocusScope.of(context).unfocus();
                              if (widget.isToEdit) {
                                if (await provider.update(
                                    taskNameController.text,
                                    commentsController.text,
                                    dependenciesController.text,
                                    context,
                                    reasonController.text,
                                    widget.workId!)) {
                                  if (context.mounted) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyWorksScreen(
                                              empName: widget.empName,
                                              empemail: widget.empemail,
                                              empImg: widget.empImg)),
                                    );
                                  }
                                }
                              } else {
                                if (await provider.submit(
                                    taskNameController.text,
                                    commentsController.text,
                                    dependenciesController.text,
                                    context)) {
                                  if (context.mounted) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyWorksScreen(
                                              empName: widget.empName,
                                              empemail: widget.empemail,
                                              empImg: widget.empImg)),
                                    );
                                  }
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
                          customSpacer(height: 15)
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                      visible: provider.isLoading,
                      child: Container(
                          color: Colors.transparent,
                          height: SizeConfigure.heightMultiplier! * 100,
                          width: SizeConfigure.widthMultiplier! * 100,
                          child: Lottie.asset("assets/json/dotsloading.json")))
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void fillEditinitialValues(
    WorklogMyWorksProvider provider,
  ) async {
    try {
      var res = await worklogGetInitialValuesForEditWork(widget.workId!);
      if (res.statusCode == 200 && res.data["result"] != false) {
        Map workDetails = res.data["result"][0][0];
        taskNameController.text = workDetails["TASK_NAME"];
        commentsController.text = workDetails["COMMENTS"] ?? "";
        provider.assignedBy = workDetails["ASSIGNED_BY"];
        provider.client = workDetails["CLIENT_NAME"];
        provider.selectedPriority = getPriorityInString(
            workDetails["PRIORITY_LOW"],
            workDetails["PRIORITY_MID"],
            workDetails["PRIORITY_HIGH"],
            context: context);
        dependenciesController.text = workDetails["DEPENDENCIES"] ?? "";
        provider.startDate = toDateTime(workDetails["START_DATE"]);
        provider.endDate = toDateTime(workDetails["END_DATE"]);
        provider.selectedWorkGroup = workDetails["WORK_GROUP"];
        provider.selectedWorType = widget.workToEdit!["WORK_TYPE"];
        provider.progressToUpdate = workDetails["PROGRESS"].toDouble();

        res.data["result"][1].forEach((e) {
          provider.attachments.add(WorklogAttachments(
              name: e["IMAGE_NAME"], base64: e["ATTACHMENT_FILE"]));
        });
      } else {
        showToastMsg(context, translation(context).wentWrong);
      }

      provider.isLoading = false;
      provider.rebuild();
    } catch (e) {
      showToastMsg(context, translation(context).wentWrong);
      provider.isLoading = false;
      provider.rebuild();
    }
  }
}
