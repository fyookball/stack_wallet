import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stackwallet/utilities/assets.dart';
import 'package:stackwallet/utilities/constants.dart';
import 'package:stackwallet/utilities/text_styles.dart';
import 'package:stackwallet/utilities/theme/stack_colors.dart';
import 'package:stackwallet/widgets/animated_widgets/rotate_icon.dart';
import 'package:stackwallet/widgets/desktop/secondary_button.dart';
import 'package:stackwallet/widgets/rounded_white_container.dart';

class JDropdownButton<T> extends StatefulWidget {
  const JDropdownButton({
    Key? key,
    this.label,
    required this.items,
    this.width,
    this.onSelectionChanged,
    this.groupValue,
    this.redrawOnScreenSizeChanged = false,
    this.showIcon = false,
  }) : super(key: key);

  final String? label;
  final double? width;
  final void Function(T?)? onSelectionChanged;
  final T? groupValue;
  final Set<T> items;
  final bool showIcon;

  /// setting this to true should be done carefully
  final bool redrawOnScreenSizeChanged;

  @override
  State<JDropdownButton<T>> createState() => _JDropdownButtonState();
}

class _JDropdownButtonState<T> extends State<JDropdownButton<T>> {
  final _key = GlobalKey();
  final _rotateIconController = RotateIconController();

  bool _isOpen = false;

  OverlayEntry? _entry;

  void close() {
    if (_isOpen) {
      _rotateIconController.reverse?.call();
      _entry?.remove();
      _isOpen = false;
    }
  }

  void open() {
    final size = (_key.currentContext!.findRenderObject() as RenderBox).size;
    _entry = OverlayEntry(
      builder: (_) {
        final position = (_key.currentContext!.findRenderObject() as RenderBox)
            .localToGlobal(Offset.zero);

        if (widget.redrawOnScreenSizeChanged) {
          // trigger rebuild
          MediaQuery.of(context).size;
        }

        return GestureDetector(
          onTap: close,
          child: _JDropdownButtonMenu<T>(
            size: size,
            position: position,
            items: widget.items
                .map(
                  (e) => _JDropdownButtonItem<T>(
                    value: e,
                    groupValue: widget.groupValue,
                    onSelected: (T value) {
                      widget.onSelectionChanged?.call(value);
                      close();
                    },
                  ),
                )
                .toList(),
          ),
        );
      },
    );
    _rotateIconController.forward?.call();
    Overlay.of(context, rootOverlay: true).insert(_entry!);
    _isOpen = true;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.redrawOnScreenSizeChanged && _isOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _entry?.markNeedsBuild();
      });
    }
    return SecondaryButton(
      key: _key,
      buttonHeight: ButtonHeight.l,
      trailingIcon: widget.showIcon
          ? RotateIcon(
              icon: SvgPicture.asset(
                Assets.svg.chevronDown,
                width: 10,
                color: Theme.of(context)
                    .extension<StackColors>()!
                    .buttonTextSecondary,
              ),
              curve: Curves.easeInOutCubic,
              controller: _rotateIconController,
              animationDurationMultiplier: 0.1,
            )
          : null,
      width: widget.width,
      label: widget.label ?? widget.groupValue.toString(),
      onPressed: _isOpen ? close : open,
    );
  }
}

class JDropdownIconButton<T> extends StatefulWidget {
  const JDropdownIconButton({
    Key? key,
    required this.items,
    required this.displayPrefix,
    this.onSelectionChanged,
    this.groupValue,
    this.redrawOnScreenSizeChanged = false,
  }) : super(key: key);

  final String displayPrefix;
  final void Function(T?)? onSelectionChanged;
  final T? groupValue;
  final Set<T> items;

  /// setting this to true should be done carefully
  final bool redrawOnScreenSizeChanged;

  @override
  State<JDropdownIconButton<T>> createState() => _JDropdownIconButtonState();
}

class _JDropdownIconButtonState<T> extends State<JDropdownIconButton<T>> {
  final _key = GlobalKey();

