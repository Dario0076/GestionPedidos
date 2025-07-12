import 'package:flutter/material.dart';

// Responsive builder widget
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 600) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

// Responsive padding
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobilePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? desktopPadding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        EdgeInsets padding;
        
        if (constraints.maxWidth >= 1200) {
          padding = desktopPadding ?? const EdgeInsets.all(32);
        } else if (constraints.maxWidth >= 600) {
          padding = tabletPadding ?? const EdgeInsets.all(24);
        } else {
          padding = mobilePadding ?? const EdgeInsets.all(16);
        }

        return Padding(
          padding: padding,
          child: child,
        );
      },
    );
  }
}

// Responsive grid
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns;
        
        if (constraints.maxWidth >= 1200) {
          columns = desktopColumns;
        } else if (constraints.maxWidth >= 600) {
          columns = tabletColumns;
        } else {
          columns = mobileColumns;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: 1,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

// Adaptive container
class AdaptiveContainer extends StatelessWidget {
  final Widget child;
  final double? mobileMaxWidth;
  final double? tabletMaxWidth;
  final double? desktopMaxWidth;

  const AdaptiveContainer({
    super.key,
    required this.child,
    this.mobileMaxWidth,
    this.tabletMaxWidth,
    this.desktopMaxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double? maxWidth;
        
        if (constraints.maxWidth >= 1200) {
          maxWidth = desktopMaxWidth ?? 1200;
        } else if (constraints.maxWidth >= 600) {
          maxWidth = tabletMaxWidth ?? 800;
        } else {
          maxWidth = mobileMaxWidth;
        }

        return Center(
          child: Container(
            width: maxWidth,
            constraints: BoxConstraints(
              maxWidth: maxWidth ?? double.infinity,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

// Screen size helper
class ScreenSize {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1200;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  static double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  // Get responsive value based on screen size
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }

  // Get responsive padding
  static EdgeInsets responsivePadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.all(32);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(16);
    }
  }

  // Get responsive font size
  static double responsiveFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return responsive<double>(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  // Get responsive icon size
  static double responsiveIconSize(BuildContext context) {
    if (isDesktop(context)) {
      return 28;
    } else if (isTablet(context)) {
      return 26;
    } else {
      return 24;
    }
  }

  // Get responsive button height
  static double responsiveButtonHeight(BuildContext context) {
    if (isDesktop(context)) {
      return 56;
    } else if (isTablet(context)) {
      return 52;
    } else {
      return 48;
    }
  }

  // Get responsive card margin
  static EdgeInsets responsiveCardMargin(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(12);
    } else {
      return const EdgeInsets.all(8);
    }
  }

  // Get responsive border radius
  static double responsiveBorderRadius(BuildContext context) {
    if (isDesktop(context)) {
      return 16;
    } else if (isTablet(context)) {
      return 14;
    } else {
      return 12;
    }
  }
}

// Orientation builder
class OrientationBuilder extends StatelessWidget {
  final Widget portrait;
  final Widget? landscape;

  const OrientationBuilder({
    super.key,
    required this.portrait,
    this.landscape,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape
        ? (landscape ?? portrait)
        : portrait;
  }
}

// Safe area with responsive padding
class ResponsiveSafeArea extends StatelessWidget {
  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;

  const ResponsiveSafeArea({
    super.key,
    required this.child,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: ResponsivePadding(child: child),
    );
  }
}
