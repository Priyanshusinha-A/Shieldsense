import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../providers/user_provider.dart';
import '../providers/video_provider.dart';
import 'chat_dialog.dart';

class CyberCoachScreen extends StatefulWidget {
  const CyberCoachScreen({super.key});

  @override
  _CyberCoachScreenState createState() => _CyberCoachScreenState();
}

class _CyberCoachScreenState extends State<CyberCoachScreen> {
  List<Map<String, dynamic>> _tips = [];
  int _currentTipIndex = 0;
  List<Map<String, dynamic>> _quizzes = [];
  int _currentQuizIndex = 0;
  bool _showExplanation = false;
  bool _isLoading = true;
  int _correctAnswers = 0;
  int _totalQuestions = 0;
  bool _quizCompleted = false;
  int _consecutiveCorrect = 0;
  int _quizCyclesCompleted = 0;
  // Removed chat-related state from here, moved to ChatDialog

  List<Map<String, dynamic>> _allBadges = [
    {'name': 'Quiz Novice', 'description': 'Answer 5 questions correctly', 'unlocked': false, 'tier': 'bronze'},
    {'name': 'Quiz Apprentice', 'description': 'Answer 10 questions correctly', 'unlocked': false, 'tier': 'silver'},
    {'name': 'Quiz Journeyman', 'description': 'Answer 20 questions correctly', 'unlocked': false, 'tier': 'gold'},
    {'name': 'Quiz Expert', 'description': 'Answer 50 questions correctly', 'unlocked': false, 'tier': 'platinum'},
    {'name': 'Quiz Master', 'description': 'Answer 100 questions correctly', 'unlocked': false, 'tier': 'diamond'},
    {'name': 'Streak Beginner', 'description': 'Get 3 consecutive correct answers', 'unlocked': false, 'tier': 'bronze'},
    {'name': 'Streak Master', 'description': 'Get 5 consecutive correct answers', 'unlocked': false, 'tier': 'silver'},
    {'name': 'Streak Champion', 'description': 'Get 10 consecutive correct answers', 'unlocked': false, 'tier': 'gold'},
    {'name': 'Streak Legend', 'description': 'Get 15 consecutive correct answers', 'unlocked': false, 'tier': 'platinum'},
    {'name': 'Streak God', 'description': 'Get 20 consecutive correct answers', 'unlocked': false, 'tier': 'diamond'},
    {'name': 'Awareness Initiate', 'description': 'Reach 60% awareness score', 'unlocked': false, 'tier': 'bronze'},
    {'name': 'Awareness Adept', 'description': 'Reach 70% awareness score', 'unlocked': false, 'tier': 'silver'},
    {'name': 'Awareness Expert', 'description': 'Reach 80% awareness score', 'unlocked': false, 'tier': 'gold'},
    {'name': 'Awareness Master', 'description': 'Reach 90% awareness score', 'unlocked': false, 'tier': 'platinum'},
    {'name': 'Awareness Guru', 'description': 'Reach 95% awareness score', 'unlocked': false, 'tier': 'diamond'},
    {'name': 'Cyber Guardian', 'description': 'Complete 10 quiz cycles', 'unlocked': false, 'tier': 'bronze'},
    {'name': 'Cyber Sentinel', 'description': 'Complete 25 quiz cycles', 'unlocked': false, 'tier': 'silver'},
    {'name': 'Cyber Warden', 'description': 'Complete 50 quiz cycles', 'unlocked': false, 'tier': 'gold'},
    {'name': 'Cyber Paladin', 'description': 'Complete 100 quiz cycles', 'unlocked': false, 'tier': 'platinum'},
    {'name': 'Cyber Archon', 'description': 'Complete 200 quiz cycles', 'unlocked': false, 'tier': 'diamond'},
  ];

  bool _showAllBadges = false;

  Map<String, Color> tierColors = {
    'bronze': Colors.orange,
    'silver': Colors.grey,
    'gold': Colors.yellow,
    'platinum': Colors.lightBlue,
    'diamond': Colors.purple,
  };

