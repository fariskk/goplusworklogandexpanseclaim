import 'package:dots/Screens/TAS/Worklog/loading_screen.dart';
import 'package:dots/Screens/TAS/Worklog/worklog_widget_and_functions.dart';
import 'package:dots/classes/commonWidgets.dart';
import 'package:dots/services/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../SizeConfigure.dart';
import '../../../constant.dart';
import '../../../provider/worklog_sub_works_provider.dart';
import 'add_sub_work_screen.dart';

class MySubWorksScreen extends StatefulWidget {
  const MySubWorksScreen({
    super.key,
    required this.work,
    required this.workId,
  });
  final Map work;
  final String workId;

  @override
  State<MySubWorksScreen> createState() => _MySubWorksScreenState();
}

class _MySubWorksScreenState extends State<MySubWorksScreen> {
  ExpansionTileController epansionTileController = ExpansionTileController();
  @override
  void initState() {
    Provider.of<WorklogSubWorkProvider>(context, listen: false).clear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var language = AppLocalizations.of(context)!;
    return Consumer<WorklogSubWorkProvider>(
      builder: (_, provider, child) {
        return FutureBuilder(
            future: worklogGetAllSubWorks(widget.workId, context, provider),
            builder: (_, AsyncSnapshot snapshot) {
              if (snapshot.hasData &&
                  provider.isLoading == false &&
                  snapshot.data.data["result"] != false) {
                List subWorks = snapshot.data.data["result"][0];
                List subWorkAttachments = snapshot.data.data["result"][1];
                return StatefulBuilder(builder: (_, setState) {
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
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        title: Localizations.override(
                          context: context,
                          locale: Locale("en"),
                          child: customText("#${widget.workId}",
                              fontSize: 2, color: Colors.white),
                        ),
                        actions: [
                          myLanguageButton(context),
                          customSpacer(
                              width: SizeConfigure.widthMultiplier! * 4.5)
                        ],
                      ),
                      body: Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 238, 237, 242),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                        ),
                        child: Column(
                          children: [
                            customSpacer(
                                height: SizeConfigure.widthMultiplier! * 3),
                            Expanded(
                                child: subWorks.isEmpty
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
                                        key: UniqueKey(),
                                        itemCount: subWorks.length,
                                        itemBuilder: (_, index) {
                                          Map subWorkDetails = subWorks[index];

                                          //expanstion tile
                                          return myExpanstionTile(
                                              subWorkAttachments,
                                              subWorkDetails,
                                              provider,
                                              context,
                                              language,
                                              widget.work,
                                              index,
                                              widget.workId,
                                              setState);
                                        })),
                            customSpacer(
                                height: SizeConfigure.widthMultiplier! * 2),
                          ],
                        ),
                      ),
                      floatingActionButton: FloatingActionButton(
                        backgroundColor: kMainColor,
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddSubWorkScreen(
                                        workId: widget.workId,
                                        work: widget.work,
                                      )));
                        },
                        child: const Icon(
                          Icons.post_add,
                          size: 28,
                          color: Colors.white,
                        ),
                      ));
                });
              }
              return LoadingScreen(
                language: language,
                onRetry: () {
                  provider.rebuild();
                },
              );
            });
      },
    );
  }
}
