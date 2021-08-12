class Band {
  String id;
  String name;
  int votes;

  Band({
    required this.id,
    required this.name,
    required this.votes,
  });

  //factory constructor tiene como objetivo regresar una nueva instancia de mi clase

  factory Band.fromMap(Map<String, dynamic> obj) {
    return Band(id: obj['id'], name: obj['name'], votes: obj['votes']);
  }
}
