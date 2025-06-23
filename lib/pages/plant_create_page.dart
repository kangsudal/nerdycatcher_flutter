import 'package:flutter/material.dart';
import 'package:nerdycatcher_flutter/data/repositories/plant_repository.dart';
import 'package:nerdycatcher_flutter/data/repositories/threshold_repository.dart';
import 'package:nerdycatcher_flutter/data/models/plant.dart';
import 'package:nerdycatcher_flutter/data/models/threshold_setting.dart';
import 'package:go_router/go_router.dart';

class PlantCreatePage extends StatefulWidget {
  const PlantCreatePage({super.key});

  @override
  State<PlantCreatePage> createState() => _PlantCreatePageState();
}

class _PlantCreatePageState extends State<PlantCreatePage> {
  final nameController = TextEditingController();
  final temperatureMinController = TextEditingController();
  final temperatureMaxController = TextEditingController();
  final humidityMinController = TextEditingController();
  final humidityMaxController = TextEditingController();
  final lightMinController = TextEditingController();
  final lightMaxController = TextEditingController();

  // 추천값 (바질 기준)
  final basilThreshold = {
    'temperatureMin': 18.0,
    'temperatureMax': 30.0,
    'humidityMin': 50.0,
    'humidityMax': 70.0,
    'lightMin': 1000.0,
    'lightMax': 3000.0,
  };

  String selectedImage = 'assets/images/sample_plants/basil.png';

  @override
  void dispose() {
    nameController.dispose();
    temperatureMinController.dispose();
    temperatureMaxController.dispose();
    humidityMinController.dispose();
    humidityMaxController.dispose();
    lightMinController.dispose();
    lightMaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('작물 추가')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: '작물 종류 코드'),
            ),
            SizedBox(height: 10),
            Text('이미지를 선택하세요:'),
            GestureDetector(
              onTap: () => showImagePickerDialog(context),
              child: Image.asset(selectedImage, width: 100),
            ),
            SizedBox(height: 10),
            SizedBox(height: 20),
            _buildThresholdInputField(
              '온도 이상',
              temperatureMaxController,
              basilThreshold['temperatureMax'],
            ),
            _buildThresholdInputField(
              '온도 이하',
              temperatureMinController,
              basilThreshold['temperatureMin'],
            ),
            _buildThresholdInputField(
              '습도 이상',
              humidityMaxController,
              basilThreshold['humidityMax'],
            ),
            _buildThresholdInputField(
              '습도 이하',
              humidityMinController,
              basilThreshold['humidityMin'],
            ),
            _buildThresholdInputField(
              '조도 이상',
              lightMaxController,
              basilThreshold['lightMax'],
            ),
            _buildThresholdInputField(
              '조도 이하',
              lightMinController,
              basilThreshold['lightMin'],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final generatedVarietyCode = nameController.text
                    .trim()
                    .toLowerCase()
                    .replaceAll(' ', '_');
                // 1. 식물 저장
                final plantRepo = PlantRepository();
                final exists = await plantRepo.checkIfVarietyCodeExists(
                  generatedVarietyCode,
                );
                if (exists) {
                  showDialog(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: Text('중복된 코드'),
                          content: Text('같은 작물 종류 코드가 이미 존재해요.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('확인'),
                            ),
                          ],
                        ),
                  );
                  return;
                }
                int? plantId;
                try {
                  plantId = await plantRepo.insertPlant(
                    Plant(
                      name: nameController.text,
                      imagePath: selectedImage,
                      varietyCode: generatedVarietyCode,
                    ),
                  );
                } catch (e) {
                  showDialog(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: Text('생성 실패'),
                          content: Text('작물 등록에 실패하였습니다.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('확인'),
                            ),
                          ],
                        ),
                  );
                  return;
                }

                // 2. 임계값 저장
                final setting = ThresholdSetting(
                  plantId: plantId!,
                  temperatureMin:
                      double.tryParse(temperatureMinController.text) ??
                      basilThreshold['temperatureMin']!,
                  temperatureMax:
                      double.tryParse(temperatureMaxController.text) ??
                      basilThreshold['temperatureMax']!,
                  humidityMin:
                      double.tryParse(humidityMinController.text) ??
                      basilThreshold['humidityMin']!,
                  humidityMax:
                      double.tryParse(humidityMaxController.text) ??
                      basilThreshold['humidityMax']!,
                  lightMin:
                      double.tryParse(lightMinController.text) ??
                      basilThreshold['lightMin']!,
                  lightMax:
                      double.tryParse(lightMaxController.text) ??
                      basilThreshold['lightMax']!,
                );

                final thresholdRepo = ThresholdRepository();
                await thresholdRepo.upsertThreshold(setting);

                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('작물이 추가되었습니다')));

                context.pushNamed('notificationSetting');
              },
              child: Text('추가하기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThresholdInputField(
    String label,
    TextEditingController controller,
    double? hintValue,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: '${hintValue?.toString()} (추천)',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  void showImagePickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('작물 이미지 선택'),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: plantImages.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final image = plantImages[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedImage = image;
                    });
                    Navigator.pop(context);
                  },
                  child: Image.asset(image),
                );
              },
            ),
          ),
        );
      },
    );
  }

  final List<String> plantImages = [
    'assets/images/sample_plants/basil.png',
    'assets/images/sample_plants/kale.png',
    // 'assets/images/sample_plants/tomato.png',
    // 'assets/images/sample_plants/mint.png',
    // 'assets/images/sample_plants/strawberry.png',
  ];
}
