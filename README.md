# Sathi Ally - AI-Powered Hate Speech Resolution Assistant

## About

Sathi Ally is a mobile application developed for the UNESCO Youth Hackathon 2025. It helps users understand and resolve hate speech through constructive feedback powered by Google's Gemini AI.

## Features

- Real-time hate speech analysis
- AI-powered feedback on user responses
- Interactive learning environment
- Constructive resolution suggestions
- Progress tracking

## Tech Stack

- **Frontend**: Flutter
- **Backend**: FastAPI
- **AI Model**: Google Gemini AI API

## Installation

### Prerequisites

- Flutter SDK
- Python 3.8+
- IDE (VS Code recommended)

### Setup

1. Clone the repository

```bash
git clone https://github.com/ShresthaSwapnil/SathiAlly.git
```

2. Install Flutter dependencies

```bash
cd frontend
flutter pub get
```

3. Setup Backend

```bash
cd backend
pip install -r requirements.txt
```

4. Configure environment variables

```
GEMINI_API_KEY=your_api_key
DATABASE_URL=your_neon_postgresql_api_key
```

5. Run the application

```bash
flutter run
```

## How It Works

1. User encounters a hate speech scenario
2. App presents the situation and asks for user's response
3. Gemini AI analyzes the response
4. Provides constructive feedback and learning points
5. Suggests better ways to handle similar situations

## Contributing

Feel free to contribute to this project by submitting pull requests or opening issues.

## License

This project is licensed under the MIT License

## Team

- Aryaman Bista
- Aayush Bhattarai
- Aditya Malla Thakuri
- Diya Shakya
- Swapnil Shrestha

## Acknowledgments

- UNESCO Youth Hackathon 2025
- Google Gemini AI
- Flutter
