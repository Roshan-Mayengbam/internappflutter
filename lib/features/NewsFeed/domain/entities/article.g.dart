// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArticleAdapter extends TypeAdapter<Article> {
  @override
  final int typeId = 0;

  @override
  Article read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Article(
      id: fields[0] as String,
      webTitle: fields[1] as String,
      sectionName: fields[2] as String,
      webPublicationDate: fields[3] as DateTime,
      webUrl: fields[4] as String,
      apiUrl: fields[5] as String,
      thumbnailUrl: fields[6] as String,
      byline: fields[7] as String,
      bodyHtml: fields[8] as String,
      trailText: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Article obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.webTitle)
      ..writeByte(2)
      ..write(obj.sectionName)
      ..writeByte(3)
      ..write(obj.webPublicationDate)
      ..writeByte(4)
      ..write(obj.webUrl)
      ..writeByte(5)
      ..write(obj.apiUrl)
      ..writeByte(6)
      ..write(obj.thumbnailUrl)
      ..writeByte(7)
      ..write(obj.byline)
      ..writeByte(8)
      ..write(obj.bodyHtml)
      ..writeByte(9)
      ..write(obj.trailText);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArticleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
