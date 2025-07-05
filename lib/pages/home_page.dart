import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nerdycatcher_flutter/data/models/plant.dart';
import 'package:nerdycatcher_flutter/data/repositories/plant_repository.dart';
import 'package:nerdycatcher_flutter/pages/widgets/default_app_bar.dart';
import 'package:nerdycatcher_flutter/providers/websocket_notifier.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    // notifier에게 소켓 연결 상태가 어떤지 확인"
    final connectionState = ref.watch(webSocketNotifierProvider);
    // 센서 데이터 좀 실시간 불러오도록"
    final sensorData = ref.watch(sensorDataStreamProvider);
    return Scaffold(
      appBar: DefaultAppBar(hasBack: false),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: FutureBuilder<List<Plant>>(
              future: PlantRepository().fetchPlants(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                ;
                if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.16,
                      ),
                      Text('''
안녕.
혹시 너도, 작은 씨앗 하나 심어볼래?
내가 지켜볼게.
''', style: TextStyle(fontSize: 17)),
                      SizedBox(height: 20),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            // GestureDetector(
                            //   child: CustomCard(
                            //     imagePath: 'assets/images/sample_plants/basil.png',
                            //     plantName: '바질',
                            //   ),
                            //   onTap: () {
                            //     context.pushNamed('notificationSetting');
                            //   },
                            // ),
                            GestureDetector(
                              child: CustomCard(
                                imagePath: 'assets/images/planting.png',
                                plantName: '작물 추가하기',
                                width: 60,
                              ),
                              onTap: () {
                                context.pushNamed('plantCreate');
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                if (snapshot.hasError) {
                  return Text('작물 정보를 불러오지 못했습니다');
                }

                final plants = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.16),
                    Text('''
안녕.
혹시 너도, 작은 씨앗 하나 심어볼래?
내가 지켜볼게.
''', style: TextStyle(fontSize: 17)),
                    SizedBox(height: 20),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          for (final plant in plants)
                            GestureDetector(
                              onTap: () {
                                context.pushNamed(
                                  'dashboard',
                                  pathParameters: {
                                    'plantId': plant.id.toString(),
                                  },
                                );
                              },
                              child: CustomCard(
                                imagePath: plant.imagePath,
                                plantName: plant.name,
                              ),
                            ),
                          GestureDetector(
                            onTap: () {
                              context.pushNamed('plantCreate');
                            },
                            child: CustomCard(
                              imagePath: 'assets/images/planting.png',
                              plantName: '작물 추가하기',
                              width: 60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final String imagePath;

  final String plantName;

  final double? width;
  final double? height;

  const CustomCard({
    super.key,
    required this.imagePath,
    required this.plantName,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(8),
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
      height: 180,
      width: 120,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Image.asset(imagePath, fit: BoxFit.contain, width: width),
          ),
          Text(plantName, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
