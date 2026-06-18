import 'package:werdi/features/tasmee3/domain/models/tasmee3_session.dart';

abstract interface class Tasmee3Repository {
  Future<List<Tasmee3Session>> getHistory();
  Future<void> saveSession(Tasmee3Session session);
}
