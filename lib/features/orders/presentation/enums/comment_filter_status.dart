/// Статус фильтра комментариев
enum CommentFilterStatus {
  all('all', 'Все'),
  completed('completed', 'Выполненные'),
  pending('pending', 'Невыполненные');

  const CommentFilterStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static CommentFilterStatus fromString(String value) {
    return CommentFilterStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => CommentFilterStatus.all,
    );
  }
}
