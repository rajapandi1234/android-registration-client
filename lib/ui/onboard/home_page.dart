// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:registration_client/model/process.dart';
import 'package:registration_client/provider/connectivity_provider.dart';

import 'package:registration_client/provider/global_provider.dart';
import 'package:registration_client/provider/sync_provider.dart';

import 'package:registration_client/ui/process_ui/widgets/language_selector.dart';

import 'package:registration_client/provider/registration_task_provider.dart';

import 'package:registration_client/utils/app_config.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'widgets/home_page_card.dart';

class HomePage extends StatefulWidget {
  static const route = "/home-page";
  const HomePage({super.key});

  static const platform =
      MethodChannel('com.flutter.dev/io.mosip.get-package-instance');

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    _fetchProcessSpec();
    super.initState();
  }

  void _showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value),
      ),
    );
  }

  _getIsConnected() {
    return context.read<ConnectivityProvider>().isConnected;
  }

  _showNetworkErrorMessage() {
    _showInSnackBar(AppLocalizations.of(context)!.network_error);
  }

  void syncData(BuildContext context) async {
    await context.read<ConnectivityProvider>().checkNetworkConnection();
    bool isConnected = _getIsConnected();
    if (!isConnected) {
      _showNetworkErrorMessage();
      return;
    }
    // ignore: use_build_context_synchronously
    await context.read<SyncProvider>().getLastSyncTime();
    await _masterDataSync();
    // ignore: use_build_context_synchronously
    await context.read<SyncProvider>().getLastSyncTime();
    await _getNewProcessSpecAction();
    await _getCenterNameAction();
    await _initializeLanguageDataList();
    await _initializeLocationHierarchy();
  }

  void _fetchProcessSpec() async {
    await _getNewProcessSpecAction();
    await _getCenterNameAction();
    await _homePageLoadedAudit();
  }

  _initializeLanguageDataList() async {
    await context.read<GlobalProvider>().initializeLanguageDataList();
  }

  _initializeLocationHierarchy() async {
    await context.read<GlobalProvider>().initializeLocationHierarchyMap();
  }

  _homePageLoadedAudit() async {
    await context
        .read<GlobalProvider>()
        .getAudit("REG-LOAD-003", "REG-MOD-102");
  }

  Future<void> _masterDataSync() async {
    String result;
    try {
      result = await HomePage.platform.invokeMethod("masterDataSync");
    } on PlatformException catch (e) {
      result = "Some Error Occurred: $e";
    }
    debugPrint(result);
  }

  _newRegistrationClickedAudit() async {
    await context
        .read<GlobalProvider>()
        .getAudit("REG-HOME-002", "REG-MOD-102");
  }

  Widget getProcessUI(BuildContext context, Process process) {
    if (process.id == "NEW") {
      _newRegistrationClickedAudit();
      context.read<GlobalProvider>().clearMap();
      context.read<GlobalProvider>().clearScannedPages();
      context.read<GlobalProvider>().newProcessTabIndex = 0;
      context.read<GlobalProvider>().htmlBoxTabIndex = 0;
      context.read<GlobalProvider>().setRegId("");
      for (var screen in process.screens!) {
        for (var field in screen!.fields!) {
          if (field!.controlType == 'dropdown' &&
              field.fieldType == 'default') {
            context
                .read<GlobalProvider>()
                .initializeGroupedHierarchyMap(field.group!);
          }
        }
      }
      context.read<GlobalProvider>().createRegistrationLanguageMap();
      showDialog(
        context: context,
        builder: (BuildContext context) => LanguageSelector(
          newProcess: process,
        ),
      );
    }
    return Container();
  }

  _getNewProcessSpecAction() async {
    await context.read<RegistrationTaskProvider>().getListOfProcesses();
  }

  // _getUiSchemaAction(BuildContext context) async {
  //   await context.read<RegistrationTaskProvider>().getUISchema();
  // }

  _getCenterNameAction() async {
    String regCenterId = context.read<GlobalProvider>().centerId;

    String langCode = context.read<GlobalProvider>().selectedLanguage;
    await context
        .read<GlobalProvider>()
        .getRegCenterName(regCenterId, langCode);
  }

  @override
  Widget build(BuildContext context) {
    double w = ScreenUtil().screenWidth;
    List<Map<String, dynamic>> operationalTasks = [
      {
        "icon": SvgPicture.asset(
          "assets/svg/Synchronising Data.svg",
          width: 20,
          height: 20,
        ),
        "title": "Sync Data",
        "onTap": syncData,
      },
      {
        "icon": SvgPicture.asset(
          "assets/svg/Uploading Local - Registration Data.svg",
          width: 20,
          height: 20,
        ),
        "title": "Download Pre-Registration Data",
        "onTap": () {},
      },
      {
        "icon": SvgPicture.asset(
          "assets/svg/Updating Operator Biometrics.svg",
          width: 20,
          height: 20,
        ),
        "title": "Update Operator Biometrics",
        "onTap": () {},
      },
      {
        "icon": SvgPicture.asset(
          "assets/svg/Uploading Local - Registration Data.svg",
          width: 20,
          height: 20,
        ),
        "title": "Application Upload",
        "onTap": () {},
      },
      {
        "icon": SvgPicture.asset(
          "assets/svg/Onboarding Yourself.svg",
          width: 20,
          height: 20,
        ),
        "title": "Pending Approval",
        "onTap": () {},
      },
      {
        "icon": SvgPicture.asset(
          "assets/svg/Uploading Local - Registration Data.svg",
          width: 20,
          height: 20,
        ),
        "title": "Check Update",
        "onTap": () {},
      },
      {
        "icon": SvgPicture.asset(
          "assets/svg/Uploading Local - Registration Data.svg",
          width: 20,
          height: 20,
        ),
        "title": "Center Remap Sync.",
        "onTap": () {},
      },
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xff214FBF), Color(0xff1C43A1)],
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: w < 512 ? 0 : 60,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 30.h,
                      ),
                      Text(
                        "Registration Tasks",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: semiBold,
                            fontSize: 18),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ResponsiveGridList(
                        shrinkWrap: true,
                        minItemWidth: 300,
                        horizontalGridSpacing: 8,
                        verticalGridSpacing: 8,
                        children: List.generate(
                            context
                                .watch<RegistrationTaskProvider>()
                                .listOfProcesses
                                .length,
                            (index) => HomePageCard(
                                  icon: Image.asset(
                                    "assets/images/${Process.fromJson(jsonDecode(context.watch<RegistrationTaskProvider>().listOfProcesses.elementAt(index).toString())).icon ?? ""}",
                                    width: 20,
                                    height: 20,
                                  ),
                                  index: index + 1,
                                  title: Process.fromJson(jsonDecode(context
                                          .watch<RegistrationTaskProvider>()
                                          .listOfProcesses
                                          .elementAt(index)
                                          .toString()))
                                      .label!["eng"]!,
                                  ontap: () {
                                    getProcessUI(
                                      context,
                                      Process.fromJson(
                                        jsonDecode(
                                          context
                                              .read<RegistrationTaskProvider>()
                                              .listOfProcesses
                                              .elementAt(index)
                                              .toString(),
                                        ),
                                      ),
                                    );
                                  },
                                )),
                      ),
                      SizedBox(
                        height: 30.h,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: w < 512 ? 0 : 60,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                SizedBox(
                  width: w < 512 ? 0 : 60,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Operational Tasks",
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: semiBold),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ResponsiveGridList(
                        shrinkWrap: true,
                        minItemWidth: 300,
                        horizontalGridSpacing: 12,
                        verticalGridSpacing: 12,
                        children: List.generate(
                          operationalTasks.length,
                          (index) {
                            return HomePageCard(
                              index: index,
                              icon: operationalTasks[index]["icon"],
                              title: operationalTasks[index]["title"] as String,
                              ontap: () =>
                                  operationalTasks[index]["onTap"](context),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 4.h,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: w < 512 ? 0 : 60,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}