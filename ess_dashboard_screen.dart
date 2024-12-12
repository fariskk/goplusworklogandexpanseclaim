import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:badges/badges.dart' as badges;
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:d_chart/d_chart.dart';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:dots/Screens/ESS/Requests/expense_claim_screen.dart';
import 'package:dots/Screens/ESS/payslip.dart';
import 'package:dots/Screens/ESS/profile_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:im_animations/im_animations.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:mime/mime.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:upgrader/upgrader.dart';
import '../../Database/db_provider.dart';
import '../../SizeConfigure.dart';
import '../../classes/commonFunctions.dart';
import '../../constant.dart';
import 'package:sizer/sizer.dart';
import '../../classes/language.dart';
import '../../classes/language_constants.dart';
import '../../controllers/notification_service.dart';
import '../../main.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../provider/forceLogoutProvider.dart';
import '../../services/services.dart';
import '../../widgets/popUpNotificationScreen.dart';
import '../Authentication/select_type.dart';
import 'package:awesome_dialog/awesome_dialog.dart' as dlg;
import '../Authentication/sign_in.dart';
import 'Approvals/general_approvals.dart';
import 'Approvals/hr_letter_approval.dart';
import 'Approvals/leave_approvals.dart';
import 'Approvals/replacement_approvals.dart';
import 'Documents/documents.dart';
import 'Leave Return/leave_return_screen.dart';
import 'Requests/general_request.dart';
import 'Requests/hr_letter_request.dart';
import 'Requests/leave_request.dart';
import 'Requests/request_status.dart';

class ESSDashScreen extends StatefulWidget {
  final int usrSlno;
  final String apiUrl;
  final String usrName;
  final String? empImage;
  final String userfirstName;
  final String empEmail;
  final bool empGioFlag;
  final bool mobATTimageFlag;
  final bool empSelfieFlag;
  final bool mobATTFlag;
  final bool mobESSFlag;
  final bool approvalFlag;
  final dynamic locationData;

  const ESSDashScreen(
      {Key? key,
      required this.usrSlno,
      required this.apiUrl,
      required this.usrName,
      required this.empImage,
      required this.userfirstName,
      required this.empEmail,
      required this.empGioFlag,
      required this.mobATTimageFlag,
      required this.empSelfieFlag,
      required this.mobATTFlag,
      required this.mobESSFlag,
      required this.approvalFlag,
      required this.locationData})
      : super(key: key);

  @override
  _ESSDashScreenState createState() => _ESSDashScreenState();
}

