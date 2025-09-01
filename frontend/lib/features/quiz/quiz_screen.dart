import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:frontend/models/quiz.dart';
import 'package:frontend/features/quiz/quiz_results_screen.dart';
import 'package:flutter/services.dart';

class QuizScreen extends StatefulWidget {
  final String topic;
  final List<QuizQuestion> questions;
  const QuizScreen({super.key, required this.topic, required this.questions});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  int _score = 0;
  bool _isAnswered = false;

  void _answerQuestion(int selectedIndex) {
    HapticFeedback.lightImpact();
    if (_isAnswered) return;
    setState(() {
      _selectedAnswerIndex = selectedIndex;
      _isAnswered = true;
      if (selectedIndex ==
          widget.questions[_currentQuestionIndex].correctAnswerIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    HapticFeedback.lightImpact();
    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswered = false;
        _selectedAnswerIndex = null;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultsScreen(
            topic: widget.topic,
            score: _score,
            totalQuestions: widget.questions.length,
          ),
        ),
      );
    }
  }

  // --- NEW: Confirmation Dialog Logic ---
  Future<bool> _onWillPop() async {
    return (await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text(
              'If you leave now, your quiz progress will be lost.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Leave'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_currentQuestionIndex];
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Knowledge Check'),
          centerTitle: true,
          // --- CHANGE 1: REMOVE automaticallyImplyLeading: false ---
          // This will make the default back button appear.
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // --- NEW: Progress Stepper ---
              _ProgressStepper(
                totalQuestions: widget.questions.length,
                currentQuestion: _currentQuestionIndex,
              ),
              const SizedBox(height: 32),
              // --- Question Text ---
              FadeIn(
                key: ValueKey(
                  _currentQuestionIndex,
                ), // Animate when question changes
                child: Text(
                  question.questionText,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              // --- Answer Options ---
              Expanded(
                child: ListView.builder(
                  itemCount: question.options.length,
                  itemBuilder: (context, index) {
                    return FadeInUp(
                      delay: Duration(milliseconds: 100 * index),
                      key: ValueKey('${_currentQuestionIndex}_$index'),
                      child: _AnswerOption(
                        text: question.options[index],
                        isSelected: _selectedAnswerIndex == index,
                        isCorrect: index == question.correctAnswerIndex,
                        isAnswered: _isAnswered,
                        onTap: () => _answerQuestion(index),
                      ),
                    );
                  },
                ),
              ),
              // --- Next Button ---
              if (_isAnswered)
                FadeInUp(
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: Text(
                      _currentQuestionIndex < widget.questions.length - 1
                          ? 'Next Question'
                          : 'See Results',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- NEW CUSTOM WIDGETS ---

class _ProgressStepper extends StatelessWidget {
  final int totalQuestions;
  final int currentQuestion;
  const _ProgressStepper({
    required this.totalQuestions,
    required this.currentQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalQuestions, (index) {
        bool isActive = index == currentQuestion;
        bool isCompleted = index < currentQuestion;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: 40,
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : isCompleted
                ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isAnswered;
  final VoidCallback onTap;

  const _AnswerOption({
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.isAnswered,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color? borderColor;
    IconData? trailingIcon;

    if (isAnswered) {
      if (isCorrect) {
        borderColor = Colors.green;
        trailingIcon = Iconsax.tick_circle;
      } else if (isSelected) {
        borderColor = Colors.red;
        trailingIcon = Iconsax.close_circle;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor ?? Colors.transparent, width: 2),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(text),
        trailing: trailingIcon != null
            ? Icon(trailingIcon, color: borderColor)
            : null,
      ),
    );
  }
}
