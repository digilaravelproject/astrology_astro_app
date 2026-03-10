import 'package:flutter/material.dart';

import '../utils/ui_spacer.dart';
import 'custom_app_bar.dart';

class CustomBaseWidget extends StatefulWidget {
  final bool useSafeArea;
  final bool showAppBar;
  final bool showLeadingAction;
  final bool showCart;
  final Function? onBackPressed;
  final String? appBarTitle;
  final Widget body;
  final Widget? appBar;
  final Widget? bottomSheet;
  final Widget? fab;
  final bool isLoading;
  final bool extendBodyBehindAppBar;
  final double? elevation;
  final Color? appBarItemColor;
  final Color? backgroundColor;
  final Color? appBarColor;
  final Color? appBarTitleColor;
  final Color? appBarLeadingColor;
  final Widget? leading;
  final Widget? bottomNavigationBar;
  final List<Widget>? actions;
  final bool resizeToAvoidBottomInset;
  final Widget? drawer;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const CustomBaseWidget({
    this.useSafeArea = false,
    this.showAppBar = false,
    this.showLeadingAction = false,
    this.leading,
    this.showCart = false,
    this.onBackPressed,
    this.appBarTitle = "",
    required this.body,
    this.appBar,
    this.bottomSheet,
    this.fab,
    this.isLoading = false,
    this.appBarColor,
    this.appBarTitleColor,
    this.appBarLeadingColor,
    this.elevation,
    this.extendBodyBehindAppBar = false,
    this.appBarItemColor,
    this.backgroundColor,
    this.bottomNavigationBar,
    this.actions,
    this.resizeToAvoidBottomInset = true,
    this.drawer,
    this.scaffoldKey,
    Key? key,

  }) : super(key: key);

  @override
  _CustomBaseWidgetState createState() => _CustomBaseWidgetState();
}

class _CustomBaseWidgetState extends State<CustomBaseWidget> {


  @override
  Widget build(BuildContext context) {
    Color textColor =widget.appBarColor ?? Theme.of(context).primaryColor;


    Widget scaffold = Scaffold(
      key: widget.scaffoldKey,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      backgroundColor:
      widget.backgroundColor ?? Theme.of(context).colorScheme.surface,
      extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
      appBar: widget.showAppBar
          ? (widget.appBar != null
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: widget.appBar!,
                )
              : CustomAppBar(
                  title: widget.appBarTitle ?? "",
                  actions: widget.actions,
                  backgroundColor: widget.appBarColor ?? Colors.white,
                  titleColor: widget.appBarTitleColor ?? const Color(0xFF2E1A47),
                  iconColor: widget.appBarLeadingColor ?? widget.appBarItemColor,
                  showLeading: widget.showLeadingAction || Navigator.canPop(context),
                  onLeadingPressed: widget.onBackPressed != null ? () => widget.onBackPressed!() : null,
                  elevation: widget.elevation ?? 0,
                ))
          : null,


      body: Column(
        children: [
          widget.isLoading
              ? const LinearProgressIndicator()
              : UiSpacer.emptySpace(),
          Expanded(child: widget.body),
        ],
      ),
      bottomSheet: widget.bottomSheet,
      floatingActionButton: widget.fab,
      bottomNavigationBar: widget.bottomNavigationBar,
      drawer: widget.drawer,

    );

    // return scaffold;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: widget.useSafeArea ? SafeArea(child: scaffold) : scaffold,
    );
  }
}
