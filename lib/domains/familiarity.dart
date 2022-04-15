class Familiarity {
  const Familiarity(this.desc, this.level);
  final String desc;
  final int level;
  factory Familiarity.unfamiliar() {
    return const Familiarity("不认识", 0);
  }
  factory Familiarity.familiar() {
    return const Familiarity("有印象", 1);
  }
  factory Familiarity.mastered() {
    return const Familiarity("已掌握", 2);
  }
}
