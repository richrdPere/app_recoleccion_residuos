// Services
import 'package:app_recoleccion_residuos/src/data/datasources/remote/remote.dart';

// Resources
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Repositories
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

class DispositivoRepositoryImpl implements DispositivoRepository {
  final DispositivosService dispositivosService;
  final AuthRepository authRepository;

  DispositivoRepositoryImpl(this.dispositivosService, this.authRepository);

  // *********************************************************
  // 1. REGISTRAR DISPOSITIVO
  // *********************************************************
  @override
  Future<Resource<ApiResponse<RegistrarDispositivoDataModel>>>
  registrarDispositivo({required RegistrarDispositivoRequest request}) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await dispositivosService.registrarDispositivo(
      request: request,
      token: token,
    );
  }

  // *********************************************************
  // 2. OBTENER MIS DISPOSITIVOS
  // *********************************************************
  @override
  Future<Resource<ApiResponse<List<MiDispositivoDataModel>>>>
  getMisDispositivos() async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await dispositivosService.getMisDispositivos(token: token);
  }

  // *********************************************************
  // 3. DESACTIVAR DISPOSITIVO
  // *********************************************************
  @override
  Future<Resource<ApiResponse<DesactivarDispositivoDataModel>>>
  desactivarDispositivo({
    required int idDispositivo,
    DesactivarDispositivoRequest request = const DesactivarDispositivoRequest(),
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await dispositivosService.desactivarDispositivo(
      idDispositivo: idDispositivo,
      token: token,
    );
  }

  // *********************************************************
  // 4. DESACTIVAR DISPOSITIVO POR TOKEN
  // *********************************************************
  @override
  Future<Resource<ApiResponse<DesactivarDispositivoTokenDataModel>>>
  desactivarDispositivoPorToken({
    required DesactivarDispositivoTokenRequest request,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await dispositivosService.desactivarDispositivoPorToken(
      request: request,
      token: token,
    );
  }
}