  bool _isOpen = false;

  OverlayEntry? _entry;

  void close() {
    if (_isOpen) {
      _entry?.remove();
      _isOpen = false;
    }
  }

  void open() {
    final size = (_key.currentContext!.findRenderObject() as RenderBox).size;
    _entry = OverlayEntry(
      builder: (_) {
        final position = (_key.currentContext!.findRenderObject() as RenderBox)
            .localToGlobal(Offset.zero);

        if (widget.redrawOnScreenSizeChanged) {
          // trigger rebuild
          MediaQuery.of(context).size;
        }

        return GestureDetector(
          onTap: close,
          child: _JDropdownButtonMenu<T>(
            size: Size(200, size.height),
            position: Offset(position.dx - 144, position.dy),
            items: widget.items
                .map(
                  (e) => _JDropdownButtonItem<T>(
                    value: e,
                    groupValue: widget.groupValue,
                    displayPrefix: widget.displayPrefix,
                    onSelected: (T value) {
                      widget.onSelectionChanged?.call(value);
                      close();
                    },
                  ),
                )
                .toList(),
          ),
        );
      },
    );
    Overlay.of(context, rootOverlay: true).insert(_entry!);
    _isOpen = true;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.redrawOnScreenSizeChanged && _isOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _entry?.markNeedsBuild();
      });
    }

    return SizedBox(
      key: _key,
      height: 56,
      width: 56,
      child: TextButton(
        style: Theme.of(context)
            .extension<StackColors>()!
            .getSecondaryEnabledButtonStyle(context)
            ?.copyWith(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  side: BorderSide(
                    color: Theme.of(context)
                        .extension<StackColors>()!
                        .buttonBackBorderSecondary,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(
                    Constants.size.circularBorderRadius,
                  ),
                ),
              ),
            ),
        onPressed: _isOpen ? close : open,
        child: SvgPicture.asset(
          Assets.svg.list,
          width: 20,
          height: 20,
        ),
      ),
    );
  }
}

// =============================================================================

class _JDropdownButtonMenu<T> extends StatefulWidget {
  const _JDropdownButtonMenu(
      {Key? key,
      required this.items,
      required this.size,
      required this.position})
      : super(key: key);

  final List<_JDropdownButtonItem<T>> items;
  final Size size;
  final Offset position;

  @override
  State<_JDropdownButtonMenu<T>> createState() => _JDropdownButtonMenuState();
}

class _JDropdownButtonMenuState<T> extends State<_JDropdownButtonMenu<T>> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Container(
            color: Colors.black.withOpacity(0.2),
            // child: widget.content,
          ),
          Positioned(
            top: widget.size.height + widget.position.dy + 10,
            left: widget.position.dx,
            width: widget.size.width,
            child: RoundedWhiteContainer(
              padding: EdgeInsets.zero,
              radiusMultiplier: 2.5,
              boxShadow: [
                Theme.of(context).extension<StackColors>()!.standardBoxShadow,
              ],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  ...widget.items,
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================

class _JDropdownButtonItem<T> extends StatelessWidget {
  const _JDropdownButtonItem({
    Key? key,
    required this.value,
    required this.groupValue,
    required this.onSelected,
    this.height = 53,
    this.displayPrefix,
  }) : super(key: key);

  final T value;
  final T? groupValue;
  final double height;
  final void Function(T) onSelected;
  final String? displayPrefix;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      fillColor: groupValue == value
          ? Theme.of(context).extension<StackColors>()!.textFieldDefaultBG
          : Colors.transparent,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      disabledElevation: 0,
      padding: EdgeInsets.zero,
      onPressed: () => onSelected(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              displayPrefix == null
                  ? value.toString()
                  : "$displayPrefix ${value.toString().toLowerCase()}",
              style: STextStyles.desktopTextExtraSmall(context).copyWith(
                color: Theme.of(context).extension<StackColors>()!.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}