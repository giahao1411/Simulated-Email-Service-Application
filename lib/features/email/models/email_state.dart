class EmailState {
  EmailState({
    required this.emailId,
    this.read = false,
    this.starred = false,
    this.trashed = false,
    this.important = false,
    this.spam = false,
    this.hidden = false,
    this.labels = const [],
  });

  factory EmailState.fromMap(Map<String, dynamic> data) {
    return EmailState(
      emailId: data['emailId'] as String? ?? '',
      read: data['read'] as bool? ?? false,
      starred: data['starred'] as bool? ?? false,
      trashed: data['trashed'] as bool? ?? false,
      important: data['important'] as bool? ?? false,
      spam: data['spam'] as bool? ?? false,
      hidden: data['hidden'] as bool? ?? false,
      labels: (data['labels'] as List<dynamic>? ?? []).cast<String>(),
    );
  }

  final String emailId;
  final bool read;
  final bool starred;
  final bool trashed;
  final bool important;
  final bool spam;
  final bool hidden;
  final List<String> labels;

  Map<String, dynamic> toMap() {
    return {
      'emailId': emailId,
      'read': read,
      'starred': starred,
      'trashed': trashed,
      'important': important,
      'spam': spam,
      'hidden': hidden,
      'labels': labels,
    };
  }

  EmailState copyWith({
    String? emailId,
    bool? read,
    bool? starred,
    bool? trashed,
    bool? important,
    bool? spam,
    bool? hidden,
    List<String>? labels,
  }) {
    return EmailState(
      emailId: emailId ?? this.emailId,
      read: read ?? this.read,
      starred: starred ?? this.starred,
      trashed: trashed ?? this.trashed,
      important: important ?? this.important,
      spam: spam ?? this.spam,
      hidden: hidden ?? this.hidden,
      labels: labels ?? this.labels,
    );
  }
}
