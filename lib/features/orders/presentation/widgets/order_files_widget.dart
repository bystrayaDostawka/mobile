import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/order_file_entity.dart';
import '../../domain/usecases/get_order_files_usecase.dart';
import '../../domain/usecases/download_order_file_usecase.dart';
import '../../../../core/di/injection.dart';

class OrderFilesWidget extends StatefulWidget {
  const OrderFilesWidget({
    super.key,
    required this.orderId,
  });

  final int orderId;

  @override
  State<OrderFilesWidget> createState() => _OrderFilesWidgetState();
}

class _OrderFilesWidgetState extends State<OrderFilesWidget> {
  List<OrderFileEntity> _files = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    print('📁 OrderFilesWidget: Инициализация для заказа ${widget.orderId}');
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final getFilesUseCase = getIt<GetOrderFilesUseCase>();
      final result = await getFilesUseCase(
        GetOrderFilesParams(orderId: widget.orderId),
      );
      
      if (result.isSuccess) {
        setState(() {
          _files = result.data ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Ошибка загрузки файлов: ${result.failure?.message ?? "Неизвестная ошибка"}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Ошибка загрузки файлов: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadFile(OrderFileEntity file) async {
    try {
      final downloadUseCase = getIt<DownloadOrderFileUseCase>();
      final result = await downloadUseCase(
        DownloadOrderFileParams(
          orderId: widget.orderId,
          fileId: file.id,
        ),
      );

      if (result.isSuccess) {
        // Для простоты показываем URL файла
        if (file.url.isNotEmpty) {
          final uri = Uri.parse(file.url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка скачивания файла: ${result.failure?.message ?? "Неизвестная ошибка"}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка скачивания файла: $e')),
        );
      }
    }
  }

  String _getFileIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return '📄';
      case 'image':
        return '🖼️';
      case 'document':
        return '📝';
      case 'spreadsheet':
        return '📊';
      case 'presentation':
        return '📽️';
      case 'archive':
        return '📦';
      default:
        return '📁';
    }
  }

  @override
  Widget build(BuildContext context) {
    print('📁 OrderFilesWidget: Рендеринг виджета, isLoading: $_isLoading, error: $_error, files: ${_files.length}');
    
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFiles,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (_files.isEmpty) {
      return const Center(
        child: Text(
          'Файлы не найдены',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _files.length,
      itemBuilder: (context, index) {
        final file = _files[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: Text(
              _getFileIcon(file.fileType),
              style: const TextStyle(fontSize: 24),
            ),
            title: Text(
              file.fileName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Размер: ${file.formattedSize}'),
                Text('Загружен: ${file.uploadedBy.name}'),
                Text(
                  '${file.createdAt.day}.${file.createdAt.month}.${file.createdAt.year}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => _downloadFile(file),
              tooltip: 'Скачать файл',
            ),
            onTap: () => _downloadFile(file),
          ),
        );
      },
    );
  }
}
