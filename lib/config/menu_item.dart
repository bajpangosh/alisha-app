class MenuItem {
  final String label;
  final String icon; // Icon name (e.g. 'home', 'info')
  final String action; // 'url', 'page', 'share'
  final String value; // The url or page route

  MenuItem({
    required this.label,
    required this.icon,
    required this.action,
    required this.value,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    final rawAction = (json['action'] ?? json['type'] ?? '').toString().trim();
    final normalizedAction = rawAction.isEmpty ? 'url' : rawAction;
    final rawValue = json['value'] ?? json['url'] ?? json['link'] ?? json['path'] ?? '';

    return MenuItem(
      label: json['label'] ?? '',
      icon: json['icon'] ?? '',
      action: normalizedAction,
      value: rawValue.toString(),
    );
  }
}
