///User notes
class UserNote {
  ///user note
  String note;

  ///Is favorite flag
  bool isFavorite = false;

  ///User note constructor
  UserNote({this.note, this.isFavorite});

  ///FromJSON method to handle json decoding
  UserNote.fromJson(Map<String, dynamic> json)
      : note = json['note'],
        isFavorite = json['isFavorite'];

  ///ToJSON method to handle json encoding
  Map<String, dynamic> toJson() {
    return {
      'note': note,
      'isFavorite': isFavorite,
    };
  }
}
