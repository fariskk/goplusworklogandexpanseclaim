import 'package:dots/Screens/TAS/Worklog/loading_screen.dart';
import 'package:dots/Screens/TAS/Worklog/worklog_widget_and_functions.dart';
import 'package:dots/classes/language_constants.dart';
import 'package:dots/services/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../SizeConfigure.dart';
import '../../../classes/commonWidgets.dart';
import '../../../constant.dart';
import '../../../provider/worklog_provider.dart';

class WorklogScreen extends StatefulWidget {
  WorklogScreen(
      {super.key, required this.workDetailsIndex, required this.workId});
  final int workDetailsIndex;

  String workId;
  @override
  State<WorklogScreen> createState() => _WorklogScreenState();
}

class _WorklogScreenState extends State<WorklogScreen> {
  bool isCommentsExpanded = false;

  TextEditingController commentsController = TextEditingController();

  bool showFullTitle = false;
  @override
  void initState() {
    Provider.of<WorklogProvider>(context, listen: false).clear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorklogProvider>(builder: (context, provider, child) {
      var language = AppLocalizations.of(context)!;
      return FutureBuilder(
          future: worklogGetWorkDetails(widget.workId, context),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData &&
                !provider.isLodaing &&
                snapshot.data.data["result"] != false &&
                snapshot.data.data["result"][0].length > 0) {
              Map workDetails = snapshot.data.data["result"][0][0];
              List attachments = snapshot.data.data["result"][1];
              List assignableEmployees = snapshot.data.data["result"][3];
              List statusTypes = snapshot.data.data["result"][2];

              return Scaffold(
                backgroundColor: kMainColor,
                appBar: myAppBar(
                    provider, context, workDetails, widget.workId, language),
                body: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 238, 237, 242),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.all(5),
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 5,
                                      spreadRadius: 2,
                                      offset: Offset(0, 4),
                                      color: Color.fromARGB(255, 213, 210, 210))
                                ]),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width:
                                          SizeConfigure.widthMultiplier! * 60,
                                      child: StatefulBuilder(
                                          builder: (context, setState) {
                                        return InkWell(
                                          onTap: () {
                                            setState(
                                              () {
                                                showFullTitle = !showFullTitle;
                                              },
                                            );
                                          },
                                          child: customText(
                                              workDetails["TASK_NAME"],
                                              fontSize: showFullTitle ? 2 : 3,
                                              fontWeight: FontWeight.w600,
                                              textOverflow: showFullTitle
                                                  ? TextOverflow.visible
                                                  : TextOverflow.ellipsis),
                                        );
                                      }),
                                    ),
                                    customText(
                                        "${getPriorityInString(workDetails["PRIORITY_LOW"], workDetails["PRIORITY_MID"], workDetails["PRIORITY_HIGH"], context: context, shouldArabize: true)} ${translation(context).priority}",
                                        color: getTextColor(getPriorityInString(
                                            workDetails["PRIORITY_LOW"],
                                            workDetails["PRIORITY_MID"],
                                            workDetails["PRIORITY_HIGH"],
                                            context: context)),
                                        fontSize: 1.3,
                                        fontWeight: FontWeight.bold)
                                  ],
                                ),

                                customText(
                                    "${toDDMMMYYY(workDetails["START_DATE"])} -- ${toDDMMMYYY(workDetails["END_DATE"])}",
                                    fontSize: 1,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey[500]),
                                //circular progress section
                                myCircularProgressWidget(
                                    context, workDetails, language),
                                //client and assignedBy section
                                myClientAndDueDateSection(
                                    context, provider, workDetails, language),
                                customSpacer(
                                    height: SizeConfigure.widthMultiplier! * 2),
                                if (workDetails["COMMENTS"] != null &&
                                    workDetails["COMMENTS"].isNotEmpty)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      customText(language.comments,
                                          fontSize: 1.7,
                                          fontWeight: FontWeight.w700),
                                      customSpacer(height: 5),
                                      myMoreText(
                                          workDetails["COMMENTS"], provider),
                                    ],
                                  ),
                                customSpacer(height: 10),
                                Visibility(
                                  visible: attachments.isNotEmpty,
                                  child: customText(language.attachments,
                                      fontSize: 1.7,
                                      fontWeight: FontWeight.w700),
                                ),
                                myWorkAttacmentsDisplayWidget(
                                    attachments, context),
                              ],
                            ),
                          ),
                          customSpacer(height: 15),
                          Container(
                            margin: EdgeInsets.all(5),
                            padding: EdgeInsets.all(
                                SizeConfigure.widthMultiplier! * 4),
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 5,
                                      spreadRadius: 2,
                                      offset: Offset(0, 4),
                                      color: Color.fromARGB(255, 213, 210, 210))
                                ]),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                customText(language.selectStatus,
                                    fontSize: 2.1, fontWeight: FontWeight.w700),
                                customSpacer(
                                    height: SizeConfigure.widthMultiplier! * 2),

                                myStatusSection(provider, context, language,
                                    assignableEmployees, statusTypes),
                                customSpacer(
                                    height: SizeConfigure.widthMultiplier! * 3),
                                AutoNumberingTextField(
                                  hintText: language.comments,
                                  controller: commentsController,
                                  minLines: 2,
                                  maxLines: 3,
                                ),

                                customSpacer(
                                    height: SizeConfigure.widthMultiplier! * 2),
                                myAttachFilesection(context, provider,
                                    widget.workDetailsIndex, language),
                                customSpacer(
                                    height: SizeConfigure.widthMultiplier! * 2),
                                //submit button
                                MaterialButton(
                                  onPressed: () async {
                                    FocusScope.of(context).unfocus();
                                    await provider.submitWork(context,
                                        widget.workId, commentsController.text);
                                    commentsController.clear();
                                  },
                                  minWidth: MediaQuery.of(context).size.width,
                                  color: kMainColor,
                                  shape: const StadiumBorder(),
                                  height: SizeConfigure.widthMultiplier! * 10,
                                  child: customText(
                                      provider.assignTo == null
                                          ? language.submit
                                          : language.assignTo,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
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

            return LoadingScreen(
              language: language,
              onRetry: () {
                provider.rebuild();
              },
            );
          });
    });
  }

  Widget myMoreText(String text, WorklogProvider provider) {
    List textLines = text.split("\n");
    if (text.split("\n").length > 2 && !isCommentsExpanded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          customText(textLines[0] + "\n" + textLines[1],
              fontSize: 1.5, textOverflow: TextOverflow.visible),
          InkWell(
              onTap: () {
                isCommentsExpanded = true;
                provider.rebuild();
              },
              child: customText("More...", color: Colors.blue))
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        customText(text, fontSize: 1.5, textOverflow: TextOverflow.visible),
        textLines.length > 2
            ? InkWell(
                onTap: () {
                  isCommentsExpanded = false;
                  provider.rebuild();
                },
                child: customText("Less", color: Colors.blue))
            : const SizedBox()
      ],
    );
  }
}
