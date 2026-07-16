enum StatusMeja { kosong, terisi }

class Meja {
  final String id;
  final String nomor;
  StatusMeja status;

  Meja({
    required this.id,
    required this.nomor,
    this.status = StatusMeja.kosong,
  });
}
