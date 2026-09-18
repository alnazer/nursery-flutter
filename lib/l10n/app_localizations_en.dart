import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appNameParent => 'My Nursery';

  @override
  String get appNameStaff => 'My Nursery - Staff';

  @override
  String get tagline => 'Follow your child’s day, moment by moment';

  @override
  String get taglineStaff => 'Your day with the children, in one place';

  @override
  String get languageSwitch => 'العربية';

  @override
  String get continueLabel => 'Continue';

  @override
  String get signIn => 'Sign in';

  @override
  String get cancel => 'Cancel';

  @override
  String get retry => 'Try again';

  @override
  String get close => 'Close';

  @override
  String get later => 'Later';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginSubtitleMobile => 'Enter the mobile number registered with the nursery.';

  @override
  String get loginSubtitlePassword => 'Enter your sign-in details.';

  @override
  String get loginSubtitleStaff => 'Sign in with the username and password you use on the dashboard.';

  @override
  String get mobileLabel => 'Mobile number';

  @override
  String get identifierLabel => 'Username or email';

  @override
  String get usernameLabel => 'Username';

  @override
  String get passwordLabel => 'Password';

  @override
  String get smsNote => 'We’ll text a verification code to this number. We never share it.';

  @override
  String get notRegistered => 'Number not registered? Contact the nursery';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get forgotTitle => 'Reset your password';

  @override
  String get forgotSubtitle => 'Enter your registered email and we’ll send a reset link.';

  @override
  String get emailLabel => 'Email';

  @override
  String get send => 'Send';

  @override
  String get forgotSent => 'If the email is registered, a message is on its way.';

  @override
  String get otpTitle => 'Verification code';

  @override
  String otpSubtitle(String target) {
    return 'Enter the code sent to $target';
  }

  @override
  String get otpCodeLabel => 'Code';

  @override
  String get verify => 'Confirm';

  @override
  String get resend => 'Resend the code';

  @override
  String resendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get otpSent => 'A new code is on its way.';

  @override
  String get biometricLabel => 'Biometric sign-in';

  @override
  String biometricHint(String name) {
    return 'Biometrics are on for $name — tap the fingerprint to sign in';
  }

  @override
  String get biometricPromptTitle => 'Sign in';

  @override
  String get biometricPromptSubtitle => 'Use your biometrics to sign in';

  @override
  String get biometricEnableTitle => 'Turn on biometric sign-in';

  @override
  String get biometricEnableBody => 'Next time, sign in with your fingerprint or face instead of typing. Your biometrics never leave this device.';

  @override
  String get biometricEnableAction => 'Turn on biometrics';

  @override
  String get biometricEnabled => 'Biometric sign-in is on for this device.';

  @override
  String get biometricDisabled => 'Biometric sign-in is off for this device.';

  @override
  String get biometricFailedTitle => 'We couldn’t verify your biometrics';

  @override
  String get biometricRetry => 'Try again, or sign in the usual way.';

  @override
  String get biometricRevoked => 'Biometric sign-in was revoked on this device. Please sign in the usual way.';

  @override
  String get biometricLocked => 'Biometrics are locked after too many attempts. Sign in the usual way.';

  @override
  String get biometricNotEnrolled => 'No biometrics are enrolled on this device. Add them in your device settings first.';

  @override
  String get biometricUnavailable => 'This device doesn’t support biometric sign-in.';

  @override
  String get biometricReauth => 'Please sign in again before turning on biometrics.';

  @override
  String get networkError => 'We couldn’t reach the server. Check your connection and try again.';

  @override
  String get serverError => 'Something went wrong. Please try again.';

  @override
  String get configMissing => 'The app key isn’t set. Run the app with the --dart-define keys.';

  @override
  String get maintenanceTitle => 'Under maintenance';

  @override
  String get maintenanceBody => 'We’re making quick improvements. Please try again shortly.';

  @override
  String get updateTitle => 'Update the app';

  @override
  String get updateBody => 'This version is no longer supported. Update to continue.';

  @override
  String get updateAction => 'Update now';

  @override
  String get accountBlockedTitle => 'Account blocked from the app';

  @override
  String get accountBlockedBody => 'Please contact the nursery administration for details.';

  @override
  String get accountInactiveTitle => 'Account is not active';

  @override
  String get accountInactiveBody => 'Please contact the nursery administration to activate your account.';

  @override
  String get tooManyTitle => 'Too many attempts';

  @override
  String tooManyBody(int minutes) {
    return 'Try again in $minutes minutes.';
  }

  @override
  String get smsUnavailable => 'The SMS service is unavailable right now. Please contact the nursery.';

  @override
  String get otpUnavailable => 'No email is registered for your account to receive the code. Contact the administration.';

  @override
  String get sessionExpiredTitle => 'Session ended';

  @override
  String get sessionExpiredBody => 'Please sign in again to continue.';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutForget => 'Sign out and turn off biometrics';

  @override
  String get staffReplacedDevices => 'Your previous device was signed out — the staff app works on one device.';

  @override
  String welcome(String name) {
    return 'Welcome, $name';
  }

  @override
  String get homeParentTitle => 'Home';

  @override
  String get homeStaffTitle => 'Today';

  @override
  String get comingSoon => 'The rest of the screens are on the way.';

  @override
  String get securitySettings => 'Security & biometrics';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get navHome => 'Home';

  @override
  String get navActivities => 'Activities';

  @override
  String get navPayments => 'Payments';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navAccount => 'Account';

  @override
  String get navToday => 'Today';

  @override
  String get navStudents => 'Students';

  @override
  String get statusPresent => 'Present now';

  @override
  String get statusCheckedOut => 'Checked out';

  @override
  String get statusAbsent => 'Absent today';

  @override
  String get statusClosed => 'Closed today';

  @override
  String get statusNotArrived => 'Not arrived yet';

  @override
  String arrivedAt(String time) {
    return 'Arrived at $time';
  }

  @override
  String leftAt(String time) {
    return 'Left at $time';
  }

  @override
  String get childCard => 'Child profile';

  @override
  String get pendingTitle => 'Waiting for you';

  @override
  String get payNow => 'Pay now';

  @override
  String get acknowledge => 'Acknowledge';

  @override
  String get acknowledged => 'Acknowledged';

  @override
  String get needsAck => 'A circular needs your acknowledgement';

  @override
  String dueOn(String date) {
    return 'Due $date';
  }

  @override
  String get overdue => 'Overdue';

  @override
  String get servicesTitle => 'Services';

  @override
  String get serviceAttendance => 'Attendance';

  @override
  String get serviceInvoices => 'Invoices';

  @override
  String get serviceCirculars => 'Circulars';

  @override
  String get serviceEvents => 'Events';

  @override
  String get serviceCoupons => 'My coupons';

  @override
  String get todayActivity => 'Today’s activity';

  @override
  String get viewAll => 'View all';

  @override
  String get noActivityYet => 'No activity published yet.';

  @override
  String get activitiesTitle => 'Activities';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get invoicesTitle => 'Invoices';

  @override
  String get circularsTitle => 'Circulars';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get emptyList => 'Nothing here yet.';

  @override
  String get loadMore => 'Load more';

  @override
  String invoiceNumber(String number) {
    return 'Invoice #$number';
  }

  @override
  String get invoiceItems => 'Invoice items';

  @override
  String get attendanceTitle => 'Attendance today';

  @override
  String get statExpected => 'Expected';

  @override
  String get statIn => 'In';

  @override
  String get statOut => 'Out';

  @override
  String get statAbsent => 'Absent';

  @override
  String get statRemaining => 'Remaining';

  @override
  String get activitiesBoard => 'Activities';

  @override
  String get statAdded => 'Added';

  @override
  String get statPublished => 'Published';

  @override
  String get statMissing => 'Missing';

  @override
  String get windowOpenNow => 'The activity window is open now.';

  @override
  String get windowOpensIn => 'Opens in';

  @override
  String get windowClosesIn => 'Closes in';

  @override
  String get windowUpdating => 'Refreshing the window status…';

  @override
  String windowHoursNote(String hours) {
    return 'Adding hours $hours';
  }

  @override
  String windowReopensAt(String time) {
    return 'Reopens at $time';
  }

  @override
  String windowClosesAt(String time) {
    return 'Closes at $time';
  }

  @override
  String get pickStudent => 'Pick a student';

  @override
  String get windowClosed => 'The activity window is closed right now.';

  @override
  String get studentsTitle => 'Students';

  @override
  String get searchHint => 'Search by name';

  @override
  String get scanTitle => 'Scan card';

  @override
  String get attendanceMonthTitle => 'Attendance';

  @override
  String attendanceRate(String rate) {
    return 'Attendance rate $rate%';
  }

  @override
  String get schoolDays => 'School days';

  @override
  String get absentDays => 'Absent days';

  @override
  String get excusedDays => 'Excused';

  @override
  String get unexcusedDays => 'Unexcused';

  @override
  String get reportAbsence => 'Report an absence';

  @override
  String get absenceFrom => 'From';

  @override
  String get absenceTo => 'To';

  @override
  String get absenceNote => 'Reason';

  @override
  String get absenceSaved => 'Your report is saved.';

  @override
  String get absenceCancel => 'Cancel report';

  @override
  String get absenceCancelled => 'The report was cancelled.';

  @override
  String get upcomingAbsences => 'Upcoming reports';

  @override
  String get notesTitle => 'Teacher notes';

  @override
  String get devicesTitle => 'My devices';

  @override
  String get deviceCurrent => 'This device';

  @override
  String get deviceSignOut => 'Sign this device out';

  @override
  String get deviceSignedOut => 'The device was signed out.';

  @override
  String lastUsed(String time) {
    return 'Last used $time';
  }

  @override
  String get staffAttendanceTitle => 'Today’s attendance';

  @override
  String get markAbsentAction => 'Mark non-arrivals absent';

  @override
  String get markAbsentConfirm => 'Everyone who has not arrived today will be marked absent. Continue?';

  @override
  String get confirm => 'Confirm';

  @override
  String get filterAll => 'All';

  @override
  String get filterNotArrived => 'Not arrived';

  @override
  String get filterPresent => 'Present';

  @override
  String get filterAbsent => 'Absent';

  @override
  String get selectChild => 'Choose the child';

  @override
  String get pickDate => 'Pick a date';

  @override
  String get eventsTitle => 'Events';

  @override
  String get bookingsTitle => 'My bookings';

  @override
  String seatsLeft(String count) {
    return '$count seats left';
  }

  @override
  String priceFrom(String price) {
    return 'From $price';
  }

  @override
  String get eventProgram => 'Programme';

  @override
  String get eventChildren => 'Children';

  @override
  String get eligible => 'Eligible';

  @override
  String get notEligible => 'Not eligible';

  @override
  String get booked => 'Booked';

  @override
  String get bookingSoon => 'Booking from the app is on the way.';

  @override
  String participantsCount(String count) {
    return '$count participants';
  }

  @override
  String get cancelBooking => 'Cancel booking';

  @override
  String get bookingCancelled => 'The booking was cancelled.';

  @override
  String get cancelBookingConfirm => 'This booking will be cancelled. Continue?';

  @override
  String get staffActivitiesTitle => 'Student activities';

  @override
  String get addActivity => 'Add activity';

  @override
  String activityFor(String name) {
    return 'Activity for $name';
  }

  @override
  String activityDay(String date) {
    return 'Activity day $date';
  }

  @override
  String get activityNote => 'Teacher note';

  @override
  String get activityTemplates => 'Quick messages';

  @override
  String get publishNow => 'Publish now';

  @override
  String get saveActivity => 'Save activity';

  @override
  String get activitySaved => 'The activity is saved.';

  @override
  String get activityExists => 'This student already has an activity today.';

  @override
  String get activityBlocked => 'You can’t add an activity right now.';

  @override
  String get filterUnpublished => 'Awaiting publish';

  @override
  String get filterPublished => 'Published';

  @override
  String get publish => 'Publish';

  @override
  String get published => 'Published';

  @override
  String get publishAll => 'Publish all';

  @override
  String publishedCount(String count) {
    return 'Published $count activities.';
  }

  @override
  String addedBy(String name) {
    return 'Added by $name';
  }

  @override
  String get missingActivity => 'No activity';

  @override
  String get hrTitle => 'My HR';

  @override
  String get hrPresentDays => 'Days present';

  @override
  String get hrAbsentDays => 'Days absent';

  @override
  String get hrLeaveDays => 'Leave days';

  @override
  String get hrLateMinutes => 'Late minutes';

  @override
  String get hrBalances => 'Leave balances';

  @override
  String get leavesTitle => 'My leaves';

  @override
  String get newLeave => 'Request leave';

  @override
  String get leaveType => 'Leave type';

  @override
  String get leaveReason => 'Reason';

  @override
  String leaveDaysCount(String count) {
    return '$count days';
  }

  @override
  String get leaveSubmitted => 'Your request is submitted.';

  @override
  String get withdraw => 'Withdraw';

  @override
  String get withdrawn => 'The request was withdrawn.';

  @override
  String get violationsTitle => 'My violations';

  @override
  String get justify => 'Justify';

  @override
  String get justification => 'Justification';

  @override
  String get justifySent => 'Your justification was sent.';

  @override
  String decisionDeadline(String date) {
    return 'Deadline $date';
  }

  @override
  String minutesCount(String count) {
    return '$count minutes';
  }

  @override
  String balanceDays(String count) {
    return '$count days left';
  }

  @override
  String get paymentsTitle => 'My payments';

  @override
  String get paymentOpen => 'Open the payment page';

  @override
  String get paymentOpened => 'The payment page opened in your browser. When you are done, come back and tap “Check status”.';

  @override
  String get paymentCheck => 'Check status';

  @override
  String get paymentPaid => 'Payment completed.';

  @override
  String get paymentFailed => 'The payment did not go through.';

  @override
  String get paymentPending => 'The payment is still in progress.';

  @override
  String get receipt => 'Receipt';

  @override
  String invoicesCount(String count) {
    return '$count invoices';
  }

  @override
  String get cannotOpenLink => 'We couldn’t open the link.';

  @override
  String get hrAttendanceTitle => 'My attendance log';

  @override
  String get correctionsTitle => 'Correction requests';

  @override
  String get newCorrection => 'Request a correction';

  @override
  String get correctionKind => 'Punch type';

  @override
  String get correctionIn => 'Check-in';

  @override
  String get correctionOut => 'Check-out';

  @override
  String get correctionTime => 'Correct time';

  @override
  String get correctionReason => 'Reason';

  @override
  String get correctionSent => 'Your correction request was sent.';

  @override
  String expectedHours(String from, String to) {
    return 'Shift $from - $to';
  }

  @override
  String lateBy(String count) {
    return 'Late $count min';
  }

  @override
  String earlyBy(String count) {
    return 'Early $count min';
  }

  @override
  String get requestCorrectionForDay => 'Request a correction for this day';

  @override
  String get absencesTitle => 'Absences';

  @override
  String get couponsTitle => 'My coupons';

  @override
  String get subscriptionsTitle => 'Subscriptions';

  @override
  String get profileTitle => 'My details';

  @override
  String get nameLabel => 'Name';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get profileSaved => 'Your details are saved.';

  @override
  String get currentPassword => 'Current password';

  @override
  String get currentPasswordHint => 'Required to change the email.';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get resetPasswordHint => 'We’ll email you a reset link.';

  @override
  String couponValue(String value) {
    return 'Discount $value';
  }

  @override
  String couponEnds(String date) {
    return 'Ends $date';
  }

  @override
  String couponFor(String names) {
    return 'For $names';
  }

  @override
  String subscriptionPeriod(String from, String to) {
    return '$from to $to';
  }

  @override
  String daysLeft(String count) {
    return '$count days left';
  }

  @override
  String get currentSubscription => 'Current';

  @override
  String get requestStop => 'Request to stop';

  @override
  String get requestStopReason => 'Reason for stopping';

  @override
  String get requestStopSent => 'Your request was sent to the administration.';

  @override
  String get noChildSelected => 'Choose a child first';

  @override
  String get documentsTitle => 'Child documents';

  @override
  String get documentsMissing => 'Missing';

  @override
  String get documentsExpired => 'Expired';

  @override
  String get documentsExpiring => 'Expiring';

  @override
  String get documentOpen => 'Open document';

  @override
  String get cardTitle => 'Child card';

  @override
  String get cardHint => 'Show this code at the gate for check-in and check-out.';

  @override
  String get weeklyTitle => 'Weekly summary';

  @override
  String get weeklyPresent => 'Days present';

  @override
  String get weeklyAbsent => 'Days absent';

  @override
  String get weeklyActivities => 'Activities';

  @override
  String get mediaConsent => 'Allow photos to be shared';

  @override
  String get mediaConsentOn => 'Allowed';

  @override
  String get mediaConsentOff => 'Not allowed';

  @override
  String get studentTitle => 'Student profile';

  @override
  String get addNote => 'Add a note';

  @override
  String get notePositive => 'Positive';

  @override
  String get noteNegative => 'Needs follow-up';

  @override
  String get noteShare => 'Share with the parent';

  @override
  String get noteSaved => 'The note is saved.';

  @override
  String get markAbsent => 'Mark absent';

  @override
  String get absenceExcused => 'Excused';

  @override
  String get absenceUnexcused => 'Unexcused';

  @override
  String get absenceSavedStaff => 'The absence is recorded.';

  @override
  String get parentsLabel => 'Parents';

  @override
  String get teachersLabel => 'Teachers';

  @override
  String get bookNow => 'Book now';

  @override
  String get bookingTitle => 'Event booking';

  @override
  String get participants => 'Participants';

  @override
  String get bookingContact => 'Contact details';

  @override
  String get bookingAnswers => 'Booking details';

  @override
  String get bookingAddons => 'Add-ons';

  @override
  String get previewBooking => 'Preview the price';

  @override
  String bookingTotal(String total) {
    return 'Total $total';
  }

  @override
  String bookingDiscount(String amount) {
    return 'Discount $amount';
  }

  @override
  String get willWait => 'Not enough seats — the booking will go on the waiting list.';

  @override
  String get consentText => 'I agree to the event participation terms.';

  @override
  String get confirmBooking => 'Confirm booking';

  @override
  String get bookingCreated => 'Your booking is confirmed.';

  @override
  String get payBooking => 'Pay for the booking';

  @override
  String get fileFieldWeb => 'This form needs a file — please finish the booking on the nursery website.';

  @override
  String get selectAtLeastOne => 'Select at least one participant.';

  @override
  String get quantity => 'Quantity';

  @override
  String get scanIn => 'Scan check-in';

  @override
  String get scanOut => 'Scan check-out';

  @override
  String get scanAgain => 'Scan another card';

  @override
  String get scanMode => 'Scan mode';

  @override
  String get scanCancelled => 'Scanning was cancelled.';

  @override
  String get scanUnavailable => 'The camera isn’t available on this device.';

  @override
  String get scanCardUnknown => 'Unrecognised card.';

  @override
  String get attachFile => 'Attach a file';

  @override
  String get attachmentRequired => 'This type requires an attachment.';

  @override
  String get removeAttachment => 'Remove attachment';

  @override
  String get addDocument => 'Upload a document';

  @override
  String get documentTitle => 'Document title';

  @override
  String get documentExpires => 'Expiry date (optional)';

  @override
  String get documentUploaded => 'The document was uploaded.';

  @override
  String get uploading => 'Uploading…';

  @override
  String get errorNotFoundTitle => 'Not found';

  @override
  String get errorNotFoundBody => 'We couldn’t find it. It may have been removed or changed.';

  @override
  String get errorForbiddenTitle => 'No permission';

  @override
  String get errorForbiddenBody => 'This page isn’t available for your account. Please contact the nursery.';

  @override
  String get errorNetworkTitle => 'No connection';

  @override
  String get errorServerTitle => 'Server error';

  @override
  String get errorServerBody => 'Something went wrong on our side. Please try again shortly.';

  @override
  String get errorValidationTitle => 'Check your input';

  @override
  String get errorSessionTitle => 'Session ended';

  @override
  String get errorDetails => 'Technical details';

  @override
  String retryIn(String seconds) {
    return 'Try again in ${seconds}s';
  }

  @override
  String get goBack => 'Back';

  @override
  String get errorConflictTitle => 'Couldn’t complete that';

  @override
  String get errorConfigTitle => 'App configuration error';

  @override
  String get errorConfigBody => 'The server keys are incorrect. Please tell the developer.';

  @override
  String get errorReauthTitle => 'Sign in again';

  @override
  String get errorTooLargeTitle => 'File too large';

  @override
  String get errorDemoTitle => 'Demo version';

  @override
  String get errorGatewayTitle => 'Payment gateway unavailable';

  @override
  String get errorCardTitle => 'Unrecognised card';

  @override
  String get errorAccountBlockedTitle => 'Account blocked';

  @override
  String get errorAccountInactiveTitle => 'Account inactive';

  @override
  String get cardFront => 'Front';

  @override
  String get cardBack => 'Back';

  @override
  String get cardDownload => 'Download card';

  @override
  String get cardSaved => 'Card saved';

  @override
  String get cardSaveCancelled => 'Saving cancelled';

  @override
  String get cardSaveFailed => 'Could not render the card image';

  @override
  String minLengthHint(String count) {
    return 'At least $count characters';
  }

  @override
  String get payslipsTitle => 'My salary';

  @override
  String get payslipsEmpty => 'No approved payslips yet.';

  @override
  String get payslipTitle => 'Payslip';

  @override
  String get payslipLast => 'Latest salary';

  @override
  String get payslipNet => 'Net';

  @override
  String get payslipGross => 'Gross';

  @override
  String get payslipDeductions => 'Deductions';

  @override
  String get payslipEarnings => 'Earnings';

  @override
  String get payslipBasic => 'Basic salary';

  @override
  String get payslipUnpaidDays => 'Unpaid days';

  @override
  String get payslipOvertime => 'Overtime';

  @override
  String get payslipBank => 'Bank';

  @override
  String payslipPaidOn(String date) {
    return 'Paid on $date';
  }

  @override
  String get checkoutTitle => 'Pay due invoices';

  @override
  String get checkoutEmpty => 'No due invoices right now.';

  @override
  String get checkoutTotal => 'Total';

  @override
  String checkoutSelected(String count) {
    return '$count invoices selected';
  }

  @override
  String checkoutBusy(String number, String time) {
    return 'Invoice $number is being paid by another parent until $time';
  }

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get couponLabel => 'Discount code';

  @override
  String get couponApply => 'Apply';

  @override
  String couponSuggested(String code, String amount) {
    return 'Coupon available $code — $amount off';
  }

  @override
  String get couponUse => 'Use it';

  @override
  String get invoicePdf => 'Download invoice';

  @override
  String get invoicePdfFailed => 'Could not generate the invoice copy.';

  @override
  String get editActivity => 'Edit activity';

  @override
  String get deleteActivity => 'Delete activity';

  @override
  String get deleteActivityConfirm => 'The activity and its entries will be deleted. Continue?';

  @override
  String get activityDeleted => 'Activity deleted';

  @override
  String get activityPublished => 'Activity published';

  @override
  String get activityUnpublished => 'Activity unpublished';

  @override
  String get unpublish => 'Unpublish';

  @override
  String get delete => 'Delete';

  @override
  String get allClassrooms => 'All classrooms';

  @override
  String get undoAbsence => 'Undo absence';

  @override
  String get undoAbsenceConfirm => 'Today\'s absence record for this student will be removed.';

  @override
  String get absenceRemoved => 'Absence record removed';

  @override
  String get filterUnread => 'Unread';

  @override
  String get filterUnacked => 'Needs acknowledgement';

  @override
  String get filterDue => 'Due';

  @override
  String get filterPaid => 'Paid';

  @override
  String get filterUnpaid => 'Unpaid';

  @override
  String get filterExpired => 'Expired';

  @override
  String get filterPending => 'In progress';

  @override
  String get filterFailed => 'Failed';

  @override
  String get filterCurrent => 'Current';

  @override
  String get filterUpcoming => 'Upcoming';

  @override
  String get filterUnviewed => 'Unseen';

  @override
  String get filterForMyChildren => 'For my children';

  @override
  String get filterActive => 'Active';

  @override
  String get filterConfirmed => 'Confirmed';

  @override
  String get filterCancelled => 'Cancelled';

  @override
  String get eventTrip => 'Trips';

  @override
  String get eventActivity => 'Activities';

  @override
  String get eventWorkshop => 'Workshops';

  @override
  String get eventCamp => 'Camps';

  @override
  String get eventCelebration => 'Celebrations';

  @override
  String get acceptBooking => 'Accept booking';

  @override
  String get bookingAccepted => 'Booking accepted';

  @override
  String get renewBooking => 'Renew hold';

  @override
  String get bookingRenewed => 'Payment hold renewed';

  @override
  String get bookingInvoice => 'Invoice';

  @override
  String get surveyTitle => 'Event survey';

  @override
  String get surveySent => 'Thanks for your feedback';

  @override
  String get surveyAlreadySent => 'You submitted feedback before; sending now replaces it.';

  @override
  String get surveyNotes => 'Notes';

  @override
  String get attachments => 'Attachments';

  @override
  String get openAttachment => 'Open attachment';

  @override
  String get downloading => 'Downloading…';

  @override
  String get fileSaved => 'File saved';

  @override
  String get assignActivities => 'Assign activities';

  @override
  String get activitiesAssigned => 'Activities assigned';

  @override
  String couponAccepted(String discount, String total) {
    return '$discount off — total after discount $total';
  }

  @override
  String get activityPdf => 'Download daily report';

  @override
  String get disablePush => 'Turn off notifications on this device';

  @override
  String get pushDisabled => 'Notifications turned off on this device';

  @override
  String get filterEveryone => 'Everyone';

  @override
  String get filterMine => 'Added by me';

  @override
  String get copy => 'Copy';

  @override
  String get couponCopied => 'Code copied';

  @override
  String get couponNoInvoices => 'No due invoices this coupon applies to.';

  @override
  String get showInvoice => 'View invoice';

  @override
  String get allChildren => 'All children';

  @override
  String get scanHint => 'Scan the child card from the Attendance tab to check in or out.';

  @override
  String get showAmounts => 'Show amounts';

  @override
  String get hideAmounts => 'Hide amounts';

  @override
  String get leaveTypesEmpty => 'No active leave types right now. Contact the system administrator.';

  @override
  String get balancesEmpty => 'No leave balances recorded on your profile.';

  @override
  String get withdrawLeaveConfirm => 'The leave request will be withdrawn and no longer reviewed. Continue?';

  @override
  String get working => 'Working…';

  @override
  String get scanSending => 'Sending the card…';

  @override
  String get markAbsentBusy => 'Marking absences…';

  @override
  String get formHiddenUntilOpen => 'The form appears automatically once the window opens.';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get photoUploading => 'Uploading the photo…';

  @override
  String get photoUpdated => 'Photo updated';

  @override
  String get markPresent => 'Mark present';

  @override
  String get markPresentNote => 'Checks the child in now and clears today\'s absence.';

  @override
  String get markCheckedOut => 'Check out';

  @override
  String get markCheckedOutNote => 'Records that the child left now.';

  @override
  String get markUnexcused => 'Unexcused absence';

  @override
  String get markUnexcusedNote => 'Recorded as absent and the parent is notified.';

  @override
  String get markExcused => 'Excused absence';

  @override
  String get markExcusedNote => 'Asks for the reason, then records it and notifies the parent.';

  @override
  String markAbsentOneConfirm(String name) {
    return '$name will be marked absent today and the parent notified. Continue?';
  }

  @override
  String get absenceReason => 'Absence reason';

  @override
  String get saved => 'Saved';

  @override
  String get studentActions => 'Student actions';
}
