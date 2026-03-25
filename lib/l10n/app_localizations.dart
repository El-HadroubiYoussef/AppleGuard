import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Apple Disease Detector'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @assistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get assistant;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @analyzeLeafDisease.
  ///
  /// In en, this message translates to:
  /// **'Analyze Apple Leaf Disease'**
  String get analyzeLeafDisease;

  /// No description provided for @takePhotoOrSelect.
  ///
  /// In en, this message translates to:
  /// **'Take a photo or select from gallery'**
  String get takePhotoOrSelect;

  /// No description provided for @startAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Start Analysis'**
  String get startAnalysis;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing leaf image...'**
  String get analyzing;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get newChat;

  /// No description provided for @askAboutAppleTrees.
  ///
  /// In en, this message translates to:
  /// **'Ask me about apple trees'**
  String get askAboutAppleTrees;

  /// No description provided for @diseasesCareTreatment.
  ///
  /// In en, this message translates to:
  /// **'Diseases, care, treatment, and more'**
  String get diseasesCareTreatment;

  /// No description provided for @typeYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get typeYourMessage;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @clearAllData.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data'**
  String get clearAllData;

  /// No description provided for @deleteAllAnalysesAndChat.
  ///
  /// In en, this message translates to:
  /// **'Delete all analyses and chat history'**
  String get deleteAllAnalysesAndChat;

  /// No description provided for @thisActionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone'**
  String get thisActionCannotBeUndone;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @switchBetweenLightDark.
  ///
  /// In en, this message translates to:
  /// **'Switch between light and dark theme'**
  String get switchBetweenLightDark;

  /// No description provided for @aiConfiguration.
  ///
  /// In en, this message translates to:
  /// **'AI Configuration'**
  String get aiConfiguration;

  /// No description provided for @apiKey.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get apiKey;

  /// No description provided for @saveApiKey.
  ///
  /// In en, this message translates to:
  /// **'Save API Key'**
  String get saveApiKey;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @noAnalysesYet.
  ///
  /// In en, this message translates to:
  /// **'No analyses yet'**
  String get noAnalysesYet;

  /// No description provided for @startByAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Start by analyzing a leaf image'**
  String get startByAnalyzing;

  /// No description provided for @disease.
  ///
  /// In en, this message translates to:
  /// **'Disease'**
  String get disease;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidence;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @analysisId.
  ///
  /// In en, this message translates to:
  /// **'Analysis ID'**
  String get analysisId;

  /// No description provided for @detailedAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Detailed Analysis'**
  String get detailedAnalysis;

  /// No description provided for @classLabel.
  ///
  /// In en, this message translates to:
  /// **'Class Label'**
  String get classLabel;

  /// No description provided for @probability.
  ///
  /// In en, this message translates to:
  /// **'Probability'**
  String get probability;

  /// No description provided for @rawLogit.
  ///
  /// In en, this message translates to:
  /// **'Raw Logit'**
  String get rawLogit;

  /// No description provided for @aiAnalysis.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis'**
  String get aiAnalysis;

  /// No description provided for @chatWithAi.
  ///
  /// In en, this message translates to:
  /// **'Chat with AI'**
  String get chatWithAi;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @newAnalysis.
  ///
  /// In en, this message translates to:
  /// **'New Analysis'**
  String get newAnalysis;

  /// No description provided for @totalAnalyses.
  ///
  /// In en, this message translates to:
  /// **'Total Analyses'**
  String get totalAnalyses;

  /// No description provided for @avgConfidence.
  ///
  /// In en, this message translates to:
  /// **'Avg Confidence'**
  String get avgConfidence;

  /// No description provided for @diseaseDistribution.
  ///
  /// In en, this message translates to:
  /// **'Disease Distribution'**
  String get diseaseDistribution;

  /// No description provided for @dailyVolume.
  ///
  /// In en, this message translates to:
  /// **'Daily Analysis Volume'**
  String get dailyVolume;

  /// No description provided for @confidenceTrend.
  ///
  /// In en, this message translates to:
  /// **'Confidence Trend'**
  String get confidenceTrend;

  /// No description provided for @exportAsCsv.
  ///
  /// In en, this message translates to:
  /// **'Export as CSV'**
  String get exportAsCsv;

  /// No description provided for @noDataToExport.
  ///
  /// In en, this message translates to:
  /// **'No data to export for the selected period'**
  String get noDataToExport;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your internet connection.'**
  String get networkError;

  /// No description provided for @invalidApiKey.
  ///
  /// In en, this message translates to:
  /// **'Invalid API key. Please check your settings.'**
  String get invalidApiKey;

  /// No description provided for @cameraError.
  ///
  /// In en, this message translates to:
  /// **'Could not access camera. Please check permissions.'**
  String get cameraError;

  /// No description provided for @imageProcessingError.
  ///
  /// In en, this message translates to:
  /// **'Could not process image. Please try another image.'**
  String get imageProcessingError;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// No description provided for @apiKeyRequired.
  ///
  /// In en, this message translates to:
  /// **'Please configure your API key in Settings first.'**
  String get apiKeyRequired;

  /// No description provided for @analysisComplete.
  ///
  /// In en, this message translates to:
  /// **'Analysis complete!'**
  String get analysisComplete;

  /// No description provided for @analysisFailed.
  ///
  /// In en, this message translates to:
  /// **'Analysis failed'**
  String get analysisFailed;

  /// No description provided for @deletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get deletedSuccessfully;

  /// No description provided for @errorDeleting.
  ///
  /// In en, this message translates to:
  /// **'Error deleting'**
  String get errorDeleting;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @selectImageSource.
  ///
  /// In en, this message translates to:
  /// **'Select Image Source'**
  String get selectImageSource;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @appleScab.
  ///
  /// In en, this message translates to:
  /// **'Apple scab'**
  String get appleScab;

  /// No description provided for @fireBlight.
  ///
  /// In en, this message translates to:
  /// **'Fire blight'**
  String get fireBlight;

  /// No description provided for @howToPrune.
  ///
  /// In en, this message translates to:
  /// **'How to prune'**
  String get howToPrune;

  /// No description provided for @organicTreatment.
  ///
  /// In en, this message translates to:
  /// **'Organic treatment'**
  String get organicTreatment;

  /// No description provided for @fertilizerSchedule.
  ///
  /// In en, this message translates to:
  /// **'Fertilizer schedule'**
  String get fertilizerSchedule;

  /// No description provided for @pestControl.
  ///
  /// In en, this message translates to:
  /// **'Pest control'**
  String get pestControl;

  /// No description provided for @alternariaLeafSpot.
  ///
  /// In en, this message translates to:
  /// **'Alternaria leaf spot'**
  String get alternariaLeafSpot;

  /// No description provided for @brownSpot.
  ///
  /// In en, this message translates to:
  /// **'Brown spot'**
  String get brownSpot;

  /// No description provided for @graySpot.
  ///
  /// In en, this message translates to:
  /// **'Gray spot'**
  String get graySpot;

  /// No description provided for @healthyLeaf.
  ///
  /// In en, this message translates to:
  /// **'Healthy leaf'**
  String get healthyLeaf;

  /// No description provided for @rust.
  ///
  /// In en, this message translates to:
  /// **'Rust'**
  String get rust;

  /// No description provided for @processingTime.
  ///
  /// In en, this message translates to:
  /// **'Processing Time'**
  String get processingTime;

  /// No description provided for @uncertainty.
  ///
  /// In en, this message translates to:
  /// **'Uncertainty'**
  String get uncertainty;

  /// No description provided for @highConfidence.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get highConfidence;

  /// No description provided for @mediumConfidence.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get mediumConfidence;

  /// No description provided for @lowConfidence.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get lowConfidence;

  /// No description provided for @diseaseDescription.
  ///
  /// In en, this message translates to:
  /// **'Disease Description'**
  String get diseaseDescription;

  /// No description provided for @treatmentRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Treatment Recommendations'**
  String get treatmentRecommendations;

  /// No description provided for @organicOptions.
  ///
  /// In en, this message translates to:
  /// **'Organic Options'**
  String get organicOptions;

  /// No description provided for @chemicalOptions.
  ///
  /// In en, this message translates to:
  /// **'Chemical Options'**
  String get chemicalOptions;

  /// No description provided for @preventionTips.
  ///
  /// In en, this message translates to:
  /// **'Prevention Tips'**
  String get preventionTips;

  /// No description provided for @whenToAct.
  ///
  /// In en, this message translates to:
  /// **'When to Act'**
  String get whenToAct;

  /// No description provided for @additionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes'**
  String get additionalNotes;

  /// No description provided for @analysisInfo.
  ///
  /// In en, this message translates to:
  /// **'Analysis Info'**
  String get analysisInfo;

  /// No description provided for @askAboutLeafAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Ask about your leaf analysis'**
  String get askAboutLeafAnalysis;

  /// No description provided for @sendingAnalysisData.
  ///
  /// In en, this message translates to:
  /// **'Sending analysis data...'**
  String get sendingAnalysisData;

  /// No description provided for @typeQuestionAboutDisease.
  ///
  /// In en, this message translates to:
  /// **'Type your question about the disease'**
  String get typeQuestionAboutDisease;

  /// No description provided for @askAboutDisease.
  ///
  /// In en, this message translates to:
  /// **'Ask about the disease...'**
  String get askAboutDisease;

  /// No description provided for @aiAnalysisAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis Assistant'**
  String get aiAnalysisAssistant;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @feedbackType.
  ///
  /// In en, this message translates to:
  /// **'Feedback Type'**
  String get feedbackType;

  /// No description provided for @suggestion.
  ///
  /// In en, this message translates to:
  /// **'Suggestion'**
  String get suggestion;

  /// No description provided for @bugReport.
  ///
  /// In en, this message translates to:
  /// **'Bug Report'**
  String get bugReport;

  /// No description provided for @featureRequest.
  ///
  /// In en, this message translates to:
  /// **'Feature Request'**
  String get featureRequest;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'This app helps farmers and gardeners detect apple tree diseases using AI. Simply take a photo of a leaf and get instant diagnosis with treatment recommendations.'**
  String get appDescription;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How It Works'**
  String get howItWorks;

  /// No description provided for @minMax.
  ///
  /// In en, this message translates to:
  /// **'Min/Max'**
  String get minMax;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'days ago'**
  String get daysAgo;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @diagnosisResults.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis Results'**
  String get diagnosisResults;

  /// No description provided for @detectedDisease.
  ///
  /// In en, this message translates to:
  /// **'Detected Disease'**
  String get detectedDisease;

  /// No description provided for @aiAnalysisPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please provide a comprehensive analysis in the following format:'**
  String get aiAnalysisPrompt;

  /// No description provided for @diseaseDescriptionPrompt.
  ///
  /// In en, this message translates to:
  /// **'Brief description of the disease and common symptoms'**
  String get diseaseDescriptionPrompt;

  /// No description provided for @organicTreatmentPrompt.
  ///
  /// In en, this message translates to:
  /// **'List organic treatments'**
  String get organicTreatmentPrompt;

  /// No description provided for @chemicalTreatmentPrompt.
  ///
  /// In en, this message translates to:
  /// **'List chemical treatments if necessary'**
  String get chemicalTreatmentPrompt;

  /// No description provided for @preventionPrompt.
  ///
  /// In en, this message translates to:
  /// **'List prevention strategies'**
  String get preventionPrompt;

  /// No description provided for @severityPrompt.
  ///
  /// In en, this message translates to:
  /// **'Severity indicators and urgency levels'**
  String get severityPrompt;

  /// No description provided for @additionalNotesPrompt.
  ///
  /// In en, this message translates to:
  /// **'Any other relevant information'**
  String get additionalNotesPrompt;

  /// No description provided for @responseGuidance.
  ///
  /// In en, this message translates to:
  /// **'Keep the response practical and helpful for farmers. Use emojis and clear sections.'**
  String get responseGuidance;

  /// No description provided for @rateLimitReached.
  ///
  /// In en, this message translates to:
  /// **'API Rate Limit Reached'**
  String get rateLimitReached;

  /// No description provided for @rateLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'The AI service is currently experiencing high demand. Please try again in a few minutes.'**
  String get rateLimitMessage;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @checkApiQuota.
  ///
  /// In en, this message translates to:
  /// **'Check your API quota'**
  String get checkApiQuota;

  /// No description provided for @tryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Try again later'**
  String get tryAgainLater;

  /// No description provided for @useLocalAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Use the local analysis results for immediate action'**
  String get useLocalAnalysis;

  /// No description provided for @localDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Local diagnosis shows'**
  String get localDiagnosis;

  /// No description provided for @apiKeyRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'API Key Configuration Required'**
  String get apiKeyRequiredTitle;

  /// No description provided for @invalidApiKeyMessage.
  ///
  /// In en, this message translates to:
  /// **'Your API key appears to be invalid or not properly configured.'**
  String get invalidApiKeyMessage;

  /// No description provided for @whatToDo.
  ///
  /// In en, this message translates to:
  /// **'What to do'**
  String get whatToDo;

  /// No description provided for @goToSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to'**
  String get goToSettings;

  /// No description provided for @verifyApiKey.
  ///
  /// In en, this message translates to:
  /// **'Verify your API key is correct'**
  String get verifyApiKey;

  /// No description provided for @clickTestConnection.
  ///
  /// In en, this message translates to:
  /// **'Click'**
  String get clickTestConnection;

  /// No description provided for @testConnection.
  ///
  /// In en, this message translates to:
  /// **'Test Connection'**
  String get testConnection;

  /// No description provided for @toValidate.
  ///
  /// In en, this message translates to:
  /// **'to validate'**
  String get toValidate;

  /// No description provided for @saveAndRetry.
  ///
  /// In en, this message translates to:
  /// **'Save the key and try again'**
  String get saveAndRetry;

  /// No description provided for @serviceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Service Temporarily Unavailable'**
  String get serviceUnavailable;

  /// No description provided for @unableToFetchAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Unable to fetch detailed AI analysis at this moment.'**
  String get unableToFetchAnalysis;

  /// No description provided for @checkInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection'**
  String get checkInternetConnection;

  /// No description provided for @verifyApiConfig.
  ///
  /// In en, this message translates to:
  /// **'Verify API configuration in Settings'**
  String get verifyApiConfig;

  /// No description provided for @localAnalysisComplete.
  ///
  /// In en, this message translates to:
  /// **'Local Analysis Complete'**
  String get localAnalysisComplete;

  /// No description provided for @basicRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Basic Recommendations'**
  String get basicRecommendations;

  /// No description provided for @removeAffectedLeaves.
  ///
  /// In en, this message translates to:
  /// **'Remove and dispose of affected leaves'**
  String get removeAffectedLeaves;

  /// No description provided for @ensureAirCirculation.
  ///
  /// In en, this message translates to:
  /// **'Ensure good air circulation around trees'**
  String get ensureAirCirculation;

  /// No description provided for @monitorOtherTrees.
  ///
  /// In en, this message translates to:
  /// **'Monitor other trees for symptoms'**
  String get monitorOtherTrees;

  /// No description provided for @orchardSanitation.
  ///
  /// In en, this message translates to:
  /// **'Practice good orchard sanitation'**
  String get orchardSanitation;

  /// No description provided for @avoidOverheadWatering.
  ///
  /// In en, this message translates to:
  /// **'Avoid overhead watering'**
  String get avoidOverheadWatering;

  /// No description provided for @applyPreventativeTreatments.
  ///
  /// In en, this message translates to:
  /// **'Apply preventative treatments in early spring'**
  String get applyPreventativeTreatments;

  /// No description provided for @detailedAiAdvice.
  ///
  /// In en, this message translates to:
  /// **'For detailed AI advice'**
  String get detailedAiAdvice;

  /// No description provided for @configureApiKey.
  ///
  /// In en, this message translates to:
  /// **'Please configure your API key in'**
  String get configureApiKey;

  /// No description provided for @getPersonalizedPlans.
  ///
  /// In en, this message translates to:
  /// **'to get personalized treatment plans.'**
  String get getPersonalizedPlans;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
