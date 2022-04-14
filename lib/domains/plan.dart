class Plan {
  int id;
  int userId;
  int bookId;
  int strategy;
  int amountPerDay;
  int isDefaults;
  int phonetic;
  int state;

  Plan({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.strategy,
    required this.amountPerDay,
    required this.isDefaults,
    required this.phonetic,
    required this.state,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'],
      userId: json['user_id'],
      bookId: json['book_id'],
      strategy: json['strategy'],
      amountPerDay: json['amount_per_day'],
      isDefaults: json['default'],
      phonetic: json['phonetic'],
      state: json['state'],
    );
  }
}