  Map<String, String> _cyberTerms = {
    'firewall': 'A security system that filters network traffic based on predefined rules to protect networks from unauthorized access.',
    'phishing': 'A cyber attack where attackers send fraudulent emails or messages to trick individuals into revealing sensitive information like passwords or credit card details.',
    'ransomware': 'Malicious software that encrypts files and demands payment (ransom) for their decryption.',
    'malware': 'Malicious software designed to harm or exploit devices, including viruses, worms, trojans, and spyware.',
    'virus': 'A type of malware that spreads by attaching itself to legitimate files and requires user action to propagate.',
    'worm': 'A self-replicating malware that spreads automatically across networks without user interaction.',
    'trojan': 'Malware disguised as legitimate software that performs malicious actions when executed.',
    'spyware': 'Malware designed to secretly collect user data without their knowledge.',
    'keylogger': 'A program that records keystrokes to steal passwords and other sensitive information.',
    'antivirus': 'Software designed to detect, prevent, and remove malicious software from devices.',
    'encryption': 'The process of converting data into a coded format to secure it from unauthorized access.',
    'vpn': 'Virtual Private Network - A service that creates a secure, encrypted connection over a less secure network.',
    'ddos': 'Distributed Denial of Service - An attack that overwhelms a system with traffic to make it unavailable.',
    'hacking': 'Unauthorized access to computer systems or networks.',
    'cybercrime': 'Illegal activities conducted via computer networks.',
    'it act': 'Information Technology Act, 2000 - Indian law dealing with electronic commerce and cybercrime.',
    'biometric': 'Authentication method using unique biological characteristics like fingerprints or facial recognition.',
    'two-factor authentication': 'A security process requiring two different forms of verification to access an account.',
    'password manager': 'A tool that securely stores and manages passwords for different accounts.',
    'social engineering': 'Manipulating people into revealing confidential information or performing actions.',
    'cyber forensics': 'The investigation and analysis of digital devices for evidence in cybercrimes.',
    'digital forensics': 'The process of identifying, preserving, analyzing, and presenting digital evidence.',
    'penetration testing': 'Authorized testing of systems to identify security vulnerabilities.',
    'ethical hacking': 'Authorized hacking to improve security by finding vulnerabilities.',
    'data breach': 'Unauthorized access to sensitive information.',
    'cyberbullying': 'Using digital platforms to harass or intimidate others.',
    'cyberstalking': 'Using the internet to harass or intimidate someone persistently.',
    'botnet': 'A network of infected computers controlled by hackers.',
    'rootkit': 'Malware that hides other malicious programs and provides unauthorized access.',
    'adware': 'Software that displays unwanted advertisements, often bundled with free programs.',
    'logic bomb': 'Malicious code triggered by a specific event or condition.',
    'cyber terrorism': 'Using technology to cause fear or harm to society.',
    'gdpr': 'General Data Protection Regulation - EU law regulating data protection and privacy.',
    'https': 'HyperText Transfer Protocol Secure - Protocol for secure web communication using encryption.',
    'ssl': 'Secure Sockets Layer - Protocol for establishing encrypted links between web servers and browsers.',
    'ids': 'Intrusion Detection System - A device or software that monitors network traffic for suspicious activity.',
    'ips': 'Intrusion Prevention System - Similar to IDS but can also block detected threats.',
    'honeypot': 'A decoy system designed to attract attackers and study their behavior.',
    'air gap': 'Physically isolating systems from networks to prevent unauthorized access.',
    'kill chain': 'A model describing the stages of a cyber attack.',
    'soc': 'Security Operations Center - A centralized unit that deals with security issues.',
    'uba': 'User Behavior Analytics - Technology that detects unusual user behavior.',
    'threat intelligence': 'Information about potential cyber threats and attackers.',
    'incident response': 'The process of handling and managing security breaches.',
    'cyber hygiene': 'Regular practices to maintain online safety and security.',
    'data integrity': 'The accuracy and consistency of stored data.',
    'data privacy': 'The right to control how personal data is collected and used.',
    'access control': 'Security technique to regulate who can access resources.',
    'multi-factor authentication': 'Using multiple methods to verify identity.',
    'brute force': 'An attack method trying all possible password combinations.',
    'sql injection': 'An attack exploiting vulnerabilities in SQL-based web applications.',
    'xss': 'Cross-Site Scripting - An attack injecting malicious scripts into web pages.',
    'man-in-the-middle': 'An attack intercepting communication between two parties.',
    'evil twin': 'A fake Wi-Fi hotspot set up to steal data.',
    'shoulder surfing': 'Watching someone type their password or enter sensitive information.',
    'dumpster diving': 'Searching discarded materials for confidential information.',
    'carding': 'Stealing and using credit card data online.',
    'cyber espionage': 'Unauthorized spying to gather confidential data.',
    'dark web': 'Encrypted online networks not indexed by search engines.',
    'ip spoofing': 'Faking an IP address to impersonate another device.',
    'data exfiltration': 'Unauthorized transfer of data from a system.',
    'cyber reconnaissance': 'Gathering intelligence about a target before an attack.',
    'proxy server': 'An intermediary server between users and the internet.',
    'hashing': 'Converting data into a fixed-size string for security purposes.',
    'digital signature': 'A cryptographic method to verify authenticity and integrity.',
    'digital certificate': 'An electronic document authenticating identities online.',
    'forensic image': 'An exact copy of a storage device for analysis.',
    'chain of custody': 'A record of evidence handling and transfer in forensics.',
    'payload': 'The malicious component of malware that performs the attack.',
    'sandboxing': 'Running code in an isolated environment for safety testing.',
    'cyber grooming': 'Befriending minors online for exploitation.',
    'iot': 'Internet of Things - Network of physical devices connected to the internet.',
    'cve': 'Common Vulnerabilities and Exposures - A database of known security vulnerabilities.',
    'wannacry': 'A notorious ransomware attack that affected global systems.',
    'pegasus': 'Spyware used for targeted surveillance.',
    'zeus': 'Banking trojan malware.',
    'mirai': 'Botnet malware that caused massive DDoS attacks.',
    'cert-in': 'Computer Emergency Response Team - India, handles cyber emergencies.',
    'cyber crime investigation cell': 'Indian agency for investigating cybercrimes.',
    'data protection authority': 'Body overseeing compliance with privacy laws.',
    'digital personal data protection act': 'Proposed Indian law for personal data protection.',
    // Cyber Laws from user feedback
    'ccpa': 'California Consumer Privacy Act, 2020 – Gives California residents the right to know, delete, and opt-out of sale of personal data.',
    'hipaa': 'Health Insurance Portability and Accountability Act, 1996 – Protects personal health information stored or transmitted electronically.',
    'ftc act': 'Federal Trade Commission Act – Regulates unfair or deceptive practices online, including data privacy violations.',
    'glba': 'Gramm-Leach-Bliley Act, 1999 – Requires financial institutions to protect consumer financial data.',
    'sox': 'Sarbanes-Oxley Act, 2002 – Includes provisions for secure electronic record-keeping in businesses.',
    'nis directive': 'Network and Information Security Directive, 2016 – EU-wide cybersecurity rules for essential services.',
    'eidas': 'eIDAS Regulation, 2014 – Legal recognition of electronic identification and trust services.',
    'cybersecurity act': 'Cybersecurity Act, 2019 – Strengthens EU cybersecurity certification framework.',
    'data protection bill': 'Data Protection Bill (DPB), 2023 draft – India\'s upcoming comprehensive data privacy law.',
    'telegraph act': 'Telegraph Act, 1885 (Amended) – Governs interception of digital communications in India.',
    'indian penal code section 66e': 'Indian Penal Code – Section 66E – Punishment for violation of privacy, e.g., sharing private images without consent.',
    'it act section 69': 'Section 69 IT Act – Grants government power to intercept, monitor, or decrypt data for security purposes.',
    'it act section 66f': 'Section 66F IT Act – Cyber terrorism penalties in India.',
    'budapest convention': 'Convention on Cybercrime (Budapest Convention), 2001 – Framework for international cybercrime cooperation.',
    'oecd guidelines': 'OECD Guidelines on the Protection of Privacy, 1980 – Early international privacy principles.',
    'apec privacy framework': 'Asia-Pacific Economic Cooperation (APEC) Privacy Framework – Cross-border privacy rules for APEC member countries.',
    'convention on the rights of the child': 'Convention on the Rights of the Child (Online Safety provisions) – Addresses child protection online.',
    'china cybersecurity law': 'China Cybersecurity Law, 2017 – Mandates data localization, cybersecurity reviews, and personal data protection.',
    'singapore pdpa': 'Singapore Personal Data Protection Act (PDPA), 2012 – Governs collection, use, and disclosure of personal data.',
    'japan appi': 'Japan Act on the Protection of Personal Information (APPI), 2003 – Japanese privacy law regulating personal data handling.',
    'south korea pipa': 'South Korea Personal Information Protection Act (PIPA), 2011 – Regulates privacy and cybersecurity.',
    'australia privacy act': 'Australia Privacy Act, 1988 – Regulates collection, use, and disclosure of personal information.',
    'notifiable data breaches scheme': 'Notifiable Data Breaches Scheme, 2018 – Requires reporting data breaches to the government and affected individuals.',
    'brazil lgpd': 'Brazil LGPD (Lei Geral de Proteção de Dados), 2020 – Brazil\'s data protection law similar to GDPR.',
    'russia federal law on personal data': 'Russia Federal Law on Personal Data, 2006 – Requires data localization and protects personal data.',
    'malaysia pdpa': 'Malaysia Personal Data Protection Act, 2010 – Regulates collection, storage, and processing of personal data.',
    'south africa popia': 'South Africa Protection of Personal Information Act (POPIA), 2013 – Protects personal information and governs data processing.',
    'uk data protection act': 'UK Data Protection Act, 2018 – Implements GDPR in UK law.',
    'new zealand privacy act': 'New Zealand Privacy Act, 2020 – Updates privacy protections and breach notification requirements.',
    'hong kong pdpo': 'Hong Kong Personal Data Privacy Ordinance, 1995 – Governs collection and use of personal data.',
    'thailand pdpa': 'Thailand Personal Data Protection Act, 2019 – Thailand\'s comprehensive privacy law.',
    'philippines data privacy act': 'Philippines Data Privacy Act, 2012 – Protects individual personal data in digital and physical forms.',
    'canada pipeda': 'Canada Personal Information Protection and Electronic Documents Act (PIPEDA), 2000 – Governs privacy in commercial activities.',
    'european eprivacy regulation': 'European ePrivacy Regulation (upcoming) – Will regulate cookies, tracking, and electronic communications in EU.',
    'germany bdsg': 'Germany Federal Data Protection Act (BDSG) – Implements GDPR principles in Germany.',
    'italy privacy code': 'Italy Privacy Code (Codice in materia di protezione dei dati personali) – Governs personal data handling in Italy.',
    'finland act on protection of privacy': 'Finland Act on the Protection of Privacy in Electronic Communications – Protects online communications privacy.',
    'norway personal data act': 'Norway Personal Data Act – Supplements GDPR in Norway.',
    'sweden data protection act': 'Sweden Data Protection Act – Implements GDPR and regulates national privacy matters.',
    'estonia cybersecurity act': 'Estonia Cybersecurity Act, 2018 – Provides framework for national cybersecurity measures.',

    'ndps act': 'Online Sale of Drugs - Narcotic Drugs and Psychotropic Substances Act.',
    'arms act': 'Online Sale of Arms - Arms Act.',
    // Additional IT Act and IPC sections from user feedback
    'section 65': 'Tampering with computer source Documents - Unauthorized alteration or destruction of computer source code.',
    'section 66': 'Hacking with computer systems, Data Alteration - Unauthorized access to computer systems or data modification.',
    'section 66a': 'Sending offensive messages through communication service, etc. - Punishment for sending offensive messages via electronic communication.',
    'section 66b': 'Dishonestly receiving stolen computer resource or communication device - Receiving stolen computer resources dishonestly.',
    'section 66c': 'Identity theft - Punishment for identity theft using computer resources.',
    'section 66d': 'Cheating by personation by using computer resource - Impersonation using computer resources for cheating.',
    'section 66e': 'Violation of privacy - Punishment for violation of privacy, e.g., sharing private images without consent.',
    'section 66f': 'Cyber terrorism - Punishment for cyber terrorism acts.',
    'section 67': 'Publishing or transmitting obscene material in electronic form - Punishment for publishing obscene material online.',
    'section 67a': 'Publishing or transmitting of material containing sexually explicit act, etc. in electronic form - Punishment for sexually explicit content.',
    'section 67b': 'Punishment for publishing or transmitting of material depicting children in sexually explicit act, etc. in electronic form - Child pornography offenses.',
    'section 67c': 'Preservation and Retention of information by intermediaries - Requirements for intermediaries to preserve information.',
    'section 69': 'Powers to issue directions for interception or monitoring or decryption of any information through any computer resource - Government interception powers.',
    'section 69a': 'Power to issue directions for blocking for public access of any information through any computer resource - Blocking access to information.',
    'section 69b': 'Power to authorize to monitor and collect traffic data or information through any computer resource for Cyber Security - Monitoring for cybersecurity.',
    'section 70': 'Un-authorized access to protected system - Punishment for unauthorized access to protected systems.',
    'section 71': 'Penalty for misrepresentation - Punishment for false representation regarding electronic signatures.',
    'section 72': 'Breach of confidentiality and privacy - Punishment for breach of confidentiality.',
    'section 73': 'Publishing False digital signature certificates - Punishment for false digital certificates.',
    'section 74': 'Publication for fraudulent purpose - Punishment for fraudulent publications.',
    'section 75': 'Act to apply for offence or contraventions committed outside India - Extraterritorial application of the Act.',
    'section 77': 'Compensation, penalties or confiscation not to interfere with other punishment - Non-interference with other punishments.',
    'section 77a': 'Compounding of Offences - Provision for compounding offenses.',
    'section 77b': 'Offences with three years imprisonment to be cognizable - Cognizable offenses.',
    'section 79': 'Exemption from liability of intermediary in certain cases - Safe harbor for intermediaries.',
    'section 84b': 'Punishment for abetment of offences - Punishment for abetting offenses.',
    'section 84c': 'Punishment for attempt to commit offences - Punishment for attempt to commit offenses.',
    'section 78': 'Empowers Police Inspector to investigate cases falling under this Act.',
    'section 85': 'Offences by Companies - Liability of companies for offenses.',
    'ipc 503': 'Sending threatening messages by e-mail - Criminal intimidation via email.',
    'ipc 509': 'Word, gesture or act intended to insult the modesty of a woman - Insulting modesty.',
    'ipc 499': 'Sending defamatory messages by e-mail - Defamation via email.',
    'ipc 420': 'Bogus websites, Cyber Frauds - Cheating and dishonesty.',
    'ipc 463': 'E-mail Spoofing - Forgery of electronic records.',
    'ipc 464': 'Making a false document - Forgery.',
    'ipc 468': 'Forgery for purpose of cheating - Forgery for cheating.',
    'ipc 469': 'Forgery for purpose of harming reputation - Forgery harming reputation.',
    'ipc 383': 'Web-Jacking - Extortion via website takeover.',
    'ipc 500': 'E-mail Abuse - Defamation.',
    'ipc 506': 'Punishment for criminal intimidation - Criminal intimidation.',
    'ipc 507': 'Criminal intimidation by an anonymous communication - Anonymous intimidation.',
    'copyright section 51': 'When copyright infringed - Copyright infringement.',
    'copyright section 63': 'Offence of infringement of copyright or other rights conferred by this Act.',
    'copyright section 63a': 'Enhanced penalty on second and subsequent convictions - Increased penalties.',
    'copyright section 63b': 'Knowing use of infringing copy of computer programme to be an offence.',
    'ipc 292': 'Obscenity - Obscene publications.',
    'ipc 292a': 'Printing etc. of grossly indecent or scurrilous matter or matter intended for blackmail.',
    'ipc 293': 'Sale, etc., of obscene objects to young person.',
    'ipc 294': 'Obscene acts and songs.',
    'ipc 378': 'Theft of Computer Hardware.',
    'ipc 379': 'Punishment for theft.',
  };

