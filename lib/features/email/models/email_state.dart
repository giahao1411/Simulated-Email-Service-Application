class EmailState {
  EmailState({
    required this.emailId,
    this.read = false,
    this.starred = false,
    this.trashed = false,
    this.labels = const [],
  });

  factory EmailState.fromMap(Map<String, dynamic> data) {
    return EmailState(
      emailId: data['emailId'] as String? ?? '',
      read: data['read'] as bool? ?? false,
      starred: data['starred'] as bool? ?? false,
      trashed: data['trashed'] as bool? ?? false,
      labels: (data['labels'] as List<dynamic>? ?? []).cast<String>(),
    );
  }

  final String emailId;
  final bool read;
  final bool starred;
  final bool trashed;
  final List<String> labels;

  Map<String, dynamic> toMap() {
    return {
      'emailId': emailId,
      'read': read,
      'starred': starred,
      'trashed': trashed,
      'labels': labels,
    };
  }

  EmailState copyWith({
    String? emailId,
    bool? read,
    bool? starred,
    bool? trashed,
    List<String>? labels,
  }) {
    return EmailState(
      emailId: emailId ?? this.emailId,
      read: read ?? this.read,
      starred: starred ?? this.starred,
      trashed: trashed ?? this.trashed,
      labels: labels ?? this.labels,
    );
  }
}
