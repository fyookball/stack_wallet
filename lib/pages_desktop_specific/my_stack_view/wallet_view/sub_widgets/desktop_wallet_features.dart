import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stackwallet/notifications/show_flush_bar.dart';
import 'package:stackwallet/pages/paynym/paynym_claim_view.dart';
import 'package:stackwallet/pages/paynym/paynym_home_view.dart';
import 'package:stackwallet/pages_desktop_specific/coin_control/desktop_coin_control_view.dart';
import 'package:stackwallet/pages_desktop_specific/my_stack_view/wallet_view/desktop_wallet_view.dart';
import 'package:stackwallet/pages_desktop_specific/my_stack_view/wallet_view/sub_widgets/more_features/more_features_dialog.dart';
import 'package:stackwallet/providers/global/paynym_api_provider.dart';
import 'package:stackwallet/providers/global/wallets_provider.dart';
import 'package:stackwallet/providers/wallet/my_paynym_account_state_provider.dart';
import 'package:stackwallet/services/coins/firo/firo_wallet.dart';
import 'package:stackwallet/services/mixins/paynym_wallet_interface.dart';
import 'package:stackwallet/utilities/assets.dart';
import 'package:stackwallet/utilities/constants.dart';
import 'package:stackwallet/utilities/enums/coin_enum.dart';
import 'package:stackwallet/utilities/enums/derive_path_type_enum.dart';
import 'package:stackwallet/utilities/logger.dart';
import 'package:stackwallet/utilities/text_styles.dart';
import 'package:stackwallet/utilities/theme/stack_colors.dart';
import 'package:stackwallet/widgets/custom_loading_overlay.dart';
import 'package:stackwallet/widgets/desktop/desktop_dialog.dart';
import 'package:stackwallet/widgets/desktop/primary_button.dart';
import 'package:stackwallet/widgets/desktop/secondary_button.dart';
import 'package:stackwallet/widgets/loading_indicator.dart';

class DesktopWalletFeatures extends ConsumerStatefulWidget {
  const DesktopWalletFeatures({
    Key? key,
    required this.walletId,
  }) : super(key: key);

  final String walletId;

  @override
  ConsumerState<DesktopWalletFeatures> createState() =>
      _DesktopWalletFeaturesState();
}

class _DesktopWalletFeaturesState extends ConsumerState<DesktopWalletFeatures> {
  Future<void> _onSwapPressed() async {
    // todo
  }

  Future<void> _onBuyPressed() async {
    // todo
  }

  Future<void> _onMorePressed() async {
    await showDialog<void>(
      context: context,
      builder: (_) => MoreFeaturesDialog(
        walletId: widget.walletId,
        onPaynymPressed: _onPaynymPressed,
        onCoinControlPressed: _onCoinControlPressed,
        onAnonymizeAllPressed: _onAnonymizeAllPressed,
        onWhirlpoolPressed: _onWhirlpoolPressed,
      ),
    );
  }

  void _onWhirlpoolPressed() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _onCoinControlPressed() {
    Navigator.of(context, rootNavigator: true).pop();

    Navigator.of(context).pushNamed(
      DesktopCoinControlView.routeName,
      arguments: widget.walletId,
    );
  }

