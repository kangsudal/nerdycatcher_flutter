import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nerdycatcher_flutter/data/models/threshold_setting.dart';
import 'package:nerdycatcher_flutter/data/repositories/threshold_repository.dart';
import 'package:nerdycatcher_flutter/pages/widgets/default_app_bar.dart';

class NotificationSettingPage extends StatefulWidget {
  const NotificationSettingPage({super.key});

  @override
  State<NotificationSettingPage> createState() =>
      _NotificationSettingPageState();
}

class _NotificationSettingPageState extends State<NotificationSettingPage> {
  // plant_id는 임시로 1 고정. ESP32 기기 개수를 추후에 추가하면 각자 고유 번호 부여하는 코드로 수정할 예정.
  final int plantId = 1; // selectedPlant!.id로 대체가능하도록 향후 개발할 예정

  // 각 항목 컨트롤러
  final temperatureMaxController = TextEditingController();
  final temperatureMinController = TextEditingController();
  final humidityMaxController = TextEditingController();
  final humidityMinController = TextEditingController();
  final lightMaxController = TextEditingController();
  final lightMinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadThresholdSettingValue();
  }

  @override
  void dispose() {
    // 컨트롤러 정리
    temperatureMaxController.dispose();
    temperatureMinController.dispose();
    humidityMaxController.dispose();
    humidityMinController.dispose();
    lightMaxController.dispose();
    lightMinController.dispose();
    super.dispose();
  }

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
                    maxController: temperatureMaxController,
                    minController: temperatureMinController,
                  ),
                  SettingNotificationCard(
                    iconPath: 'assets/icons/humidity.png',
                    conditionLabel: '습도',
                    maxController: humidityMaxController,
                    minController: humidityMinController,
                  ),
                  SettingNotificationCard(
                    iconPath: 'assets/icons/light.png',
                    conditionLabel: '조도',
                    maxController: lightMaxController,
                    minController: lightMinController,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: Colors.black,
                      child: Text('저장', style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        final repo = ThresholdRepository();
                        final setting = ThresholdSetting(
                          plantId: plantId,
                          temperatureMin: double.parse(
                            temperatureMinController.text,
                          ),
                          temperatureMax: double.parse(
                            temperatureMaxController.text,
                          ),
                          humidityMin: double.parse(humidityMinController.text),
                          humidityMax: double.parse(humidityMaxController.text),
                          lightMin: double.parse(lightMinController.text),
                          lightMax: double.parse(lightMaxController.text),
                        );

                        await repo.upsertThreshold(setting);

                        if (!mounted) return;
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('임계값이 저장되었습니다')));
                      },
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

  Future<void> loadThresholdSettingValue() async {
    //설정 페이지 열었을 때 기존 설정 값이 자동으로 텍스트필드에 세팅
    final repo = ThresholdRepository();
    final setting = await repo.loadThresholdSettingValue(plantId);

    if (setting != null) {
      temperatureMinController.text = setting.temperatureMin.toString();
      temperatureMaxController.text = setting.temperatureMax.toString();
      humidityMinController.text = setting.humidityMin.toString();
      humidityMaxController.text = setting.humidityMax.toString();
      lightMinController.text = setting.lightMin.toString();
      lightMaxController.text = setting.lightMax.toString();
      print(
        'setting.temperatureMin.toString():${setting.temperatureMin.toString()}',
      );
    } else {
      print('ddd');
    }
  }
}

class SettingNotificationCard extends StatefulWidget {
  final String iconPath;

  final String conditionLabel;

  final double? width;
  final double? height;

  final TextEditingController maxController;
  final TextEditingController minController;

  const SettingNotificationCard({
    super.key,
    required this.iconPath,
    required this.conditionLabel,
    this.width,
    this.height,
    required this.maxController,
    required this.minController,
  });

  @override
  State<SettingNotificationCard> createState() =>
      _SettingNotificationCardState();
}

class _SettingNotificationCardState extends State<SettingNotificationCard> {
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
              Image.asset(
                widget.iconPath,
                fit: BoxFit.contain,
                width: widget.width,
              ),
              SizedBox(width: 5),
              Text(
                widget.conditionLabel,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: TextFormField(
              controller: widget.maxController,
              decoration: InputDecoration(
                labelText: '이상',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
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
              controller: widget.minController,
              decoration: InputDecoration(
                labelText: '이하',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
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
