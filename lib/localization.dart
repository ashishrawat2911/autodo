import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AutodoLocalizations {
  static AutodoLocalizations of(BuildContext context) {
    return Localizations.of<AutodoLocalizations>(
      context,
      AutodoLocalizations,
    );
  }

  static String get appTitle => "auToDo";
  // TODO: change this for non-US locales
  static dateFormat(date) => (DateFormat("MM/dd/yyyy").format(date));
  static String get undo => "Undo";
  static todoDeleted(name) => "ToDo $name deleted.";
  static String get refuelingDeleted => "Refueling deleted.";
  static String get repeatDeleted => "Repeat deleted.";
  static String get firstTimeDoingTask => "First Time Doing This Task.";
  static String get dueAt => "Due At";
  static String get distanceUnits => "miles";
  static String get distanceUnitsShort => "(mi)";
  static String get dueOn => "Due on";
  static String get pastDue => "Past Due";
  static String get dueSoon => "Due Soon";
  static String get upcoming => "Upcoming";
  static String get totalCost => "Total Cost";
  static String get moneyUnits => "\$";
  static String get moneyUnitsSuffix => "(USD)";
  static String get totalAmount => "Total Amount";
  static String get fuelUnits => "gal";
  static String get onLiteral => "on";
  static String get refueling => "Refueling";
  static String get at => "at";
  static String get requiredLiteral => "Required";
  static String get optional => "Optional";
  static String get odomReading => "Odometer Reading";
  static String get totalPrice => "Total Price";
  static String get refuelingDate => "Refueling Date";
  static String get refuelingAmount => "Refueling Amount";
  static String get chooseDate => "Choose Date";
  static String get invalidDate => "Not a valid date";
  static String get addRefueling => "Add Refueling";
  static String get editRefueling => "Edit Refueling";
  static String get saveChanges => "Save Changes";
  static String get carName => "Car Name";
  static String get mileage => "Mileage";
  static String get todoDueSoon => "Maintenance ToDo Due Soon";
  static String get markAllIncomplete => "Mark All Incomplete";
  static String get markAllComplete => "Mark All Complete";
  static String get clearCompleted => "Clear Completed";
  static String get filterTodos => "Filter ToDos";
  static String get showAll => "Show All";
  static String get showActive => "Show Active";
  static String get showCompleted => "Show Completed";
  static String get todos => "ToDos";
  static String get refuelings => "Refuelings";
  static String get stats => "Stats";
  static String get repeats => "Repeats";
  static String get interval => "Interval";
  static String get dueDate => "Due Date";
  static String get signInWithGoogle => "Sign In with Google";
  static String get forgotYourPassword => "Forgot your password?";
  static String get login => "Login";
  static String get email => "Email";
  static String get password => "Password";
  static String get sendPasswordReset => "Send Password Reset";
  static String get createAnAccount => "Create an Account";
  static String get legal1 => "By signing up, you agree to the";
  static String get legal2 => "terms and conditions";
  static String get legal3 => "and";
  static String get legal4 => "privacy policy";
  static String get legal5 => "of the auToDo app.";
  static String get gotItBang => "Got It!";
  static String get send => "Send";
  static String get back => "Back";
  static String get loginFailure => "Login Failure";
  static String get loggingInEllipsis => "Logging in...";
  static String get signingUpEllipsis => "Signing up...";
  static String get signup => "Sign Up";
  static String get alreadyHaveAnAccount => "Already have an account?";
  static String get verifyEmail => "Verify Email";
  static String get verifyBodyText =>
      'An email has been sent to you with a link to verify your account.\n\nYou must verify your email to use auToDo.';
  static String get next => "Next";
  static String get editTodo => "Edit ToDo";
  static String get addTodo => "Add Todo";
  static String get repeatName => "Repeat Name";
  static String get editRepeat => "Edit Repeat";
  static String get addRepeat => "Add Repeat";
  static String get verificationSent => "Verification Email Sent";
  static String get verificationDialogContent =>
      "Please check the specified email address for an email from auToDo. This email will contain a link through which you can verify your account and use the app.";
  static String get completed => "Completed: ";
}

class AutodoLocalizationsDelegate
    extends LocalizationsDelegate<AutodoLocalizations> {
  @override
  Future<AutodoLocalizations> load(Locale locale) =>
      Future(() => AutodoLocalizations());

  @override
  bool shouldReload(AutodoLocalizationsDelegate old) => false;

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode.toLowerCase().contains("en");
}
