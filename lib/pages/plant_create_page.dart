import 'package:flutter/cupertino.dart';
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
  final varietyCodeController = TextEditingController();
  final temperatureMinController = TextEditingController();
  final temperatureMaxController = TextEditingController();
  final humidityMinController = TextEditingController();
  final humidityMaxController = TextEditingController();
  final lightMinController = TextEditingController();
  final lightMaxController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

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
    varietyCodeController.dispose();
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: '작물 이름'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이름을 입력해주세요';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: varietyCodeController,
                decoration: InputDecoration(labelText: '작물 종류 코드'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '작물 종류 코드를 입력해주세요';
                  }
                  return null;
                },
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
                '최고 온도를 입력해주세요',
              ),
              _buildThresholdInputField(
                '온도 이하',
                temperatureMinController,
                basilThreshold['temperatureMin'],
                '최저 온도를 입력해주세요',
              ),
              _buildThresholdInputField(
                '습도 이상',
                humidityMaxController,
                basilThreshold['humidityMax'],
                '최고 습도를 입력해주세요',
              ),
              _buildThresholdInputField(
                '습도 이하',
                humidityMinController,
                basilThreshold['humidityMin'],
                '최저 습도를 입력해주세요',
              ),
              _buildThresholdInputField(
                '조도 이상',
                lightMaxController,
                basilThreshold['lightMax'],
                '최대 조도값을 입력해주세요',
              ),
              _buildThresholdInputField(
                '조도 이하',
                lightMinController,
                basilThreshold['lightMin'],
                '최저 조도값을 입력해주세요',
              ),
              SizedBox(height: 20),
              CupertinoButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final double? temperatureMin = double.tryParse(
                      temperatureMinController.text,
                    );
                    final double? temperatureMax = double.tryParse(
                      temperatureMaxController.text,
                    );
                    final double? humidityMin = double.tryParse(
                      humidityMinController.text,
                    );
                    final double? humidityMax = double.tryParse(
                      humidityMaxController.text,
                    );
                    final double? lightMin = double.tryParse(
                      lightMinController.text,
                    );
                    final double? lightMax = double.tryParse(
                      lightMaxController.text,
                    );
                    //각 값의 유효성 검사
                    if (!await _validateMinMax(
                          context,
                          '조도',
                          lightMin,
                          lightMax,
                        ) ||
                        !await _validateMinMax(
                          context,
                          '온도',
                          temperatureMin,
                          temperatureMax,
                        ) ||
                        !await _validateMinMax(
                          context,
                          '습도',
                          humidityMin,
                          humidityMax,
                        )) {
                      return; // 유효성 검사 실패 시 함수 실행 중단
                    }

                    final generatedVarietyCode = varietyCodeController.text
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
                      plantId: plantId,
                      temperatureMin: temperatureMin,
                      temperatureMax: temperatureMax,
                      humidityMin: humidityMin,
                      humidityMax: humidityMax,
                      lightMin: lightMin,
                      lightMax: lightMax,
                    );

                    final thresholdRepo = ThresholdRepository();
                    await thresholdRepo.upsertThreshold(setting);

                    //Threshold말고도 PlantRepository의 insertPlant로 저장도 추가해야함

                    if (!mounted) return;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('작물이 추가되었습니다')));

                    context.pushNamed('dashboard', extra: plantId);
                  }
                },
                child: Text('추가하기', style: TextStyle(color: Colors.white)),
                color: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThresholdInputField(
    String label,
    TextEditingController controller,
    double? hintValue,
    String validationMessage,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: '${hintValue?.toString()} (추천)',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validationMessage;
          }
          if (double.tryParse(value) == null) {
            return '유효한 숫자를 입력해주세요.'; // 숫자 유효성 검사 추가
          }
          return null;
        },
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

  Future<bool> _validateMinMax(
    BuildContext context,
    String fieldName,
    double? minValue,
    double? maxValue,
  ) async {
    // 두 값 중 하나라도 null이 아니라면 비교를 시도합니다.
    // (TextFormField의 validator가 이미 null/빈 문자열을 거르지만, 혹시 모를 경우를 대비)
    if (minValue != null && maxValue != null && maxValue < minValue) {
      await showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text('입력 오류'),
              content: Text('$fieldName 이상 값은 $fieldName 이하 값보다 크거나 같아야 합니다.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('확인'),
                ),
              ],
            ),
      );
      return false; // 유효성 검사 실패
    }
    return true; // 유효성 검사 통과
  }
}
