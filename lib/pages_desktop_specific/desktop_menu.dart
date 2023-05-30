import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stackwallet/pages_desktop_specific/desktop_menu_item.dart';
import 'package:stackwallet/providers/desktop/current_desktop_menu_item.dart';
import 'package:stackwallet/themes/stack_colors.dart';
import 'package:stackwallet/utilities/assets.dart';
import 'package:stackwallet/utilities/text_styles.dart';
import 'package:stackwallet/widgets/desktop/living_stack_icon.dart';

enum DesktopMenuItemId {
  myStack,
  exchange,
  buy,
  notifications,
  addressBook,
  settings,
  support,
  about,
}

class DesktopMenu extends ConsumerStatefulWidget {
  const DesktopMenu({
    Key? key,
    this.onSelectionChanged,
    this.onSelectionWillChange,
  }) : super(key: key);

  final void Function(DesktopMenuItemId)? onSelectionChanged;
  final void Function(DesktopMenuItemId)? onSelectionWillChange;

  @override
  ConsumerState<DesktopMenu> createState() => _DesktopMenuState();
}

class _DesktopMenuState extends ConsumerState<DesktopMenu> {
  static const expandedWidth = 225.0;
  static const minimizedWidth = 72.0;

  final Duration duration = const Duration(milliseconds: 250);
  late final List<DMIController> controllers;

  double _width = expandedWidth;

  // final _buyDataLoadingService = BuyDataLoadingService();

  void updateSelectedMenuItem(DesktopMenuItemId idKey) {
    widget.onSelectionWillChange?.call(idKey);

    ref.read(currentDesktopMenuItemProvider.state).state = idKey;

    widget.onSelectionChanged?.call(idKey);
  }

  void toggleMinimize() {
    final expanded = _width == expandedWidth;

    for (var e in controllers) {
      e.toggle?.call();
    }

    setState(() {
      _width = expanded ? minimizedWidth : expandedWidth;
    });
  }

  @override
  void initState() {
    controllers = [
      DMIController(),
      DMIController(),
      DMIController(),
      DMIController(),
      DMIController(),
      DMIController(),
      DMIController(),
      DMIController(),
      DMIController(),
    ];

    super.initState();
  }

  @override
  void dispose() {
    for (var e in controllers) {
      e.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).extension<StackColors>()!.popupBG,
      child: AnimatedContainer(
        width: _width,
        duration: duration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 25,
            ),
            AnimatedContainer(
              duration: duration,
              width: _width == expandedWidth ? 70 : 32,
              child: LivingStackIcon(
                onPressed: toggleMinimize,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            AnimatedOpacity(
              duration: duration,
              opacity: _width == expandedWidth ? 1 : 0,
              child: SizedBox(
                height: 28,
                child: Text(
                  "Stack Wallet",
                  style: STextStyles.desktopH2(context).copyWith(
                    fontSize: 18,
                    height: 23.4 / 18,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 60,
            ),
            Expanded(
              child: AnimatedContainer(
                duration: duration,
                width: _width == expandedWidth
                    ? _width - 32 // 16 padding on either side
                    : _width - 16, // 8 padding on either side
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DesktopMenuItem(
                      duration: duration,
                      icon: const DesktopMyStackIcon(),
                      label: "My Stack",
                      value: DesktopMenuItemId.myStack,
                      onChanged: updateSelectedMenuItem,
                      controller: controllers[0],
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    DesktopMenuItem(
                      duration: duration,
                      icon: const DesktopExchangeIcon(),
                      label: "Swap",
                      value: DesktopMenuItemId.exchange,
                      onChanged: updateSelectedMenuItem,
                      controller: controllers[1],
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    DesktopMenuItem(
                      duration: duration,
                      icon: const DesktopBuyIcon(),
                      label: "Buy crypto",
                      value: DesktopMenuItemId.buy,
                      onChanged: updateSelectedMenuItem,
                      controller: controllers[2],
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    DesktopMenuItem(
                      duration: duration,
                      icon: const DesktopNotificationsIcon(),
                      label: "Notifications",
                      value: DesktopMenuItemId.notifications,
                      onChanged: updateSelectedMenuItem,
                      controller: controllers[3],
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    DesktopMenuItem(
                      duration: duration,
                      icon: const DesktopAddressBookIcon(),
                      label: "Address Book",
                      value: DesktopMenuItemId.addressBook,
                      onChanged: updateSelectedMenuItem,
                      controller: controllers[4],
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    DesktopMenuItem(
                      duration: duration,
                      icon: const DesktopSettingsIcon(),
                      label: "Settings",
                      value: DesktopMenuItemId.settings,
                      onChanged: updateSelectedMenuItem,
                      controller: controllers[5],
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    DesktopMenuItem(
                      duration: duration,
                      icon: const DesktopSupportIcon(),
                      label: "Support",
                      value: DesktopMenuItemId.support,
                      onChanged: updateSelectedMenuItem,
                      controller: controllers[6],
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    DesktopMenuItem(
                      duration: duration,
                      icon: const DesktopAboutIcon(),
                      label: "About",
                      value: DesktopMenuItemId.about,
                      onChanged: updateSelectedMenuItem,
                      controller: controllers[7],
                    ),
                    const Spacer(),
                    if (!Platform.isIOS)
                      DesktopMenuItem(
                        duration: duration,
                        labelLength: 123,
                        icon: const DesktopExitIcon(),
                        label: "Exit",
                        value: 7,
                        onChanged: (_) {
                          // todo: save stuff/ notify before exit?
                          // exit(0);
                          if (Platform.isWindows) {
                            exit(0);
                          } else {
                            SystemNavigator.pop();
                          }
                        },
                        controller: controllers[8],
                      ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                const Spacer(),
                IconButton(
                  splashRadius: 18,
                  onPressed: toggleMinimize,
                  icon: SvgPicture.asset(
                    Assets.svg.minimize,
                    height: 12,
                    width: 12,
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
