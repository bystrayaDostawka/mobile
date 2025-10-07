import 'package:dio/dio.dart';

import '../../../../core/usecase/usecase.dart';
import '../repositories/orders_repository.dart';

class DownloadOrderFileUseCase implements UseCase<Result<Response<List<int>>>, DownloadOrderFileParams> {
  const DownloadOrderFileUseCase({required this.repository});

  final OrdersRepository repository;

  @override
  Future<Result<Response<List<int>>>> call(DownloadOrderFileParams params) async {
    return await repository.downloadOrderFile(params.orderId, params.fileId);
  }
}

class DownloadOrderFileParams {
  const DownloadOrderFileParams({
    required this.orderId,
    required this.fileId,
  });

  final int orderId;
  final int fileId;
}
