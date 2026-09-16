class HuxiuDetailModel {
  int? id;
  late String title;
  late String url;
  String? summary;
  late String itemid;
  late String create;

  HuxiuDetailModel({
    this.id,
    required this.title,
    required this.url,
    this.summary,
    required this.itemid,
    required this.create,
  });

  HuxiuDetailModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
    summary = json['summary'];
    itemid = json['itemid'];
    create = json['create'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'summary': summary,
      'itemid': itemid,
      'create': create,
    };
  }
}
