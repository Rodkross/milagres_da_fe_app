with open('lib/main.dart', 'r') as f:
    content = f.read()

old_state = """  @override
  void dispose() {"""

new_state = """  @override
  void didUpdateWidget(_HeroBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      if (_currentPage >= widget.items.length) {
        _currentPage = widget.items.isEmpty ? 0 : widget.items.length - 1;
        if (_controller.hasClients) {
          _controller.jumpToPage(_currentPage);
        }
      }
      _startAutoPlay();
    }
  }

  @override
  void dispose() {"""

content = content.replace(old_state, new_state)

with open('lib/main.dart', 'w') as f:
    f.write(content)
