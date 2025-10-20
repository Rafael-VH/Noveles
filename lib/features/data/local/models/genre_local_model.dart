class GenreLocalModel {
  final int id;
  final DateTime createdAt;
  final String name;
  final String description;

  GenreLocalModel({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.description,
  });

  //  Se utiliza para actualizar los datos del 'Genero' sin modificar la instancia original.
  GenreLocalModel copyWith({
    int? id,
    DateTime? createdAt,
    String? name,
    String? description,
  }) {
    return GenreLocalModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  //  Devuelve un mapa de las propiedades de la 'Genero'.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt,
      'name': name,
      'description': description,
    };
  }

  //  Devuelve un mapa de las propiedades de la 'Genero' en formato JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt,
      'name': name,
      'description': description,
    };
  }

  //  Convierte un mapa JSON en una instancia de GenreModel.
  factory GenreLocalModel.fromJson(Map<String, dynamic> json) {
    return GenreLocalModel(
      id: json['id'],
      createdAt: json['createdAt'],
      name: json['name'],
      description: json['description'],
    );
  }
}