class _ESSDashScreenState extends State<ESSDashScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoader = true;
  bool? result;
  int leaveRequestsLen = 0;
  int generalRequestLen = 0;
  int replacementRequestLen = 0;
  int notificationCount = 0;
  List listOfLeaveRequest = [];
  List listOfGeneralRequest = [];
  List listOfReplacementRequest = [];
  List listOfAnnouncement = [];
  DateTime now = new DateTime.now();
  var eligibleCount;
  var usedLeaveCount;
  var bookedLeaveCount;
  var balanceLeaveCount;
  var presentBalanceCount = 0;
  var carriedOverCount = 0;
  var compOffCount;
  bool compOffFlag = false;
  var sickLeaveCount;
  var unpaidLeaveCount;
  var othersCount;
  int? year = int.parse(DateTime.now().year.toString());
  String? annTitle;
  String? annDate;
  String annDesc = ' ';
  String? appStroreLink, playStoreLink;
  String? token;

  PageController pageController = PageController(initialPage: 0);
  CarouselControllerPlus carouselController = CarouselControllerPlus();
  int currentIndexPage = 0;
  //late PDFDocument document;

  bool isAnnouncement = false;
  bool isPiechartValue = false;
  bool adminFlag = false;

  bool documentShowFlag = true;
  bool payslipShowFlag = true;

  bool presentFlag = true;
  // var showAll = false;
  final length = 100;

  Future<bool> _onLogout(BuildContext context) async {
    bool exitResult = await _showLogoutBottomSheet(context);
    return exitResult;
  }

  Future<bool> _showLogoutBottomSheet(BuildContext context) async {
    return await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: _buildBottomSheet(context),
        );
      },
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          height: 20,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              translation(context).logoutApp,
              style: kTextStyle2.copyWith(
                  color: Colors.black54,
                  fontSize: 13.0.sp,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            TextButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(translation(context).cancel),
            ),
            TextButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                ),
              ),
              onPressed: () async {
                await DBProvider.db.deleteItems();
                PushNotifications.deleteTokenFromCloud();
                Navigator.pushAndRemoveUntil<dynamic>(
                  context,
                  MaterialPageRoute<dynamic>(
                      builder: (BuildContext context) =>
                          SignIn(apiURL: widget.apiUrl)),
                  (route) => false,
                );
              },
              child: Text(translation(context).yesLogout),
            ),
          ],
        ),
      ],
    );
  }

  PackageInfo _packageInfo = PackageInfo(
    appName: '',
    packageName: '',
    version: '',
    buildNumber: '',
  );

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    adminFlag = box.read('adminFlag') ?? false;
    _forceLogout();
    initialDashboard();
    _initPackageInfo();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.empImage);
    final fullHeight = MediaQuery.of(context).size.height;
    final appBar = AppBar();
    final appBarHeight =
        appBar.preferredSize.height + MediaQuery.of(context).padding.top;
    final scaffoldBodyHeight = fullHeight - appBarHeight;

    return UpgradeAlert(
      showLater: false,
      showIgnore: false,
      upgrader: Upgrader(
        durationUntilAlertAgain: const Duration(seconds: 0),
      ),
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: CommonServices().getThemeColor(),
        appBar: AppBar(
          backgroundColor: CommonServices().getThemeColor(),
          elevation: 0.0,
          titleSpacing: 0.0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            'ESS',
            // translation(context).ess,
            maxLines: 1,
            style: kTextStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 2.2 * SizeConfigure.textMultiplier!),
          ),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: SvgPicture.asset(
                  "images/drawer.svg",
                  height: 12.sp,
                  color: Colors.white,
                ),
                onPressed: () {
                  isLoader == false ? Scaffold.of(context).openDrawer() : null;
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              );
            },
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: DropdownButton<Language>(
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
                                  fontSize:
                                      2.5 * SizeConfigure.textMultiplier!),
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
            ),
            GestureDetector(
              onTap: () {
                if (notificationCount != 0 && widget.approvalFlag == true) {
                  _showNotification(context);
                }
              },
              child: badges.Badge(
                showBadge:
                    notificationCount != 0 && widget.approvalFlag == true,
                badgeContent: Text(
                  notificationCount.toString(),
                  style: kTextStyle.copyWith(
                      color: Colors.white,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.bold),
                ),
                position: badges.BadgePosition.topEnd(top: 5, end: 7),
                badgeAnimation: badges.BadgeAnimation.slide(
                  animationDuration: Duration(milliseconds: 3000),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 15.0, right: 10.0, left: 10.0),
                  child: Icon(Icons.notifications),
                ),
              ),
            ),
            Visibility(
              visible: (adminFlag && widget.mobATTFlag && !widget.mobESSFlag) ||
                  (adminFlag && !widget.mobATTFlag && widget.mobESSFlag) ||
                  (adminFlag && widget.mobATTFlag && widget.mobESSFlag) ||
                  (!adminFlag && widget.mobATTFlag && widget.mobESSFlag),
              child: Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0, bottom: 8.0, right: 8.0, left: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) => SelectType(
                            usrSlno: widget.usrSlno,
                            apiUrl: widget.apiUrl,
                            usrName: widget.usrName,
                            empImage: widget.empImage,
                            userfirstName: widget.userfirstName,
                            empEmail: widget.empEmail,
                            empGioFlag: widget.empGioFlag,
                            mobATTimageFlag: widget.mobATTimageFlag,
                            empSelfieFlag: widget.empSelfieFlag,
                            mobATTFlag: widget.mobATTFlag,
                            mobESSFlag: widget.mobESSFlag,
                            approvalFlag: widget.approvalFlag,
                            locationData: widget.locationData,
                          ),
                        ),
                        (route) =>
                            false, //if you want to disable back feature set to false
                      );
                    },
                    child: const Icon(
                      Icons.home,
                      size: 26.0,
                    ),
                  )),
            ),
          ],
          automaticallyImplyLeading: false,
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0)),
                  color: CommonServices().getThemeColor(),
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30.0),
                            bottomRight: Radius.circular(30.0)),
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 15.0,
                              ),
                              widget.empImage.isEmptyOrNull
                                  ? const CircleAvatar(
                                      radius: 60.0,
                                      backgroundColor: kMainColor,
                                      backgroundImage: AssetImage(
                                        'images/emp1.png',
                                      ),
                                    )
                                  : CircularProfileAvatar(
                                      widget.apiUrl +
                                          'uploads/Emp_Image/' +
                                          widget.empImage!,
                                      radius: 60.0,
                                      borderWidth: 1,
                                      borderColor: kMainColor,
                                      elevation: 10.0,
                                      foregroundColor:
                                          Colors.brown.withOpacity(0.5),
                                      cacheImage: false,
                                      onTap: () {},
                                    ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                widget.userfirstName,
                                style: kTextStyle.copyWith(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              Text(
                                widget.empEmail ?? 'Email Address',
                                style:
                                    kTextStyle.copyWith(color: kGreyTextColor),
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                            ],
                          ).onTap(() {}),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(
                              translation(context).dotsgo,
                              style: kTextStyle.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              'V ${_packageInfo.version}',
                              style: kTextStyle.copyWith(color: Colors.white),
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              ExpansionTile(
                leading: const Icon(
                  FontAwesomeIcons.bank,
                  color: kMainColor,
                ),
                title: Text(
                  translation(context).myAccount,
                  style: kTextStyle.copyWith(color: kGreyTextColor),
                ),
                children: <Widget>[
                  ListTile(
                    onTap: () {
                      Navigator.pushAndRemoveUntil<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) => ProfileScreen(
                            usrSlno: widget.usrSlno,
                            apiUrl: widget.apiUrl,
                            usrName: widget.usrName,
                            empImage: widget.empImage,
                            userfirstName: widget.userfirstName,
                            empEmail: widget.empEmail,
                            empGioFlag: widget.empGioFlag,
                            mobATTimageFlag: widget.mobATTimageFlag,
                            empSelfieFlag: widget.empSelfieFlag,
                            mobATTFlag: widget.mobATTFlag,
                            mobESSFlag: widget.mobESSFlag,
                            approvalFlag: widget.approvalFlag,
                            locationData: widget.locationData,
                          ),
                        ),
                        (route) =>
                            false, //if you want to disable back feature set to false
                      );
                    },
                    leading: const Icon(
                      FontAwesomeIcons.user,
                      color: kGreyTextColor,
                    ),
                    title: Text(
                      translation(context).profile,
                      style: kTextStyle.copyWith(color: kGreyTextColor),
                    ),
                  ),
                  if (documentShowFlag == true)
                    ListTile(
                      onTap: () {
                        Navigator.pushAndRemoveUntil<dynamic>(
                          context,
                          MaterialPageRoute<dynamic>(
                            builder: (BuildContext context) => DocumentScreen(
                              usrSlno: widget.usrSlno,
                              apiUrl: widget.apiUrl,
                              usrName: widget.usrName,
                              empImage: widget.empImage,
                              userfirstName: widget.userfirstName,
                              empEmail: widget.empEmail,
                              empGioFlag: widget.empGioFlag,
                              mobATTimageFlag: widget.mobATTimageFlag,
                              empSelfieFlag: widget.empSelfieFlag,
                              mobATTFlag: widget.mobATTFlag,
                              mobESSFlag: widget.mobESSFlag,
                              approvalFlag: widget.approvalFlag,
                              locationData: widget.locationData,
                            ),
                          ),
                          (route) =>
                              false, //if you want to disable back feature set to false
                        );
                      },
                      leading: const Icon(
                        FontAwesomeIcons.passport,
                        color: kGreyTextColor,
                      ),
                      title: Text(
                        translation(context).document,
                        style: kTextStyle.copyWith(color: kGreyTextColor),
                      ),
                    ),
                  if (payslipShowFlag == true)
                    ListTile(
                      onTap: () {
                        Navigator.pushAndRemoveUntil<dynamic>(
                          context,
                          MaterialPageRoute<dynamic>(
                            builder: (BuildContext context) => Payslip(
                              usrSlno: widget.usrSlno,
                              apiUrl: widget.apiUrl,
                              usrName: widget.usrName,
                              empImage: widget.empImage,
                              userfirstName: widget.userfirstName,
                              empEmail: widget.empEmail,
                              empGioFlag: widget.empGioFlag,
                              mobATTimageFlag: widget.mobATTimageFlag,
                              empSelfieFlag: widget.empSelfieFlag,
                              mobATTFlag: widget.mobATTFlag,
                              mobESSFlag: widget.mobESSFlag,
                              approvalFlag: widget.approvalFlag,
                              locationData: widget.locationData,
                            ),
                          ),
                          (route) =>
                              false, //if you want to disable back feature set to false
                        );
                      },
                      leading: const Icon(
                        Icons.payments_outlined,
                        color: kGreyTextColor,
                      ),
                      title: Text(
                        translation(context).payslip,
                        style: kTextStyle.copyWith(color: kGreyTextColor),
                      ),
                    ),
                ],
              ),
              ExpansionTile(
                leading: const Icon(
                  FontAwesomeIcons.fileArrowUp,
                  color: kMainColor,
                ),
                title: Text(
                  translation(context).newRequest,
                  style: kTextStyle.copyWith(color: kGreyTextColor),
                ),
                children: <Widget>[
                  ListTile(
                    onTap: () {
                      Navigator.pushAndRemoveUntil<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) => RequestLeave(
                            usrSlno: widget.usrSlno,
                            apiUrl: widget.apiUrl,
                            usrName: widget.usrName,
                            empImage: widget.empImage,
                            userfirstName: widget.userfirstName,
                            empEmail: widget.empEmail,
                            empGioFlag: widget.empGioFlag,
                            mobATTimageFlag: widget.mobATTimageFlag,
                            empSelfieFlag: widget.empSelfieFlag,
                            mobATTFlag: widget.mobATTFlag,
                            mobESSFlag: widget.mobESSFlag,
                            approvalFlag: widget.approvalFlag,
                            locationData: widget.locationData,
                          ),
                        ),
                        (route) =>
                            false, //if you want to disable back feature set to false
                      );
                    },
                    leading: const Icon(
                      FontAwesomeIcons.calendarCheck,
                      color: kGreyTextColor,
                    ),
                    title: Text(
                      translation(context).leaveRequests,
                      style: kTextStyle.copyWith(color: kGreyTextColor),
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.pushAndRemoveUntil<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) => RequestGeneral(
                            usrSlno: widget.usrSlno,
                            apiUrl: widget.apiUrl,
                            usrName: widget.usrName,
                            empImage: widget.empImage,
                            userfirstName: widget.userfirstName,
                            empEmail: widget.empEmail,
                            empGioFlag: widget.empGioFlag,
                            mobATTimageFlag: widget.mobATTimageFlag,
                            empSelfieFlag: widget.empSelfieFlag,
                            mobATTFlag: widget.mobATTFlag,
                            mobESSFlag: widget.mobESSFlag,
                            approvalFlag: widget.approvalFlag,
                            locationData: widget.locationData,
                          ),
                        ),
                        (route) =>
                            false, //if you want to disable back feature set to false
                      );
                    },
                    leading: const Icon(
                      FontAwesomeIcons.fileLines,
                      color: kGreyTextColor,
                    ),
                    title: Text(
                      translation(context).generalRequests,
                      style: kTextStyle.copyWith(color: kGreyTextColor),
                    ),
                  ),
                  //faris -exp
                  ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) =>
                              ExpenseClaimScreen(),
                        ),
                      );
                    },
                    leading: Icon(
                      FontAwesomeIcons.fileInvoiceDollar,
                      color: kGreyTextColor,
                    ),
                    title: Text(
                      translation(context).expanseClaimRequest,
                      style: kTextStyle.copyWith(color: kGreyTextColor),
                    ),
                  ),
                  //faris -exp
                  ListTile(
                    onTap: () {
                      Navigator.pushAndRemoveUntil<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                            builder: (BuildContext context) =>
                                HrLetterHomeScreen(
                                  usrSlno: widget.usrSlno,
                                  apiUrl: widget.apiUrl,
                                  usrName: widget.usrName,
                                  empImage: widget.empImage,
                                  userfirstName: widget.userfirstName,
                                  empEmail: widget.empEmail,
                                  empGioFlag: widget.empGioFlag,
                                  mobATTimageFlag: widget.mobATTimageFlag,
                                  empSelfieFlag: widget.empSelfieFlag,
                                  mobATTFlag: widget.mobATTFlag,
                                  mobESSFlag: widget.mobESSFlag,
                                  approvalFlag: widget.approvalFlag,
                                  locationData: widget.locationData,
                                )),
                        (route) =>
                            false, //if you want to disable back feature set to false
                      );
                    },
                    leading: const Icon(
                      Icons.request_page_outlined,
                      color: kGreyTextColor,
                    ),
                    title: Text(
                      translation(context).hrletter,
                      style: kTextStyle.copyWith(color: kGreyTextColor),
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: widget.approvalFlag,
                child: ExpansionTile(
                  leading: const Icon(
                    Icons.group,
                    color: kMainColor,
                  ),
                  title: Text(
                    translation(context).approvals,
                    style: kTextStyle.copyWith(color: kGreyTextColor),
                  ),
                  children: <Widget>[
                    ListTile(
                      onTap: () {
                        Navigator.pushAndRemoveUntil<dynamic>(
                          context,
                          MaterialPageRoute<dynamic>(
                            builder: (BuildContext context) => LeaveApprovals(
                              usrSlno: widget.usrSlno,
                              apiUrl: widget.apiUrl,
                              usrName: widget.usrName,
                              empImage: widget.empImage,
                              userfirstName: widget.userfirstName,
                              empEmail: widget.empEmail,
                              empGioFlag: widget.empGioFlag,
                              mobATTimageFlag: widget.mobATTimageFlag,
                              empSelfieFlag: widget.empSelfieFlag,
                              mobATTFlag: widget.mobATTFlag,
                              mobESSFlag: widget.mobESSFlag,
                              approvalFlag: widget.approvalFlag,
                              locationData: widget.locationData,
                            ),
                          ),
                          (route) =>
                              false, //if you want to disable back feature set to false
                        );
                      },
                      leading: const Icon(
                        FontAwesomeIcons.calendarCheck,
                        color: kGreyTextColor,
                      ),
                      title: Text(
                        translation(context).leaveApprovals,
                        style: kTextStyle.copyWith(color: kGreyTextColor),
                      ),
                    ),
                    ListTile(
                      onTap: () {
                        Navigator.pushAndRemoveUntil<dynamic>(
                          context,
                          MaterialPageRoute<dynamic>(
                            builder: (BuildContext context) => GeneralApprovals(
                              usrSlno: widget.usrSlno,
                              apiUrl: widget.apiUrl,
                              usrName: widget.usrName,
                              empImage: widget.empImage,
                              userfirstName: widget.userfirstName,
                              empEmail: widget.empEmail,
                              empGioFlag: widget.empGioFlag,
                              mobATTimageFlag: widget.mobATTimageFlag,
                              empSelfieFlag: widget.empSelfieFlag,
                              mobATTFlag: widget.mobATTFlag,
                              mobESSFlag: widget.mobESSFlag,
                              approvalFlag: widget.approvalFlag,
                              locationData: widget.locationData,
                            ),
                          ),
                          (route) =>
                              false, //if you want to disable back feature set to false
                        );
                      },
                      leading: const Icon(
                        FontAwesomeIcons.fileLines,
                        color: kGreyTextColor,
                      ),
                      title: Text(
                        translation(context).generalApprovals,
                        style: kTextStyle.copyWith(color: kGreyTextColor),
                      ),
                    ),
                    ListTile(
                      onTap: () {
                        Navigator.pushAndRemoveUntil<dynamic>(
                          context,
                          MaterialPageRoute<dynamic>(
                              builder: (BuildContext context) =>
                                  HrLetterApprovalScreeen(
                                    usrSlno: widget.usrSlno,
                                    apiUrl: widget.apiUrl,
                                    usrName: widget.usrName,
                                    empImage: widget.empImage,
                                    userfirstName: widget.userfirstName,
                                    empEmail: widget.empEmail,
                                    empGioFlag: widget.empGioFlag,
                                    mobATTimageFlag: widget.mobATTimageFlag,
                                    empSelfieFlag: widget.empSelfieFlag,
                                    mobATTFlag: widget.mobATTFlag,
                                    mobESSFlag: widget.mobESSFlag,
                                    approvalFlag: widget.approvalFlag,
                                    locationData: widget.locationData,
                                  )),
                          (route) =>
                              false, //if you want to disable back feature set to false
                        );
                      },
                      leading: const Icon(
                        Icons.request_page_outlined,
                        color: kGreyTextColor,
                      ),
                      title: Text(
                        translation(context).hrletterapprovals,
                        style: kTextStyle.copyWith(color: kGreyTextColor),
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.pushAndRemoveUntil<dynamic>(
                    context,
                    MaterialPageRoute<dynamic>(
                      builder: (BuildContext context) => LeaveReturnScreen(
                        usrSlno: widget.usrSlno,
                        apiUrl: widget.apiUrl,
                        usrName: widget.usrName,
                        empImage: widget.empImage,
                        userfirstName: widget.userfirstName,
                        empEmail: widget.empEmail,
                        empGioFlag: widget.empGioFlag,
                        mobATTimageFlag: widget.mobATTimageFlag,
                        empSelfieFlag: widget.empSelfieFlag,
                        mobATTFlag: widget.mobATTFlag,
                        mobESSFlag: widget.mobESSFlag,
                        approvalFlag: widget.approvalFlag,
                        locationData: widget.locationData,
                      ),
                    ),
                    (route) =>
                        false, //if you want to disable back feature set to false
                  );
                },
                leading: const Icon(
                  Icons.assignment_return_outlined,
                  color: kMainColor,
                ),
                title: Text(
                  translation(context).leavereturn,
                  style: kTextStyle.copyWith(color: kGreyTextColor),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.pushAndRemoveUntil<dynamic>(
                    context,
                    MaterialPageRoute<dynamic>(
                      builder: (BuildContext context) => RequestStatus(
                        usrSlno: widget.usrSlno,
                        apiUrl: widget.apiUrl,
                        usrName: widget.usrName,
                        empImage: widget.empImage,
                        userfirstName: widget.userfirstName,
                        empEmail: widget.empEmail,
                        empGioFlag: widget.empGioFlag,
                        mobATTimageFlag: widget.mobATTimageFlag,
                        empSelfieFlag: widget.empSelfieFlag,
                        mobATTFlag: widget.mobATTFlag,
                        mobESSFlag: widget.mobESSFlag,
                        approvalFlag: widget.approvalFlag,
                        locationData: widget.locationData,
                      ),
                    ),
                    (route) =>
                        false, //if you want to disable back feature set to false
                  );
                },
                leading: const Icon(
                  Icons.mark_unread_chat_alt,
                  color: kMainColor,
                ),
                title: Text(
                  translation(context).requestStatus,
                  style: kTextStyle.copyWith(color: kGreyTextColor),
                ),
              ),
              Visibility(
                visible: replacementRequestLen != 0,
                child: ListTile(
                  onTap: () {
                    Navigator.pushAndRemoveUntil<dynamic>(
                      context,
                      MaterialPageRoute<dynamic>(
                        builder: (BuildContext context) => ReplacementApprovals(
                          usrSlno: widget.usrSlno,
                          apiUrl: widget.apiUrl,
                          usrName: widget.usrName,
                          empImage: widget.empImage,
                          userfirstName: widget.userfirstName,
                          empEmail: widget.empEmail,
                          empGioFlag: widget.empGioFlag,
                          mobATTimageFlag: widget.mobATTimageFlag,
                          empSelfieFlag: widget.empSelfieFlag,
                          mobATTFlag: widget.mobATTFlag,
                          mobESSFlag: widget.mobESSFlag,
                          approvalFlag: widget.approvalFlag,
                          locationData: widget.locationData,
                        ),
                      ),
                      (route) =>
                          false, //if you want to disable back feature set to false
                    );
                  },
                  leading: const Icon(
                    Icons.find_replace,
                    color: kMainColor,
                  ),
                  title: Text(
                    translation(context).replacementRequest,
                    style: kTextStyle.copyWith(color: kGreyTextColor),
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    Share.share(
                        'check out DOTS Go+ App on \n iOS : $appStroreLink \n Android : $playStoreLink');
                  });
                },
                leading: const Icon(
                  FontAwesomeIcons.share,
                  color: kMainColor,
                ),
                title: Text(
                  translation(context).share,
                  style: kTextStyle.copyWith(color: kGreyTextColor),
                ),
              ),
              ListTile(
                onTap: () {
                  _onLogout(context);
                },
                leading: const Icon(
                  FontAwesomeIcons.signOutAlt,
                  color: kMainColor,
                ),
                title: Text(
                  translation(context).logout,
                  style: kTextStyle.copyWith(color: kGreyTextColor),
                ),
              ),
            ],
          ),
        ),
        body: PopScope(
          canPop: false,
          onPopInvoked: (val) {
            if ((adminFlag && widget.mobATTFlag && !widget.mobESSFlag) ||
                (adminFlag && !widget.mobATTFlag && widget.mobESSFlag) ||
                (adminFlag && widget.mobATTFlag && widget.mobESSFlag) ||
                (!adminFlag && widget.mobATTFlag && widget.mobESSFlag)) {
              Navigator.pushAndRemoveUntil<dynamic>(
                context,
                MaterialPageRoute<dynamic>(
                  builder: (BuildContext context) => SelectType(
                    usrSlno: widget.usrSlno,
                    apiUrl: widget.apiUrl,
                    usrName: widget.usrName,
                    empImage: widget.empImage,
                    userfirstName: widget.userfirstName,
                    empEmail: widget.empEmail,
                    empGioFlag: widget.empGioFlag,
                    mobATTimageFlag: widget.mobATTimageFlag,
                    empSelfieFlag: widget.empSelfieFlag,
                    mobATTFlag: widget.mobATTFlag,
                    mobESSFlag: widget.mobESSFlag,
                    approvalFlag: widget.approvalFlag,
                    locationData: widget.locationData,
                  ),
                ),
                (route) =>
                    false, //if you want to disable back feature set to false
              );
            } else {
              _onWillPop();
            }
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        greeting(),
                        style: kTextStyle.copyWith(
                            color: Colors.white,
                            fontSize: 2.2 * SizeConfigure.textMultiplier!,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 5.0,
                      ),
                      Text(
                        widget.userfirstName,
                        style: kTextStyle.copyWith(
                            color: Colors.white,
                            fontSize: 2.2 * SizeConfigure.textMultiplier!,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 5.0,
                      ),
                      Text(
                        '👋',
                        style: kTextStyle.copyWith(
                            color: Colors.white,
                            fontSize: 2.2 * SizeConfigure.textMultiplier!,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 5.0, left: 20.0, right: 20.0),
                  child: Text(
                    translation(context).welcomeText,
                    style: kTextStyle.copyWith(
                      color: Colors.white,
                      fontSize: 1.8 * SizeConfigure.textMultiplier!,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Container(
                  padding: EdgeInsets.all(
                    1 * SizeConfigure.heightMultiplier!,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFF7F7FC),
                    // gradient: LinearGradient(
                    // begin: Alignment.topLeft,
                    // end: Alignment.bottomRight,
                    // stops: [0.1, 0.3, 0.7, 1],
                    // colors: [Colors.blue.shade50, Colors.yellow.shade50, Colors.orange.shade50, Colors.blue.shade50]),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0)),
                  ),
                  child: isLoader == true
                      ? Container(
                          width: context.width(),
                          height: scaffoldBodyHeight,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Lottie.asset('images/loading.json'),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Fade(
                          duration: const Duration(milliseconds: 1000),
                          fadeEffect: FadeEffect.fadeIn,
                          child: Column(
                            children: [
                              Visibility(
                                visible: isAnnouncement,
                                child: CarouselSlider.builder(
                                  itemCount: listOfAnnouncement.length,
                                  itemBuilder: (BuildContext context,
                                          int itemIndex, int pageViewIndex) =>
                                      Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15))),
                                    elevation: 5,
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(15)),
                                      child: Container(
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.only(
                                                  left: 2 *
                                                      SizeConfigure
                                                          .widthMultiplier!,
                                                  right: 2 *
                                                      SizeConfigure
                                                          .widthMultiplier!),
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                    colors: [
                                                      Colors.blue.shade400,
                                                      Colors.blue.shade500,
                                                      Colors.blue.shade600,
                                                      kMainColor
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    //begin of the gradient color
                                                    end: Alignment.bottomRight,
                                                    stops: [
                                                      0.2,
                                                      0.4,
                                                      0.5,
                                                      0.8
                                                    ] //stops for individual color
                                                    //set the stops number equal to numbers of color
                                                    ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Expanded(
                                                    flex: 3,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 3.0),
                                                              child: Icon(
                                                                FontAwesomeIcons
                                                                    .bullhorn,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                            SizedBox(width: 10),
                                                            Text(
                                                              translation(
                                                                      context)
                                                                  .announcement,
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 5),
                                                        Text(
                                                          listOfAnnouncement[
                                                                  itemIndex]
                                                              ['title'],
                                                          style: kTextStyle
                                                              .copyWith(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      13.sp),
                                                        ),
                                                        SizedBox(height: 5),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Lottie.asset(
                                                          'images/mic.json',
                                                          height: 10 *
                                                              SizeConfigure
                                                                  .heightMultiplier!)),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.only(
                                                  top: 2 *
                                                      SizeConfigure
                                                          .heightMultiplier!,
                                                  left: 2 *
                                                      SizeConfigure
                                                          .heightMultiplier!,
                                                  right: 2 *
                                                      SizeConfigure
                                                          .heightMultiplier!),
                                              child: Column(
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      SizedBox(
                                                        width: 3 *
                                                            SizeConfigure
                                                                .widthMultiplier!,
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Text(
                                                              translation(
                                                                      context)
                                                                  .addedOn,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize:
                                                                      8.sp),
                                                            ),
                                                            SizedBox(
                                                              height: 4,
                                                            ),
                                                            Text(
                                                              listOfAnnouncement[
                                                                      itemIndex]
                                                                  ['date'],
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          16)),
                                                          child:
                                                              GestureDetector(
                                                                  onTap:
                                                                      () => {
                                                                            inform(listOfAnnouncement[itemIndex]['filename'])
                                                                          },
                                                                  child: listOfAnnouncement[itemIndex]
                                                                              [
                                                                              'filename'] !=
                                                                          null
                                                                      ? isImage(listOfAnnouncement[itemIndex]
                                                                              [
                                                                              'filename'])
                                                                          ? Image
                                                                              .asset(
                                                                              "images/imgIcon.png",
                                                                              width: 10 * SizeConfigure.widthMultiplier!,
                                                                            )
                                                                          : Image
                                                                              .asset(
                                                                              "images/pdfIcon.png",
                                                                              width: 10 * SizeConfigure.widthMultiplier!,
                                                                            )
                                                                      : Text(
                                                                          ''))),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 12,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text.rich(
                                                          TextSpan(
                                                            children: <InlineSpan>[
                                                              TextSpan(
                                                                text: listOfAnnouncement[itemIndex]['Description']
                                                                            .length >
                                                                        length
                                                                    //&& !showAll
                                                                    ? listOfAnnouncement[itemIndex]['Description'].substring(
                                                                            0,
                                                                            length) +
                                                                        "..."
                                                                    : listOfAnnouncement[
                                                                            itemIndex]
                                                                        [
                                                                        'Description'],
                                                                style: kTextStyle.copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                    fontSize:
                                                                        11.sp,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                              listOfAnnouncement[itemIndex]
                                                                              [
                                                                              'Description']
                                                                          .length >
                                                                      length
                                                                  ? WidgetSpan(
                                                                      child:
                                                                          Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              8.0,
                                                                          right:
                                                                              8.0),
                                                                      child:
                                                                          GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          openAlertBox(
                                                                              listOfAnnouncement[itemIndex]['title'],
                                                                              listOfAnnouncement[itemIndex]['Description']);
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(20.0),
                                                                            color:
                                                                                kMainColor.withOpacity(0.08),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(left: 8.0, right: 8.0),
                                                                            child:
                                                                                Text(
                                                                              translation(context).more,
                                                                              style: kTextStyle.copyWith(color: kMainColor, fontSize: 10.sp),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ))
                                                                  : TextSpan(),
                                                            ],
                                                          ),
                                                          textAlign:
                                                              TextAlign.justify,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  //Slider Container properties
                                  controller: carouselController,
                                  options: CarouselOptions(
                                    enlargeCenterPage: true,
                                    autoPlay: listOfAnnouncement.length != 1,
                                    autoPlayCurve: Curves.fastOutSlowIn,
                                    enableInfiniteScroll: true,
                                    height:
                                        37 * SizeConfigure.heightMultiplier!,
                                    pauseAutoPlayOnTouch: true,
                                    autoPlayAnimationDuration:
                                        Duration(milliseconds: 1000),
                                    viewportFraction: 0.999,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              Container(
                                width: context.width(),
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF7F7FC),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  children: [
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              translation(context).annualLeave,
                                              style: kTextStyle.copyWith(
                                                  fontSize: 12.0.sp),
                                            ),
                                            const Spacer(),
                                            Container(
                                              height: 30.0,
                                              width: 120.0,
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                                color: kMainColor,
                                              ),
                                              child: Center(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator
                                                        .pushAndRemoveUntil<
                                                            dynamic>(
                                                      context,
                                                      MaterialPageRoute<
                                                          dynamic>(
                                                        builder: (BuildContext
                                                                context) =>
                                                            RequestLeave(
                                                          usrSlno:
                                                              widget.usrSlno,
                                                          apiUrl: widget.apiUrl,
                                                          usrName:
                                                              widget.usrName,
                                                          empImage:
                                                              widget.empImage,
                                                          userfirstName: widget
                                                              .userfirstName,
                                                          empEmail:
                                                              widget.empEmail,
                                                          empGioFlag:
                                                              widget.empGioFlag,
                                                          mobATTimageFlag: widget
                                                              .mobATTimageFlag,
                                                          empSelfieFlag: widget
                                                              .empSelfieFlag,
                                                          mobATTFlag:
                                                              widget.mobATTFlag,
                                                          mobESSFlag:
                                                              widget.mobESSFlag,
                                                          approvalFlag: widget
                                                              .approvalFlag,
                                                          locationData: widget
                                                              .locationData,
                                                        ),
                                                      ),
                                                      (route) => false,
                                                    );
                                                  },
                                                  child: Text(
                                                    translation(context)
                                                        .applyLeave,
                                                    style: kTextStyle.copyWith(
                                                        color: Colors.white,
                                                        fontSize: 12.sp),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10.0,
                                        ),
                                        Material(
                                          elevation: 5.0,
                                          child: GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                              width: context.width(),
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                              ),
                                              child: Column(
                                                children: [
                                                  Visibility(
                                                    visible: isPiechartValue,
                                                    child: Container(
                                                      height: 250,
                                                      child: Stack(
                                                        children: [
                                                          DChartPieO(
                                                            data: [
                                                              OrdinalData(
                                                                  domain: translation(
                                                                          context)
                                                                      .utilized,
                                                                  measure:
                                                                      usedLeaveCount ??
                                                                          0,
                                                                  color: Colors
                                                                          .red[
                                                                      500]),
                                                              OrdinalData(
                                                                  domain: translation(
                                                                          context)
                                                                      .booked,
                                                                  measure:
                                                                      bookedLeaveCount ??
                                                                          0,
                                                                  color: Colors
                                                                          .orange[
                                                                      500]),
                                                              OrdinalData(
                                                                  domain: translation(
                                                                          context)
                                                                      .balanceLeave,
                                                                  measure:
                                                                      balanceLeaveCount ??
                                                                          0,
                                                                  color: Colors
                                                                          .green[
                                                                      500]),
                                                            ],
                                                            customLabel:
                                                                (barData, id) {
                                                              if (barData
                                                                      .measure !=
                                                                  0) {
                                                                return barData
                                                                    .measure
                                                                    .toString();
                                                              } else {
                                                                return '';
                                                              }
                                                            },
                                                            configRenderPie:
                                                                ConfigRenderPie(
                                                                    arcWidth:
                                                                        30,
                                                                    arcLength:
                                                                        7 /
                                                                            5 *
                                                                            pi,
                                                                    startAngle:
                                                                        4 /
                                                                            5 *
                                                                            pi,
                                                                    arcLabelDecorator: ArcLabelDecorator(
                                                                        showLeaderLines: true,
                                                                        outsideLabelStyle: LabelStyle(
                                                                          fontSize:
                                                                              17,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                        labelPosition: ArcLabelPosition.outside,
                                                                        leaderLineStyle: ArcLabelLeaderLineStyle(color: Colors.black, length: 8.0, thickness: 1.5))),
                                                            animationDuration:
                                                                Duration(
                                                                    milliseconds:
                                                                        1000),
                                                            animate: true,
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .center, // Adjust alignment as needed
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center, // Center the text horizontally
                                                              children: [
                                                                Text(
                                                                  eligibleCount
                                                                      .toString(),
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        15.sp,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  translation(
                                                                          context)
                                                                      .yearlyEligible,
                                                                  style: kTextStyle
                                                                      .copyWith(
                                                                    fontSize:
                                                                        10.sp,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Positioned(
                                                            bottom: 3 *
                                                                SizeConfigure
                                                                    .heightMultiplier!,
                                                            left: 0,
                                                            right: 0,
                                                            child: Align(
                                                                child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                _buildSquare(
                                                                    Colors.red,
                                                                    usedLeaveCount
                                                                        .toString(),
                                                                    translation(
                                                                            context)
                                                                        .utilized),
                                                                SizedBox(
                                                                    width: 2 *
                                                                        SizeConfigure
                                                                            .widthMultiplier!),
                                                                _buildSquare(
                                                                    Colors
                                                                        .orange,
                                                                    bookedLeaveCount
                                                                        .toString(),
                                                                    translation(
                                                                            context)
                                                                        .booked),
                                                                SizedBox(
                                                                    width: 2 *
                                                                        SizeConfigure
                                                                            .widthMultiplier!),
                                                                _buildSquare(
                                                                    Colors
                                                                        .green,
                                                                    balanceLeaveCount
                                                                        .toString(),
                                                                    translation(
                                                                            context)
                                                                        .balanceLeave),
                                                              ],
                                                            )),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Visibility(
                                                        visible: presentFlag,
                                                        child: Expanded(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(2.0),
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 10.0,
                                                                      bottom:
                                                                          10.0,
                                                                      left:
                                                                          10.0,
                                                                      right:
                                                                          10.0),
                                                              decoration:
                                                                  BoxDecoration(
                                                                border:
                                                                    const Border(
                                                                        top:
                                                                            BorderSide(
                                                                  color: const Color(
                                                                      0xFF4CE364),
                                                                )),
                                                                color: const Color(
                                                                        0xFF4CE364)
                                                                    .withOpacity(
                                                                        0.1),
                                                              ),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                          presentBalanceCount
                                                                              .toString(),
                                                                          style: kTextStyle.copyWith(
                                                                              color: const Color(0xFF4CE364),
                                                                              fontSize: 15.0.sp,
                                                                              fontWeight: FontWeight.bold)),
                                                                      Text(
                                                                          translation(context)
                                                                              .days,
                                                                          style:
                                                                              kTextStyle.copyWith(
                                                                            color:
                                                                                const Color(0xFF4CE364),
                                                                            fontSize:
                                                                                11.0.sp,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          )),
                                                                      const Spacer(),
                                                                      Icon(
                                                                        FontAwesomeIcons
                                                                            .calendarCheck,
                                                                        color: const Color(
                                                                            0xFF4CE364),
                                                                        size: 20
                                                                            .sp,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Text(
                                                                    translation(
                                                                            context)
                                                                        .presentBalance,
                                                                    style: kTextStyle.copyWith(
                                                                        fontSize:
                                                                            11.sp),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 10.0,
                                                                    bottom:
                                                                        10.0,
                                                                    left: 10.0,
                                                                    right: 5.0),
                                                            decoration:
                                                                BoxDecoration(
                                                              border: const Border(
                                                                  top: BorderSide(
                                                                color: kHalfDay,
                                                              )),
                                                              color: kHalfDay
                                                                  .withOpacity(
                                                                      0.1),
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                        carriedOverCount
                                                                            .toString(),
                                                                        style: kTextStyle.copyWith(
                                                                            color:
                                                                                kHalfDay,
                                                                            fontSize:
                                                                                15.0.sp,
                                                                            fontWeight: FontWeight.bold)),
                                                                    Text(
                                                                        translation(context)
                                                                            .days,
                                                                        style: kTextStyle
                                                                            .copyWith(
                                                                          color:
                                                                              kHalfDay,
                                                                          fontSize:
                                                                              11.0.sp,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        )),
                                                                    const Spacer(),
                                                                    Icon(
                                                                      FontAwesomeIcons
                                                                          .solidCalendarMinus,
                                                                      color:
                                                                          kHalfDay,
                                                                      size:
                                                                          20.sp,
                                                                    ),
                                                                  ],
                                                                ),
                                                                Text(
                                                                  translation(
                                                                          context)
                                                                      .carriedOver,
                                                                  style: kTextStyle
                                                                      .copyWith(
                                                                          fontSize:
                                                                              11.sp),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Visibility(
                                                    visible: compOffFlag,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 10.0,
                                                                bottom: 10.0,
                                                                left: 10.0,
                                                                right: 10.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          border: const Border(
                                                              top: BorderSide(
                                                            color: Colors.cyan,
                                                          )),
                                                          color: Colors.cyan
                                                              .withOpacity(0.1),
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                    compOffCount
                                                                        .toString(),
                                                                    style: kTextStyle.copyWith(
                                                                        color: Colors
                                                                            .cyan,
                                                                        fontSize:
                                                                            15.0
                                                                                .sp,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                Text(
                                                                    translation(
                                                                            context)
                                                                        .days,
                                                                    style: kTextStyle
                                                                        .copyWith(
                                                                      color: Colors
                                                                          .cyan,
                                                                      fontSize:
                                                                          11.0.sp,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    )),
                                                                const Spacer(),
                                                                Icon(
                                                                  FontAwesomeIcons
                                                                      .userClock,
                                                                  color: Colors
                                                                      .cyan,
                                                                  size: 20.sp,
                                                                ),
                                                              ],
                                                            ),
                                                            Text(
                                                              translation(
                                                                      context)
                                                                  .compOffBal,
                                                              style: kTextStyle
                                                                  .copyWith(
                                                                      fontSize:
                                                                          11.sp),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5.0,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              Row(
                                children: [
                                  Text(
                                    translation(context).leave,
                                    style:
                                        kTextStyle.copyWith(fontSize: 12.0.sp),
                                  ),
                                  const Spacer(),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              translation(context).currentYear,
                                          style: kTextStyle.copyWith(
                                              color: kGreyTextColor,
                                              fontSize: 11.0.sp),
                                        ),
                                        TextSpan(
                                          text: year.toString() ?? ' ',
                                          style: kTextStyle.copyWith(
                                              color: kGreyTextColor,
                                              fontSize: 11.0.sp),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              Material(
                                elevation: 5.0,
                                child: GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    width: context.width(),
                                    padding: const EdgeInsets.all(20.0),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    child: Column(
                                      children: [
                                        AspectRatio(
                                          aspectRatio: 16 / 16,
                                          child: DChartBarO(
                                            groupList: [
                                              OrdinalGroup(
                                                id: '1',
                                                data: [
                                                  OrdinalData(
                                                      domain:
                                                          translation(context)
                                                              .sickLeave,
                                                      measure:
                                                          sickLeaveCount ?? 0),
                                                  OrdinalData(
                                                      domain:
                                                          translation(context)
                                                              .unpaidLeave,
                                                      measure:
                                                          unpaidLeaveCount ??
                                                              0),
                                                  OrdinalData(
                                                      domain: !presentFlag
                                                          ? translation(context)
                                                              .casualLeave
                                                          : translation(context)
                                                              .others,
                                                      measure:
                                                          othersCount ?? 0),
                                                ],
                                              ),
                                            ],
                                            barLabelValue:
                                                (barData, index, id) {
                                              return index.measure.toString();
                                            },
                                            // barLabelDecorator:
                                            //     BarLabelDecorator(
                                            //   labelAnchor: BarLabelAnchor.start,
                                            //   barLabelPosition:
                                            //       BarLabelPosition.right,
                                            // ),
                                            fillColor: (barData, index, id) {
                                              return index.measure >= 5
                                                  ? Colors.green.shade700
                                                  : Colors.green.shade300;
                                            },
                                            domainAxis: DomainAxis(
                                              showLine: true,
                                              labelAnchor: LabelAnchor.centered,
                                              labelStyle: LabelStyle(
                                                  color: Colors.black,
                                                  fontSize: 12),
                                            ),
                                            vertical: true,
                                            measureAxis: MeasureAxis(
                                              showLine: true,
                                              labelAnchor: LabelAnchor.centered,
                                              labelStyle: LabelStyle(
                                                  color: Colors.black,
                                                  fontSize: 12),
                                              tickLength: 2,
                                            ),
                                            animationDuration:
                                                Duration(milliseconds: 1000),
                                            animate: true,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsets.symmetric(vertical: 8),
                                          child: Text(
                                            year.toString() ?? ' ',
                                            style: kTextStyle.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                                fontSize: 12.sp),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //load dashboard data
  void initialDashboard() async {
    bool result = await InternetConnectionChecker().hasConnection;
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    if (result == true) {
      setState(() {
        isLoader = true;
      });

      String initialServiceUrl = widget.apiUrl;
      try {
        var user = {"user_slno": widget.usrSlno};
        Map<String, String> body = {'data': json.encode(user)};

        FormData formData = FormData.fromMap(body);
        Dio dio = new Dio();
        dio.options.headers['content-Type'] = 'multipart/form-data';
        dio.options.headers['Authorization'] = token!;
        dio.options.connectTimeout = Duration(seconds: 15);
        dio.options.receiveTimeout = Duration(seconds: 15);
        dio.interceptors.add(
          RetryInterceptor(
            dio: dio,
            logPrint: print,
            retries: 4,
            retryDelays: const [
              Duration(seconds: 1),
              Duration(seconds: 2),
              Duration(seconds: 3),
              Duration(seconds: 4),
            ],
          ),
        );
        final response = await dio.post(
            initialServiceUrl + "dndApi/Load_ESS_DashBoardPageData_mobile",
            data: formData);
        if (response.data['result'] == false) {
          eligibleCount = 0;
          usedLeaveCount = 0;
          bookedLeaveCount = 0;
          balanceLeaveCount = 0;
          presentBalanceCount = 0;
          carriedOverCount = 0;
          sickLeaveCount = 0;
          unpaidLeaveCount = 0;
          othersCount = 0;
          year = 0;
          Fluttertoast.showToast(
              msg: translation(context).tryAgain,
              toastLength: Toast.LENGTH_SHORT,
              backgroundColor: Colors.red[900],
              textColor: Colors.white);
          setState(() {
            isLoader = false;
          });
        } else {
          eligibleCount = response.data['result'][1][0]['TotalLeaveDays'] ?? 0;
          usedLeaveCount = response.data['result'][1][0]['Usedleavedays'] ?? 0;

          bookedLeaveCount =
              response.data['result'][1][0]['BookedLeaveDays'] ?? 0;
          balanceLeaveCount =
              response.data['result'][1][0]['BalanceLeaveDays'] ?? 0;
          presentBalanceCount =
              response.data['result'][1][0]['Present_balance'] ?? 0;
          carriedOverCount = response.data['result'][1][0]['CarryOver'] ?? 0;
          sickLeaveCount = response.data['result'][3][0]['leave'] ?? 0;
          unpaidLeaveCount = response.data['result'][3][0]['unpaidLeave'] ?? 0;
          othersCount = response.data['result'][3][0]['others'] ?? 0;
          year = response.data['result'][3][0]['currentYear'];

          appStroreLink = response.data['result'][5][0]['appStore'];
          playStoreLink = response.data['result'][5][0]['playStore'];

          if (response.data['result'][6].length != 0) {
            compOffFlag = response.data['result'][6][0]['compoff_flg'];
            compOffCount = response.data['result'][6][0]['compoff_bal'];
          }

          listOfLeaveRequest = response.data['result'][7];
          if (listOfLeaveRequest.isNotEmpty) {
            leaveRequestsLen = listOfLeaveRequest.length;
          } else {
            leaveRequestsLen = 0;
          }

          listOfGeneralRequest = response.data['result'][8];
          if (listOfGeneralRequest.isNotEmpty) {
            generalRequestLen = listOfGeneralRequest.length;
          } else {
            generalRequestLen = 0;
          }

          if (response.data['result'].length > 11) {
            listOfReplacementRequest = response.data['result'][11];
            if (listOfReplacementRequest.isNotEmpty) {
              replacementRequestLen = listOfReplacementRequest.length;
            } else {
              replacementRequestLen = 0;
            }
          }

          print('request');
          print(listOfLeaveRequest);
          print(listOfGeneralRequest);
          print(listOfReplacementRequest);

          notificationCount = notificationCount +
              leaveRequestsLen +
              generalRequestLen +
              replacementRequestLen;

          print(notificationCount);
          PushNotifications.updateAppBadgeCount(notificationCount);

          if (usedLeaveCount == 0 &&
              bookedLeaveCount == 0 &&
              balanceLeaveCount == 0) {
            isPiechartValue = false;
          } else {
            isPiechartValue = true;
          }

          if (response.data['result'][4].length != 0) {
            isAnnouncement = true;
            listOfAnnouncement = response.data['result'][4];
          }

          if (response.data['result'].length > 10) {
            if (response.data['result'][9].length != 0) {
              setState(() {
                documentShowFlag =
                    response.data['result'][9][0]['documentShowFlag'] ?? true;
              });
            }
            if (response.data['result'][10].length != 0) {
              setState(() {
                payslipShowFlag = response.data['result'][10][0]
                        ['ESS_PAY_SLIP_DWNLD_FLG'] ??
                    true;
              });
            }
          }

          if (response.data['result'].length > 13) {
            presentFlag = response.data['result'][13][0]['limitFlag'] ?? true;
          }

          setState(() {
            isLoader = false;
          });
        }
      } on DioError catch (ex) {
        setState(() {
          isLoader = false;
        });

        if (ex.response?.statusCode == 502) {
          dlg.AwesomeDialog(
            context: context,
            dialogType: dlg.DialogType.warning,
            headerAnimationLoop: false,
            animType: dlg.AnimType.topSlide,
            title: translation(context).wentWrong,
            desc: translation(context).connProblem,
            buttonsTextStyle: kTextStyle.copyWith(
                fontWeight: FontWeight.bold, color: Colors.white),
            titleTextStyle: kTextStyle.copyWith(
                fontWeight: FontWeight.bold, fontSize: 16.0.sp),
            descTextStyle: kTextStyle,
            btnOkColor: Colors.orange,
            btnOkOnPress: () {
              Navigator.pushAndRemoveUntil<dynamic>(
                context,
                MaterialPageRoute<dynamic>(
                  builder: (BuildContext context) => SelectType(
                    usrSlno: widget.usrSlno,
                    apiUrl: widget.apiUrl,
                    usrName: widget.usrName,
                    empImage: widget.empImage,
                    userfirstName: widget.userfirstName,
                    empEmail: widget.empEmail,
                    empGioFlag: widget.empGioFlag,
                    mobATTimageFlag: widget.mobATTimageFlag,
                    empSelfieFlag: widget.empSelfieFlag,
                    mobATTFlag: widget.mobATTFlag,
                    mobESSFlag: widget.mobESSFlag,
                    approvalFlag: widget.approvalFlag,
                    locationData: widget.locationData,
                  ),
                ),
                (route) =>
                    false, //if you want to disable back feature set to false
              );
            },
            onDismissCallback: (type) {
              Navigator.pushAndRemoveUntil<dynamic>(
                context,
                MaterialPageRoute<dynamic>(
                  builder: (BuildContext context) => SelectType(
                    usrSlno: widget.usrSlno,
                    apiUrl: widget.apiUrl,
                    usrName: widget.usrName,
                    empImage: widget.empImage,
                    userfirstName: widget.userfirstName,
                    empEmail: widget.empEmail,
                    empGioFlag: widget.empGioFlag,
                    mobATTimageFlag: widget.mobATTimageFlag,
                    empSelfieFlag: widget.empSelfieFlag,
                    mobATTFlag: widget.mobATTFlag,
                    mobESSFlag: widget.mobESSFlag,
                    approvalFlag: widget.approvalFlag,
                    locationData: widget.locationData,
                  ),
                ),
                (route) =>
                    false, //if you want to disable back feature set to false
              );
            },
          ).show();
        }
        if (ex.type == DioErrorType.connectionTimeout) {
          throw Exception("Connection Timeout Exception");
        } else if (ex.type == DioErrorType.receiveTimeout) {
          throw Exception("Receive Timeout Exception");
        }
        throw Exception(ex.message);
      }
    } else {
      Fluttertoast.showToast(
          msg: translation(context).noInternet,
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.red[900],
          textColor: Colors.white);
    }
  }

  _forceLogout() {
    String apiUrl = widget.apiUrl;
    int userNo = widget.usrSlno;
    Provider.of<ForceLogoutProvider>(context, listen: false)
        .forceLogoutFunction(context, apiUrl, userNo);
  }

  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return translation(context).goodMorning;
    }
    if (hour < 17) {
      return translation(context).goodAfternoon;
    }
    return translation(context).goodEvening;
  }

  Future<bool> _onWillPop() async {
    Dialogs.bottomMaterialDialog(
        msg: translation(context).exitApp,
        title: translation(context).confirm,
        context: context,
        actions: [
          IconsOutlineButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            text: translation(context).cancel,
            iconData: Icons.cancel_outlined,
            textStyle: TextStyle(color: Colors.grey),
            iconColor: Colors.grey,
          ),
          IconsButton(
            onPressed: () {
              if (Platform.isAndroid) {
                SystemNavigator.pop();
              } else if (Platform.isIOS) {
                exit(0);
              }
            },
            text: translation(context).confirm,
            iconData: Icons.check_circle_outline,
            color: Colors.red,
            textStyle: TextStyle(color: Colors.white),
            iconColor: Colors.white,
          ),
        ]);
    return true; // return true if the route to be popped
  }

  void _showNotification(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.3,
          maxChildSize: 0.5,
          minChildSize: 0.28,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: popUpNotificationScreen(
                totalCount: notificationCount,
                leaveCount: leaveRequestsLen,
                generalCount: generalRequestLen,
                replaceCount: replacementRequestLen,
                leaveList: listOfLeaveRequest,
                generalList: listOfGeneralRequest,
                replaceList: listOfReplacementRequest,
                usrSlno: widget.usrSlno,
                apiUrl: widget.apiUrl,
                usrName: widget.usrName,
                empImage: widget.empImage,
                userfirstName: widget.userfirstName,
                empEmail: widget.empEmail,
                empGioFlag: widget.empGioFlag,
                mobATTimageFlag: widget.mobATTimageFlag,
                empSelfieFlag: widget.empSelfieFlag,
                mobATTFlag: widget.mobATTFlag,
                mobESSFlag: widget.mobESSFlag,
                approvalFlag: widget.approvalFlag,
                locationData: widget.locationData,
              ),
            );
          }),
    );
  }

  bool isImage(String path) {
    final mimeType = lookupMimeType(path);
    if (mimeType == 'image/png' ||
        mimeType == 'image/jpeg' ||
        mimeType == 'image/jpg' ||
        mimeType == 'image/webp') {
      return true;
    } else {
      return false;
    }
  }

  void inform(String path) async {
    Fluttertoast.showToast(
      msg: translation(context).openingFile, // message
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: kMainColor.withOpacity(0.7), // length
      gravity: ToastGravity.BOTTOM, // location
    );

    // if (isImage(path) == false) {
    //   document = await PDFDocument.fromURL(
    //     widget.apiUrl + 'uploads/' + path,
    //   );
    // }

    showDialog<AlertDialog>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            actions: <Widget>[
              isImage(path)
                  ? Container(
                      height: 70 * SizeConfigure.heightMultiplier!,
                      child: Image.network(widget.apiUrl + 'uploads/' + path))
                  : Container(
                      height: 70 * SizeConfigure.heightMultiplier!,
                      child: Center(
                        child: PDF().cachedFromUrl(
                          widget.apiUrl + 'uploads/' + path,
                          placeholder: (progress) =>
                              Center(child: Text('$progress %')),
                          errorWidget: (error) =>
                              Center(child: Text(error.toString())),
                        ),
                        // PDFViewer(
                        //   document: document,
                        //   lazyLoad: false,
                        //   zoomSteps: 1,
                        // ),
                      ),
                    ),
            ],
          );
        });
  }

  openAlertBox(String title, String desc) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.all(10),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white),
                    padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                    child: Container(
                      width: 90 * SizeConfigure.widthMultiplier!,
                      constraints: BoxConstraints(
                          maxHeight: 70 * SizeConfigure.heightMultiplier!),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: Text(
                                title,
                                style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Divider(
                              color: Colors.grey,
                              height: 4.0,
                            ),
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                desc,
                                style: TextStyle(
                                    fontSize: 10.sp, color: Colors.black54),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding:
                                    EdgeInsets.only(top: 20.0, bottom: 20.0),
                                decoration: BoxDecoration(
                                  color: kMainColor,
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(30.0),
                                      bottomRight: Radius.circular(30.0)),
                                ),
                                child: Text(
                                  translation(context).close,
                                  style: TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -100,
                    child: Lottie.asset('images/mic.json',
                        height: 20 * SizeConfigure.heightMultiplier!),
                  )
                ],
              ));
        });
  }

  onBottom(Widget child) => Positioned.fill(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: child,
        ),
      );

  Widget _buildSquare(Color color, String text, String title) {
    return Row(
      children: [
        Container(
          width: 2 * SizeConfigure.widthMultiplier!,
          height: 1 * SizeConfigure.heightMultiplier!,
          color: color,
        ),
        SizedBox(width: 1 * SizeConfigure.widthMultiplier!),
        // Space between square and text
        Text(
          title,
          style: kTextStyle.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 1.3 * SizeConfigure.textMultiplier!,
            color: Colors.black45,
          ),
        ),
      ],
    );
  }
}
