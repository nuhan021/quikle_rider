import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/core/utils/constants/colors.dart';

class ConnectionLost extends StatelessWidget {
  const ConnectionLost({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Oops! Network is off",
              style: getTextStyle(fontSize: 35, fontWeight: FontWeight.bold),
            ),
            Text(
              "Turn on your internet or Wifi and continue Ordering",
              style: getTextStyle(fontSize: 15),
            ),
            Container(
              height: 350,
              child: Image.asset("assets/images/image4.png"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Material(
                      color: AppColors.beakYellow,
                      borderRadius: BorderRadius.circular(6),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: () async {
                          AppSettings.openAppSettings(
                            type: AppSettingsType.wifi,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          child: Center(
                            child: Text(
                              'Enable Network',
                              // style applied below because getTextStyle is not const
                              style: getTextStyle(
                                color: AppColors.blackText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Material(
                      color: AppColors.blackColor,
                      borderRadius: BorderRadius.circular(6),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: () async {
                          AppSettings.openAppSettings();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          child: Center(
                            child: Text(
                              'Settings',
                              // style applied below because getTextStyle is not const
                              style: getTextStyle(
                                color: AppColors.textWhite,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
