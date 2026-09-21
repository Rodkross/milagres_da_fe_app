with open('lib/main.dart', 'r') as f:
    content = f.read()

# Remove current Row structure
old_structure = """
    return Row(
      children: [
        _Avatar(user: user, isAdmin: isAdmin),
        const SizedBox(width: 12),
        Expanded(
          child: StreamBuilder<DocumentSnapshot>(
"""
new_structure = """
    return StreamBuilder<DocumentSnapshot>(
"""

content = content.replace(old_structure, new_structure)

# In the return statement of StreamBuilder, add the Row
old_return = """
                  return Row(
                    children: [
"""
new_return = """
                  return Row(
                    children: [
                      _Avatar(user: user, isAdmin: isAdmin),
                      const SizedBox(width: 12),
"""
content = content.replace(old_return, new_return)

# Also fix the fallback return of StreamBuilder
old_fallback = """
              // Fallback se não tiver dados ainda
              return Column(
"""
new_fallback = """
              // Fallback se não tiver dados ainda
              return Row(
                children: [
                  _Avatar(user: user, isAdmin: false),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
"""
content = content.replace(old_fallback, new_fallback)

# Close the Expanded in the fallback
old_fallback_end = """
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
"""
new_fallback_end = """
                      ),
                    ],
                  ),
                  ),
                ],
              );
            },
    );
"""
content = content.replace(old_fallback_end, new_fallback_end)

with open('lib/main.dart', 'w') as f:
    f.write(content)
