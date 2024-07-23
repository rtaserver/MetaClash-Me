import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget currentProxyNameBuilder({
  required String groupName,
  required Widget Function(String) builder,
}) {
  return Selector2<AppState, Config, String>(
    selector: (_, appState, config) {
      final group = appState.getGroupWithName(groupName)!;
      return config.currentSelectedMap[groupName] ?? group.now ?? '';
    },
    builder: (_, value, ___) {
      return builder(value);
    },
  );
}



double getListCardHeight() {
  final measure = globalState.appController.measure;
  return 24 + measure.labelMediumHeight + 4 + measure.bodyMediumHeight;
}

double getItemHeight(ProxyCardType proxyCardType) {
  final measure = globalState.appController.measure;
  final baseHeight =
      12 * 2 + measure.bodyMediumHeight * 2 + measure.bodySmallHeight + 8;
  return switch(proxyCardType){
    ProxyCardType.expand => baseHeight + measure.labelSmallHeight + 8,
    ProxyCardType.shrink => baseHeight,
    ProxyCardType.min => baseHeight - measure.bodyMediumHeight,
  };
}
