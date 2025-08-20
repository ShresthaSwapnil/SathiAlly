import 'package:flutter/material.dart';
import 'package:frontend/models/quiz.dart';
import 'package:frontend/features/quiz/quiz_results_screen.dart';

class QuizScreen extends StatefulWidget {
  final List<QuizQuestion> questions;
  const QuizScreen({super.key, required this.questions});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  int _score = 0;
  bool _isAnswered = false;

  void _answerQuestion(int selectedIndex) {
    if (_isAnswered) return; // Prevent answering twice

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
    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswered = false;
        _selectedAnswerIndex = null;
      });
    } else {
      // End of quiz
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultsScreen(
            score: _score,
            totalQuestions: widget.questions.length,
          ),
        ),
      );
    }
  }

  Color _getOptionColor(int index) {
    if (!_isAnswered) {
      return _selectedAnswerIndex == index
          ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
          : Theme.of(context).colorScheme.surface;
    } else {
      if (index == widget.questions[_currentQuestionIndex].correctAnswerIndex) {
        return Colors.green.withOpacity(0.3); // Correct answer
      } else if (index == _selectedAnswerIndex) {
        return Colors.red.withOpacity(0.3); // Incorrect selected answer
      }
    }
    return Theme.of(context).colorScheme.surface;
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quiz: Question ${_currentQuestionIndex + 1}/${widget.questions.length}',
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              question.questionText,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            ...List.generate(question.options.length, (index) {
              return Card(
                color: _getOptionColor(index),
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(question.options[index]),
                  onTap: () => _answerQuestion(index),
                ),
              );
            }),
            const Spacer(),
            if (_isAnswered)
              ElevatedButton(
                onPressed: _nextQuestion,
                child: Text(
                  _currentQuestionIndex < widget.questions.length - 1
                      ? 'Next Question'
                      : 'Finish Quiz',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
