with open('pubspec.yaml', 'r') as f:
    content = f.read()

old_deps = """dependencies:
  flutter:
    sdk: flutter"""

new_deps = """dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter"""

content = content.replace(old_deps, new_deps)

with open('pubspec.yaml', 'w') as f:
    f.write(content)