  @override
  void initState() {
    super.initState();
    _loadTips();
    _loadQuestions();
  }

  Future<void> _loadTips() async {
    try {
      final String response = await rootBundle.loadString('assets/tips.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        _tips = data.map((item) => {
          'tip': item['tip'],
          'category': item['category'],
        }).toList();
        if (_tips.isNotEmpty) {
          _currentTipIndex = DateTime.now().day % _tips.length;
        }
      });
    } catch (e) {
      // Fallback to hardcoded tips if loading fails
      setState(() {
        _tips = [
          {
            'tip': 'Never click on links from unknown senders.',
            'category': 'Email Safety',
          },
          {
            'tip': 'Use unique passwords for each account.',
            'category': 'Password Security',
          },
          {
            'tip': 'Enable two-factor authentication wherever possible.',
            'category': 'Account Protection',
          },
          {
            'tip': 'Be cautious with attachments from unfamiliar sources.',
            'category': 'File Safety',
          },
        ];
        if (_tips.isNotEmpty) {
          _currentTipIndex = DateTime.now().day % _tips.length;
        }
      });
    }
  }

  Future<void> _loadQuestions() async {
    try {
      final String response = await rootBundle.loadString('assets/questions.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        _quizzes = data.map((item) => {
          'question': item['question'],
          'options': item['options'],
          'correct': item['correctAnswer'],
          'explanation': 'Correct answer: ${item['options'][item['correctAnswer']]}',
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      // Fallback to hardcoded questions if loading fails
      setState(() {
        _quizzes = [
          {
            'question': 'You receive an email from your bank asking you to click a link to verify your account. What should you do?',
            'options': ['Click the link immediately', 'Call the bank directly', 'Ignore it'],
            'correct': 1,
            'explanation': 'Always contact your bank through official channels, not through email links.',
          },
          {
            'question': 'Which of these is a strong password?',
            'options': ['password123', 'MyDogName2023!', '123456'],
            'correct': 1,
            'explanation': 'Strong passwords combine letters, numbers, and symbols, and avoid common words.',
          },
        ];
        _isLoading = false;
      });
    }
  }

  void _answerQuiz(int selectedIndex) {
    setState(() {
      _showExplanation = true;
      _totalQuestions++;
    });

    bool isCorrect = selectedIndex == _quizzes[_currentQuizIndex]['correct'];
    if (isCorrect) {
      setState(() {
        _correctAnswers++;
        _consecutiveCorrect++;
      });

      // Increase cyber health score by 1 on correct answer
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      int currentScore = userProvider.user?.cyberHealthScore ?? 0;
      userProvider.updateScore(currentScore + 1);
    } else {
      setState(() {
        _consecutiveCorrect = 0;
      });
    }

    // Calculate awareness score after each answer
    int awarenessScore = _totalQuestions > 0 ? ((_correctAnswers / _totalQuestions) * 100).round() : 0;
    Provider.of<UserProvider>(context, listen: false).updateCyberAwarenessScore(awarenessScore);

    // Check and unlock badges
    _checkAndUnlockBadges();

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _showExplanation = false;
        _currentQuizIndex = (_currentQuizIndex + 1) % _quizzes.length;
        if (_currentQuizIndex == 0) {
          _quizCompleted = true;
          _quizCyclesCompleted++;
        }
      });
    });
  }

  void _checkAndUnlockBadges() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    int awarenessScore = _totalQuestions > 0 ? ((_correctAnswers / _totalQuestions) * 100).round() : 0;

    // Quiz Novice: Answer 5 questions correctly
    if (_correctAnswers >= 5 && !_allBadges[0]['unlocked']) {
      _allBadges[0]['unlocked'] = true;
      userProvider.addBadge(_allBadges[0]['name']);
    }
    // Quiz Apprentice: Answer 10 questions correctly
    if (_correctAnswers >= 10 && !_allBadges[1]['unlocked']) {
      _allBadges[1]['unlocked'] = true;
      userProvider.addBadge(_allBadges[1]['name']);
    }
    // Quiz Journeyman: Answer 20 questions correctly
    if (_correctAnswers >= 20 && !_allBadges[2]['unlocked']) {
      _allBadges[2]['unlocked'] = true;
      userProvider.addBadge(_allBadges[2]['name']);
    }
    // Quiz Expert: Answer 50 questions correctly
    if (_correctAnswers >= 50 && !_allBadges[3]['unlocked']) {
      _allBadges[3]['unlocked'] = true;
      userProvider.addBadge(_allBadges[3]['name']);
    }
    // Quiz Master: Answer 100 questions correctly
    if (_correctAnswers >= 100 && !_allBadges[4]['unlocked']) {
      _allBadges[4]['unlocked'] = true;
      userProvider.addBadge(_allBadges[4]['name']);
    }
    // Streak Beginner: Get 3 consecutive correct answers
    if (_consecutiveCorrect >= 3 && !_allBadges[5]['unlocked']) {
      _allBadges[5]['unlocked'] = true;
      userProvider.addBadge(_allBadges[5]['name']);
    }
    // Streak Master: Get 5 consecutive correct answers
    if (_consecutiveCorrect >= 5 && !_allBadges[6]['unlocked']) {
      _allBadges[6]['unlocked'] = true;
      userProvider.addBadge(_allBadges[6]['name']);
    }
    // Streak Champion: Get 10 consecutive correct answers
    if (_consecutiveCorrect >= 10 && !_allBadges[7]['unlocked']) {
      _allBadges[7]['unlocked'] = true;
      userProvider.addBadge(_allBadges[7]['name']);
    }
    // Streak Legend: Get 15 consecutive correct answers
    if (_consecutiveCorrect >= 15 && !_allBadges[8]['unlocked']) {
      _allBadges[8]['unlocked'] = true;
      userProvider.addBadge(_allBadges[8]['name']);
    }
    // Streak God: Get 20 consecutive correct answers
    if (_consecutiveCorrect >= 20 && !_allBadges[9]['unlocked']) {
      _allBadges[9]['unlocked'] = true;
      userProvider.addBadge(_allBadges[9]['name']);
    }
    // Awareness Initiate: Reach 60% awareness score
    if (awarenessScore >= 60 && !_allBadges[10]['unlocked']) {
      _allBadges[10]['unlocked'] = true;
      userProvider.addBadge(_allBadges[10]['name']);
    }
    // Awareness Adept: Reach 70% awareness score
    if (awarenessScore >= 70 && !_allBadges[11]['unlocked']) {
      _allBadges[11]['unlocked'] = true;
      userProvider.addBadge(_allBadges[11]['name']);
    }
    // Awareness Expert: Reach 80% awareness score
    if (awarenessScore >= 80 && !_allBadges[12]['unlocked']) {
      _allBadges[12]['unlocked'] = true;
      userProvider.addBadge(_allBadges[12]['name']);
    }
    // Awareness Master: Reach 90% awareness score
    if (awarenessScore >= 90 && !_allBadges[13]['unlocked']) {
      _allBadges[13]['unlocked'] = true;
      userProvider.addBadge(_allBadges[13]['name']);
    }
    // Awareness Guru: Reach 95% awareness score
    if (awarenessScore >= 95 && !_allBadges[14]['unlocked']) {
      _allBadges[14]['unlocked'] = true;
      userProvider.addBadge(_allBadges[14]['name']);
    }
    // Cyber Guardian: Complete 10 quiz cycles
    if (_quizCyclesCompleted >= 10 && !_allBadges[15]['unlocked']) {
      _allBadges[15]['unlocked'] = true;
      userProvider.addBadge(_allBadges[15]['name']);
    }
    // Cyber Sentinel: Complete 25 quiz cycles
    if (_quizCyclesCompleted >= 25 && !_allBadges[16]['unlocked']) {
      _allBadges[16]['unlocked'] = true;
      userProvider.addBadge(_allBadges[16]['name']);
    }
    // Cyber Warden: Complete 50 quiz cycles
    if (_quizCyclesCompleted >= 50 && !_allBadges[17]['unlocked']) {
      _allBadges[17]['unlocked'] = true;
      userProvider.addBadge(_allBadges[17]['name']);
    }
    // Cyber Paladin: Complete 100 quiz cycles
    if (_quizCyclesCompleted >= 100 && !_allBadges[18]['unlocked']) {
      _allBadges[18]['unlocked'] = true;
      userProvider.addBadge(_allBadges[18]['name']);
    }
    // Cyber Archon: Complete 200 quiz cycles
    if (_quizCyclesCompleted >= 200 && !_allBadges[19]['unlocked']) {
      _allBadges[19]['unlocked'] = true;
      userProvider.addBadge(_allBadges[19]['name']);
    }
  }

  void _openRewardLink() async {
    if (!_quizCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('First complete that quiz')),
      );
      return;
    }
    const url = 'https://drive.google.com/drive/folders/1mZwaNmPJB6OcGf-lSejIvbU8y2YxjDt4';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch URL')),
      );
    }
  }

  void _showBadgeDetails(Map<String, dynamic> badge) {
    final Color tierColor = tierColors[badge['tier']] ?? Colors.grey;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                _getBadgeIcon(badge['name']),
                color: tierColor,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  badge['name'],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                badge['description'],
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 16,
                    color: tierColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${badge['tier'].toString().toUpperCase()} TIER',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: tierColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                badge['unlocked'] ? 'Status: Unlocked' : 'Status: Locked',
                style: TextStyle(
                  fontSize: 14,
                  color: badge['unlocked'] ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBadgeCard(String badgeName, String tier, bool isUnlocked, int index, {VoidCallback? onTap}) {
    final Color tierColor = tierColors[tier] ?? Colors.grey;
    final IconData badgeIcon = _getBadgeIcon(badgeName);

    final card = Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isUnlocked
                ? [tierColor.withOpacity(0.8), tierColor.withOpacity(0.4)]
                : [Colors.grey.withOpacity(0.3), Colors.grey.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                badgeIcon,
                size: 32,
                color: isUnlocked ? Colors.white : Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                badgeName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? Colors.white : Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: Duration(milliseconds: index * 100)).scale(delay: Duration(milliseconds: index * 50));

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: card,
      );
    }
    return card;
  }

  IconData _getBadgeIcon(String badgeName) {
    if (badgeName.contains('Quiz')) return Icons.quiz;
    if (badgeName.contains('Streak')) return Icons.flash_on;
    if (badgeName.contains('Awareness')) return Icons.lightbulb;
    if (badgeName.contains('Cyber')) return Icons.security;
    return Icons.star;
  }

  List<Widget> _buildTierSections(bool isUnlocked) {
    final Map<String, List<Map<String, dynamic>>> tierGroups = {
      'bronze': [],
      'silver': [],
      'gold': [],
      'platinum': [],
      'diamond': [],
    };

    for (final badge in _allBadges) {
      if (badge['unlocked'] == isUnlocked) {
        tierGroups[badge['tier']]!.add(badge);
      }
    }

    final List<Widget> sections = [];
    tierGroups.forEach((tier, badges) {
      if (badges.isNotEmpty) {
        sections.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 16,
                    color: tierColors[tier],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${tier.toUpperCase()} TIER',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 0.8,
                ),
                itemCount: badges.length,
                itemBuilder: (context, index) {
                  final badge = badges[index];
                  return _buildBadgeCard(badge['name'], badge['tier'], isUnlocked, index, onTap: isUnlocked ? () => _showBadgeDetails(badge) : null);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }
    });

    return sections;
  }



  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final videoProvider = Provider.of<VideoProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background video
          videoProvider.isVideoInitialized
              ? SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: videoProvider.controller.value.size.width,
                      height: videoProvider.controller.value.size.height,
                      child: VideoPlayer(videoProvider.controller),
                    ),
                  ),
                )
              : Container(color: Colors.black),

          // Overlay gradient and content
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.5),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                // Custom App Bar
                Container(
                  padding: const EdgeInsets.only(
                      top: 50, left: 16, right: 16, bottom: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Cyber Coach',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Body content
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Daily Cyber Tip',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.3, end: 0),
                            const SizedBox(height: 10),
                            Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              color: Colors.white.withOpacity(0.1),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _tips.isNotEmpty ? _tips[_currentTipIndex]['tip'] : 'Loading tip...',
                                        style: const TextStyle(fontSize: 16, color: Colors.white),
                                      ).animate().fadeIn(duration: 600.ms),
                                      const SizedBox(height: 8),
                                      Text(
                                        _tips.isNotEmpty ? _tips[_currentTipIndex]['category'] : '',
                                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontStyle: FontStyle.italic),
                                      ).animate().fadeIn(duration: 700.ms),
                                    ],
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),
                            const SizedBox(height: 20),
                            const Text(
                              'Quick Quiz',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ).animate().fadeIn(duration: 800.ms),
                            const SizedBox(height: 10),
                            Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              color: Colors.white.withOpacity(0.1),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (_isLoading) ...[
                                        const Center(child: CircularProgressIndicator(color: Colors.white)),
                                      ] else ...[
                                        Text(
                                          _quizzes[_currentQuizIndex]['question'],
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                        ).animate().fadeIn(duration: 900.ms),
                                        const SizedBox(height: 16),
                                        if (!_showExplanation) ...[
                                          ...(_quizzes[_currentQuizIndex]['options'] as List<dynamic>).asMap().entries.map(
                                                (entry) => Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                                  child: ElevatedButton(
                                                    onPressed: () => _answerQuiz(entry.key),
                                                    style: ElevatedButton.styleFrom(
                                                      minimumSize: const Size(double.infinity, 48),
                                                      backgroundColor: Colors.blue,
                                                      foregroundColor: Colors.white,
                                                      elevation: 4,
                                                      shadowColor: Colors.blue.withOpacity(0.3),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                    ),
                                                    child: Text(entry.value),
                                                  ).animate().fadeIn(duration: 1000.ms, delay: Duration(milliseconds: entry.key * 100)).scale(delay: Duration(milliseconds: entry.key * 50)),
                                                ),
                                              ),
                                        ] else ...[
                                          Text(
                                            _quizzes[_currentQuizIndex]['explanation'],
                                            style: const TextStyle(fontSize: 16, color: Colors.greenAccent),
                                          ).animate().fadeIn(duration: 500.ms).shake(),
                                        ],
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),
                            const SizedBox(height: 20),
                            const Text(
                              'Quiz Reward',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ).animate().fadeIn(duration: 1100.ms),
                            const SizedBox(height: 10),
                            Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              color: Colors.white.withOpacity(0.1),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        _quizCompleted ? Icons.lock_open : Icons.lock,
                                        size: 48,
                                        color: _quizCompleted ? Colors.greenAccent : Colors.white.withOpacity(0.7),
                                      ).animate().rotate(duration: 600.ms, begin: 0, end: _quizCompleted ? 0.5 : 0),
                                      const SizedBox(height: 10),
                                      Text(
                                        _quizCompleted ? 'Reward Unlocked!' : 'Complete the quiz to unlock reward',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: _quizCompleted ? Colors.greenAccent : Colors.white.withOpacity(0.7),
                                        ),
                                      ).animate().fadeIn(duration: 700.ms),
                                      const SizedBox(height: 10),
                                      ElevatedButton.icon(
                                        onPressed: _openRewardLink,
                                        icon: const Icon(Icons.link),
                                        label: const Text('Cyber Security Course'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _quizCompleted ? Colors.purple : Colors.grey,
                                          foregroundColor: Colors.white,
                                          elevation: 4,
                                          shadowColor: Colors.purple.withOpacity(0.3),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      ).animate().scale(delay: 200.ms),
                                    ],
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(duration: 1000.ms).slideY(begin: 0.3, end: 0),
                            const SizedBox(height: 20),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _showAllBadges = !_showAllBadges;
                                });
                              },
                              child: Row(
                                children: [
                                  const Text(
                                    'Your Badges',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Icon(
                                    _showAllBadges ? Icons.expand_less : Icons.expand_more,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 1300.ms),
                            const SizedBox(height: 10),
                            if (!_showAllBadges) ...[
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 12.0,
                                  mainAxisSpacing: 12.0,
                                  childAspectRatio: 0.8,
                                ),
                                itemCount: (user?.badges ?? []).length,
                                itemBuilder: (context, index) {
                                  final badgeName = (user?.badges ?? [])[index];
                                  final badge = _allBadges.firstWhere(
                                    (b) => b['name'] == badgeName,
                                    orElse: () => {'tier': 'bronze'},
                                  );
                                  return _buildBadgeCard(badgeName, badge['tier'], true, index, onTap: () => _showBadgeDetails(badge));
                                },
                              ),
                            ] else ...[
                              Card(
                                elevation: 8,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                color: Colors.white.withOpacity(0.1),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Unlocked Badges',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        ..._buildTierSections(true),
                                        const SizedBox(height: 32),
                                        const Text(
                                          'Locked Badges',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        ..._buildTierSections(false),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            const Text(
                              'Cyber Chatbot',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ).animate().fadeIn(duration: 1500.ms),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return ChatDialog(cyberTerms: _cyberTerms);
                                  },
                                );
                              },
                              icon: const Icon(Icons.chat),
                              label: const Text('Open Chatbot'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shadowColor: Colors.orange.withOpacity(0.3),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                              ),
                            ).animate().fadeIn(duration: 1600.ms).scale(delay: 200.ms),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
