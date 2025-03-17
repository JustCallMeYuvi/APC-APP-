// import 'package:flutter/material.dart';

// class EmployeeFeedbackScreen extends StatefulWidget {
//   @override
//   _EmployeeFeedbackScreenState createState() => _EmployeeFeedbackScreenState();
// }

// class _EmployeeFeedbackScreenState extends State<EmployeeFeedbackScreen> {
//   final Map<String, String> _responses = {};

//   Widget buildQuestion(String question, String questionTelugu) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(question,
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         Text(questionTelugu,
//             style: TextStyle(fontSize: 16, color: Colors.grey)),
//         Column(
//           children: [
//             'Strongly Disagree గట్టిగా అంగీకరించలేదు2',
//             'Disagree అంగీకరించలేదు',
//             'Neutral తటస్థంగా',
//             'Agree అంగీకరిస్తున్నాను',
//             'Strongly Agree గట్టిగా అంగీకరిస్తున్నాను'
//           ]
//               .map((option) => RadioListTile<String>(
//                     title: Text(option),
//                     value: option,
//                     groupValue: _responses[question],
//                     onChanged: (value) {
//                       setState(() {
//                         _responses[question] = value!;
//                       });
//                     },
//                   ))
//               .toList(),
//         ),
//         if (_responses[question] == 'Strongly Disagree' ||
//             _responses[question] == 'Disagree')
//           TextField(
//             decoration: InputDecoration(
//               labelText: 'Additional Comments',
//               border: OutlineInputBorder(),
//             ),
//             onChanged: (value) {
//               // Handle comment input
//             },
//           ),
//         SizedBox(height: 20),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Employee Feedback Survey')),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Text('Respectable Workplace & Gender Equality ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             // buildQuestion(
//             //   'I am treated with dignity and respect at work.',
//             //   'నేను పని ప్రదేశంలో గౌరవంగా మరియు మర్యాదపూర్వకంగా వ్యహరించబడతాను.',
//             // ),
//             // buildQuestion(
//             //   'I feel comfortable speaking up and sharing my opinions.',
//             //   'నా అభిప్రాయాలను వ్యక్తపరిచేందుకు మరియు పంచుకునేందుకు నాకెంతో సౌకర్యంగా ఉంటుంది.',
//             // ),

//             ExpansionTile(
//               title: Text(
//                 'I. Respectable Workplace & Gender Equality గౌరవనీయమైన పని స్థలం & లింగ సమానత్వం',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               children: [
//                 buildQuestion(
//                   '1.	I feel that all employees are treated with respect, regardless of gender.',
//                   'లింగ భేదం లేకుండా ఉద్యోగులందరూ గౌరవంగా వ్యవహరిస్తున్నారని నేను భావిస్తున్నాను.',
//                 ),
//                 buildQuestion(
//                   '2.	The company actively promotes a culture free from gender-based harassment and discrimination.',
//                   'లింగ-ఆధారిత వేధింపులు మరియు వివక్షత లేని సంస్కృతిని కంపెనీ చురుకుగా ప్రోత్సహిస్తుంది.',
//                 ),
//                 buildQuestion(
//                   '3.	I feel comfortable reporting instances of disrespect or harassment, regardless of the gender of those involved.',
//                   'పాల్గొన్న వారి లింగంతో సంబంధం లేకుండా, అగౌరవం లేదా వేధింపులకు సంబంధించిన సందర్భాలను నివేదించడం నాకు సౌకర్యంగా ఉంది.',
//                 ),
//                 buildQuestion(
//                   '4.	The company takes reports of gender-based disrespect seriously and addresses them effectively.',
//                   'కంపెనీ లింగ-ఆధారిత అగౌరవ నివేదికలను తీవ్రంగా పరిగణిస్తుంది మరియు వాటిని సమర్థవంతంగా పరిష్కరిస్తుంది.',
//                 ),
//                 buildQuestion(
//                   '5.	I have witnessed or experienced any kind of gender-based aggressions in the workplace.',
//                   'నేను కార్యాలయంలో ఎటువంటి లింగ-ఆధారిత దురాక్రమణలను చూశాను లేదా అనుభవించాను.',
//                 ),
//               ],
//             ),
//             // Text('Leadership',
//             //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             // buildQuestion(
//             //   'My manager demonstrates effective leadership.',
//             //   'నా మేనేజర్ సమర్థవంతమైన నాయకత్వాన్ని ప్రదర్శిస్తారు.',
//             // ),

//             // Text('Health & Safety',
//             //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             // buildQuestion(
//             //   'The company prioritizes my health and safety.',
//             //   'కంపెనీ నా ఆరోగ్యం మరియు భద్రతకు ప్రాధాన్యత ఇస్తుంది.',
//             // ),

//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 print(_responses);
//                 // TODO: Send the responses to API
//               },
//               child: Text('Submit Feedback'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:animated_movies_app/services/feedback_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmployeeFeedbackScreen extends StatefulWidget {
  const EmployeeFeedbackScreen({super.key});

  @override
  State<EmployeeFeedbackScreen> createState() => _EmployeeFeedbackScreenState();
}

