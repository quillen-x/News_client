class SohuDetailModel {
  int? id;
  late String title;
  late String url;
  String? img;
  late String itemid;
  late String create;

  SohuDetailModel({
    this.id,
    required this.title,
    required this.url,
    this.img,
    required this.itemid,
    required this.create,
  });

  SohuDetailModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
    img = json['img'];
    itemid = json['itemid'];
    create = json['create'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'img': img,
      'itemid': itemid,
      'create': create,
    };
  }
}
