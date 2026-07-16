class UsuarioModelo {
  final String id;
  final String nombre;
  final String correo;
  final String? urlFoto;

  UsuarioModelo({
    required this.id,
    required this.nombre,
    required this.correo,
    this.urlFoto,
  });
}
