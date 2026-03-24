# Quiz Feature Implementation

This folder contains the implementation of the quiz feature for the KL MATKAA app, which includes:
- Quiz Home Screen with tabs for Quiz Play and Watch Live Match
- Quiz Play with multiple quiz sections 
- Quiz Description with terms and conditions
- MCQ Quiz with timer, animations, and score tracking

## Setup Instructions

### 1. Add Required Dependencies

The following packages are needed for this feature to work properly:
```yaml
confetti: ^0.7.0
lottie: ^3.1.0
audioplayers: ^6.0.0
```

### 2. Create Required Asset Directories

Make sure the following directories exist:
```
assets/animations/
assets/sound/
```

And update your pubspec.yaml to include them:
```yaml
assets:
  - assets/images/
  - assets/animations/
  - assets/sound/
```

### 3. Add Required Animation and Sound Files

For the complete experience, add the following files:
- `assets/animations/quiz_loading.json` - A loading animation for quiz
- `assets/animations/trophy.json` - A trophy animation for quiz winners
- `assets/animations/try_again.json` - An animation for when users don't perform well

- `assets/sound/countdown.mp3` - Sound for the countdown timer
- `assets/sound/select.mp3` - Sound for option selection
- `assets/sound/victory.mp3` - Sound for celebration when quiz is completed

### 4. Run flutter pub get

After adding dependencies, run:
```
flutter pub get
```

## Feature Usage

The app will show either the Quiz Home Screen or the KL MATKAA Screen based on the `isQuizBet` flag in `HomeScreen`. Users can switch between these modes using the toggle buttons in the app bar.

## How It Works

1. **Quiz Data Management**: Quiz data (sections, questions, results) is managed through the `QuizNotifier` class.

2. **Navigation Flow**:
   - HomeScreen → QuizHomeScreen → QuizPlayScreen → QuizPlayDescription → MCQQuizScreen → ResultScreen

3. **State Management**: Uses Riverpod for state management.

4. **Animations & Sound**: 
   - Animations for question transitions
   - Timer animations
   - Confetti celebration for good results
   - Sound effects for interactions

## Known Limitations

- The quiz currently uses mock data. In a production app, this should be fetched from an API.
- Sound and animation files need to be added manually to the assets directories.