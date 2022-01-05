// To parse this JSON data, do
//
//     final usuario = usuarioFromJson(jsonString);

import 'dart:convert';

Usuario usuarioFromJson(String str) => Usuario.fromJson(json.decode(str));

String usuarioToJson(Usuario data) => json.encode(data.toJson());

class Usuario {
  int idUsuario;
  String nombre;
  String apellido;
  String cedula;
  DateTime createdAt;
  int createdBy;
  dynamic modifiedAt;
  dynamic modifiedBy;
  dynamic deletedAt;
  dynamic deletedBy;
  Usuario({
    this.idUsuario,
    this.nombre,
    this.apellido,
    this.cedula,
    this.createdAt,
    this.createdBy,
    this.modifiedAt,
    this.modifiedBy,
    this.deletedAt,
    this.deletedBy,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        idUsuario: json["idUsuario"],
        nombre: json["nombre"],
        apellido: json["apellido"],
        cedula: json["cedula"],
        createdAt: DateTime.parse(json["createdAt"]),
        createdBy: json["createdBy"],
        modifiedAt: json["modifiedAt"],
        modifiedBy: json["modifiedBy"],
        deletedAt: json["deletedAt"],
        deletedBy: json["deletedBy"],
      );

  Map<String, dynamic> toJson() => {
        "idUsuario": idUsuario,
        "nombre": nombre,
        "apellido": apellido,
        "cedula": cedula,
        "createdAt": createdAt.toIso8601String(),
        "createdBy": createdBy,
        "modifiedAt": modifiedAt,
        "modifiedBy": modifiedBy,
        "deletedAt": deletedAt,
        "deletedBy": deletedBy,
      };
}
