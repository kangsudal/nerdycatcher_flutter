import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nerdycatcher_flutter/pages/widgets/default_app_bar.dart';

class NotificationSettingPage extends StatefulWidget {
  const NotificationSettingPage({super.key});

  @override
  State<NotificationSettingPage> createState() =>
      _NotificationSettingPageState();
}

class _NotificationSettingPageState extends State<NotificationSettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(Icons.mail),
                      SizedBox(width: 10),
                      Text(
                        '알림 발송 조건',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/sample_plants/basil.png',
                        width: 80,
                      ),
                      Text(
                        '바질',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Spacer(),
                      Text('plant_id: 1'),
                    ],
                  ),
                  SettingNotificationCard(
                    iconPath: 'assets/icons/temperature.png',
                    conditionLabel: '온도',
                  ),
                  SettingNotificationCard(
                    iconPath: 'assets/icons/humidity.png',
                    conditionLabel: '습도',
                  ),
                  SettingNotificationCard(
                    iconPath: 'assets/icons/light.png',
                    conditionLabel: '조도',
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: Colors.black,
                      child: Text('저장', style: TextStyle(color: Colors.white)),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SettingNotificationCard extends StatelessWidget {
  final String iconPath;

  final String conditionLabel;

  final double? width;
  final double? height;

  const SettingNotificationCard({
    super.key,
    required this.iconPath,
    required this.conditionLabel,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.25),
            blurRadius: 10.0,
            spreadRadius: 3.0,
            offset: const Offset(0, 6),
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      // height: 180,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(iconPath, fit: BoxFit.contain, width: width),
              SizedBox(width: 5),
              Text(
                conditionLabel,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: '이상',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '값을 입력하세요';
                }
                return null;
              },
              onSaved: (value) {},
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: '이하',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '값을 입력하세요';
                }
                return null;
              },
              onSaved: (value) {},
            ),
          ),
        ],
      ),
    );
  }
}
