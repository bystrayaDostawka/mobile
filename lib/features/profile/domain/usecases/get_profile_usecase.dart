import '../../../../core/usecase/usecase.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../data/model/profile_response_model.dart';

/// Use Case для получения профиля пользователя
class GetProfileUseCase
    extends UseCase<Result<ProfileResponseModel>, NoParams> {
  GetProfileUseCase({required this.profileRepository});

  final ProfileRepository profileRepository;

  @override
  Future<Result<ProfileResponseModel>> call(NoParams params) async {
    return await profileRepository.getProfile();
  }
}
