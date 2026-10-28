enum DownloadStatus { downloading, converting, completed, failed }
enum MediaType { video, audio }

class DownloadItem {
  final String id;
  final String title;
  final String url;
  final String thumbnailUrl;
  final String quality;
  final MediaType mediaType;
  double progress;
  DownloadStatus status;
  int receivedBytes;
  int totalBytes;

  DownloadItem({
    required this.id,
    required this.title,
    required this.url,
    required this.thumbnailUrl,
    required this.quality,
    required this.mediaType,
    this.progress = 0.0,
    this.status = DownloadStatus.downloading,
    this.receivedBytes = 0,
    this.totalBytes = 0,
  });

  DownloadItem copyWith({
    double? progress,
    DownloadStatus? status,
    int? receivedBytes,
    int? totalBytes,
  }) {
    return DownloadItem(
      id: id,
      title: title,
      url: url,
      thumbnailUrl: thumbnailUrl,
      quality: quality,
      mediaType: mediaType,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
    );
  }
}