import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:logging/logging.dart';
import 'package:source_gen/source_gen.dart';
import 'package:angular_compiler/angular_compiler.dart';

import '../transform/common/names.dart';
import 'template_compiler/generator.dart';

export 'template_compiler/generator.dart'
    show TemplatePlaceholderBuilder, TemplateGenerator;

const _outlineOnlyFlag = '--outline-only';

Builder templateCompiler(List<String> args) {
  var outlineOnly = args.contains(_outlineOnlyFlag);
  if (outlineOnly) {
    args = args.toList()..remove(_outlineOnlyFlag);
  }

  var flags = new CompilerFlags.parseArgs(
    args,
    defaultTo: const CompilerFlags(
      genDebugInfo: false,
      useLegacyStyleEncapsulation: true,
      usePlaceholder: true,
    ),
    severity: Level.SEVERE,
  );

  if (outlineOnly) {
    return new TemplateOutliner(flags);
  } else {
    return createSourceGenTemplateCompiler(flags);
  }
}

Builder templatePlaceholderBuilder(_) => const TemplatePlaceholderBuilder();

Builder createSourceGenTemplateCompiler(CompilerFlags flags) =>
    new LibraryBuilder(new TemplateGenerator(flags),
        formatOutput: (String original) => _formatter.format(original),
        generatedExtension: TEMPLATE_EXTENSION);

// Note: Use an absurdly long line width in order to speed up the formatter. We
// still get a lot of other formatting, such as forced line breaks (after
// semicolons for instance), spaces in argument lists, etc.
final _formatter = new DartFormatter(pageWidth: 1000000);
