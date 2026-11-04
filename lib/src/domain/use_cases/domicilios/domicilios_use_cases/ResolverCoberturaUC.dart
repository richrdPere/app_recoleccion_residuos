import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/repositories.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class ResolverCoberturaUC {
  DomiciliosRepository domiciliosRepository;
  ResolverCoberturaUC(this.domiciliosRepository);

  Future<Resource<ApiResponse<ResolverCoberturaDataModel>>> run({
    required ResolverCoberturaRequest request,
  }) => domiciliosRepository.resolverCobertura(request: request);
}
