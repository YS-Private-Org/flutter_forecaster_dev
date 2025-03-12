import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_forecaster/src/dart/arima_forecaster.dart';
import 'package:flutter_forecaster/src/dart/augur_forecaster.dart';
import 'package:flutter_forecaster/src/dart/model/prediction_source.dart';
import 'package:flutter_forecaster/src/dart/model/prediction_type.dart';
import 'package:flutter_forecaster/src/rust/frb_generated.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<PredictionSource> predictionList = [];

  final List<PredictionSource> sourceData = [
    /// Add PredictionSource data like below
    // PredictionSource(date: DateTime(2025, 2, 1), value: 100000.40),
    // PredictionSource(date: DateTime(2025, 1, 1), value: 80000.40),
    PredictionSource(date: DateTime(2025, 1, 1), value: 106418.20),
    PredictionSource(date: DateTime(2024, 12, 1), value: 81678.45),
    PredictionSource(date: DateTime(2024, 11, 1), value: 111488.59),
    PredictionSource(date: DateTime(2024, 10, 1), value: 110186.00),
    PredictionSource(date: DateTime(2024, 9, 1), value: 118818.90),
    PredictionSource(date: DateTime(2024, 8, 1), value: 198366.05),
    PredictionSource(date: DateTime(2024, 7, 1), value: 145274.80),
    PredictionSource(date: DateTime(2024, 6, 1), value: 113852.00),
    PredictionSource(date: DateTime(2024, 5, 1), value: 121192.10),
    PredictionSource(date: DateTime(2024, 4, 1), value: 126572.90),
    PredictionSource(date: DateTime(2024, 3, 1), value: 109980.60),
    PredictionSource(date: DateTime(2024, 2, 1), value: 103947.00),
    PredictionSource(date: DateTime(2024, 1, 1), value: 200878.55),
    PredictionSource(date: DateTime(2023, 12, 1), value: 117605.80),
    PredictionSource(date: DateTime(2023, 11, 1), value: 152036.40),
    PredictionSource(date: DateTime(2023, 10, 1), value: 103124.60),
    PredictionSource(date: DateTime(2023, 9, 1), value: 78098.40),
    PredictionSource(date: DateTime(2023, 8, 1), value: 107269.00),
    PredictionSource(date: DateTime(2023, 7, 1), value: 84685.00),
    PredictionSource(date: DateTime(2023, 6, 1), value: 116322.20),
    PredictionSource(date: DateTime(2023, 5, 1), value: 96528.20),
    PredictionSource(date: DateTime(2023, 4, 1), value: 92570.00),
    PredictionSource(date: DateTime(2023, 3, 1), value: 79047.20),
    PredictionSource(date: DateTime(2023, 2, 1), value: 91036.80),
    PredictionSource(date: DateTime(2023, 1, 1), value: 102551.00),
  ].reversed.toList();

  @override
  Widget build(BuildContext context) {
    final listView = List<PredictionSource>.from(sourceData).reversed.toList();
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Forecaster Rust Bridge Test')),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                buildButton(PredictionType.monthly, "Arima Monthly", true),
                buildButton(PredictionType.monthly, "Augur Monthly", false)
              ],
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: listView.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final currentPrediction = listView[index];
                        return Row(
                          children: [
                            Text(DateFormat('yyyy-MM-dd')
                                .format(currentPrediction.date)),
                            const SizedBox(width: 30),
                            Text(currentPrediction.value.toString()),
                          ],
                        );
                      },
                    ),
                  ),
                  Expanded(
                      child: Column(
                    children: [
                      if (predictionList.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Predicted Value'),
                            const SizedBox(width: 30),
                            Text(predictionList
                                .map((e) =>
                                    '${DateFormat('yyyy-MM-dd').format(e.date)}      ${e.value}')
                                .join('\n')),
                          ],
                        ),
                    ],
                  ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildButton(PredictionType prediction, String title, bool useArima) {
    return CupertinoButton(
      onPressed: () async {
        predictionList = useArima
            ? await ArimaForecaster().initializePrediction(sourceData: sourceData)
            : await AugurForecaster().initializePrediction(
                sourceData: sourceData,
                prediction: PredictionType.monthly,
              );
        setState(() {});
      },
      child: Text(title),
    );
  }
}
