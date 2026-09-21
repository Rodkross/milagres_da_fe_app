with open('lib/main.dart', 'r') as f:
    content = f.read()

# Add import
import_stmt = "import 'helpers.dart';"
if import_stmt not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\n" + import_stmt)

# Use it in _TopBar
old_topbar = """          if (data != null) {
            final eccTitle = data['ecclesiasticalTitle'] as String?;
            final deptAccess = data['departmentAccess'] as String?;
            isAdmin = (deptAccess == 'presidencia' || deptAccess == 'secretaria');

            if (eccTitle != null && eccTitle != 'Membro' && eccTitle != 'Visitante' && firstName != null) {
              titleText = '$eccTitle $firstName';
            }"""
new_topbar = """          if (data != null) {
            final eccTitle = data['ecclesiasticalTitle'] as String?;
            final gender = data['gender'] as String? ?? 'Masculino';
            final deptAccess = data['departmentAccess'] as String?;
            isAdmin = (deptAccess == 'presidencia' || deptAccess == 'secretaria');

            if (eccTitle != null && eccTitle != 'Membro' && eccTitle != 'Visitante' && firstName != null) {
              final resolvedTitle = Helpers.resolveTitle(eccTitle, gender);
              titleText = '$resolvedTitle $firstName';
            }"""
content = content.replace(old_topbar, new_topbar)

with open('lib/main.dart', 'w') as f:
    f.write(content)
