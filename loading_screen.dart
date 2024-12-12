import 'package:dots/classes/commonWidgets.dart';
import 'package:dots/provider/worklog_common_provider.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../classes/language_constants.dart';
import '../../../constant.dart';

class LoadingScreen extends StatefulWidget {
  LoadingScreen({super.key, required this.onRetry, required this.language});
  Function onRetry;
  AppLocalizations language;
  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WorklogCommonProvider>(context, listen: false)
          .onErrorCanceled();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorklogCommonProvider>(builder: (context, provider, child) {
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
              provider.onErrorCanceled();
              Navigator.maybePop(context);
            },
          ),
          title: customText(
              provider.isErrorfound
                  ? widget.language.error
                  : widget.language.loading,
              fontSize: 2.5,
              color: Colors.white),
        ),
        body: PopScope(
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              provider.onErrorCanceled();
            }
          },
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            child: Center(
              child: provider.isErrorfound
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset("assets/json/oops.json"),
                        customText(translation(context).wentWrong,
                            fontSize: 2, fontWeight: FontWeight.bold),
                        customText(translation(context).checkInternetTryAgain,
                            color: Colors.grey),
                        customSpacer(height: 10),
                        InkWell(
                            onTap: () {
                              provider.onErrorCanceled();
                              widget.onRetry();
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    color: kMainColor,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8))),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 10),
                                child: customText(translation(context).retry,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)))
                      ],
                    )
                  : Lottie.asset("assets/json/dotsloading.json"),
            ),
          ),
        ),
      );
    });
  }
}
