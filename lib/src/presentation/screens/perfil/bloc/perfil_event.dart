abstract class PerfilEvent {
  const PerfilEvent();
}

// *********************************************************
// 1. CONSULTAR O ACTUALIZAR PERFIL
// *********************************************************
class PerfilRequested extends PerfilEvent {
  const PerfilRequested();
}

// *********************************************************
// 2. LIMPIAR PERFIL
// *********************************************************
class PerfilCleared extends PerfilEvent {
  const PerfilCleared();
}
