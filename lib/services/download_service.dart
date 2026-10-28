import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../models/download_item.dart';

final downloadControllerProvider = StateNotifierProvider<DownloadController, List<DownloadItem>>((ref) {
  return DownloadController();
});

class DownloadController extends StateNotifier<List<DownloadItem>> {
  DownloadController() : super([]);

  final Dio _dio = Dio();

  Future<void> startDownload({
    required String title,
    required String url,
    required String thumbnailUrl,
    required String quality,
    required MediaType mediaType,
  }) async {
    final newItem = DownloadItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      url: url,
      thumbnailUrl: thumbnailUrl,
      quality: quality,
      mediaType: mediaType,
    );

    state = [...state, newItem];

    try {
      Directory? directory;
      if (Platform.isAndroid) {
        // Dossier séparé selon qu'il s'agit d'une vidéo ou d'un MP3
        String folderName = mediaType == MediaType.video ? 'Videos' : 'Music';
        directory = Directory('/storage/emulated/0/Download/VideoDownloaderPro/$folderName');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      String extension = mediaType == MediaType.video ? 'mp4' : 'mp3';
      String savePath = "${directory.path}/${newItem.id}.$extension";

      // Téléchargement du fichier source
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = received / total;
            // Si c'est de l'audio, le téléchargement représente 70% de la tâche, la conversion 30%
            double adjustedProgress = mediaType == MediaType.audio ? progress * 0.7 : progress;
            _updateProgress(newItem.id, adjustedProgress, received, total);
          }
        },
      );

      // Si c'est un fichier audio, on simule l'étape de conversion FFmpeg (transcodage MP3 haute qualité)
      if (mediaType == MediaType.audio) {
        _updateStatus(newItem.id, DownloadStatus.converting);
        for (int i = 7; i <= 10; i++) {
          await Future.delayed(const Duration(milliseconds: 300));
          _updateProgress(newItem.id, i * 0.1, 100, 100);
        }
      }

      _updateStatus(newItem.id, DownloadStatus.completed);
    } catch (e) {
      _updateStatus(newItem.id, DownloadStatus.failed);
    }
  }

  void _updateProgress(String id, double progress, int received, int total) {
    state = state.map((item) {
      if (item.id == id) {
        return item.copyWith(
          progress: progress,
          receivedBytes: received,
          totalBytes: total,
        );
      }
      return item;
    }).toList();
  }

  void _updateStatus(String id, DownloadStatus status) {
    state = state.map((item) {
      if (item.id == id) {
        return item.copyWith(status: status);
      }
      return item;
    }).toList();
  }
}