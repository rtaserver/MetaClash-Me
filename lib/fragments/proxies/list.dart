import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'card.dart';
import 'common.dart';

class ProxiesListFragment extends StatefulWidget {
  const ProxiesListFragment({super.key});

  @override
  State<ProxiesListFragment> createState() => _ProxiesListFragmentState();
}

class _ProxiesListFragmentState extends State<ProxiesListFragment> {
  final _controller = ScrollController();

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  _handleChange(Set<String> currentUnfoldSet, String groupName) {
    final tempUnfoldSet = Set<String>.from(currentUnfoldSet);
    if (tempUnfoldSet.contains(groupName)) {
      tempUnfoldSet.remove(groupName);
    } else {
      tempUnfoldSet.add(groupName);
    }
    globalState.appController.config.updateCurrentUnfoldSet(
      tempUnfoldSet,
    );
  }

  List<Widget> _buildItems({
    required List<String> groupNames,
    required int columns,
    required Set<String> currentUnfoldSet,
    required ProxyCardType type,
  }) {
    final items = <Widget>[];
    for (final groupName in groupNames) {
      final group =
          globalState.appController.appState.getGroupWithName(groupName)!;
      final isExpand = currentUnfoldSet.contains(groupName);
      items.addAll([
        ProxyGroupItem(
          isExpand: isExpand,
          groupName: groupName,
          groupType: group.type.name,
          onChange: (String groupName) {
            _handleChange(currentUnfoldSet, groupName);
          },
        ),
        const SizedBox(
          height: 8,
        ),
      ]);
      if (isExpand) {
        final chunks = group.all.chunks(columns);
        final rows = chunks.map<Widget>((proxies) {
          final children = proxies
              .map<Widget>(
                (proxy) => Flexible(
                  child: currentProxyNameBuilder(
                      groupName: group.name,
                      builder: (currentProxyName) {
                        return ProxyCard(
                          type: type,
                          isSelected: currentProxyName == proxy.name,
                          key: ValueKey('$groupName.${proxy.name}'),
                          proxy: proxy,
                          groupName: groupName,
                        );
                      }),
                ),
              )
              .fill(
                columns,
                filler: (_) => const Flexible(
                  child: SizedBox(),
                ),
              )
              .separated(
                const SizedBox(
                  width: 8,
                ),
              );

          return Row(
            children: children.toList(),
          );
        }).separated(
          const SizedBox(
            height: 8,
          ),
        );
        items.addAll(
          [
            ...rows,
            const SizedBox(
              height: 8,
            ),
          ],
        );
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Selector2<AppState, Config, ProxiesListSelectorState>(
      selector: (_, appState, config) {
        final currentGroups = appState.currentGroups;
        final groupNames = currentGroups.map((e) => e.name).toList();
        return ProxiesListSelectorState(
          groupNames: groupNames,
          currentUnfoldSet: config.currentUnfoldSet,
          proxyCardType: config.proxyCardType,
          proxiesSortType: config.proxiesSortType,
          columns: globalState.appController.columns,
          sortNum: appState.sortNum,
        );
      },
      builder: (_, state, __) {
        final items = _buildItems(
          groupNames: state.groupNames,
          currentUnfoldSet: state.currentUnfoldSet,
          columns: state.columns,
          type: state.proxyCardType,
        );
        return Scrollbar(
          controller: _controller,
          thumbVisibility: true,
          trackVisibility: true,
          thickness: 8,
          radius: const Radius.circular(8),
          interactive: true,
          child: ScrollConfiguration(
            behavior: HiddenBarScrollBehavior(),
            child: ListView.builder(
              controller: _controller,
              padding: const EdgeInsets.all(16),
              itemExtentBuilder: (index, __) {
                final runtimeType = items[index].runtimeType;
                if (runtimeType == SizedBox) {
                  return 8;
                }
                if (runtimeType == ProxyGroupItem) {
                  return getListCardHeight();
                }
                return getItemHeight(state.proxyCardType);
              },
              itemCount: items.length,
              itemBuilder: (_, index) {
                return items[index];
              },
            ),
          ),
        );
      },
    );
  }
}

class ProxyGroupItem extends StatefulWidget {
  final String groupName;
  final String groupType;
  final Function(String groupName) onChange;
  final bool isExpand;

  const ProxyGroupItem({
    super.key,
    required this.groupName,
    required this.groupType,
    required this.onChange,
    required this.isExpand,
  });

  @override
  State<ProxyGroupItem> createState() => _ProxyGroupItemState();
}

class _ProxyGroupItemState extends State<ProxyGroupItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _iconTurns;

  String get groupName => widget.groupName;

  String get groupType => widget.groupType;

  bool get isExpand => widget.isExpand;

  _handleChange(String groupName) {
    if (isExpand) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    widget.onChange(groupName);
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _iconTurns = _animationController.drive(
      Tween<double>(begin: 0.0, end: 0.5),
    );
    if (isExpand) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      key: widget.key,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 1,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(groupName),
                  const SizedBox(
                    height: 4,
                  ),
                  Flexible(
                    flex: 1,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          groupType,
                          style: context.textTheme.labelMedium?.toLight,
                        ),
                        Flexible(
                          flex: 1,
                          child: currentProxyNameBuilder(
                            groupName: groupName,
                            builder: (value) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (value.isNotEmpty) ...[
                                    Flexible(
                                      flex: 1,
                                      child: Text(
                                        overflow: TextOverflow.ellipsis,
                                        " · $value",
                                        style: context
                                            .textTheme.labelMedium?.toLight,
                                      ),
                                    ),
                                  ]
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AnimatedBuilder(
              animation: _animationController.view,
              builder: (_, __) {
                return IconButton(
                  onPressed: () {
                    _handleChange(groupName);
                  },
                  icon: RotationTransition(
                    turns: _iconTurns,
                    child: const Icon(Icons.expand_more),
                  ),
                );
              },
            )
          ],
        ),
      ),
      onPressed: () {
        _handleChange(groupName);
      },
    );
  }
}
