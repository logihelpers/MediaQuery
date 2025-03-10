import 'package:flet/flet.dart';

import 'mediaquerycontainer.dart';

CreateControlFactory createControl = (CreateControlArgs args) {
  switch (args.control.type) {
    case "mediaquerycontainer":
      return MediaQueryContainerControl(
        parent: args.parent,
        control: args.control,
        children: args.children,
        parentAdaptive: args.parentAdaptive,
        parentDisabled: args.parentDisabled,
        backend: args.backend,
      );
    default:
      return null;
  }
};

void ensureInitialized() {
  // nothing to initialize
}
