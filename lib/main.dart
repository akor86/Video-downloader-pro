import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'services/download_service.dart';
import 'models/download_item.dart';

void main() {
  runApp(const ProviderScope(child: VideoDownloaderApp()));
}

class VideoDownloaderApp extends StatelessWidget {
  const VideoDownloaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediaVault Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.dark(
          primary: Colors.deepPurpleAccent,
          secondary: Colors.amberAccent,
          surface: const Color(0xFF1E1E1E),
        ),
      ),
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const DownloadsScreen(),
    const PremiumSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.download_rounded),
            label: 'Télécharger',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_shared_rounded),
            label: 'Fichiers',
          ),
          NavigationDestination(
            icon: Icon(Icons.workspace_premium_rounded, color: Colors.amber),
            label: 'Mode Pro',
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Écran 1 : Accueil & Options de Téléchargement (Vidéo / Audio MP3)
// -----------------------------------------------------------------------------
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  String _selectedQuality = "4K 60FPS";
  MediaType _selectedMediaType = MediaType.video;

  void _showDownloadOptions(BuildContext context) {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer une URL valide !')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Options de Téléchargement & Conversion",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<MediaType>(
                    segments: const [
                      ButtonSegment(
                        value: MediaType.video,
                        label: Text('Vidéo MP4'),
                        icon: Icon(Icons.videocam),
                      ),
                      ButtonSegment(
                        value: MediaType.audio,
                        label: Text('Audio MP3'),
                        icon: Icon(Icons.audiotrack),
                      ),
                    ],
                    selected: {_selectedMediaType},
                    onSelectionChanged: (Set<MediaType> newSelection) {
                      setModalState(() {
                        _selectedMediaType = newSelection.first;
                        _selectedQuality = _selectedMediaType == MediaType.video
                            ? "4K 60FPS"
                            : "MP3 320 kbps (Studio)";
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _selectedMediaType == MediaType.video ? "Résolution Vidéo :" : "Qualité Audio (Bitrate) :",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: _selectedQuality,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF2C2C2C),
                    items: (_selectedMediaType == MediaType.video
                            ? ["4K 60FPS", "1080p Full HD", "720p HD"]
                            : ["MP3 320 kbps (Studio)", "MP3 192 kbps (Standard)", "FLAC Lossless"])
                        .map((quality) => DropdownMenuItem(
                              value: quality,
                              child: Text(quality),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => _selectedQuality = val);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _startProcess(url);
                      },
                      icon: const Icon(Icons.download_rounded),
                      label: Text(
                        _selectedMediaType == MediaType.video
                            ? "Lancer le Téléchargement Vidéo"
                            : "Convertir et Télécharger en MP3",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _startProcess(String url) {
    ref.read(downloadControllerProvider.notifier).startDownload(
          title: _selectedMediaType == MediaType.video
              ? "Conférence Flutter 2026 - Masterclass"
              : "Podcast Tech Pro - Audio HQ",
          url: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
          thumbnailUrl: "https://picsum.photos/300/200",
          quality: _selectedQuality,
          mediaType: _selectedMediaType,
        );

    _urlController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_selectedMediaType == MediaType.video
            ? 'Téléchargement vidéo lancé !'
            : 'Téléchargement et conversion MP3 en cours...'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MediaVault Pro 🚀', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.indigo],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Convertisseur & Téléchargeur Pro",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Extrayez vos flux en MP4 Ultra HD ou en MP3 Haute Fidélité instantanément sans publicité.",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: 'Collez le lien multimédia ici...',
                prefixIcon: const Icon(Icons.link),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _showDownloadOptions(context),
                icon: const Icon(Icons.tune_rounded),
                label: const Text(
                  "Analyser et Choisir le Format",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Écran 2 : Gestionnaire avec états de Conversion et Téléchargement
// -----------------------------------------------------------------------------
class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = ref.watch(downloadControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Fichiers & Conversions')),
      body: downloads.isEmpty
          ? const Center(
              child: Text("Aucun fichier en cours ou converti.",
                  style: TextStyle(color: Colors.grey)),
            )
          : ListView.builder(
              itemCount: downloads.length,
              itemBuilder: (context, index) {
                final item = downloads[index];
                
                String statusText = "";
                if (item.status == DownloadStatus.downloading) {
                  statusText = "Téléchargement...";
                } else if (item.status == DownloadStatus.converting) {
                  statusText = "Conversion en cours (MP3)...";
                } else if (item.status == DownloadStatus.completed) {
                  statusText = "Terminé avec succès";
                } else {
                  statusText = "Échec";
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CachedNetworkImage(
                            imageUrl: item.thumbnailUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => const Icon(Icons.insert_drive_file),
                          ),
                          Icon(
                            item.mediaType == MediaType.video ? Icons.play_circle_fill : Icons.audiotrack,
                            color: Colors.white70,
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                    title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text("$statusText • ${item.quality}", style: const TextStyle(fontSize: 12, color: Colors.amber)),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(value: item.progress),
                      ],
                    ),
                    trailing: Text(
                      item.status == DownloadStatus.completed
                          ? "Prêt"
                          : "${(item.progress * 100).toStringAsFixed(0)}%",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// -----------------------------------------------------------------------------
// Écran 3 : Options Premium
// -----------------------------------------------------------------------------
class PremiumSettingsScreen extends StatelessWidget {
  const PremiumSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Options Premium & Contrôles')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.block, color: Colors.redAccent),
            title: const Text('Bloqueur de Publicité Intégré'),
            subtitle: const Text('Traqueurs et pubs entièrement bloqués'),
            trailing: Switch(value: true, onChanged: (v) {}),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.audio_file, color: Colors.amberAccent),
            title: const Text('Conversion MP3 Automatique par défaut'),
            subtitle: const Text('Extrait directement la piste audio en 320kbps'),
            trailing: Switch(value: true, onChanged: (v) {}),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.speed, color: Colors.greenAccent),
            title: const Text('Accélération Multi-Thread Turbo'),
            subtitle: const Text('Vitesse maximale sur les flux vidéo/audio'),
            trailing: Switch(value: true, onChanged: (v) {}),
          ),
        ],
      ),
    );
  }
}