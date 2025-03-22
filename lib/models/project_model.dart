// Project model class
class Project {
  final String id;
  final String title;
  final String description;
  final List<String> technologies;
  final String youtubeVideoId;
  final String thumbnailUrl;
  final DateTime? date;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.technologies,
    required this.youtubeVideoId,
    required this.thumbnailUrl,
    this.date,
  });

  // Factory constructor to convert from AppConfig ProjectInfo
  factory Project.fromConfig(int index, dynamic projectInfo) {
    return Project(
      id: 'project_$index',
      title: projectInfo.title,
      description: projectInfo.description,
      technologies: List<String>.from(projectInfo.technologies),
      youtubeVideoId: projectInfo.youtubeVideoId,
      thumbnailUrl: projectInfo.thumbnailUrl,
      date: DateTime.now().subtract(Duration(days: index * 30)), // Mock date
    );
  }

  // Generate YouTube video URL
  String get youtubeUrl => 'https://www.youtube.com/embed/$youtubeVideoId';
  
  // Generate YouTube thumbnail URL if none provided
  String get youtubeThumbnail => thumbnailUrl.isEmpty 
      ? 'https://img.youtube.com/vi/$youtubeVideoId/hqdefault.jpg'
      : thumbnailUrl;
}

// Service model class
class Service {
  final String id;
  final String title;
  final String description;
  final String iconPath;

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
  });

  // Factory constructor to convert from AppConfig ServiceInfo
  factory Service.fromConfig(int index, dynamic serviceInfo) {
    return Service(
      id: 'service_$index',
      title: serviceInfo.title,
      description: serviceInfo.description,
      iconPath: serviceInfo.iconPath,
    );
  }
}