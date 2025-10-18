import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math';
import 'package:internappflutter/skillVerify/Testend.dart';

class test1 extends StatefulWidget {
  final String selectedSkill;
  final String selectedLevel;
  const test1({
    super.key,
    required this.selectedSkill,
    required this.selectedLevel,
  });

  @override
  State<test1> createState() => _test1State();
}

class _test1State extends State<test1> {
  int? selectedOption;
  int currentQuestionIndex = 0;
  Map<String, dynamic>? questionsData;
  List<String> questionKeys = [];
  bool isLoading = true;
  final Random _random = Random();

  // Track correct answers
  int correctAnswersCount = 0;
  Map<int, int?> userAnswers = {}; // Store user's selected answers

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    try {
      print(
        'Loading questions for: ${widget.selectedSkill} - ${widget.selectedLevel}',
      );

      String fileName = 'assets/skills.json';
      final String response = await rootBundle.loadString(fileName);
      final dynamic decodedData = json.decode(response);

      Map<String, dynamic>? data;

      // Check if the JSON is an array or object
      if (decodedData is List) {
        print('JSON is a List with ${decodedData.length} items');
        // Find the matching skill and level in the array (case-insensitive)
        for (var item in decodedData) {
          if (item['Skill']?.toString().toLowerCase() ==
                  widget.selectedSkill.toLowerCase() &&
              item['Difficulty']?.toString().toLowerCase() ==
                  widget.selectedLevel.toLowerCase()) {
            data = item as Map<String, dynamic>;
            break;
          }
        }

        if (data == null) {
          print('No matching skill found in list');
          print('Available skills:');
          for (var item in decodedData) {
            print('  - ${item['Skill']} (${item['Difficulty']})');
          }
        }
      } else if (decodedData is Map) {
        print('JSON is a Map/Object');
        data = decodedData as Map<String, dynamic>;

        // Verify if it matches (case-insensitive)
        if (data['Skill']?.toString().toLowerCase() !=
                widget.selectedSkill.toLowerCase() ||
            data['Difficulty']?.toString().toLowerCase() !=
                widget.selectedLevel.toLowerCase()) {
          print('Skill/Level mismatch');
          print('Expected: ${widget.selectedSkill} - ${widget.selectedLevel}');
          print('Got: ${data['Skill']} - ${data['Difficulty']}');
          data = null;
        }
      }

      if (data != null) {
        print('Found matching data!');

        // Get all question keys as strings
        List<String> keys = [];
        data.forEach((key, value) {
          if (key != 'Skill' && key != 'Difficulty') {
            keys.add(key);
          }
        });

        // Sort numerically
        keys.sort((a, b) {
          try {
            return int.parse(a).compareTo(int.parse(b));
          } catch (e) {
            return a.compareTo(b);
          }
        });

        print('Total questions available: ${keys.length}');

        // Randomly select 10 questions
        List<String> selectedKeys = [];
        if (keys.length <= 10) {
          // If 10 or fewer questions, use all
          selectedKeys = keys;
        } else {
          // Randomly select 10 questions
          List<String> shuffledKeys = List.from(keys);
          shuffledKeys.shuffle(_random);
          selectedKeys = shuffledKeys.take(10).toList();

          // Sort the selected keys to maintain order
          selectedKeys.sort((a, b) {
            try {
              return int.parse(a).compareTo(int.parse(b));
            } catch (e) {
              return a.compareTo(b);
            }
          });
        }

        setState(() {
          questionsData = data;
          questionKeys = selectedKeys;
          isLoading = false;
        });

        print('Selected ${questionKeys.length} random questions');
        print('Selected question keys: $questionKeys');
      } else {
        print('Could not find matching skill data');
        setState(() {
          isLoading = false;
        });

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Error'),
              content: Text(
                'Could not find questions for ${widget.selectedSkill} - ${widget.selectedLevel}',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text('Go Back'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('Error loading questions: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text(
              'Failed to load questions: $e\n\nPlease check the console for details.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('Go Back'),
              ),
            ],
          ),
        );
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  Map<String, dynamic>? getCurrentQuestion() {
    if (questionsData == null || questionKeys.isEmpty) return null;
    String currentKey = questionKeys[currentQuestionIndex];
    var question = questionsData![currentKey];

    // Ensure it's a Map
    if (question is Map<String, dynamic>) {
      return question;
    } else if (question is Map) {
      return Map<String, dynamic>.from(question);
    }
    return null;
  }

  void nextQuestion() {
    if (selectedOption == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select an option')));
      return;
    }

    // Store the user's answer
    userAnswers[currentQuestionIndex] = selectedOption;

    // Check if the answer is correct
    final currentQuestion = getCurrentQuestion();
    if (currentQuestion != null) {
      String correctAnswer = currentQuestion['Correct']?.toString() ?? '';
      // Convert selectedOption (0-3) to answer key (1-4)
      String userAnswer = (selectedOption! + 1).toString();

      if (userAnswer == correctAnswer) {
        correctAnswersCount++;
        print('Correct! Total correct: $correctAnswersCount');
      } else {
        print(
          'Wrong! Correct answer was: $correctAnswer, User answered: $userAnswer',
        );
      }
    }

    if (currentQuestionIndex < questionKeys.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedOption = null;
      });
    } else {
      // Calculate percentage
      double percentage = (correctAnswersCount / questionKeys.length) * 100;
      String testResult2 =
          '${correctAnswersCount}/${questionKeys.length} (${percentage.toStringAsFixed(1)}%)';
      String testResult = '$correctAnswersCount';

      print('Test completed! Score: $testResult');

      // Navigate to test end screen with results
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TestSuccessPage(
            userskill: widget.selectedSkill,
            TestResult: testResult,
            userlevel: widget.selectedLevel,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentQuestion = getCurrentQuestion();
    if (currentQuestion == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('No questions available for this skill and level'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    // Access options as strings from the question map
    final List<String> options = [
      currentQuestion['1']?.toString() ?? '',
      currentQuestion['2']?.toString() ?? '',
      currentQuestion['3']?.toString() ?? '',
      currentQuestion['4']?.toString() ?? '',
    ];

    double progress = (currentQuestionIndex + 1) / questionKeys.length;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(5.0, 40, 0, 0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 20),
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  "${widget.selectedSkill} Test",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Text(
                    "${currentQuestionIndex + 1}/${questionKeys.length}",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color.fromARGB(255, 138, 239, 70),
                ),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Divider(color: Colors.black, thickness: 1),
            SizedBox(height: 24),
            // GIF and message box image
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100,
                  height: 124,
                  child: Image.asset('assets/bear.gif', fit: BoxFit.fill),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          height: 150,
                          width: 275,
                          child: Container(
                            height: 300,
                            width: 200,
                            child: Image.asset(
                              'assets/Union.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 16,
                          left: 16,
                          child: InkWell(
                            onTap: () {
                              print(
                                'Question: ${currentQuestion['Question']?.toString()}',
                              );
                              print('Options:');
                              for (int i = 0; i < options.length; i++) {
                                print('  ${i + 1}. ${options[i]}');
                              }
                              print(
                                'Correct Answer: ${currentQuestion['Correct']?.toString()}',
                              );
                            },
                            child: SizedBox(
                              width: 230,
                              child: Text(
                                currentQuestion['Question']?.toString() ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Jost',
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24),
            // Options
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final bool isSelected = selectedOption == index;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 20,
                    ),
                    child: Material(
                      elevation: 0,
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          setState(() {
                            selectedOption = index;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color.fromRGBO(232, 226, 254, 1)
                                : const Color.fromRGBO(248, 248, 248, 1),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(
                                  255,
                                  181,
                                  169,
                                  235,
                                ).withOpacity(0.5),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                            border: Border(
                              bottom: isSelected
                                  ? BorderSide(
                                      color: const Color.fromRGBO(
                                        182,
                                        165,
                                        254,
                                        1,
                                      ),
                                      width: 5,
                                    )
                                  : BorderSide.none,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                          child: Text(
                            options[index],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? const Color.fromRGBO(182, 165, 254, 1)
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(4, 4),
                blurRadius: 0,
                spreadRadius: 2,
              ),
            ],
            borderRadius: BorderRadius.circular(8),
          ),
          child: ElevatedButton(
            onPressed: nextQuestion,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB6A5FE),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              currentQuestionIndex < questionKeys.length - 1
                  ? 'Next'
                  : 'Finish',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