class _EmployeeFeedbackScreenState extends State<EmployeeFeedbackScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FeedbackProvider>(context); // Access Provider

    return WillPopScope(
      onWillPop: () async {
        provider.clearResponses(); // ✅ Clear when back pressed
        return true;
      },
      child: Scaffold(
        // appBar: AppBar(
        //   title: const Text('Employee Feedback Survey'),
        //   backgroundColor: Colors.lightGreen,
        // ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ExpansionTile(
                title: const Text(
                  'I. Respectable Workplace & Gender Equality గౌరవనీయమైన పని స్థలం & లింగ సమానత్వం',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                children: [
                  buildQuestion(
                    context,
                    '1.	I feel that all employees are treated with respect, regardless of gender.',
                    'లింగ భేదం లేకుండా ఉద్యోగులందరూ గౌరవంగా వ్యవహరిస్తున్నారని నేను భావిస్తున్నాను.',
                  ),
                  buildQuestion(
                    context,
                    '2.	The company actively promotes a culture free from gender-based harassment and discrimination.',
                    'లింగ-ఆధారిత వేధింపులు మరియు వివక్షత లేని సంస్కృతిని కంపెనీ చురుకుగా ప్రోత్సహిస్తుంది.',
                  ),
                  buildQuestion(
                    context,
                    '3.	I feel comfortable reporting instances of disrespect or harassment, regardless of the gender of those involved.',
                    'పాల్గొన్న వారి లింగంతో సంబంధం లేకుండా, అగౌరవం లేదా వేధింపులకు సంబంధించిన సందర్భాలను నివేదించడం నాకు సౌకర్యంగా ఉంది.',
                  ),
                  buildQuestion(
                    context,
                    '4.	The company takes reports of gender-based disrespect seriously and addresses them effectively.',
                    'కంపెనీ లింగ-ఆధారిత అగౌరవ నివేదికలను తీవ్రంగా పరిగణిస్తుంది మరియు వాటిని సమర్థవంతంగా పరిష్కరిస్తుంది.',
                  ),
                  buildQuestion(
                    context,
                    '5.	I have witnessed or experienced any kind of gender-based aggressions in the workplace.',
                    'నేను కార్యాలయంలో ఎటువంటి లింగ-ఆధారిత దురాక్రమణలను చూశాను లేదా అనుభవించాను.',
                  ),
                ],
              ),
              ExpansionTile(
                title: const Text(
                  'II. Leadership & Development నాయకత్వం & అభివృద్ధి',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                children: [
                  buildQuestion(
                    context,
                    '1.	Women have equal opportunities for leadership positions within the company.',
                    'కంపెనీలో నాయకత్వ స్థానాలకు మహిళలకు సమాన అవకాశాలు ఉన్నాయి.',
                  ),
                  buildQuestion(
                    context,
                    '2.	Leadership development programs are accessible to all employees, regardless of gender.',
                    'నాయకత్వ అభివృద్ధి కార్యక్రమాలు లింగంతో సంబంధం లేకుండా ఉద్యోగులందరికీ అందుబాటులో ఉంటాయి.',
                  ),
                  buildQuestion(
                    context,
                    '3.	Management is approachable and open to all employee suggestions without any gender bias.',
                    'యాజమన్యం అనేది ఎటువంటి లింగ పక్షపాతం లేకుండా అన్ని ఉద్యోగి సూచనలకు అందుబాటులో ఉంటుంది.',
                  ),
                  buildQuestion(
                    context,
                    '4.	I believe that women\'s contributions are valued equally to men\'s by company leadership.',
                    'కంపెనీ నాయకత్వంలో పురుషులతో సమానంగా మహిళల సహకారం విలువైనదని నేను నమ్ముతున్నాను.',
                  ),
                  buildQuestion(
                    context,
                    '5.	I feel that there are equal opportunities for career advancement for all genders.',
                    'అన్ని లింగాలకు కెరీర్‌లో పురోగతికి సమాన అవకాశాలు ఉన్నాయని నేను భావిస్తున్నాను.',
                  ),
                ],
              ),
              ExpansionTile(
                title: const Text(
                  'III. Voice & Representation వాయిస్ & ప్రాతినిధ్యం',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                children: [
                  buildQuestion(
                    context,
                    '1.	Women\'s voices are heard and valued in company decision-making processes.',
                    'కంపెనీ నిర్ణయాత్మక ప్రక్రియలలో మహిళల అభిప్రాయాలు చెప్పే అవకాశం మరియు విలువను ఇస్తారు.',
                  ),
                  buildQuestion(
                    context,
                    '2.	I feel that there are adequate channels for women to express their concerns and suggestions.',
                    'మహిళలు తమ సమస్యలను మరియు సూచనలను తెలియజేయడానికి తగిన ఛానెల్‌లు ఉన్నాయని నేను భావిస్తున్నాను.',
                  ),
                  buildQuestion(
                    context,
                    '3.	The company actively seeks input from women on matters that affect them.',
                    'కంపెనీ మహిళలను ప్రభావితం చేసే విషయాలపై వారి నుండి ఇన్‌పుట్‌ను చురుకుగా కోరుతుంది.',
                  ),
                  buildQuestion(
                    context,
                    '4.	Women are represented fairly in employee committees and working groups.',
                    'ఉద్యోగుల కమిటీలు మరియు వర్కింగ్ గ్రూపులలో మహిళా ఉద్యోగులు న్యాయంగా ప్రాతినిధ్యం వహిస్తారు.',
                  ),
                  buildQuestion(
                    context,
                    '5.	I believe that the company promotes a culture where women feel empowered to speak up.',
                    'మహిళలు మాట్లాడే అధికారం ఉన్న సంస్కృతిని కంపెనీ ప్రోత్సహిస్తుందని నేను నమ్ముతున్నాను.',
                  ),
                ],
              ),
              ExpansionTile(
                title: const Text(
                  'IV. Health & Safety ఆరోగ్యం & భద్రత',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                children: [
                  buildQuestion(
                    context,
                    '1.	The company provides adequate resources and support for the specific health and safety needs of women.',
                    'కంపెనీ మహిళల నిర్దిష్ట ఆరోగ్యం మరియు భద్రతా అవసరాలకు తగిన వనరులు మరియు మద్దతును అందిస్తుంది.',
                  ),
                  buildQuestion(
                    context,
                    '2.	The company\'s health and safety policies are sensitive to the needs of pregnant employees.',
                    'కంపెనీ ఆరోగ్య మరియు భద్రతా విధానాలు గర్భిణీ ఉద్యోగుల అవసరాలకు తగినట్లు సున్నితంగా ఉంటాయి.',
                  ),
                  buildQuestion(
                    context,
                    '3.	The company provides a safe and secure environment for all employees, regardless of gender.',
                    'కంపెనీ లింగంతో సంబంధం లేకుండా ఉద్యోగులందరికీ సురక్షితమైన వాతావరణాన్ని అందిస్తుంది.',
                  ),
                  buildQuestion(
                    context,
                    '4.	Health benefits are equally available and comprehensive for both men and women.',
                    'ఆరోగ్య ప్రయోజనాలు పురుషులు మరియు మహిళలు ఇద్దరికీ సమానంగా అందుబాటులో ఉంటాయి మరియు సమగ్రంగా ఉంటాయి.',
                  ),
                  buildQuestion(
                    context,
                    '5.	The company provides adequate facilities for women\'s hygiene and comfort.',
                    'సంస్థ మహిళల పరిశుభ్రత మరియు సౌకర్యానికి తగిన సౌకర్యాలను అందిస్తుంది.',
                  ),
                ],
              ),
              ExpansionTile(
                title: const Text(
                  'V. Gender-Based Violence (GBV) and Harassment & Abuse (H&A) లింగ-ఆధారిత హింస (GBV) మరియు వేధింపు & దుర్వినియోగం (H&A)',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                children: [
                  buildQuestion(
                    context,
                    '1.	The company has a clear policy against GBV and H&A.',
                    'GBV మరియు H&Aకి వ్యతిరేకంగా కంపెనీ స్పష్టమైన పాలసీ కలిగి ఉంది.',
                  ),
                  buildQuestion(
                    context,
                    '2.	I am aware of the procedures for reporting GBV and H&A.',
                    'GBV మరియు H&Aని నివేదించే విధానాల గురించి నాకు తెలుసు.',
                  ),
                  buildQuestion(
                    context,
                    '3.	I believe that reports of GBV and H&A are treated with confidentiality and sensitivity.',
                    'GBV మరియు H&A యొక్క నివేదికలు గోప్యత మరియు సున్నితత్వంతో పరిగణించబడతాయని నేను నమ్ముతున్నాను.',
                  ),
                  buildQuestion(
                    context,
                    '4.	The company provides training on preventing and addressing GBV and H&A.',
                    'సంస్థ GBV మరియు H&Aలను నిరోధించడం మరియు పరిష్కరించడంపై శిక్షణను అందిస్తుంది.',
                  ),
                  buildQuestion(
                    context,
                    '5.	I feel safe from GBV and H&A in the workplace.',
                    'నేను కార్యాలయంలో GBV మరియు H&A నుండి సురక్షితంగా ఉన్నాను.',
                  ),
                ],
              ),
              ExpansionTile(
                title: const Text(
                  'VI. Wages & Compensation వేతనాలు & పరిహారం ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                children: [
                  buildQuestion(
                    context,
                    '1.	I believe that men and women are paid equally for equal work.',
                    'సమాన పనికి స్త్రీ పురుషులకు సమాన వేతనం లభిస్తుందని నేను నమ్ముతున్నాను.',
                  ),
                  buildQuestion(
                    context,
                    '2	My salary accurately reflects my skills and experience.',
                    'నా జీతం నా నైపుణ్యాలు మరియు అనుభవాన్ని ఖచ్చితంగా ప్రతిబింబిస్తుంది.',
                  ),
                  buildQuestion(
                    context,
                    '3	I feel that my performance is fairly rewarded.',
                    'నా పనితీరుకు  తగిన ప్రతిఫలం లభించిందని నేను భావిస్తున్నాను.',
                  ),
                  buildQuestion(
                    context,
                    '4	The company\'s compensation policies are transparent and free from gender bias.',
                    'కంపెనీ పరిహార విధానాలు పారదర్శకంగా మరియు లింగ పక్షపాతం లేకుండా ఉంటాయి.',
                  ),
                  buildQuestion(
                    context,
                    '5	I understand how my compensation is determined and I am well aware of the overall benefits package offered by the company.',
                    'నా పరిహారం ఎలా నిర్ణయించబడుతుందో నాకు అర్థమైంది మరియు కంపెనీ అందించే మొత్తం ప్రయోజనాల ప్యాకేజీ గురించి నాకు బాగా తెలుసు.',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final responses = provider.responses;
                  print(responses);
                  // TODO: Send the responses to API
                },
                child: const Text('Submit Feedback'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildQuestion(
      BuildContext context, String question, String questionTelugu) {
    final provider = Provider.of<FeedbackProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(questionTelugu,
            style: const TextStyle(fontSize: 16, color: Colors.grey)),
        Column(
          children: [
            'Strongly Disagree గట్టిగా అంగీకరించలేదు',
            'Disagree అంగీకరించలేదు',
            'Neutral తటస్థంగా',
            'Agree అంగీకరిస్తున్నాను',
            'Strongly Agree గట్టిగా అంగీకరిస్తున్నాను'
          ]
              .map((option) => RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: provider.responses[question],
                    onChanged: (value) {
                      provider.setResponse(question, value!);
                    },
                  ))
              .toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
