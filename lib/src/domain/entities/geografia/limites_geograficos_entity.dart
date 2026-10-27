class LimitesGeograficosEntity {
  final double oeste;
  final double sur;
  final double este;
  final double norte;

  const LimitesGeograficosEntity({
    required this.oeste,
    required this.sur,
    required this.este,
    required this.norte,
  }) : assert(oeste >= -180 && oeste <= 180),
       assert(este >= -180 && este <= 180),
       assert(sur >= -90 && sur <= 90),
       assert(norte >= -90 && norte <= 90),
       assert(sur <= norte);
}
