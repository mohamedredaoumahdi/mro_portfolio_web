// This file contains all your personal information and configuration
// Edit this file to update your portfolio content

class AppConfig {
  // Personal Information
  static const String name = "Mohamed Reda Oumahdi";
  static const String initials = "MRO";
  static const String title = "Mobile App Developer";
  static const String email = "mrodev.official@gmail.com";
  static const String phone = "+212 627344151";
  static const String location = "Agadir, Morocco";
  
  // About Me Description
  static const String aboutMe = """
I am a passionate mobile application developer specializing in creating 
beautiful and functional apps for iOS and Android platforms. With expertise 
in Flutter development, I deliver cross-platform solutions that provide 
native-like experiences.
""";

  // Services Offered
  static const List<ServiceInfo> services = [
    ServiceInfo(
      title: "Mobile App Development",
      description: "Development of high-quality native and cross-platform mobile applications for iOS and Android.",
      iconPath: "",
    ),
    ServiceInfo(
      title: "UI/UX Design",
      description: "Creating intuitive and engaging user interfaces with focus on user experience and modern design principles.",
      iconPath: "",
    ),
    ServiceInfo(
      title: "API Integration",
      description: "Seamless integration with RESTful APIs, third-party services, and backend systems.",
      iconPath: "",
    ),
    ServiceInfo(
      title: "App Maintenance",
      description: "Ongoing support, bug fixes, and feature enhancements for existing mobile applications.",
      iconPath: "",
    ),
  ];

  // Projects - YouTube video IDs and descriptions
  static const List<ProjectInfo> projects = [
    ProjectInfo(
      title: "E-Commerce Mobile App",
      description: "A full-featured e-commerce application with product browsing, cart management, and secure checkout process.",
      technologies: ["Flutter", "Firebase", "Stripe"],
      youtubeVideoId: "VIDEO_ID_1", // Replace with your actual YouTube video ID
      thumbnailUrl: "assets/images/projects/ecommerce_thumbnail.jpg",
    ),
    ProjectInfo(
      title: "Food Delivery Application",
      description: "On-demand food delivery platform connecting users with local restaurants, featuring real-time order tracking.",
      technologies: ["Flutter", "Google Maps API", "Node.js"],
      youtubeVideoId: "VIDEO_ID_2", // Replace with your actual YouTube video ID
      thumbnailUrl: "assets/images/projects/food_delivery_thumbnail.jpg",
    ),
    ProjectInfo(
      title: "Fitness Tracking App",
      description: "Personal fitness companion app with workout tracking, progress visualization, and customized training plans.",
      technologies: ["Flutter", "HealthKit", "Google Fit"],
      youtubeVideoId: "VIDEO_ID_3", // Replace with your actual YouTube video ID
      thumbnailUrl: "assets/images/projects/fitness_thumbnail.jpg",
    ),
  ];

  // Social Media Links
  static const SocialLinks socialLinks = SocialLinks(
    fiverr: "https://fiverr.com/yourusername",
    upwork: "https://upwork.com/yourusername",
    freelancer: "https://freelancer.com/yourusername",
    instagram: "https://instagram.com/yourusername",
    facebook: "https://facebook.com/yourusername",
    github: "https://github.com/yourusername",
    linkedin: "https://linkedin.com/in/yourusername",
  );

  // Theme Configuration
  static const ThemeConfig themeConfig = ThemeConfig(
    useDarkMode: true,
    primaryColor: 0xFF4A00E0,    // Deep purple
    accentColor: 0xFF8E2DE2,     // Purple
    backgroundColor: 0xFF121212, // Dark background
    textPrimaryColor: 0xFFFFFFFF, // White
    textSecondaryColor: 0xFFBDBDBD, // Light gray
  );
}

// Models for configuration data
class ServiceInfo {
  final String title;
  final String description;
  final String iconPath;

  const ServiceInfo({
    required this.title,
    required this.description,
    required this.iconPath,
  });
}

class ProjectInfo {
  final String title;
  final String description;
  final List<String> technologies;
  final String youtubeVideoId;
  final String thumbnailUrl;

  const ProjectInfo({
    required this.title,
    required this.description,
    required this.technologies,
    required this.youtubeVideoId,
    required this.thumbnailUrl,
  });
}

class SocialLinks {
  final String fiverr;
  final String upwork;
  final String freelancer;
  final String instagram;
  final String facebook;
  final String github;
  final String linkedin;

  const SocialLinks({
    required this.fiverr,
    required this.upwork,
    required this.freelancer,
    required this.instagram,
    required this.facebook,
    required this.github,
    required this.linkedin,
  });
}

class ThemeConfig {
  final bool useDarkMode;
  final int primaryColor;
  final int accentColor;
  final int backgroundColor;
  final int textPrimaryColor;
  final int textSecondaryColor;

  const ThemeConfig({
    required this.useDarkMode,
    required this.primaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
  });
}