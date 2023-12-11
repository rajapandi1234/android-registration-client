import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_html/flutter_html.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:registration_client/model/field.dart';
import 'package:registration_client/pigeon/demographics_data_pigeon.dart';
import 'package:registration_client/provider/global_provider.dart';
import 'package:registration_client/utils/app_config.dart';

class HtmlBoxControl extends StatelessWidget {
  const HtmlBoxControl({super.key, required this.field});
  final Field field;

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 750;

    return Card(
      color: pureWhite,
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        children: [
          const SizedBox(
            width: double.infinity,
          ),
          SizedBox(
              height: 40.h,
              child: Row(
                children: [
                  for (int i = 0;
                      i < context.watch<GlobalProvider>().chosenLang.length;
                      i++)
                    isMobile
                        ? Expanded(
                            child: InkWell(
                              onTap: () {
                                context.read<GlobalProvider>().htmlBoxTabIndex =
                                    i;
                              },
                              child: Container(
                                padding: const EdgeInsets.only(top: 10),
                                height: 40.h,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                  color: (context
                                              .watch<GlobalProvider>()
                                              .htmlBoxTabIndex ==
                                          i)
                                      ? solidPrimary
                                      : pureWhite,
                                ),
                                child: Text(
                                  context.read<GlobalProvider>().chosenLang.elementAt(i),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: (context
                                                  .watch<GlobalProvider>()
                                                  .htmlBoxTabIndex ==
                                              i)
                                          ? pureWhite
                                          : blackShade1,
                                      fontWeight: semiBold),
                                ),
                              ),
                            ),
                          )
                        : InkWell(
                            onTap: () {
                              context.read<GlobalProvider>().htmlBoxTabIndex =
                                  i;
                            },
                            child: Container(
                              padding: const EdgeInsets.only(top: 10),
                              height: 40.h,
                              width: 116,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                                color: (context
                                            .watch<GlobalProvider>()
                                            .htmlBoxTabIndex ==
                                        i)
                                    ? solidPrimary
                                    : pureWhite,
                              ),
                              child: Text(
                                context.read<GlobalProvider>().chosenLang.elementAt(i),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: (context
                                                .watch<GlobalProvider>()
                                                .htmlBoxTabIndex ==
                                            i)
                                        ? pureWhite
                                        : blackShade1,
                                    fontWeight: semiBold),
                              ),
                            ),
                          ),
                ],
              )),
          Divider(
            thickness: 3,
            color: solidPrimary,
            height: 0,
          ),
          Container(
            height: 341.h,
            padding: const EdgeInsets.all(18),
            child: HtmlRenderer(field: field),
          ),
        ],
      ),
    );
  }
}

class HtmlRenderer extends StatefulWidget {
  const HtmlRenderer({super.key, required this.field});
  final Field field;

  @override
  State<HtmlRenderer> createState() => _HtmlRendererState();
}

class _HtmlRendererState extends State<HtmlRenderer> {
  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < context.read<GlobalProvider>().chosenLang.length; i++) {
      List<int> bytes = utf8.encode(context
          .read<GlobalProvider>()
          .fieldDisplayValues[widget.field.id][i]);
      Uint8List unit8List = Uint8List.fromList(bytes);
      String? hash;
      DemographicsApi().getHashValue(unit8List).then((value) {
        hash = value;
        context.read<GlobalProvider>().fieldInputValue[widget.field.id!] = hash;
        debugPrint("ID : ${widget.field.id!}");
        DemographicsApi().addSimpleTypeDemographicField(
            widget.field.id!,
            value,
            context
                .read<GlobalProvider>()
                .langToCode(context.read<GlobalProvider>().chosenLang[i]));
      });
    }
    return SingleChildScrollView(
      child: Html(
        data:
            context.watch<GlobalProvider>().fieldDisplayValues[widget.field.id]
                [context.watch<GlobalProvider>().htmlBoxTabIndex],
      ),
      // Text(context.watch<GlobalProvider>().fieldDisplayValues[field.id][context.watch<GlobalProvider>().htmlBoxTabIndex])
    );
  }
}


// ListView.builder(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.all(0),
//               itemCount: context.watch<GlobalProvider>().chosenLang.length,
//               itemBuilder: (BuildContext context, int index) {
//                 Container(
//                   height: 40.h,
//                   width: 174.w,
//                   decoration:
//                       BoxDecoration(borderRadius: BorderRadius.circular(10)),
//                   // color:
//                   //     (context.watch<GlobalProvider>().htmlBoxTabIndex == index)
//                   //         ? solidPrimary
//                   //         : pureWhite,
//                   child: Text(
//                       "${context.read<GlobalProvider>().chosenLang.elementAt(index)}",
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: semiBold,
//                         color: blackShade1,
//                       )
//                       // (context.watch<GlobalProvider>().htmlBoxTabIndex ==
//                       //         index)
//                       //     ? pureWhite
//                       //     : blackShade1),
//                       ),
//                 );
//               },
//             ),