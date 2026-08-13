class ZHDetailModel {
  late int id;
  late String title;
  late String url;
  late String type;
  String? thumbnail;
  late String created;
  late String excerpt;

  ZHDetailModel(
      {required this.id,
      required this.title,
      required this.url,
      required this.type,
      this.thumbnail,
      required this.created,
      required this.excerpt});

  ZHDetailModel.fromJson(Map<String, dynamic> json) {
    id = _asInt(json['id']) ?? 0;
    title = json['title']?.toString() ?? '';
    url = json['url']?.toString() ?? '';
    type = json['type']?.toString() ?? '';
    thumbnail = json['thumbnail']?.toString();
    created = json['created']?.toString() ?? '';
    excerpt = json['excerpt']?.toString() ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['title'] = title;
    data['url'] = url;
    data['type'] = type;
    data['thumbnail'] = thumbnail;
    data['created'] = created;
    data['excerpt'] = excerpt;
    return data;
  }
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

String? _asString(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

class ZhiHuModel {
  List<ZHModel>? data;
  Paging? paging;
  String? freshText;
  int? displayNum;
  int? fbBillMainRise;

  ZhiHuModel(
      {this.data,
      this.paging,
      this.freshText,
      this.displayNum,
      this.fbBillMainRise});

  ZhiHuModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ZHModel>[];
      json['data'].forEach((v) {
        data!.add(ZHModel.fromJson(v));
      });
    }
    paging = json['paging'] != null ? Paging.fromJson(json['paging']) : null;
    freshText = _asString(json['fresh_text']);
    displayNum = _asInt(json['display_num']);
    fbBillMainRise = _asInt(json['fb_bill_main_rise']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (paging != null) {
      data['paging'] = paging!.toJson();
    }
    data['fresh_text'] = freshText;
    data['display_num'] = displayNum;
    data['fb_bill_main_rise'] = fbBillMainRise;
    return data;
  }
}

class ZHModel {
  String? type;
  String? styleType;
  String? id;
  String? cardId;
  Target? target;
  String? attachedInfo;
  String? detailText;
  int? trend;
  bool? debut;
  List<Children>? children;

  ZHModel(
      {this.type,
      this.styleType,
      this.id,
      this.cardId,
      this.target,
      this.attachedInfo,
      this.detailText,
      this.trend,
      this.debut,
      this.children});

  ZHModel.fromJson(Map<String, dynamic> json) {
    type = _asString(json['type']);
    styleType = _asString(json['style_type']);
    id = _asString(json['id']);
    cardId = _asString(json['card_id']);
    target = json['target'] != null ? Target.fromJson(json['target']) : null;
    attachedInfo = _asString(json['attached_info']);
    detailText = _asString(json['detail_text']);
    trend = _asInt(json['trend']);
    debut = json['debut'] is bool ? json['debut'] as bool : null;
    if (json['children'] != null) {
      children = [];
      json['children'].forEach((v) {
        children!.add(Children.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['style_type'] = styleType;
    data['id'] = id;
    data['card_id'] = cardId;
    if (target != null) {
      data['target'] = target!.toJson();
    }
    data['attached_info'] = attachedInfo;
    data['detail_text'] = detailText;
    data['trend'] = trend;
    data['debut'] = debut;
    if (children != null) {
      data['children'] = children!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Target {
  int? id;
  String? title;
  String? excerptTitle;
  String? type;
  int? voteupCount;
  int? voting;
  int? commentCount;
  String? url;
  String? imageUrl;
  int? updated;
  int? created;
  String? commentPermission;
  Author? author;
  Linkbox? linkbox;
  String? excerpt;
  String? excerptNew;
  String? previewType;
  String? previewText;

  Target(
      {this.id,
      this.title,
      this.excerptTitle,
      this.type,
      this.voteupCount,
      this.voting,
      this.commentCount,
      this.url,
      this.imageUrl,
      this.updated,
      this.created,
      this.commentPermission,
      this.author,
      this.linkbox,
      this.excerpt,
      this.excerptNew,
      this.previewType,
      this.previewText});

  Target.fromJson(Map<String, dynamic> json) {
    id = _asInt(json['id']);
    title = _asString(json['title']);
    excerptTitle = _asString(json['excerpt_title']);
    type = _asString(json['type']);
    voteupCount = _asInt(json['voteup_count']);
    voting = _asInt(json['voting']);
    commentCount = _asInt(json['comment_count']);
    url = _asString(json['url']);
    imageUrl = _asString(json['image_url']);
    updated = _asInt(json['updated']);
    created = _asInt(json['created']);
    commentPermission = _asString(json['comment_permission']);
    author = json['author'] != null ? Author.fromJson(json['author']) : null;
    linkbox =
        json['linkbox'] != null ? Linkbox.fromJson(json['linkbox']) : null;
    excerpt = _asString(json['excerpt']);
    excerptNew = _asString(json['excerpt_new']);
    previewType = _asString(json['preview_type']);
    previewText = _asString(json['preview_text']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['excerpt_title'] = excerptTitle;
    data['type'] = type;
    data['voteup_count'] = voteupCount;
    data['voting'] = voting;
    data['comment_count'] = commentCount;
    data['url'] = url;
    data['image_url'] = imageUrl;
    data['updated'] = updated;
    data['created'] = created;
    data['comment_permission'] = commentPermission;
    if (author != null) {
      data['author'] = author!.toJson();
    }
    if (linkbox != null) {
      data['linkbox'] = linkbox!.toJson();
    }
    data['excerpt'] = excerpt;
    data['excerpt_new'] = excerptNew;
    data['preview_type'] = previewType;
    data['preview_text'] = previewText;
    return data;
  }
}

class Author {
  String? type;
  String? userType;
  String? id;
  String? urlToken;
  String? url;
  String? name;
  String? headline;
  String? avatarUrl;

  Author(
      {this.type,
      this.userType,
      this.id,
      this.urlToken,
      this.url,
      this.name,
      this.headline,
      this.avatarUrl});

  Author.fromJson(Map<String, dynamic> json) {
    type = _asString(json['type']);
    userType = _asString(json['user_type']);
    id = _asString(json['id']);
    urlToken = _asString(json['url_token']);
    url = _asString(json['url']);
    name = _asString(json['name']);
    headline = _asString(json['headline']);
    avatarUrl = _asString(json['avatar_url']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['user_type'] = userType;
    data['id'] = id;
    data['url_token'] = urlToken;
    data['url'] = url;
    data['name'] = name;
    data['headline'] = headline;
    data['avatar_url'] = avatarUrl;
    return data;
  }
}

class Linkbox {
  String? pic;
  String? title;
  String? url;
  String? category;

  Linkbox({this.pic, this.title, this.url, this.category});

  Linkbox.fromJson(Map<String, dynamic> json) {
    pic = json['pic'];
    title = json['title'];
    url = json['url'];
    category = json['category'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pic'] = pic;
    data['title'] = title;
    data['url'] = url;
    data['category'] = category;
    return data;
  }
}

class Children {
  String? type;
  String? thumbnail;

  Children({this.type, this.thumbnail});

  Children.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    thumbnail = json['thumbnail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['thumbnail'] = thumbnail;
    return data;
  }
}

class Paging {
  bool? isEnd;
  String? next;
  String? previous;

  Paging({this.isEnd, this.next, this.previous});

  Paging.fromJson(Map<String, dynamic> json) {
    isEnd = json['is_end'];
    next = json['next'];
    previous = json['previous'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['is_end'] = isEnd;
    data['next'] = next;
    data['previous'] = previous;
    return data;
  }
}
