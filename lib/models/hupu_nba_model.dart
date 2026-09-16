class HupuNbaDetailModel {
  int? id;
  late String title;
  late String url;
  late String itemid;
  late String create;

  HupuNbaDetailModel({
    this.id,
    required this.title,
    required this.url,
    required this.itemid,
    required this.create,
  });

  HupuNbaDetailModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
    itemid = json['itemid'];
    create = json['create'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'itemid': itemid,
      'create': create,
    };
  }
}
