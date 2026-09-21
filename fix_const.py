with open('lib/main.dart', 'r') as f:
    content = f.read()

# Replace 'const SliverPadding(' before the StreamBuilder with just 'SliverPadding('
old_sliver = """          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 28, 20, 0),
            sliver: SliverToBoxAdapter(
              child: StreamBuilder<QuerySnapshot>("""

new_sliver = """          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
            sliver: SliverToBoxAdapter(
              child: StreamBuilder<QuerySnapshot>("""

content = content.replace(old_sliver, new_sliver)

with open('lib/main.dart', 'w') as f:
    f.write(content)
