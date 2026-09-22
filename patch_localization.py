with open('lib/main.dart', 'r') as f:
    content = f.read()

# Add import
import_stmt = "import 'package:flutter_localizations/flutter_localizations.dart';"
if import_stmt not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\n" + import_stmt)

# Update MaterialApp
old_material_app = """    return MaterialApp(
      title: AppInfo.appName,
      debugShowCheckedModeBanner: false,"""

new_material_app = """    return MaterialApp(
      title: AppInfo.appName,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],"""

content = content.replace(old_material_app, new_material_app)

with open('lib/main.dart', 'w') as f:
    f.write(content)