  Future<void> _onAnonymizeAllPressed() async {
    Navigator.of(context, rootNavigator: true).pop();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DesktopDialog(
        maxWidth: 500,
        maxHeight: 210,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: Column(
            children: [
              Text(
                "Attention!",
                style: STextStyles.desktopH2(context),
              ),
              const SizedBox(height: 16),
              Text(
                "You're about to anonymize all of your public funds.",
                style: STextStyles.desktopTextSmall(context),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SecondaryButton(
                    width: 200,
                    buttonHeight: ButtonHeight.l,
                    label: "Cancel",
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 20),
                  PrimaryButton(
                    width: 200,
                    buttonHeight: ButtonHeight.l,
                    label: "Continue",
                    onPressed: () {
                      Navigator.of(context).pop();

                      unawaited(
                        _attemptAnonymize(),
                      );
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _attemptAnonymize() async {
    final managerProvider = ref
        .read(walletsChangeNotifierProvider)
        .getManagerProvider(widget.walletId);

    bool shouldPop = false;
    unawaited(
      showDialog(
        context: context,
        builder: (context) => WillPopScope(
          child: const CustomLoadingOverlay(
            message: "Anonymizing balance",
            eventBus: null,
          ),
          onWillPop: () async => shouldPop,
        ),
      ),
    );
    final firoWallet = ref.read(managerProvider).wallet as FiroWallet;

    final publicBalance = firoWallet.availablePublicBalance();
    if (publicBalance <= Decimal.zero) {
      shouldPop = true;
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.of(context).popUntil(
          ModalRoute.withName(DesktopWalletView.routeName),
        );
        unawaited(
          showFloatingFlushBar(
            type: FlushBarType.info,
            message: "No funds available to anonymize!",
            context: context,
          ),
        );
      }
      return;
    }

    try {
      await firoWallet.anonymizeAllPublicFunds();
      shouldPop = true;
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.of(context).popUntil(
          ModalRoute.withName(DesktopWalletView.routeName),
        );
        unawaited(
          showFloatingFlushBar(
            type: FlushBarType.success,
            message: "Anonymize transaction submitted",
            context: context,
          ),
        );
      }
    } catch (e) {
      shouldPop = true;
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.of(context).popUntil(
          ModalRoute.withName(DesktopWalletView.routeName),
        );
        await showDialog<dynamic>(
          context: context,
          builder: (_) => DesktopDialog(
            maxWidth: 400,
            maxHeight: 300,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Anonymize all failed",
                    style: STextStyles.desktopH3(context),
                  ),
                  const Spacer(
                    flex: 1,
                  ),
                  Text(
                    "Reason: $e",
                    style: STextStyles.desktopTextSmall(context),
                  ),
                  const Spacer(
                    flex: 2,
                  ),
                  Row(
                    children: [
                      const Spacer(),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: PrimaryButton(
                          label: "Ok",
                          buttonHeight: ButtonHeight.l,
                          onPressed:
                              Navigator.of(context, rootNavigator: true).pop,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      }
    }
  }

  Future<void> _onPaynymPressed() async {
    Navigator.of(context, rootNavigator: true).pop();

    unawaited(
      showDialog(
        context: context,
        builder: (context) {
          return const LoadingIndicator(
            width: 100,
          );
        },
      ),
    );

    final manager =
        ref.read(walletsChangeNotifierProvider).getManager(widget.walletId);

    final wallet = manager.wallet as PaynymWalletInterface;

    final code =
        await wallet.getPaymentCode(DerivePathTypeExt.primaryFor(manager.coin));

    final account = await ref.read(paynymAPIProvider).nym(code.toString());

    Logging.instance.log(
      "my nym account: $account",
      level: LogLevel.Info,
    );

    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();

      // check if account exists and for matching code to see if claimed
      if (account.value != null && account.value!.codes.first.claimed) {
        ref.read(myPaynymAccountStateProvider.state).state = account.value!;

        await Navigator.of(context).pushNamed(
          PaynymHomeView.routeName,
          arguments: widget.walletId,
        );
      } else {
        await Navigator.of(context).pushNamed(
          PaynymClaimView.routeName,
          arguments: widget.walletId,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final manager = ref.watch(
      walletsChangeNotifierProvider.select(
        (value) => value.getManager(widget.walletId),
      ),
    );

    final showMore = manager.hasPaynymSupport ||
        manager.hasCoinControlSupport ||
        manager.coin == Coin.firo ||
        manager.coin == Coin.firoTestNet ||
        manager.hasWhirlpoolSupport;

    return Row(
      children: [
        if (Constants.enableExchange)
          SecondaryButton(
            label: "Swap",
            width: 160,
            buttonHeight: ButtonHeight.l,
            icon: SvgPicture.asset(
              Assets.svg.arrowRotate,
              height: 20,
              width: 20,
              color: Theme.of(context)
                  .extension<StackColors>()!
                  .buttonTextSecondary,
            ),
            onPressed: () => _onSwapPressed(),
          ),
        if (Constants.enableExchange)
          const SizedBox(
            width: 16,
          ),
        if (Constants.enableExchange)
          SecondaryButton(
            label: "Buy",
            width: 160,
            buttonHeight: ButtonHeight.l,
            icon: SvgPicture.asset(
              Assets.svg.buy(context),
              height: 20,
              width: 20,
              color: Theme.of(context)
                  .extension<StackColors>()!
                  .buttonTextSecondary,
            ),
            onPressed: () => _onBuyPressed(),
          ),
        if (showMore)
          const SizedBox(
            width: 16,
          ),
        SecondaryButton(
          label: "More",
          width: 160,
          buttonHeight: ButtonHeight.l,
          icon: SvgPicture.asset(
            Assets.svg.bars,
            height: 20,
            width: 20,
            color:
                Theme.of(context).extension<StackColors>()!.buttonTextSecondary,
          ),
          onPressed: () => _onMorePressed(),
        ),
      ],
    );
  }
}