/// "Kur'an'a Sor" isteği sırasında oluşan, kullanıcıya gösterilebilir hata.
class AskQuranFailure implements Exception {
  const AskQuranFailure(this.message);

  final String message;

  @override
  String toString() => message;
}