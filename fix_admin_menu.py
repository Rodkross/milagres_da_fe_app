with open('lib/main.dart', 'r') as f:
    lines = f.readlines()

new_lines = []
skip = False
for i, line in enumerate(lines):
    if skip:
        if line.strip() == '],':
            skip = False
        continue
    
    # Remove shield from TopBar
    if 'if (isAdmin)' in line and 'IconButton(' in lines[i+1]:
        skip = True
        continue
    
    # Make _Avatar take isAdmin
    if 'class _Avatar extends StatelessWidget {' in line:
        new_lines.append(line)
        new_lines.append("  const _Avatar({required this.user, this.isAdmin = false});\n")
        new_lines.append("\n")
        new_lines.append("  final User user;\n")
        new_lines.append("  final bool isAdmin;\n")
        continue
    if 'const _Avatar({required this.user});' in line:
        continue
    if 'final User user;' in line and 'class _Avatar' in lines[i-3]:
        continue

    # Fix placeholder in _showUserMenu
    if 'final bool isAdmin = true; // Placeholder para permissões' in line:
        # Just remove this line since isAdmin is now a class field
        continue

    # Pass isAdmin to _Avatar in TopBar
    if '_Avatar(user: user),' in line:
        line = line.replace('_Avatar(user: user),', '_Avatar(user: user, isAdmin: isAdmin),')
    
    new_lines.append(line)

with open('lib/main.dart', 'w') as f:
    f.writelines(new_lines)
