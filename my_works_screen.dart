import 'package:animated_float_action_button/animated_floating_action_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dots/Screens/TAS/Worklog/loading_screen.dart';
import 'package:dots/classes/commonFunctions.dart';
import 'package:dots/helper/excel_generator.dart';
import 'package:dots/helper/pdf_generator.dart';
import 'package:dots/services/services.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../SizeConfigure.dart';
import '../../../classes/commonWidgets.dart';
import '../../../classes/language_constants.dart';
import '../../../constant.dart';
import '../../../provider/worklog_my_works_provider.dart';
import 'add_work_screen.dart';
import 'worklog_widget_and_functions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyWorksScreen extends StatefulWidget {
  MyWorksScreen(
      {super.key,
      required this.empName,
      required this.empemail,
      required this.empImg});

  String empName;
  String empemail;
  String? empImg;

  @override
  State<MyWorksScreen> createState() => _MyWorksScreenState();
}

class _MyWorksScreenState extends State<MyWorksScreen> {
  List chartValues = [];
  TextEditingController searchController = TextEditingController();
  final GlobalKey<AnimatedFloatingActionButtonState> fabKey = GlobalKey();
  ScrollController singleChildScrollViewController = ScrollController();
  ScrollController listViewController = ScrollController();
  @override
  void initState() {
    WorklogMyWorksProvider provider =
        Provider.of<WorklogMyWorksProvider>(context, listen: false);
    provider.clear();
    provider.getDropdownValues(context);
    listViewController.addListener(() {
      if (listViewController.position.pixels ==
          listViewController.position.maxScrollExtent) {
        singleChildScrollViewController.animToBottom();
      }
      ;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorklogMyWorksProvider>(
        builder: (context, provider, child) {
      return Builder(builder: (_) {
        AppLocalizations language = AppLocalizations.of(context)!;

        return FutureBuilder(
          future: worklogGetAllWorks(context, provider),
          builder: (_, AsyncSnapshot snapshot) {
            if (snapshot.hasData &&
                provider.isLoading == false &&
                snapshot.data.data["result"] != false) {
              return StatefulBuilder(builder: (_, customSetState) {
                var data = snapshot.data.data["result"];
                List works = data[5];

                getChartData(data);

                if (provider.dateRangeToSort.isNotEmpty) {
                  works = works.where((element) {
                    List dateParts = element["END_DATE"].split("-");
                    DateTime date = DateTime(int.parse(dateParts[2]),
                        int.parse(dateParts[1]), int.parse(dateParts[0]));

                    if (date.isAfter(provider.dateRangeToSort.first!
                            .subtract(const Duration(days: 1))) &&
                        date.isBefore(provider.dateRangeToSort.last!
                            .add(const Duration(days: 1)))) {
                      return true;
                    }

                    return false;
                  }).toList();
                }
                if (provider.selectedTypeForSort != "All") {
                  works = works
                      .where((element) =>
                          element["WORK_TYPE"] == provider.selectedTypeForSort)
                      .toList();
                }
                if (provider.selectedPriorityForSort != "All") {
                  works = works
                      .where((element) =>
                          getPriorityInString(element["PRIORITY_LOW"],
                              element["PRIORITY_MID"], element["PRIORITY_HIGH"],
                              context: context) ==
                          provider.selectedPriorityForSort)
                      .toList();
                }
                if (provider.selectedStatusForSort != "All") {
                  works = works
                      .where((element) =>
                          element["WORK_STATUS"] ==
                          provider.selectedStatusForSort)
                      .toList();
                }
                if (provider.isSearchEnabled) {
                  works = works
                      .where((element) =>
                          element["WORKID"].contains(provider.searchKeyword) ||
                          element["TASK_NAME"]
                              .toLowerCase()
                              .contains(provider.searchKeyword.toLowerCase()))
                      .toList();
                }
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
                        Navigator.pop(context);
                      },
                    ),
                    title: customText(language.worklog,
                        fontSize: 2.5, color: Colors.white),
                    actions: [
                      myLanguageButton(context),
                      customSpacer(width: SizeConfigure.widthMultiplier! * 4.5)
                    ],
                    bottom: PreferredSize(
                      preferredSize: Size(MediaQuery.of(context).size.width,
                          SizeConfigure.heightMultiplier! * 10),
                      child: Container(
                        padding: EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      translation(context).hey,
                                      style: kTextStyle.copyWith(
                                          color: Colors.white,
                                          fontSize:
                                              2 * SizeConfigure.textMultiplier!,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      width: 5.0,
                                    ),
                                    SizedBox(
                                      width:
                                          SizeConfigure.widthMultiplier! * 50,
                                      child: customText(widget.empName,
                                          fontSize: 2,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                customSpacer(height: 10),
                                Text(
                                  translation(context).welcomeToWorklog,
                                  style: kTextStyle.copyWith(
                                    color: Colors.white,
                                    fontSize:
                                        1.8 * SizeConfigure.textMultiplier!,
                                  ),
                                )
                              ],
                            ),
                            Visibility(
                              visible: !widget.empImg.isEmptyOrNull,
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                                child: CachedNetworkImage(
                                  imageUrl:
                                      "${getCompanyURL()}uploads/Emp_Image/${widget.empImg}",
                                  height: 60,
                                  width: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  body: InkWell(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      if (fabKey.currentState != null &&
                          fabKey.currentState!.isOpened) {
                        fabKey.currentState?.animate();
                      }
                    },
                    child: PopScope(
                      onPopInvokedWithResult: (didPop, result) {
                        FocusScope.of(context).unfocus();
                      },
                      child: SingleChildScrollView(
                        controller: singleChildScrollViewController,
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height + 100,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 238, 237, 242),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                customSpacer(height: 15),
                                Visibility(
                                  visible: data[5].isNotEmpty,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          customText(
                                              translation(context).workOverview,
                                              fontSize: 2,
                                              fontWeight: FontWeight.bold),
                                          Icon(Icons.calendar_month)
                                        ],
                                      ),
                                      customSpacer(height: 10),
                                      myChartWidget(context, provider,
                                          chartValues, language),
                                      customSpacer(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          myPieChartDetailsWidget(
                                              language.completed,
                                              chartValues[0],
                                              const Color.fromARGB(
                                                  255, 142, 194, 84),
                                              Icons.check_circle,
                                              context),
                                          myPieChartDetailsWidget(
                                              language.pending,
                                              chartValues[1],
                                              const Color.fromARGB(
                                                  255, 253, 201, 81),
                                              Icons.alarm_on,
                                              context),
                                        ],
                                      ),
                                      customSpacer(height: 15),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          myPieChartDetailsWidget(
                                              language.onHold,
                                              chartValues[2],
                                              const Color.fromARGB(
                                                  255, 88, 151, 231),
                                              Icons.do_not_disturb_on,
                                              context),
                                          myPieChartDetailsWidget(
                                              language.overdue,
                                              chartValues[3],
                                              const Color.fromARGB(
                                                  255, 230, 79, 96),
                                              Icons.dangerous,
                                              context),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                customSpacer(height: 10),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      children: [
                                        myFilterAndSearchSection(
                                            provider,
                                            language,
                                            context,
                                            customSetState,
                                            data[5].length),
                                        //search field
                                        mySearchField(
                                            provider,
                                            context,
                                            language,
                                            searchController,
                                            customSetState)
                                      ],
                                    )),
                                Expanded(
                                  child: works.isEmpty
                                      ? Center(
                                          child: Image.asset(
                                            "assets/icons/folder.png",
                                            height:
                                                SizeConfigure.widthMultiplier! *
                                                    20,
                                            width:
                                                SizeConfigure.widthMultiplier! *
                                                    30,
                                          ),
                                        )
                                      : ListView.builder(
                                          controller: listViewController,
                                          itemCount: works.length,
                                          itemBuilder: (_, index) {
                                            Map workDetails = works[index];

                                            //my works tile
                                            return myWorksTile(
                                                context,
                                                index,
                                                workDetails,
                                                provider,
                                                language,
                                                customSetState,
                                                empImg: widget.empImg,
                                                empName: widget.empName,
                                                empemail: widget.empemail);
                                          },
                                        ),
                                ),
                              ],
                            )),
                      ),
                    ),
                  ),
                  floatingActionButton: AnimatedFloatingActionButton(
                      key: fabKey,
                      fabButtons: <Widget>[
                        FloatingActionButton(
                          backgroundColor: kMainColor,
                          heroTag: null,
                          onPressed: () {
                            fabKey.currentState?.animate();

                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddWorkScreen(
                                          empImg: widget.empImg,
                                          empName: widget.empName,
                                          empemail: widget.empemail,
                                        )));
                          },
                          child: Image.asset(
                            "assets/icons/add.png",
                            height: 25,
                            color: Colors.white,
                            width: 25,
                          ),
                        ),
                        FloatingActionButton(
                          backgroundColor: kMainColor,
                          heroTag: null,
                          onPressed: () async {
                            fabKey.currentState?.animate();
                            if (works.isEmpty) {
                              showToastMsg(
                                  context, translation(context).noWorksFound);
                              return;
                            }
                            if (!await ExcelGenerator.generateExcel(
                                    provider: provider,
                                    works: works,
                                    empName: widget.empName) &&
                                context.mounted) {
                              showToastMsg(context,
                                  translation(context).noSupportedAppFound);
                            }
                          },
                          child: Image.asset(
                            "assets/icons/xls.png",
                            height: 25,
                            color: Colors.white,
                            width: 25,
                          ),
                        ),
                        FloatingActionButton(
                          backgroundColor: kMainColor,
                          heroTag: null,
                          child: Image.asset(
                            "assets/icons/download-pdf.png",
                            color: Colors.white,
                            height: 25,
                            width: 25,
                          ),
                          onPressed: () async {
                            fabKey.currentState?.animate();
                            if (works.isEmpty) {
                              showToastMsg(
                                  context, translation(context).noWorksFound);
                              return;
                            }
                            if (!await PdfGenerator.generatePdf(
                                  provider: provider,
                                  works: works,
                                  empName: widget.empName,
                                  email: widget.empemail,
                                ) &&
                                context.mounted) {
                              showToastMsg(context,
                                  translation(context).noSupportedAppFound);
                            }
                          },
                        ),
                      ],
                      colorStartAnimation: kMainColor,
                      colorEndAnimation:
                          const Color.fromARGB(255, 124, 158, 197),
                      animatedIconData: AnimatedIcons.menu_close),
                );
              });
            }
            return LoadingScreen(
              language: language,
              onRetry: () {
                provider.rebuild();
              },
            );
          },
        );
      });
    });
  }

  getChartData(List data) {
    chartValues.clear();

    chartValues.add(data[5]
        .where((element) => element["WORK_STATUS"] == "COMPLETED")
        .toList()
        .length
        .toDouble());
    chartValues.add(data[5]
        .where((element) => element["WORK_STATUS"] == "PENDING")
        .toList()
        .length
        .toDouble());
    chartValues.add(data[5]
        .where((element) => element["WORK_STATUS"] == "ON_HOLD")
        .toList()
        .length
        .toDouble());
    chartValues.add(data[5]
        .where((element) => getDateDiffrence(element["END_DATE"]) < 1)
        .toList()
        .length
        .toDouble());
    chartValues.add(chartValues[0] + chartValues[1] + chartValues[2]);
    chartValues.add(data[5].length);
  }
}
