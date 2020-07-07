class StorageUrl {
  String url;
  String title;
  String avatar;
  List<String> tags;
  String note;
  int createAt;
  StorageUrl(
      {this.url, this.title, this.avatar, this.tags, this.note, this.createAt});

  static StorageUrl fromMap(Map map) {
    return new StorageUrl(
        url: map['url'] as String,
        title: map['title'] as String,
        avatar: map['avatar'] as String,
        tags: map['tags'].split(' '),
        note: map['note'] as String,
        createAt: map['create_at'] as int);
  }

  Map<String, dynamic> toMap() => {
        "url": url,
        "title": title,
        "avatar": avatar,
        'tags': tags != null ? tags.join(' ') : 'tag',
        'note': note ?? 'bio',
        'create_at': createAt
      };
}
