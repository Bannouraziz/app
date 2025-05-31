import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../services/question_service.dart';
import '../../services/progress_service.dart';
import '../../services/student_service.dart';

class ParentRecommendationPage extends StatefulWidget {
  const ParentRecommendationPage({super.key});

  @override
  State<ParentRecommendationPage> createState() =>
      _ParentRecommendationPageState();
}

class _ParentRecommendationPageState extends State<ParentRecommendationPage> {
  bool _isLoading = true;
  bool _isGeneratingRecommendation = false;
  bool _error = false;
  String _errorMessage = '';

  // Student performance data
  Map<String, dynamic> _performanceData = {
    'correctAnswers': 0,
    'totalQuestions': 0,
    'strengths': <String>[],
    'weaknesses': <String>[],
    'domainStats': <String, Map<String, dynamic>>{},
    'recommendations': <Map<String, dynamic>>[],
    'aiRecommendation': '',
  };

  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Fetch student performance data
  Future<void> _fetchStudentData() async {
    setState(() {
      _isLoading = true;
      _error = false;
    });

    try {
      // Get student profile and progress data
      final studentService =
          Provider.of<StudentService>(context, listen: false);
      final progressService =
          Provider.of<ProgressService>(context, listen: false);
      final questionService =
          Provider.of<QuestionService>(context, listen: false);

      // Get student profile
      final profile = await studentService.getProfile();

      // Calculate performance metrics based on response history
      // For this demo, we'll simulate with some sample data, normally from API
      final domainStats = <String, Map<String, dynamic>>{
        'Mathématiques': {'correct': 8, 'total': 10, 'percentage': 80},
        'Français': {'correct': 5, 'total': 10, 'percentage': 50},
        'Sciences': {'correct': 7, 'total': 10, 'percentage': 70},
        'Histoire': {'correct': 4, 'total': 10, 'percentage': 40},
      };

      // Calculate strengths and weaknesses
      List<String> strengths = [];
      List<String> weaknesses = [];

      domainStats.forEach((domain, stats) {
        if (stats['percentage'] >= 70) {
          strengths.add(domain);
        } else if (stats['percentage'] <= 60) {
          weaknesses.add(domain);
        }
      });

      // Calculate global statistics
      int totalCorrect = 0;
      int totalQuestions = 0;

      domainStats.forEach((domain, stats) {
        totalCorrect += stats['correct'] as int;
        totalQuestions += stats['total'] as int;
      });

      // Generate recommendations based on weaknesses
      final recommendations = <Map<String, dynamic>>[];

      if (weaknesses.contains('Mathématiques')) {
        recommendations.add({
          'title': 'Jeux de mathématiques',
          'description':
              'Encouragez l\'utilisation d\'applications ludiques de mathématiques pour renforcer les compétences numériques',
          'icon': Icons.calculate,
        });
      }

      if (weaknesses.contains('Français')) {
        recommendations.add({
          'title': 'Lecture quotidienne',
          'description':
              'Établir une routine de lecture de 20 minutes par jour pour améliorer le vocabulaire et la compréhension',
          'icon': Icons.menu_book,
        });
      }

      if (weaknesses.contains('Sciences')) {
        recommendations.add({
          'title': 'Expériences scientifiques simples',
          'description':
              'Réalisez des expériences scientifiques à la maison pour développer l\'esprit d\'observation',
          'icon': Icons.science,
        });
      }

      if (weaknesses.contains('Histoire')) {
        recommendations.add({
          'title': 'Documentaires historiques',
          'description':
              'Regardez des documentaires adaptés à l\'âge pour rendre l\'histoire plus vivante et mémorable',
          'icon': Icons.history_edu,
        });
      }

      // If no specific recommendations, add general ones
      if (recommendations.isEmpty) {
        recommendations.add({
          'title': 'Exercices réguliers',
          'description':
              'Encouragez une pratique régulière pour maintenir le bon niveau dans toutes les matières',
          'icon': Icons.assignment,
        });
      }

      // Update performance data
      _performanceData = {
        'correctAnswers': totalCorrect,
        'totalQuestions': totalQuestions,
        'strengths': strengths,
        'weaknesses': weaknesses,
        'domainStats': domainStats,
        'recommendations': recommendations,
        'aiRecommendation': '',
      };

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = true;
        _errorMessage = e.toString();
      });
    }
  }

  // Generate AI recommendation
  Future<void> _generateAIRecommendation() async {
    if (_promptController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez entrer une question')));
      return;
    }

    setState(() {
      _isGeneratingRecommendation = true;
    });

    try {
      // Prepare data for AI recommendation
      final strengths = _performanceData['strengths'].join(', ');
      final weaknesses = _performanceData['weaknesses'].join(', ');
      final prompt = _promptController.text;

      // In a real app, this would be an API call to an AI service
      // For now, we're simulating a response

      // Simulated API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Simulated AI response based on the student's performance
      String aiResponse = '';

      if (weaknesses.contains('Mathématiques')) {
        aiResponse +=
            'Pour améliorer les compétences en mathématiques, je recommande des activités ludiques comme des jeux de société impliquant des calculs ou des applications éducatives. ';
      }

      if (weaknesses.contains('Français')) {
        aiResponse +=
            'Pour le français, la lecture quotidienne est essentielle. Choisissez des livres adaptés au niveau et aux intérêts de l\'enfant. ';
      }

      if (!weaknesses.isEmpty) {
        aiResponse +=
            'Je note que l\'enfant excelle en $strengths. Ces forces peuvent être utilisées comme leviers pour développer les domaines plus faibles. ';
      }

      aiResponse +=
          'Pour répondre spécifiquement à votre question: "$prompt", je suggère de maintenir une routine d\'apprentissage régulière et de célébrer les petites victoires pour maintenir la motivation.';

      // Update the performance data with AI recommendation
      setState(() {
        _performanceData['aiRecommendation'] = aiResponse;
        _isGeneratingRecommendation = false;
      });

      // Scroll to recommendation
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      setState(() {
        _isGeneratingRecommendation = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF6C63FF),
                const Color(0xFF6C63FF).withOpacity(0.8),
              ],
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.psychology, color: Colors.white, size: 28),
            const SizedBox(width: 10),
            Text(
              'Recommandations',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchStudentData,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error
              ? Center(child: Text('Erreur: $_errorMessage'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final percentage = _performanceData['totalQuestions'] > 0
        ? (_performanceData['correctAnswers'] /
                _performanceData['totalQuestions'] *
                100)
            .round()
        : 0;

    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Performance Overview Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  Text(
                    'Performance Globale',
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Row(
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: percentage / 100,
                              strokeWidth: 10,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF66B51B)),
                              semanticsLabel: 'Performance',
                            ),
                            Text(
                              '$percentage%',
                              style: GoogleFonts.poppins(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_performanceData['correctAnswers']} bonnes réponses',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700],
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              '${_performanceData['totalQuestions'] - _performanceData['correctAnswers']} mauvaises réponses',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.red[700],
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              '${_performanceData['totalQuestions']} questions au total',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 25.h),

          // Domain Performance Section
          Text(
            'Performance par Domaine',
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 15.h),
          _buildDomainPerformanceCards(),
          SizedBox(height: 25.h),

          // Strengths & Weaknesses Section
          Text(
            'Points Forts et Faibles',
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 15.h),
          Row(
            children: [
              Expanded(
                child: _buildSkillBox(
                  title: 'Points Forts',
                  skills: _performanceData['strengths'],
                  color: const Color(0xFF66B51B),
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: _buildSkillBox(
                  title: 'À Améliorer',
                  skills: _performanceData['weaknesses'],
                  color: Colors.orange[700]!,
                ),
              ),
            ],
          ),
          SizedBox(height: 25.h),

          // AI Recommendations Section
          Text(
            'Recommandations Personnalisées',
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Conseils basés sur les résultats de votre enfant',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 15.h),
          Column(
            children: (_performanceData['recommendations'] as List<dynamic>)
                .map<Widget>((recommendation) {
              return _buildRecommendationCard(
                icon: recommendation['icon'],
                title: recommendation['title'],
                description: recommendation['description'],
              );
            }).toList(),
          ),
          SizedBox(height: 25.h),

          // AI Assistant Section
          Text(
            'Assistant IA Éducatif',
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Posez une question sur comment aider votre enfant',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 15.h),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(15.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _promptController,
                    decoration: InputDecoration(
                      hintText:
                          'Ex: Comment aider mon enfant en mathématiques?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 15.h),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _isGeneratingRecommendation
                          ? null
                          : _generateAIRecommendation,
                      icon: _isGeneratingRecommendation
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.psychology),
                      label: Text(
                        _isGeneratingRecommendation
                            ? 'Génération en cours...'
                            : 'Générer une recommandation',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  if (_performanceData['aiRecommendation']?.isNotEmpty ??
                      false) ...[
                    SizedBox(height: 20.h),
                    Container(
                      padding: EdgeInsets.all(15.w),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.purple[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb,
                                  color: Colors.purple[700], size: 20.sp),
                              SizedBox(width: 8.w),
                              Text(
                                'Recommandation IA',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                  color: Colors.purple[700],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            _performanceData['aiRecommendation']!,
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _buildDomainPerformanceCards() {
    final domainStats = _performanceData['domainStats'] as Map<String, dynamic>;

    return Column(
      children: domainStats.entries.map((entry) {
        final domain = entry.key;
        final stats = entry.value as Map<String, dynamic>;
        final percentage = stats['percentage'] as int;

        Color color;
        if (percentage >= 70) {
          color = Colors.green;
        } else if (percentage >= 50) {
          color = Colors.orange;
        } else {
          color = Colors.red;
        }

        return Card(
          margin: EdgeInsets.only(bottom: 10.h),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      domain,
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                LinearProgressIndicator(
                  value: percentage / 100,
                  minHeight: 8.h,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                SizedBox(height: 8.h),
                Text(
                  '${stats['correct']}/${stats['total']} questions correctes',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSkillBox({
    required String title,
    required List<dynamic> skills,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: color,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 10.h),
          if (skills.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Text(
                'Aucun domaine identifié',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (skills as List<dynamic>)
                  .map((skill) => Padding(
                        padding: EdgeInsets.only(bottom: 5.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              title == 'Points Forts'
                                  ? Icons.check_circle
                                  : Icons.warning,
                              color: color,
                              size: 18.sp,
                            ),
                            SizedBox(width: 5.w),
                            Expanded(
                              child: Text(
                                skill,
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 15.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(15.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: const Color(0xFF66B51B).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF66B51B),
                size: 24.sp,
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
