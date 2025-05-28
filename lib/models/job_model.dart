class Job {
  final String title;
  final String company;
  final String location;

  Job({required this.title, required this.company, required this.location});

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      title: json['title'],
      company: json['company'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'company': company,
    'location': location,
  };
}

