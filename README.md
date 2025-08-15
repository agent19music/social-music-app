# 🎵 Music Social Platform

A beautiful, iOS-inspired music social platform combining analytics, dating, and live music battles.

## 🏗️ Architecture

```
music-social-platform/
├── client/          # Flutter cross-platform app
├── backend/         # Flask Python REST API
├── shared/          # Shared configurations and assets
└── docs/           # Documentation
```

## ✨ Features

- **Music Analytics Dashboard** - Beautiful stats cards with listening insights
- **Social Discovery** - Match with people based on music compatibility
- **Aux Wars** - Live music battle competitions
- **Cross-Platform** - iOS, Android, Web, Desktop from single codebase
- **Real-time Updates** - WebSocket-powered live interactions

## 🚀 Quick Start

### Prerequisites
- Flutter 3.16+ 
- Python 3.11+
- PostgreSQL 15+
- Redis 7+
- Node.js 18+ (for tooling)

### Development Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/music-social-platform.git
cd music-social-platform

# Backend setup
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env
# Configure your .env file
flask db upgrade
flask run

# Client setup (new terminal)
cd ../client
flutter pub get
flutter run -d chrome  # Or your preferred device
```

## 📱 Supported Platforms

- iOS 12.0+
- Android 5.0+ (API 21)
- Web (Chrome, Safari, Firefox, Edge)
- macOS 10.14+
- Windows 10+
- Linux (Ubuntu 18.04+)

## 🎨 Design Philosophy

- **iOS-inspired aesthetics** with clean, minimal cards
- **Smooth animations** and micro-interactions
- **Responsive design** adapting to any screen size
- **Dark/Light themes** with calm accent colors
- **Consistent spacing** and typography hierarchy

## 📚 Documentation

- [API Documentation](./docs/api.md)
- [Flutter Architecture](./docs/flutter-architecture.md)
- [Database Schema](./docs/database.md)
- [Deployment Guide](./docs/deployment.md)

## 🤝 Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for details.

## 📄 License

MIT License - see [LICENSE](./LICENSE) file.
