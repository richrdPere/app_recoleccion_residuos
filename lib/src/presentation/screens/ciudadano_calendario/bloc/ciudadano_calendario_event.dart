abstract class CiudadanoCalendarioEvent {
  const CiudadanoCalendarioEvent();
}

class CiudadanoCalendarioRequested extends CiudadanoCalendarioEvent {
  final DateTime mes;

  const CiudadanoCalendarioRequested({required this.mes});
}
